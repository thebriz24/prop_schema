# PropSchema
[![Hex Version](https://img.shields.io/hexpm/v/prop_schema.svg)](https://hex.pm/packages/prop_schema)

An extension of both `Ecto.Schema` and `ExUnitProperties` for auto-generation of changeset property tests.
Consists of two main modules: `PropSchema` and `PropSchema.Executor`

## Installation

```elixir
def deps do
  [
    {:prop_schema, "~> 0.1.0"}
  ]
end
```

## Usage

#### Look at the documentation for full usage
https://hexdocs.com/prop_schema

#### Basic Example

In example_module.ex: 
```elixir
defmodule ExampleModule do
  use PropSchema
  alias Ecto.Changeset

  prop_schema "example" do
    prop_field(:example_string, :string, string_type: :alphanumeric, required: true)
    prop_field(:example_int, :integer, positive: true, required: false)
    field(:example_float, :float)
  end

  def changeset(schema, data) do
    schema
    |> Changeset.cast(data, [:example_string, :example_int, :example_float])
    |> Changeset.validate_required([:example_string])
  end
end
```

In example_module_test.ex:
```elixir
defmodule ExampleModuleTest do
  use PropSchema.Executor, to_test: PropSchema.ExampleModule
end
```

Then run `mix test`. In this example it will make 3 prop tests.


Or for a more realistic example see example [module](https://github.com/podium/prop_schema/blob/master/lib/prop_schema/examples/animagus/csv_mapping.ex), [properties](https://github.com/podium/prop_schema/blob/master/lib/prop_schema/examples/animagus/csv_mapping_properties.ex), and [generated tests](https://github.com/podium/prop_schema/blob/master/lib/prop_schema/examples/animagus/results_of_print.ex).
