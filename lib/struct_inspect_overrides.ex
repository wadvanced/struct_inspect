defmodule StructInspectOverrides do
  @moduledoc """
  Provides a mechanism to globally override the `Inspect` implementation for structs.

  This module allows you to configure `StructInspect` to take over the inspection of any
  struct, even for libraries or dependencies where you cannot add `use StructInspect`
  directly.

  The overrides are configured in your `config/config.exs` file.
  """
  @inspect_overrides Application.compile_env(:struct_inspect, :overrides, [])

  @doc """
  Generates `Inspect` implementations for the modules configured in the application environment.

  This macro reads the `:struct_inspect, :overrides` configuration and for each module,
  it generates a `defimpl Inspect` that uses `StructInspect.compact/4` for inspection.
  """
  @spec __using__(keyword()) :: Macro.t()
  defmacro __using__(_opts) do
    quoted_overrides =
      @inspect_overrides
      |> get_overrides()
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
      (unquote_splicing(quoted_overrides))
    end
  end

  ## PRIVATE

  # Parses the override configuration and returns a list of {module, ommits} tuples.
  @spec get_overrides(keyword()) :: [{module(), keyword()}]
  defp get_overrides(overrides) do
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
  defp reject_override({module, _attrs}), do: valid_module?(module)

  # Validates if a module is a valid override target.
  @spec valid_module?(module() | nil) :: boolean()
  defp valid_module?(nil), do: false
  defp valid_module?(StructInspect.Opts), do: false

  defp valid_module?(module) do
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

  You can `use EnableOverrides` in your application, for example in `application.ex`,
  to activate the global inspection overrides.
  """
  use StructInspectOverrides
end
