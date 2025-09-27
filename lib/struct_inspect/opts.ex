defmodule StructInspect.Opts do
  @moduledoc """
  Provides a struct to configure the behavior of `StructInspect`.
  """
  use StructInspect, [:false_value]

  @type t :: %__MODULE__{
          nil_value: boolean(),
          zero_integer_value: boolean(),
          zero_float_value: boolean(),
          empty_string: boolean(),
          empty_list: boolean(),
          empty_map: boolean(),
          empty_struct: boolean(),
          empty_tuple: boolean(),
          true_value: boolean(),
          false_value: boolean()
        }

  @type attributes :: t() | map() | keyword() | list(atom())

  defstruct nil_value: true,
            zero_integer_value: false,
            zero_float_value: false,
            empty_string: true,
            empty_list: true,
            empty_map: true,
            empty_struct: true,
            empty_tuple: false,
            true_value: false,
            false_value: false

  @struct_inspect_default_ommits Application.compile_env(:struct_inspect, :ommits, [])

  @doc """
  Creates a new `StructInspect.Opts` struct.

  It can receive:
  - A map or keyword list of ommits to override the default values.
  - A list of atoms. When a list of atoms is provided, ONLY the named keys will be set to true and the rest to false.
  - Another `StructInspect.Opts` struct, which will be returned as is.
  - Nothing, in which case it will return the default struct.

  ## Parameters
  - `ommits` (map() | keyword() | list(atom()) | t()) - The ommits to create the struct.

  ## Returns
  %StructInspect.Opts{} - A new `StructInspect.Opts` struct.
  """
  @spec new() :: t()
  def new(), do: struct(__MODULE__)

  @spec new(attributes()) :: t()
  def new(ommits), do: change(%__MODULE__{}, ommits)

  @spec change(t(), attributes()) :: t()
  def change(options, %__MODULE__{} = ommits), do: struct(options, ommits)
  def change(options, ommits) when is_map(ommits), do: options |> new() |> struct(ommits)

  def change(options, []), do: options

  def change(options, ommits) when is_list(ommits) do
    if Keyword.keyword?(ommits) do
      struct(options, ommits)
    else
      true_opts = Map.new(ommits, &{&1, true})

      options
      |> Map.keys()
      |> List.delete(:__struct__)
      |> Enum.map(&{&1, false})
      |> then(&struct(options, &1))
      |> struct(true_opts)
    end
  end

  @spec apply_to_defaults(attributes()) :: t()
  def apply_to_defaults(attrs \\ [])

  def apply_to_defaults(attrs) when is_struct(attrs),
    do: attrs |> Map.from_struct() |> apply_to_defaults()

  def apply_to_defaults(attrs), do: @struct_inspect_default_ommits |> new() |> change(attrs)
end
