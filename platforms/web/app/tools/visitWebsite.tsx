import Spinner from "@/components/Spinner";
import OpenAI from "openai";
import { chromium } from "playwright";
import Markdown from "react-markdown";
import sharp from "sharp";
import { z } from "zod";

const openai = new OpenAI();

interface WebPageInfo {
  url: string;
}

function WebPageCard({ url }: WebPageInfo) {
  return (
    <iframe
      className="fixed left-0 top-0 right-0 bottom-0 w-screen h-screen -z-10"
      src={url}
    />
  );
}

export default function visitWebsite({ aiState }: any) {
  return {
    description: "Open a web page",
    parameters: z
      .object({
        url: z.string().describe("a url"),
      })
      .required(),
    render: async function* ({ url }: { url: string }) {
      console.log("visitWebsite");

      yield <Spinner />;

      aiState.done([
        ...aiState.get(),
        {
          role: "function",
          name: "visit_website",
          content: JSON.stringify({
            url,
          }),
          complete: true,
        },
      ]);

      return <WebPageCard url={url} />;
    },
  };
}
