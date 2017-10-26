defmodule Library.Repo.Migrations.AddCheckinDate do
  use Ecto.Migration

  def up do
    alter table(:book_loans) do
      add :checked_in, :naive_datetime
      remove :queue
    end
  end

  def down do
    alter table(:book_loans) do
      remove :checked_in, :naive_datetime
      add :queue
    end
  end
end
