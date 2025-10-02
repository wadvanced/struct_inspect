defmodule StructInspect.Overrides do
  @moduledoc """
  Provides a mechanism to globally override the `Inspect` implementation for structs.

  This module allows you to configure `StructInspect` to take over the inspection of any
  struct, even for libraries or dependencies where you cannot add `use StructInspect`
  directly.

  The overrides are configured in your `config/config.exs` file.
  """
  @inspect_ignore_compiler_warning Application.compile_env(
                                     :struct_inspect,
                                     :ignore_compiler_warning,
                                     false
                                   )

  @doc """
  Generates `Inspect` implementations for the modules configured in the application environment.

  This macro reads the `:struct_inspect, :overrides` configuration and for each module,
  it generates a `defimpl Inspect` that uses `StructInspect.compact/4` for inspection.
  """
  @spec __using__(keyword()) :: Macro.t()
  defmacro __using__(_opts) do
    quoted_compile_option =
      quote do
        Code.compiler_options(
          ignore_module_conflict: unquote(@inspect_ignore_compiler_warning),
          ignore_already_consolidated: unquote(@inspect_ignore_compiler_warning)
        )
      end

    quoted_overrides =
      :struct_inspect
      |> Application.get_env(:overrides, [])
      |> filter_overrides()
      |> Enum.map(fn {module, ommits} ->
        quote do
          defimpl Inspect, for: unquote(module) do
            def inspect(struct, opts) do
              StructInspect.compact(__MODULE__, struct, opts, unquote(Macro.escape(ommits)))
            end
          end
        end
      end)

    quote do
      unquote(quoted_compile_option)

      unquote(quoted_overrides)
    end
  end

  ## PRIVATE

  # Parses the override configuration and returns a list of {module, ommits} tuples.
  @spec filter_overrides([atom() | tuple()]) :: [{module(), keyword()}]
  defp filter_overrides(overrides) do
    overrides
    |> Enum.map(&override/1)
    |> Enum.reject(&reject_override/1)
  end

  # Normalizes an override entry into a {module, ommits} tuple.
  @spec override(atom() | {atom(), keyword()}) :: {module(), keyword()} | nil
  defp override(module) when is_atom(module), do: {module, StructInspect.Opts.new()}
  defp override({module, attrs}), do: {module, attrs}
  defp override(_value), do: nil

  # Rejects invalid override entries.
  @spec reject_override(nil | {module(), any()}) :: boolean()
  defp reject_override(nil), do: true

  defp reject_override({module, _attrs}),
    do: reject_module?(module)

  # Rejects non valid module override.
  # Allows any struct and Map
  @spec reject_module?(module() | nil) :: boolean()
  defp reject_module?(nil), do: true

  defp reject_module?(Map), do: false

  defp reject_module?(module) do
    with {:module, compiled_module} <- Code.ensure_compiled(module),
         true <- :struct |> compiled_module.__info__() |> is_nil() do
      true
    else
      _ -> false
    end
  end
end

defmodule EnableOverrides do
  @moduledoc """
  Enables the global `Inspect` overrides defined in the application configuration.
  """
  use StructInspect.Overrides
end
