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
    "favorited_by", 
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
    # array
    "attachments" => %{ "type" => "array" },
    # string, URL
    "avatar_url" => %{ "type" => "string", "format": "uri" },
    # number, epoch timestamp
    "created_at" => %{ "type" => "number" },
    # array
    "favorited_by" => %{ "type" => "array" },
    # string, number string
    "group_id" => %{ "type" => "string" },
    # string, number string
    "id" => %{ "type" => "string" },
    # string, name
    "name" => %{ "type" => "string" },
    # string, number string
    "sender_id" => %{ "type" => "string" },
    # string
    "sender_type" => %{ "type" => "string" },
    # string, number string
    "source_guid" => %{ "type" => "string" },
    # boolean
    "system" => %{ "type" => "boolean" },
    # string
    "text" => %{ "type" => "string" },
    # string, number string
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
