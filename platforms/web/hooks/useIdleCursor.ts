import { useState, useEffect } from "react";

export function useIdleCursor(timeout = 1000) {
  const [cursorVisible, setCursorVisible] = useState(true);

  useEffect(() => {
    let timer: NodeJS.Timeout;

    const handleMouseMove = () => {
      setCursorVisible(true);
      clearTimeout(timer);
      timer = setTimeout(() => {
        setCursorVisible(false);
      }, timeout);
    };

    document.addEventListener("mousemove", handleMouseMove);

    return () => {
      document.removeEventListener("mousemove", handleMouseMove);
      clearTimeout(timer);
    };
  }, [timeout]);

  return cursorVisible;
}
