defmodule ShakhaNowWeb.PageController do
  use ShakhaNowWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
