defmodule Bots.MemeTracker do
  @moduledoc """
  This module is responsible for managing the meme names users will register
  and image with provided in a future message.
  """

  @doc """
  Starts a new tracker.
  """
  def start_link(name) do
    Agent.start_link(fn -> %{} end, name: name)
  end

  @doc """
  Gets the current traacked meme name for the user
  """
  def get_meme(tracker, user) do
    Agent.get(tracker, &Map.get(&1, user))
  end

  @doc """
  Sets the current meme name to listen for. Will overwrite
  the current name if saved.
  """
  def set_meme(tracker, user, name, action) do
    value = %{:name => name, :action => action}
    Agent.update(tracker, &Map.put(&1, user, value))
  end

  @doc """
  Clears any meme data set for user
  """
  def get_and_delete_meme(tracker, user) do
    Agent.get_and_update(tracker, &Map.pop(&1, user))
  end
end