defmodule LibraryWeb.ComponentView do
  use LibraryWeb, :view

  def force_map_from_struct(struct) do
    Map.has_key?(struct, :__struct__) && Map.from_struct(struct) || struct
  end

  def create_query_string(book) do
    book
    |> force_map_from_struct()
    |> Map.to_list()
    |> Enum.map(fn {key, value} ->
      if is_list(value) do
        {key, Enum.join(value, ";")}
      else
        {key, value}
      end
    end)
    |> Enum.into(%{})
    |> Map.delete(:author)
    |> Map.delete(:__meta__)
    |> URI.encode_query()
  end

  def get_thumbnail(book, conn) do
    Map.get(book, :thumbnail_small) || static_path(conn, "/images/null-image.png")
  end
end
