defmodule WadmClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :wadm_client,
      version: "0.1.0",
      elixir: "~> 1.17",
      description: "WadmClient is a library for working with Wasmcloud's WADM service via nats",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        "coveralls.json": :test,
        "coveralls.html": :test
      ],
      package: package(),
      dialyzer: dialyzer(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gnat, "~> 1.9.0"},
      {:yaml_elixir, "~> 2.11.0"},
      {:credo, "~> 1.7", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: :dev, runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14", only: :test, runtime: false}
    ]
  end

  defp dialyzer do
    [
      plt_file: {:no_warn, ".wadm_client.plt"},
      plt_add_apps: [:mix],
      ignore_warnings: ".dialyzer_ignore.exs"
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"Github" => "https://github.com/thomas9911/wadm-client-ex"}
    ]
  end
end
