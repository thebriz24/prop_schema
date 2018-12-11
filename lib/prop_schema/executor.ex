defmodule PropSchema.Executor do
  @moduledoc """
    Reads the `prop_schema` information from the provided module. Then it constructs a series of prop tests according to provided field requirements and other considerations declared in the schema.
    Once the tests are all constructed the tests will run through the normal `mix test` routine.
  """

  alias PropSchema.BaseProperties, as: Properties
  alias PropSchema.Types

  @type prop_test_args :: [to_test: atom(), additional_properties: atom()]

  @doc """
  Call in a test file to generate and execute property tests for the given schema, `[to_test: module]`. `[additional_properties: module]` is used to provide properties not yet implemented in the base `PropSchema.BaseProperties` module.

  ## Example

      defmodule PropSchemaTest do
        use PropSchema.Executor,
          to_test: PropSchema.TestModule,
          additional_properties: PropSchema.TestAdditionalProperties
      end
  """
  @spec __using__(prop_test_args()) :: Types.ast_expression()
  defmacro __using__(args) do
    quote do
      use ExUnitProperties
      use ExUnit.Case
      import PropSchema.Executor
      require Logger

      Module.eval_quoted(__ENV__, [prop_test(unquote(args))])
    end
  end

  @doc """
   Can be used independently, but personally I'd just use `__using__/1`.
  """
  @spec prop_test(prop_test_args()) :: Types.ast_expression()
  defmacro prop_test(args) do
    quote do
      [
        # credo:disable-for-next-line
        PropSchema.Executor.__create_prop_test__(
          unquote(args[:to_test]),
          :all_fields,
          unquote(args[:to_test]).__prop_schema__(),
          unquote(args[:additional_properties])
        ),
        # credo:disable-for-next-line
        PropSchema.Executor.__create_prop_test__(
          unquote(args[:to_test]),
          unquote(args[:to_test]).__prop_schema__(),
          unquote(args[:additional_properties])
        )
      ]
    end
  end

  def __create_prop_test__(mod, :all_fields, props, additional_props) do
    generators = generate_props(props, additional_props)

    quote do
      property "valid changeset" do
        check all map <- fixed_map(unquote(generators)) do
          changeset = unquote(mod).changeset(struct(unquote(mod)), map)

          if not changeset.valid?,
            do: Logger.error("Test will fail because: #{inspect(changeset.errors)}")

          assert changeset.valid?
        end
      end
    end
  end

  def __create_prop_test__(mod, props, additional_props) do
    Enum.map(
      props,
      fn
        {field, {_, %{default: default, required: true}}} = prop when not is_nil(default) ->
          generators = generate_props(prop, props, additional_props)

          quote do
            property "valid changeset - missing #{unquote(field)}" do
              check all map <- fixed_map(unquote(generators)) do
                changeset = unquote(mod).changeset(struct(unquote(mod)), map)

                if not changeset.valid?,
                  do: Logger.error("Test will fail because: #{inspect(changeset.errors)}")

                assert changeset.valid?
              end
            end
          end

        {field, {_, %{required: true}}} = prop ->
          generators = generate_props(prop, props, additional_props)

          quote do
            property "invalid changeset - missing #{unquote(field)}" do
              check all map <- fixed_map(unquote(generators)) do
                changeset = unquote(mod).changeset(struct(unquote(mod)), map)

                if changeset.valid?, do: Logger.error("Test will fail because: No errors")
                refute changeset.valid?
              end
            end
          end

        {field, _} = prop ->
          generators = generate_props(prop, props, additional_props)

          quote do
            property "valid changeset - missing #{unquote(field)}" do
              check all map <- fixed_map(unquote(generators)) do
                changeset = unquote(mod).changeset(struct(unquote(mod)), map)

                if not changeset.valid?,
                  do: Logger.error("Test will fail because: #{inspect(changeset.errors)}")

                assert changeset.valid?
              end
            end
          end
      end
    )
  end

  defp generate_props(props, additional_props) do
    props
    |> Enum.map(fn {field, {type, opts}} -> generate_prop(field, type, opts, additional_props) end)
    |> generate_misc(nil, additional_props)
    |> Enum.reject(&is_nil(&1))
  end

  defp generate_props({excluded, _}, props, additional_props) do
    props
    |> Enum.map(fn
      {field, {type, opts}} when field != excluded ->
        generate_prop(field, type, opts, additional_props)

      _ ->
        nil
    end)
    |> generate_misc(excluded, additional_props)
    |> Enum.reject(&is_nil(&1))
  end

  defp generate_misc(properties, _excluded, nil), do: properties

  defp generate_misc(properties, excluded, additional_props) do
    additional_props
    |> apply(:generate_misc, [excluded])
    |> Kernel.++(properties)
    |> List.flatten()
  rescue
    _ -> properties
  end

  defp generate_prop(field, type, opts, nil), do: Properties.generate_prop(field, type, opts)

  defp generate_prop(field, type, opts, additional_props) do
    case apply(additional_props, :generate_prop, [field, type, opts]) do
      nil ->
        Properties.generate_prop(field, type, opts)

      expression ->
        expression
    end
  end
end
