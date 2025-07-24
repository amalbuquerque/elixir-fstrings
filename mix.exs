defmodule FStrings.MixProject do
  use Mix.Project

  def project do
    [
      app: :f_strings,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "F-strings",
      source_url: "https://github.com/amalbuquerque/elixir-fstrings",
      homepage_url: "https://github.com/amalbuquerque/elixir-fstrings",
      docs: &docs/0
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
      {:ex_doc, "~> 0.38.2", only: :dev, runtime: false, warn_if_outdated: true}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      deps: [logger: "https://hexdocs.pm/logger"]
    ]
  end
end
