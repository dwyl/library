defmodule LibraryWeb.LoginController do
  use LibraryWeb, :controller

  def index(conn, _params) do
    IO.inspect(conn.assigns[:user])
    render conn, "index.html"
  end

  def login(conn, _params) do

    case ElixirAuthGithub.login_url_with_scope(["user:email", "read:org"]) do
      {:err, reason} ->
        IO.inspect(reason)
        render conn, "index.html"
      {:ok, url} ->
        redirect conn, external: url
    end
  end

  def callback(conn, %{"code" => code}) do
    case ElixirAuthGithub.github_auth(code) do
      {:error, error} ->
        IO.inspect(error)
        conn
        |> put_flash(:error, "Problem getting info from github, try again later")
        |> render("index.html")
      {:ok, user} ->
        IO.inspect(user)
        case add_user(user) do
            {:ok, user} ->
              IO.inspect(user)
              conn = conn
                    |> put_flash(:info, "added to db succesfully")
                    |> put_session(:user_id, user.id)
              redirect(conn, to: page_path(conn, :index))
            {:error, "not a dwyl member"} ->
              conn = conn
                     |> put_flash(:error, "Sorry, the library can only be used by members of dwyl!")

              redirect(conn, to: page_path(conn, :index))
            error ->
              IO.inspect(error)
              conn = conn
                     |> put_flash(:error, "Problem adding user, sorry, try again later!")

              redirect(conn, to: page_path(conn, :index))

        end
    end
  end

  defp add_user(%{"name" => first_name, "organizations_url" => org_url, "login" => username, "access_token" => token}) do
    case get_orgs_and_email(org_url, token) do
      {:ok, %{"orgs" => orgs, "email" => email}} ->
        if is_member_of_dwyl?(orgs) do
          insert_or_update_user(
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
        # TODO: check if user exists in database, if they do, get them out, if
        # they don't, add them
      _error ->
        {:error, "problem getting info from github"}
    end
  end

  def get_orgs_and_email(org_url, token) do
    case get_orgs(org_url, token) do
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

  def get_orgs(org_url, token) do
    case HTTPoison.get(org_url, [{"Accept", "application/json"}, {"Authorization", "token #{token}"}]) do
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
      {:error, reason} ->
        IO.inspect reason
        {:error, "problem getting orgs"}
    end
  end

  def is_member_of_dwyl?(orgs) do
    Enum.any? orgs, fn org -> org == "dwyl" end
  end

  def get_primary_email(token) do
    case HTTPoison.get("https://api.github.com/user/emails", [{"Accept", "application/json"}, {"Authorization", "token #{token}"}]) do
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
      {:error, reason} ->
        IO.inspect(reason)
        {:error, "problem getting emails"}
    end
  end

  def insert_or_update_user(%{username: username} = user) do
    case Library.Users.get_user_by_username(username) do
      nil ->
        Library.Users.create_user(user)
      old_user ->
        Library.Users.update_user(old_user, user)
    end
  end

  # TODO:
  # set up route for redirect for user to log in DONE
  # use the github callback thing DONE
  # put user in database DONE
  # set session with user information
  # create plug for requiring auth
  # protect routes so that only logged in users can view them
  # create plug for requiring user to be an admin
  # protect routes so that only admins can view them
  #
end