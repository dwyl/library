defmodule LibraryWeb.LayoutView do
  use LibraryWeb, :view

  defdelegate get_user(conn), to: LibraryWeb.ComponentView

  def get_login_button_text(conn) do
    if get_user(conn) do
      "Logout"
    else
      "Login"
    end
  end

  def get_login_button_route(conn) do
    if get_user(conn) do
      login_path(conn, :logout)
    else
      login_path(conn, :login)
    end
  end


end
