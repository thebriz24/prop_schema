defmodule PropSchema.Generator.ExpressionModifier do
  @moduledoc false
  @spec inject_argmument(Macro.t(), Macro.t()) :: Macro.t()
  def inject_argmument(ast, nil), do: ast

  def inject_argmument(ast, to_insert) do
    Macro.prewalk(ast, fn
      {:all, _, args} = expression -> put_elem(expression, 2, args ++ [to_insert])
      expression -> expression
    end)
  end
end
