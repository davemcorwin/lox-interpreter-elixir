alias Lox.{ErrorAgent, Expr, Token}
alias Lox.Parser.{Cursor, Error}

defmodule Lox.Parser do
  @moduledoc """

  -----------------
  Syntactic grammar
  -----------------

  expression    -> equality ;
  equality      -> comparison ( ( "!=" | "==" ) comparison )* ;
  comparison    -> term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
  term          -> factor ( ( "-" | "+" ) factor )* ;
  factor        -> unary ( ( "/" | "*" ) unary )* ;
  unary         -> ( "!" | "-" ) unary
                | primary ;
  primary       -> NUMBER | STRING | "true" | "false" | "nil"
                | "(" expression ")" ;

  -----------
  Precendence
  -----------

  Name        Operators  Associates
  ----------  ---------  ----------
  Equality    == !=      Left
  Comparison  > >= < <=  Left
  Term        - +        Left
  Factor      / *        Left
  Unary       ! -        Right

  """

  @spec parse(list(Token.t())) :: Expr.t()
  def parse(tokens) do
    cursor = Cursor.new(tokens)
    try do
      expression(cursor)
    rescue
      e in [Error] ->  ErrorAgent.error(e)
    else
      {expr, _} -> expr
    end
  end

  @spec expression(Cursor.t()) :: {Expr.t(), Cursor.t()}
  def expression(cursor) do
    equality(cursor)
  end

  @spec equality(Cursor.t()) :: {Expr.t(), Cursor.t()}
  def equality(cursor) do
    {left, cursor} = comparison(cursor)
    equality_sub(cursor, left, Cursor.peek(cursor))
  end

  def equality_sub(cursor, left, %Token{type: token_type} = operator)
    when token_type in [:bang_equal, :equal_equal] do
    cursor = Cursor.next(cursor)
    {right, cursor} = comparison(cursor)
    left = Expr.Binary.new(left, operator, right)
    equality_sub(cursor, left, Cursor.peek(cursor))
  end

  def equality_sub(cursor, left, _operator), do: {left, cursor}

  @spec comparison(Cursor.t()) :: {Expr.t(), Cursor.t()}
  def comparison(cursor) do
    {left, cursor} = term(cursor)
    comparison_sub(cursor, left, Cursor.peek(cursor))
  end

  def comparison_sub(cursor, left, %Token{type: token_type} = operator)
    when token_type in [:greater, :greater_equal, :less, :less_equal] do
    cursor = Cursor.next(cursor)
    {right, cursor} = term(cursor)
    left = Expr.Binary.new(left, operator, right)
    comparison_sub(cursor, left, Cursor.peek(cursor))
  end

  def comparison_sub(cursor, left, _operator), do: {left, cursor}

  @spec term(Cursor.t()) :: {Expr.t(), Cursor.t()}
  def term(cursor) do
    {left, cursor} = factor(cursor)
    term_sub(cursor, left, Cursor.peek(cursor))
  end

  def term_sub(cursor, left, %Token{type: token_type} = operator)
    when token_type in [:minus, :plus] do
    cursor = Cursor.next(cursor)
    {right, cursor} = factor(cursor)
    left = Expr.Binary.new(left, operator, right)
    term_sub(cursor, left, Cursor.peek(cursor))
  end

  def term_sub(cursor, left, _operator), do: {left, cursor}

  @spec factor(Cursor.t()) :: {Expr.t(), Cursor.t()}
  def factor(cursor) do
    {left, cursor} = unary(cursor)
    factor_sub(cursor, left, Cursor.peek(cursor))
  end

  def factor_sub(cursor, left, %Token{type: token_type} = operator)
    when token_type in [:slash, :star] do
    cursor = Cursor.next(cursor)
    {right, cursor} = unary(cursor)
    left = Expr.Binary.new(left, operator, right)
    factor_sub(cursor, left, Cursor.peek(cursor))
  end

  def factor_sub(cursor, left, _operator), do: {left, cursor}

  @spec unary(Cursor.t()) :: {Expr.t(), Cursor.t()}
  def unary(cursor) do
    case Cursor.peek(cursor) do
      %Token{type: token_type} = operator when token_type in [:bang, :minus] ->
        cursor = Cursor.next(cursor)
        {right, cursor} = unary(cursor)
        {Expr.Unary.new(operator, right), cursor}
      _ -> primary(cursor)
    end
  end

  @spec primary(Cursor.t()) :: {Expr.t(), Cursor.t()}
  def primary(cursor) do
    case Cursor.peek(cursor) do
      %Token{type: token_type} when token_type === :false_kw ->
        {Expr.Literal.new(false), Cursor.next(cursor)}

      %Token{type: token_type} when token_type === :true_kw ->
        {Expr.Literal.new(true), Cursor.next(cursor)}

      %Token{type: token_type} when token_type === :nil_kw ->
        {Expr.Literal.new(nil), Cursor.next(cursor)}

      %Token{type: token_type} = token when token_type in [:number, :string] ->
        {Expr.Literal.new(token.literal), Cursor.next(cursor)}

      %Token{type: token_type} when token_type === :left_paren ->
        cursor = Cursor.next(cursor)
        {expr, cursor} = expression(cursor)
        case Cursor.peek(cursor) do
          %Token{type: token_type} when token_type === :right_paren ->
            {Expr.Grouping.new(expr), Cursor.next(cursor)}
          token -> error!(token, "Expect ')' after expression.")
        end

      token -> error!(token, "Expect expression.")
    end
  end

  def error!(token, message) do
    raise Error, token: token, message: message
  end

  # def synchronize() do
  #   advance();

  #   while (!isAtEnd()) {
  #     if (previous().type == SEMICOLON) return;

  #     switch (peek().type) {
  #       case CLASS:
  #       case FUN:
  #       case VAR:
  #       case FOR:
  #       case IF:
  #       case WHILE:
  #       case PRINT:
  #       case RETURN:
  #         return;
  #     }

  #     advance();
  #   }
  # end
end
