"use client";

import { motion } from "framer-motion";
import styles from "./Rain.module.css";

function randRange(minNum: number, maxNum: number) {
  return Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum;
}

export default function Rain() {
  const drops: Array<{
    left: number;
    top: number;
  }> = [];

  for (let i = 1; i < 100; i++) {
    var dropLeft = randRange(0, 1600);
    var dropTop = randRange(-1000, 1400);

    drops.push({
      left: dropLeft,
      top: dropTop,
    });
  }

  return (
    <motion.section
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className={styles.rain}
    >
      {drops.map((drop, i) => (
        <div
          className={styles.drop}
          id={`drop${i}`}
          key={i}
          style={{ left: drop.left, top: drop.top }}
        />
      ))}
    </motion.section>
  );
}
