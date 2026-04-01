defmodule ShakhaNowWeb.SwayamsevakLive.Form do
  use ShakhaNowWeb, :live_view

  alias ShakhaNow.Members
  alias ShakhaNow.Members.Swayamsevak

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage swayamsevak records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="swayamsevak-form" phx-change="validate" phx-submit="save" class="space-y-4 mt-6">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <.input field={@form[:full_name]} type="text" label="Full name" required />
          <.input field={@form[:date_of_birth]} type="date" label="Date of birth" />
        </div>

        <div class="divider text-sm">Contact Details</div>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <.input field={@form[:mobile_number]} type="tel" inputmode="numeric" pattern="[0-9]*" label="Mobile number (Required)" required />
          <.input field={@form[:whatsapp_number]} type="tel" inputmode="numeric" pattern="[0-9]*" label="Whatsapp number" />
        </div>

        <div class="divider text-sm">Location Details</div>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <.input field={@form[:area]} type="text" label="Area / Locality" />
          <.input field={@form[:city]} type="text" label="City" />
          <.input field={@form[:pincode]} type="text" inputmode="numeric" pattern="[0-9]*" label="Pincode" />
        </div>

        <div class="divider text-sm">Other Information</div>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <.input
            field={@form[:occupation]}
            type="select"
            label="Occupation"
            options={[
              {"Student", "Student"},
              {"Service", "Service"},
              {"Business", "Business"},
              {"Other", "Other"}
            ]}
            prompt="Select occupation"
          />
          <.input field={@form[:education]} type="text" label="Education" />
        </div>

        <.input field={@form[:photo_path]} type="text" label="Photo URL" />

        <footer class="flex justify-end gap-2 mt-6">
          <.button type="button" class="btn btn-ghost" navigate={return_path(@current_scope, @return_to, @swayamsevak)}>Cancel</.button>
          <.button phx-disable-with="Saving..." class="btn btn-primary">Save Swayamsevak</.button>
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
    swayamsevak = Members.get_swayamsevak!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Swayamsevak")
    |> assign(:swayamsevak, swayamsevak)
    |> assign(:form, to_form(Members.change_swayamsevak(socket.assigns.current_scope, swayamsevak)))
  end

  defp apply_action(socket, :new, _params) do
    swayamsevak = %Swayamsevak{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Swayamsevak")
    |> assign(:swayamsevak, swayamsevak)
    |> assign(:form, to_form(Members.change_swayamsevak(socket.assigns.current_scope, swayamsevak)))
  end

  @impl true
  def handle_event("validate", %{"swayamsevak" => swayamsevak_params}, socket) do
    changeset = Members.change_swayamsevak(socket.assigns.current_scope, socket.assigns.swayamsevak, swayamsevak_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"swayamsevak" => swayamsevak_params}, socket) do
    save_swayamsevak(socket, socket.assigns.live_action, swayamsevak_params)
  end

  defp save_swayamsevak(socket, :edit, swayamsevak_params) do
    case Members.update_swayamsevak(socket.assigns.current_scope, socket.assigns.swayamsevak, swayamsevak_params) do
      {:ok, swayamsevak} ->
        {:noreply,
         socket
         |> put_flash(:info, "Swayamsevak updated successfully")
         |> push_navigate(to: return_path(socket.assigns.current_scope, socket.assigns.return_to, swayamsevak))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_swayamsevak(socket, :new, swayamsevak_params) do
    case Members.create_swayamsevak(socket.assigns.current_scope, swayamsevak_params) do
      {:ok, swayamsevak} ->
        {:noreply,
         socket
         |> put_flash(:info, "Swayamsevak created successfully")
         |> push_navigate(to: return_path(socket.assigns.current_scope, socket.assigns.return_to, swayamsevak))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _swayamsevak), do: ~p"/swayamsevaks"
  defp return_path(_scope, "show", swayamsevak), do: ~p"/swayamsevaks/#{swayamsevak}"
end
