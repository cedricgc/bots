defmodule Bots.GroupMe.MemeBot do
  use Bots.Web, :controller
  require Logger

  def callback(conn, message_data) do
    Logger.info "Received message from GroupMe"

    [schema: schema] = Application.get_env(:ex_json_schema, :groupme_callback)
    case ExJsonSchema.Validator.validate(schema, message_data) do
      :ok -> 
        Logger.info("JSON received fits format")
        send_resp(conn, :ok, "")
      {:error, error_list} -> 
        Logger.error("Received Invalid JSON input")
        send_resp(conn, :expectation_failed, "")
    end
  end
end