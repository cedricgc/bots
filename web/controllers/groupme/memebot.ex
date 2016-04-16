defmodule Bots.GroupMe.MemeBot do
  use Bots.Web, :controller
  require Logger

  def callback(conn, message_data) do
    Logger.info "Received message from GroupMe"

    [schema: schema] = Application.get_env(:ex_json_schema, :groupme_callback)
    case ExJsonSchema.Validator.validate(schema, message_data) do
      :ok -> 
        Logger.info("JSON received fits format")
        Task.start(fn -> process_callback_data(message_data) end)
        send_resp(conn, :ok, "")
      {:error, error_list} -> 
        Logger.error("Received Invalid JSON input")
        send_resp(conn, :expectation_failed, "")
    end
  end

  defp process_callback_data(%{"sender_type" => "bot"}), do: Logger.info("Ignoring bot message")
  defp process_callback_data(message = %{"sender_type" => "user"}) do
    %{"text" => body} = message
    body = body |> String.strip
    Logger.info("Message body: #{body}")
    if meme?(body) do
      serve_image(body)
    else
      tokens = String.split(body)
      Logger.info("tokens: #{inspect tokens}")
      if List.first(tokens) == "memebot" do
        memebot_dispatch(tokens)
      end
    end
  end

  defp meme?(string) do
    false
  end

  defp serve_image(image_name) do
    Logger.info("serving image with name #{image_name}")
  end

  defp memebot_dispatch(command_list) do
    [name | subcommands] = command_list
    case subcommands do
      [] -> help()
      ["help"] -> help()
      ["list"] -> list_memes()
      ["insult"] -> insult_layton()
      ["add", name, url] -> add_meme(name, url)
      ["update", name, url] -> update_meme(name, url)
      ["delete", name] -> delete_meme(name)
      _ -> bad_command()
    end
  end

  defp help_text(), do: Application.get_env(:bots, __MODULE__) |> Keyword.fetch!(:help)
  defp memebot_id(), do: Application.get_env(:bots, __MODULE__) |> Keyword.fetch!(:bot_id)

  defp help() do
    Bots.GroupMe.send_bot_message(memebot_id, help_text)
  end

  defp list_memes() do
    Bots.GroupMe.send_bot_message(memebot_id, "Memes available:\n")
  end

  defp insult_layton() do
    Bots.GroupMe.send_bot_message(memebot_id, "Fuck you Layton")
  end

  defp add_meme(name, url) do
    Bots.GroupMe.send_bot_message(memebot_id, "Registered #{name} with image #{url}")
  end

  defp update_meme(name, url) do
    Bots.GroupMe.send_bot_message(memebot_id, "Updated #{name} with image #{url}")
  end

  defp delete_meme(name) do
    Bots.GroupMe.send_bot_message(memebot_id, "Deleted meme #{name}")
  end

  defp bad_command() do
    error_message = """
    Error: Command was unrecognized or was provided the wrong number of arguments.
    Use memebot help to list all commands.
    """
    Bots.GroupMe.send_bot_message(memebot_id, error_message)
  end
end