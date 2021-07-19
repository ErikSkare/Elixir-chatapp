import create from "zustand";
import {combine} from "zustand/middleware";

export default create(
  combine(
    {
      socket: null,
      username: "",
    },
    (set) => ({
      setSocket: (socket: WebSocket) =>
        set((state) => {
          return {...state, socket};
        }),
      setUsername: (username: string) =>
        set((state) => {
          return {...state, username};
        }),
    })
  )
);
