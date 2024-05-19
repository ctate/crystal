import React, { useCallback, useEffect, useRef } from "react";
import { useHotkeys } from "react-hotkeys-hook";

export default function WebcamSwitcher({ onSnap = (dataUrl: string) => {} }) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useHotkeys(" ", (e) => {
    e.preventDefault();

    takePhoto();
  });

  const setupCamera = async () => {
    const stream = await navigator.mediaDevices.getUserMedia({
      video: { facingMode: { exact: "environment" } },
    });
    if (videoRef.current) {
      videoRef.current.srcObject = stream;
    }
  };

  const takePhoto = useCallback(() => {
    if (canvasRef.current && videoRef.current) {
      const context = canvasRef.current.getContext("2d");
      const { videoWidth, videoHeight } = videoRef.current;
      canvasRef.current.width = videoWidth;
      canvasRef.current.height = videoHeight;
      context?.drawImage(videoRef.current, 0, 0, videoWidth, videoHeight);
      const imageDataUrl = canvasRef.current.toDataURL("image/png");
      onSnap(imageDataUrl);
    }
  }, [onSnap]);

  const handleTouchStart = useCallback(async () => {
    takePhoto();
  }, [takePhoto]);

  useEffect(() => {
    setupCamera();
  }, []);

  useEffect(() => {
    document.addEventListener("touchstart", handleTouchStart);

    return () => {
      document.removeEventListener("touchstart", handleTouchStart);
    };
  }, [handleTouchStart]);

  return (
    <div className="fixed top-4 right-4 left-4">
      <video
        className="aspect-square bg-gray-600 object-cover rounded-2xl w-full"
        ref={videoRef}
        autoPlay
        muted
        playsInline
      />
      <canvas ref={canvasRef} style={{ display: "none" }}></canvas>
    </div>
  );
}
