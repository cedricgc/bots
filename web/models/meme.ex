defmodule Bots.Meme do
  use Bots.Web, :model

  schema "memes" do
    field :name, :string
    field :link, :string

    timestamps
  end

  @required_fields ~w(name link)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:name)
    |> validate_change(:link, :link_valid, &valid_link/2)
  end

  def valid_link(_field, str) do
    uri = URI.parse(str)
    case uri do
      %URI{scheme: nil} -> [link: "Link is not a url"]
      %URI{host: nil} -> [link: "Link is not a url"]
      %URI{path: nil} -> [link: "Link is not a url"]
      %URI{scheme: "http"} -> []
      %URI{scheme: "https"} -> []
      %URI{scheme: _} -> [link: "Invalid scheme, must be http or https"]
    end 
  end 
end
