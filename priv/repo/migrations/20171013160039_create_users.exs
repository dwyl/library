defmodule Library.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
      add :first_name, :string, null: false
      add :email, :string, null: false
      add :orgs, {:array, :string}, null: false
      add :is_admin, :boolean

      timestamps()
    end

  end
end
