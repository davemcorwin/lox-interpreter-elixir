alias Lox.{ErrorAgent, Interpreter, Parser, Scanner, Token}

defmodule Lox.CLI do
  def main(args) do
    {_, args, _} = OptionParser.parse(args, strict: [])

    ErrorAgent.start_link(&report/1)

    case args do
      [file] -> run_file(file)
      _ -> run_prompt()
    end
  end

  def run_file(file) do
    file
    |> File.read!()
    |> run()

    if ErrorAgent.has_error?() or ErrorAgent.has_runtime_error?() do
      exit(:shutdown)
    end
  end

  def run_prompt() do
    IO.puts("\nWelcome to the Lox REPL! Press ctrl-c to exit.\n")
    run_prompt(1)
  end

  def run_prompt(num) do
    case IO.gets("Lox(#{num})> ") do
      :eof ->
        IO.puts("Exiting Lox REPL")
        exit(:normal)

      line ->
        run(line)
        ErrorAgent.clear_error()
        ErrorAgent.clear_runtime_error()
        run_prompt(num + 1)
    end
  end

  def run(source) do
    expression =
      source
      |> Scanner.scan()
      |> Parser.parse()

    unless ErrorAgent.has_error?() do
      value = Interpreter.interpret(expression)
      IO.puts(value)
    end
  end

  def report(%Lox.Scanner.Error{} = error) do
    report(error.line, "", error.message)
  end

  def report(%{token: %Token{type: :eof} = token} = error) do
    report(token.line, " at end", error.message)
  end

  def report(%{token: %Token{} = token} = error) do
    report(token.line, " at '" <> token.lexeme <> "'", error.message)
  end

  def report(line, where, message) do
    IO.warn("[line #{line}] Error #{where}: #{message}", [])
  end
end
