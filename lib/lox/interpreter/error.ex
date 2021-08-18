defmodule Lox.Interpreter.Error do
  defexception [:message, :token]

  @impl true
  def exception(token: token, message: message) do
    %Lox.Interpreter.Error{message: message, token: token}
  end
end
