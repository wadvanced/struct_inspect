# For overriding structs by config
Application.put_env(:struct_inspect, :overrides, [StructInspectTest.OverridableStruct])

ExUnit.start()
