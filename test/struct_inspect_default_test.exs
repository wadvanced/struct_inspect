defmodule StructInspectTest.Default do
  use ExUnit.Case
  doctest StructInspect

  alias StructInspectTest.Address
  alias StructInspectTest.BasicStruct

  describe "StructInspect with default options" do
    test "omits nil values" do
      data = %BasicStruct{bio: nil}
      refute inspect(data) =~ "bio:"
    end

    test "omits empty string values" do
      data = %BasicStruct{email: ""}
      refute inspect(data) =~ "email:"
    end

    test "omits empty list values" do
      data = %BasicStruct{roles: []}
      refute inspect(data) =~ "roles:"
    end

    test "ommits empty map values" do
      data = %BasicStruct{metadata: %{}}
      refute inspect(data) =~ "metadata:"
    end

    test "omits empty data values" do
      data = %BasicStruct{address: %Address{}}
      refute inspect(data) =~ "address:"
    end

    test "accepts false values" do
      data = %BasicStruct{is_active: false}
      assert inspect(data) =~ "is_active:"
    end

    test "accepts true values" do
      data = %BasicStruct{is_legacy: true}
      assert inspect(data) =~ "is_legacy:"
    end

    test "accepts zero integer values" do
      data = %BasicStruct{count: 0}
      assert inspect(data) =~ "count:"
    end

    test "accepts zero float values" do
      data = %BasicStruct{score: 0.0}
      assert inspect(data) =~ "score:"
    end

    test "keeps populated values" do
      data = %BasicStruct{name: "Gemini", bio: "AI"}
      assert inspect(data) =~ "name: \"Gemini\""
      assert inspect(data) =~ "bio: \"AI\""
    end
  end
end
