defmodule Bots.MemeTest do
  use Bots.ModelCase

  alias Bots.Meme

  @valid_attrs %{link: "https://i.groupme.com/8c294880d2f301301dd332bc697c4904", name: "meme.gif"}
  @invalid_attrs %{link: "ftp://ftp.example.com/meme.gif", name: "meme.gif"}

  test "changeset with valid attributes" do
    changeset = Meme.changeset(%Meme{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid link" do
    assert {:link, "Invalid scheme, must be http or https"} in errors_on(%Meme{}, @invalid_attrs)
  end

  test "changset with no required name" do
    changeset = Meme.changeset(%Meme{}, Map.delete(@valid_attrs, :name))
    refute changeset.valid?
  end

  test "changset with no required link" do
    changeset = Meme.changeset(%Meme{}, Map.delete(@valid_attrs, :link))
    refute changeset.valid?
  end
end
