"use client";

import { nanoid } from "nanoid";
import { useState } from "react";
import { v4 as uuidv4 } from "uuid";
import Button from "./Button";

export interface IdCardProps {
  type?: "nanoid" | "uuid";
}

export default function IdCard({ type = "uuid" }: IdCardProps) {
  const [uuid, setUuid] = useState(type === "nanoid" ? nanoid() : uuidv4());

  return (
    <div className="flex flex-col gap-4">
      <div className="bg-black px-8 py-4 font-mono rounded-full whitespace-nowrap text-2xl">
        {uuid}
      </div>
      <div className="flex justify-center">
        <div className="gap-4 grid grid-cols-2">
          <Button
            color="secondary"
            onClick={() => setUuid(type === "nanoid" ? nanoid() : uuidv4())}
          >
            Copy UUID
          </Button>
          <Button
            color="primary"
            onClick={() => setUuid(type === "nanoid" ? nanoid() : uuidv4())}
          >
            Generate Another
          </Button>
        </div>
      </div>
    </div>
  );
}
