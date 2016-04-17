defmodule Bots.Repo.Migrations.CreateMeme do
  use Ecto.Migration

  def change do
    create table(:memes) do
      add :name, :text
      add :link, :text

      timestamps
    end
    create unique_index(:memes, [:name])

  end
end
