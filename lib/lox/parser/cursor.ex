defmodule Lox.Parser.Cursor do
  @enforce_keys [:tokens]
  defstruct current: 0, tokens: []

  @type t :: %__MODULE__{
          current: non_neg_integer(),
          tokens: list(Token.t())
        }

  @spec new(list(Token.t())) :: t()
  def new(tokens), do: %__MODULE__{tokens: tokens}

  @spec peek(t()) :: Token.t()
  def peek(cursor), do: Enum.at(cursor.tokens, cursor.current)

  @spec next(t()) :: t()
  def next(cursor) do
    case peek(cursor) do
      nil -> cursor
      _ -> %{cursor | current: cursor.current + 1}
    end
  end
end
