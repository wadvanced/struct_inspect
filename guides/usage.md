# Usage Guide

`StructInspect` provides a configurable implementation of the `Inspect` protocol for Elixir structs. It allows developers to define rules for omitting fields with specific values—such as `nil`, `""`, or `[]`—from the inspection output. This can result in a more concise representation of data structures, especially in logging and interactive sessions.

## Getting Started

To begin using `StructInspect`, add it to your list of dependencies in your `mix.exs` file:

```elixir
def deps do
  [
    {:struct_inspect, "~> 0.1.0"}
  ]
end
```

Then, run `mix deps.get` to fetch the new dependency.

## Basic Usage

The simplest way to use `StructInspect` is to `use` it in your struct definition.

```elixir
defmodule MyStruct do
  use StructInspect

  defstruct [:id, :name, :bio, :email]
end
```

By default, `StructInspect` will omit fields with `nil` values, empty strings (`""`), empty lists (`[]`), and empty structs (`%SomeStruct{}`).

Let's see it in action:

```elixir
iex> struct = %MyStruct{id: 1, name: "Gemini", bio: nil, email: ""}
%MyStruct{id: 1, name: "Gemini"}
```

As you can see, the `:bio` and `:email` fields are not present in the inspected output because their values are `nil` and `""` respectively.

## Configuration

`StructInspect` offers a flexible configuration system that allows you to tailor the inspection behavior to your specific needs. The configuration is managed by the `StructInspect.Opts` module, which defines all the available options and their default values.

You can configure `StructInspect` in three ways:

1.  **Per-Struct Configuration:** Directly in your struct module.
2.  **Application-wide Configuration:** Globally in your `config/config.exs` file.
3.  **Combination:** A mix of both, with per-struct configuration taking precedence.

### Per-Struct Configuration

You can customize the inspection behavior for a specific struct by passing options to the `use StructInspect` macro. You can provide these options as a map, a keyword list, or a list of atoms.

#### Using a Keyword List or Map

This is the most common way to configure a struct. You can override the default options by providing a keyword list or a map.

For example, to also omit fields with `false` values:

```elixir
defmodule MyConfiguredStruct do
  use StructInspect, false_value: true

  defstruct [:id, :name, :is_active]
end
```

Now, when a `MyConfiguredStruct` is inspected, fields with a value of `false` will be omitted:

```elixir
iex> struct = %MyConfiguredStruct{id: 1, name: "Gemini", is_active: false}
%MyConfiguredStruct{id: 1, name: "Gemini"}
```

#### Using a List of Atoms

When you provide a list of atoms, **only** the specified keys will be set to `true`, and all other options will be set to `false`, completely overriding the defaults.

```elixir
defmodule MyOtherStruct do
  use StructInspect, [:false_value, :true_value]

  defstruct [:id, :name, :is_active, :is_legacy]
end
```

In this case, only fields with `false` or `true` values will be omitted. All other "empty" values like `nil` or `""` will be shown.

### Application-wide Configuration

For consistent inspection behavior across your entire application, you can set default options in your `config/config.exs` file.

```elixir
# In your config/config.exs

# This setting will be merged with the defaults in `StructInspect.Opts`.
config :struct_inspect,
  ommits: [
    nil_value: true,
    empty_string: true,
    false_value: true
  ]
```

You can also provide a list of atoms to enable only specific options globally:

```elixir
# This setting will produce a `StructInspect.Opts` set with only nils, empty maps and zero integers enabled.
config :struct_inspect,
  ommits: [:nil_value, :empty_map, :zero_integer]
```

The options passed directly to `use StructInspect` in a module will be merged with the application-wide configuration, with the per-struct options taking precedence.

### Available Omissions

Here is a complete list of all the available omission options that you can use to configure `StructInspect`.

-   `nil_value` (default: `true`): Omits fields with a value of `nil`.
-   `zero_integer_value` (default: `true`): Omits fields with an integer value of `0`.
-   `zero_float_value` (default: `true`): Omits fields with a float value of `0.0`.
-   `empty_string` (default: `true`): Omits fields with an empty string value (`""`).
-   `empty_list` (default: `true`): Omits fields with an empty list (`[]`).
-   `empty_map` (default: `false`): Omits fields with an empty map (`%{}`).
-   `empty_struct` (default: `true`): Omits fields that contain an "empty" struct. See ['What is an "Empty Struct"?'](#what-is-an-empty-struct) below.
-   `empty_tuple` (default: `false`): Omits fields with an empty tuple (`{}`).
-   `true_value` (default: `false`): Omits fields with a boolean value of `true`.
-   `false_value` (default: `false`): Omits fields with a boolean value of `false`.

#### What is an "Empty Struct"?

A struct is considered "empty" if all of its values are the same as a newly created struct without setting any keys. In other words, if `struct == %SomeStruct{}`.

For example, consider this struct:

```elixir
defmodule Address do
  use StructInspect

  defstruct [:street, :city, zip_code: "00000-0000", po_box?: false]
end
```

If you create an `Address` struct like this, it is considered empty, because :street, :city are nil and the fields :zip_code and :po_box? contain theirs default values, therefore:

If you have a `User` struct that contains a address struct without changes:

```elixir
defmodule User do
  use StructInspect

  defstruct [:name, :address]
end

user = %User{name: "Gemini", address: %Address{}}
```

When you inspect the `user` struct, the `:address` field will be omitted because the `address` struct itself is considered empty.

```elixir
iex> user
%User{name: "Gemini"}
```

This helps to keep your logs and console output clean, especially when dealing with nested structs.

## Overriding Structs from Dependencies

`StructInspect` provides a clean way to customize the inspection of structs from your dependencies without altering their source code. This can be done by defining overrides in your configuration.

Let's take, for example, the `Phoenix.LiveView.Socket` struct, which is a notoriously large struct.

`Phoenix.LiveView.Socket` with default Inspect protocol implementation:

```elixir
iex(1)> %Phoenix.LiveView.Socket{}
#Phoenix.LiveView.Socket<
  id: nil,
  endpoint: nil,
  view: nil,
  parent_pid: nil,
  root_pid: nil,
  router: nil,
  assigns: %{__changed__: %{}},
  transport_pid: nil,
  sticky?: false,
  ...
>
```

### Configure the Overrides

In your `config/config.exs` file, add the `:overrides` configuration for `struct_inspect`. You can list the modules you want to override.

```elixir
# in config/config.exs
config :struct_inspect,
  overrides: [
    Phoenix.LiveView.Socket
  ]
```

Now with the override in place, here is the same output for Phoenix.LiveView.Socket struct:
```elixir
iex(1)> %Phoenix.LiveView.Socket{}
%Phoenix.LiveView.Socket{
  private: %{live_temp: %{}},
  assigns: %{__changed__: %{}},
  sticky?: false
}
```

By default, the configuration, will use the standard `StructInspect` options. If you want to specify, what type of contents are to be omitted, for a particular struct, you can use a tuple where the second element can be a keyword, list of atoms or a map, see the [Configuration](#configuration) section in this document for options configuration, for example:

```elixir
# in config/config.exs or test/config.exs
config :struct_inspect,
  overrides: [
    {Phoenix.LiveView.Socket, [nil_value: false, empty_struct: false]},
    Another.Module,
    {SpecialStruct, [:nil_value, :empty_string]}
  ]
```

In the example above, for `Phoenix.Live_View.Socket`, we are specifying that we are overriding the defaults by allowing nil values and empty struct to be outputted. `Another.Module` will take the StructInspect.Opts defaults, and SpecialStruct will only omit nil values and empty strings.

### Handling Compiler Warnings

When you use the `:overrides` configuration, the Elixir compiler will issue a warning for each module you are overriding, similar to this:

```
warning: redefining protocol implementation for Inspect for Phoenix.LiveView.Socket
```

This is expected. You are intentionally replacing the default `Inspect` implementation for that module with a custom one provided by `StructInspect`.

It is recommended to keep these warnings visible to be aware of the protocol overrides. However, once you have acknowledged them, you can suppress them by setting the `ignore_compiler_warning` option to `true` in your `config/config.exs`:

```elixir
# in config/config.exs
config :struct_inspect,
  ignore_compiler_warning: true
```

This will set the `ignore_module_conflict` and `ignore_already_consolidated` compiler options, effectively hiding the warnings for the protocol overrides.
