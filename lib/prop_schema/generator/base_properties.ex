defmodule PropSchema.BaseProperties do
  @moduledoc false

  # Private moduledoc:
  # Base collection of properties according to their requirement and other considerations.
  # See `PropSchema.AdditionalProperties` for how to add to this collection or override any of these.

  alias PropSchema.Generator
  alias StreamData.LazyTree

  @doc """
  Covers a few cases of the `integer` and `string` types. For integers `required` and `positive` are provided. For strings `required` and `string_type` are provided.
  """
  @spec generate_prop(atom(), :integer | :string, %{optional(atom()) => atom() | boolean()}) ::
          {String.t(), StreamData.t()}
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

  def generate_prop(field, :id, %{type: :binary_id}) do
    quote do
      {unquote(Atom.to_string(field)), unquote(uuid_generator())}
    end
  end

  def generate_prop(field, :binary_id, %{required: true}) do
    quote do
      {unquote(Atom.to_string(field)), unquote(uuid_generator())}
    end
  end

  def generate_prop(field, :binary_id, %{required: false}) do
    quote do
      {unquote(Atom.to_string(field)), StreamData.one_of([unquote(uuid_generator()), StreamData.constant(nil)])}
    end
  end

  def generate_prop(field, :utc_datetime, %{now: true, required: true}) do
    quote do
      {unquote(Atom.to_string(field)), unquote(current_datetime())}
    end
  end

  def generate_prop(field, :utc_datetime, %{now: true, required: false}) do
    quote do
      {unquote(Atom.to_string(field)), StreamData.one_of([unquote(current_datetime()), StreamData.constant(nil)])}
    end
  end

  def generate_prop(field, module, %{cardinality: :one, additional_props: adds})
      when is_atom(module) do
    quote do
      {unquote(Atom.to_string(field)),
       unquote(Generator.generate_complete_map(module.__prop_schema__(), adds))}
    end
  end

  def generate_prop(field, module, %{cardinality: :many, additional_props: adds} = map)
      when is_atom(module) do
    quote do
      {unquote(Atom.to_string(field)),
       StreamData.list_of(
         unquote(Generator.generate_complete_map(module.__prop_schema__(), adds)),
         min_length: 1,
         max_length: unquote(Map.get(map, :max_length, 5))
       )}
    end
  end

  def generate_prop(
        field,
        module,
        %{
          cardinality: :many_to_many,
          additional_props: adds,
          disabled: false
        } = map
      )
      when is_atom(module) do
    prop_schema =
      Enum.map(module.__prop_schema__(), fn
        {k, {mod, %{cardinality: :many_to_many} = map}} ->
          {k, {mod, Map.put(map, :disabled, true)}}

        kv ->
          kv
      end)

    quote do
      {unquote(Atom.to_string(field)),
       StreamData.list_of(unquote(Generator.generate_complete_map(prop_schema, adds)),
         min_length: 1,
         max_length: unquote(Map.get(map, :max_length, 5))
       )}
    end
  end

  def generate_prop(field, module, %{cardinality: :many_to_many, disabled: true})
      when is_atom(module) do
    quote do
      {unquote(Atom.to_string(field)), StreamData.constant([])}
    end
  end

  def generate_prop(_field, _type, _opts), do: nil

  defp uuid_generator do
    quote do
      StreamData.map(
        StreamData.string(Enum.concat([?a..?f, ?0..?9]), length: 32),
        unquote(string_to_uuid())
      )
    end
  end

  defp string_to_uuid do
    quote do
      fn string when byte_size(string) == 32 ->
        string
        |> String.to_charlist()
        |> List.insert_at(20, ?-)
        |> List.insert_at(16, ?-)
        |> List.insert_at(12, ?-)
        |> List.insert_at(8, ?-)
        |> List.to_string()
      end
    end
  end

  defp current_datetime do
    quote do
      %StreamData{
        generator: fn _seed, _size -> %LazyTree{root: DateTime.utc_now()} end
      }
    end
  end
end
