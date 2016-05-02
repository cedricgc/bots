# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :bots, Bots.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "PjlIC3pgf0dZfXH36g3Nd9lenNlS3WLcPgkDsnAwlblulGxRhkhbdHqpMCZuRrjc",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Bots.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :bots, Bots.GroupMe.MemeBot,
  bot_id: System.get_env("BOTS_MEMEBOT_BOT_ID"),
  help: """
  Memebot: Posts memes
  memebot COMMAND [args...]

  Options:
  add NAME [URL | "next"]
    Registers image at URL with NAME
  update NAME [URL | "next"]
    Updates URL assigned to NAME
  delete NAME
    Removes registered meme
  help
    Shows this help
  list
    Lists available memes
  insult
    Insults random friend
  """

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

groupme_callback_schema = %{
  "type" => "object",
  "required" => [
    "attachments", 
    "avatar_url", 
    "created_at",
    # "favorited_by", 
    "group_id", 
    "id", 
    "name", 
    "sender_id", 
    "sender_type", 
    "source_guid", 
    "system", 
    "text", 
    "user_id"
  ],
  "properties" => %{
    "attachments" => %{ "type" => "array" },
    "avatar_url" => %{ "type" => ["string", "null"], "format": "uri" },
    "created_at" => %{ "type" => "number" },
    # "favorited_by" => %{ "type" => "array" },
    "group_id" => %{ "type" => "string" },
    "id" => %{ "type" => "string" },
    "name" => %{ "type" => "string" },
    "sender_id" => %{ "type" => "string" },
    "sender_type" => %{ "type" => "string" },
    "source_guid" => %{ "type" => "string" },
    "system" => %{ "type" => "boolean" },
    "text" => %{ "type" => ["string", "null"] },
    "user_id" => %{ "type" => "string" }
  }
}

config :ex_json_schema, :groupme_callback,
  schema: groupme_callback_schema

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false
