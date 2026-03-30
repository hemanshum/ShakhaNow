defmodule ShakhaNow.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ShakhaNowWeb.Telemetry,
      ShakhaNow.Repo,
      {DNSCluster, query: Application.get_env(:shakha_now, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ShakhaNow.PubSub},
      # Start a worker by calling: ShakhaNow.Worker.start_link(arg)
      # {ShakhaNow.Worker, arg},
      # Start to serve requests, typically the last entry
      ShakhaNowWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ShakhaNow.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ShakhaNowWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
