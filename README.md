# Kennel

A simple Elixir library for managing kennels and dogs. This library provides basic functionality for organizing and managing dog-related data.

## Installation

Add to application.ex:
```
translators = Application.fetch_env!(:logger, :translators)

:logger.add_primary_filter(
  :datadog_error_tracker_filter,
  {&Kennel.include_error_metadata/2, [translators: translators]}
)
```


The package can be installed by adding `kennel` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kennel, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
# Basic usage
iex> Kennel.include_error_metadata(:error, [])
:error
```

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/kennel>.

