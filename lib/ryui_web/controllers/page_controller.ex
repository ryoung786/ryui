defmodule RyuiWeb.PageController do
  use RyuiWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
