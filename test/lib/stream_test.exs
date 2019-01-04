defmodule PropSchema.StreamTest do
  use ExUnit.Case

  alias PropSchema.{ExampleModule, Stream}
  require Stream

  # credo:disable-for-lines:5
  Stream.generate_complete_map(PropSchema.ExampleModule, PropSchema.ExampleAdditionalProperties)

  Stream.generate_all_incomplete_maps(
    PropSchema.ExampleModule,
    PropSchema.ExampleAdditionalProperties
  )

  test "Can call complete/0 like any StreamData stream" do
    try do
      Enum.take(complete(), 10)
    rescue
      e -> flunk("Raised #{e}")
    end
  end

  test "Can call all incomplete/1 like any StreamData stream" do
    Enum.each(ExampleModule.__prop_schema__(), fn {exluded, _} ->
      try do
        Enum.take(incomplete(exluded), 10)
      rescue
        e -> flunk("Raised #{e}")
      end
    end)
  end
end
