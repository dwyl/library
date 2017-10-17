defmodule LibraryWeb.AdminControllerTest do
  use LibraryWeb.ConnCase

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
end
