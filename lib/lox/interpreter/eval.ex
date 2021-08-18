alias Lox.Expr

defprotocol Lox.Interpreter.Eval do
  @spec evaluate(Expr.t()) :: term()
  def evaluate(expr)
end

defimpl Lox.Interpreter.Eval, for: Expr.Binary do
  def evaluate(binary) do
    alias Lox.Interpreter.{Eval, Helpers}

    left = Eval.evaluate(binary.left)
    right = Eval.evaluate(binary.right)

    case binary.operator.type do
      :bang_equal ->
        !Helpers.is_equal(left, right)

      :equal_equal ->
        Helpers.is_equal(left, right)

      :greater when is_float(left) and is_float(right) ->
        left > right

      :greater_equal when is_float(left) and is_float(right) ->
        left >= right

      :less when is_float(left) and is_float(right) ->
        left < right

      :less_equal when is_float(left) and is_float(right) ->
        left <= right

      :minus when is_float(left) and is_float(right) ->
        left - right

      :slash when is_float(left) and is_float(right) ->
        left / right

      :star when is_float(left) and is_float(right) ->
        left * right

      :plus when is_float(left) and is_float(right) ->
        left + right

      :plus when is_binary(left) and is_binary(right) ->
        left <> right

      :plus ->
        Helpers.error!(binary.operator, "Operands must be two numbers or two strings.")

      t when t in [:minus, :slash, :star, :greater, :greater_equal, :less, :less_equal] ->
        Helpers.error!(binary.operator, "Operand must be a number.")
    end
  end
end

defimpl Lox.Interpreter.Eval, for: Expr.Grouping do
  def evaluate(grouping) do
    alias Lox.Interpreter.Eval

    Eval.evaluate(grouping.expression)
  end
end

defimpl Lox.Interpreter.Eval, for: Expr.Literal do
  def evaluate(literal) do
    literal.value
  end
end

defimpl Lox.Interpreter.Eval, for: Expr.Unary do
  def evaluate(unary) do
    alias Lox.Interpreter.{Eval, Helpers}

    right = Eval.evaluate(unary.right)

    case unary.operator.type do
      :bang -> !Helpers.is_truthy(right)
      :minus when is_float(right) -> -right
      :minus -> Helpers.error!(unary.operator, "Operand must be a number.")
    end
  end
end
