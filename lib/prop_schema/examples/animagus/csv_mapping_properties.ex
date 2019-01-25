defmodule Animagus.CSVMappingProperties do
  @moduledoc false

  @behaviour PropSchema.AdditionalProperties
  import StreamData

  @impl PropSchema.AdditionalProperties
  def generate_prop(field, :string, %{default: value, string_type: :ascii, required: true}) do
    quote do
      {unquote(Atom.to_string(field)),
       one_of([string([?!..?~], min_length: 1), constant(unquote(value))])}
    end
  end

  def generate_prop(field, :string, %{default: value, string_type: type, required: true})
      when type == :ascii or type == :alphanumeric do
    quote do
      {unquote(Atom.to_string(field)),
       one_of([string(unquote(type), min_length: 1), constant(unquote(value))])}
    end
  end

  def generate_prop(field, :string, %{string_type: type, limited_values: true})
      when type == :ascii or type == :alphanumeric do
    quote do
      {unquote(Atom.to_string(field)),
       one_of([constant("(?<last>.*),\s*(?<first>.*)"), constant("(?<first>.*)\s+(?<last>.*)")])}
    end
  end

  def generate_prop(field, :integer, %{first: first, last: last, required: true}) do
    range = quote do: unquote(first)..unquote(last)

    quote do
      {unquote(Atom.to_string(field)), integer(unquote(range))}
    end
  end

  def generate_prop(field, :integer, %{first: first, last: last}) do
    range = quote do: unquote(first)..unquote(last)

    quote do
      {unquote(Atom.to_string(field)), one_of([integer(unquote(range)), constant(nil)])}
    end
  end

  def generate_prop(:file_regex = field, _, %{default: value}) do
    quote do
      {unquote(Atom.to_string(field)),
       one_of([
         string(Enum.concat([?a..?z, ?A..?Z, ?0..?9, [?., ?*, ?/, ?[, ?]]]), min_length: 1),
         constant(unquote(value))
       ])}
    end
  end

  def generate_prop(_field, _type, _opts), do: nil

  @impl PropSchema.AdditionalProperties
  def generate_misc(_), do: []
end
