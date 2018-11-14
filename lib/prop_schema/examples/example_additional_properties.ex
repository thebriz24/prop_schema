defmodule PropSchema.ExampleAdditionalProperties do
  @moduledoc false
  @behaviour PropSchema.AdditionalProperties
  use ExUnitProperties

  def generate_prop(field, :float, %{positive: true, required: true}) do
    quote do
      {unquote(Atom.to_string(field)), float(min: 1)}
    end
  end

  def generate_prop(_field, _type, _opts), do: nil
end
