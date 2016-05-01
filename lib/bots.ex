defmodule Bots do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    schema_validations()

    children = [
      # Start the endpoint when the application starts
      supervisor(Bots.Endpoint, []),
      # Start the Ecto repository
      supervisor(Bots.Repo, []),
      # Here you could define other workers and supervisors as children
      # worker(Bots.Worker, [arg1, arg2, arg3]),
      worker(Bots.MemeTracker, [Bots.MemeTracker])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bots.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Bots.Endpoint.config_change(changed, removed)
    :ok
  end

  def schema_validations() do
    # Validate Groupme Callback schema
    groupme_schema = Application.get_env(:ex_json_schema, :groupme_callback) 
    |> Keyword.fetch!(:schema)
    ExJsonSchema.Schema.resolve(groupme_schema)
  end
end
