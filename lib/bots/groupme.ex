defmodule Bots.GroupMe do
  @base_url "https://api.groupme.com/v3"
  @headers [{"Content-Type", "application/json"}]

  def send_bot_message(bot_id, message) do
    body = %{"bot_id" => bot_id, "text" => message} |> Poison.encode!
    HTTPoison.post(@base_url <> "/bots/post", body, @headers)
  end
end