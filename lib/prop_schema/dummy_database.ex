defmodule PropSchema.DummyDatabase do
  @moduledoc """
    Since this library uses macros, I can't provide a mix task for dummy data. I can, however, provide a `use` statement
    where you simply have to plug the schema's module, the additional_properties module (optional), and the repo's module.
    Place that statement in the mix tasks and you'll be able to create dummy data for that model.
  """

  @doc """
  Creates a mix task for creating dummy data in the provided database repo.

  ### Options

  * `module`: The module where the schema is located. Will be the same as found in other places in this library.
  * `additional_properties`: The module where the additional defined properties (using the `PropSchema.AdditionalProperties`
    behaviour) are located. It is optional.
  * `repo`: The module where `Ecto.Repo` is implemented.
  """
  defmacro __using__(usage_args) do
    quote do
      use Mix.Task

      alias PropSchema.Stream
      require Stream
      require Logger

      Stream.generate_complete_map(
        unquote(usage_args[:module]),
        unquote(usage_args[:additional_properties])
      )

      def run(args) do
        generate_and_insert(
          unquote(usage_args[:module]),
          unquote(usage_args[:repo]),
          parse_count(args),
          0
        )
      end

      defp parse_count(args) do
        {[count: count]} = OptionParser.parse(args, strict: [count: :integer])
        count
      end

      defp generate_and_insert(module, repo, count, tries \\ 0)

      defp generate_and_insert(module, repo, count, tries) when count != 0 and tries >= 5 do
        Logger.error(fn ->
          "Maximum retry threshold met. Couldn't create #{count} records without conflicts."
        end)
      end

      defp generate_and_insert(module, repo, count, tries) when count == 0 do
        Logger.info(fn -> "Success!" end)
      end

      defp generate_and_insert(module, repo, count, tries) do
        results = module |> generate(count) |> insert(repo, module)
        Logger.info("Was able to insert #{results}/#{count} records during try ##{tries}.")
        generate_and_insert(module, repo, count - results, tries + 1)
      end

      defp generate(module, count) do
        records =
          __MODULE__
          |> apply(:"complete_#{mod_name(module)}", [])
          |> Enum.take(count)

        Logger.debug(fn -> "Generated #{count} new records" end)
        records
      end

      defp insert(items, repo, module) do
        {count, _} = repo.insert_all(module, items, on_conflict: :nothing)
        Logger.debug(fn -> "Inserted #{count} new records without conflicts" end)
        count
      end

      defp mod_name(mod) do
        mod |> elem(2) |> List.last() |> Atom.to_string() |> Macro.underscore()
      end
    end
  end
end
