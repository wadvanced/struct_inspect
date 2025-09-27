# Usage Guide

`StructInspect` is a powerful Elixir library for customizing how your structs are inspected. It helps you create cleaner, more readable output by omitting fields with "empty" or unwanted values. This is especially useful for large, complex structs.

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
-   `empty_struct` (default: `true`): Omits fields that contain an "empty" struct.
-   `empty_tuple` (default: `false`): Omits fields with an empty tuple (`{}`).
-   `true_value` (default: `false`): Omits fields with a boolean value of `true`.
-   `false_value` (default: `false`): Omits fields with a boolean value of `false`.

#### What is an "Empty Struct"?

A struct is considered "empty" if all of its values are the same as a newly created struct without setting any keys. In other words, if `struct == %SomeStruct{}`.

For example, consider this struct:

```elixir
defmodule Address do
  use StructInspect

  defstruct [:street, :city, :zip_code, po_box?: false]
end
```

If you create an `Address` struct like this, it is considered empty because all its fields are `nil`, which is the default value for fields in a struct:

```elixir
address = %Address{}
# %Address{}
# or
address = %Address{street: nil, city: nil, zip_code: nil}
```

And you have a `User` struct that contains this address:

```elixir
defmodule User do
  use StructInspect

  defstruct [:name, :address]
end

user = %User{name: "Gemini", address: address}
```

When you inspect the `user` struct, the `:address` field will be omitted because the `address` struct itself is considered empty.

```elixir
iex> user
%User{name: "Gemini"}
```

This is a powerful feature that helps to keep your logs and console output clean, especially when dealing with nested structs.

## Overriding Structs from Dependencies

Sometimes you may want to change the inspection behavior of a struct defined in one of your dependencies. `StructInspect` allows you to do this by creating an "override" module.

Let's say you have a dependency that defines a `ThirdParty.User` struct, and you want to customize its inspection. You can create a module in your own application to override it.

A good place for these overrides is in a file like `lib/struct_inspect_overrides.ex`.

```elixir
# In lib/struct_inspect_overrides.ex

defmodule ThirdParty.User do
  use StructInspect, false_value: true

  defstruct [:id, :name, :is_active]
end
```

### Handling Module Redefinition Warnings

When you override a module like this, the Elixir compiler will generate a warning:

```
warning: redefining module ThirdParty.User
```

This is expected because you are intentionally redefining a module that already exists. To suppress this warning, you can use the `@dialyzer {:nowarn_function, {:redefine_module, 1}}` attribute in your override module.

Here is the complete example of how to override a struct and suppress the warning:

```elixir
# In lib/struct_inspect_overrides.ex

defmodule ThirdParty.User do
  @dialyzer {:nowarn_function, {:redefine_module, 1}}
  use StructInspect, false_value: true

  defstruct [:id, :name, :is_active]
end
```

Now, whenever a `ThirdParty.User` struct is inspected anywhere in your application, it will use the options you've defined in your override module.
