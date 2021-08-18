defmodule Lox.Interpreter do
  alias Lox.ErrorAgent
  alias Lox.Interpreter.{Error, Eval}

  def interpret(expr) do
    try do
      Eval.evaluate(expr)
    rescue
      e in [Error] -> ErrorAgent.runtime_error(e)
    end
  end
end
