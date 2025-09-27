defmodule StructInspectTest do
  use ExUnit.Case
  doctest StructInspect

  alias StructInspectTest.BasicStruct
  alias StructInspectTest.Address

  describe "StructInspect with default options" do
    test "omits nil values" do
      struct = %BasicStruct{bio: nil}
      refute inspect(struct) =~ "bio:"
    end

    test "omits empty string values" do
      struct = %BasicStruct{email: ""}
      refute inspect(struct) =~ "email:"
    end

    test "omits empty list values" do
      struct = %BasicStruct{roles: []}
      refute inspect(struct) =~ "roles:"
    end

    test "ommits empty map values" do
      struct = %BasicStruct{metadata: %{}}
      refute inspect(struct) =~ "metadata:"
    end

    test "omits empty struct values" do
      struct = %BasicStruct{address: %Address{}}
      refute inspect(struct) =~ "address:"
    end

    test "accepts false values" do
      struct = %BasicStruct{is_active: false}
      assert inspect(struct) =~ "is_active:"
    end

    test "accepts true values" do
      struct = %BasicStruct{is_legacy: true}
      assert inspect(struct) =~ "is_legacy:"
    end

    test "accepts zero integer values" do
      struct = %BasicStruct{count: 0}
      assert inspect(struct) =~ "count:"
    end

    test "accepts zero float values" do
      struct = %BasicStruct{score: 0.0}
      assert inspect(struct) =~ "score:"
    end

    test "keeps populated values" do
      struct = %BasicStruct{name: "Gemini", bio: "AI"}
      assert inspect(struct) =~ "name: \"Gemini\""
      assert inspect(struct) =~ "bio: \"AI\""
    end
  end

  describe "StructInspect by different ommit variations" do
    test "test basic struct without inspect" do
      defimpl Inspect, for: StructInspect.BasicStruct do
        def inspect(struct, opts) do
          StructInspect.compact(__MODULE__, struct, opts, empty_struct: false)
        end
      end
    end
  end
end
