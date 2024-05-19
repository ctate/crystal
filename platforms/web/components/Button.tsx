import classNames from "@/utils/classNames";
import { MouseEvent, ReactNode } from "react";

export interface ButtonProps {
  children?: ReactNode;
  className?: string;
  color?: "primary" | "secondary";
  onClick?: (e: MouseEvent) => void;
  type?: "button" | "submit";
}

export default function Button({
  children,
  className,
  color = "secondary",
  onClick,
  type = "button",
}: ButtonProps) {
  return (
    <button
      className={classNames(
        "border border-white px-4 py-2 rounded-2xl text-xs",
        {
          "bg-white text-black": color === "primary",
        },
        className
      )}
      onClick={onClick}
      type={type}
    >
      {children}
    </button>
  );
}
