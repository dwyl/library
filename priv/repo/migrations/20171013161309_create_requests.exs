defmodule Library.Repo.Migrations.CreateRequests do
  use Ecto.Migration

  def change do
    create table(:requests) do
      add :book_id, references(:books, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:requests, [:book_id])
    create index(:requests, [:user_id])
  end
end
