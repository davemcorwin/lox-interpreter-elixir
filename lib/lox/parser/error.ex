defmodule Lox.Parser.Error do
  defexception [:message, :token]

  @impl true
  def exception(token: token, message: message) do
    %Lox.Parser.Error{message: message, token: token}
  end
end
