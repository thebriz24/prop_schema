defmodule PropSchema.ExampleTest do
  use PropSchema.Executor,
    to_test: PropSchema.ExampleModule,
    additional_properties: PropSchema.ExampleAdditionalProperties
end
