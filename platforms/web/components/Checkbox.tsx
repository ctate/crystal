import { useState } from "react";

export interface CheckboxProps {
  label: string;
}

export default function Checkbox({ label }: CheckboxProps) {
  const [checked, setChecked] = useState(false);

  const handleCheckboxChange = () => {
    setChecked(!checked);
  };

  return (
    <label className="inline-flex items-start cursor-pointer">
      <input
        checked={checked}
        className="sr-only"
        onChange={handleCheckboxChange}
        type="checkbox"
      />
      <div
        className={`min-w-6 min-h-6 inline-block mt-0.5 mr-2 rounded-full border-2 overflow-hidden ${
          checked ? "bg-blue-500 border-blue-500" : "bg-white border-gray-300"
        }`}
      >
        {checked && (
          <svg
            className="fill-current w-5 h-5 text-white mx-auto"
            viewBox="0 0 20 20"
          >
            <path d="M7.629 14.571L3.5 10.571L4.536 9.571L7.629 12.536L15.464 4.5L16.5 5.536L7.629 14.571Z" />
          </svg>
        )}
      </div>
      <span>{label}</span>
    </label>
  );
}
