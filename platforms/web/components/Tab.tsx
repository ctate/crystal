import React from "react";
import { useTabsContext } from "./Tabs";

interface TabProps {
  children: React.ReactNode;
  onClick?: () => void;
  value: string;
}

export const Tab: React.FC<TabProps> = ({ children, onClick, value }) => {
  const { activeTab } = useTabsContext();
  const isActive = activeTab === value;

  return (
    <button
      aria-selected={isActive}
      className={`border-b-2 border-transparent text-2xl py-2 font-semibold ${
        isActive ? "text-white border-b-white" : "text-gray-400"
      }`}
      role="tab"
      onClick={onClick}
    >
      {children}
    </button>
  );
};
