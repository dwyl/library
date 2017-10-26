defmodule LibraryWeb.AdminController do
  use LibraryWeb, :controller

  alias Library.Books

  plug LibraryWeb.Plugs.RequireAdmin

  def create(conn, %{"author_list" => authors} = params) do
      params
      |> Map.put("author_list", String.split(authors, ";"))
      |> Map.put("owned", true)
      |> Library.Books.create_book_authors_return_book!
      |> case do
        {:ok, book} ->
          conn
          |> put_flash(:info, "Book added")
          |> redirect(to: page_path(conn, :show, book.id))
      end

  end

  def delete(conn, %{"id" => id}) do

    Books.get_book!(id)
    |> Books.delete_book_and_unique_authors

    redirect(conn, to: page_path(conn, :index))
  end
end
