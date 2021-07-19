defmodule Router do
  use Plug.Router

  plug Corsica, origins: ["http://localhost:3000"]
  plug :match
  plug :dispatch

  get "/rooms" do
    send_resp(conn, 200, Jason.encode!(%{"rooms" => RoomSession.get_rooms}))
  end

end
