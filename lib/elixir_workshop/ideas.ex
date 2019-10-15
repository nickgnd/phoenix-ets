defmodule ElixirWorkshop.Ideas do
  alias ElixirWorkshop.Ets
  alias ElixirWorkshop.Ideas.Idea

  @table_name :ideas

  def start() do
    {:ok, _pid} = GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Ets.create(@table_name)
  end

  @doc """
  Returns the list of ideas.
  """
  def list_ideas() do
    Ets.lookup_all(@table_name)
    |> Enum.map(fn idea -> struct!(Idea, idea) end)
  end

  @doc """
  Gets a single idea.
  """
  def get_idea(key) do
    case Ets.lookup(@table_name, key) do
      {:ok, idea} -> struct!(Idea, idea)
      :none -> nil
    end
  end

  @doc """
  Gets a single idea. Raise an error if not found.
  """
  def get_idea!(key) do
    case get_idea(key) do
      nil -> raise "Not found"
      idea -> idea
    end
  end

  @doc """
  Creates a idea.
  """
  def create_idea(attrs \\ %{}) do
    idea = struct!(Idea, attrs)
    Ets.insert(@table_name, idea)
  end

  @doc """
  Updates a idea.
  """
  def update_idea(%Idea{} = idea, attrs) do
    updated_idea = idea |> Map.merge(attrs)
    Ets.update(@table_name, idea.id, updated_idea)
  end

  @doc """
  Deletes a Idea.
  """
  def delete_idea(%Idea{} = idea) do
    Ets.delete(@table_name, idea.id)
  end
end
