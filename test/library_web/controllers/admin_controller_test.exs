defmodule LibraryWeb.AdminControllerTest do
  use LibraryWeb.ConnCase
  import Plug.Test
  alias Library.Books
  alias Library.Users
  alias Library.Users.User

  @admin %{
    email: "hello@dwyl.com",
    first_name: "dwyl",
    orgs: [],
    username: "dwyl",
    is_admin: true
  }

  test "post /create with access", %{conn: conn} do
    book = %{"title" => "harry potter", "author_list" => "jk rowling", "owned" => false}
    {:ok, %User{id: user_id}} = Users.create_user(@admin)

    conn = conn
    |> init_test_session(%{user_id: user_id})
    |> post("/admin/create", book)
    assert html_response(conn, 302) =~ "redirected"
  end

  test "post /create without access", %{conn: conn} do
    book = %{"title" => "harry potter", "author_list" => "jk rowling", "owned" => false}
    conn = conn
    |> post("/admin/create", book)
    assert html_response(conn, 302) =~ "redirected"
  end

  test "GET /delete/ with access", %{conn: conn} do
    {:ok, %User{id: user_id}} = Users.create_user(@admin)

    Books.create_book_authors!(%{title: "some title", author_list: ["some author"]})

    [%{id: id} | _tail] = Books.list_books()
    conn = conn
    |> init_test_session(%{user_id: user_id})
    |> get("/admin/delete/#{id}")
    assert html_response(conn, 302) =~ "redirected"
  end

end
