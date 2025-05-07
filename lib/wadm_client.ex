defmodule WadmClient do
  @moduledoc """
  Documentation for `WadmClient`.
  """

  alias WadmClient.Conn

  @type success :: {:ok, map}
  @type error :: {:error, :timeout} | {:error, :no_responders}
  @type result :: success | error

  @spec from_gnat(Gnat.t(), binary, binary | nil) :: Conn.t()
  def from_gnat(gnat_connection, lattice, prefix) do
    Conn.new(gnat_connection, lattice, prefix)
  end

  @spec list_manifests(Conn.t()) :: result
  def list_manifests(conn) do
    conn.conn
    |> Gnat.request(model_list_topic(conn.lattice, conn.prefix), "")
    |> parse_response()
  end

  @spec put_manifest(Conn.t(), map) :: result
  def put_manifest(conn, manifest) do
    body = Jason.encode!(manifest)

    conn.conn
    |> Gnat.request(model_put_topic(conn.lattice, conn.prefix), body,
      headers: [{"Content-Type", "application/json"}]
    )
    |> parse_response()
  end

  @spec list_versions(Conn.t(), binary) :: result
  def list_versions(conn, manifest) do
    conn.conn
    |> Gnat.request(model_versions_topic(conn.lattice, conn.prefix, manifest), "")
    |> parse_response()
  end

  @spec get_manifest(Conn.t(), binary, binary | nil) :: result
  def get_manifest(conn, manifest, version \\ nil) do
    body = format_version(version)

    conn.conn
    |> Gnat.request(model_get_topic(conn.lattice, conn.prefix, manifest), body)
    |> parse_response()
  end

  @spec delete_manifest(Conn.t(), binary, binary | nil) :: result
  def delete_manifest(conn, manifest, version \\ nil) do
    body = format_version(version)

    conn.conn
    |> Gnat.request(model_delete_topic(conn.lattice, conn.prefix, manifest), body)
    |> parse_response()
  end

  @spec deploy_manifest(Conn.t(), binary, binary | nil) :: result
  def deploy_manifest(conn, manifest, version \\ nil) do
    body = format_version(version)

    conn.conn
    |> Gnat.request(model_deploy_topic(conn.lattice, conn.prefix, manifest), body)
    |> parse_response()
  end

  @spec undeploy_manifest(Conn.t(), binary, binary | nil) :: result
  def undeploy_manifest(conn, manifest, version \\ nil) do
    body = format_version(version)

    conn.conn
    |> Gnat.request(model_undeploy_topic(conn.lattice, conn.prefix, manifest), body)
    |> parse_response()
  end

  @spec get_manifest_status(Conn.t(), binary) :: result
  def get_manifest_status(conn, manifest) do
    conn.conn
    |> Gnat.request(model_status_topic(conn.lattice, conn.prefix, manifest), "")
    |> parse_response()
  end

  @spec parse_response({:ok, Gnat.message()} | {:error, :timeout} | {:error, :no_responders}) ::
          result
  defp parse_response({:ok, %{body: body}}) do
    {:ok, Jason.decode!(body)}
  end

  defp parse_response(other), do: other

  @spec format_version(binary | nil) :: binary
  defp format_version(nil), do: ""
  defp format_version(version), do: Jason.encode!(%{version: version})

  defp model_list_topic(lattice, prefix) do
    "#{model_prefix(lattice, prefix)}.list"
  end

  defp model_get_topic(lattice, prefix, model_name) do
    "#{model_prefix(lattice, prefix)}.get.#{model_name}"
  end

  defp model_put_topic(lattice, prefix) do
    "#{model_prefix(lattice, prefix)}.put"
  end

  defp model_delete_topic(lattice, prefix, model_name) do
    "#{model_prefix(lattice, prefix)}.del.#{model_name}"
  end

  defp model_deploy_topic(lattice, prefix, model_name) do
    "#{model_prefix(lattice, prefix)}.deploy.#{model_name}"
  end

  defp model_undeploy_topic(lattice, prefix, model_name) do
    "#{model_prefix(lattice, prefix)}.undeploy.#{model_name}"
  end

  defp model_versions_topic(lattice, prefix, model_name) do
    "#{model_prefix(lattice, prefix)}.versions.#{model_name}"
  end

  defp model_status_topic(lattice, prefix, model_name) do
    "#{model_prefix(lattice, prefix)}.status.#{model_name}"
  end

  defp model_prefix(lattice, prefix) do
    "#{prefix}.#{lattice}.model"
  end
end
