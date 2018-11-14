defmodule PropSchema do
  @moduledoc """
    An extension on `Ecto.Schema` where you can provide additional options, which will be read by the corresponding
    `PropSchema.Executor` module, used in the test files to generate property tests.
  """

  alias PropSchema.Types

  defmacro __using__(_opts) do
    quote do
      import PropSchema, only: [prop_schema: 2, prop_embedded: 1]
      use Ecto.Schema
      Module.register_attribute(__MODULE__, :prop_schema_fields, accumulate: true)
    end
  end

  @doc """
  Declares an `Ecto.Schema` with additional mechanisms that will be used under the hood to generate property tests
  using `PropSchema.Executor`.

  ## Field Declaration

  When a field is declared with `prop_field/3` it will add the extra values to the
  additional mechanisms, but a field can just be declared with `Ecto.Schema.field/3` and `PropSchema.Executor` will
  not know about it.

  ## Examples

      prop_schema "example" do
        prop_field(:example_string, :string, string_type: :alphanumeric, required: true)
        prop_field(:example_int, :integer, postive: true, required: false)
        field(:example_float, :float)
      end
  """
  @spec prop_schema(String.t(), do: Types.ast_expression()) :: Types.ast_expression()
  defmacro prop_schema(source, do: block) do
    schema(source, block)
  end

  @doc """
  High school english class time! `prop_embedded/1` is to `prop_schema/2` as `Ecto.Schema.embedded_schema/1` is to `Ecto.Schema.schema/2`

  ## Examples

      prop_embedded do
        prop_field(:example_string, :string, string_type: :alphanumeric, required: true)
        prop_field(:example_int, :integer, postive: true, required: false)
        field(:example_float, :float)
      end
  """
  @spec prop_embedded(do: Types.ast_expression()) :: Types.ast_expression()
  defmacro prop_embedded(do: block) do
    embedded_schema(block)
  end

  defp schema(source, block) do
    quote do
      try do
        import PropSchema
        schema(unquote(source), do: unquote(block))
      after
        :ok
      end

      Module.eval_quoted(__ENV__, [
        PropSchema.__prop_schema__(@prop_schema_fields)
      ])
    end
  end

  defp embedded_schema(block) do
    quote do
      try do
        import PropSchema
        embedded_schema(do: unquote(block))
      after
        :ok
      end

      Module.eval_quoted(__ENV__, [
        PropSchema.__prop_schema__(@prop_schema_fields)
      ])
    end
  end

  @doc """
    Declares a field in the schema, processes it for use in `PropSchema.Executor` and then passes it through to `Ecto.Schema.field/3`. See `prop_schema/2` for examples.
  """
  @spec prop_field(atom(), atom(), keyword()) :: Types.ast_expression()
  defmacro prop_field(name, type \\ :string, opts \\ []) do
    quote do
      PropSchema.__field__(__MODULE__, unquote(name), unquote(type), unquote(opts))
      field(unquote(name), unquote(type), unquote(opts))
    end
  end

  def __field__(mod, name, type, opts) do
    Module.put_attribute(mod, :prop_schema_fields, {name, {type, Enum.into(opts, %{})}})
  end

  def __prop_schema__(prop_schema_fields) do
    map = prop_schema_fields |> Enum.into(%{}) |> Macro.escape()

    quote do
      def __prop_schema__, do: unquote(map)
    end
  end
end
