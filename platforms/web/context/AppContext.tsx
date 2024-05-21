import React, { createContext, useContext, useState, ReactNode } from "react";

interface AppContextType {
  selectedModel: string;
  setSelectedModel: (model: string) => void;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

export const AppContextProvider: React.FC<{ children: ReactNode }> = ({
  children,
}) => {
  const [selectedModel, setSelectedModel] = useState("gpt-4");

  return (
    <AppContext.Provider value={{ selectedModel, setSelectedModel }}>
      {children}
    </AppContext.Provider>
  );
};

export const useAppContext = (): AppContextType => {
  const context = useContext(AppContext);
  if (context === undefined) {
    throw new Error("useAppContext must be used within a AppContextProvider");
  }
  return context;
};
