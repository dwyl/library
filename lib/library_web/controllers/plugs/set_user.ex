defmodule LibraryWeb.Plugs.SetUser do
  import Plug.Conn
  import Phoenix.Controller

  alias Library.Users

  def init(_params) do

  end

  def call(conn, _params) do
    user_id = get_session(conn, :user_id)
    cond do
      user = user_id && Users.get_user(user_id) ->
        assign(conn, :user, user)
      true ->
        assign(conn, :user, nil)
    end

  end

end
