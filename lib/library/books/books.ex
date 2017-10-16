defmodule Library.Books do
  @moduledoc """
  The Books context.
  """

  import Ecto.Query, warn: false
  alias Library.Repo

  alias Library.Books.Book
  alias Library.Books.Author

  @doc """
  Returns the list of books.

  ## Examples

      iex> list_books()
      [%Book{}, ...]

  """
  def list_books do
    Repo.all(Book)
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
  def get_book!(id), do: Repo.get!(Book, id)

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
    Repo.transaction fn ->
      attrs
      |> create_book!()
      |> Repo.preload(:author)
      |> create_authors_for_book!()
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
  alias Library.Books.Author

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

  alias Library.Books.Request

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
  def create_request(attrs \\ %{}) do
    %Request{}
    |> Request.changeset(attrs)
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
end
