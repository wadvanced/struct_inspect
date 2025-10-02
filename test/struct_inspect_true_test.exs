defmodule StructInspectTest.True do
  @moduledoc """
  Tests the behavior of the `StructInspect` macro when specific `ommits` are set to `true`.
  """
  use ExUnit.Case

  alias StructInspectTest.Address
  alias StructInspectTest.Helper

  require StructInspectTest.Helper

  describe "StructInspect by different ommit variations set to true" do
    defmodule NilValue do
      use StructInspect, [:nil_value]
      Helper.create_struct()
    end

    test "test basic data without inspect for nil_value" do
      %NilValue{}
      |> tap(&refute inspect(&1) =~ "bio:")
      |> tap(&assert inspect(&1) =~ "name: \"Gemini\"")
      |> struct(%{name: nil, bio: "45"})
      |> tap(&assert inspect(&1) =~ "bio: \"45\"")
      |> tap(&refute inspect(&1) =~ "name:")
    end

    defmodule ZeroIntegerValue do
      use StructInspect, [:zero_integer_value]
      Helper.create_struct()
    end

    test "test basic data without inspect for zero_integer_value" do
      %ZeroIntegerValue{}
      |> tap(&refute inspect(&1) =~ "count:")
      |> tap(&assert inspect(&1) =~ "score: 0.0")
      |> struct(%{count: 1})
      |> tap(&assert inspect(&1) =~ "count: 1")
      |> tap(&assert inspect(&1) =~ "score: 0.0")
    end

    defmodule ZeroFloatValue do
      use StructInspect, [:zero_float_value]
      Helper.create_struct()
    end

    test "test basic data without inspect for zero_float_value" do
      %ZeroFloatValue{}
      |> tap(&refute inspect(&1) =~ "score:")
      |> tap(&assert inspect(&1) =~ "count: 0")
      |> struct(%{score: 4.2})
      |> tap(&assert inspect(&1) =~ "score: 4.2")
      |> tap(&assert inspect(&1) =~ "count: 0")
    end

    defmodule EmptyString do
      use StructInspect, [:empty_string]
      Helper.create_struct()
    end

    test "test basic data without inspect for empty_string" do
      %EmptyString{}
      |> tap(&refute inspect(&1) =~ "email:")
      |> tap(&assert inspect(&1) =~ "name: \"Gemini\"")
      |> struct(%{name: "", email: "user@wadvanced.com"})
      |> tap(&assert inspect(&1) =~ "email: \"user@wadvanced.com\"")
      |> tap(&refute inspect(&1) =~ "name:")
    end

    defmodule EmptyList do
      use StructInspect, [:empty_list]
      Helper.create_struct()
    end

    test "test basic data without inspect for empty_list" do
      %EmptyList{}
      |> tap(&refute inspect(&1) =~ "roles:")
      |> tap(&assert inspect(&1) =~ "metadata: %{}")
      |> struct(%{roles: ["accounting", "payroll-manager"]})
      |> tap(&assert inspect(&1) =~ "roles: [\"accounting\", \"payroll-manager\"]")
      |> tap(&assert inspect(&1) =~ "metadata: %{}")
    end

    defmodule EmptyMap do
      use StructInspect, [:empty_map]
      Helper.create_struct()
    end

    test "test basic data without inspect for empty_map" do
      %EmptyMap{}
      |> tap(&refute inspect(&1) =~ "metadata:")
      |> tap(&assert inspect(&1) =~ "roles: []")
      |> struct(%{metadata: %{pages: 10, state: "closed"}})
      |> tap(&assert inspect(&1) =~ "metadata: %{")
      |> tap(&assert inspect(&1) =~ "pages: 10")
      |> tap(&assert inspect(&1) =~ "state: \"closed\"")
      |> tap(&assert inspect(&1) =~ "roles: []")
    end

    defmodule EmptyStruct do
      use StructInspect, [:empty_struct]
      Helper.create_struct()
    end

    test "test basic data without inspect for empty_struct" do
      %EmptyStruct{}
      |> tap(&refute inspect(&1) =~ "address:")
      |> tap(&assert inspect(&1) =~ "metadata: %{}")
      |> struct(%{address: %Address{street: "Elm street"}})
      |> tap(&assert inspect(&1) =~ "address:")
      |> tap(&assert inspect(&1) =~ "Address{")
      |> tap(&assert inspect(&1) =~ "street: \"Elm street\"")
      |> tap(&assert inspect(&1) =~ "po_box?: false")
      |> tap(&assert inspect(&1) =~ "metadata: %{}")
    end

    defmodule EmptyTuple do
      use StructInspect, [:empty_tuple]
      Helper.create_struct()
    end

    test "test basic data without inspect for empty_tuple" do
      %EmptyTuple{metadata: {}}
      |> tap(&refute inspect(&1) =~ "metadata:")
      |> struct(%{metadata: {:ok, :tested}})
      |> tap(&assert inspect(&1) =~ "metadata: {:ok, :tested}")
    end

    defmodule TrueValue do
      use StructInspect, [:true_value]
      Helper.create_struct()
    end

    test "test basic data without inspect for true_value" do
      %TrueValue{metadata: {}}
      |> tap(&refute inspect(&1) =~ "is_legacy:")
      |> struct(%{is_legacy: false})
      |> tap(&assert inspect(&1) =~ "is_legacy: false")
    end

    defmodule FalseValue do
      use StructInspect, [:false_value]
      Helper.create_struct()
    end

    test "test basic data without inspect for false_value" do
      %FalseValue{metadata: {}}
      |> tap(&refute inspect(&1) =~ "is_active:")
      |> struct(%{is_active: true})
      |> tap(&assert inspect(&1) =~ "is_active: true")
    end
  end
end
