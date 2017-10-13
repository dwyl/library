defmodule Library.Books.Request do
  use Ecto.Schema
  import Ecto.Changeset
  alias Library.Books.Request


  schema "requests" do
    field :book_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Request{} = request, attrs) do
    request
    |> cast(attrs, [])
    |> validate_required([])
  end
end
