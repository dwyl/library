# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :library,
  ecto_repos: [Library.Repo]

# Configures the endpoint
config :library, LibraryWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "k9N76KJ2NDp1pig5CqD2w2DRBgcSMbt7fLSAOm+qpzziYjOsc8R7ACXU1PzrxTVt",
  render_errors: [view: LibraryWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Library.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :pre_commit, commands: ["test", "credo --strict"]

config :elixir_auth_github,
  client_id: System.get_env("CLIENT_ID"),
  client_secret: System.get_env("CLIENT_SECRET")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
