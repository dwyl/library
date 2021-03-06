defmodule LibraryWeb.PageController do
  use LibraryWeb, :controller
  import Library.Books
  alias Library.GoogleBooks

  plug LibraryWeb.Plugs.RequireAuth when action in [:checkout, :checkin]

  def index(conn, _params) do
    books = list_books()

    render(conn, "index.html", books: books, web: false)
  end

  def search(conn, %{"search" => %{"author" => author, "isbn" => isbn, "title" => title}, "web" => _web}) do
    books = GoogleBooks.google_books_search(title, author, isbn)
    |> replace_matches_with_db()

    render(conn, "index.html", books: books, web: "web")
  end

  def search(conn, %{"search" => %{"author" => author, "isbn" => isbn, "title" => title}}) do
    {web, books} =
      search_books(author, isbn, title)
      |> case do
        [] ->
          {true, GoogleBooks.google_books_search(title, author, isbn)}
        results ->
          {false, results}
      end

    render(conn, "index.html", books: books, web: web)
  end

  def show(conn, %{"id" => id} = _params) do
    render(conn, "show.html", book: get_preloaded_book!(id), web: false)
  end

  def show_web(conn, book) do
    book = swap_to_atom_keys(book)

    render(conn, "show.html", book: book, web: "web")
  end

  defp swap_to_atom_keys(map) do
    for {key, val} <- map, into: %{}, do: {String.to_atom(key), val}
  end

  def checkout(conn, %{"id" => id} = _params) do
    case checkout_book(id, conn.assigns.user.id) do
      {:ok, _book_loan} ->
        conn
        |> put_flash(:info, "Book checked out.")
      _ ->
        conn
        |> put_flash(:error, "Error checking book out.")
    end
    |> redirect(to: page_path(conn, :show, id))
  end

  def checkin(conn, %{"id" => id} = _params) do
    case checkin_book(id, conn.assigns.user.id) do
      {:ok, _book_loan} ->
        conn
        |> put_flash(:info, "Book checked in.")
      _ ->
        conn
        |> put_flash(:error, "Error checking book in.")
    end
    |> redirect(to: page_path(conn, :show, id))
  end
end
