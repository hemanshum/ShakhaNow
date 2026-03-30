defmodule ShakhaNow.Repo do
  use Ecto.Repo,
    otp_app: :shakha_now,
    adapter: Ecto.Adapters.Postgres
end
