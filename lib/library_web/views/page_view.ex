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
end
