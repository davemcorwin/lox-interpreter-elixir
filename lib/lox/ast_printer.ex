alias Lox.Expr

defprotocol Lox.AstPrinter do
  @spec print(Expr.t()) :: IO.chardata()
  def print(expr)
end

defimpl Lox.AstPrinter, for: Expr.Binary do
  def print(binary) do
    [
      " ",
      "(",
      binary.operator.lexeme,
      Lox.AstPrinter.print(binary.left),
      Lox.AstPrinter.print(binary.right),
      ")"
    ]
  end
end

defimpl Lox.AstPrinter, for: Expr.Grouping do
  def print(grouping) do
    [" ", "(", "group", Lox.AstPrinter.print(grouping.expression), ")"]
  end
end

defimpl Lox.AstPrinter, for: Expr.Literal do
  def print(literal) do
    " #{literal.value}"
  end
end

defimpl Lox.AstPrinter, for: Expr.Unary do
  def print(unary) do
    [" ", "(", unary.operator.lexeme, Lox.AstPrinter.print(unary.right), ")"]
  end
end
