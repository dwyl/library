defmodule LibraryWeb.PageControllerTest do
  use LibraryWeb.ConnCase
  alias Library.Books
  alias Library.Users

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

  test "GET /show/:id shows a single book by id", %{conn: conn} do
    %{id: id} = Books.create_book!(%{title: "some title", author_list: ["some author"]})

    conn = conn
    |> get("/show/#{id}")
    assert html_response(conn, 200) =~ "dwyl | Library"
  end

  test "GET /show-web shows a single book by query params", %{conn: conn} do
    conn = conn
    |> get("/show-web", %{"title" => "some book", "author_list" => "some author", "isbn_10" => "123"})
    assert html_response(conn, 200) =~ "dwyl | Library"
  end

  test "GET /checkout/:id checks out a book", %{conn: conn} do
    %{id: id} = Books.create_book!(%{title: "some title", author_list: ["some author"]})

    {:ok, %{id: user_id}} = Users.create_user(%{email: "finn@finn.com",
                                first_name: "Finn",
                                is_admin: false,
                                orgs: ["dwyl"],
                                username: "finnhodgkin"})
    assigns = Map.put(conn.assigns, :user, %{id: user_id})

    conn = conn
    |> Map.put(:assigns, assigns)
    |> get("/checkout/#{id}")
    assert html_response(conn, 302) =~ "redirected"
  end

  test "GET /checkout/:id checks in a book", %{conn: conn} do
    %{id: id} = Books.create_book!(%{title: "some title", author_list: ["some author"]})

    {:ok, %{id: user_id}} = Users.create_user(%{email: "finn@finn.com",
                                first_name: "Finn",
                                is_admin: false,
                                orgs: ["dwyl"],
                                username: "finnhodgkin"})
    assigns = Map.put(conn.assigns, :user, %{id: user_id})

    Books.checkout_book(id, user_id)

    conn = conn
    |> Map.put(:assigns, assigns)
    |> get("/checkout/#{id}")
    assert html_response(conn, 302) =~ "redirected"
  end

  test "GET /checkin/:id checks in a book", %{conn: conn} do
    %{id: id} = Books.create_book!(%{title: "some title", author_list: ["some author"]})
    {:ok, %{id: user_id}} = Users.create_user(%{email: "finn@finn.com",
                                first_name: "Finn",
                                is_admin: false,
                                orgs: ["dwyl"],
                                username: "finnhodgkin"})

                                Books.checkout_book(id, user_id)

    assigns = Map.put(conn.assigns, :user, %{id: user_id})

    conn = conn
    |> Map.put(:assigns, assigns)
    |> get("/checkin/#{id}")
    assert html_response(conn, 302) =~ "redirected"
  end

  test "GET /checkin/:id can't check in a book if it's not checked out", %{conn: conn} do
    %{id: id} = Books.create_book!(%{title: "some title", author_list: ["some author"]})
    {:ok, %{id: user_id}} = Users.create_user(%{email: "finn@finn.com",
                                first_name: "Finn",
                                is_admin: false,
                                orgs: ["dwyl"],
                                username: "finnhodgkin"})

    assigns = Map.put(conn.assigns, :user, %{id: user_id})

    conn = conn
    |> Map.put(:assigns, assigns)
    |> get("/checkin/#{id}")
    assert html_response(conn, 302) =~ "redirected"
  end
end
