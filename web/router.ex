defmodule Bots.Router do
  use Bots.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Bots do
    pipe_through :browser # Use the default browser stack

    # get "/", PageController, :index
  end

  scope "/groupme", Bots.GroupMe do
    pipe_through :api

    post "/memebot/callback", MemeBotController, :callback
  end

  # Other scopes may use custom stacks.
  # scope "/api", Bots do
  #   pipe_through :api
  # end
end
