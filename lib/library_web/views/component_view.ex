defmodule LibraryWeb.ComponentView do
  use LibraryWeb, :view

  def create_query_string(book) do
    book
    |> Map.put(:author_list, Enum.join(book.author_list, ";"))
    |> Map.delete(:category)
    |> URI.encode_query()
  end

  def get_thumbnail(book, conn) do
    Map.get(book, :thumbnail_small) || static_path(conn, "/images/null-image.png")
  end

  def admin?(conn) do
    case get_user(conn) do
      nil -> nil
      user -> Map.get(user, :is_admin)
    end
  end

  def get_user(conn) do
    Map.get(conn.assigns, :user)
    %{id: 1, is_admin: 1}
  end

  def get_button_text(book, conn) do
    user = get_user(conn)
    admin = admin?(conn)
    web = Map.get(book, :web)
    request = Map.get(book, :request)
    owned = Map.get(book, :owned)
    loan = Map.get(book, :book_loan)

    cond do
      !user ->
        "Login"
      loan && user && (user.id == loan.id || admin) ->
        "Check in"
      loan ->
        "Join queue"
      owned ->
        "Check out"
      owned && admin ->
        "Remove"
      !owned && web && admin ->
        "Add book"
      web && request && Enum.count(request) == 0 ->
        "Request"
      web && request && Enum.count(request) > 0 ->
        "Requested"
      true ->
        "n/a"
    end
  end

  def get_button_options(book, conn) do
    active = "f6 w-100 tc link dim pv1 mb2 dib white bg-dwyl-teal"

    case get_button_text(book, conn) do
      "Login" ->
        [to: "testing", class: active]
      "Add book" ->
        [to: admin_path(conn, :create) <> "?" <> create_query_string(book),
        class: active,
        method: :post]
      "Check in" ->
        [to: "testing", class: active]
      "Check out" ->
        [to: "testing", class: active]
      "Remove" ->
        [to: "testing", class: active]
      "Request" ->
        [to: "testing", class: active]
      "Requested" ->
        [to: "testing", class: active]
      "n/a" ->
        [to: "testing", class: active]
    end
  end
end
