defmodule PropSchema do
  @moduledoc """
    An extension on `Ecto.Schema` used to generate property tests. Schema can be further augmented
    based on additional options, which will be read by the corresponding `PropSchema.TestHarness` module
    to generate tests.

  ## Example

        prop_schema "example" do
          prop_field(:example_string, :string, string_type: :alphanumeric, required: true)
          prop_field(:example_int, :integer, postive: true, required: false)
          field(:example_float, :float)
        end

    This declares the schema `"example"` with three fields: `:example_string`, `:example_int`, and `:example_float`.
    Property test will be generated for `:example_string` and `:example_int` but, since `:example` is declared using
    the regular `Ecto.Schema.field/3`, a test will not be generated for it.

    Adding these are equivalent to writing these tests:

        property("valid changeset") do
          check(all(map <- StreamData.fixed_map([{"example_int", StreamData.one_of([StreamData.integer(), StreamData.constant(nil)])}, {"example_string", StreamData.string(:alphanumeric, min_length: 1)}]))) do
            changeset = PropSchema.ExampleModule.changeset(struct(PropSchema.ExampleModule), map)
            (fn changeset ->
              if(not(changeset.valid?())) do
                Logger.error("Test will fail because: \#{inspect(changeset.errors())}")
              end
              assert(changeset.valid?())
            end).(changeset)
          end

        property("valid changeset - missing example_int") do
          check(all(map <- StreamData.fixed_map([{"example_string", StreamData.string(:alphanumeric, min_length: 1)}]))) do
            changeset = PropSchema.ExampleModule.changeset(struct(PropSchema.ExampleModule), map)
            (fn changeset ->
              if(not(changeset.valid?())) do
                Logger.error("Test will fail because: \#{inspect(changeset.errors())}")
              end
              assert(changeset.valid?())
            end).(changeset)
          end
        end

        property("invalid changeset - missing example_string") do
          check(all(map <- StreamData.fixed_map([{"example_int", StreamData.one_of([StreamData.integer(), StreamData.constant(nil)])}]))) do
            changeset = PropSchema.ExampleModule.changeset(struct(PropSchema.ExampleModule), map)
            (fn changeset ->
              if(changeset.valid?()) do
                Logger.error("Test will fail because: No errors")
              end
              refute(changeset.valid?())
            end).(changeset)
          end
        end

    I you would like to see what tests are being generated for your schema, use the mix task:
    ```console
    $ mix prop_schema.print <module> [options]
    ```
    Docs can be found here: `Mix.Tasks.PropSchema.Print`

  Or for a more realistic example see example: [module](https://github.com/podium/prop_schema/blob/master/lib/prop_schema/examples/animagus/csv_mapping.ex), [properties](https://github.com/podium/prop_schema/blob/master/lib/prop_schema/examples/animagus/csv_mapping_properties.ex), and [generated tests](https://github.com/podium/prop_schema/blob/master/lib/prop_schema/examples/animagus/results_of_print.ex).
  """

  alias PropSchema.Types

  defmacro __using__(_opts) do
    quote do
      import PropSchema, only: [prop_schema: 2, prop_embedded: 1, prop_embedded_schema: 1]
      use Ecto.Schema
      Module.register_attribute(__MODULE__, :prop_schema_fields, accumulate: true)
    end
  end

  @doc """
  Declares an `Ecto.Schema` with additional options that are used to generate property tests
  using `PropSchema.TestHarness`.

  ## Field Declaration

  When a field is declared with `prop_field/3` it will add the extra values as conditions for generating property tests.
  It is possible to declare a field just by using `Ecto.Schema.field/3` however `PropSchema.TestHarness` will
  not know about it, and tests will not be generated for that field.

  ## Examples

      prop_schema "example" do
        prop_field(:example_string, :string, string_type: :alphanumeric, required: true)
        prop_field(:example_int, :integer, postive: true, required: false)
        field(:example_float, :float)
      end
  """
  @spec prop_schema(String.t(), do: Types.ast_expression()) :: Types.ast_expression()
  defmacro prop_schema(source, do: block) do
    schema(source, block)
  end

  @doc """
  Deprecated in favor of `prop_embedded_schema/1`, see for usage details.
  """
  @deprecated "Use prop_embedded_schema/1 instead"
  @spec prop_embedded(do: Types.ast_expression()) :: Types.ast_expression()
  defmacro prop_embedded(do: block) do
    embedded_schema(block)
  end

  @doc """
  High school english class time! `prop_embedded_schema/1` is to `prop_schema/2` as `Ecto.Schema.embedded_schema/1` is to `Ecto.Schema.schema/2`

  ## Examples

      prop_embedded_schema do
        prop_field(:example_string, :string, string_type: :alphanumeric, required: true)
        prop_field(:example_int, :integer, postive: true, required: false)
        field(:example_float, :float)
      end
  """
  @spec prop_embedded_schema(do: Types.ast_expression()) :: Types.ast_expression()
  defmacro prop_embedded_schema(do: block) do
    embedded_schema(block)
  end

  defp schema(source, block) do
    quote do
      try do
        import PropSchema
        schema(unquote(source), do: unquote(block))
      after
        :ok
      end

      Module.eval_quoted(__ENV__, [
        PropSchema.__prop_schema__(@prop_schema_fields)
      ])
    end
  end

  defp embedded_schema(block) do
    quote do
      try do
        import PropSchema
        embedded_schema(do: unquote(block))
      after
        :ok
      end

      Module.eval_quoted(__ENV__, [
        PropSchema.__prop_schema__(@prop_schema_fields)
      ])
    end
  end

  @doc """
    Declares a field in the schema, processes it for use in `PropSchema.TestHarness` and then passes it through to `Ecto.Schema.field/3`. See `prop_schema/2` for examples.
  """
  @spec prop_field(atom(), atom(), keyword()) :: Types.ast_expression()
  defmacro prop_field(name, type \\ :string, opts \\ []) do
    quote do
      PropSchema.__field__(__MODULE__, unquote(name), unquote(type), unquote(opts))
      field(unquote(name), unquote(type), unquote(opts))
    end
  end

  def __field__(mod, name, type, opts) do
    Module.put_attribute(mod, :prop_schema_fields, {name, {type, Enum.into(opts, %{})}})
  end

  def __prop_schema__(prop_schema_fields) do
    map = prop_schema_fields |> Enum.into(%{}) |> Macro.escape()

    quote do
      def __prop_schema__, do: unquote(map)
    end
  end

  @valid_belongs_to_options [
    :foreign_key,
    :references,
    :define_field,
    :type,
    :on_replace,
    :defaults,
    :primary_key,
    :source,
    :where
  ]

  @doc """
  Declares a field in `__prop_schema__/2` which will either be the `name` with `"_id"` appended or the value of the `:foreign_key` option.
  A UUID generator is provided for uid ids.
  """
  @spec prop_belongs_to(atom(), module(), Keyword.t()) :: Types.ast_expression()
  defmacro prop_belongs_to(name, queryable, opts \\ []) do
    ecto_opts =
      Enum.reject(opts, fn {k, _v} -> not Enum.member?(@valid_belongs_to_options, k) end)

    key =
      case Keyword.get(opts, :foreign_key) do
        nil -> :"#{name}_id"
        key -> key
      end

    quote do
      PropSchema.__field__(__MODULE__, unquote(key), :id, unquote(opts))
      belongs_to(unquote(name), unquote(queryable), unquote(ecto_opts))
    end
  end

  @valid_has_options [
    :foreign_key,
    :references,
    :through,
    :on_delete,
    :defaults,
    :on_replace,
    :where
  ]

  @doc """
  Declares a field in `__prop_schema__/2` which corresponds with a provided generator that will build the associated struct for you.
  The only addition to the normal `Ecto.Schema.has_one/3` call is the `:additional_props` option which will tell the generator where
  to find the additional props for building the associated struct.
  """
  @spec prop_has_one(atom(), module(), Keyword.t()) :: Types.ast_expression()
  defmacro prop_has_one(name, queryable, opts \\ []) do
    ecto_opts = Enum.reject(opts, fn {k, _v} -> not Enum.member?(@valid_has_options, k) end)

    quote do
      PropSchema.__field__(
        __MODULE__,
        unquote(name),
        unquote(queryable),
        unquote(opts ++ [cardinality: :one])
      )

      has_one(unquote(name), unquote(queryable), unquote(ecto_opts))
    end
  end

  @doc """
  Declares a field in `__prop_schema__/2` which corresponds with a provided generator that will build the list of associated structs for you.
  The only addition to the normal `Ecto.Schema.has_many/3` call is the `:additional_props` option which will tell the generator where
  to find the additional props for building the associated structs.
  """
  @spec prop_has_many(atom(), module(), Keyword.t()) :: Types.ast_expression()
  defmacro prop_has_many(name, queryable, opts \\ []) do
    ecto_opts = Enum.reject(opts, fn {k, _v} -> not Enum.member?(@valid_has_options, k) end)

    quote do
      PropSchema.__field__(
        __MODULE__,
        unquote(name),
        unquote(queryable),
        unquote(opts ++ [cardinality: :many])
      )

      has_many(unquote(name), unquote(queryable), unquote(ecto_opts))
    end
  end

  @valid_many_to_many_options [
    :join_through,
    :join_keys,
    :on_delete,
    :defaults,
    :on_replace,
    :unique,
    :where
  ]

  @doc """
  Declares a field in `__prop_schema__/2` which corresponds with a provided generator that will build the list of
  associated structs for you. The only addition to the normal `Ecto.Schema.many_to_many/3` call is the `:additional_props`
  option which will tell the generator where to find the additional props for building the associated structs. The
  associated struct's `__prop_schema__/2` results will be modified so as to not generate it's associated many_to_many
  structs due to the endless recursion that would cause.
  """
  @spec prop_many_to_many(atom(), module(), Keyword.t()) :: Types.ast_expression()
  defmacro prop_many_to_many(name, queryable, opts \\ []) do
    ecto_opts =
      Enum.reject(opts, fn {k, _v} -> not Enum.member?(@valid_many_to_many_options, k) end)

    quote do
      PropSchema.__field__(
        __MODULE__,
        unquote(name),
        unquote(queryable),
        unquote(opts ++ [cardinality: :many_to_many, disabled: false])
      )

      many_to_many(unquote(name), unquote(queryable), unquote(ecto_opts))
    end
  end

  @valid_embeds_one_options [:strategy, :on_replace, :source]
  @doc """
    Declares a field in `__prop_schema__/2` which corresponds with a provided generator that will build the associated struct for you.
    The only addition to the normal `Ecto.Schema.embeds_one/3` call is the `:additional_props` option which will tell the generator where
    to find the additional props for building the associated struct.
  """
  @spec prop_embeds_one(atom(), module(), Keyword.t()) :: Types.ast_expression()
  defmacro prop_embeds_one(name, queryable, opts \\ []) do
    ecto_opts =
      Enum.reject(opts, fn {k, _v} -> not Enum.member?(@valid_embeds_one_options, k) end)

    quote do
      PropSchema.__field__(
        __MODULE__,
        unquote(name),
        unquote(queryable),
        unquote(opts ++ [cardinality: :one])
      )

      embeds_one(unquote(name), unquote(queryable), unquote(ecto_opts))
    end
  end

  @valid_embeds_many_options [:strategy, :on_replace, :source]

  @doc """
  Declares a field in `__prop_schema__/2` which corresponds with a provided generator that will build the list of associated structs for you.
  The only addition to the normal `Ecto.Schema.embeds_many/3` call is the `:additional_props` option which will tell the generator where
  to find the additional props for building the associated structs.
  """
  @spec prop_embeds_many(atom(), module(), Keyword.t()) :: Types.ast_expression()
  defmacro prop_embeds_many(name, queryable, opts \\ []) do
    ecto_opts =
      Enum.reject(opts, fn {k, _v} -> not Enum.member?(@valid_embeds_many_options, k) end)

    quote do
      PropSchema.__field__(
        __MODULE__,
        unquote(name),
        unquote(queryable),
        unquote(opts ++ [cardinality: :many])
      )

      embeds_many(unquote(name), unquote(queryable), unquote(ecto_opts))
    end
  end
end
