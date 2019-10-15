defmodule ElixirWorkshopWeb.Router do
  use ElixirWorkshopWeb, :router

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

  scope "/", ElixirWorkshopWeb do
    pipe_through :browser

    get "/", PageController, :index

    resources "/ideas", IdeaController
  end

  # Other scopes may use custom stacks.
  # scope "/api", ElixirWorkshopWeb do
  #   pipe_through :api
  # end
end
