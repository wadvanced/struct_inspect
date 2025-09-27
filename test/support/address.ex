defmodule StructInspectTest.Address do
  @moduledoc false
  use StructInspect
  defstruct [:street, :city, :zip_code, po_box?: false]
end
