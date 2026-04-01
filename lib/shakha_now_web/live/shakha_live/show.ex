defmodule ShakhaNowWeb.ShakhaLive.Show do
  use ShakhaNowWeb, :live_view

  alias ShakhaNow.Organizations
  alias ShakhaNow.Members

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

      <div class="mt-12 max-w-2xl">
        <.header>
          Roles
          <:subtitle>Assign key roles for this Shakha.</:subtitle>
        </.header>

        <.form for={@form} id="roles-form" phx-change="validate_roles" phx-submit="save_roles" class="mt-4 space-y-4">
          <div class="grid grid-cols-1 gap-4">
            <.input
              field={@form[:mukhya_shikshak_id]}
              type="select"
              label="Mukhya Shikshak"
              prompt="Select Mukhya Shikshak"
              options={@swayamsevak_options}
              phx-hook="SearchableSelect"
            />

            <.input
              field={@form[:karyavah_id]}
              type="select"
              label="Karyavah"
              prompt="Select Karyavah"
              options={@swayamsevak_options}
              phx-hook="SearchableSelect"
            />
          </div>

          <div class="flex justify-end">
            <.button type="submit" phx-disable-with="Saving..." variant="primary">Save Roles</.button>
          </div>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Organizations.subscribe_shakhas(socket.assigns.current_scope)
    end

    shakha = Organizations.get_shakha!(socket.assigns.current_scope, id)
    swayamsevaks = Members.list_swayamsevaks(socket.assigns.current_scope)
    
    swayamsevak_options =
      swayamsevaks
      |> Enum.map(fn s -> {"#{s.full_name} - #{s.mobile_number}", s.id} end)

    changeset = Organizations.change_shakha(socket.assigns.current_scope, shakha)

    {:ok,
     socket
     |> assign(:page_title, "Show Shakha")
     |> assign(:shakha, shakha)
     |> assign(:swayamsevak_options, swayamsevak_options)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("validate_roles", %{"shakha" => shakha_params}, socket) do
    changeset =
      socket.assigns.current_scope
      |> Organizations.change_shakha(socket.assigns.shakha, shakha_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save_roles", %{"shakha" => shakha_params}, socket) do
    case Organizations.update_shakha(socket.assigns.current_scope, socket.assigns.shakha, shakha_params) do
      {:ok, shakha} ->
        {:noreply,
         socket
         |> put_flash(:info, "Roles updated successfully")
         |> assign(:shakha, shakha)
         |> assign(:form, to_form(Organizations.change_shakha(socket.assigns.current_scope, shakha)))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
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
