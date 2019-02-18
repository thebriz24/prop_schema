defmodule TestStream do
  import PropSchema.Stream

  generate_incomplete_map(PropSchema.ExampleModule, :test_int)

  def gimme, do: incomplete_example_module(:test_int) |> Enum.at(0)
end

alias PropSchema.Generator.ExpressionModifier, as: EM