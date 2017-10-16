defmodule Library.Books.BookLoan do
  use Ecto.Schema
  import Ecto.Changeset
  alias Library.Books.BookLoan


  schema "book_loans" do
    field :queue, {:array, :integer}
    field :book_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(%BookLoan{} = book_loan, attrs) do
    book_loan
    |> cast(attrs, [:queue])
    |> validate_required([:queue])
  end
end
