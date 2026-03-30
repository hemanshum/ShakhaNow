defmodule ShakhaNowWeb.DashboardLive.Index do
  use ShakhaNowWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Dashboard
        <:subtitle>Welcome to your ShakhaNow dashboard.</:subtitle>
      </.header>

      <div class="mt-8">
        <p>This is the dashboard. More features coming soon.</p>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:page_title, "Dashboard")}
  end
end
