defmodule Library.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Library.Users.User


  schema "users" do
    field :email, :string
    field :first_name, :string
    field :is_admin, :string
    field :orgs, {:array, :string}
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :first_name, :email, :orgs, :is_admin])
    |> validate_required([:username, :first_name, :email, :orgs, :is_admin])
  end
end
