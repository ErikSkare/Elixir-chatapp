defmodule SocketHandler do
  defstruct [:username]

  @behaviour :cowboy_websocket

  @impl true
  def init(request, _state) do
    "username="<>username=request.qs
    initial_state = %__MODULE__{username: username}
    {:cowboy_websocket, request, initial_state}
  end

  @impl true
  def websocket_init(initial_state) do
    if initial_state.username in UserSession.get_users == false do
      UserSession.start_link(initial_state.username, self())
    else
      UserSession.set_ws(initial_state.username, self())
    end
    {:ok, initial_state}
  end

  @impl true
  def websocket_handle({:text, json_str}, state) do
    case decode(json_str) do
      %{"cmd" => "join-room", "room_name" => room_name} -> UserSession.join_room(state.username, room_name)
      %{"cmd" => "leave-room"} -> UserSession.leave_room(state.username)
      %{"cmd" => "send-message", "message" => message} -> UserSession.send_message(state.username, message)
    end
    {:ok, state}
  end

  @impl true
  def websocket_info(json, state) do
    {:reply, {:text, encode(json)}, state}
  end

  defp decode(json_str), do: Jason.decode!(json_str)
  defp encode(json), do: Jason.encode!(json)
end
