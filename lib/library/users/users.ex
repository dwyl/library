defmodule Library.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Library.Repo

  alias Library.Users.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user.

  Returns {:ok, %User{}} if user does exist, and {:error, "user does not exist"}
  if they do not.

  """
  def get_user(id), do: Repo.get(User, id)


  @doc """
    Gets a single user from the database by username.

    ## Examples
    iex>get_user_by_username "username that exists in db"
    %User{}
    iex>get_user_by_username "username that doesn't exist in db"
    nil
  """
  def get_user_by_username(username) do
    Repo.get_by(User, username: username)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
  @doc """
    Checks by username if the user is in the database, and updates them if they
    are, and inserts them if not.

    ## Examples

        iex> insert_or_update_user(user_info)
        {:ok, %User{}}

        iex> insert_or_update_user(invalid_user_info)
        {:error, %Ecto.Changeset{}}
  """
  def insert_or_update_user(%{username: username} = user) do
    case Library.Users.get_user_by_username(username) do
      nil ->
        Library.Users.create_user(user)
      old_user ->
        Library.Users.update_user(old_user, user)
    end
  end
end
