defmodule ShakhaNow.OrganizationsTest do
  use ShakhaNow.DataCase

  alias ShakhaNow.Organizations

  describe "shakhas" do
    alias ShakhaNow.Organizations.Shakha

    import ShakhaNow.AccountsFixtures, only: [user_scope_fixture: 0]
    import ShakhaNow.OrganizationsFixtures

    @invalid_attrs %{name: nil, area: nil, city: nil, pincode: nil, latitude: nil, longitude: nil, schedule_type: nil, meeting_time: nil}

    test "list_shakhas/1 returns all scoped shakhas" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      shakha = shakha_fixture(scope)
      other_shakha = shakha_fixture(other_scope)
      assert Organizations.list_shakhas(scope) == [shakha]
      assert Organizations.list_shakhas(other_scope) == [other_shakha]
    end

    test "get_shakha!/2 returns the shakha with given id" do
      scope = user_scope_fixture()
      shakha = shakha_fixture(scope)
      other_scope = user_scope_fixture()
      assert Organizations.get_shakha!(scope, shakha.id) == shakha
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_shakha!(other_scope, shakha.id) end
    end

    test "create_shakha/2 with valid data creates a shakha" do
      valid_attrs = %{name: "some name", area: "some area", city: "some city", pincode: "some pincode", latitude: 120.5, longitude: 120.5, schedule_type: "some schedule_type", meeting_time: ~T[14:00:00]}
      scope = user_scope_fixture()

      assert {:ok, %Shakha{} = shakha} = Organizations.create_shakha(scope, valid_attrs)
      assert shakha.name == "some name"
      assert shakha.area == "some area"
      assert shakha.city == "some city"
      assert shakha.pincode == "some pincode"
      assert shakha.latitude == 120.5
      assert shakha.longitude == 120.5
      assert shakha.schedule_type == "some schedule_type"
      assert shakha.meeting_time == ~T[14:00:00]
      assert shakha.user_id == scope.user.id
    end

    test "create_shakha/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Organizations.create_shakha(scope, @invalid_attrs)
    end

    test "update_shakha/3 with valid data updates the shakha" do
      scope = user_scope_fixture()
      shakha = shakha_fixture(scope)
      update_attrs = %{name: "some updated name", area: "some updated area", city: "some updated city", pincode: "some updated pincode", latitude: 456.7, longitude: 456.7, schedule_type: "some updated schedule_type", meeting_time: ~T[15:01:01]}

      assert {:ok, %Shakha{} = shakha} = Organizations.update_shakha(scope, shakha, update_attrs)
      assert shakha.name == "some updated name"
      assert shakha.area == "some updated area"
      assert shakha.city == "some updated city"
      assert shakha.pincode == "some updated pincode"
      assert shakha.latitude == 456.7
      assert shakha.longitude == 456.7
      assert shakha.schedule_type == "some updated schedule_type"
      assert shakha.meeting_time == ~T[15:01:01]
    end

    test "update_shakha/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      shakha = shakha_fixture(scope)

      assert_raise MatchError, fn ->
        Organizations.update_shakha(other_scope, shakha, %{})
      end
    end

    test "update_shakha/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      shakha = shakha_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Organizations.update_shakha(scope, shakha, @invalid_attrs)
      assert shakha == Organizations.get_shakha!(scope, shakha.id)
    end

    test "delete_shakha/2 deletes the shakha" do
      scope = user_scope_fixture()
      shakha = shakha_fixture(scope)
      assert {:ok, %Shakha{}} = Organizations.delete_shakha(scope, shakha)
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_shakha!(scope, shakha.id) end
    end

    test "delete_shakha/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      shakha = shakha_fixture(scope)
      assert_raise MatchError, fn -> Organizations.delete_shakha(other_scope, shakha) end
    end

    test "change_shakha/2 returns a shakha changeset" do
      scope = user_scope_fixture()
      shakha = shakha_fixture(scope)
      assert %Ecto.Changeset{} = Organizations.change_shakha(scope, shakha)
    end
  end
end
