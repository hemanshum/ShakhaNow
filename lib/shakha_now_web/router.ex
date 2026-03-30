defmodule ShakhaNowWeb.Router do
  use ShakhaNowWeb, :router

  import ShakhaNowWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ShakhaNowWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ShakhaNowWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{ShakhaNowWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/", UserLive.Login, :new
      live "/users/log-in", UserLive.Login, :new
    end
  end

  scope "/", ShakhaNowWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ShakhaNowWeb.UserAuth, :require_authenticated}] do
      live "/dashboard", UserLive.Settings, :edit
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", ShakhaNowWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{ShakhaNowWeb.UserAuth, :mount_current_scope}] do
      # Registration removed
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
