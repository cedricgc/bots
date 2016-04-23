defmodule Bots.GroupMe.MemeBot do
  use Bots.Web, :controller
  alias Bots.Meme
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
    case Repo.get_by(Meme, name: body) do
      %Meme{name: name, link: link} ->
        Logger.info("Recognized meme #{name}, will post link #{link}")
        serve_image(link)
      nil ->
        tokens = String.split(body)
        Logger.info("tokens: #{inspect tokens}")
        possible_name = List.first(tokens) |> String.downcase
        if possible_name == "memebot" do
          memebot_dispatch(tokens)
        else
          Logger.info("Nothing to do, discarding message")
        end
    end
  end

  defp serve_image(image_link) do
    Bots.GroupMe.send_bot_message(memebot_id, image_link)
  end

  defp memebot_dispatch(command_list) do
    [name | subcommands] = command_list
    case subcommands do
      [] -> help()
      ["help"] -> help()
      ["list"] -> list_memes()
      ["insult"] -> insult_friend()
      ["add", name, url] -> add_meme(name, url)
      ["update", name, url] -> update_meme(name, url)
      ["delete", name] -> delete_meme(name)
      _ -> bad_command()
    end
  end

  def help_text(), do: Application.get_env(:bots, __MODULE__) |> Keyword.fetch!(:help)
  def memebot_id(), do: Application.get_env(:bots, __MODULE__) |> Keyword.fetch!(:bot_id)

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