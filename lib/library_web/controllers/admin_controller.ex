defmodule LibraryWeb.AdminController do
  use LibraryWeb, :controller

  import Library.Books

  plug LibraryWeb.Plugs.RequireAdmin

  def create(conn, %{"author_list" => authors} = params) do
      book = params
      |> Map.put("author_list", String.split(authors, ";"))
      |> Map.put("owned", true)
      |> create_book_authors_return_book!

      conn
      |> put_flash(:info, "Book added")
      |> redirect(to: page_path(conn, :show, book.id))
  end

  def delete(conn, %{"id" => id}) do

    get_book!(id)
    |> delete_book_and_unique_authors

    redirect(conn, to: page_path(conn, :index))
  end
end
