defmodule LibraryWeb.PageControllerTest do
  use LibraryWeb.ConnCase
  alias Library.Books

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "dwyl | Library"
  end

  test "GET /search", %{conn: conn} do
    Books.create_book_authors!(%{title: "some title", author_list: ["some author"]})

    conn = conn
    |> get("/search", %{"search" => %{"title" => "", "author" => "", "isbn" => ""}})
    assert html_response(conn, 200) =~ "dwyl | Library"
  end

  test "GET /search with no results", %{conn: conn} do
    conn = conn
    |> get("/search", %{"search" => %{"title" => "harry potter", "author" => "", "isbn" => ""}})
    assert html_response(conn, 200) =~ "dwyl | Library"
  end

  test "GET /search as a web search", %{conn: conn} do
    conn = conn
    |> get("/search", %{"search" => %{"title" => "harry potter", "author" => "", "isbn" => ""}, "web" => "web"})
    assert html_response(conn, 200) =~ "dwyl | Library"
  end

end
