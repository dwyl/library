defmodule Library.Books.BookQueue do
  use Ecto.Schema
  import Ecto.Changeset
  alias Library.Books.BookQueue


  schema "book_queue" do
    belongs_to :user, Library.Users.User
    belongs_to :book, Library.Books.Book

    timestamps()
  end

  @doc false
  def changeset(%BookQueue{} = book_queue, attrs) do
    book_queue
    |> cast(attrs, [:book_id, :user_id])
    |> validate_required([:book_id, :user_id])
  end
end
