import Spinner from "@/components/Spinner";
import { ChangeVoiceCard } from "@/components/cards/ChangeVoiceCard";
import getSettings from "@/utils/getSettings";
import { nanoid } from "nanoid";
import { z } from "zod";

export default function changeVoice({ aiState }: any) {
  return {
    description: "Change voice",
    parameters: z.object({}).required(),
    render: async function* () {
      console.log("changeVoice");

      yield <Spinner />;

      aiState.done([
        ...aiState.get(),
        {
          role: "function",
          name: nanoid(),
          content: "Please select a voice",
          complete: true,
        },
      ]);

      const { voice } = await getSettings();

      return <ChangeVoiceCard initialVoice={voice} />;
    },
  };
}
