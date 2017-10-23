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

  def admin?(user) do
    case user do
      nil -> nil
      user -> Map.get(user, :is_admin)
    end
  end

  def get_user(conn) do
    Map.get(conn.assigns, :user)
  end

  def get_button_text(book, conn) do
    user = get_user(conn)
    admin = admin?(user)
    web = Map.get(book, :web)
    request = Map.get(book, :request)
    owned = Map.get(book, :owned)
    loan = book
           |> Map.get(:book_loan)
           |> (fn book_loan ->
                book_loan && Enum.find(book_loan, fn loan -> loan.checked_in == nil end) || nil
              end).()

    cond do
      !user ->
        "Login"
      loan && user && (user.id == loan.user_id || admin) ->
        "Check in"
      loan ->
        "Join queue"
      owned && admin ->
        "Remove"
      owned ->
        "Check out"
      !owned && web && admin ->
        "Add book"
      web && request && Enum.count(request) > 0 ->
        "Requested"
      web ->
        "Request"
      true ->
        "n/a"
    end
  end

  def get_button_options(book, conn) do
    active = "f6 w-100 tc link dim pv1 mb2 dib white bg-dwyl-teal"
    inactive = "f6 w-100 tc link dim pv1 mb2 dib medium-grey bg-light-grey"

    case get_button_text(book, conn) do
      "Login" ->
        [to: "#", class: inactive]
      "Add book" ->
        [to: admin_path(conn, :create) <> "?" <> create_query_string(book),
        class: active,
        method: :post]
      "Join queue" ->
        [to: "#", class: inactive]
      "Check in" ->
        [to: page_path(conn, :checkin, book.id), class: active]
      "Check out" ->
        [to: page_path(conn, :checkout, book.id), class: active]
      "Remove" ->
        [to: "#", class: inactive]
      "Request" ->
        [to: "#", class: inactive]
      "Requested" ->
        [to: "#", class: inactive]
      "n/a" ->
        [to: "#", class: inactive]
    end
  end
end
