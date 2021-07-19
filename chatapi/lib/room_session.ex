defmodule RoomSession do
  defstruct [:room_name, :created_by, users: []]

  use GenServer

  # -- CLIENT SIDE --
  @impl true
  def init(initial_state) do
    ws_json = %{"event" => "new-room-created", "room_name" => initial_state.room_name}
    send = fn x ->
      if x != initial_state.created_by, do: UserSession.send_ws(x, ws_json)
    end
    Enum.each(UserSession.get_users, send)
    {:ok, initial_state}
  end

  def start_link(room_name, created_by) do
    initial_state = %__MODULE__{room_name: room_name, created_by: created_by, users: []}
    GenServer.start_link(__MODULE__, initial_state, name: via(room_name))
  end

  def add_user(room_name, username), do: cast(room_name, {:add_user, username})
  def remove_user(room_name, username), do: cast(room_name, {:remove_user, username})
  def broadcast(room_name, from_user, json), do: cast(room_name, {:broadcast, from_user, json})

  def view_state(room_name), do: call(room_name, :view_state)

  def get_rooms, do: Registry.select(Registry.RoomSession, [{{:"$1", :_, :_}, [], [:"$1"]}])

  # -- SERVER SIDE --
  @impl true
  def handle_cast({:add_user, username}, state) do
    if username in state.users == false do
      {:noreply, %__MODULE__{state | users: state.users ++ [username]}}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:remove_user, username}, state) do
    {:noreply, %__MODULE__{state | users: List.delete(state.users, username)}}
  end

  @impl true
  def handle_cast({:broadcast, from_user, json}, state) do
    send = fn x ->
      if x != from_user, do: UserSession.send_ws(x, json)
    end
    Enum.each(state.users, send)
    {:noreply, state}
  end

  @impl true
  def handle_call(:view_state, _from, state) do
    {:reply, state, state}
  end

  # -- HELPER FUNCTIONS --
  defp call(room_name, params), do: GenServer.call(via(room_name), params)
  defp cast(room_name, params), do: GenServer.cast(via(room_name), params)
  defp via(room_name), do: {:via, Registry, {Registry.RoomSession, room_name}}
end
