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

      <.table
        id="swayamsevaks"
        rows={@streams.swayamsevaks}
        row_click={fn {_id, swayamsevak} -> JS.navigate(~p"/swayamsevaks/#{swayamsevak}") end}
      >
        <:col :let={{_id, swayamsevak}} label="Full name">{swayamsevak.full_name}</:col>
        <:col :let={{_id, swayamsevak}} label="Mobile number">{swayamsevak.mobile_number}</:col>
        <:col :let={{_id, swayamsevak}} label="Whatsapp number">{swayamsevak.whatsapp_number}</:col>
        <:col :let={{_id, swayamsevak}} label="Date of birth">{swayamsevak.date_of_birth}</:col>
        <:col :let={{_id, swayamsevak}} label="City">{swayamsevak.city}</:col>
        <:col :let={{_id, swayamsevak}} label="Occupation">{swayamsevak.occupation}</:col>
        <:action :let={{_id, swayamsevak}}>
          <div class="sr-only">
            <.link navigate={~p"/swayamsevaks/#{swayamsevak}"}>Show</.link>
          </div>
          <.link navigate={~p"/swayamsevaks/#{swayamsevak}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, swayamsevak}}>
          <.link
            phx-click={JS.push("delete", value: %{id: swayamsevak.id}) |> hide("##{id}")}
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
end
