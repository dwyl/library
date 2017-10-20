defmodule LibraryWeb.Plugs.SetUser do
  import Plug.Conn
  import Phoenix.Controller

  alias Library.Users

  def init(_params) do

  end

  @doc """
    Checks if the user_id exists on the session, and if it does, we query the
    database and get their info, and put that on the assigns part of the conn
    under the key of user, if not we set the user as nil. 
  """

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
