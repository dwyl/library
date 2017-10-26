defmodule LibraryWeb.AdminControllerTest do
  use LibraryWeb.ConnCase
  import Plug.Test
  alias Library.Books
  alias Library.Users.User
  alias Library.Users

  @books %{books: [%{title: "Test title", author_list: ["Test author"],
                     thumbnail_small: "test.jpg", owned: false}]}

  @admin %{
    email: "hello@dwyl.com",
    first_name: "dwyl",
    orgs: [],
    username: "dwyl",
    is_admin: true
  }

  test "GET / with access", %{conn: conn} do
    {:ok, %User{id: user_id}} = Users.create_user(@admin)

    conn = conn
    |> Map.put(:assigns, @books)
    |> init_test_session(%{user_id: user_id})
    |> get("/admin")
    assert html_response(conn, 200) =~ "dwyl | Library"
  end

  test "GET / without access", %{conn: conn} do
    conn = conn
    |> Map.put(:assigns, @books)
    |> get("/admin")
    assert html_response(conn, 302) =~ "redirected"
  end

  test "GET /search with access", %{conn: conn} do

    {:ok, %User{id: user_id}} = Users.create_user(@admin)

    conn = conn
    |> Map.put(:assigns, @books)
    |> init_test_session(%{user_id: user_id})
    |> get("/admin/search", %{"search" => %{"query" => "harry potter"}})

    assert html_response(conn, 200) =~ "dwyl | Library"
  end

  test "GET /search without access", %{conn: conn} do
    conn = conn
    |> get("/admin/search", %{"search" => %{"query" => "harry potter"}})
    assert html_response(conn, 302) =~ "redirected"
  end

  test "post /create with a book that already exists in db with access", %{conn: conn} do
    book = %{"title" => "harry potter", "author_list" => "jk rowling", "owned" => false}

    {:ok, %User{id: user_id}} = Users.create_user(@admin)

    book
    |> Map.put("author_list", [book["author_list"]])
    |> Books.create_book_authors!

    conn = conn
    |> init_test_session(%{user_id: user_id})
    |> Map.put(:assigns, @books)
    |> post("/admin/create", book)
    assert html_response(conn, 200) =~ "dwyl | Library"
  end

  test "post /create with access", %{conn: conn} do
    book = %{"title" => "harry potter", "author_list" => "jk rowling", "owned" => false}
    {:ok, %User{id: user_id}} = Users.create_user(@admin)

    conn = conn
    |> init_test_session(%{user_id: user_id})
    |> post("/admin/create", book)
    assert html_response(conn, 200) =~ "dwyl | Library"
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
    assert html_response(conn, 200) =~ "dwyl | Library"
  end
end
