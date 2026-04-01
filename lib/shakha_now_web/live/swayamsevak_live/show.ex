defmodule ShakhaNowWeb.SwayamsevakLive.Show do
  use ShakhaNowWeb, :live_view

  alias ShakhaNow.Members

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Swayamsevak {@swayamsevak.id}
        <:subtitle>This is a swayamsevak record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/swayamsevaks"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/swayamsevaks/#{@swayamsevak}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit swayamsevak
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Full name">{@swayamsevak.full_name}</:item>
        <:item title="Mobile number">{@swayamsevak.mobile_number}</:item>
        <:item title="Whatsapp number">{@swayamsevak.whatsapp_number}</:item>
        <:item title="Date of birth">{@swayamsevak.date_of_birth}</:item>
        <:item title="Photo path">{@swayamsevak.photo_path}</:item>
        <:item title="Area">{@swayamsevak.area}</:item>
        <:item title="City">{@swayamsevak.city}</:item>
        <:item title="Pincode">{@swayamsevak.pincode}</:item>
        <:item title="Occupation">{@swayamsevak.occupation}</:item>
        <:item title="Education">{@swayamsevak.education}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Swayamsevak")
     |> assign(:swayamsevak, Members.get_swayamsevak!(socket.assigns.current_scope, id))}
  end
end
