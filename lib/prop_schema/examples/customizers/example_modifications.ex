defmodule PropSchema.ExampleModifications do
  @moduledoc false
  @behaviour PropSchema.Modifications

  @impl PropSchema.Modifications
  def generate_modification(_map, :test_int), do: nil
  def generate_modification(map, :test_float) do
    quote do
      unquote(map) = Map.update(unquote(map), "test_int", 0, fn
        nil -> nil
        int -> int + 10
      end)
    end
  end
  def generate_modification(map, _) do
    quote do
      unquote(map) = Map.update(unquote(map), "unused", 0, &Integer.to_string/1)
    end
  end

end
