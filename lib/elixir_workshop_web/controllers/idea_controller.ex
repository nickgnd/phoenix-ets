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
    attributes = set_idea_attributes(params)

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
    attributes = set_idea_attributes(params)

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

  defp set_idea_attributes(params) do
    params
    |> atomify_map()
    |> Map.delete(:picture)
    |> set_picture_url(params["picture"])
  end

  defp atomify_map(map) do
    Map.new(map, fn {k, v} -> {String.to_atom(k), v} end)
  end

  defp set_picture_url(attributes, nil), do: attributes

  defp set_picture_url(attributes, picture_params) do
    picture_url = store_picture(picture_params)
    Map.put(attributes, :picture_url, picture_url)
  end

  defp store_picture(%{filename: filename, path: path}) do
    File.mkdir_p("priv/static/uploads")
    File.cp(path, Path.expand("priv/static/uploads/#{filename}"))
    "uploads/" <> filename
  end
end
