defmodule PropSchema.Types do
  @moduledoc """
    Holds type declarations.
  """
  @type ast_expression :: {String.t(), StreamData.t()}
  @type excluded_field :: atom()
end
