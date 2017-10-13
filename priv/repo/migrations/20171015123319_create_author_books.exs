defmodule Library.Repo.Migrations.CreateAuthorBooks do
  use Ecto.Migration

  def change do
    create table(:author_books, primary_key: false) do
      add :book_id, references(:books, on_delete: :delete_all)
      add :author_id, references(:authors, on_delete: :delete_all)
    end
  end
end
