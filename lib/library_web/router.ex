defmodule LibraryWeb.Router do
  use LibraryWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug LibraryWeb.Plugs.SetUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LibraryWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/search", PageController, :search
    get "/checkout/:id", PageController, :checkout
    get "/checkin/:id", PageController, :checkin
    get "/show/:id", PageController, :show
    get "/show-web", PageController, :show_web
  end

  scope "/admin", LibraryWeb do
    pipe_through :browser

    get "/", AdminController, :index
    get "/search", AdminController, :search
    post "/create", AdminController, :create
  end

  scope "/login", LibraryWeb do
    pipe_through :browser

    get "/", LoginController, :index
    get "/github", LoginController, :login
    get "/github-callback", LoginController, :callback
    get "/logout", LoginController, :logout
  end

  scope "/logout", LibraryWeb do
    pipe_through :browser

    get "/", LoginController, :logout
  end


  # Other scopes may use custom stacks.
  # scope "/api", LibraryWeb do
  #   pipe_through :api
  # end
end
