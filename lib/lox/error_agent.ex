defmodule Lox.ErrorAgent do
  use Agent

  def start_link(report \\ fn -> nil end) do
    Agent.start_link(
      fn ->
        %{
          error: false,
          report: report,
          runtime_error: false
        }
      end,
      name: __MODULE__
    )
  end

  def error(error) do
    Agent.update(__MODULE__, fn state ->
      state.report.(error)
      %{state | error: true}
    end)
  end

  def clear_error do
    Agent.update(__MODULE__, &Map.put(&1, :error, false))
  end

  def clear_runtime_error do
    Agent.update(__MODULE__, &Map.put(&1, :runtime_error, false))
  end

  def runtime_error(error) do
    Agent.update(__MODULE__, fn state ->
      state.report.(error)
      %{state | runtime_error: true}
    end)
  end

  def has_error? do
    Agent.get(__MODULE__, &(Map.get(&1, :error) === true))
  end

  def has_runtime_error? do
    Agent.get(__MODULE__, &(Map.get(&1, :runtime_error) === true))
  end
end
