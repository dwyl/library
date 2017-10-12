defmodule LibraryWeb.PageControllerTest do
  use LibraryWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "dwyl | Library"
  end
end
