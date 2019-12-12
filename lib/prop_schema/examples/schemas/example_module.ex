defmodule PropSchema.ExampleModule do
  @moduledoc false
  use PropSchema
  alias Ecto.Changeset
  @options ["maybe this one", "or this one"]

  @foreign_key_type :binary_id
  prop_embedded_schema do
    prop_field(:test_string, :string, one_of: @options, required: true)
    prop_field(:test_int, :integer, positive: true, required: false)
    prop_field(:test_float, :float, positive: true, required: true)
  end

  def changeset(schema, data) do
    schema
    |> Changeset.cast(data, [:test_string, :test_int, :test_float])
    |> Changeset.validate_required([:test_string, :test_float])
    |> Changeset.validate_inclusion(:test_string, @options)
  end
end
