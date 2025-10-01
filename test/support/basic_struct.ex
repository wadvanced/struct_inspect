defmodule StructInspectTest.BasicStruct do
  @moduledoc """
  A basic struct for testing purposes.
  """
  use StructInspect

  alias StructInspectTest.Address
  alias StructInspectTest.Helper

  require StructInspectTest.Helper

  Helper.create_struct()
end
