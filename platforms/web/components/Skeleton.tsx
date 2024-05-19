import classNames from "@/utils/classNames";

export interface SkeletonProps {
  className?: string;
  height?: number;
  width?: number;
}

export default function Skeleton({ className, height, width }: SkeletonProps) {
  return (
    <div
      className={classNames("animate-pulse bg-slate-400", className)}
      style={{ height, width }}
    />
  );
}
