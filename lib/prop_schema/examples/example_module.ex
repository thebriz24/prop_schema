defmodule PropSchema.ExampleModule do
  @moduledoc false
  use PropSchema
  alias Ecto.Changeset

  @foreign_key_type :binary_id
  prop_schema "test" do
    prop_field(:test_string, :string, string_type: :alphanumeric, required: true)
    prop_field(:test_int, :integer, positive: true, required: false)
    prop_field(:test_float, :float, positive: true, required: true)

    prop_belongs_to(:example_owner, PropSchema.ExampleOwner,
      foreign_key: :example_owner_uid,
      references: :uid,
      type: :binary_id,
      required: true
    )
  end

  def changeset(schema, data) do
    schema
    |> Changeset.cast(data, [:test_string, :test_int, :test_float, :example_owner_uid])
    |> Changeset.validate_required([:test_string, :test_float, :example_owner_uid])
  end
end
