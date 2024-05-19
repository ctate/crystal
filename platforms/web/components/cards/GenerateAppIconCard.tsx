"use client";

import { useActions, useUIState } from "ai/rsc";
import { motion } from "framer-motion";
import { useState } from "react";
import { AI } from "@/app/action";

const colors = [
  { name: "Red", hex: "#F44336" },
  { name: "Pink", hex: "#E91E63" },
  { name: "Purple", hex: "#9C27B0" },
  { name: "Deep Purple", hex: "#673AB7" },
  { name: "Indigo", hex: "#3F51B5" },
  { name: "Blue", hex: "#2196F3" },
  { name: "Light Blue", hex: "#03A9F4" },
  { name: "Cyan", hex: "#00BCD4" },
  { name: "Teal", hex: "#009688" },
  { name: "Green", hex: "#4CAF50" },
  { name: "Light Green", hex: "#8BC34A" },
  { name: "Lime", hex: "#CDDC39" },
  { name: "Yellow", hex: "#FFEB3B" },
  { name: "Amber", hex: "#FFC107" },
  { name: "Orange", hex: "#FF9800" },
  { name: "Deep Orange", hex: "#FF5722" },
  { name: "Brown", hex: "#795548" },
  { name: "Grey", hex: "#9E9E9E" },
  { name: "Blue Grey", hex: "#607D8B" },
  { name: "Black", hex: "#222222" },
];

const icons = [
  { name: "Origami", url: "/images/app-icons/unicorn-origami.webp" },
  { name: "Polygon", url: "/images/app-icons/unicorn-polygon.webp" },
  { name: "Metallic", url: "/images/app-icons/unicorn-metallic.webp" },
  { name: "32-Bit Pixelated", url: "/images/app-icons/unicorn-32bit.webp" },
  { name: "16-Bit Pixelated", url: "/images/app-icons/unicorn-16bit.webp" },
  { name: "Flat", url: "/images/app-icons/unicorn-flat.webp" },
  { name: "Clay", url: "/images/app-icons/unicorn-clay.webp" },
  { name: "Line Art", url: "/images/app-icons/unicorn-line-art.webp" },
  { name: "Grunge", url: "/images/app-icons/unicorn-grunge.webp" },
  { name: "Cyberpunk", url: "/images/app-icons/unicorn-cyberpunk.webp" },
  { name: "Pop Art", url: "/images/app-icons/unicorn-pop-art.webp" },
  { name: "Comic Book", url: "/images/app-icons/unicorn-comic-book.webp" },
  { name: "Cartoon", url: "/images/app-icons/unicorn-cartoon.webp" },
  {
    name: "Sophisticated",
    url: "/images/app-icons/unicorn-sophisticated.webp",
  },
  { name: "Simple", url: "/images/app-icons/unicorn-simple.webp" },
  { name: "Minimalist", url: "/images/app-icons/unicorn-minimalist.webp" },
];

export default function GenerateAppIconCard({ description = "" }) {
  const [, setMessages] = useUIState<typeof AI>();
  const { submitUserMessage } = useActions();
  const [currentStep, setCurrentStep] = useState(1);
  const [color, setColor] = useState("");
  const [shouldAnimate, setShouldAnimate] = useState(false);

  if (currentStep === 1) {
    return (
      <motion.div
        key="1"
        className="flex flex-col gap-4"
        animate={shouldAnimate ? { opacity: 0, translateX: -500 } : undefined}
        transition={{ bounce: false }}
        onAnimationComplete={
          shouldAnimate ? () => setCurrentStep(currentStep + 1) : undefined
        }
      >
        <h2 className="text-2xl">Choose a Color</h2>
        <ul className="grid grid-cols-4 gap-4">
          {colors.map((color) => (
            <li className="flex flex-col gap-2 items-center" key={color.name}>
              <button
                className="aspect-square rounded-full w-16"
                onClick={() => {
                  setColor(color.name);
                  setShouldAnimate(true);
                }}
                style={{ backgroundColor: color.hex }}
              />
            </li>
          ))}
        </ul>
      </motion.div>
    );
  }

  if (currentStep === 2) {
    return (
      <motion.div
        key="2"
        initial={{ opacity: 0, translateX: 500 }}
        animate={{ opacity: 1, translateX: 0 }}
        className="flex flex-col gap-4"
        transition={{ bounce: false }}
      >
        <h2 className="text-2xl">Choose a Style</h2>
        <ul className="grid grid-cols-4 gap-4">
          {icons.map((icon) => (
            <li className="flex flex-col gap-2 items-center" key={icon.name}>
              <button
                className="aspect-square overflow-hidden rounded-2xl w-full"
                onClick={async () => {
                  const response = await submitUserMessage(
                    `Render the app icon with these properties:\n\nDescription: ${description}\nColor: ${color}\nStyle: ${icon.name}`
                  );
                  setMessages((currentMessages) => [
                    ...currentMessages,
                    response,
                  ]);
                }}
              >
                <img src={icon.url} />
              </button>
              <div className="text-sm text-white">{icon.name}</div>
            </li>
          ))}
        </ul>
      </motion.div>
    );
  }

  return <div></div>;
}
