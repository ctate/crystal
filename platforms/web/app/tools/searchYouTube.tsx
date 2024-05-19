import Skeleton from "@/components/Skeleton";
import OpenAI from "openai";
import { google } from "googleapis";
import { z } from "zod";

function YouTubeCard({ videoId }: { videoId: string }) {
  return (
    <div className="flex flex-col gap-2 justify-center items-center">
      <iframe
        width="560"
        height="315"
        src={`https://www.youtube.com/embed/${videoId}?autoplay=1`}
        title="YouTube video player"
        frameBorder="0"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
        referrerPolicy="strict-origin-when-cross-origin"
        allowFullScreen
      />
    </div>
  );
}

export default function searchYouTube({ aiState }: any) {
  return {
    description:
      "Search YouTube. If someone asks to play music or a video, you can just use YouTube to search for it and play it.",
    parameters: z
      .object({
        query: z.string(),
      })
      .required(),
    render: async function* ({ query }: { query: string }) {
      console.log("searchYouTube");

      yield (
        <div>
          <Skeleton width={256} height={256} />
        </div>
      );

      const res = await google.youtube("v3").search.list({
        auth: process.env.GOOGLE_SEARCH_API_KEY!,
        q: query,
        part: ["snippet"],
      });

      console.log(JSON.stringify(res.data.items![0], null, 2));

      aiState.done([
        ...aiState.get(),
        {
          role: "function",
          name: "search_you_tube",
          content: "",
          complete: true,
        },
      ]);

      return (
        <div className="flex flex-col gap-4">
          <YouTubeCard videoId={res.data.items![0].id!.videoId!} />
        </div>
      );
    },
  };
}
