defmodule PropSchema.ExampleModule do
  @moduledoc false
  use PropSchema
  alias Ecto.Changeset

  prop_embedded do
    prop_field(:test_string, :string, string_type: :alphanumeric, required: true)
    prop_field(:test_int, :integer, positive: true, required: false)
    prop_field(:test_float, :float, positive: true, required: true)
  end

  def changeset(schema, data) do
    schema
    |> Changeset.cast(data, [:test_string, :test_int, :test_float])
    |> Changeset.validate_required([:test_string, :test_float])
  end
end
