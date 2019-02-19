defmodule PropSchema.ExampleTest do
  use PropSchema.TestHarness,
    to_test: PropSchema.ExampleModule,
    additional_properties: PropSchema.ExampleAdditionalProperties,
    filters: PropSchema.ExampleFilters
end

defmodule PropSchema.ExampleOwnerTest do
  use PropSchema.TestHarness,
    to_test: PropSchema.ExampleOwner,
    additional_properties: PropSchema.ExampleAdditionalProperties,
    filters: PropSchema.ExampleFilters
end
