defmodule Library.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :first_name, :string
      add :email, :string
      add :orgs, {:array, :string}
      add :is_admin, :string

      timestamps()
    end

  end
end
