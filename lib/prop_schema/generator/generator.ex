defmodule PropSchema.Generator do
  @moduledoc false

  alias PropSchema.BaseProperties, as: Properties

  def generate_valid_prop_test(mod, props, additional_props) do
    generators = generate_complete_map(props, additional_props)
    generate_prop_test(mod, generators, "valid changeset", valid?())
  end

  def generate_valid_prop_test(mod, {field, _} = prop, props, additional_props) do
    generators = generate_incomplete_map(prop, props, additional_props)
    generate_prop_test(mod, generators, "valid changeset - missing #{field}", valid?())
  end

  def generate_invalid_prop_test(mod, {field, _} = prop, props, additional_props) do
    generators = generate_incomplete_map(prop, props, additional_props)
    generate_prop_test(mod, generators, "invalid changeset - missing #{field}", invalid?())
  end

  def generate_complete_map(props, additional_props) do
    generators = generate_props(props, additional_props)

    quote do
      StreamData.fixed_map(unquote(generators))
    end
  end

  def generate_incomplete_map(prop, props, additional_props) do
    generators = generate_props(prop, props, additional_props)

    quote do
      StreamData.fixed_map(unquote(generators))
    end
  end

  defp generate_prop_test(mod, generators, message, correct?) do
    quote do
      property unquote(message) do
        check all map <- unquote(generators) do
          changeset = unquote(mod).changeset(struct(unquote(mod)), map)

          unquote(correct?).(changeset)
        end
      end
    end
  end

  defp generate_props(props, additional_props) do
    props
    |> Enum.map(fn {field, {type, opts}} -> generate_prop(field, type, opts, additional_props) end)
    |> generate_misc(nil, additional_props)
    |> Enum.reject(&is_nil(&1))
  end

  defp generate_props({excluded, _}, props, additional_props),
    do: generate_props(excluded, props, additional_props)

  defp generate_props(excluded, props, additional_props) do
    props
    |> Enum.map(fn
      {field, {type, opts}} when field != excluded ->
        generate_prop(field, type, opts, additional_props)

      _ ->
        nil
    end)
    |> generate_misc(excluded, additional_props)
    |> Enum.reject(&is_nil(&1))
  end

  defp generate_misc(properties, _excluded, nil), do: properties

  defp generate_misc(properties, excluded, additional_props) do
    additional_props
    |> apply(:generate_misc, [excluded])
    |> Kernel.++(properties)
    |> List.flatten()
  rescue
    _ -> properties
  end

  defp generate_prop(field, type, opts, nil), do: Properties.generate_prop(field, type, opts)

  defp generate_prop(field, type, opts, additional_props) do
    case apply(additional_props, :generate_prop, [field, type, opts]) do
      nil ->
        Properties.generate_prop(field, type, opts)

      expression ->
        expression
    end
  end

  defp valid? do
    quote do
      fn changeset ->
        if not changeset.valid?,
          do: Logger.error("Test will fail because: #{inspect(changeset.errors)}")

        assert changeset.valid?
      end
    end
  end

  defp invalid? do
    quote do
      fn changeset ->
        if changeset.valid?, do: Logger.error("Test will fail because: No errors")
        refute changeset.valid?
      end
    end
  end
end
