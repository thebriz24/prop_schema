defmodule PropSchema.MixProject do
  use Mix.Project

  @version "1.0.4"

  def project do
    [
      app: :prop_schema,
      version: @version,
      elixir: ">= 1.5.0",
      elixirc_paths: ["lib", "test/support"],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      name: "PropSchema",
      package: package(),
      description: description(),
      aliases: aliases()
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
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},
      {:ecto, ">= 2.0.0"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:stream_data, "~> 0.4"}
    ]
  end

  def description do
    "An extension on `Ecto.Schema` where you can provide additional options, which will be read by the corresponding `PropSchema.TestHarness` module, used in the test files to generate property tests."
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/podium/prop_schema",
        "Docs" => "https://hexdocs.pm/prop_schema/#{@version}"
      },
      maintainers: ["Podium", "Brandon Bennett", "Kelsey Heidarian", "Rob Hughes"],
      source_url: "https://github.com/podium/prop_schema"
    ]
  end

  defp docs do
    [
      main: "PropSchema",
      logo: "misc/pink-p.png",
      extras: ["README.md"],
      groups_for_modules: [
        Generators: [PropSchema.Stream, PropSchema.TestHarness],
        Customizers: [PropSchema.AdditionalProperties, PropSchema.Modifications],
        Deprecated: [PropSchema.Executor]
      ]
    ]
  end

  defp aliases do
    [
      credo: ["credo --strict"]
    ]
  end
end
