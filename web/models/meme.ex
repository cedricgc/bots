defmodule Bots.Meme do
  use Bots.Web, :model

  schema "memes" do
    field :name, :string
    field :link, :string

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w(link)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:name)
  end
end
