defmodule StructInspectTest.Helper do
  @moduledoc """
  Provides a helper macro for creating test structs.
  """

  @doc """
  Defines a struct with a standard set of fields for testing `StructInspect`.
  """
  @spec create_struct() :: Macro.t()
  defmacro create_struct do
    quote do
      alias StructInspectTest.Address

      defstruct [
        :id,
        name: "Gemini",
        bio: nil,
        email: "",
        roles: [],
        metadata: %{},
        address: %Address{},
        is_active: false,
        is_legacy: true,
        count: 0,
        score: 0.0
      ]
    end
  end
end
