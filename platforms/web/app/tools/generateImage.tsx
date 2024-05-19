import Skeleton from "@/components/Skeleton";
import ImageCard from "@/components/cards/ImageCard";
import OpenAI from "openai";
import { z } from "zod";

const openai = new OpenAI();

export default function generateImage({ aiState }: any) {
  return {
    description:
      "Generate an image. Only use if user asks to generate an image.",
    parameters: z
      .object({
        subject: z.string(),
      })
      .required(),
    render: async function* ({ subject }: { subject: string }) {
      console.log("generateImage");

      yield (
        <div>
          <Skeleton width={256} height={256} />
        </div>
      );

      const image = await openai.images.generate({
        prompt: subject,
        model: "dall-e-3",
        quality: "standard",
        response_format: "b64_json",
        size: "1024x1024",
      });

      aiState.done([
        ...aiState.get(),
        {
          role: "function",
          name: "generate_id",
          content: "",
          complete: true,
        },
      ]);

      return (
        <ImageCard
          imageUrl={`data:image/png;base64,${image.data[0].b64_json!}`}
        />
      );
    },
  };
}
