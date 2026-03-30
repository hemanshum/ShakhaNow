defmodule ShakhaNow.Organizations do
  @moduledoc """
  The Organizations context.
  """

  import Ecto.Query, warn: false
  alias ShakhaNow.Repo

  alias ShakhaNow.Organizations.Shakha
  alias ShakhaNow.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any shakha changes.

  The broadcasted messages match the pattern:

    * {:created, %Shakha{}}
    * {:updated, %Shakha{}}
    * {:deleted, %Shakha{}}

  """
  def subscribe_shakhas(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(ShakhaNow.PubSub, "user:#{key}:shakhas")
  end

  defp broadcast_shakha(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(ShakhaNow.PubSub, "user:#{key}:shakhas", message)
  end

  @doc """
  Returns the list of shakhas.

  ## Examples

      iex> list_shakhas(scope)
      [%Shakha{}, ...]

  """
  def list_shakhas(%Scope{} = scope) do
    Repo.all_by(Shakha, user_id: scope.user.id)
  end

  @doc """
  Gets a single shakha.

  Raises `Ecto.NoResultsError` if the Shakha does not exist.

  ## Examples

      iex> get_shakha!(scope, 123)
      %Shakha{}

      iex> get_shakha!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_shakha!(%Scope{} = scope, id) do
    Repo.get_by!(Shakha, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a shakha.

  ## Examples

      iex> create_shakha(scope, %{field: value})
      {:ok, %Shakha{}}

      iex> create_shakha(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shakha(%Scope{} = scope, attrs) do
    with {:ok, shakha = %Shakha{}} <-
           %Shakha{}
           |> Shakha.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_shakha(scope, {:created, shakha})
      {:ok, shakha}
    end
  end

  @doc """
  Updates a shakha.

  ## Examples

      iex> update_shakha(scope, shakha, %{field: new_value})
      {:ok, %Shakha{}}

      iex> update_shakha(scope, shakha, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_shakha(%Scope{} = scope, %Shakha{} = shakha, attrs) do
    true = shakha.user_id == scope.user.id

    with {:ok, shakha = %Shakha{}} <-
           shakha
           |> Shakha.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_shakha(scope, {:updated, shakha})
      {:ok, shakha}
    end
  end

  @doc """
  Deletes a shakha.

  ## Examples

      iex> delete_shakha(scope, shakha)
      {:ok, %Shakha{}}

      iex> delete_shakha(scope, shakha)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shakha(%Scope{} = scope, %Shakha{} = shakha) do
    true = shakha.user_id == scope.user.id

    with {:ok, shakha = %Shakha{}} <-
           Repo.delete(shakha) do
      broadcast_shakha(scope, {:deleted, shakha})
      {:ok, shakha}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking shakha changes.

  ## Examples

      iex> change_shakha(scope, shakha)
      %Ecto.Changeset{data: %Shakha{}}

  """
  def change_shakha(%Scope{} = scope, %Shakha{} = shakha, attrs \\ %{}) do
    true = shakha.user_id == scope.user.id

    Shakha.changeset(shakha, attrs, scope)
  end
end
