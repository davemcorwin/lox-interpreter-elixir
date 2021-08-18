defmodule Lox.Token do
  @type token_type ::
          :left_paren
          | :right_paren
          | :left_brace
          | :right_brace
          | :comma
          | :dot
          | :minus
          | :plus
          | :semicolon
          | :slash
          | :star
          | :eof

          # One or two character tokens.
          | :bang
          | :bang_equal
          | :equal
          | :equal_equal
          | :greater
          | :greater_equal
          | :less
          | :less_equal

          # Literals.
          | :identifier
          | :string
          | :number
          | :comment

          # Keywords.
          | :and
          | :class
          | :else
          | :false_kw
          | :for
          | :fun
          | :if
          | :nil_kw
          | :or
          | :print
          | :return
          | :super
          | :this
          | :true_kw
          | :var
          | :while

  @enforce_keys [:type, :line]
  defstruct type: nil,
            lexeme: "",
            literal: nil,
            line: nil

  @type t :: %__MODULE__{
          type: token_type(),
          lexeme: String.t(),
          literal: any(),
          line: pos_integer()
        }

  @keywords %{
    "and" => :and,
    "class" => :class,
    "else" => :else,
    "false" => :false_kw,
    "for" => :for,
    "fun" => :fun,
    "if" => :if,
    "nil" => :nil_kw,
    "or" => :or,
    "print" => :print,
    "return" => :return,
    "super" => :super,
    "this" => :this,
    "true" => :true_kw,
    "var" => :var,
    "while" => :while
  }

  @spec get_keyword(String.t()) :: token_type() | nil
  def get_keyword(identifier) do
    Map.get(@keywords, identifier)
  end
end
