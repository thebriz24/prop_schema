defmodule PropSchema.TestHarness do
  @moduledoc """
    Reads the `prop_schema` information from the provided module. Then it constructs a series of prop tests according to provided field requirements and other considerations declared in the schema.
    Once the tests are all constructed the tests will run through the normal `mix test` routine.
  """

  alias PropSchema.Generator
  require Generator

  @type prop_test_args :: [to_test: atom(), additional_properties: atom(), modifications: atom()]

  @doc """
  Call in a test file to generate and execute property tests for the given 
  schema, `[to_test: module]` or `[schema: module, changeset: {module, function}]`.
  `[additional_properties: module]` is used to provide properties not yet 
  implemented in the base `PropSchema.BaseProperties` module.

  ## Example

      defmodule PropSchemaTest do
        use PropSchema.TestHarness,
          to_test: PropSchema.TestModule,
          additional_properties: PropSchema.TestAdditionalProperties
      end
  """
  @spec __using__(prop_test_args()) :: Macro.t()
  defmacro __using__(args) do
    quote do
      use ExUnitProperties
      use ExUnit.Case
      import PropSchema.TestHarness
      require Logger

      Module.eval_quoted(__ENV__, [prop_test(unquote(args))])
    end
  end

  @doc false
  defmacro prop_test(args) do
    schema = schema_from_args(args)
    changeset = changeset_from_args(args)

    quote do
      [
        # credo:disable-for-next-line
        PropSchema.TestHarness.__create_prop_test__(
          unquote(schema),
          unquote(changeset),
          :all_fields,
          unquote(args[:additional_properties]),
          unquote(args[:modifications])
        ),
        # credo:disable-for-next-line
        PropSchema.TestHarness.__create_prop_test__(
          unquote(schema),
          unquote(changeset),
          unquote(args[:additional_properties]),
          unquote(args[:modifications])
        )
      ]
    end
  end

  def __create_prop_test__(schema, changeset, :all_fields, additional_props, modifications) do
    Generator.generate_valid_prop_test(schema, changeset, additional_props, modifications)
  end

  def __create_prop_test__({mod, func} = schema, changeset, additional_props, modifications) do
    Enum.map(
      apply(mod, func, []),
      fn
        {_, {_, %{default: default, required: true}}} = prop when not is_nil(default) ->
          Generator.generate_valid_prop_test(
            schema,
            changeset,
            prop,
            additional_props,
            modifications
          )

        {_, {_, %{required: true}}} = prop ->
          Generator.generate_invalid_prop_test(
            schema,
            changeset,
            prop,
            additional_props,
            modifications
          )

        prop ->
          Generator.generate_valid_prop_test(
            schema,
            changeset,
            prop,
            additional_props,
            modifications
          )
      end
    )
  end

  defp schema_from_args(args) do
    if not is_nil(args[:schema]),
      do: {args[:schema], :__prop_schema__},
      else: {args[:to_test], :__prop_schema__}
  end

  defp changeset_from_args(args) do
    if not is_nil(args[:changeset]), do: args[:changeset], else: {args[:to_test], :changeset}
  end
end
