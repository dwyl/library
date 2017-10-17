defmodule LibraryWeb.AdminController do
  use LibraryWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
