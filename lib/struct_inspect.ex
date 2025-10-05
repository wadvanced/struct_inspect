defmodule StructInspect do
  @moduledoc """
  Provides a mechanism to customize struct inspection by omitting fields with empty values.

  By `use`-ing `StructInspect` in your struct definition, it automatically implements the
  `Inspect` protocol for you, providing a more compact and readable representation of your
  structs, especially when they contain many optional or empty fields.

  ## Key Features

  - **Automatic `Inspect` Implementation**: Simplifies the process of custom struct inspection.
  - **Configurable Empty Values**: Allows customization of what is considered an "empty"
    value through application configuration.
  - **Clean and Readable Output**: Produces a cleaner inspection output by hiding noise from
    empty fields.
  - **Empty Structs**: A struct is considered empty if all its fields have the default
    values defined in its `defstruct`. This is particularly useful for nested structs that
    may be initialized with default values but are not considered "empty" by default.

  ## Examples

  First, you need to define a struct and `use StructInspect`:

  ```elixir
  defmodule MyStruct do
    @enforce_keys [:id]
    defstruct [:id, :name, :age, :data]
    use StructInspect
  end

  # Now, when you inspect instances of `MyStruct`, fields with empty values will be omitted:

  %MyStruct{id: 1, name: "John", age: nil, data: %{}}
  > %MyStruct{id: 1, name: "John"}
  ```

  You can also configure the default omitted values in your `config/config.exs`:

  ```elixir
  config :struct_inspect, :ommits, [:nil_value, :empty_string]
  ```
  """
  import Inspect.Algebra
  alias Inspect.Algebra

  @doc """
  Injects the necessary code to enable custom inspection for a struct.

  This macro sets up a `@before_compile` hook to generate the `Inspect` protocol
  implementation for the calling module. It also reads the default omitted values from the
  application environment.
  """
  @spec __using__(keyword()) :: Macro.t()
  defmacro __using__(opts \\ []) do
    quote do
      @struct_inspect_ommits unquote(opts)
      @before_compile StructInspect
    end
  end

  @doc """
  Generates the `Inspect` protocol implementation for the struct.

  This macro is called before the module is compiled and defines the `Inspect`
  implementation. The implementation delegates the actual inspection logic to the
  `inspect/4` function.
  """
  @spec __before_compile__(Macro.Env.t()) :: Macro.t()
  defmacro __before_compile__(env) do
    ommits = Module.get_attribute(env.module, :struct_inspect_ommits)

    quote do
      defimpl Inspect do
        def inspect(struct, opts) do
          StructInspect.inspect(struct, opts, unquote(ommits))
        end

        defdelegate inspect(map, name, infos, opts), to: StructInspect
      end
    end
  end

  @doc """
  Filters the struct fields and builds the inspection algebra.

  ## Parameters
  - `data` (map() | struct()) - The struct or map to be inspected.
  - `opts` (Inspect.Opts.t()) - The inspection options.
  - `ommits` (keyword()) - A list of atoms representing the types of empty values to omit.

  ## Returns
  Inspect.Algebra.t() - The algebra document representing the compacted struct.
  """
  @spec inspect(
          map() | struct(),
          Inspect.Opts.t(),
          list(atom()) | keyword() | StructInspect.Opts.t()
        ) :: Algebra.t()

  def inspect(map, opts, ommits) do
    ommits = ommits |> StructInspect.Opts.apply_to_defaults() |> Map.to_list()

    list =
      if Keyword.get(opts.custom_options, :sort_maps) do
        map |> Map.to_list() |> :lists.sort()
      else
        Map.to_list(map)
      end

    filtered_list = filter_empty_fields(list, ommits)

    fun =
      if Inspect.List.keyword?(list) do
        &Inspect.List.keyword/2
      else
        sep = color(" => ", :map, opts)
        &format_key_value(&1, &2, sep)
      end

    name = name(map)
    map_container_doc(filtered_list, name, opts, fun)
  end

  @doc """
  Builds the inspection algebra for a map.

  ## Parameters
  - `map` (map()) - The map to be inspected.
  - `name` (binary()) - The name of the map.
  - `infos` (list()) - A list of fields to be inspected.
  - `opts` (Inspect.Opts.t()) - The inspection options.

  ## Returns
  Inspect.Algebra.t() - The algebra document representing the compacted map.
  """
  @spec inspect(map(), binary(), list(), Inspect.Opts.t()) :: Algebra.t()
  def inspect(map, name, infos, opts) do
    fun = fn %{field: field}, opts -> Inspect.List.keyword({field, Map.get(map, field)}, opts) end
    map_container_doc(infos, name, opts, fun)
  end

  ## PRIVATE

  # Formats a key-value pair into an Inspect.Algebra document.
  @spec format_key_value(tuple(), Inspect.Opts.t(), binary()) :: Algebra.t()
  defp format_key_value({key, value}, opts, sep) do
    value_doc = to_doc(value, opts)

    key
    |> to_doc(opts)
    |> concat(sep)
    |> concat(value_doc)
  end

  @spec map_container_doc(list(), binary(), Inspect.Opts.t(), function()) :: Algebra.t()
  defp map_container_doc(list, name, opts, fun) do
    open = color("%" <> name <> "{", :map, opts)
    sep = color(",", :map, opts)
    close = color("}", :map, opts)
    container_doc(open, list, close, opts, fun, separator: sep, break: :strict)
  end

  # Returns the proper name for a map or a struct
  @spec name(map() | struct()) :: binary()
  defp name(%{__struct__: struct}),
    do: String.replace("#{struct}", "Elixir.", "")

  defp name(_map), do: ""

  # Filters the fields of a struct or map, removing those with empty values.
  @spec filter_empty_fields(list(), list() | struct()) :: list()
  defp filter_empty_fields(struct, ommits) when is_list(struct) do
    except =
      ommits
      |> Enum.find({:default, []}, &(elem(&1, 0) == :except))
      |> elem(1)

    Enum.reject(struct, &(reject_key(&1, except) or reject_field(&1, ommits)))
  end

  @spec reject_key(tuple(), list()) :: boolean()
  defp reject_key({key, _value}, except), do: Enum.member?(except, key)

  @spec reject_field(tuple(), list()) :: boolean()
  defp reject_field({_key, value}, ommits), do: Enum.any?(ommits, &empty_value?(value, &1))

  # Checks if a value is considered "empty" based on the given atom.
  @spec empty_value?(any(), tuple()) :: boolean()
  defp empty_value?(nil, {:nil_value, true}), do: true
  defp empty_value?(0, {:zero_integer_value, true}), do: true
  defp empty_value?(+0.0, {:zero_float_value, true}), do: true
  defp empty_value?("", {:empty_string, true}), do: true
  defp empty_value?([], {:empty_list, true}), do: true

  defp empty_value?(map, {:empty_map, true}) when is_non_struct_map(map) and map_size(map) == 0,
    do: true

  defp empty_value?(entity, {:empty_struct, true}) when is_struct(entity) do
    entity.__struct__
    |> struct()
    |> Kernel.==(entity)
  end

  defp empty_value?({}, {:empty_tuple, true}), do: true
  defp empty_value?(false, {:false_value, true}), do: true
  defp empty_value?(true, {:true_value, true}), do: true
  defp empty_value?(_value, _to_test), do: false
end
