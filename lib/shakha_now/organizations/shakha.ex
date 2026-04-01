defmodule ShakhaNow.Organizations.Shakha do
  use Ecto.Schema
  import Ecto.Changeset

  schema "shakhas" do
    field :name, :string
    field :area, :string
    field :city, :string
    field :pincode, :string
    field :latitude, :float
    field :longitude, :float
    field :schedule_type, :string
    field :meeting_time, :time
    field :user_id, :id
    belongs_to :mukhya_shikshak, ShakhaNow.Members.Swayamsevak
    belongs_to :karyavah, ShakhaNow.Members.Swayamsevak

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shakha, attrs, user_scope) do
    shakha
    |> cast(attrs, [:name, :area, :city, :pincode, :latitude, :longitude, :schedule_type, :meeting_time, :mukhya_shikshak_id, :karyavah_id])
    |> validate_required([:name, :area, :city, :pincode, :latitude, :longitude, :schedule_type, :meeting_time])
    |> put_change(:user_id, user_scope.user.id)
    |> validate_different_roles()
  end

  defp validate_different_roles(changeset) do
    mukhya_shikshak_id = get_field(changeset, :mukhya_shikshak_id)
    karyavah_id = get_field(changeset, :karyavah_id)

    if mukhya_shikshak_id != nil and karyavah_id != nil and mukhya_shikshak_id == karyavah_id do
      add_error(changeset, :karyavah_id, "cannot be the same as Mukhya Shikshak")
    else
      changeset
    end
  end
end
