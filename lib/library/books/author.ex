defmodule Library.Books.Author do
  use Ecto.Schema
  import Ecto.Changeset
  alias Library.Books.Author

  schema "authors" do
    field :author, :string
    many_to_many :book, Library.Books.Book, join_through: "author_books"

    timestamps()
  end

  @doc false
  def changeset(%Author{} = author, attrs) do
    author
    |> cast(attrs, [:author])
    |> validate_required([:author])
  end
end
