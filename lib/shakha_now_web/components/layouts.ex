defmodule ShakhaNowWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use ShakhaNowWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <%= if @current_scope do %>
      <div class="drawer lg:drawer-open h-full">
        <input id="app-drawer" type="checkbox" class="drawer-toggle" />
        <div class="drawer-content flex flex-col h-full overflow-hidden">
          <!-- Mobile navbar -->
          <div class="navbar bg-base-100 lg:hidden shadow-sm">
            <div class="flex-none">
              <label for="app-drawer" aria-label="open sidebar" class="btn btn-square btn-ghost">
                <.icon name="hero-bars-3" class="size-6" />
              </label>
            </div>
            <div class="flex-1">
              <a class="btn btn-ghost text-xl">ShakhaNow</a>
            </div>
          </div>
          <!-- Page content -->
          <div class="flex-1 overflow-y-auto">
            <main class="p-4 sm:p-6 lg:p-8">
              <div class="mx-auto max-w-7xl">
                {render_slot(@inner_block)}
              </div>
            </main>
          </div>
        </div>
        <div class="drawer-side z-20 h-full border-r border-base-200">
          <label for="app-drawer" aria-label="close sidebar" class="drawer-overlay"></label>
          <ul class="menu p-4 w-64 min-h-full bg-base-100 text-base-content flex flex-col gap-2">
            <li><a class="text-2xl font-bold mb-4 hover:bg-transparent">ShakhaNow</a></li>
            <li>
              <.link navigate={~p"/dashboard"} class={["font-medium", active_tab?(assigns, ShakhaNowWeb.DashboardLive.Index) && "active bg-base-200"]}>
                <.icon name="hero-home" class="size-5" />
                Dashboard
              </.link>
            </li>
            <li>
              <.link navigate={~p"/shakhas"} class={["font-medium", active_tab?(assigns, [ShakhaNowWeb.ShakhaLive.Index, ShakhaNowWeb.ShakhaLive.Show, ShakhaNowWeb.ShakhaLive.Form]) && "active bg-base-200"]}>
                <.icon name="hero-building-office" class="size-5" />
                Shakhas
              </.link>
            </li>
            <li>
              <.link navigate={~p"/swayamsevaks"} class={["font-medium", active_tab?(assigns, [ShakhaNowWeb.SwayamsevakLive.Index, ShakhaNowWeb.SwayamsevakLive.Show, ShakhaNowWeb.SwayamsevakLive.Form]) && "active bg-base-200"]}>
                <.icon name="hero-user" class="size-5" />
                Swayamsevaks
              </.link>
            </li>
            <div class="flex-1"></div>
            <div class="divider my-0"></div>
            <li class="menu-title">{@current_scope.user.email}</li>
            <li>
              <.link navigate={~p"/users/settings"} class={["font-medium", active_tab?(assigns, ShakhaNowWeb.UserLive.Settings) && "active bg-base-200"]}>
                <.icon name="hero-cog-8-tooth" class="size-5" />
                Settings
              </.link>
            </li>
            <li>
              <.link href={~p"/users/log-out"} method="delete" class="text-error font-medium hover:bg-error/10 hover:text-error">
                <.icon name="hero-arrow-right-on-rectangle" class="size-5" />
                Log out
              </.link>
            </li>
          </ul>
        </div>
      </div>
    <% else %>
      <main class="p-4 sm:p-6 lg:p-8 flex-1">
        <div class="mx-auto max-w-7xl">
          {render_slot(@inner_block)}
        </div>
      </main>
    <% end %>

    <.flash_group flash={@flash} />
    """
  end

  defp active_tab?(assigns, expected_views) when is_list(expected_views) do
    view = assigns[:socket] && assigns.socket.view
    view in expected_views
  end

  defp active_tab?(assigns, expected_view) do
    active_tab?(assigns, [expected_view])
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
