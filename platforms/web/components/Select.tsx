import classNames from "@/utils/classNames";

export default function Select({
  className,
  ...props
}: React.DetailedHTMLProps<
  React.SelectHTMLAttributes<HTMLSelectElement>,
  HTMLSelectElement
>) {
  return (
    <select
      className={classNames("p-2 rounded text-black", className)}
      {...props}
    />
  );
}
