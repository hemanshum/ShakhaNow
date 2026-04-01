defmodule ShakhaNow.MembersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ShakhaNow.Members` context.
  """

  @doc """
  Generate a swayamsevak.
  """
  def swayamsevak_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        area: "some area",
        city: "some city",
        date_of_birth: ~D[2026-03-31],
        education: "some education",
        full_name: "some full_name",
        mobile_number: "9876543210" <> Integer.to_string(System.unique_integer([:positive])),
        occupation: "Student",
        photo_path: "some photo_path",
        pincode: "123456",
        whatsapp_number: "9876543210"
      })

    {:ok, swayamsevak} = ShakhaNow.Members.create_swayamsevak(scope, attrs)
    swayamsevak
  end
end
