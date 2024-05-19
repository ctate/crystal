"use client";

import { motion } from "framer-motion";

export default function Stars() {
  return (
    <motion.iframe
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="fixed left-0 top-0 right-0 bottom-0 w-screen h-screen -z-10"
      src="/stars/index.html"
    />
  );
}
