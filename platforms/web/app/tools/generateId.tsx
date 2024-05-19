import IdCard from "@/components/IdCard";
import { z } from "zod";

export default function generateId({ aiState }: any) {
  return {
    description: "Generate a unique identifier",
    parameters: z
      .object({
        type: z.enum(["nanoid", "uuid"]).describe("type of id").default("uuid"),
      })
      .required(),
    render: async function* ({ type }: { type: "nanoid" | "uuid" }) {
      console.log("generateId");

      aiState.done([
        ...aiState.get(),
        {
          role: "function",
          name: "generate_id",
          content: "",
          complete: true,
        },
      ]);

      return <IdCard type={type} />;
    },
  };
}
