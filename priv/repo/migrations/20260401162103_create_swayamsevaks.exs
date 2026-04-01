defmodule ShakhaNow.Repo.Migrations.CreateSwayamsevaks do
  use Ecto.Migration

  def change do
    create table(:swayamsevaks) do
      add :full_name, :string
      add :mobile_number, :string
      add :whatsapp_number, :string
      add :date_of_birth, :date
      add :photo_path, :string
      add :area, :string
      add :city, :string
      add :pincode, :string
      add :occupation, :string
      add :education, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:swayamsevaks, [:user_id])
    create unique_index(:swayamsevaks, [:mobile_number])
  end
end
