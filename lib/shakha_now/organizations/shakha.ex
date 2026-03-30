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

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shakha, attrs, user_scope) do
    shakha
    |> cast(attrs, [:name, :area, :city, :pincode, :latitude, :longitude, :schedule_type, :meeting_time])
    |> validate_required([:name, :area, :city, :pincode, :latitude, :longitude, :schedule_type, :meeting_time])
    |> put_change(:user_id, user_scope.user.id)
  end
end
