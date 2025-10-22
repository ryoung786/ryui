defmodule RyuiWeb.Router do
  use RyuiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RyuiWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", RyuiWeb do
    pipe_through :browser

    live "/", StorybookLive, :home
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:ryui, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: RyuiWeb.Telemetry
    end
  end
end
