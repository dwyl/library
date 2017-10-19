defmodule LibraryWeb.PageView do
  use LibraryWeb, :view

  def results_text(assigns) do
    case Map.get(assigns, :web) do
      false ->
        "In the dwyl library"
      "web" ->
        "Results from the web"
      _ ->
        "No results found, showing results from the web"
    end
  end

  def search_the_web_url(conn) do
    web = Map.get(conn.query_params, :web) || "&web=true"

    page_path(conn, :search) <>
    "?" <>
    conn.query_string <>
    web
  end
end
