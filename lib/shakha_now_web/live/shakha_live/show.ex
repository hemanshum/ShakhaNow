defmodule ShakhaNowWeb.ShakhaLive.Show do
  use ShakhaNowWeb, :live_view

  alias ShakhaNow.Organizations
  alias ShakhaNow.Members

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@shakha.name}
        <:subtitle>Shakha details and swayamsevaks.</:subtitle>
        <:actions>
          <.button navigate={~p"/shakhas"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/shakhas/#{@shakha}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit shakha
          </.button>
        </:actions>
      </.header>

      <%!-- Tab navigation --%>
      <div class="mt-8 mb-6" style="display:flex;gap:0;border-bottom:2px solid oklch(93% 0 0);">
        <div
          id="tab-details"
          phx-click="switch_tab"
          phx-value-tab="details"
          style={"cursor:pointer;padding:10px 24px;font-size:14px;font-weight:600;border-bottom:3px solid #{if @active_tab == :details, do: "oklch(86% 0.17 101)", else: "transparent"};margin-bottom:-2px;color:#{if @active_tab == :details, do: "oklch(40% 0.12 101)", else: "oklch(50% 0 0)"}"}
        >
          Details & Roles
        </div>
        <div
          id="tab-swayamsevaks"
          phx-click="switch_tab"
          phx-value-tab="swayamsevaks"
          style={"cursor:pointer;padding:10px 24px;font-size:14px;font-weight:600;border-bottom:3px solid #{if @active_tab == :swayamsevaks, do: "oklch(86% 0.17 101)", else: "transparent"};margin-bottom:-2px;color:#{if @active_tab == :swayamsevaks, do: "oklch(40% 0.12 101)", else: "oklch(50% 0 0)"}"}
        >
          Swayamsevaks ({@swayamsevak_count})
        </div>
      </div>

      <%!-- Details & Roles tab panel --%>
      <div class={if(@active_tab != :details, do: "hidden", else: "")}>
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
      </div>

      <%!-- Swayamsevaks tab panel — ALWAYS in DOM so stream works --%>
      <div class={if(@active_tab != :swayamsevaks, do: "hidden", else: "")}>
        <div class="overflow-x-auto rounded-xl border border-base-200 mt-2 bg-base-100 shadow-sm">
          <table class="table table-zebra w-full">
            <thead class="bg-base-200/50">
              <tr>
                <th>Name & Details</th>
                <th>Contact</th>
                <th>Role</th>
              </tr>
            </thead>
            <tbody id="shakha-swayamsevaks" phx-update="stream">
              <tr :for={{id, swayamsevak} <- @streams.swayamsevaks} id={id} class="hover:bg-base-200/50 transition-colors">
                <td>
                  <div class="flex items-center gap-4">
                    <div class="avatar">
                      <div class="mask mask-squircle w-12 h-12 shadow-sm border border-base-200">
                        <img src={swayamsevak.photo_path || "https://ui-avatars.com/api/?name=#{URI.encode(swayamsevak.full_name)}&background=random"} alt={swayamsevak.full_name} />
                      </div>
                    </div>
                    <div>
                      <div class="font-bold text-base">{swayamsevak.full_name}</div>
                      <div class="text-sm opacity-60 font-medium">{swayamsevak.occupation}</div>
                    </div>
                  </div>
                </td>
                <td>
                  <div class="text-sm space-y-1">
                    <div><a href={"mailto:#{swayamsevak.email}"} class="link link-hover text-base-content/80 flex items-center gap-1"><.icon name="hero-envelope" class="w-4 h-4 opacity-70" /> {swayamsevak.email}</a></div>
                    <div><a href={"tel:#{swayamsevak.mobile_number}"} class="link link-hover text-base-content/80 flex items-center gap-1"><.icon name="hero-phone" class="w-4 h-4 opacity-70" /> {swayamsevak.mobile_number}</a></div>
                  </div>
                </td>
                <td>
                  <span class="badge badge-primary badge-outline badge-sm font-medium">{swayamsevak.role}</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Organizations.subscribe_shakhas(socket.assigns.current_scope)
      Members.subscribe_swayamsevaks(socket.assigns.current_scope)
    end

    shakha = Organizations.get_shakha!(socket.assigns.current_scope, id)
    swayamsevaks = Members.list_swayamsevaks(socket.assigns.current_scope)
    shakha_swayamsevaks = Members.list_swayamsevaks_for_shakha(socket.assigns.current_scope, id)
    
    swayamsevak_options =
      swayamsevaks
      |> Enum.map(fn s -> {"#{s.full_name} - #{s.mobile_number}", s.id} end)

    changeset = Organizations.change_shakha(socket.assigns.current_scope, shakha)

    {:ok,
     socket
     |> assign(:page_title, "Show Shakha")
     |> assign(:shakha, shakha)
     |> assign(:swayamsevak_options, swayamsevak_options)
     |> assign(:active_tab, :details)
     |> assign(:swayamsevak_count, length(shakha_swayamsevaks))
     |> stream(:swayamsevaks, shakha_swayamsevaks)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, active_tab: String.to_existing_atom(tab))}
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
