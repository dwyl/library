defmodule Library.Repo.Migrations.CreateBookQueue do
  use Ecto.Migration

  def change do
    create table(:book_queue) do
      add :book_id, references(:books, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:book_queue, [:book_id])
    create index(:book_queue, [:user_id])
  end
end
