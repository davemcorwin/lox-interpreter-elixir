defmodule Lox.Interpreter.Helpers do
  alias Lox.Interpreter.Error

  def error!(token, message), do: raise(Error, token: token, message: message)
  def is_equal(a, b), do: a === b
  def is_truthy(value) when is_nil(value), do: false
  def is_truthy(value) when is_boolean(value), do: value
  def is_truthy(_), do: true
end
