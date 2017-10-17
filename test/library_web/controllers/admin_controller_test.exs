defmodule LibraryWeb.AdminControllerTest do
  use LibraryWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/admin"
    assert html_response(conn, 200) =~ "dwyl | Library"
  end
end
