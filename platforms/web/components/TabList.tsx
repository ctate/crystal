import React from "react";
import { useTabsContext } from "./Tabs";

interface TabListProps {
  children?: React.ReactElement[] | React.ReactElement;
}

export const TabList: React.FC<TabListProps> = ({ children }) => {
  const { setActiveTab } = useTabsContext();

  return (
    <div className="flex gap-4" role="tablist">
      {React.Children.map(children || [], (child) =>
        React.cloneElement(child, {
          onClick: () => setActiveTab(child.props.value),
        })
      )}
    </div>
  );
};
