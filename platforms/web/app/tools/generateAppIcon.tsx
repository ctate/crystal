import Skeleton from "@/components/Skeleton";
import GenerateAppIconCard from "@/components/cards/GenerateAppIconCard";
import OpenAI from "openai";
import { z } from "zod";

export default function generateAppIcon({ aiState }: any) {
  return {
    description:
      "Generate an app icon for iOS and Android. The user must specify an exact subject in their prompt.",
    parameters: z
      .object({
        subject: z
          .string()
          .describe("The subject to represent in the app icon."),
      })
      .required(),
    render: async function* ({ subject }: { subject: string }) {
      console.log("generateAppIcon");

      yield (
        <div>
          <Skeleton width={256} height={256} />
        </div>
      );

      aiState.done([
        ...aiState.get(),
        {
          role: "function",
          name: "generate_id",
          content:
            "Sure, I can help you with that. Just choose a color and a style and I'll create 4 variations for you to try out.",
          complete: true,
        },
      ]);

      return <GenerateAppIconCard description={subject} />;
    },
  };
}
