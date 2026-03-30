defmodule ShakhaNowWeb.ShakhaLive.Form do
  use ShakhaNowWeb, :live_view

  alias ShakhaNow.Organizations
  alias ShakhaNow.Organizations.Shakha

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage shakha records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="shakha-form" phx-change="validate" phx-submit="save" class="space-y-4">
        <.input field={@form[:name]} type="text" label="Shakha Name" required />
        
        <div class="divider text-sm">Location Details</div>
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <.input field={@form[:area]} type="text" label="Area" required />
          <.input field={@form[:city]} type="text" label="City" required />
          <.input field={@form[:pincode]} type="text" label="Pincode" required />
        </div>
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <.input field={@form[:latitude]} type="number" label="Latitude (Optional)" step="any" />
          <.input field={@form[:longitude]} type="number" label="Longitude (Optional)" step="any" />
        </div>

        <div class="divider text-sm">Meeting Details</div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <.input 
            field={@form[:schedule_type]} 
            type="select" 
            label="Meeting Schedule" 
            options={[
              {"Daily", "daily"},
              {"Weekends", "weekends"},
              {"Custom days", "custom"}
            ]}
            required 
          />
          <.input field={@form[:meeting_time]} type="time" label="Meeting Time" required />
        </div>

        <footer class="flex justify-end gap-2 mt-6">
          <.button type="button" class="btn btn-ghost" navigate={return_path(@current_scope, @return_to, @shakha)}>Cancel</.button>
          <.button phx-disable-with="Saving..." class="btn btn-primary">Save Shakha</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    shakha = Organizations.get_shakha!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Shakha")
    |> assign(:shakha, shakha)
    |> assign(:form, to_form(Organizations.change_shakha(socket.assigns.current_scope, shakha)))
  end

  defp apply_action(socket, :new, _params) do
    shakha = %Shakha{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Shakha")
    |> assign(:shakha, shakha)
    |> assign(:form, to_form(Organizations.change_shakha(socket.assigns.current_scope, shakha)))
  end

  @impl true
  def handle_event("validate", %{"shakha" => shakha_params}, socket) do
    changeset = Organizations.change_shakha(socket.assigns.current_scope, socket.assigns.shakha, shakha_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"shakha" => shakha_params}, socket) do
    save_shakha(socket, socket.assigns.live_action, shakha_params)
  end

  defp save_shakha(socket, :edit, shakha_params) do
    case Organizations.update_shakha(socket.assigns.current_scope, socket.assigns.shakha, shakha_params) do
      {:ok, shakha} ->
        {:noreply,
         socket
         |> put_flash(:info, "Shakha updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, shakha)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_shakha(socket, :new, shakha_params) do
    case Organizations.create_shakha(socket.assigns.current_scope, shakha_params) do
      {:ok, shakha} ->
        {:noreply,
         socket
         |> put_flash(:info, "Shakha created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, shakha)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _shakha), do: ~p"/shakhas"
  defp return_path(_scope, "show", shakha), do: ~p"/shakhas/#{shakha}"
end
