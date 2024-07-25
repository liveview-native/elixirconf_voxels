# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :elixirconf_voxels,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :elixirconf_voxels, ElixirconfVoxelsWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ElixirconfVoxelsWeb.ErrorHTML, json: ElixirconfVoxelsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ElixirconfVoxels.PubSub,
  live_view: [signing_salt: "v8O8DZ2j"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  elixirconf_voxels: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  elixirconf_voxels: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

config :live_view_native, plugins: [
  LiveViewNative.SwiftUI
]

config :mime, :types, %{
  "text/swiftui" => ["swiftui"],
  "text/styles" => ["styles"]
}

config :phoenix_template, :format_encoders, [
  swiftui: Phoenix.HTML.Engine
]

config :phoenix, :template_engines, [
  neex: LiveViewNative.Engine
]

config :live_view_native_stylesheet,
  content: [
    swiftui: [
      "lib/**/*swiftui*"
    ]
  ],
  output: "priv/static/assets"