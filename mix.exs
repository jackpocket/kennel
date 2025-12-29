defmodule Kennel.MixProject do
  use Mix.Project

  @version "0.1.3"
  @source_url "https://github.com/jackpocket/kennel"

  def project do
    [
      app: :kennel,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs()
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
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Prepares error messages for logging with Datadog."
  end

  defp package() do
    [
      name: "kennel",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jackpocket/kennel"},
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Todd Resudek", "Rudolph Manusadzhian"]
    ]
  end

  defp docs() do
    [
      extras: [
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "Kennel",
      logo: "logo.png",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end
end
