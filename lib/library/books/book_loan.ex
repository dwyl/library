defmodule Library.Books.BookLoan do
  use Ecto.Schema
  import Ecto.Changeset
  alias Library.Books.BookLoan


  schema "book_loans" do
    field :queue, {:array, :integer}
    belongs_to :user, Library.Users.User
    belongs_to :book, Library.Books.Book

    timestamps()
  end

  @doc false
  def changeset(%BookLoan{} = book_loan, attrs) do
    book_loan
    |> cast(attrs, [:queue, :book_id, :user_id])
    |> validate_required([:book_id, :user_id])
  end
end
