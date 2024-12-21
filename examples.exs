{:ok, gnat} = Gnat.start_link(%{host: "127.0.0.1", port: 4222})

# gnat
# |> WadmClient.from_gnat("default", nil)
# |> WadmClient.list_manifests()
# |> IO.inspect()


# gnat
# |> WadmClient.from_gnat("default", nil)
# |> WadmClient.get_manifest("bb-runtime-cloud", "v0.0.1")
# |> IO.inspect()

# gnat
# |> WadmClient.from_gnat("default", nil)
# |> WadmClient.list_versions("bb-runtime-cloud")
# |> IO.inspect()

# gnat
# |> WadmClient.from_gnat("default", nil)
# |> WadmClient.delete_manifest("bb-runtime-cloud", "v0.0.1")
# |> IO.inspect()

# gnat
# |> WadmClient.from_gnat("default", nil)
# |> WadmClient.deploy_manifest("bb-runtime-cloud", "v0.0.2")
# |> IO.inspect()

# gnat
# |> WadmClient.from_gnat("default", nil)
# |> WadmClient.undeploy_manifest("bb-runtime-cloud", "v0.0.2")
# |> IO.inspect()

# gnat
# |> WadmClient.from_gnat("default", nil)
# |> WadmClient.get_manifest_status("bb-runtime-cloud")
# |> IO.inspect()

# manifest = YamlElixir.read_from_file!("F:\\Rust\\wasmcloud\\runtime-cloud\\graphql-server\\local.wadm.yaml")
# updated = put_in(manifest, ["metadata", "annotations", "version"], "v0.0.3")

# gnat
# |> WadmClient.from_gnat("default", nil)
# |> WadmClient.put_manifest(updated)
# |> IO.inspect()

# gnat
# |> WadmClient.from_gnat("default", nil)
# |> WadmClient.list_versions("bb-runtime-cloud")
# |> IO.inspect()
