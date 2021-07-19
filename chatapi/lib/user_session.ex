defmodule UserSession do
  defstruct [:username, :socket_pid, :current_room_name]

  use GenServer

  # -- CLIENT SIDE --
  @impl true
  def init(initial_state) do
    {:ok, initial_state}
  end

  def start_link(username, socket_pid) do
    initial_state = %__MODULE__{username: username, socket_pid: socket_pid}
    GenServer.start_link(__MODULE__, initial_state, name: via(username))
  end

  def join_room(username, room_name), do: cast(username, {:join_room, room_name})
  def leave_room(username), do: cast(username, :leave_room)
  def send_message(username, message), do: cast(username, {:send_message, message})

  def send_ws(username, json), do: cast(username, {:send_ws, json})
  def set_ws(username, pid), do: cast(username, {:set_ws, pid})

  def view_state(username), do: call(username, :view_state)

  def get_users, do: Registry.select(Registry.UserSession, [{{:"$1", :_, :_}, [], [:"$1"]}])

  # -- SERVER SIDE --
  @impl true
  def handle_cast({:join_room, room_name}, state) do
    if room_name in RoomSession.get_rooms do RoomSession.add_user(room_name, state.username)
    else RoomSession.start_link(room_name, state.username) end
    {:noreply, %__MODULE__{state | current_room_name: room_name}}
  end

  @impl true
  def handle_cast(:leave_room, state) do
    if state.current_room_name != nil, do: RoomSession.remove_user(state.current_room_name, state.username)
    {:noreply, %__MODULE__{ state | current_room_name: nil}}
  end

  @impl true
  def handle_cast({:send_message, message}, state) do
    json = %{"event" => "message-received", "from" => state.username, "message" => message}
    RoomSession.broadcast(state.current_room_name, state.username, json)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:set_ws, pid}, state) do
    if state.socket_pid != nil, do: Process.exit(state.socket_pid, :normal)
    {:noreply, %__MODULE__{state | socket_pid: pid}}
  end

  @impl true
  def handle_cast({:send_ws, json}, state) do
    send(state.socket_pid, json)
    {:noreply, state}
  end

  @impl true
  def handle_call(:view_state, _from, state) do
    {:reply, state, state}
  end

  # -- HELPER FUNCTIONS --
  defp call(username, params), do: GenServer.call(via(username), params)
  defp cast(username, params), do: GenServer.cast(via(username), params)
  defp via(username), do: {:via, Registry, {Registry.UserSession, username}}
end
