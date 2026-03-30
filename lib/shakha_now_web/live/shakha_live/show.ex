defmodule ShakhaNowWeb.ShakhaLive.Show do
  use ShakhaNowWeb, :live_view

  alias ShakhaNow.Organizations

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Shakha {@shakha.id}
        <:subtitle>This is a shakha record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/shakhas"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/shakhas/#{@shakha}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit shakha
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@shakha.name}</:item>
        <:item title="Area">{@shakha.area}</:item>
        <:item title="City">{@shakha.city}</:item>
        <:item title="Pincode">{@shakha.pincode}</:item>
        <:item title="Latitude">{@shakha.latitude}</:item>
        <:item title="Longitude">{@shakha.longitude}</:item>
        <:item title="Schedule type">{@shakha.schedule_type}</:item>
        <:item title="Meeting time">{@shakha.meeting_time}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Organizations.subscribe_shakhas(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Shakha")
     |> assign(:shakha, Organizations.get_shakha!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %ShakhaNow.Organizations.Shakha{id: id} = shakha},
        %{assigns: %{shakha: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :shakha, shakha)}
  end

  def handle_info(
        {:deleted, %ShakhaNow.Organizations.Shakha{id: id}},
        %{assigns: %{shakha: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current shakha was deleted.")
     |> push_navigate(to: ~p"/shakhas")}
  end

  def handle_info({type, %ShakhaNow.Organizations.Shakha{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
