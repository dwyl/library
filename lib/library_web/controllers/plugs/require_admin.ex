defmodule LibraryWeb.Plugs.RequireAdmin do
  import Plug.Conn
  import Phoenix.Controller
  alias LibraryWeb.Router.Helpers

  def init(_params) do
  end

  @doc """
    Checks if the user exists on the connection, and that they are an admin. If
    they are we pass the connection along so that the user carries on to whatever path they were going to, if they are not we redirect them to the home route and put a flash message up telling them why they were redirected
  """
  def call(conn, _params) do
    if conn.assigns[:user] && conn.assigns[:user].is_admin === true do
      conn
    else
      conn
      |> put_flash(:error, "You must be an admin to access that page")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end
end
