defmodule Library.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :title, :string
      add :authors, {:array, :string}
      add :date_published, :string
      add :isbn_13, :string
      add :isbn_10, :string
      add :type, :string
      add :category, :string
      add :thumbnail_small, :string
      add :thumbnail, :string
      add :preview_link, :string
      add :language, :string
      add :owned, :boolean, default: false, null: false

      timestamps()
    end

  end
end
