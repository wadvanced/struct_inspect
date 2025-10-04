# StructInspect
<script>
  import version from "./VERSION.md"
</script>  

[![CI](https://github.com/[your-username]/struct_inspect/actions/workflows/ci.yml/badge.svg)](https://github.com/[your-username]/struct_inspect/actions/workflows/ci.yml)
[![Hex.pm](https://img.shields.io/hexpm/v/struct_inspect.svg)](https://hex.pm/packages/struct_inspect)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/struct_inspect)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/hexpm/v/struct_inspect.svg)](https://hex.pm/packages/struct_inspect)

`StructInspect` is a highly configurable library to customize struct inspection in Elixir. It allows you to omit fields with "empty" values, producing cleaner and more readable output, especially for complex structs.

For a more detailed guide with advanced usage examples, please see the [Usage Guide](guides/usage.md).

## Installation

The package can be installed by adding `struct_inspect` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:struct_inspect, "~> 0.1.3"}
  ]
end
```

## Usage

To use `StructInspect`, you just need to `use StructInspect` in your struct definition.

```elixir
defmodule MyStruct do
  use StructInspect

  defstruct [:id, :name, :bio, :email]
end
```

By default, `StructInspect` will omit fields with `nil` values, empty strings, empty lists, and empty structs.

```elixir
iex> struct = %MyStruct{id: 1, name: "Gemini", bio: nil, email: ""}
%MyStruct{id: 1, name: "Gemini"}
```

## Configuration

The behavior of `StructInspect` is determined by a set of options that can be provided at different levels. The core of the configuration is the `StructInspect.Opts` module, which defines all the available options and their default values. Please refer to the `StructInspect.Opts` module documentation for the most up-to-date list of defaults.

You can customize the inspection behavior on a per-struct basis by passing options to the `use StructInspect` macro. You can pass a map, a keyword list, or a list of atoms.

For example, if you want to also omit fields with `false` values, you can do:

```elixir
defmodule MyConfiguredStruct do
  use StructInspect, false_value: true

  defstruct [:id, :name, :is_active]
end
```

```elixir
iex> struct = %MyConfiguredStruct{id: 1, name: "Gemini", is_active: false}
%MyConfiguredStruct{id: 1, name: "Gemini"}
```

When a list of atoms is provided, ONLY the named keys will be set to `true` and the rest to `false`, overriding all the defaults.

```elixir
defmodule MyOtherStruct do
  use StructInspect, [:false_value, :true_value]

  defstruct [:id, :name, :is_active, :is_legacy]
end
```

### Application-wide Configuration

You can also configure the default options for `StructInspect` application-wide in your `config/config.exs` file.

```elixir
# This setting will be merged to the defaults in `StructInspect.Opts`.
config :struct_inspect,
  ommits: [
    nil_value: true,
    empty_string: true,
    false_value: true
  ]
```

```elixir
# This setting will produce a `StructInspect.Opts` set with only nils, empty maps and zero integers enabled.
config :struct_inspect,
  ommits: [:nil_value, :empty_map, :zero_integer]
```

The options passed to `use StructInspect` will be merged with the application-wide configuration. The options passed directly to `use` have precedence.

### Available Options

The following options are available in `StructInspect.Opts`:

-   `nil_value`: Omits `nil` values. (default: `true`)
-   `zero_integer_value`: Omits `0`. (default: `false`)
-   `zero_float_value`: Omits `0.0`. (default: `false`)
-   `empty_string`: Omits `""`. (default: `true`)
-   `empty_list`: Omits `[]`. (default: `true`)
-   `empty_map`: Omits `%{}`. (default: `true`)
-   `empty_struct`: Omits empty structs. (default: `true`)
-   `empty_tuple`: Omits `{}`. (default: `true`)
-   `true_value`: Omits `true`. (default: `false`)
-   `false_value`: Omits `false`. (default: `false`)
-   `except`: List of keys to omits. (default: `[:__struct__]`)

## License

`StructInspect` is released under the MIT License. See the [LICENSE](LICENSE) file for more details.