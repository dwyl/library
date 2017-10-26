defmodule LibraryWeb.LoginControllerTest do
  use LibraryWeb.ConnCase
  alias Library.Users

  test "GET /", %{conn: conn} do
    conn = get conn, "/login"
    assert html_response(conn, 200) =~ "dwyl | Library"
  end

  test "GET /login with env set", %{conn: conn} do
    Application.put_env(:elixir_auth_github, :client_id, "TEST_ID")
    conn = get conn, "/login/github"

    assert html_response(conn, 302) =~ "redirected"
  end

  test "GET /login without env set", %{conn: conn} do
    Application.put_env(:elixir_auth_github, :client_id, nil)
    conn = get conn, "/login/github"
    assert html_response(conn, 200) =~ "dwyl | Library"
  end

  test "GET /login/github-callback with error on first gh call", %{conn: conn} do
    conn = get conn, "/login/github-callback", %{"code" => "123"}
    assert html_response(conn, 200) =~ "Problem getting info from github, try again later"
  end

  test "GET /login/github-callback with success", %{conn: conn} do
    conn = get conn, "/login/github-callback", %{"code" => "456"}
    assert html_response(conn, 302) =~ "redirected"
  end

  test "GET /login/github-callback with person not a member of dwyl", %{conn: conn} do
    conn = get conn, "/login/github-callback", %{"code" => "789"}
    assert html_response(conn, 302) =~ "redirected"
  end

  test "GET /login/github-callback with an error getting orgs", %{conn: conn} do
    conn = get conn, "/login/github-callback", %{"code" => "235"}
    assert html_response(conn, 302) =~ "redirected"
  end

  test "GET /login/github-callback with success, with user already in db", %{conn: conn} do
    Users.create_user(%{
      email: "indiana@dwyl.com",
      first_name: "indiana",
      orgs: [],
      username: "temple-of-doom",
      is_admin: false
    })
    conn = get conn, "/login/github-callback", %{"code" => "456"}
    assert html_response(conn, 302) =~ "redirected"
  end

  test "GET /login/github-callback with invalid json when getting emails", %{conn: conn} do
    conn = get conn, "/login/github-callback", %{"code" => "420"}
    assert html_response(conn, 302) =~ "redirected"
  end

  test "GET /login/github-callback with invalid json when getting orgs", %{conn: conn} do
    conn = get conn, "/login/github-callback", %{"code" => "365"}
    assert html_response(conn, 302) =~ "redirected"
  end

end
