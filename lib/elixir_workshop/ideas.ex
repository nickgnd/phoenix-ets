defmodule ElixirWorkshop.Ideas do
  alias ElixirWorkshop.Ets
  alias ElixirWorkshop.Ideas.Idea

  @table_name :ideas

  def start() do
    {:ok, _pid} =
      GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Ets.create(@table_name)
  end

  @doc """
  Returns the list of ideas.
  """
  def list_ideas() do
    Ets.lookup_all(@table_name)
    |> Enum.map(fn ({id, data}) ->
      name = data |> elem(0)
      description = data |> elem(1)
      picture_url = data |> elem(2)

      struct!(Idea, %{id: id, name: name, description: description, picture_url: picture_url})
    end)
  end

  @doc """
  Gets a single idea.
  """
  def get_idea(key) do
    case Ets.lookup(@table_name, key) do
      {:ok, data} ->
        name = data |> elem(0)
        description = data |> elem(1)
        picture_url = data |> elem(2)
        struct!(Idea, %{id: key, name: name, description: description, picture_url: picture_url})

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
    data = [:name, :description, :picture_url] # Order matters
    |> Enum.map(&Map.get(idea, &1))
    |> List.to_tuple()

    case Ets.insert(@table_name, data) do
      {:ok, tuple} ->
        id = tuple |> elem(0)
        idea = struct!(Idea, attrs |> Map.merge(%{id: id}))
        {:ok, idea}

      {:error, term} -> {:error, term}
    end
  end

  @doc """
  Updates a idea.
  """
  def update_idea(%Idea{} = idea, attrs) do
    updated_idea = idea |> Map.merge(attrs)

    data = [:name, :description, :picture_url] # Order matters
    |> Enum.map(&Map.get(updated_idea, &1))
    |> List.to_tuple()

    case Ets.update(@table_name, updated_idea.id, data) do
      {:ok, _tuple} ->
        updated_idea = Map.merge(idea, attrs)
        {:ok, updated_idea}

      {:error, term} -> {:error, term}
    end
  end

  @doc """
  Deletes a Idea.
  """
  def delete_idea(%Idea{} = idea) do
    Ets.delete(@table_name, idea.id)
  end
end
