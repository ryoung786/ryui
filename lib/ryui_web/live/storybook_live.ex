defmodule RyuiWeb.StorybookLive do
  use RyuiWeb, :live_view

  import Ryui

  def search_fn(q) do
    params = URI.encode_query(%{search: q})

    for x <- Req.get!("https://swapi.dev/api/people/?#{params}").body["results"] do
      {x["name"], x["name"]}
    end
  end
end
