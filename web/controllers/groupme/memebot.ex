defmodule Bots.GroupMe.MemeBot do
  use Bots.Web, :controller
  require Logger

  def callback(conn, message_data) do
    Logger.info "Received message from GroupMe"

    %{"text" => text, "sender_id" => sender_id} = message_data

    Logger.debug("Message: #{text} from #{sender_id}")

    json conn, message_data
  end
end