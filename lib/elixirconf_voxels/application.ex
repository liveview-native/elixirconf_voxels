defmodule ElixirconfVoxels.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ElixirconfVoxelsWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:elixirconf_voxels, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ElixirconfVoxels.PubSub},
      # Start a worker by calling: ElixirconfVoxels.Worker.start_link(arg)
      # {ElixirconfVoxels.Worker, arg},
      # Start to serve requests, typically the last entry
      ElixirconfVoxelsWeb.Endpoint,
      ElixirconfVoxels.World,
      ElixirconfVoxelsWeb.Presence
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirconfVoxels.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ElixirconfVoxelsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
