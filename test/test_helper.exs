ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Bots.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Bots.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Bots.Repo)

