defmodule ShakhaNow.MembersTest do
  use ShakhaNow.DataCase

  alias ShakhaNow.Members

  describe "swayamsevaks" do
    alias ShakhaNow.Members.Swayamsevak

    import ShakhaNow.AccountsFixtures, only: [user_scope_fixture: 0]
    import ShakhaNow.MembersFixtures

    @invalid_attrs %{full_name: nil, mobile_number: nil, whatsapp_number: nil, date_of_birth: nil, photo_path: nil, area: nil, city: nil, pincode: nil, occupation: nil, occupation_details: nil, education: nil}

    test "list_swayamsevaks/1 returns all scoped swayamsevaks" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      swayamsevak = swayamsevak_fixture(scope)
      other_swayamsevak = swayamsevak_fixture(other_scope)
      assert Members.list_swayamsevaks(scope) == [swayamsevak]
      assert Members.list_swayamsevaks(other_scope) == [other_swayamsevak]
    end

    test "get_swayamsevak!/2 returns the swayamsevak with given id" do
      scope = user_scope_fixture()
      swayamsevak = swayamsevak_fixture(scope)
      other_scope = user_scope_fixture()
      assert Members.get_swayamsevak!(scope, swayamsevak.id) == swayamsevak
      assert_raise Ecto.NoResultsError, fn -> Members.get_swayamsevak!(other_scope, swayamsevak.id) end
    end

    test "create_swayamsevak/2 with valid data creates a swayamsevak" do
      valid_attrs = %{full_name: "some full_name", mobile_number: "1234567890", whatsapp_number: "1234567890", date_of_birth: ~D[2026-03-31], photo_path: "some photo_path", area: "some area", city: "some city", pincode: "123456", occupation: "some occupation", education: "some education"}
      scope = user_scope_fixture()

      assert {:ok, %Swayamsevak{} = swayamsevak} = Members.create_swayamsevak(scope, valid_attrs)
      assert swayamsevak.full_name == "some full_name"
      assert swayamsevak.mobile_number == "1234567890"
      assert swayamsevak.whatsapp_number == "1234567890"
      assert swayamsevak.date_of_birth == ~D[2026-03-31]
      assert swayamsevak.photo_path == "some photo_path"
      assert swayamsevak.area == "some area"
      assert swayamsevak.city == "some city"
      assert swayamsevak.pincode == "123456"
      assert swayamsevak.occupation == "some occupation"
      assert swayamsevak.education == "some education"
      assert swayamsevak.user_id == scope.user.id
    end

    test "create_swayamsevak/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Members.create_swayamsevak(scope, @invalid_attrs)
    end

    test "update_swayamsevak/3 with valid data updates the swayamsevak" do
      scope = user_scope_fixture()
      swayamsevak = swayamsevak_fixture(scope)
      update_attrs = %{full_name: "some updated full_name", mobile_number: "0987654321", whatsapp_number: "0987654321", date_of_birth: ~D[2026-04-01], photo_path: "some updated photo_path", area: "some updated area", city: "some updated city", pincode: "654321", occupation: "some updated occupation", education: "some updated education"}

      assert {:ok, %Swayamsevak{} = swayamsevak} = Members.update_swayamsevak(scope, swayamsevak, update_attrs)
      assert swayamsevak.full_name == "some updated full_name"
      assert swayamsevak.mobile_number == "0987654321"
      assert swayamsevak.whatsapp_number == "0987654321"
      assert swayamsevak.date_of_birth == ~D[2026-04-01]
      assert swayamsevak.photo_path == "some updated photo_path"
      assert swayamsevak.area == "some updated area"
      assert swayamsevak.city == "some updated city"
      assert swayamsevak.pincode == "654321"
      assert swayamsevak.occupation == "some updated occupation"
      assert swayamsevak.education == "some updated education"
    end

    test "update_swayamsevak/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      swayamsevak = swayamsevak_fixture(scope)

      assert_raise MatchError, fn ->
        Members.update_swayamsevak(other_scope, swayamsevak, %{})
      end
    end

    test "update_swayamsevak/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      swayamsevak = swayamsevak_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Members.update_swayamsevak(scope, swayamsevak, @invalid_attrs)
      assert swayamsevak == Members.get_swayamsevak!(scope, swayamsevak.id)
    end

    test "delete_swayamsevak/2 deletes the swayamsevak" do
      scope = user_scope_fixture()
      swayamsevak = swayamsevak_fixture(scope)
      assert {:ok, %Swayamsevak{}} = Members.delete_swayamsevak(scope, swayamsevak)
      assert_raise Ecto.NoResultsError, fn -> Members.get_swayamsevak!(scope, swayamsevak.id) end
    end

    test "delete_swayamsevak/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      swayamsevak = swayamsevak_fixture(scope)
      assert_raise MatchError, fn -> Members.delete_swayamsevak(other_scope, swayamsevak) end
    end

    test "change_swayamsevak/2 returns a swayamsevak changeset" do
      scope = user_scope_fixture()
      swayamsevak = swayamsevak_fixture(scope)
      assert %Ecto.Changeset{} = Members.change_swayamsevak(scope, swayamsevak)
    end
  end
end
