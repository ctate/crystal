import { useAppContext } from "@/context/AppContext";
import { Popover } from "./Popover";
import { useRef, useState } from "react";
import classNames from "@/utils/classNames";
import PROVIDERS from "@/constants/PROVIDERS";
import { saveSetting } from "@/app/action";
import RightArrowIcon from "./icons/RightArrowIcon";
import ExpandArrowIcon from "./icons/ExpandArrowIcon";

export default function Header() {
  const { selectedModel, setSelectedModel } = useAppContext();

  const targetRef = useRef<HTMLButtonElement>(null);
  const [showPopover, setShowPopover] = useState(false);

  return (
    <header className="fixed flex justify-center p-4 left-0 right-0 top-0">
      <button
        className="flex gap-2 items-center"
        onClick={() => setShowPopover(!showPopover)}
        ref={targetRef}
      >
        <span>{selectedModel}</span>
        <span
          className={classNames("transition-transform", {
            "rotate-90": showPopover,
          })}
        >
          <ExpandArrowIcon color="gray" size={16} />
        </span>
      </button>
      <Popover
        isOpen={showPopover}
        onClose={() => setShowPopover(false)}
        target={targetRef.current}
      >
        <ul>
          {PROVIDERS.map((provider) => (
            <li key={provider.name}>
              <div className="font-bold">{provider.name}</div>
              <ul>
                {provider.models.map((model) => (
                  <li key={model}>
                    <button
                      onClick={async () => {
                        void fetch("/api/saveSetting", {
                          method: "POST",
                          headers: {
                            "content-type": "application/json",
                          },
                          body: JSON.stringify({
                            key: "model",
                            value: model,
                          }),
                        });
                        setSelectedModel(model);
                        setShowPopover(false);
                      }}
                    >
                      {model}
                    </button>
                  </li>
                ))}
              </ul>
            </li>
          ))}
        </ul>
      </Popover>
    </header>
  );
}
