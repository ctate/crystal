import Skeleton from "@/components/Skeleton";
import ImageCard from "@/components/cards/ImageCard";
import OpenAI from "openai";
import { google } from "googleapis";
import { z } from "zod";

const openai = new OpenAI();

export default function searchWeb({ aiState }: any) {
  return {
    description: "Search web",
    parameters: z
      .object({
        query: z.string(),
      })
      .required(),
    render: async function* ({ query }: { query: string }) {
      console.log("searchWeb");

      yield (
        <div>
          <Skeleton width={256} height={256} />
        </div>
      );

      const res = await google.customsearch("v1").cse.list({
        auth: process.env.GOOGLE_SEARCH_API_KEY!,
        cx: "17486b203b6a74b0a",
        q: query,
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
        <div className="flex flex-col gap-4">
          {res.data.items!.slice(0, 9).map((item) => (
            <div key={item.cacheId}>{item.title}</div>
          ))}
        </div>
      );
    },
  };
}
