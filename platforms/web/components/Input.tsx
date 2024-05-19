import classNames from "@/utils/classNames";

export default function Input({
  className,
  id,
  label,
  ...props
}: React.DetailedHTMLProps<
  React.InputHTMLAttributes<HTMLInputElement>,
  HTMLInputElement
> & {
  label?: string;
}) {
  return (
    <div className="flex flex-col gap-4">
      {label && <label htmlFor={id || props.name}>{label}</label>}
      <input
        className={classNames("p-2 rounded text-black", className)}
        id={id || props.name}
        {...props}
      />
    </div>
  );
}
