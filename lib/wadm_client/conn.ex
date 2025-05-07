defmodule WadmClient.Conn do
  @moduledoc """
  struct wrapping a nats connection
  """
  defstruct [:conn, :lattice, :prefix]

  @type t :: %__MODULE__{
          conn: Gnat.t(),
          lattice: binary,
          prefix: binary
        }

  def new(conn, lattice, prefix) do
    %__MODULE__{conn: conn, lattice: lattice, prefix: prefix || "wadm.api"}
  end
end
