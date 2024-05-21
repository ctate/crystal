export default function ExpandArrowIcon({ color = "white", size = 32 }) {
  return (
    <svg
      fill="none"
      viewBox="0 0 24 24"
      height={size}
      width={size}
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        clipRule="evenodd"
        d="m7.2072 20.7072c-.39052-.3905-.39052-1.0237 0-1.4142l7.2929-7.2929-7.2929-7.29292c-.39052-.39052-.39052-1.02369 0-1.41421l.70711-.70711c.39052-.39052 1.02368-.39052 1.41421 0l8.35358 8.35354c.5858.5858.5858 1.5356 0 2.1213l-8.35358 8.3536c-.39052.3905-1.02369.3905-1.41421 0z"
        fill={color}
        fillRule="evenodd"
      />
    </svg>
  );
}
