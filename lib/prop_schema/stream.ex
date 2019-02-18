defmodule PropSchema.Stream do
  @moduledoc """
  Reads the `prop_schema` information from the provided module. Then it constructs a series of private functions to
  include in a test module according to provided field requirements and other considerations declared in the schema.
  """

  alias PropSchema.Generator
  require Generator

  @doc """
  Creates the quoted fixed_map expression like you would find in the property tests but can be used at your discretion.

  ## Example

      defmodule Test do
        require PropSchema.Stream
        PropSchema.Stream.generate_complete_map(PropSchema.ExampleModule, PropSchema.ExampleAdditionalProperties)

        def get_ten(), do: Enum.take(complete(), 10)
      end
  """
  @spec generate_complete_map(atom(), atom()) :: Macro.t()
  defmacro generate_complete_map(mod, additional_props \\ nil) do
    schema = Macro.expand_once(mod, __ENV__).__prop_schema__()
    adds = Macro.expand_once(additional_props, __ENV__)

    quote do
      defp unquote({:"complete_#{mod_name(mod)}", [context: Elixir], Elixir}) do
        unquote(Generator.generate_complete_map(schema, adds))
      end
    end
  end

  @doc """
  Creates the quoted fixed_map expression but with the specified `missing_prop` excluded.

  ## Example

      defmodule Test do
        require PropSchema.Stream
        PropSchema.Stream.generate_incomplete_map(PropSchema.ExampleModule, :test_int, PropSchema.ExampleAdditionalProperties)

        def get_ten(excluded), do: excluded |> incomplete() |> Enum.take(10)
      end
  """
  @spec generate_incomplete_map(atom(), atom(), atom()) :: Macro.t()
  defmacro generate_incomplete_map(mod, excluded, additional_props \\ nil) do
    schema = Macro.expand_once(mod, __ENV__)
    adds = Macro.expand_once(additional_props, __ENV__)
    quoted_map(mod, schema, excluded, adds)
  end

  @doc """
  Scans the schema and calls `generate_incomplete_map/3` for each field as the `missing_prop`

  ## Example

        defmodule Test do
          require PropSchema.Stream
          PropSchema.Stream.generate_all_incomplete_maps(PropSchema.ExampleModule, PropSchema.ExampleAdditionalProperties)

          def get_ten(excluded), do: excluded |> incomplete() |> Enum.take(10)
        end
  """
  @spec generate_all_incomplete_maps(atom(), atom()) :: Macro.t()
  defmacro generate_all_incomplete_maps(mod, additional_props \\ nil) do
    schema = Macro.expand_once(mod, __ENV__)
    adds = Macro.expand_once(additional_props, __ENV__)
    quoted = Enum.map(schema.__prop_schema__(), &quoted_map(mod, schema, &1, adds))
    {:__block__, [], quoted}
  end

  defp quoted_map(mod, schema, {excluded, _}, additional_props),
    do: quoted_map(mod, schema, excluded, additional_props)

  defp quoted_map(mod, schema, excluded, additional_props) do
    quote do
      defp unquote(:"incomplete_#{mod_name(mod)}")(unquote(excluded)) do
        unquote(
          Generator.generate_incomplete_map(excluded, schema.__prop_schema__(), additional_props)
        )
      end
    end
  end

  defp mod_name(mod) do
    mod |> elem(2) |> List.last() |> Atom.to_string() |> Macro.underscore()
  end
end
