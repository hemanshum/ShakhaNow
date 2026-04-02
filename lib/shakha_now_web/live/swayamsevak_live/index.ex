defmodule ShakhaNowWeb.SwayamsevakLive.Index do
  use ShakhaNowWeb, :live_view

  alias ShakhaNow.Members

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Swayamsevaks
        <:actions>
          <.button variant="primary" navigate={~p"/swayamsevaks/new"}>
            <.icon name="hero-plus" /> New Swayamsevak
          </.button>
        </:actions>
      </.header>

      <div class="mb-6 mt-4 p-4 border rounded-xl bg-base-100 shadow-sm">
        <h3 class="font-bold mb-2">Upload CSV</h3>
        <form id="upload-form" phx-submit="save_csv" phx-change="validate_csv" class="flex items-center gap-4">
          <.live_file_input upload={@uploads.csv} class="file-input file-input-bordered file-input-sm w-full max-w-xs" />
          <.button type="submit" phx-disable-with="Uploading..." class="btn btn-secondary btn-sm">Upload</.button>
        </form>
        <%= for entry <- @uploads.csv.entries do %>
          <div class="text-sm mt-2 text-info">Selected: {entry.client_name}</div>
        <% end %>
      </div>

      <div class="overflow-x-auto rounded-box border border-base-200">
        <table class="table table-zebra w-full">
          <thead>
            <tr>
              <th>Name & Details</th>
              <th>Contact</th>
              <th>Location</th>
              <th>Occupation</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody id="swayamsevaks">
            <tr :for={{id, swayamsevak} <- @streams.swayamsevaks} id={id}>
              <td>
                <div class="flex items-center gap-3">
                  <div class="avatar">
                    <div class="mask mask-squircle w-12 h-12">
                      <img src={swayamsevak.photo_path || "https://ui-avatars.com/api/?name=#{URI.encode(swayamsevak.full_name)}&background=random"} alt={swayamsevak.full_name} />
                    </div>
                  </div>
                  <div>
                    <div class="font-bold">{swayamsevak.full_name}</div>
                    <div class="text-sm opacity-50">{role_and_shakha(swayamsevak)}</div>
                  </div>
                </div>
              </td>
              <td>
                <div class="text-sm">
                  <div><a href={"mailto:#{swayamsevak.email}"} class="link link-hover">{swayamsevak.email}</a></div>
                  <div><a href={"tel:#{swayamsevak.mobile_number}"} class="link link-hover">{swayamsevak.mobile_number}</a></div>
                  <div :if={swayamsevak.whatsapp_number} class="text-xs opacity-50">WA: {swayamsevak.whatsapp_number}</div>
                </div>
              </td>
              <td>
                <div class="text-sm">
                  <div>{swayamsevak.city}</div>
                  <div class="text-xs opacity-50">{swayamsevak.area}</div>
                </div>
              </td>
              <td>
                <div class="text-sm">{swayamsevak.occupation}</div>
              </td>
              <td>
                <div class="flex justify-end">
                  <div class="sr-only">
                    <.link navigate={~p"/swayamsevaks/#{swayamsevak}"}>Show</.link>
                  </div>
                  <.link navigate={~p"/swayamsevaks/#{swayamsevak}/edit"}>Edit</.link>
                  <.link
                    phx-click={JS.push("delete", value: %{id: swayamsevak.id}) |> hide("##{id}")}
                    data-confirm="Are you sure?"
                  >
                    Delete
                  </.link>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Members.subscribe_swayamsevaks(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Swayamsevaks")
     |> stream(:swayamsevaks, list_swayamsevaks(socket.assigns.current_scope))
     |> allow_upload(:csv, accept: ~w(.csv), max_entries: 1)}
  end

  @impl true
  def handle_event("validate_csv", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save_csv", _params, socket) do
    consume_uploaded_entries(socket, :csv, fn %{path: path}, _entry ->
      parse_and_insert_csv(path, socket.assigns.current_scope)
      {:ok, path}
    end)

    {:noreply, put_flash(socket, :info, "CSV processed successfully")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    swayamsevak = Members.get_swayamsevak!(socket.assigns.current_scope, id)
    {:ok, _} = Members.delete_swayamsevak(socket.assigns.current_scope, swayamsevak)

    {:noreply, stream_delete(socket, :swayamsevaks, swayamsevak)}
  end

  @impl true
  def handle_info({type, %ShakhaNow.Members.Swayamsevak{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :swayamsevaks, list_swayamsevaks(socket.assigns.current_scope), reset: true)}
  end

  defp list_swayamsevaks(current_scope) do
    Members.list_swayamsevaks(current_scope)
  end

  defp parse_and_insert_csv(path, scope) do
    path
    |> File.stream!()
    |> ShakhaNow.CSVParser.parse_stream(skip_headers: true)
    |> Enum.each(fn row ->
      attrs =
        case row do
          [full_name, mobile_number, whatsapp_number, dob, photo, area, city, pincode, occupation, education | _] ->
            %{
              "full_name" => full_name,
              "mobile_number" => mobile_number,
              "whatsapp_number" => whatsapp_number,
              "date_of_birth" => parse_dob(dob),
              "photo_path" => photo,
              "area" => area,
              "city" => city,
              "pincode" => pincode,
              "occupation" => occupation,
              "education" => education
            }

          [full_name, mobile_number, whatsapp_number, dob, photo, address, occupation, education | _] ->
            [area, city, pincode] = parse_address(address)
            %{
              "full_name" => full_name,
              "mobile_number" => mobile_number,
              "whatsapp_number" => whatsapp_number,
              "date_of_birth" => parse_dob(dob),
              "photo_path" => photo,
              "area" => area,
              "city" => city,
              "pincode" => pincode,
              "occupation" => occupation,
              "education" => education
            }

          _ ->
            %{}
        end

      if map_size(attrs) > 0 and attrs["mobile_number"] != "" do
        existing = ShakhaNow.Repo.get_by(ShakhaNow.Members.Swayamsevak, mobile_number: attrs["mobile_number"], user_id: scope.user.id)
        if existing do
          Members.update_swayamsevak(scope, existing, attrs)
        else
          Members.create_swayamsevak(scope, attrs)
        end
      end
    end)
  end

  defp parse_dob(dob_str) when is_binary(dob_str) do
    case String.split(dob_str, "/") do
      [d, m, y] ->
        try do
          d = String.trim(d) |> String.to_integer()
          m = String.trim(m) |> String.to_integer()
          y = String.trim(y) |> String.to_integer()
          case Date.new(y, m, d) do
            {:ok, date} -> date
            _ -> nil
          end
        rescue
          _ -> nil
        end
      _ -> nil
    end
  end
  defp parse_dob(_), do: nil

  defp parse_address(address) when is_binary(address) do
    parts = String.split(address, ",") |> Enum.map(&String.trim/1)
    case parts do
      [area, city, pincode | _] -> [area, city, pincode]
      [area, city] -> [area, city, ""]
      [area] -> [area, "", ""]
      [] -> ["", "", ""]
    end
  end
  defp parse_address(_), do: ["", "", ""]

  defp role_and_shakha(swayamsevak) do
    role = swayamsevak.role || "Swayamsevak"
    shakha = 
      if swayamsevak.shakha do
        swayamsevak.shakha.name
      else
        nil
      end

    if shakha do
      "#{role}, #{shakha}"
    else
      role
    end
  end
end
