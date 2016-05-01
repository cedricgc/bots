defmodule Bots.MemeTracker do
  @moduledoc """
  This module is responsible for managing the meme names users will register
  and image with provided in a future message.
  """

  @doc """
  Starts a new tracker.
  """
  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  Gets the current traacked meme name for the user
  """
  def get_meme(user) do
    Agent.get(__MODULE__, &Map.get(&1, user))
  end

  @doc """
  Sets the current meme name to listen for. Will overwrite
  the current name if saved.
  """
  def set_meme(user, name, action) do
    value = %{:name => name, :action => action}
    Agent.update(__MODULE__, &Map.put(&1, user, value))
  end
end