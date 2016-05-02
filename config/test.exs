use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bots, Bots.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn, backends: []

# Configure your database
config :bots, Bots.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "bots_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
