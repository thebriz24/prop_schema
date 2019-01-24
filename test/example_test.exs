defmodule PropSchema.ExampleTest do
  use PropSchema.Executor,
    to_test: PropSchema.ExampleModule,
    additional_properties: PropSchema.ExampleAdditionalProperties
end

defmodule PropSchema.ExampleOwnerTest do
  use PropSchema.Executor,
    to_test: PropSchema.ExampleOwner,
    additional_properties: PropSchema.ExampleAdditionalProperties
end
