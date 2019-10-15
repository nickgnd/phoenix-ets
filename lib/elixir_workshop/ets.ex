defmodule ElixirWorkshop.Ets do
  @moduledoc """
  Ets interface
  """

  @spec create(atom) :: {:error, :ets_not_created} | {:ok, atom()}

  @doc """
  Creates a new table with the given name.
  The following options are used for the creation:
  - public: any process can read or write to the table.
  - named_table: the table is registered with a name which can then be used instead of the table identifier in subsequent operations.
  - set: the table is a set table (one key, one object, no order among objects).

  The function will return the tuple {:ok, table_name} if the creation succeed,
  otherwise {:error, :ets_not_created}.
  """
  def create(table_name) do
    {:ok, :ets.new(table_name, [:public, :named_table, :set])}
  rescue
    _e in ArgumentError ->
      {:error, :ets_not_created}
  end

  @spec lookup(atom, String.t()) :: :none | {:ok, map()}

  @doc """
  Retrives a tuple froma a table by its key.
  """
  def lookup(ets_table, key) do
    case :ets.lookup(ets_table, key) do
      [] -> :none
      [{_, data}] -> {:ok, Jason.decode!(data, keys: :atoms)}
    end
  end

  @spec lookup_all(atom) :: list

  @doc """
  Gets the all data from a table.
  """
  def lookup_all(ets_table) do
    :ets.foldl(
      fn {_id, data}, acc ->
        acc ++ [Jason.decode!(data, keys: :atoms)]
      end,
      [],
      ets_table
    )
  end

  @spec first_key(atom) :: :none | String.t()

  @doc """
  Returns the first key in the given table.
  """
  def first_key(ets_table) do
    case :ets.first(ets_table) do
      :"$end_of_table" -> :none
      key -> key
    end
  end

  @spec next_key(atom, String.t()) :: :none | String.t()

  @doc """
  Returns the next key, following the given key.
  """
  def next_key(ets_table, current_key) do
    case :ets.next(ets_table, current_key) do
      :"$end_of_table" -> :none
      key -> key
    end
  end

  @spec insert(atom, map) :: {:error, term} | {:ok, map}

  @doc """
  Inserts a new tuple into the given table with an auto-generated UUID as key.
  """
  def insert(ets_table, attrs) do
    id = SecureRandom.uuid()
    data = attrs |> Map.merge(%{id: id})
    encoded_data = data |> Jason.encode!()
    row = {id, encoded_data}

    if :ets.insert_new(ets_table, row) do
      {:ok, data}
    else
      {:error, :uuid_already_taken}
    end
  rescue
    _e in ArgumentError ->
      {:error, :not_inserted}
  end

  @spec update(atom, String.t(), map) :: {:error, :not_updated} | {:ok, map}

  @doc """
  Updates a tuple into the given table by its key.
  """
  def update(ets_table, key, data) do
    encoded_data = data |> Jason.encode!()
    row = {key, encoded_data}
    :ets.insert(ets_table, row)
    {:ok, data}
  rescue
    _e in ArgumentError ->
      {:error, :not_updated}
  end

  @spec delete(atom, String.t()) :: {:ok, String.t()}

  @doc """
  Deletes a tuple from a table by its key.
  """
  def delete(ets_table, key) do
    :ets.delete(ets_table, key)
    {:ok, key}
  end
end
