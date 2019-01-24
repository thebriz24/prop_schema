defmodule PropSchema.ExampleOwner do
  @moduledoc false
  use PropSchema
  alias Ecto.Changeset

  @primary_key {:uid, :binary_id, autogenerate: true}
  prop_schema "test_owner" do
    prop_has_one(:test_subjects, PropSchema.ExampleModule,
      additional_props: PropSchema.ExampleAdditionalProperties
    )
  end

  def changeset(schema, data) do
    schema
    |> Changeset.cast(data, [])
    |> Changeset.cast_assoc(:test_subjects)
  end
end
