import classNames from "@/utils/classNames";
import { CSSProperties } from "react";

export interface ImageCardProps {
  className?: string;
  imageUrl: string;
  size?: number;
  style?: CSSProperties;
}

export default function ImageCard({
  className,
  imageUrl,
  size = 256,
  style,
}: ImageCardProps) {
  return (
    <div>
      <img
        className={classNames(
          "aspect-square object-contain bg-white",
          className
        )}
        height={size}
        src={imageUrl}
        style={style}
        width={size}
      />
    </div>
  );
}
