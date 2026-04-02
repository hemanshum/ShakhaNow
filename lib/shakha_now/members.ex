defmodule ShakhaNow.Members do
  @moduledoc """
  The Members context.
  """

  import Ecto.Query, warn: false
  alias ShakhaNow.Repo

  alias ShakhaNow.Members.Swayamsevak
  alias ShakhaNow.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any swayamsevak changes.

  The broadcasted messages match the pattern:

    * {:created, %Swayamsevak{}}
    * {:updated, %Swayamsevak{}}
    * {:deleted, %Swayamsevak{}}

  """
  def subscribe_swayamsevaks(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(ShakhaNow.PubSub, "user:#{key}:swayamsevaks")
  end

  defp broadcast_swayamsevak(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(ShakhaNow.PubSub, "user:#{key}:swayamsevaks", message)
  end

  @doc """
  Returns the list of swayamsevaks.

  ## Examples

      iex> list_swayamsevaks(scope)
      [%Swayamsevak{}, ...]

  """
  def list_swayamsevaks(user_scope) do
    Swayamsevak
    |> where([s], s.user_id == ^user_scope.user.id)
    |> preload([:shakha, :shakhas_as_mukhya_shikshak, :shakhas_as_karyavah])
    |> Repo.all()
  end

  @doc """
  Returns the list of swayamsevaks for a given shakha.
  """
  def list_swayamsevaks_for_shakha(user_scope, shakha_id) do
    shakha_id = if is_binary(shakha_id), do: String.to_integer(shakha_id), else: shakha_id
    Swayamsevak
    |> where([s], s.user_id == ^user_scope.user.id and s.shakha_id == ^shakha_id)
    |> preload([:shakha, :shakhas_as_mukhya_shikshak, :shakhas_as_karyavah])
    |> Repo.all()
  end

  @doc """
  Gets a single swayamsevak.

  Raises `Ecto.NoResultsError` if the Swayamsevak does not exist.

  ## Examples

      iex> get_swayamsevak!(scope, 123)
      %Swayamsevak{}

      iex> get_swayamsevak!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_swayamsevak!(%Scope{} = scope, id) do
    Swayamsevak
    |> where([s], s.user_id == ^scope.user.id and s.id == ^id)
    |> preload([:shakha, :shakhas_as_mukhya_shikshak, :shakhas_as_karyavah])
    |> Repo.one!()
  end

  @doc """
  Creates a swayamsevak.

  ## Examples

      iex> create_swayamsevak(scope, %{field: value})
      {:ok, %Swayamsevak{}}

      iex> create_swayamsevak(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_swayamsevak(%Scope{} = scope, attrs) do
    with {:ok, swayamsevak = %Swayamsevak{}} <-
           %Swayamsevak{}
           |> Swayamsevak.changeset(attrs, scope)
           |> Repo.insert() do
      
      swayamsevak = Repo.preload(swayamsevak, [:shakha, :shakhas_as_mukhya_shikshak, :shakhas_as_karyavah])
      broadcast_swayamsevak(scope, {:created, swayamsevak})
      {:ok, swayamsevak}
    end
  end

  @doc """
  Updates a swayamsevak.

  ## Examples

      iex> update_swayamsevak(scope, swayamsevak, %{field: new_value})
      {:ok, %Swayamsevak{}}

      iex> update_swayamsevak(scope, swayamsevak, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_swayamsevak(%Scope{} = scope, %Swayamsevak{} = swayamsevak, attrs) do
    true = swayamsevak.user_id == scope.user.id

    with {:ok, swayamsevak = %Swayamsevak{}} <-
           swayamsevak
           |> Swayamsevak.changeset(attrs, scope)
           |> Repo.update() do
           
      swayamsevak = Repo.preload(swayamsevak, [:shakha, :shakhas_as_mukhya_shikshak, :shakhas_as_karyavah])
      broadcast_swayamsevak(scope, {:updated, swayamsevak})
      {:ok, swayamsevak}
    end
  end

  @doc """
  Deletes a swayamsevak.

  ## Examples

      iex> delete_swayamsevak(scope, swayamsevak)
      {:ok, %Swayamsevak{}}

      iex> delete_swayamsevak(scope, swayamsevak)
      {:error, %Ecto.Changeset{}}

  """
  def delete_swayamsevak(%Scope{} = scope, %Swayamsevak{} = swayamsevak) do
    true = swayamsevak.user_id == scope.user.id

    with {:ok, swayamsevak = %Swayamsevak{}} <-
           Repo.delete(swayamsevak) do
      broadcast_swayamsevak(scope, {:deleted, swayamsevak})
      {:ok, swayamsevak}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking swayamsevak changes.

  ## Examples

      iex> change_swayamsevak(scope, swayamsevak)
      %Ecto.Changeset{data: %Swayamsevak{}}

  """
  def change_swayamsevak(%Scope{} = scope, %Swayamsevak{} = swayamsevak, attrs \\ %{}) do
    true = swayamsevak.user_id == scope.user.id

    Swayamsevak.changeset(swayamsevak, attrs, scope)
  end
end
