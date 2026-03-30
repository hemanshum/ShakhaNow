defmodule ShakhaNow.Repo.Migrations.CreateShakhas do
  use Ecto.Migration

  def change do
    create table(:shakhas) do
      add :name, :string
      add :area, :string
      add :city, :string
      add :pincode, :string
      add :latitude, :float
      add :longitude, :float
      add :schedule_type, :string
      add :meeting_time, :time
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:shakhas, [:user_id])
  end
end
