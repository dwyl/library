defmodule Library.Repo.Migrations.AddCheckinDate do
  use Ecto.Migration

  def change do
    alter table(:book_loans) do
      add :checked_in, :naive_datetime
      remove :queue
    end
  end
end
