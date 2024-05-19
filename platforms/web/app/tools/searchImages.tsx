import Skeleton from "@/components/Skeleton";
import ImageCard from "@/components/cards/ImageCard";
import OpenAI from "openai";
import { google } from "googleapis";
import { z } from "zod";

export default function searchImages({ aiState }: any) {
  return {
    description: "Search images",
    parameters: z
      .object({
        query: z.string(),
      })
      .required(),
    render: async function* ({ query }: { query: string }) {
      console.log("searchImages");

      yield (
        <div>
          <Skeleton width={256} height={256} />
        </div>
      );

      const res = await google.customsearch("v1").cse.list({
        auth: process.env.GOOGLE_SEARCH_API_KEY!,
        cx: "17486b203b6a74b0a",
        q: query,
        searchType: "image",
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
        <div className="gap-4 grid grid-cols-3 items-center justify-center">
          {res.data.items!.slice(0, 9).map((item) => (
            <ImageCard key={item.cacheId} imageUrl={item.link!} size={150} />
          ))}
        </div>
      );
    },
  };
}
