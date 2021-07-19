import {FormEvent, useEffect, useState} from "react";
import {useRouter} from "next/router";
import Link from "next/link";
import axios from "axios";
import Input from "../components/Input";
import Button from "../components/Button";
import useSocket from "../stores/useSocket";

const IndexPage = () => {
  const router = useRouter();

  const [username, setUsername] = useState("");
  const [rooms, setRooms] = useState([]);
  const [creatingRoomName, setCreatingRoomName] = useState("");

  const socket = useSocket((state) => state.socket);
  const setSocket = useSocket((state) => state.setSocket);
  const setSocketUsername = useSocket((state) => state.setUsername);

  useEffect(() => {
    if (!socket) return;
    axios
      .get("http://localhost:4001/rooms")
      .then((resp) => setRooms(resp.data.rooms));

    const onMessage = (event) => {
      const data = JSON.parse(event.data);
      if (data.event == "new-room-created") {
        setRooms((rooms) => [...rooms, data.room_name]);
      }
    };

    (socket as WebSocket).addEventListener("message", onMessage);
    return () =>
      (socket as WebSocket).removeEventListener("message", onMessage);
  }, [socket]);

  const onJoin = (event: FormEvent) => {
    event.preventDefault();
    setSocketUsername(username);
    setSocket(new WebSocket(`ws://localhost:4001/socket?username=${username}`));
  };

  const onRoomCreate = (event: FormEvent) => {
    event.preventDefault();
    (socket as WebSocket).send(
      JSON.stringify({cmd: "join-room", room_name: creatingRoomName})
    );
    setRooms((rooms) => [...rooms, creatingRoomName]);
    setCreatingRoomName("");
  };

  return (
    <div className="w-screen h-screen flex items-center justify-center">
      {socket ? (
        <div className="py-6 px-12 bg-gray-100 rounded-xl flex flex-col justify-center items-center gap-y-3">
          <span className="text-xl font-semibold">List of rooms</span>
          {!rooms.length ? (
            <div className="text-lg">There are no rooms!</div>
          ) : (
            <>
              {rooms.map((room, key) => (
                <Link href={`/${room}`} key={key}>
                  <a className="text-lg cursor-pointer">{room}</a>
                </Link>
              ))}
            </>
          )}
          <form className="mt-6" onSubmit={onRoomCreate}>
            <Input
              type="text"
              placeholder="Roomname"
              value={creatingRoomName}
              onChange={(event) => setCreatingRoomName(event.target.value)}
            />
            <Button className="mt-4">Create</Button>
          </form>
        </div>
      ) : (
        <div className="w-screen h-screen flex items-center justify-center">
          <div className="p-10 bg-gray-100 rounded-xl w-screen max-w-md">
            <form onSubmit={onJoin} className="w-full">
              <Input
                type="text"
                placeholder="Username"
                value={username}
                onChange={(event) => setUsername(event.target.value)}
              ></Input>
              <Button className="mt-6">Join</Button>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default IndexPage;
