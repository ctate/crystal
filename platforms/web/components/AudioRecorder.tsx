import { motion } from "framer-motion";
import React, { useState, useRef, useEffect, useCallback } from "react";
import { useHotkeys } from "react-hotkeys-hook";

export interface AudioRecordProps {
  onChange: (formData: FormData) => Promise<void>;
  onStart: () => void;
}

export default function AudioRecorder({ onChange, onStart }: AudioRecordProps) {
  const [recording, setRecording] = useState(false);
  const [audioBlob, setAudioBlob] = useState<Blob | null>(null);
  const [volume, setVolume] = useState(0);
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);

  // const audioContext = new AudioContext();
  // const analyser = audioContext.createAnalyser();
  // analyser.fftSize = 256;
  // analyser.smoothingTimeConstant = 0.8;

  useHotkeys(
    " ",
    (e) => {
      e.preventDefault();

      if (recording) {
        return;
      }

      startRecording();
    },
    {
      keydown: true,
    }
  );
  useHotkeys(
    " ",
    (e) => {
      e.preventDefault();

      if (!recording) {
        return;
      }

      stopRecording();
    },
    {
      keyup: true,
    }
  );

  const startRecording = useCallback(async () => {
    onStart();

    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      const mediaRecorder = new MediaRecorder(stream);
      mediaRecorderRef.current = mediaRecorder;
      mediaRecorder.start(100);

      // const source = audioContext.createMediaStreamSource(stream);
      // source.connect(analyser);

      // const dataArray = new Uint8Array(analyser.frequencyBinCount);

      // const getVolume = () => {
      //   analyser.getByteFrequencyData(dataArray);
      //   let sum = 0;
      //   for (let i = 0; i < dataArray.length; i++) {
      //     sum += dataArray[i];
      //   }
      //   const average = sum / dataArray.length;
      //   setVolume(average);
      //   requestAnimationFrame(getVolume);
      // };

      // getVolume();

      const audioChunks: BlobPart[] = [];
      mediaRecorder.ondataavailable = (event) => {
        audioChunks.push(event.data);
      };

      mediaRecorder.onstop = () => {
        const audioBlob = new Blob(audioChunks, { type: "audio/mpeg" });
        setAudioBlob(audioBlob);

        const formData = new FormData();
        formData.append("file", audioBlob, "audio.mp3");

        // audioContext.close();

        onChange(formData);
      };

      setRecording(true);
    } catch (error) {
      console.error("Failed to start recording:", error);
    }
  }, [onChange, onStart]);

  const stopRecording = useCallback(() => {
    mediaRecorderRef.current?.stop();
    setRecording(false);
  }, []);

  const handleTouchStart = useCallback(
    (e: TouchEvent) => {
      if (
        (e.target as HTMLElement).tagName === "BUTTON" ||
        (e.target as HTMLElement).closest("button") ||
        (e.target as HTMLElement).tagName === "LABEL" ||
        (e.target as HTMLElement).closest("label") ||
        (e.target as HTMLElement).tagName === "OL" ||
        (e.target as HTMLElement).closest("ol") ||
        (e.target as HTMLElement).tagName === "UL" ||
        (e.target as HTMLElement).closest("ul")
      ) {
        return;
      }

      e.preventDefault();

      if (recording) {
        return;
      }

      startRecording();
    },
    [recording, startRecording]
  );

  const handleTouchEnd = useCallback(
    (e: TouchEvent) => {
      if (
        (e.target as HTMLElement).tagName === "BUTTON" ||
        (e.target as HTMLElement).closest("button") ||
        (e.target as HTMLElement).tagName === "LABEL" ||
        (e.target as HTMLElement).closest("label") ||
        (e.target as HTMLElement).tagName === "OL" ||
        (e.target as HTMLElement).closest("ol") ||
        (e.target as HTMLElement).tagName === "UL" ||
        (e.target as HTMLElement).closest("ul")
      ) {
        return;
      }

      e.preventDefault();

      if (!recording) {
        return;
      }

      stopRecording();
    },
    [recording, stopRecording]
  );

  useEffect(() => {
    document.addEventListener("touchstart", handleTouchStart);
    document.addEventListener("touchend", handleTouchEnd);

    return () => {
      document.removeEventListener("touchstart", handleTouchStart);
      document.removeEventListener("touchend", handleTouchEnd);
    };
  }, [handleTouchEnd, handleTouchStart]);

  return (
    <div>
      <motion.iframe
        initial={{ opacity: 0, translateY: 100, scale: 0.5 }}
        animate={recording ? { opacity: 1, translateY: 0, scale: 1 } : {}}
        transition={{ bounce: false }}
        height={100}
        src="/sphere/index.html"
      />
    </div>
  );
}
