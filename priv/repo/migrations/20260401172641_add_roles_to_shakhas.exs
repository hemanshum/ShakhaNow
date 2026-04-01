defmodule ShakhaNow.Repo.Migrations.AddRolesToShakhas do
  use Ecto.Migration

  def change do
    alter table(:shakhas) do
      add :mukhya_shikshak_id, references(:swayamsevaks, on_delete: :nothing)
      add :karyavah_id, references(:swayamsevaks, on_delete: :nothing)
    end

    create index(:shakhas, [:mukhya_shikshak_id])
    create index(:shakhas, [:karyavah_id])
  end
end
