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

  defp process_callback_data(message) do
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
    [bot_id: bot_id, help: help_text] = Application.get_env(:bots, __MODULE__)
    [name | subcommands] = command_list
    case subcommands do
      [] -> help(help_text)
      ["help"] -> help(help_text)
      ["list"] -> list_memes()
      ["add", name, url] -> add_meme(name, url)
      ["update", name, url] -> update_meme(name, url)
      ["delete", name] -> delete_meme(name)
      _ -> bad_command()
    end
  end

  defp help(help_text) do
    :atom
  end

  defp list_memes() do
    :atom
  end

  defp add_meme(name, url) do
    :atom
  end

  defp update_meme(name, url) do
    :atom
  end

  defp delete_meme(name) do
    :atom
  end

  defp bad_command() do
    :atom
  end
end