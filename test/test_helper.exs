if Application.get_env(:wadm_client, :enable_testcontainers) do
  Testcontainers.start_link()
end

ExUnit.start()
