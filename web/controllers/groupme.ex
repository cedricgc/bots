defmodule Bots.GroupMe do
  require Logger

  @base_url "https://api.groupme.com/v3"
  @headers [{"Content-Type", "application/json"}]

  def send_bot_message(bot_id, message) do
    body = %{"bot_id" => bot_id, "text" => message} |> Poison.encode!
    case HTTPoison.post(@base_url <> "/bots/post", body, @headers) do
      {:ok, %HTTPoison.Response{status_code: 202}} -> Logger.info("Posted bot message to GroupMe: #{message}")
      {:ok, %HTTPoison.Response{status_code: 400}} -> Logger.error("GroupMe did not accept message")
      {:error, err} -> Logger.error("Failed to post message to GroupMe")
    end
  end
end