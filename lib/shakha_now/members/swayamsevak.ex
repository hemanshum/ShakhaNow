defmodule ShakhaNow.Members.Swayamsevak do
  use Ecto.Schema
  import Ecto.Changeset

  schema "swayamsevaks" do
    field :full_name, :string
    field :mobile_number, :string
    field :whatsapp_number, :string
    field :date_of_birth, :date
    field :photo_path, :string
    field :area, :string
    field :city, :string
    field :pincode, :string
    field :occupation, :string
    field :education, :string
    field :user_id, :id
    has_many :shakhas_as_mukhya_shikshak, ShakhaNow.Organizations.Shakha, foreign_key: :mukhya_shikshak_id
    has_many :shakhas_as_karyavah, ShakhaNow.Organizations.Shakha, foreign_key: :karyavah_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(swayamsevak, attrs, user_scope) do
    swayamsevak
    |> cast(attrs, [:full_name, :mobile_number, :whatsapp_number, :date_of_birth, :photo_path, :area, :city, :pincode, :occupation, :education])
    |> validate_required([:full_name, :mobile_number])
    |> validate_format(:mobile_number, ~r/^[0-9]+$/, message: "must contain only numbers")
    |> validate_format(:whatsapp_number, ~r/^[0-9]+$/, message: "must contain only numbers")
    |> validate_format(:pincode, ~r/^[0-9]+$/, message: "must contain only numbers")
    |> unique_constraint(:mobile_number)
    |> put_change(:user_id, user_scope.user.id)
  end
end
