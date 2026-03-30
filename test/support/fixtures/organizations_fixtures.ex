defmodule ShakhaNow.OrganizationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ShakhaNow.Organizations` context.
  """

  @doc """
  Generate a shakha.
  """
  def shakha_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        area: "some area",
        city: "some city",
        latitude: 120.5,
        longitude: 120.5,
        meeting_time: ~T[14:00:00],
        name: "some name",
        pincode: "some pincode",
        schedule_type: "some schedule_type"
      })

    {:ok, shakha} = ShakhaNow.Organizations.create_shakha(scope, attrs)
    shakha
  end
end
