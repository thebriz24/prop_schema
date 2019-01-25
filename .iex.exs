defmodule TestStream do
  import PropSchema.Stream

  generate_complete_map(PropSchema.ExampleModule)

  def gimme, do: complete() |> Enum.at(0)
end

alias PropSchema.Generator.ExpressionModifier, as: EM