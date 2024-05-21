import React, { useRef, useEffect, Ref, useState } from "react";
import { createPortal } from "react-dom";

interface PopoverProps {
  children: React.ReactNode;
  isOpen?: boolean;
  onClose?: () => void;
  position?: "top" | "bottom" | "left" | "right";
  target?: HTMLElement | null;
}

export const Popover: React.FC<PopoverProps> = ({
  children,
  onClose = () => {},
  isOpen = false,
  position = "bottom",
  target,
}) => {
  const contentRef = useRef<HTMLDivElement>(null);

  const [left, setLeft] = useState(0);
  const [top, setTop] = useState(0);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        contentRef.current &&
        !contentRef.current.contains(event.target as Node) &&
        target &&
        !target.contains(event.target as Node)
      ) {
        onClose();
      }
    };

    const handleResize = () => {
      const left =
        (target?.getBoundingClientRect().left || 0) -
        ((contentRef.current?.getBoundingClientRect().width || 0) -
          (target?.getBoundingClientRect().width || 0)) /
          2;

      const top =
        (target?.getBoundingClientRect().top || 0) +
        (target?.getBoundingClientRect().height || 0) +
        5;

      setLeft(left);
      setTop(top);
    };

    handleResize();

    document.addEventListener("mousedown", handleClickOutside);
    window.addEventListener("resize", handleResize);

    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
      window.removeEventListener("resize", handleResize);
    };
  }, [onClose, target]);

  if (!isOpen) {
    return null;
  }

  return createPortal(
    <div
      className="bg-gray-900 fixed p-4 rounded-2xl"
      ref={contentRef}
      style={{
        left,
        top,
      }}
    >
      {children}
    </div>,
    document.body
  );
};
