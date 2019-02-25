defmodule PropSchema.Generator do
  @moduledoc false

  alias PropSchema.BaseProperties, as: Properties
  alias PropSchema.Generator.ExpressionModifier

  @type prop_details :: {atom(), %{optional(atom()) => any()}}
  @type prop :: {atom(), prop_details()}
  @type props :: %{optional(atom()) => prop_details()}

  @spec generate_valid_prop_test(atom(), props(), atom(), atom()) :: Macro.t()
  def generate_valid_prop_test(mod, props, additional_props, modifications) do
    generators = generate_complete_map(props, additional_props)
    filters = generate_modifications(modifications, nil)
    generate_prop_test(mod, generators, filters, "valid changeset", valid?())
  end

  @spec generate_valid_prop_test(atom(), prop(), props(), atom(), atom()) :: Macro.t()
  def generate_valid_prop_test(mod, {field, _} = prop, props, additional_props, modifications) do
    generators = generate_incomplete_map(prop, props, additional_props)
    filters = generate_modifications(modifications, field)
    generate_prop_test(mod, generators, filters, "valid changeset - missing #{field}", valid?())
  end

  @spec generate_invalid_prop_test(atom(), prop(), props(), atom(), atom()) :: Macro.t()
  def generate_invalid_prop_test(mod, {field, _} = prop, props, additional_props, modifications) do
    generators = generate_incomplete_map(prop, props, additional_props)
    filters = generate_modifications(modifications, field)

    generate_prop_test(
      mod,
      generators,
      filters,
      "invalid changeset - missing #{field}",
      invalid?()
    )
  end

  @spec generate_complete_map(props(), atom()) :: Macro.t()
  def generate_complete_map(props, additional_props) do
    generators = generate_props(props, additional_props)

    quote do
      StreamData.fixed_map(unquote(generators))
    end
  end

  @spec generate_incomplete_map(prop(), props(), atom()) :: Macro.t()
  def generate_incomplete_map(prop, props, additional_props) do
    generators = generate_props(prop, props, additional_props)

    quote do
      StreamData.fixed_map(unquote(generators))
    end
  end

  defp generate_modifications(nil, _excluded), do: nil

  defp generate_modifications(mod, excluded) when is_atom(mod),
    do: mod.generate_modification(Macro.var(:map, __MODULE__), excluded)

  defp generate_prop_test(mod, generators, modifications, message, correct?) do
    ast =
      quote do
        @tag generated: true
        property unquote(message) do
          check all map <- unquote(generators) do
            changeset = unquote(mod).changeset(struct(unquote(mod)), map)

            unquote(correct?).(changeset)
          end
        end
      end

    ExpressionModifier.inject_argmument(ast, modifications)
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
