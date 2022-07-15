defmodule CoseDellaVitaEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :case_della_vita_ex,
      version: "0.0.0+development",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      description: """
      Library with helper modules for developing an API with Absinthe.
      """,
      package: [
        licenses: ["apache-2.0"],
        links: %{github: "https://github.com/weareyipyip/CoseDellaVitaEx"},
        source_url: "https://github.com/weareyipyip/CoseDellaVitaEx"
      ],
      source_url: "https://github.com/weareyipyip/CoseDellaVitaEx",
      name: "CoseDellaVitaEx",
      docs: [
        source_ref: "main",
        extras: ["./README.md"],
        main: "readme"
      ]
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
      {:ex_doc, "~> 0.21", only: [:dev, :test], runtime: false},
      {:absinthe, "~> 1.0"},
      {:ecto, "~> 3.0"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
