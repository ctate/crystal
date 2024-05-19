import Spinner from "@/components/Spinner";
import OpenAI from "openai";
import { chromium } from "playwright";
import Markdown from "react-markdown";
import sharp from "sharp";
import { z } from "zod";

const openai = new OpenAI();

interface SummaryInfo {
  summary: string;
  image: string;
}

function SummaryCard({ summary }: { summary: SummaryInfo }) {
  return (
    <div>
      <p>
        <Markdown>{summary.summary}</Markdown>
      </p>
      <img src={summary.image} />
    </div>
  );
}

async function summarizeApi(url: string) {
  const browser = await chromium.launch();
  const context = await browser.newContext({
    userAgent:
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
  });
  const page = await context.newPage();

  await page.goto(url);

  const buffer = await page.screenshot({ fullPage: true });
  await browser.close();

  const resizedBuffer = await sharp(buffer)
    .resize({
      width: 640,
      fit: "inside",
    })
    .toBuffer();
  const base64Image = resizedBuffer.toString("base64");
  const base64URL = `data:image/png;base64,${base64Image}`;

  const completion = await openai.chat.completions.create({
    messages: [
      {
        role: "system",
        content: "You are a web page summarizer",
      },
      {
        role: "user",
        content: [
          {
            image_url: {
              url: base64URL,
            },
            type: "image_url",
          },
          {
            text: "Summarize this image",
            type: "text",
          },
        ],
      },
    ],
    model: "gpt-4-turbo-2024-04-09",
  });

  return {
    summary: completion.choices[0].message.content!,
    image: base64URL,
  };
}

export default function summarizeScreenshot({ aiState }: any) {
  return {
    description: "Summarize a web page with an image",
    parameters: z
      .object({
        url: z.string().describe("a url"),
      })
      .required(),
    render: async function* ({ url }: { url: string }) {
      console.log("summarizeScreenshot");

      yield <Spinner />;

      const summary = await summarizeApi(url);

      aiState.done([
        ...aiState.get(),
        {
          role: "function",
          name: "summarize_image",
          content: JSON.stringify({
            summary: summary.summary,
          }),
          complete: true,
        },
      ]);

      return <SummaryCard summary={summary} />;
    },
  };
}
