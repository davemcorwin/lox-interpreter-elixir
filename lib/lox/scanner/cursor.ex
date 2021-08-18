defmodule Lox.Scanner.Cursor do
  defstruct current: 0, line: 1, source: "", start: 0

  @type t :: %__MODULE__{
          current: non_neg_integer(),
          line: pos_integer(),
          source: String.t(),
          start: non_neg_integer()
        }

  defguard peekg(c, cursor)
           when binary_part(cursor.source, cursor.current, 1) === c

  @spec new(String.t()) :: t()
  def new(source), do: %__MODULE__{source: source}

  @spec end?(t()) :: boolean()
  def end?(cursor), do: peek(cursor) === nil

  @spec peek(t()) :: String.t() | nil
  def peek(cursor), do: peek(cursor, 0)

  @spec peek(t(), non_neg_integer()) :: String.t() | nil
  def peek(cursor, offset), do: String.at(cursor.source, cursor.current + offset)

  @spec line(t()) :: pos_integer()
  def line(cursor), do: cursor.line

  @spec read(t()) :: String.t()
  def read(cursor), do: String.slice(cursor.source, cursor.start..(cursor.current - 1))

  @spec next(t()) :: t()
  def next(cursor) do
    case peek(cursor) do
      nil -> cursor
      "\n" -> %{cursor | current: cursor.current + 1, line: cursor.line + 1}
      _ -> %{cursor | current: cursor.current + 1}
    end
  end

  @spec next_while(t(), (String.t() -> boolean())) :: t()
  def next_while(cursor, fun) do
    c = peek(cursor)

    if c != nil and fun.(c) do
      next_while(next(cursor), fun)
    else
      cursor
    end
  end

  @spec next_until(t(), (String.t() -> boolean())) :: t()
  def next_until(cursor, fun) do
    next_while(cursor, fn c -> !fun.(c) end)
  end

  @spec slide(t()) :: t()
  def slide(cursor), do: %{cursor | start: cursor.current}
end
