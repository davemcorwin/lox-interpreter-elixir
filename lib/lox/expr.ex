defmodule Lox.Expr do
  alias Lox.{Binary, Grouping, Literal, Unary}
  @type t :: Binary.t() | Grouping.t() | Literal.t() | Unary.t() | Foo.t()

  defmodule Binary do
    alias Lox.{Expr, Token}

    @enforce_keys [:left, :operator, :right]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            left: Expr.t(),
            operator: Token.t(),
            right: Expr.t()
          }

    @spec new(Expr.t(), Token.t(), Expr.t()) :: t()
    def new(left, operator, right), do: %__MODULE__{left: left, operator: operator, right: right}
  end

  defmodule Grouping do
    alias Lox.Expr

    @enforce_keys [:expression]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            expression: Expr.t()
          }

    @spec new(Expr.t()) :: t()
    def new(expression), do: %__MODULE__{expression: expression}
  end

  defmodule Literal do
    @enforce_keys [:value]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            value: term()
          }

    @spec new(term()) :: t()
    def new(value), do: %__MODULE__{value: value}
  end

  defmodule Unary do
    alias Lox.{Expr, Token}

    @enforce_keys [:operator, :right]
    defstruct @enforce_keys

    @type t :: %__MODULE__{
            operator: Token.t(),
            right: Expr.t()
          }

    @spec new(Token.t(), Expr.t()) :: t()
    def new(operator, right), do: %__MODULE__{operator: operator, right: right}
  end
end
