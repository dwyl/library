defmodule LibraryWeb.ComponentView do
  use LibraryWeb, :view

  def create_query_string(book) do
    book
    |> Map.put(:author_list, Enum.join(book.author_list, ";"))
    |> Map.delete(:category)
    |> URI.encode_query()
  end
  
end
