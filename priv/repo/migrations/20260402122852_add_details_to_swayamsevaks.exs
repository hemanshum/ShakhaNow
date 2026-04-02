defmodule ShakhaNow.Repo.Migrations.AddDetailsToSwayamsevaks do
  use Ecto.Migration

  def change do
    alter table(:swayamsevaks) do
      add :email, :string, null: false, default: ""
      add :shakha_id, references(:shakhas, on_delete: :nilify_all)
      add :role, :string, default: "Swayamsevak"
      add :attendance_type, :string
    end
    
    # We create a unique index for email within the scope
    create unique_index(:swayamsevaks, [:email, :user_id])
  end
end
