defmodule ShakhaNow.MembersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ShakhaNow.Members` context.
  """

  @doc """
  Generate a swayamsevak.
  """
  def swayamsevak_fixture(scope, attrs \\ %{}) do
    unique_num = System.unique_integer([:positive])
    
    {:ok, swayamsevak} =
      ShakhaNow.Members.create_swayamsevak(scope, attrs
      |> Enum.into(%{
        area: "some area",
        city: "some city",
        date_of_birth: ~D[2026-03-31],
        education: "some education",
        full_name: "some full_name",
        email: "user#{unique_num}@example.com",
        mobile_number: "9876543210#{unique_num}",
        occupation: "Student",
        photo_path: "some photo_path",
        pincode: "123456",
        whatsapp_number: "9876543210"
      }))

    swayamsevak
  end
end
