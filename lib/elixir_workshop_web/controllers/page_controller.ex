defmodule ElixirWorkshopWeb.PageController do
  use ElixirWorkshopWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
