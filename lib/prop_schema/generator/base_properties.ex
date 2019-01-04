defmodule PropSchema.BaseProperties do
  @moduledoc false

  # Private moduledoc:
  # Base collection of properties according to their requirement and other considerations.
  # See `PropSchema.AdditionalProperties` for how to add to this collection or override any of these.

  alias PropSchema.Types

  @doc """
  Covers a few cases of the `integer` and `string` types. For integers `required` and `positive` are provided. For strings `required` and `string_type` are provided.
  """
  @spec generate_prop(atom(), :integer | :string, %{optional(atom()) => atom() | boolean()}) ::
          Types.ast_expression()
  def generate_prop(field, type, opts)

  def generate_prop(field, :integer, %{positive: true, required: true}) do
    quote do
      {unquote(Atom.to_string(field)), StreamData.positive_integer()}
    end
  end

  def generate_prop(field, :integer, %{required: true}) do
    quote do
      {unquote(Atom.to_string(field)), StreamData.integer()}
    end
  end

  def generate_prop(field, :integer, %{positive: true, required: false}) do
    quote do
      {unquote(Atom.to_string(field)),
       StreamData.one_of([StreamData.positive_integer(), StreamData.constant(nil)])}
    end
  end

  def generate_prop(field, :integer, %{required: false}) do
    quote do
      {unquote(Atom.to_string(field)),
       StreamData.one_of([StreamData.integer(), StreamData.constant(nil)])}
    end
  end

  def generate_prop(field, :integer, %{positive: true}),
    do: generate_prop(field, :integer, %{positive: true, required: false})

  def generate_prop(field, :integer, _), do: generate_prop(field, :integer, %{required: false})

  def generate_prop(field, :string, %{string_type: type, required: true})
      when type == :ascii or type == :alphanumeric do
    quote do
      {unquote(Atom.to_string(field)), StreamData.string(unquote(type), min_length: 1)}
    end
  end

  def generate_prop(field, :string, %{string_type: type, required: false})
      when type == :ascii or type == :alphanumeric do
    quote do
      {unquote(Atom.to_string(field)),
       StreamData.one_of([StreamData.string(unquote(type)), StreamData.constant(nil)])}
    end
  end

  def generate_prop(field, :string, %{string_type: type})
      when type == :ascii or type == :alphanumeric do
    generate_prop(field, :string, %{string_type: type, required: false})
  end

  def generate_prop(_field, _type, _opts), do: nil
end
