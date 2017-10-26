defmodule LibraryWeb.LoginController do
  use LibraryWeb, :controller
  alias Library.Users
  @elixir_auth_github Application.get_env(:library, :elixir_auth_github) || ElixirAuthGithub

  @httpoison Application.get_env(:library, :httpoison) || HTTPoison


  @doc """
    Creates a github URL with the scope for getting the user's email and orgs
    renders the index.html if there is a failure constructing it (can only
    happen when elixir_auth_github is not configured correctly/env variables
    are not set), and redirects to github login if the url is correct
  """
  def login(conn, _params) do

    case @elixir_auth_github.login_url_with_scope(["user:email", "read:org"]) do
      {:err, _reason} ->
        # TODO: set internal server error
        conn
        |> put_flash(:error, "Something went wrong on our end, try again later!")
        |> redirect(to: page_path(conn, :index))
      {:ok, url} ->
        redirect conn, external: url
    end
  end

  @doc """
    This is the route which will be called after the user has authenticated on
    github, it takes the code from github, and then ElixirAuthGithub goes and
    gets the user's details. If there's an error, we send the user to the index
    page, with an error message, if it's succesful, we proceed to get their
    email and organisations in separate requests to the github api, and then
    check if they're a member of dwyl. If all of this happens without a hitch,
    we insert them into the database (or update their entry, if they're already in there). If there's any errors along the way then we redirect the user to
    the index page with a message about what went wrong.
  """

  def callback(conn, %{"code" => code}) do
    case @elixir_auth_github.github_auth(code) do
      {:error, _error} ->
        conn
        |> put_flash(:error, "Problem getting info from github, try again later")
        |> redirect(to: page_path(conn, :index))
      {:ok, user} ->
        case add_user(user) do
            {:ok, user} ->
              conn
              |> put_flash(:info, "Added to db succesfully")
              |> put_session(:user_id, user.id)
            {:error, "not a dwyl member"} ->
               conn
               |> put_flash(:error, "Sorry, the library can only be used by members of dwyl!")
            _error ->
              conn
              |> put_flash(:error, "Problem adding user, sorry, try again later!")
        end
        |> redirect(to: page_path(conn, :index))
    end
  end

  def logout(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> redirect(to: page_path(conn, :index))
  end

  defp add_user(%{"name" => first_name, "login" => username, "access_token" => token}) do
    case get_orgs_and_email(token) do
      {:ok, %{"orgs" => orgs, "email" => email}} ->
        if is_member_of_dwyl?(orgs) do
          Users.insert_or_update_user(
          %{
            email: email,
            first_name: first_name,
            orgs: [],
            username: username,
            is_admin: false
          }
          )
        else
          {:error, "not a dwyl member"}
        end
      _error ->
        {:error, "problem getting info from github"}
    end
  end

  defp get_orgs_and_email(token) do
    case get_orgs(token) do
      {:ok, orgs} ->
        case get_primary_email(token) do
          {:ok, email} ->
            {:ok, %{"orgs" => orgs, "email" => email}}
          _error ->
            {:error, "problem getting info from github"}
        end
      _error ->
        {:error, "problem getting info from github"}
    end
  end

  defp get_orgs(token) do
    case @httpoison.get("https://api.github.com/user/orgs", [{"Accept", "application/json"}, {"Authorization", "token #{token}"}]) do
      {:ok, res} ->
        res.body
        |> Poison.decode
        |> case do
          {:ok, body} ->
            cond do
              is_list(body) ->
                {:ok,
                  Enum.map(body, fn org -> org["login"] end)
                  }

              true ->
                {:error, "problem getting orgs"}
            end
          error ->
            error
        end
      {:error, _reason} ->
        {:error, "problem getting orgs"}
    end
  end

  defp is_member_of_dwyl?(orgs) do
    Enum.any? orgs, fn org -> org == "dwyl" end
  end

  defp get_primary_email(token) do
    case @httpoison.get("https://api.github.com/user/emails", [{"Accept", "application/json"}, {"Authorization", "token #{token}"}]) do
      {:ok, res} ->
        res.body
        |> Poison.decode
        |> case do
          {:ok, body} ->
            cond do
              is_list(body) ->
                email = Enum.find(body, fn email -> email["primary"] end)
                {:ok, email["email"]}
              true ->
                {:error, "problem getting emails"}
            end
          error ->
            error
        end
      {:error, _reason} ->
        {:error, "problem getting emails"}
    end
  end
end
