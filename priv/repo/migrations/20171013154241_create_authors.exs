defmodule Library.Repo.Migrations.CreateAuthors do
  use Ecto.Migration

  def change do
    create table(:authors) do
      add :author, :string

      timestamps()
    end

  end
end
