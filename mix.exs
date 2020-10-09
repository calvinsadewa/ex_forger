defmodule ExForger.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_forger,
      version: "0.1.1",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      name: "ExForger",
      description: "Easy & Customizable Ecto data forger",
      source_url: "https://github.com/calvinsadewa/ex_forger",
      homepage_url: "https://github.com/calvinsadewa/ex_forger",
      package: [
        licenses: ["GPL-3"],
        links: %{"GitHub" => "https://github.com/calvinsadewa/ex_forger",},
      ],
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.0"},
      {:mimic, "~> 1.3", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
