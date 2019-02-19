defmodule PropSchema.ExampleAdditionalProperties do
  @moduledoc false
  @behaviour PropSchema.AdditionalProperties

  @impl PropSchema.AdditionalProperties
  def generate_prop(field, :float, %{positive: true, required: true}) do
    quote do
      {unquote(Atom.to_string(field)), StreamData.float(min: 1)}
    end
  end

  def generate_prop(_field, _type, _opts), do: nil

  @impl PropSchema.AdditionalProperties
  def generate_misc(_) do
    quote do
      [{unquote(Atom.to_string(:unused)), StreamData.integer()}]
    end
  end
end
