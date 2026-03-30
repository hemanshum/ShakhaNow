defmodule ShakhaNowWeb.UserLive.Login do
  use ShakhaNowWeb, :live_view

  alias ShakhaNow.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-screen bg-base-200 flex items-center justify-center -m-4 py-12 px-4 sm:px-6 lg:px-8">
        <div class="card w-full max-w-md bg-base-100 shadow-xl">
          <div class="card-body items-center text-center">
            <h2 class="card-title text-3xl font-extrabold mb-2">ShakhaNow</h2>
            <p class="text-base-content/70 mb-6">Log in to access your dashboard</p>
            
            <div class="w-full">
              <.form
                :let={f}
                for={@form}
                id="login_form"
                action={~p"/users/log-in"}
                phx-submit="submit_password"
                phx-trigger-action={@trigger_submit}
                class="flex flex-col gap-4"
              >
                <div class="form-control w-full text-left">
                  <.input
                    field={f[:email]}
                    type="email"
                    label="Email"
                    required
                    class="input input-bordered w-full"
                    phx-mounted={JS.focus()}
                  />
                </div>
                
                <div class="form-control w-full text-left">
                  <.input 
                    field={f[:password]} 
                    type="password" 
                    label="Password" 
                    required 
                    class="input input-bordered w-full" 
                  />
                </div>

                <div class="flex items-center justify-between w-full mt-2">
                  <label class="label cursor-pointer gap-2 justify-start">
                    <.input field={f[:remember_me]} type="checkbox" class="checkbox checkbox-primary" />
                    <span class="label-text">Keep me logged in</span>
                  </label>
                </div>
                
                <div class="form-control w-full mt-4">
                  <button type="submit" class="btn btn-primary w-full">
                    Log in <span aria-hidden="true">→</span>
                  </button>
                </div>
              </.form>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  @impl true
  def handle_event("submit_password", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end

  def handle_event("submit_magic", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_login_instructions(
        user,
        &url(~p"/users/log-in/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions for logging in shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> push_navigate(to: ~p"/users/log-in")}
  end
end
