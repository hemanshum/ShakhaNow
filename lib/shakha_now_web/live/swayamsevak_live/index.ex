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
          <.button type="submit" phx-disable-with="Uploading..." disabled={length(@uploads.csv.entries) == 0} class="btn btn-secondary btn-sm">Upload</.button>
        </form>

        <%= for entry <- @uploads.csv.entries do %>
          <div class="mt-4">
            <div class="flex justify-between text-sm mb-1">
              <span class="text-info font-medium">Selected: {entry.client_name}</span>
              <span>{entry.progress}%</span>
            </div>
            <progress class="progress progress-secondary w-full" value={entry.progress} max="100"></progress>
            <div class="text-xs text-error mt-1" :for={err <- upload_errors(@uploads.csv, entry)}>
              {error_to_string(err)}
            </div>
          </div>
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
          <tbody id="swayamsevaks" phx-update="stream">
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
                    <div class="text-sm mt-1 flex items-center gap-1">
                      <.role_badge role={swayamsevak.role || "Swayamsevak"} />
                      <span :if={swayamsevak.shakha} class="opacity-50">, {swayamsevak.shakha.name}</span>
                    </div>
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
  def handle_event("delete", %{"id" => id}, socket) do
    swayamsevak = Members.get_swayamsevak!(socket.assigns.current_scope, id)
    {:ok, _} = Members.delete_swayamsevak(socket.assigns.current_scope, swayamsevak)

    {:noreply, stream_delete(socket, :swayamsevaks, swayamsevak)}
  end

  def handle_event("validate_csv", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save_csv", _params, socket) do
    if length(socket.assigns.uploads.csv.entries) == 0 do
      {:noreply, put_flash(socket, :error, "Please select a file to upload first.")}
    else
      try do
        results = consume_uploaded_entries(socket, :csv, fn %{path: path}, _entry ->
          # Process CSV synchronously to catch errors before returning
          case parse_and_insert_csv(path, socket.assigns.current_scope) do
            {:ok, count} -> {:ok, {:ok, count}}
            {:error, reason} -> {:ok, {:error, reason}}
          end
        end)
        
        # Check results
        case results do
          [{:ok, count}] when count > 0 ->
            {:noreply, put_flash(socket, :info, "CSV processed successfully. #{count} swayamsevaks imported.")}
          [{:ok, 0}] ->
            {:noreply, put_flash(socket, :error, "No valid swayamsevaks found in the CSV. Please check the format and try again.")}
          [{:error, reason}] ->
            {:noreply, put_flash(socket, :error, "Failed to process CSV: #{reason}")}
          _ ->
            {:noreply, put_flash(socket, :error, "An unknown error occurred during upload.")}
        end
      rescue
        e ->
          require Logger
          Logger.error("CSV upload failed: #{inspect(e)}")
          {:noreply, put_flash(socket, :error, "Failed to parse CSV. Please ensure it matches the expected format.")}
      end
    end
  end

  defp error_to_string(:too_large), do: "File is too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(_), do: "An unknown error occurred"

  @impl true
  def handle_info({:created, swayamsevak}, socket) do
    {:noreply, stream_insert(socket, :swayamsevaks, swayamsevak, at: 0)}
  end

  @impl true
  def handle_info({:updated, swayamsevak}, socket) do
    {:noreply, stream_insert(socket, :swayamsevaks, swayamsevak)}
  end

  @impl true
  def handle_info({:deleted, swayamsevak}, socket) do
    {:noreply, stream_delete(socket, :swayamsevaks, swayamsevak)}
  end

  defp list_swayamsevaks(current_scope) do
    Members.list_swayamsevaks(current_scope)
  end

  defp parse_and_insert_csv(path, scope) do
    try do
      count = 
        path
        |> File.stream!()
        |> ShakhaNow.CSVParser.parse_stream(skip_headers: true)
        |> Enum.reduce(0, fn row, acc ->
          # Pad the row to ensure we have at least 12 columns
          padded_row = row ++ List.duplicate("", max(0, 12 - length(row)))
          
          attrs =
            case padded_row do
              # Format based on actual output: Full Name, Role, Attendance Type, Email, Mobile Number, WhatsApp Number, Date of Birth, Photo, Address, Occupation, Education, Shakha
              [full_name, role, attendance_type, email, mobile_number, whatsapp_number, dob, photo, address, occupation, education, shakha_name | _] ->
                [area, city, pincode] = parse_address(address)
                
                # Clean up mobile number (remove any non-numeric characters)
                clean_mobile = String.replace(mobile_number || "", ~r/[^\d]/, "")
                clean_whatsapp = String.replace(whatsapp_number || "", ~r/[^\d]/, "")

                # Map role
                mapped_role = case String.trim(role || "") do
                  "MukhyaShishak" -> "MukhyaShishak"
                  "Karyavha" -> "Karyavha"
                  "Gatnayak" -> "Gatnayak"
                  _ -> "Swayamsevak"
                end

                # Map attendance type
                mapped_attendance = case String.trim(attendance_type || "") do
                  "Daily" -> "Daily"
                  "Weekends" -> "Weekends"
                  _ -> nil
                end

                # Map shakha
                shakha_name = String.trim(shakha_name || "")
                shakha_id = if shakha_name != "" do
                  case ShakhaNow.Repo.get_by(ShakhaNow.Organizations.Shakha, name: shakha_name, user_id: scope.user.id) do
                    nil -> nil
                    shakha -> shakha.id
                  end
                else
                  nil
                end

                # Generate dummy email if blank since it's required
                email_str = String.trim(email || "")
                final_email = if email_str == "", do: "user#{:os.system_time(:millisecond)}#{acc}@example.com", else: email_str

                %{
                  "full_name" => String.trim(full_name || ""),
                  "role" => mapped_role,
                  "attendance_type" => mapped_attendance,
                  "email" => final_email,
                  "mobile_number" => clean_mobile,
                  "whatsapp_number" => clean_whatsapp,
                  "date_of_birth" => parse_dob(dob || ""),
                  "photo_path" => String.trim(photo || ""),
                  "area" => area,
                  "city" => city,
                  "pincode" => pincode,
                  "occupation" => String.trim(occupation || ""),
                  "education" => String.trim(education || ""),
                  "shakha_id" => shakha_id
                }

              _ ->
                require Logger
                Logger.warning("Failed to match CSV row: #{inspect(padded_row)}")
                %{}
            end

          if map_size(attrs) > 0 and Map.get(attrs, "mobile_number", "") != "" do
            existing = ShakhaNow.Repo.get_by(ShakhaNow.Members.Swayamsevak, mobile_number: attrs["mobile_number"], user_id: scope.user.id)
            
            result = 
              if existing do
                Members.update_swayamsevak(scope, existing, attrs)
              else
                Members.create_swayamsevak(scope, attrs)
              end
              
            case result do
              {:ok, _} -> acc + 1
              {:error, changeset} -> 
                require Logger
                Logger.error("Failed to save CSV row. Attrs: #{inspect(attrs)}, Errors: #{inspect(changeset.errors)}")
                acc
            end
          else
            if map_size(attrs) > 0 do
              require Logger
              Logger.warning("Skipping CSV row due to missing mobile number: #{inspect(attrs)}")
            end
            acc
          end
        end)
        
      {:ok, count}
    rescue
      e -> 
        require Logger
        Logger.error("CSV processing error: #{inspect(e)}")
        {:error, "Invalid CSV format or data"}
    end
  end

  defp parse_dob(dob_str) when is_binary(dob_str) do
    # Handle DD/MM/YYYY or DD-MM-YYYY formats
    separator = if String.contains?(dob_str, "/"), do: "/", else: "-"
    
    case String.split(dob_str, separator) do
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
