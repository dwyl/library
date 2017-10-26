defmodule LibraryWeb.AdminController do
  use LibraryWeb, :controller

  import Library.Books
  alias Library.GoogleBooks
  alias Library.Books

  plug LibraryWeb.Plugs.RequireAdmin

  def index(conn, _params) do
    books = list_books()

    render(conn, "index.html", books: books, web: false)
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

  def delete(conn, %{"id" => id}) do

    Books.get_book!(id)
    |> Books.delete_book_and_unique_authors

    render(conn, "index.html", books: [])
  end
end
