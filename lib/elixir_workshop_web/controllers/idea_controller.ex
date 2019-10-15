defmodule ElixirWorkshopWeb.IdeaController do
  use ElixirWorkshopWeb, :controller

  alias ElixirWorkshop.Ideas
  alias ElixirWorkshop.Ideas.Idea

  def index(conn, _params) do
    ideas = Ideas.list_ideas()
    render(conn, "index.html", ideas: ideas)
  end

  def new(conn, _params) do
    conn = merge_assigns(conn, action: :create)
    idea = %Idea{name: nil, description: nil, picture_url: nil}
    render(conn, "new.html", idea: idea)
  end

  def create(conn, %{"idea" => params}) do
    attributes = params |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)

    case Ideas.create_idea(attributes) do
      {:ok, idea} ->
        conn
        |> put_flash(:info, "Idea created successfully.")
        |> redirect(to: Routes.idea_path(conn, :show, idea.id))

      {:error, _term} ->
        render(conn, "new.html")
    end
  end

  def show(conn, %{"id" => id}) do
    idea = Ideas.get_idea!(id)
    render(conn, "show.html", idea: idea)
  end

  def edit(conn, %{"id" => id}) do
    conn = merge_assigns(conn, action: :update)
    idea = Ideas.get_idea!(id)
    render(conn, "edit.html", idea: idea)
  end

  def update(conn, %{"id" => id, "idea" => params}) do
    idea = Ideas.get_idea!(id)
    attributes = params |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)

    case Ideas.update_idea(idea, attributes) do
      {:ok, idea} ->
        conn
        |> put_flash(:info, "Idea updated successfully.")
        |> redirect(to: Routes.idea_path(conn, :show, idea))

      {:error, _term} ->
        render(conn, "edit.html", idea: idea)
    end
  end

  def delete(conn, %{"id" => id}) do
    idea = Ideas.get_idea!(id)
    {:ok, _id} = Ideas.delete_idea(idea)

    conn
    |> put_flash(:info, "Idea deleted successfully.")
    |> redirect(to: Routes.idea_path(conn, :index))
  end
end
