"use client";

import { motion } from "framer-motion";
import { useCallback, useEffect, useRef, useState } from "react";
import { useUIState, useActions, useAIState } from "ai/rsc";
import type { AI } from "./action";
import { useHotkeys } from "react-hotkeys-hook";
import AudioRecorder from "@/components/AudioRecorder";
import classNames from "@/utils/classNames";
import WebcamSwitcher from "@/components/Webcam";
import { useIdleCursor } from "@/hooks/useIdleCursor";

export default function Page() {
  const cursorVisible = useIdleCursor();

  const audioRef = useRef<HTMLAudioElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  const [coords, setCoords] = useState([0, 0]);
  const [inputValue, setInputValue] = useState("");
  const [isPending, setIsPending] = useState(true);
  const [aiMessages, setAiMessages] = useAIState<typeof AI>();
  const [imageUrl, setImageUrl] = useState("");
  const [messages, setMessages] = useUIState<typeof AI>();
  const [showInput, setShowInput] = useState(false);
  const [showWebcam, setShowWebcam] = useState(false);
  const { submitUserImage, submitUserMessage, submitUserVoice } =
    useActions<typeof AI>();

  useHotkeys("meta+.", () => setShowInput(!showInput));
  useHotkeys("meta+/", () => setShowWebcam(!showWebcam));

  useEffect(() => {
    if (window.navigator && window.navigator.geolocation) {
      window.navigator.geolocation.getCurrentPosition((position) => {
        setCoords([position.coords.latitude, position.coords.longitude]);
      });
    }
  }, []);

  useEffect(() => {
    const aiMessage = aiMessages.slice(-1);
    if (
      aiMessage &&
      aiMessage[0] &&
      ((aiMessage[0].role === "assistant" && aiMessage[0].complete) ||
        aiMessage[0].role === "function")
    ) {
      (async () => {
        audioRef.current!.src = `/api/tts?input=${encodeURIComponent(
          typeof aiMessage[0].content === "string"
            ? aiMessage[0].content
            : (aiMessage[0].content.find((c) => c.type === "text") as any).text
        )}`;
        audioRef.current!.play();
      })();
      setIsPending(false);
    } else {
      setIsPending(true);
    }
  }, [aiMessages]);

  useEffect(() => {
    document.body.style.cursor = cursorVisible ? "auto" : "none";
  }, [cursorVisible]);

  return (
    <>
      <div
        className={classNames(
          "flex flex-col items-center justify-center min-h-dvh",
          showWebcam
            ? "fixed left-0 right-0 bottom-0 min-h-0 h-1/2 justify-start"
            : ""
        )}
      >
        {isPending &&
          messages
            .filter((message) => message.role === "user")
            .slice(-1)
            .map((message) => (
              <motion.div
                className="animate-pulse p-4 italic rounded-2xl text-center text-gray-500 text-2xl w-full md:w-1/2"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ bounce: false }}
                key={message.id}
              >
                {message.display}
              </motion.div>
            ))}
        {!isPending &&
          messages.slice(-1).map((message) => (
            <motion.div
              className="p-4 rounded-2xl text-lg w-full md:w-1/2"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ bounce: false }}
              key={message.id}
            >
              {message.display}
            </motion.div>
          ))}
      </div>
      <motion.form
        initial={{ opacity: 0, translateY: 100, scale: 0.5 }}
        animate={showInput ? { opacity: 1, translateY: 0, scale: 1 } : {}}
        transition={{ bounce: false }}
        autoFocus={showInput}
        className="fixed left-8 bottom-8 right-8 flex justify-center"
        onAnimationComplete={() => {
          if (!showInput) {
            return;
          }
          inputRef.current?.focus();
        }}
        onSubmit={async (e) => {
          e.preventDefault();

          setShowInput(false);
          setIsPending(true);

          setMessages((currentMessages) => [
            ...currentMessages,
            {
              id: Date.now(),
              display: <div>{inputValue}</div>,
              role: "user",
            },
          ]);

          const responseMessage =
            showWebcam && imageUrl
              ? await submitUserImage(inputValue, imageUrl)
              : await submitUserMessage(inputValue);
          setMessages((currentMessages) => [
            ...currentMessages,
            responseMessage,
          ]);

          setInputValue("");
        }}
      >
        <input
          autoFocus
          className={classNames(
            "bg-white bg-opacity-15 caret-transparent flex outline-none rounded-full p-4 text-white text-lg text-center w-full focus:border focus:border-white md:w-1/2",
            { "pointer-events-none": !showInput }
          )}
          ref={inputRef}
          value={inputValue}
          onChange={(event) => {
            setInputValue(event.target.value);
          }}
        />
      </motion.form>
      {!showInput && (
        <div className="fixed left-4 bottom-4 right-4 flex justify-center pointer-events-none">
          <AudioRecorder
            onChange={async (formData) => {
              const input = await submitUserVoice(formData);

              setIsPending(true);

              setMessages((currentMessages) => [
                ...currentMessages,
                {
                  id: Date.now(),
                  display: <div>{input.replace(/\.$/, "")}</div>,
                  role: "user",
                },
              ]);

              const responseMessage =
                showWebcam && imageUrl
                  ? await submitUserImage(input, imageUrl)
                  : await submitUserMessage(input);
              setMessages((currentMessages) => [
                ...currentMessages,
                responseMessage,
              ]);

              setInputValue("");
            }}
            onStart={() => audioRef.current?.pause()}
          />
        </div>
      )}
      {showWebcam && (
        <WebcamSwitcher onSnap={(imageUrl) => setImageUrl(imageUrl)} />
      )}
      <audio ref={audioRef} />
    </>
  );
}
