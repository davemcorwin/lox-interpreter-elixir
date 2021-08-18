require Lox.Scanner.Cursor
alias Lox.Scanner.{Cursor, Error}
alias Lox.{ErrorAgent, Token}

defmodule Lox.Scanner do
  defguardp is_digit(c) when c >= "0" and c <= "9"
  defguardp is_alpha(c) when (c >= "a" and c <= "z") or (c >= "A" and c <= "Z") or c === "_"
  defguardp is_alphanumeric(c) when is_alpha(c) or is_digit(c)
  defguardp is_next(c, cursor) when Cursor.peekg(c, cursor)

  @type token_tuple :: {Token.t(), Cursor.t()}

  @spec scan(String.t()) :: list(Token.t())
  def scan(source) do
    cursor = Cursor.new(source)

    Stream.unfold(cursor, fn cursor ->
      if Cursor.end?(cursor), do: nil, else: read_token(cursor)
    end)
    |> Enum.to_list()
  end

  @spec read_token(Cursor.t()) :: token_tuple()
  defp read_token(cursor) do
    cursor = Cursor.slide(cursor)
    c = Cursor.peek(cursor)
    cursor = Cursor.next(cursor)
    check(c, cursor)
  end

  @spec check(String.t(), Cursor.t()) :: token_tuple()
  defp check(nil, cursor), do: token(cursor, :eof)
  defp check("(", cursor), do: token(cursor, :left_paren)
  defp check(")", cursor), do: token(cursor, :right_paren)
  defp check("{", cursor), do: token(cursor, :left_brace)
  defp check("}", cursor), do: token(cursor, :right_brace)
  defp check(",", cursor), do: token(cursor, :comma)
  defp check(".", cursor), do: token(cursor, :dot)
  defp check("-", cursor), do: token(cursor, :minus)
  defp check("+", cursor), do: token(cursor, :plus)
  defp check(";", cursor), do: token(cursor, :semicolon)
  defp check("*", cursor), do: token(cursor, :star)

  defp check("!", cursor) when is_next("=", cursor),
    do: token(Cursor.next(cursor), :bang_equal)

  defp check("!", cursor), do: token(cursor, :bang)

  defp check("=", cursor) when is_next("=", cursor),
    do: token(Cursor.next(cursor), :equal_equal)

  defp check("=", cursor), do: token(cursor, :equal)

  defp check("<", cursor) when is_next("=", cursor),
    do: token(Cursor.next(cursor), :less_equal)

  defp check("<", cursor), do: token(cursor, :less)

  defp check(">", cursor) when is_next("=", cursor),
    do: token(Cursor.next(cursor), :greater_equal)

  defp check(">", cursor), do: token(cursor, :greater)
  defp check("/", cursor) when is_next("/", cursor), do: comment(cursor)
  defp check("/", cursor), do: token(cursor, :slash)
  defp check("\"", cursor), do: string(cursor)
  defp check(c, cursor) when c in [" ", "\t", "\r", "\n"], do: read_token(cursor)
  defp check(c, cursor) when is_digit(c), do: number(cursor)
  defp check(c, cursor) when is_alpha(c), do: identifier(cursor)

  defp check(c, cursor) do
    ErrorAgent.error(%Error{line: cursor.line, message: "Unexpected character: '#{c}'."})
    read_token(cursor)
  end

  @spec comment(Cursor.t()) :: token_tuple()
  defp comment(cursor) do
    cursor = Cursor.next_until(cursor, &(&1 === "\n"))
    comment = String.slice(Cursor.read(cursor), 2..-1//1)
    token(cursor, :comment, comment)
  end

  @spec string(Cursor.t()) :: token_tuple()
  defp string(cursor) do
    cursor = Cursor.next_until(cursor, &(&1 == "\""))

    case Cursor.peek(cursor) do
      "\"" ->
        string = String.slice(Cursor.read(cursor), 1..-1//1)
        token(Cursor.next(cursor), :string, string)

      _ ->
        ErrorAgent.error(%Error{line: cursor.line, message: "Unterminated string."})
        read_token(cursor)
    end
  end

  @spec number(Cursor.t()) :: token_tuple()
  defp number(cursor) do
    cursor = Cursor.next_while(cursor, &is_digit/1)

    cursor =
      if Cursor.peek(cursor) === "." and is_digit(Cursor.peek(cursor, 1)) do
        cursor
        |> Cursor.next()
        |> Cursor.next_while(&is_digit/1)
      else
        cursor
      end

    number = Cursor.read(cursor)
    token(cursor, :number, to_float(number))
  end

  @spec to_float(String.t()) :: float()
  defp to_float(string) do
    number =
      if String.contains?(string, ".") do
        string
      else
        string <> ".0"
      end

    String.to_float(number)
  end

  @spec identifier(Cursor.t()) :: token_tuple()
  defp identifier(cursor) do
    cursor = Cursor.next_while(cursor, &is_alphanumeric/1)
    identifier = Cursor.read(cursor)
    token_type = Token.get_keyword(identifier) || :identifier
    token(cursor, token_type)
  end

  @spec token(Cursor.t(), Token.token_type(), term()) :: token_tuple()
  defp token(cursor, token_type, value \\ nil) do
    {%Token{
       type: token_type,
       lexeme: Cursor.read(cursor),
       line: Cursor.line(cursor),
       literal: value
     }, cursor}
  end
end
