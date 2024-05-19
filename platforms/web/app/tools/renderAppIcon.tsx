import Skeleton from "@/components/Skeleton";
import RenderAppIconCard from "@/components/cards/RenderAppIconCard";
import OpenAI from "openai";
import { z } from "zod";

const openai = new OpenAI();

export default function renderAppIcon({ aiState }: any) {
  return {
    description:
      "Render an app icon if these properties are provided by the user: description, color and style. Call this function again if this request is made.",
    parameters: z
      .object({
        description: z.string().describe("A description for the app icon"),
        color: z.string(),
        style: z.string(),
      })
      .required(),
    render: async function* ({
      description,
      color,
      style,
    }: {
      description: string;
      color: string;
      style: string;
    }) {
      console.log("renderAppIcon");

      yield (
        <div className="flex flex-col gap-4">
          <div className="grid grid-cols-2 gap-4">
            {Array.from({ length: 4 }).map((_, index) => (
              <div
                className="flex flex-col gap-4 justify-center items-center"
                key={index}
              >
                <Skeleton className="aspect-square rounded-2xl w-36 md:w-64" />
              </div>
            ))}
          </div>
          <div className="flex justify-center">
            <Skeleton className="rounded-2xl" width={87.81} height={34} />
          </div>
        </div>
      );

      const generations: Array<Promise<string>> = [];

      async function handleGeneration() {
        const image = await openai.images.generate({
          prompt: `Create an image with a ${style} aesthetic with ${color} as the primary color. It should be very simple, with a slightly abstract form, giving it a modern artistic touch. The image should be of: ${description}`,
          model: "dall-e-3",
          quality: "standard",
          response_format: "b64_json",
          size: "1024x1024",
        });

        return `data:image/png;base64,${image.data[0].b64_json!}`;
      }

      for (let i = 0; i < 4; i++) {
        generations.push(handleGeneration());
      }

      const imageUrls = await Promise.all(generations);

      aiState.done([
        ...aiState.get(),
        {
          role: "function",
          name: "render_app_icon_complete",
          content: "",
          complete: true,
        },
      ]);

      return <RenderAppIconCard imageUrls={imageUrls} />;
    },
  };
}
