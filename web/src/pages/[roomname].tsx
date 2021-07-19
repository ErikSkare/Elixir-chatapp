import {useRouter} from "next/router";
import {FormEvent, useEffect, useState} from "react";
import Button from "../components/Button";
import Input from "../components/Input";
import useSocket from "../stores/useSocket";

const Roomname = () => {
  const router = useRouter();
  const {roomname} = router.query;

  const socket = useSocket((state) => state.socket);
  const [error, setError] = useState("");
  const [messages, setMessages] = useState([]);

  const [pendingMessage, setPendingMessage] = useState("");
  const username = useSocket((state) => state.username);

  useEffect(() => {
    if (!socket) return setError("No socket provided!");
    (socket as WebSocket).send(
      JSON.stringify({cmd: "join-room", room_name: roomname})
    );

    const onMessage = (event) => {
      const data = JSON.parse(event.data);
      if (data.event == "message-received") {
        setMessages((state) => [
          ...state,
          {from: data.from, message: data.message},
        ]);
      }
    };

    (socket as WebSocket).addEventListener("message", onMessage);
    return () => {
      (socket as WebSocket).send(JSON.stringify({cmd: "leave-room"}));
      (socket as WebSocket).removeEventListener("message", onMessage);
    };
  }, []);

  const onSend = (event: FormEvent) => {
    event.preventDefault();
    (socket as WebSocket).send(
      JSON.stringify({cmd: "send-message", message: pendingMessage})
    );
    setMessages((state) => [
      ...state,
      {from: username, message: pendingMessage},
    ]);
    setPendingMessage("");
  };

  if (error != "")
    return (
      <div className="w-screen h-screen flex items-center justify-center text-lg font-semibold">
        {error}
      </div>
    );

  return (
    <div className="w-screen h-screen flex flex-col">
      <div className="h-screen p-10 bg-gray-100 flex flex-col flex-grow text-lg overflow-auto">
        {messages.map((message, key) => (
          <div key={key} className="flex flex-row gap-x-2">
            <span className="font-semibold">{message.from}:</span>
            <span>{message.message}</span>
          </div>
        ))}
      </div>
      <form className="flex flex-row" onSubmit={onSend}>
        <Input
          className="flex-grow"
          placeholder="Your message"
          value={pendingMessage}
          onChange={(event) => setPendingMessage(event.target.value)}
        />
        <Button className="max-w-md">Send</Button>
      </form>
    </div>
  );
};

export default Roomname;
