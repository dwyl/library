defmodule LibraryWeb.AdminControllerTest do
  use LibraryWeb.ConnCase
  alias Library.Books

  @books %{books: [%{title: "Test title", author_list: ["Test author"],
                     thumbnail_small: "test.jpg", owned: false}]}

  test "GET /", %{conn: conn} do
    conn = conn
    |> Map.put(:assigns, @books)
    |> get("/admin")
    assert html_response(conn, 200) =~ "dwyl | Library"
  end

  test "GET /search", %{conn: conn} do
    conn = conn
    |> get("/admin/search", %{"search" => %{"query" => "harry potter"}})
    assert html_response(conn, 200) =~ "dwyl | Library"
  end

  test "post /create with a book that already exists in db", %{conn: conn} do
    book = %{"title" => "harry potter", "author_list" => "jk rowling", "owned" => false}

    book
    |> Map.put("author_list", [book["author_list"]])
    |> Books.create_book_authors!

    conn = conn
    |> post("/admin/create", book)
    assert html_response(conn, 200) =~ "dwyl | Library"
  end

  test "post /create", %{conn: conn} do
    book = %{"title" => "harry potter", "author_list" => "jk rowling", "owned" => false}
    conn = conn
    |> post("/admin/create", book)
    assert html_response(conn, 200) =~ "dwyl | Library"
  end
end
