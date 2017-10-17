defmodule Library.GoogleBooks do
  @book_api_url "https://www.googleapis.com/books/v1/volumes?key=#{System.get_env "GOOGLE_BOOKS_KEY"}&q="
  @desired_info ["title", "authors", "publishedDate", "printType", "categories", ["imageLinks", "thumbnail"], ["imageLinks", "smallThumbnail"], "language", "previewLink", "industryIdentifiers"]
  @keys_to_rename [{"title", :title}, {"authors", :author_list},
                   {"publishedDate", :date_published}, {"printType", :type},
                   {"categories", :category}, {"thumbnail", :thumbnail},
                   {"smallThumbnail", :thumbnail_small},
                   {"language", :language}, {"previewLink", :preview_link},
                   {"ISBN_13", :isbn_10}, {"ISBN_10", :isbn_13}]
  @httpoison Application.get_env(:library, :httpoison) || HTTPoison

  @doc """
    Takes a search term and a category for the search, and makes a call to
    the google books API, returning the relevant results
  """
  def google_books_search(search_query, search_category) do
      search_query
      |> create_url(search_category)
      |> @httpoison.get
      |> handle_google_api_response
  end

  @doc """

  """
  defp handle_google_api_response(result) do
    case result do
      {:ok, result} ->
        result
        |> Map.get(:body)
        |> Poison.decode
        |> handle_api_decode
      {:error, _error} = error ->
        error
    end
  end

  def handle_api_decode(result) do
    case result do
      {:ok, map} ->
        Map.get(map, "items")
        |> Enum.reduce([], fn (%{"volumeInfo" => map}, acc) ->
          map
          |> get_values_from_map(@desired_info)
          |> get_isbns
          |> rename_keys(@keys_to_rename)
          |> Map.put(:owned, false)
          |> validate_required
          |> case do
            {:ok, map} ->
              acc ++ [map]
            {:error, error} ->
              acc
          end
        end)
      {:error, error} ->
        error # TODO: do something proper with this error
    end
  end

  defp validate_required(%{title: _title,
                          author_list: _authors,
                          owned: _owned} = map), do: {:ok, map}
  defp validate_required(map), do: {:error, "Missing valid property"}

  defp get_isbns(%{"industryIdentifiers" => identifiers} = map) do
    Enum.reduce(identifiers, %{}, fn %{"identifier" => isbn, "type" => type}, acc ->
      Map.put(acc, type, isbn)
    end)
    |> Map.merge(map)
    |> Map.delete("industryIdentifiers")
  end

  defp get_isbns(map), do: map

  def create_url(search_query, search_category) do
    query = URI.encode(search_query)
    @book_api_url <> case search_category do
      "title" ->
        "intitle:" <> query
      "isbn" ->
        "isbn:" <> query
      "author" ->
        "inauthor:" <> query
      _ ->
        ""
    end
  end

  def get_values_from_map(map_to_decode, list_of_keys) do
    preloaded = fn key -> get_if_value key, map_to_decode end

    Enum.map(list_of_keys, preloaded)
    |> Enum.reduce(%{}, fn x, acc -> Map.merge x, acc end)
  end

  def get_if_value(key, map, map_to_return \\ %{})

  def get_if_value([final_key] = key, map, map_to_return) when is_list(key) and length(key) == 1 do
    case Map.get(map, final_key) do
      nil ->
        map_to_return
      value ->
        Map.put(map_to_return, final_key, value)
    end
  end

  def get_if_value([head | tail], map, map_to_return) do
    case Map.get(map, head) do
      nil ->
        map_to_return
      value ->
        get_if_value(tail, value, map_to_return)
    end
  end

  def get_if_value(string, map, map_to_return) do
    case Map.get(map, string) do
      nil ->
        map_to_return
      value ->
        Map.put(map_to_return, string, value)
    end
  end

  def rename_keys(map, list) do
    list
    |> Enum.reduce(%{}, fn {old, new}, acc ->
      case Map.get(map, old) do
        nil ->
          acc
        value ->
          Map.put(acc, new, value)
      end
    end)
  end

end
