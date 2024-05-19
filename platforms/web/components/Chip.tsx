import { ReactNode } from "react";

export interface ChipProps {
  children?: ReactNode;
}

export default function Chip({ children }: ChipProps) {
  return (
    <div className="bg-white bg-opacity-50 px-4 rounded-full">{children}</div>
  );
}
