defmodule LibraryWeb.Plugs.RequireAuth do
  import Plug.Conn
  import Phoenix.Controller
  alias LibraryWeb.Router.Helpers

  def init(_params) do
  end

  def call(conn, _params) do
    if conn.assigns[:user] do
      conn
    else
      conn
      |> put_flash(:error, "You must be an admin to access that page")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end
end
