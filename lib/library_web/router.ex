defmodule LibraryWeb.Router do
  use LibraryWeb, :router

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

  scope "/", LibraryWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/admin", LibraryWeb do
    pipe_through :browser

    get "/", AdminController, :index
    get "/search", AdminController, :search
    post "/create", AdminController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", LibraryWeb do
  #   pipe_through :api
  # end
end
