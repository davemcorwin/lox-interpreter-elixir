defmodule Lox.Scanner.Error do
  defexception [:line, :message]

  @impl true
  def exception(line: line, message: message) do
    %Lox.Scanner.Error{line: line, message: message}
  end
end
