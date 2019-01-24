defmodule Animagus.CSVMapping do
  @moduledoc """
    A model for the csv_mappings table. Include functionality for changeset validations and display/index lookups.
  """

  use PropSchema
  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  @allowed_regexes [
    %{"Last,First" => "(?<last>.*),\s*(?<first>.*)"},
    %{"First Last" => "(?<first>.*)\s+(?<last>.*)"}
  ]

  prop_schema "animagus_csv_mappings" do
    prop_field(:expected_columns, :integer, first: 81, last: 100, required: true)
    prop_field(:external_location_id, :integer, first: 1, last: 10, required: true)
    prop_field(:event_date, :integer, first: 11, last: 20)
    prop_field(:primary_name, :integer, first: 21, last: 30, required: true)
    prop_field(:secondary_name, :integer, first: 31, last: 40)
    prop_field(:primary_phone, :integer, first: 41, last: 50, required: true)
    prop_field(:secondary_phone, :integer, first: 51, last: 60)
    prop_field(:tertiary_phone, :integer, first: 61, last: 70)
    prop_field(:email, :integer, first: 71, last: 80)
    prop_field(:parser, :string, default: "CSV", string_type: :alphanumeric, required: true)

    prop_field(
      :file_regex,
      :string,
      default: ".*\.[cC][sS][vV]",
      string_type: :ascii,
      required: true
    )

    prop_field(:name_regex, :string, string_type: :ascii, limited_values: true)
    prop_field(:date_format, :string, string_type: :ascii)

    prop_field(
      :integration_name,
      :string,
      default: "external",
      string_type: :alphanumeric,
      required: true
    )

    prop_field(:event_name, :string, string_type: :alphanumeric, required: true)

    timestamps()
  end

  @doc """
    Creates a changeset from the `data` and `params`. Runs several validations on the changes:

    1. Required fields
    2. The integer fields should be positive
    3. The name_regex field should only have the allowed values
    4. No two integer fields should have the same value
    5. All integer fields should be less than the expected_columns field's value
    6. The combination of integration_name and event_name should be unique
  """
  @spec changeset(t(), map()) :: Changeset.t()
  def changeset(data, params \\ %{}) do
    data
    |> Changeset.cast(params, __schema__(:fields))
    |> Changeset.validate_required([
      :expected_columns,
      :external_location_id,
      :primary_phone,
      :primary_name,
      :parser,
      :file_regex,
      :integration_name,
      :event_name
    ])
    |> validate_positivity([
      :expected_columns,
      :external_location_id,
      :event_date,
      :primary_name,
      :secondary_name,
      :primary_phone
    ])
    |> validate_regex()
    |> validate_no_duplicate_fields()
    |> validate_index_lies_within_expected()
    |> Changeset.unique_constraint(
         :event_name,
         name: :animagus_csv_mappings_integration_name_event_name_index
       )
  end

  @doc """
    Returns the fields in the schema and their type
  """
  @spec fields() :: %{required(atom()) => atom()}
  def fields do
    :fields
    |> __MODULE__.__schema__()
    |> Enum.into(%{}, fn
      field when field != :inserted_at or field != :updated_at ->
        {field, __MODULE__.__schema__(:type, field)}

      _ ->
        nil
    end)
  end

  @doc """
    Returns the allowed regexes for printing out in the `new` endpoint.
  """
  @spec regexes() :: [%{required(String.t()) => String.t()}]
  def regexes, do: @allowed_regexes

  defp validate_positivity(changeset, fields) do
    Enum.reduce(
      fields,
      changeset,
      &Changeset.validate_number(&2, &1, greater_than_or_equal_to: 0)
    )
  end

  defp validate_regex(changeset) do
    Changeset.validate_change(changeset, :name_regex, fn
      :name_regex, nil ->
        []

      :name_regex, regex ->
        if Enum.member?(allowed_regexes(), regex) do
          []
        else
          [name_regex: "must be one of: #{inspect(allowed_regexes())}"]
        end
    end)
  end

  defp validate_no_duplicate_fields(changeset) do
    Enum.reduce(integer_fields(), changeset, &validate_not_duplicate(&2, &1))
  end

  defp validate_index_lies_within_expected(changeset) do
    expected_columns = Changeset.get_field(changeset, :expected_columns)

    Enum.reduce(
      integer_fields(),
      changeset,
      &Changeset.validate_number(&2, &1, less_than: expected_columns)
    )
  end

  defp allowed_regexes do
    @allowed_regexes
    |> Enum.map(&Map.values(&1))
    |> List.flatten()
  end

  defp integer_fields do
    Enum.reduce(fields(), [], fn
      {:expected_columns, _}, acc -> acc
      {k, :integer}, acc -> [k | acc]
      {_, _}, acc -> acc
    end)
  end

  defp other_fields(changeset, field) do
    integer_fields()
    |> List.delete(field)
    |> Enum.map(fn i_field -> Changeset.get_field(changeset, i_field) end)
  end

  defp validate_not_duplicate(changeset, field) do
    if is_nil(Changeset.get_field(changeset, field)) do
      changeset
    else
      others = other_fields(changeset, field)
      Changeset.validate_exclusion(changeset, field, others, message: "duplicate column index")
    end
  end
end
