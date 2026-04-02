defmodule ShakhaNow.Members.Swayamsevak do
  use Ecto.Schema
  import Ecto.Changeset

  schema "swayamsevaks" do
    field :full_name, :string
    field :email, :string
    field :mobile_number, :string
    field :whatsapp_number, :string
    field :date_of_birth, :date
    field :photo_path, :string
    field :area, :string
    field :city, :string
    field :pincode, :string
    field :occupation, :string
    field :education, :string
    field :role, :string, default: "Swayamsevak"
    field :attendance_type, :string
    field :user_id, :id
    
    belongs_to :shakha, ShakhaNow.Organizations.Shakha
    has_many :shakhas_as_mukhya_shikshak, ShakhaNow.Organizations.Shakha, foreign_key: :mukhya_shikshak_id
    has_many :shakhas_as_karyavah, ShakhaNow.Organizations.Shakha, foreign_key: :karyavah_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(swayamsevak, attrs, user_scope) do
    swayamsevak
    |> cast(attrs, [:full_name, :email, :mobile_number, :whatsapp_number, :date_of_birth, :photo_path, :area, :city, :pincode, :occupation, :education, :role, :attendance_type, :shakha_id])
    |> validate_required([:full_name, :email, :mobile_number])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_format(:mobile_number, ~r/^[0-9]+$/, message: "must contain only numbers")
    |> validate_format(:whatsapp_number, ~r/^[0-9]+$/, message: "must contain only numbers")
    |> validate_format(:pincode, ~r/^[0-9]+$/, message: "must contain only numbers")
    |> validate_inclusion(:role, ["MukhyaShishak", "Karyavha", "Gatnayak", "Swayamsevak"])
    |> validate_inclusion(:attendance_type, ["Daily", "Weekends", nil, ""])
    |> unique_constraint([:email, :user_id], name: :swayamsevaks_email_user_id_index)
    |> unique_constraint(:mobile_number)
    |> put_change(:user_id, user_scope.user.id)
  end
end
