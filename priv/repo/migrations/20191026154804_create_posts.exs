defmodule Chubi.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :text, null: false
      add :slug, :text
      add :excerpt, :text
      add :content, :text, null: false
      add :format, :string, default: "html"
      add :draft, :boolean, default: true, null: false
      add :date, :utc_datetime

      timestamps()
    end
    create unique_index(:posts, [:slug])
  end
end
