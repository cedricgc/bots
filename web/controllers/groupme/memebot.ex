defmodule Bots.GroupMe.MemeBot do
  use Bots.Web, :controller
  alias Bots.Meme
  alias Bots.MemeTracker
  require Logger

  @friends ["Cedric", "Kyle", "Enrique", "Ian", "Layton", "Andrew"]

  def callback(conn, message_data) do
    Logger.info "Received message from GroupMe"
    [schema: schema] = Application.get_env(:ex_json_schema, :groupme_callback)
    case ExJsonSchema.Validator.validate(schema, message_data) do
      :ok -> 
        Logger.info("JSON received fits format")
        Task.start(fn -> process_callback_data(message_data) end)
        send_resp(conn, :ok, "")
      {:error, _error_list} -> 
        Logger.error("Received Invalid JSON input")
        send_resp(conn, :expectation_failed, "")
    end
  end

  defp process_callback_data(%{"sender_type" => "bot"}), do: Logger.info("Ignoring bot message")
  defp process_callback_data(message = %{"sender_type" => "user"}) do
    %{"text" => body, "user_id" => user_id, "attachments" => attachments} = message
    body = normalize_to_string(body)
    Logger.debug("Message body: #{body}")
    Logger.debug("Attachments: #{inspect attachments}")
    respond_or_dispatch(body, user_id)
  end

  defp normalize_to_string(nil), do: ""
  defp normalize_to_string(message), do: String.strip(message)

  defp respond_or_dispatch(body, user_id) do
    case Repo.get_by(Meme, name: String.downcase(body)) do
      %Meme{name: name, link: link} ->
        Logger.info("Recognized meme #{name}, will post link #{link}")
        serve_image(link)
      nil ->
        tokens = String.split(body)
        Logger.debug("tokens: #{inspect tokens}")
        possible_name = find_possible_name(tokens)
        if String.downcase(possible_name) == "memebot" do
          memebot_dispatch(tokens, user_id)
        else
          Logger.info("Nothing to do, discarding message")
        end
    end
  end

  defp find_possible_name([]), do: ""
  defp find_possible_name(tokens), do: List.first(tokens)

  defp serve_image(image_link) do
    Bots.GroupMe.send_bot_message(memebot_id, image_link)
  end

  defp memebot_dispatch(command_list, user) do
    [_name | subcommands] = command_list
    case subcommands do
      [] -> help()
      ["help"] -> help()
      ["list"] -> list_memes()
      ["insult"] -> insult_friend()
      ["add", name, "next"] -> add_meme_listener(user, String.downcase(name), :add)
      ["add", name, url] -> add_meme(String.downcase(name), url)
      ["update", name, "next"] -> add_meme_listener(user, String.downcase(name), :update)
      ["update", name, url] -> update_meme(String.downcase(name), url)
      ["delete", name] -> delete_meme(String.downcase(name))
      _ -> bad_command()
    end
  end

  def help_text(), do: Application.get_env(:bots, __MODULE__) |> Keyword.fetch!(:help)
  def memebot_id(), do: Application.get_env(:bots, __MODULE__) |> Keyword.fetch!(:bot_id)

  defp add_meme_listener(user, name, :add) do
    MemeTracker.set_meme(MemeTracker, user, name, :add)
    Logger.info("Added listener for user #{user} on meme name #{name} for a future add action")

    notify_add_listener("Next image posted by user will be added for meme #{name}")
  end
  defp add_meme_listener(user, name, :update) do
    MemeTracker.set_meme(MemeTracker, user, name, :update)
    Logger.info("Added listener for user #{user} on meme name #{name} for a future update action")

    notify_add_listener("Next image posted by user will update meme #{name}")
  end

  defp notify_add_listener(message) do
    Bots.GroupMe.send_bot_message(memebot_id, message)
  end

  defp help() do
    Bots.GroupMe.send_bot_message(memebot_id, help_text)
  end

  defp list_memes() do
    memes = Repo.all(Meme)
    |> Enum.map(fn(meme) -> meme.name end)
    |> Enum.join("\n")
    Bots.GroupMe.send_bot_message(memebot_id, "Memes available:\n#{memes}")
  end

  defp insult_friend() do
    target = Enum.random(@friends)
    Bots.GroupMe.send_bot_message(memebot_id, "Fuck you #{target}")
  end

  defp add_meme(name, url) do
    changeset = Meme.changeset(%Meme{}, %{"name" => name, "link" => url})
    case Repo.insert(changeset) do
      {:ok, _meme} ->
        Logger.info("Registered #{name} with image #{url}")
        Bots.GroupMe.send_bot_message(memebot_id, "Registered #{name} with image #{url}")
      {:error, %Ecto.Changeset{errors: [name: error]}} ->
        Bots.GroupMe.send_bot_message(memebot_id, "ERROR: Issue with name: #{error}")
      {:error, %Ecto.Changeset{errors: [link: error]}} ->
        Bots.GroupMe.send_bot_message(memebot_id, "ERROR: Issue with url: #{error}")
    end
  end

  defp update_meme(name, url) do
    meme = Repo.get_by(Meme, name: name)
    if meme == nil do
      Logger.info("Could not find meme name in registered names")
      message = "Could not find meme name in registered names, " <>
        "use memebot list to list all registered memes"
      Bots.GroupMe.send_bot_message(memebot_id, message)
    else
      changeset = Meme.changeset(meme, %{"name" => name, "link" => url})
      case Repo.update(changeset) do
        {:ok, _meme} ->
          Logger.info("Updated #{name} with image #{url}")
          Bots.GroupMe.send_bot_message(memebot_id, "Updated #{name} with image #{url}")
        {:error, %Ecto.Changeset{errors: [name: error]}} ->
          Bots.GroupMe.send_bot_message(memebot_id, "ERROR: Issue with name: #{error}")
        {:error, %Ecto.Changeset{errors: [link: error]}} ->
          Bots.GroupMe.send_bot_message(memebot_id, "ERROR: Issue with url: #{error}")
      end
    end
  end

  defp delete_meme(name) do
    meme = Repo.get_by(Meme, name: name)
    if meme == nil do
      Logger.info("Could not find meme name in registered names")
      message = "Could not find meme name in registered names, " <>
        "use memebot list to list all registered memes"
      Bots.GroupMe.send_bot_message(memebot_id, message)
    else
      Repo.delete!(meme)
      Logger.info("Deleted meme #{name}")
      Bots.GroupMe.send_bot_message(memebot_id, "Deleted meme #{name}")
    end
  end

  defp bad_command() do
    error_message = """
    Error: Command was unrecognized or was provided the wrong number of arguments.
    Use memebot help to list all commands.
    """
    Bots.GroupMe.send_bot_message(memebot_id, error_message)
  end
end