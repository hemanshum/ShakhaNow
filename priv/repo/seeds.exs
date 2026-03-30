# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ShakhaNow.Repo.insert!(%ShakhaNow.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ShakhaNow.Accounts
alias ShakhaNow.Repo

# Create default admin user
admin_email = "admin@shakhanow.com"
admin_password = "Abcd123456789"

case Accounts.get_user_by_email(admin_email) do
  nil ->
    {:ok, _user} = Accounts.register_user(%{
      email: admin_email,
      password: admin_password
    })
    IO.puts("Admin user created successfully.")
  
  _user ->
    IO.puts("Admin user already exists.")
end
