defmodule StructInspectTest.BasicStruct do
  alias StructInspectTest.Address
  use StructInspect

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
