import React from "react";

interface MeterProps {
  formatOptions?: Intl.NumberFormatOptions;
  maxValue?: number;
  minValue?: number;
  size?: number;
  strokeWidth?: number;
  value: number;
}

export const Meter: React.FC<MeterProps> = ({
  formatOptions = {},
  maxValue = 100,
  minValue = 0,
  size = 300,
  strokeWidth = 14,
  value,
}) => {
  const center = size / 2;
  const r = center - strokeWidth;
  const c = 2 * r * Math.PI;
  const a = c * (270 / 360);
  const percentage = (value - minValue) / (maxValue - minValue);
  const offset = c - percentage * a;

  // Custom formatter using Intl.NumberFormat
  const formatter = new Intl.NumberFormat("en-US", formatOptions);
  const formattedValue = formatter.format(value);

  return (
    <svg
      width={size}
      height={size}
      viewBox={`0 0 ${size} ${size}`}
      fill="none"
      strokeWidth={strokeWidth}
    >
      <circle
        cx={center}
        cy={center}
        r={r}
        stroke="white"
        strokeOpacity={0.2}
        strokeDasharray={`${a} ${c}`}
        strokeLinecap="round"
        transform={`rotate(135 ${center} ${center})`}
      />
      <circle
        cx={center}
        cy={center}
        r={r}
        stroke="white"
        strokeDasharray={c}
        strokeDashoffset={offset}
        strokeLinecap="round"
        transform={`rotate(135 ${center} ${center})`}
      />
      <text
        x={center}
        y={center + 5}
        fontFamily="ui-rounded, system-ui"
        fontSize={12}
        textAnchor="middle"
        fill="white"
      >
        {formattedValue}
      </text>
    </svg>
  );
};

export default Meter;
