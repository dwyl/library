defmodule Library.Repo.Migrations.CreateBookLoans do
  use Ecto.Migration

  def change do
    create table(:book_loans) do
      add :queue, {:array, :integer}
      add :book_id, references(:books, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:book_loans, [:book_id])
    create index(:book_loans, [:user_id])
  end
end
