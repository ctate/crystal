"use client";

import { useState } from "react";
import Button from "../Button";
import { useActions, useUIState } from "ai/rsc";
import { AI } from "@/app/action";

const voices = ["alloy", "echo", "fable", "onyx", "nova", "shimmer"];

export interface ChangeVoiceCardProps {
  initialVoice?: string;
}

export function ChangeVoiceCard({
  initialVoice = "alloy",
}: ChangeVoiceCardProps) {
  const [, setMessages] = useUIState<typeof AI>();
  const { submitUserMessage } = useActions();
  const [selectedVoice, setSelectedVoice] = useState(initialVoice);

  return (
    <div className="flex flex-col gap-4">
      <ul className="flex flex-col gap-4 md:flex-row">
        {voices.map((voice) => (
          <li key={voice}>
            <Button
              className="w-full"
              color={voice === selectedVoice ? "primary" : "secondary"}
              onClick={() => setSelectedVoice(voice)}
              type="button"
            >
              {voice}
            </Button>
          </li>
        ))}
      </ul>
      <button
        onClick={async () => {
          const response = await submitUserMessage(
            `Save voice setting as "${selectedVoice}"`
          );
          setMessages((currentMessages) => [...currentMessages, response]);
        }}
      >
        Save
      </button>
    </div>
  );
}
