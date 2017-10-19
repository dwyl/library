defmodule LibraryWeb.PageController do
  use LibraryWeb, :controller
  import Library.Books
  alias Library.GoogleBooks

  def index(conn, _params) do
    books = list_books()

    render conn, "index.html", books: books, web: false
  end

  def search(conn, %{"search" => %{"author" => _author, "isbn" => _isbn, "title" => title}, "web" => _web}) do
    books = GoogleBooks.google_books_search(title, "title")

    render(conn, "index.html", books: books, web: "web")
  end

  def search(conn, %{"search" => %{"author" => author, "isbn" => isbn, "title" => title}}) do
    {web, books} =
      search_books(author, isbn, title)
      |> case do
        [] ->
          {true, GoogleBooks.google_books_search(title, "title")}
        results ->
          {false, results}
      end

    render(conn, "index.html", books: books, web: web)
  end
end
