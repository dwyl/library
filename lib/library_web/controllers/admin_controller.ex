defmodule LibraryWeb.AdminController do
  use LibraryWeb, :controller

  alias Library.GoogleBooks

  def index(conn, _params) do
    render(conn, "index.html", books: [])
  end

  def search(conn, %{"search" => %{"query" => query}}) do
    books = GoogleBooks.google_books_search(query, "title")

    render(conn, "index.html", books: books)
  end

  def create(conn, %{"author_list" => authors} = params) do
      params
      |> Map.put("author_list", String.split(authors, ";"))
      |> Map.put("owned", true)
      |> Library.Books.create_book_authors!
      |> case do
        false ->
          conn
          |> put_flash(:info, "Book not added, already in library")
        _ ->
          conn
          |> put_flash(:info, "Book added")
      end
      |> render("index.html", books: [])

  end
end
