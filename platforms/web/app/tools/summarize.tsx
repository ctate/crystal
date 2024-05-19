import Spinner from "@/components/Spinner";
import OpenAI from "openai";
import { chromium } from "playwright";
import Markdown from "react-markdown";
import sharp from "sharp";
import { z } from "zod";

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY || "",
});

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

  const content = await page.content();
  const buffer = await page.screenshot({ fullPage: true });
  await browser.close();

  const base64Image = buffer.toString("base64");
  const base64URL = `data:image/png;base64,${base64Image}`;

  try {
    const completion = await openai.chat.completions.create({
      messages: [
        {
          role: "system",
          content: "You are an expert summarizer",
        },
        {
          role: "user",
          content: `Summarize this: ${content}`,
        },
      ],
      model: "gpt-3.5-turbo-0125",
    });

    return {
      summary: completion.choices[0].message.content!,
      image: base64URL,
    };
  } catch (error) {
    console.error(error);
    return {
      summary: "",
      image: base64URL,
    };
  }
}

export default function summarize({ aiState }: any) {
  return {
    description: "Summarize a web page",
    parameters: z
      .object({
        url: z.string().describe("a url"),
      })
      .required(),
    render: async function* ({ url }: { url: string }) {
      console.log("summarize");

      yield <Spinner />;

      const summary = await summarizeApi(url);

      aiState.done([
        ...aiState.get(),
        {
          role: "function",
          name: "summarize",
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
