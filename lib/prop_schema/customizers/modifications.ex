defmodule PropSchema.Modifications do
  @moduledoc """
    A behaviour that is used to define filters used in property tests.
  """

  @doc """
  Implement to define modifications that come after the generation of the fixed map, but before the actual run of the test.
  Modifications in this case consist of filters `map[:test_int] > 5` or modifications to the map
  `map = %{map | test_int: map[:test_int] + 10}`.

      check all int1 <- integer(),
                int2 <- integer(),
                int1 > 0 and int2 > 0,
                sum = int1 + int2 do
        assert sum > int1
        assert sum > int2
      end

  Line 3 and 4 are examples of modifications provided by the docs of `ExUnitProperties`. We can get modify our map in this manner like so:

  ### Example
      def generate_modification(map, _) do
        quote do
          unquote(map) = Map.put(unquote(map), "uid", Ecto.UUID.generate())
        end
      end

  ## A Caveat
  According to `ExUnitProperties.check/1` you can also assign new
  variables (see `StreamData` docs for example). However, that is not allowed in this behaviour since the generated prop_tests
  have a narrower use case. Instead use a custom property test that uses `PropSchema.Stream`.

  ### Example
      defmodule ExampleTest do
        alias PropSchema.Stream
        require Stream
        Stream.generate_complete_map(ExampleModule, ExampleAdditionalProperties)

        use ExUnitProperties
        property "example_test" do
          check all map <- complete(),
          super_map = %{stuff: "stuff", sub_map: map} do
            {test here}
          end
        end
      end

  """
  @callback generate_modification({var :: atom(), [], context:: atom()}, atom()) :: Macro.t()
  @optional_callbacks generate_modification: 2
end
