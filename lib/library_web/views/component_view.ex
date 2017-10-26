defmodule LibraryWeb.ComponentView do
  use LibraryWeb, :view

  defp force_map_from_struct(struct) do
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

  def get_large_thumbnail(book, conn) do
    Map.get(book, :thumbnail) || static_path(conn, "/images/null-image.png")
  end

  def list_book_props(book) do
    potential_props = [:author_list, :date_published, :isbn_10,
                       :isbn_13, :category, :language, :type]
    Enum.reduce(potential_props, [], reduce_values(book))
  end

  defp reduce_values(book) do
    fn prop, acc ->
      case prop do
        :author_list ->
          value = Map.get(book, prop)
          list? = is_list(value)
          plurality = list? && Enum.count(value) > 1 && "Authors" || "Author"
          authors =
            case list? do
              false -> String.replace(value, ";", ", ")
              true -> Enum.join(value, ", ")
            end
          acc ++ [[plurality, authors]]
        _ ->
          case Map.get(book, prop) do
            nil ->
              acc
            value ->
              prop = prop
              |> Atom.to_string
              |> String.capitalize
              |> String.replace("_", " ")

              acc ++ [[prop, String.downcase(value)]]
          end
      end
    end
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

  def on_loan(book) do
    book
     |> Map.get(:book_loan)
     |> (fn book_loan ->
          book_loan && Enum.find(book_loan, fn loan ->
            loan.checked_in == nil
          end) || nil
        end).()
  end

  def get_button_text(book, conn) do
    user = get_user(conn)
    admin = admin?(user)
    web = Map.get(book, :web)
    request = Map.get(book, :request)
    owned = Map.get(book, :owned) && Map.get(book, :owned) != "false"
    loan = on_loan(book)

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
    inactive = "f6 w-100 tc link pv1 mb2 dib moon-gray bg-light-grey"

    case get_button_text(book, conn) do
      "Login" ->
        [to: login_path(conn, :login), class: active]
      "Add book" ->
        [to: admin_path(conn, :create) <> "?" <> create_query_string(book),
        class: active,
        method: :post]
      "Join queue" ->
        [to: "#", class: inactive]
      "Check in" ->
        [to: page_path(conn, :checkin, Map.get(book, :id)), class: active]
      "Check out" ->
        [to: page_path(conn, :checkout, Map.get(book, :id)), class: active]
      "Remove" ->
        [to: admin_path(conn, :delete, book.id), class: active]
      "Request" ->
        [to: "#", class: inactive]
      "Requested" ->
        [to: "#", class: inactive]
      "n/a" ->
        [to: "#", class: inactive]
    end
  end

  def loan_html(book, conn) do
    valid = "dwyl-teal"
    invalid = "dwyl-red"
    user = get_user(conn)

    case on_loan(book) do
      nil ->
        Map.get(book, :web) && {invalid, "Not in the dwyl library"} ||
          {valid, "In the dwyl library"}
      loan ->
        name = "#{loan.user.first_name} (#{loan.user.username})"
        user && loan.user_id == user.id && {valid, "Book on loan to you"} ||
          {invalid, "Currently on loan to #{name}"}
    end
  end
end
