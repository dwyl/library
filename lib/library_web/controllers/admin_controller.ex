defmodule LibraryWeb.AdminController do
  use LibraryWeb, :controller

  alias Library.GoogleBooks

  def index(conn, _params) do
    render conn, "index.html", books: []
  end

  def search(conn, %{"search" => %{"query" => query}}) do
    books = GoogleBooks.google_books_search(query, "title")

    render(conn, "index.html", books: books)
  end
end
