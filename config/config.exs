import Config

if Mix.env() == :test do
  config :wadm_client,
    enable_testcontainers: System.get_env("ENABLE_TESTCONTAINERS", "true") == "true",
    nats_host: System.get_env("NATS_HOST", "127.0.0.1"),
    nats_port: System.get_env("NATS_PORT", "4222") |> String.to_integer()
end
