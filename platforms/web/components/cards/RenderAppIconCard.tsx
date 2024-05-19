"use client";

import { useActions, useUIState } from "ai/rsc";
import { motion } from "framer-motion";
import { AI } from "@/app/action";
import Button from "../Button";
import ImageCard from "./ImageCard";
import { useRef, useState } from "react";
import { useHotkeys } from "react-hotkeys-hook";
import JSZip from "jszip";
import { saveAs } from "file-saver";
import Skeleton from "../Skeleton";

export interface RenderAppIconCardProps {
  imageUrls: string[];
}

export default function RenderAppIconCard({
  imageUrls,
}: RenderAppIconCardProps) {
  const [, setMessages] = useUIState<typeof AI>();
  const { submitUserMessage } = useActions();

  const [coords, setCoords] = useState({
    top: 0,
    left: 0,
    height: 0,
    width: 0,
  });
  const [selectedImage, setSelectedImage] = useState(-1);
  const [selectedImageUrl, setSelectedImageUrl] = useState("");

  useHotkeys("esc", () => setSelectedImage(-1));

  const canvasRef = useRef<HTMLCanvasElement>(null);

  const generateIcons = async (base64: string) => {
    const iconSizes = [16, 32, 48, 72, 96, 128, 144, 152, 192, 196, 512]; // Add more sizes as needed
    const zip = new JSZip();
    const canvas = canvasRef.current!;
    const ctx = canvas.getContext("2d")!;
    const img = new Image();

    img.onload = () => {
      iconSizes.forEach((size) => {
        canvas.width = size;
        canvas.height = size;
        ctx.clearRect(0, 0, size, size);
        ctx.drawImage(img, 0, 0, size, size);
        canvas.toBlob((blob) => {
          zip.file(`icon-${size}.png`, blob!);
          if (size === iconSizes[iconSizes.length - 1]) {
            zip.generateAsync({ type: "blob" }).then((content) => {
              saveAs(content, "icons.zip");
            });
          }
        });
      });
    };

    img.src = base64;
  };

  return (
    <>
      <div className="flex flex-col gap-4">
        <div className="grid grid-cols-2 gap-4">
          {imageUrls.map((imageUrl, index) => (
            <motion.button
              initial={{
                opacity: 1,
              }}
              animate={{
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                opacity: selectedImage === -1 ? 1 : 0,
              }}
              className="flex flex-col gap-4 justify-center items-center"
              key={index}
              onClick={(e) => {
                const bounds = (
                  e.target as HTMLImageElement
                ).getBoundingClientRect();

                setCoords({
                  left: bounds.left,
                  top: bounds.top,
                  width: bounds.width,
                  height: bounds.height,
                });
                setSelectedImage(selectedImage === index ? -1 : index);
                setSelectedImageUrl(imageUrl);
              }}
            >
              <ImageCard
                className="rounded-2xl w-36 md:w-64"
                imageUrl={imageUrl}
              />
            </motion.button>
          ))}
        </div>
        <motion.div
          animate={{
            opacity: selectedImage === -1 ? 1 : 0,
          }}
          className="flex justify-center"
        >
          <Button
            color="secondary"
            onClick={async () => {
              const response = await submitUserMessage("try again");
              setMessages((currentMessages) => [...currentMessages, response]);
            }}
          >
            Try Again
          </Button>
        </motion.div>
      </div>
      {selectedImage !== -1 && (
        <button
          className="fixed top-0 right-0 bottom-0 left-0"
          onClick={() => setSelectedImage(-1)}
        />
      )}
      {selectedImageUrl && (
        <motion.div
          className="fixed flex flex-col justify-center gap-4"
          initial={coords}
          animate={{
            left: selectedImage !== -1 ? "50%" : coords.left,
            top: selectedImage !== -1 ? "50%" : coords.top,
            translateX: selectedImage !== -1 ? "-50%" : "0%",
            translateY: selectedImage !== -1 ? "-50%" : "0%",
            scale: selectedImage !== -1 ? 2 : 1,
          }}
          transition={{
            bounce: false,
          }}
          onAnimationComplete={
            selectedImage === -1 ? () => setSelectedImageUrl("") : undefined
          }
        >
          <ImageCard
            className="rounded-2xl"
            imageUrl={selectedImageUrl}
            style={coords}
          />
        </motion.div>
      )}
      {selectedImage !== -1 && (
        <motion.div
          initial={{
            opacity: 0,
          }}
          animate={{
            opacity: 1,
          }}
          transition={{
            delay: 0.25,
          }}
          className="flex justify-center fixed right-0 bottom-6 left-0 scale-150"
          onClick={() => setSelectedImage(-1)}
        >
          <Button
            color="primary"
            onClick={async (e) => {
              e.stopPropagation();
              generateIcons(selectedImageUrl);
            }}
          >
            Download Assets
          </Button>
        </motion.div>
      )}
      <canvas ref={canvasRef} style={{ display: "none" }}></canvas>
    </>
  );
}
