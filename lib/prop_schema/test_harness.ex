defmodule PropSchema.TestHarness do
  @moduledoc """
    Reads the `prop_schema` information from the provided module. Then it constructs a series of prop tests according to provided field requirements and other considerations declared in the schema.
    Once the tests are all constructed the tests will run through the normal `mix test` routine.
  """

  alias PropSchema.Generator
  require Generator

  @type prop_test_args :: [to_test: atom(), additional_properties: atom()]

  @doc """
  Call in a test file to generate and execute property tests for the given schema, `[to_test: module]`. `[additional_properties: module]` is used to provide properties not yet implemented in the base `PropSchema.BaseProperties` module.

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
    quote do
      [
        # credo:disable-for-next-line
        PropSchema.TestHarness.__create_prop_test__(
          unquote(args[:to_test]),
          :all_fields,
          unquote(args[:to_test]).__prop_schema__(),
          unquote(args[:additional_properties])
        ),
        # credo:disable-for-next-line
        PropSchema.TestHarness.__create_prop_test__(
          unquote(args[:to_test]),
          unquote(args[:to_test]).__prop_schema__(),
          unquote(args[:additional_properties])
        )
      ]
    end
  end

  def __create_prop_test__(mod, :all_fields, props, additional_props) do
    Generator.generate_valid_prop_test(mod, props, additional_props)
  end

  def __create_prop_test__(mod, props, additional_props) do
    Enum.map(
      props,
      fn
        {_, {_, %{default: default, required: true}}} = prop when not is_nil(default) ->
          Generator.generate_valid_prop_test(mod, prop, props, additional_props)

        {_, {_, %{required: true}}} = prop ->
          Generator.generate_invalid_prop_test(mod, prop, props, additional_props)

        prop ->
          Generator.generate_valid_prop_test(mod, prop, props, additional_props)
      end
    )
  end
end
