# Fixture to create a new backend user
# mix run priv/repo/backend_seeds.exs

alias Rumbl.Repo
alias Rumbl.User

Repo.insert!(%User{name: "Wolfram", username: "wolfram"})
