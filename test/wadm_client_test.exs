defmodule WadmClientTest do
  use ExUnit.Case
  doctest WadmClient

  @simple_manifest YamlElixir.read_from_file!("test/fixture/simple.yaml")

  defp start_container(config) do
    {:ok, container} = Testcontainers.start_container(config)
    ExUnit.Callbacks.on_exit(fn -> Testcontainers.stop_container(container.container_id) end)
    container
  end

  setup_all do
    address = Application.get_env(:wadm_client, :nats_host, "127.0.0.1")
    port = Application.get_env(:wadm_client, :nats_port, 4222)

    if Application.get_env(:wadm_client, :enable_testcontainers) do
      start_container(
        Testcontainers.Container.new("nats:2.10-alpine")
        |> Testcontainers.Container.with_cmd(["-js"])
        |> Testcontainers.Container.with_exposed_port(4222)
        |> Testcontainers.Container.with_waiting_strategy(
          Testcontainers.LogWaitStrategy.new(~r"Listening for client connections")
        )
        |> Testcontainers.Container.with_network_mode("host")
      )

      start_container(
        Testcontainers.Container.new("wasmcloud/wasmcloud:1.7.1-wolfi")
        |> Testcontainers.Container.with_environment("WASMCLOUD_RPC_HOST", address)
        |> Testcontainers.Container.with_environment("WASMCLOUD_RPC_PORT", "#{port}")
        |> Testcontainers.Container.with_environment("WASMCLOUD_CTL_HOST", address)
        |> Testcontainers.Container.with_environment("WASMCLOUD_CTL_PORT", "#{port}")
        |> Testcontainers.Container.with_network_mode("host")
        |> Testcontainers.Container.with_waiting_strategy(
          Testcontainers.LogWaitStrategy.new(~r"wasmCloud host started")
        )
      )

      start_container(
        Testcontainers.Container.new("ghcr.io/wasmcloud/wadm:0.21.0-wolfi")
        |> Testcontainers.Container.with_environment("WADM_NATS_SERVER", "#{address}:#{port}")
        |> Testcontainers.Container.with_network_mode("host")
      )
    end

    {:ok, gnat} = Gnat.start_link(%{host: address, port: port, no_responders: true})

    on_exit(fn ->
      Gnat.stop(gnat)
    end)

    conn = WadmClient.from_gnat(gnat, "default", nil)

    wait_until_ready(conn)

    {:ok, %{conn: conn}}
  end

  test "works", %{conn: conn} do
    app_name = "hello-simple"
    assert {:ok, []} = WadmClient.list_manifests(conn)
    assert {:ok, %{"result" => "created"}} = WadmClient.put_manifest(conn, @simple_manifest)

    assert {:ok, [%{"name" => ^app_name, "status" => "undeployed"}]} =
             WadmClient.list_manifests(conn)

    assert {:ok, %{"result" => "acknowledged"}} = WadmClient.deploy_manifest(conn, app_name)
    assert {:ok, %{"manifest" => @simple_manifest}} = WadmClient.get_manifest(conn, app_name)

    assert {:ok,
            %{
              "result" => "success",
              "versions" => [%{"deployed" => true, "version" => _}]
            }} = WadmClient.list_versions(conn, app_name)

    assert :ok = wait_until_deployed(conn, app_name)
    assert {:ok, _} = WadmClient.undeploy_manifest(conn, app_name)
    assert {:ok, _} = WadmClient.delete_manifest(conn, app_name)

    assert {:ok, []} = WadmClient.list_manifests(conn)
  end

  test "invalid manifest", %{conn: conn} do
    assert {:error, %{}} = WadmClient.put_manifest(conn, %{"name" => "test"})
  end

  defp wait_until_ready(conn) do
    # there is some weirdness that there are no_responders, just try until there are.
    0..100
    |> Enum.reduce_while(:error, fn _, _ ->
      case WadmClient.list_manifests(conn) do
        {:ok, _} -> {:halt, :ok}
        {:error, _} -> {:cont, :error}
      end
    end)
  end

  defp wait_until_deployed(conn, name) do
    0..100
    |> Enum.reduce_while(:error, fn _, _ ->
      case WadmClient.get_manifest_status(conn, name) do
        {:ok, %{"status" => %{"status" => %{"type" => status}}}}
        when status in ["undeployed", "reconciling"] ->
          Process.sleep(1000)
          {:cont, :error}

        {:ok, %{"status" => %{"status" => %{"type" => "deployed"}}}} ->
          {:halt, :ok}

        error ->
          {:halt, error}
      end
    end)
  end
end
