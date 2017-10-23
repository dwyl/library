defmodule Library.Books do
  @moduledoc """
  The Books context.
  """

  import Ecto.Query, warn: false
  alias Library.Repo

  alias Library.Books.{Book, Author, BookLoan, Request, BookQueue}
  alias Library.Users

  @doc """
  Check out a book by book id and user id.

  If the book is already on loan, return {:error, "Book already on loan."},
  otherwise return {:ok, book_loan}.
  """
  def checkout_book(book_id, user_id) do
    book = get_book!(book_id)
    user = Users.get_user!(user_id)

    if check_loaned?(book_id) do
      {:error, "Book already on loan."}
    else
      {:ok, create_book_loan!(book, user)}
    end
  end

  @doc """
  Check in a book by book id and user id.

  If the book is not on loan, return {:error, "Book not on loan."},
  otherwise return {:ok, book_loan}.
  """
  def checkin_book(book_id, user_id) do
    query = from bl in BookLoan,
            join: b in assoc(bl, :book),
            where: b.id == ^book_id,
            join: u in assoc(bl, :user),
            where: u.id == ^user_id,
            where: is_nil(bl.checked_in)

    case Repo.all(query) do
      [] ->
        {:error, "Book not on loan."}
      [book_loan | _tail] ->
        time = NaiveDateTime.utc_now()
        update_book_loan(book_loan, %{checked_in: time})
        {:ok, book_loan}
    end
  end

  @doc """
  Check to see if a book is on loan by book id.
  """
  def check_loaned?(book_id) do
    query = from bl in BookLoan,
            preload: [:book],
            join: b in assoc(bl, :book),
            where: b.id == ^book_id,
            where: is_nil(bl.checked_in)

    case Repo.all(query) do
      [_book_loan | _tail] ->
        true
      [] ->
        false
    end
  end

  @doc """
  Returns the list of books.

  ## Examples

      iex> list_books()
      [%Book{}, ...]

  """
  def list_books do
    query = from b in Book,
            preload: [:request, :book_loan, :book_queue]
    Repo.all(query)
  end

  @doc """
  Returns a list of books filtered by author and title or by exact isbn
  """
  def search_books(author, isbn, title) do
    query =
      unless (isbn == "") do
        from b in Book,
        where: b.isbn_13 == ^isbn,
        or_where: b.isbn_10 == ^isbn,
        or_where: ^isbn == ""
      else
        from b in Book,
        preload: [:request, :book_loan],
        where: ilike(b.title, ^"%#{title}%"),
        join: a in assoc(b, :author),
        where: ilike(a.author, ^"%#{author}%")
      end

    Repo.all(query)
  end



  @doc """
  Gets a single book.

  Raises `Ecto.NoResultsError` if the Book does not exist.

  ## Examples

      iex> get_book!(123)
      %Book{}

      iex> get_book!(456)
      ** (Ecto.NoResultsError)

  """
  def get_book!(id), do: Repo.get!(Book, id) |> Repo.preload(:book_loan)

  @doc """
  Gets a book using the title

  Gives nil if no book with that title exists

  ## Examples
  iex> get_book_by_title!("harry potter")
  %Book{}

  iex> get_book_by_title!("not a title")
  Error
"""
  def get_book_by_title!(title), do: Repo.get_by!(Book, title: title)

  @doc """
    Gets a book using the title and author_list

    Returns an empty list for no results

    ## Examples
    iex> get_book_by_title_and_authors("harry potter")
    [%Book{}]

    iex> get_book_by_title_and_authors("not a title")
    []
  """
  def get_books_by_title_and_authors(%{"title" => title, "author_list" => author_list}), do: get_books_by_title_and_authors(title, author_list)
  def get_books_by_title_and_authors(%{title: title, author_list: author_list}), do: get_books_by_title_and_authors(title, author_list)
  def get_books_by_title_and_authors(title, author_list) do
    query = from b in "books",
            where: b.title == ^title,
            where: b.author_list == ^author_list,
            select: b.title

    Repo.all(query)
  end

  def book_exists?(book), do: get_books_by_title_and_authors(book) != []

  @doc """
  Updates a book to be owned.

  ## Examples

      iex> get_book!(1)
      %Book{owned: false}
      iex> update_owned_by_id(1)
      %Book{owned: true}
  """
  def update_owned_by_id!(id) do
    {:ok, book} = get_book!(id)
    |> update_owned()

    book
  end
  defp update_owned(%{owned: owned} = book) do
    update_book(book, %{owned: !owned})
  end

  @doc """
  Add a book plus all authors.

  Inserts a book plus all authors contained in the `author_list` array.

  Runs all queries as a transaction, so if one insert goes fails all changes
  will roll back.
  """
  def create_book_authors!(attrs \\ %{}) do
    unless book_exists?(attrs) do
      Repo.transaction fn ->
        attrs
        |> create_book!()
        |> Repo.preload(:author)
        |> create_authors_for_book!()
      end
    else
      false
    end
  end

  @doc """
  Adds all the authors of a book to the authors table.

  Uses the `author_list` property to add all the authors of a book to the
  authors table. Also updates the associations in the `:author_books` join
  table.
  """
  def create_authors_for_book!(book) do
    Enum.each(book.author_list, fn name ->
      case get_author_by_name(name) do
        nil ->
          create_author!(%{author: name})
          |> update_assoc!(:book, book)
        author ->
          update_assoc!(book, :author, author)
      end
    end)
  end

  @doc """
  Get author by name.

  Returns the first `Author` by name or `nil` in cases with no results.
  """
  def get_author_by_name(name) do
    query = from p in Author,
            where: p.author == ^name

    case Repo.all(query) do
      [] -> nil
      [author | _] -> author
    end
  end

  @doc """
  Gets all books by exact author name.

  Takes a string name and returns all matching books.
  """
  def get_books_by_author(author) do
    %{id: id} = Repo.get_by!(Author, author: author)

    Author
    |> Repo.get!(id)
    |> Ecto.assoc(:book)
    |> Repo.all()
  end

  @doc """
  Removes a %Book{} from the database, as well as any authors that are unique to
  that book.
  """
  def delete_book_and_unique_authors(%{author_list: authors} = book) do
    Repo.transaction fn ->
      delete_book(book)
      delete_unique_author(authors)
    end
  end
  defp delete_unique_author([author | tail]) do
    author
    |> get_books_by_author
    |> Enum.count
    |> case do
      0 ->
        author
        |> get_author_by_name
        |> delete_author
      _ ->
        nil
    end
    delete_unique_author(tail)
  end
  defp delete_unique_author([]), do: :ok

  @doc """
  Creates a book.

  ## Examples

      iex> create_book!(%{field: value})
      %Book{}

  """
  def create_book!(attrs \\ %{}) do
    %Book{}
    |> Book.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Updates a book.

  ## Examples

      iex> update_book(book, %{field: new_value})
      {:ok, %Book{}}

      iex> update_book(book, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_book(%Book{} = book, attrs) do
    book
    |> Book.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Book.

  ## Examples

      iex> delete_book(book)
      {:ok, %Book{}}

      iex> delete_book(book)
      {:error, %Ecto.Changeset{}}

  """
  def delete_book(%Book{} = book) do
    Repo.delete(book)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book changes.

  ## Examples

      iex> change_book(book)
      %Ecto.Changeset{source: %Book{}}

  """
  def change_book(%Book{} = book) do
    Book.changeset(book, %{})
  end

  @doc """
  Updates the join table for two associated tables.

  Takes two associated schemas plus the atom name of the second and adds the IDs
  of both to a join table:

  ```elixir
  update_assoc!(users, user_comments, :user_comments)
  ```
  """
  def update_assoc!(origin, join, assoc) do
    origin
    |> Repo.preload(join)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(join, [assoc])
    |> Repo.update!()
  end

  @doc """
  Returns the list of authors.

  ## Examples

      iex> list_authors()
      [%Author{}, ...]

  """
  def list_authors do
    Repo.all(Author)
  end

  @doc """
  Gets a single author.

  Raises `Ecto.NoResultsError` if the Author does not exist.

  ## Examples

      iex> get_author!(123)
      %Author{}

      iex> get_author!(456)
      ** (Ecto.NoResultsError)

  """
  def get_author!(id), do: Repo.get!(Author, id)

  @doc """
  Creates a author.

  ## Examples

      iex> create_author(%{field: value})
      {:ok, %Author{}}

  """
  def create_author!(attrs \\ %{}) do
    %Author{}
    |> Author.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Updates a author.

  ## Examples

      iex> update_author(author, %{field: new_value})
      {:ok, %Author{}}

      iex> update_author(author, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_author(%Author{} = author, attrs) do
    author
    |> Author.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Author.

  ## Examples

      iex> delete_author(author)
      {:ok, %Author{}}

      iex> delete_author(author)
      {:error, %Ecto.Changeset{}}

  """
  def delete_author(%Author{} = author) do
    Repo.delete(author)
  end


  @doc """
  Returns the list of requests.

  ## Examples

      iex> list_requests()
      [%Request{}, ...]

  """
  def list_requests do
    Repo.all(Request)
  end

  @doc """
  Gets a single request.

  Raises `Ecto.NoResultsError` if the Request does not exist.

  ## Examples

      iex> get_request!(123)
      %Request{}

      iex> get_request!(456)
      ** (Ecto.NoResultsError)

  """
  def get_request!(id), do: Repo.get!(Request, id)

  @doc """
  Creates a request.

  ## Examples

      iex> create_request(%{field: value})
      {:ok, %Request{}}

      iex> create_request(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_request!(attrs \\ %{}, user, book) do
    user_assoc = Ecto.build_assoc(user, :request, attrs)
    user_assoc_two = Ecto.build_assoc(book, :request, user_assoc)
    %Request{}
    |> Request.changeset(Map.from_struct user_assoc_two)
    |> Repo.insert()
  end

  @doc """
  Updates a request.

  ## Examples

      iex> update_request(request, %{field: new_value})
      {:ok, %Request{}}

      iex> update_request(request, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_request(%Request{} = request, attrs) do
    request
    |> Request.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Request.

  ## Examples

      iex> delete_request(request)
      {:ok, %Request{}}

      iex> delete_request(request)
      {:error, %Ecto.Changeset{}}

  """
  def delete_request(%Request{} = request) do
    Repo.delete(request)
  end


  @doc """
  Returns the list of book_loans.

  ## Examples

      iex> list_book_loans()
      [%BookLoan{}, ...]

  """
  def list_book_loans do
    Repo.all(BookLoan)
  end

  @doc """
  Gets a single book_loan.

  Raises `Ecto.NoResultsError` if the Book loan does not exist.

  ## Examples

      iex> get_book_loan!(123)
      %BookLoan{}

      iex> get_book_loan!(456)
      ** (Ecto.NoResultsError)

  """
  def get_book_loan!(id), do: Repo.get!(BookLoan, id)

  @doc """
  Creates a book_loan.

  ## Examples

      iex> create_book_loan(%{field: value})
      {:ok, %BookLoan{}}

      iex> create_book_loan(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_book_loan!(attrs \\ %{}, user, book) do
    user_assoc = Ecto.build_assoc(user, :book_loan, attrs)
    user_assoc_two = Ecto.build_assoc(book, :book_loan, user_assoc)
    %BookLoan{}
    |> BookLoan.changeset(Map.from_struct user_assoc_two)
    |> Repo.insert()
  end

  @doc """
  Updates a book_loan.

  ## Examples

      iex> update_book_loan(book_loan, %{field: new_value})
      {:ok, %BookLoan{}}

      iex> update_book_loan(book_loan, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_book_loan(%BookLoan{} = book_loan, attrs) do
    book_loan
    |> BookLoan.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a BookLoan.

  ## Examples

      iex> delete_book_loan(book_loan)
      {:ok, %BookLoan{}}

      iex> delete_book_loan(book_loan)
      {:error, %Ecto.Changeset{}}

  """
  def delete_book_loan(%BookLoan{} = book_loan) do
    Repo.delete(book_loan)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book_loan changes.

  ## Examples

      iex> change_book_loan(book_loan)
      %Ecto.Changeset{source: %BookLoan{}}

  """
  def change_book_loan(%BookLoan{} = book_loan) do
    BookLoan.changeset(book_loan, %{})
  end


  @doc """
  Gets a single book_queue.

  Raises `Ecto.NoResultsError` if the Book queue does not exist.

  ## Examples

      iex> get_book_queue!(123)
      %BookQueue{}

      iex> get_book_queue!(456)
      ** (Ecto.NoResultsError)

  """
  def get_book_queue!(id), do: Repo.get!(BookQueue, id)

  @doc """
  Deletes a BookQueue.

  ## Examples

  iex> delete_book_queue(book_queue)
  {:ok, %BookQueue{}}

  iex> delete_book_queue(book_queue)
  {:error, %Ecto.Changeset{}}

  """
  def delete_book_queue(%BookQueue{} = book_queue) do
    Repo.delete(book_queue)
  end

  @doc """
  Creates a book_queue.

  ## Examples

  iex> create_book_queue(%{field: value})
  {:ok, %BookLoan{}}

  iex> create_book_queue(%{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def create_book_queue!(attrs \\ %{}, user, book) do
    user_assoc = Ecto.build_assoc(user, :book_queue, attrs)
    user_assoc_two = Ecto.build_assoc(book, :book_queue, user_assoc)
    %BookQueue{}
    |> BookQueue.changeset(Map.from_struct user_assoc_two)
    |> Repo.insert()
  end
end
