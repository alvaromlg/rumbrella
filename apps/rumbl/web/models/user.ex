defmodule Rumbl.User do
  use Rumbl.Web, :model

  # DSL built with schema and field Elixir macros
  # :id automatic primary key like Django
  schema "users" do
    field :name, :string
    field :username, :string
    # virtual field for password
    # it's an intermediate field for password hash
    # virtual fields are not persisted to the database
    field :password, :string, virtual: true
    field :password_hash, :string
    has_many :videos, Rumbl.Video
    has_many :annotations, Rumbl.Annotation

    timestamps()
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(name username))
    |> validate_required([:name, :username])
    |> validate_length(:username, min: 1, max: 20)
    |> unique_constraint(:username)
  end

  def registration_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, ~w(password))
    |> validate_required([:password])
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end
