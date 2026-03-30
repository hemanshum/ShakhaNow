defmodule ShakhaNowWeb.ShakhaLiveTest do
  use ShakhaNowWeb.ConnCase

  import Phoenix.LiveViewTest
  import ShakhaNow.OrganizationsFixtures

  @create_attrs %{name: "some name", area: "some area", city: "some city", pincode: "some pincode", latitude: 120.5, longitude: 120.5, schedule_type: "daily", meeting_time: "14:00"}
  @update_attrs %{name: "some updated name", area: "some updated area", city: "some updated city", pincode: "some updated pincode", latitude: 456.7, longitude: 456.7, schedule_type: "weekends", meeting_time: "15:01"}
  @invalid_attrs %{name: nil, area: nil, city: nil, pincode: nil, latitude: nil, longitude: nil, schedule_type: "daily", meeting_time: nil}

  setup :register_and_log_in_user

  defp create_shakha(%{scope: scope}) do
    shakha = shakha_fixture(scope)

    %{shakha: shakha}
  end

  describe "Index" do
    setup [:create_shakha]

    test "lists all shakhas", %{conn: conn, shakha: shakha} do
      {:ok, _index_live, html} = live(conn, ~p"/shakhas")

      assert html =~ "Listing Shakhas"
      assert html =~ shakha.name
    end

    test "saves new shakha", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/shakhas")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Shakha")
               |> render_click()
               |> follow_redirect(conn, ~p"/shakhas/new")

      assert render(form_live) =~ "New Shakha"

      assert form_live
             |> form("#shakha-form", shakha: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#shakha-form", shakha: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/shakhas")

      html = render(index_live)
      assert html =~ "Shakha created successfully"
      assert html =~ "some name"
    end

    test "updates shakha in listing", %{conn: conn, shakha: shakha} do
      {:ok, index_live, _html} = live(conn, ~p"/shakhas")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#shakhas-#{shakha.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/shakhas/#{shakha}/edit")

      assert render(form_live) =~ "Edit Shakha"

      assert form_live
             |> form("#shakha-form", shakha: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#shakha-form", shakha: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/shakhas")

      html = render(index_live)
      assert html =~ "Shakha updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes shakha in listing", %{conn: conn, shakha: shakha} do
      {:ok, index_live, _html} = live(conn, ~p"/shakhas")

      assert index_live |> element("#shakhas-#{shakha.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#shakhas-#{shakha.id}")
    end
  end

  describe "Show" do
    setup [:create_shakha]

    test "displays shakha", %{conn: conn, shakha: shakha} do
      {:ok, _show_live, html} = live(conn, ~p"/shakhas/#{shakha}")

      assert html =~ "Show Shakha"
      assert html =~ shakha.name
    end

    test "updates shakha and returns to show", %{conn: conn, shakha: shakha} do
      {:ok, show_live, _html} = live(conn, ~p"/shakhas/#{shakha}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/shakhas/#{shakha}/edit?return_to=show")

      assert render(form_live) =~ "Edit Shakha"

      assert form_live
             |> form("#shakha-form", shakha: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#shakha-form", shakha: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/shakhas/#{shakha}")

      html = render(show_live)
      assert html =~ "Shakha updated successfully"
      assert html =~ "some updated name"
    end
  end
end
