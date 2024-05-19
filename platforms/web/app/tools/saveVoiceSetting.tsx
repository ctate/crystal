import Spinner from "@/components/Spinner";
import saveSettings from "@/utils/saveSettings";
import { nanoid } from "nanoid";
import { z } from "zod";

export default function saveVoiceSetting({ aiState }: any) {
  return {
    description: "Save voice setting",
    parameters: z
      .object({
        voice: z.enum(["alloy", "echo", "fable", "onyx", "nova", "shimmer"]),
      })
      .required(),
    render: async function* ({ voice }: { voice: string }) {
      console.log("saveVoiceSetting");

      yield <Spinner />;

      aiState.done([
        ...aiState.get(),
        {
          role: "function",
          name: nanoid(),
          content: "All done",
          complete: true,
        },
      ]);

      await saveSettings("voice", voice);

      return <div>All done</div>;
    },
  };
}
