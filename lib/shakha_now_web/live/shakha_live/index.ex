defmodule ShakhaNowWeb.ShakhaLive.Index do
  use ShakhaNowWeb, :live_view

  alias ShakhaNow.Organizations

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Shakhas
        <:actions>
          <.button variant="primary" navigate={~p"/shakhas/new"}>
            <.icon name="hero-plus" /> New Shakha
          </.button>
        </:actions>
      </.header>

      <.table
        id="shakhas"
        rows={@streams.shakhas}
        row_click={fn {_id, shakha} -> JS.navigate(~p"/shakhas/#{shakha}") end}
      >
        <:col :let={{_id, shakha}} label="Name">{shakha.name}</:col>
        <:col :let={{_id, shakha}} label="Area">{shakha.area}</:col>
        <:col :let={{_id, shakha}} label="City">{shakha.city}</:col>
        <:col :let={{_id, shakha}} label="Pincode">{shakha.pincode}</:col>
        <:col :let={{_id, shakha}} label="Latitude">{shakha.latitude}</:col>
        <:col :let={{_id, shakha}} label="Longitude">{shakha.longitude}</:col>
        <:col :let={{_id, shakha}} label="Schedule type">{shakha.schedule_type}</:col>
        <:col :let={{_id, shakha}} label="Meeting time">{shakha.meeting_time}</:col>
        <:action :let={{_id, shakha}}>
          <div class="sr-only">
            <.link navigate={~p"/shakhas/#{shakha}"}>Show</.link>
          </div>
          <.link navigate={~p"/shakhas/#{shakha}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, shakha}}>
          <.link
            phx-click={JS.push("delete", value: %{id: shakha.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Organizations.subscribe_shakhas(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Shakhas")
     |> stream(:shakhas, list_shakhas(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    shakha = Organizations.get_shakha!(socket.assigns.current_scope, id)
    {:ok, _} = Organizations.delete_shakha(socket.assigns.current_scope, shakha)

    {:noreply, stream_delete(socket, :shakhas, shakha)}
  end

  @impl true
  def handle_info({type, %ShakhaNow.Organizations.Shakha{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :shakhas, list_shakhas(socket.assigns.current_scope), reset: true)}
  end

  defp list_shakhas(current_scope) do
    Organizations.list_shakhas(current_scope)
  end
end
