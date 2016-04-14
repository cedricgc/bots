defmodule Bots.PageController do
  use Bots.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
