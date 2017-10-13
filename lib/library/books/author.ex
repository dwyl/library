defmodule Library.Books.Author do
  use Ecto.Schema
  import Ecto.Changeset
  alias Library.Books.Author


  schema "authors" do
    field :author, :string

    timestamps()
  end

  @doc false
  def changeset(%Author{} = author, attrs) do
    author
    |> cast(attrs, [:author])
    |> validate_required([:author])
  end
end
