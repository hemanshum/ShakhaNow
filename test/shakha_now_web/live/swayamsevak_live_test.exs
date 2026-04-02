defmodule ShakhaNowWeb.SwayamsevakLiveTest do
  use ShakhaNowWeb.ConnCase

  import Phoenix.LiveViewTest
  import ShakhaNow.MembersFixtures
  import ShakhaNow.AccountsFixtures

  @create_attrs %{full_name: "some full_name", email: "test@example.com", mobile_number: "1234567890", whatsapp_number: "1234567890", date_of_birth: "2026-03-31", photo_path: "some photo_path", area: "some area", city: "some city", pincode: "123456", occupation: "Student", education: "some education"}
  @update_attrs %{full_name: "some updated full_name", email: "updated@example.com", mobile_number: "0987654321", whatsapp_number: "0987654321", date_of_birth: "2026-04-01", photo_path: "some updated photo_path", area: "some updated area", city: "some updated city", pincode: "654321", occupation: "Business", education: "some updated education"}
  @invalid_attrs %{full_name: nil, email: nil, mobile_number: nil, whatsapp_number: nil, date_of_birth: nil, photo_path: nil, area: nil, city: nil, pincode: nil, occupation: nil, education: nil}

  defp create_swayamsevak(%{user: user}) do
    scope = %ShakhaNow.Accounts.Scope{user: user}
    swayamsevak = swayamsevak_fixture(scope)

    %{swayamsevak: swayamsevak, scope: scope}
  end

  setup %{conn: conn} do
    user = user_fixture()
    conn = conn |> log_in_user(user)
    %{conn: conn, user: user}
  end

  describe "Index" do
    setup [:create_swayamsevak]

    test "lists all swayamsevaks", %{conn: conn, swayamsevak: swayamsevak} do
      {:ok, _index_live, html} = live(conn, ~p"/swayamsevaks")

      assert html =~ "Listing Swayamsevaks"
      assert html =~ swayamsevak.full_name
    end

    test "saves new swayamsevak", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/swayamsevaks")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Swayamsevak")
               |> render_click()
               |> follow_redirect(conn, ~p"/swayamsevaks/new")

      assert render(form_live) =~ "New Swayamsevak"

      assert form_live
             |> form("#swayamsevak-form", swayamsevak: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#swayamsevak-form", swayamsevak: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/swayamsevaks")

      html = render(index_live)
      assert html =~ "Swayamsevak created successfully"
      assert html =~ "some full_name"
    end

    test "updates swayamsevak in listing", %{conn: conn, swayamsevak: swayamsevak} do
      {:ok, index_live, _html} = live(conn, ~p"/swayamsevaks")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#swayamsevaks-#{swayamsevak.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/swayamsevaks/#{swayamsevak}/edit")

      assert render(form_live) =~ "Edit Swayamsevak"

      assert form_live
             |> form("#swayamsevak-form", swayamsevak: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#swayamsevak-form", swayamsevak: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/swayamsevaks")

      html = render(index_live)
      assert html =~ "Swayamsevak updated successfully"
      assert html =~ "some updated full_name"
    end

    test "deletes swayamsevak in listing", %{conn: conn, swayamsevak: swayamsevak} do
      {:ok, index_live, _html} = live(conn, ~p"/swayamsevaks")

      assert index_live |> element("#swayamsevaks-#{swayamsevak.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#swayamsevaks-#{swayamsevak.id}")
    end
  end

  describe "Show" do
    setup [:create_swayamsevak]

    test "displays swayamsevak", %{conn: conn, swayamsevak: swayamsevak} do
      {:ok, _show_live, html} = live(conn, ~p"/swayamsevaks/#{swayamsevak}")

      assert html =~ "Show Swayamsevak"
      assert html =~ swayamsevak.full_name
    end

    test "updates swayamsevak and returns to show", %{conn: conn, swayamsevak: swayamsevak} do
      {:ok, show_live, _html} = live(conn, ~p"/swayamsevaks/#{swayamsevak}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/swayamsevaks/#{swayamsevak}/edit?return_to=show")

      assert render(form_live) =~ "Edit Swayamsevak"

      assert form_live
             |> form("#swayamsevak-form", swayamsevak: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#swayamsevak-form", swayamsevak: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/swayamsevaks/#{swayamsevak}")

      html = render(show_live)
      assert html =~ "Swayamsevak updated successfully"
      assert html =~ "some updated full_name"
    end
  end
end
