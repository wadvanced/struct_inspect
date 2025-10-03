defmodule StructInspectTest.Overrides do
  @moduledoc """
  Tests the override mechanism for `StructInspect`.
  """
  use ExUnit.Case

  alias StructInspectTest.OverridableStruct

  describe "StructInspect override test" do
    test "Check overrides" do
      %OverridableStruct{}
      |> tap(&assert inspect(&1) =~ "count:")
      |> tap(&assert inspect(&1) =~ "name: \"Gemini\"")
      |> tap(&refute inspect(&1) =~ "metadata:")
      |> tap(&refute inspect(&1) =~ "address:")
    end
  end
end
