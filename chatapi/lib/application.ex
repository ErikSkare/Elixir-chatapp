defmodule Chatapi.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Registry.UserSession},
      {Registry, keys: :unique, name: Registry.RoomSession},
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Router,
        options: [
          port: 4001,
          dispatch: dispatch(),
          protocol_options: [idle_timeout: :infinity]
        ]
      )
    ]
    opts = [strategy: :one_for_one, name: Chatapi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    [
      {:_,
       [
         {"/socket", SocketHandler, []},
         {:_, Plug.Cowboy.Handler, {Router, []}}
       ]}
    ]
  end
end
