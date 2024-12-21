defmodule WadmClient.Conn do
  defstruct [:conn, :lattice, :prefix]

  def new(conn, lattice, prefix) do
    %__MODULE__{conn: conn, lattice: lattice, prefix: prefix || "wadm.api"}
  end
end
