import React, { useState, createContext, useContext, useEffect } from "react";

interface TabsContextType {
  activeTab: string;
  setActiveTab: (id: string) => void;
}

const TabsContext = createContext<TabsContextType | undefined>(undefined);

export const useTabsContext = () => {
  const context = useContext(TabsContext);
  if (!context)
    throw new Error("useTabsContext must be used within a Tabs component");
  return context;
};

interface TabsProps {
  children: React.ReactNode;
  defaultValue?: string;
  onChange?: (newActiveTabId: string) => void;
  value?: string;
}

export const Tabs: React.FC<TabsProps> = ({
  children,
  defaultValue,
  onChange,
  value,
}) => {
  const [activeTab, setActiveTab] = useState<string>(
    defaultValue || value || ""
  );

  useEffect(() => {
    if (value !== undefined) {
      setActiveTab(value);
    }
  }, [value]);

  const handleChange = (id: string) => {
    if (value === undefined) {
      setActiveTab(id);
    }
    if (onChange) {
      onChange(id);
    }
  };

  const contextValue = { activeTab, setActiveTab: handleChange };

  return (
    <TabsContext.Provider value={contextValue}>{children}</TabsContext.Provider>
  );
};
