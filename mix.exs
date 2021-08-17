defmodule GeoJSON.Area.MixProject do
  use Mix.Project

  def project do
    [
      app: :geojson_area,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      preferred_cli_env: [
        docs: :docs,
        "hex.publish": :docs,
        dialyzer: :test
      ],
      package: package(),
      description: "Compute the area of GeoJSON geometries",
      dialyzer: dialyzer()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      maintainers: ["RESTAR Inc"],
      licenses: ["BSD-2-Clause"],
      links: %{"GitHub" => "https://github.com/RESTAR-inc/geojson_area"},
      files: ~w(lib mix.exs README.md LICENSE.md)
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.25.1", only: :docs, runtime: false},
      {:dialyxir, "~> 1.0", only: :test, runtime: false}
    ]
  end

  defp dialyzer do
    [
      plt_core_path: "priv/plts",
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end
end
