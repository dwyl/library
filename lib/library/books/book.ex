defmodule Library.Books.Book do
  use Ecto.Schema
  import Ecto.Changeset
  alias Library.Books.Book

  schema "books" do
    field :author_list, {:array, :string}
    field :category, :string
    field :date_published, :string
    field :isbn_10, :string
    field :isbn_13, :string
    field :language, :string
    field :owned, :boolean, default: false
    field :preview_link, :string
    field :thumbnail, :string
    field :thumbnail_small, :string
    field :title, :string
    field :type, :string
    many_to_many :author, Library.Books.Author, join_through: "author_books"

    timestamps()
  end

  @doc false
  def changeset(%Book{} = book, attrs) do
    book
    |> cast(attrs, [:title, :author_list, :date_published, :isbn_13, :isbn_10, :type, :category, :thumbnail_small, :thumbnail, :preview_link, :language, :owned])
    |> validate_required([:title, :author_list, :owned])
  end
end
