defmodule Library.Books.Request do
  use Ecto.Schema
  import Ecto.Changeset
  alias Library.Books.Request


  schema "requests" do
    belongs_to :user, Library.Users.User
    belongs_to :book, Library.Books.Book

    timestamps()
  end

  @doc false
  def changeset(%Request{} = request, attrs) do
    request
    |> cast(attrs, [:user_id, :book_id])
    |> validate_required([:user_id, :book_id])
  end
end
