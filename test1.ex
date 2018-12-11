property("valid changeset") do
  check(all(map <- fixed_map([{"test_int", one_of([positive_integer(), constant(nil)])}, {"test_string", string(:alphanumeric, min_length: 1)}]))) do
    changeset = PropSchema.ExampleModule.changeset(struct(PropSchema.ExampleModule), map)
    if(not(changeset.valid?())) do
      Logger.error("Test will fail because: #{inspect(changeset.errors())}")
    end
    assert(changeset.valid?())
  end
end

property("invalid changeset - missing #{:test_float}") do
  check(all(map <- fixed_map([{"test_int", one_of([positive_integer(), constant(nil)])}, {"test_string", string(:alphanumeric, min_length: 1)}]))) do
    changeset = apply(PropSchema.ExampleModule, :changeset, [apply(PropSchema.ExampleModule, :__struct__, []), map])
    if(changeset.valid?()) do
      Logger.error("Test will fail because: No errors")
    end
    refute(changeset.valid?())
  end
end

property("valid changeset - missing #{:test_int}") do
  check(all(map <- fixed_map([{"test_string", string(:alphanumeric, min_length: 1)}]))) do
    changeset = apply(PropSchema.ExampleModule, :changeset, [apply(PropSchema.ExampleModule, :__struct__, []), map])
    if(not(changeset.valid?())) do
      Logger.error("Test will fail because: #{inspect(changeset.errors())}")
    end
    assert(changeset.valid?())
  end
end

property("invalid changeset - missing #{:test_string}") do
  check(all(map <- fixed_map([{"test_int", one_of([positive_integer(), constant(nil)])}]))) do
    changeset = apply(PropSchema.ExampleModule, :changeset, [apply(PropSchema.ExampleModule, :__struct__, []), map])
    if(changeset.valid?()) do
      Logger.error("Test will fail because: No errors")
    end
    refute(changeset.valid?())
  end
end