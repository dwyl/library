defmodule Library.Repo.Migrations.CreateAuthors do
  use Ecto.Migration

  def change do
    create table(:authors) do
      add :author, :string, null: false

      timestamps()
    end

  end
end
