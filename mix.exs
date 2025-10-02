defmodule StructInspect.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :struct_inspect,
      mod: StructInspect.Overrides,
      version: @version,
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :test,
      deps: deps(),
      dialyzer: [
        plt_add_apps: [:eex, :mix]
      ],
      # Hex
      description: "Configurable library to customize struct inspection.",
      package: [
        name: "struct_inspect",
        maintainers: ["Federico Alcántara"],
        licenses: ["MIT"],
        links: %{
          "GitHub" => "https://github.com/wadvanced/struct_inspect"
        },
        files: ~w(.formatter.exs mix.exs README.md CHANGELOG.md lib)
      ],
      # Docs
      docs: [
        main: "readme",
        source_ref: "v#{@version}",
        source_url: "https://github.com/wadvanced/struct_inspect",
        extras: ["README.md", "guides/usage.md", "LICENSE"]
      ],
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support/"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      ## Dev dependencies
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:doctor, "~> 0.22", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.38", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      consistency: [
        "format",
        "compile --warnings-as-errors",
        "credo --strict",
        "dialyzer",
        "doctor"
      ]
    ]
  end
end
