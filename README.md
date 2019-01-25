# PropSchema
[![Hex Version](https://img.shields.io/hexpm/v/prop_schema.svg)](https://hex.pm/packages/prop_schema)
[![Codeship Status for podium/prop_schema](https://app.codeship.com/projects/4eb5b1a0-f733-0136-4d7f-3a9020bdf416/status?branch=master)](/projects/321150)

An extension of both `Ecto.Schema` and `ExUnitProperties` for auto-generation of changeset property tests.
Consists of two main modules: `PropSchema` and `PropSchema.TestHarness`

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
  use PropSchema.TestHarness, to_test: PropSchema.ExampleModule
end
```

Then run `mix test`. In this example it will make 3 prop tests.


Or for a more realistic example see example [module](https://github.com/podium/prop_schema/blob/master/lib/prop_schema/examples/animagus/csv_mapping.ex), [properties](https://github.com/podium/prop_schema/blob/master/lib/prop_schema/examples/animagus/csv_mapping_properties.ex), and [generated tests](https://github.com/podium/prop_schema/blob/master/lib/prop_schema/examples/animagus/results_of_print.ex).

## Tips for First Time Users

I would suggest following this 6 step process your first time through (to get a feel for how this library builds on `Ecto.Schema` and `StreamData` to generate dummy data and tests) 
1. Start with simply creating your `Ecto.Schema` and define your changeset requirements as you would normally do.
2. Modify that schema by replacing all the macros with the corresponding `PropSchema` macros (Don't worry about adding any options at this point)
3. Create a `.iex.mix` file where you define a module that 
    1. Uses `PropSchema.Stream.generate_complete_map/2` with your new schema's module as its first argument and 
    2. Defines a public function that runs `complete() |> Enum.at(0)` (This will generate a random map that you can run through your changeset)
4. Determine what is unsatisfactory with the resulting map and add `generate_prop/3` functions to a new "AdditionalProperties" module for each key of that map you'd like to generate (see `PropSchema.AdditionalProperties` for directions, or examine this: [example](https://github.com/podium/prop_schema/blob/master/lib/prop_schema/examples/animagus/csv_mapping_properties.ex))
5. Place this new module as the second argument of the `PropSchema.Stream.generate_complete_map/2` call in your `.iex.exs` file.
6. Once the generated map is satisfactory, use the `PropSchema.TestHarness` module to generate your tests with ease.

