defmodule Library.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Library.Users.User


  schema "users" do
    field :email, :string
    field :first_name, :string
    field :is_admin, :boolean
    field :orgs, {:array, :string}
    field :username, :string
    has_many :book_loan, Library.Books.BookLoan
    has_many :request, Library.Books.Request
    has_many :book_queue, Library.Books.BookQueue
    

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :first_name, :email, :orgs, :is_admin])
    |> validate_required([:username, :first_name, :email, :orgs])
  end
end
