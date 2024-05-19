import Spinner from "@/components/Spinner";
import { chromium } from "playwright";
import { z } from "zod";

interface Item {
  title: string;
  url: string;
  description: string;
  image: string;
}

function HackerNewsCard({ items }: { items: Item[] }) {
  return (
    <div className="flex flex-col gap-4 list-none">
      {items.map((item) => (
        <li className="w-72" key={item.title}>
          <a
            className="flex relative w-full"
            href={item.url}
            rel="noopener noreferrer"
            target="_blank"
          >
            {item.image ? (
              <img
                className="aspect-video object-cover w-full"
                src={item.image}
              />
            ) : (
              <div className="aspect-video bg-gray-600 w-full" />
            )}
            <div className="absolute bg-black bg-opacity-50 bottom-1 left-1 text-sm px-2 rounded-2xl text-white whitespace-nowrap text-ellipsis overflow-hidden max-w-36">
              {item.title}
            </div>
          </a>
        </li>
      ))}
    </div>
  );
}

async function fetchOgTags(url: string) {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto(url);

  const ogTags = await page.evaluate(() => {
    const tags: {
      [key: string]: string;
    } = {};
    document.querySelectorAll('meta[property^="og:"]').forEach((tag) => {
      const property = tag.getAttribute("property") || "";
      const content = tag.getAttribute("content") || "";
      tags[property] = content;
    });
    return tags;
  });

  await browser.close();
  return ogTags;
}

async function fetchStory(id: number) {
  const res = await fetch(
    `https://hacker-news.firebaseio.com/v0/item/${id}.json`
  );
  const data = (await res.json()) as {
    title: string;
    url: string;
  };

  const ogTags = await fetchOgTags(data.url);

  return {
    title: data.title,
    url: data.url,
    description: ogTags["og:description"],
    image: ogTags["og:image"],
  };
}

async function getHackerNewsApi(type: "top" | "new" | "best") {
  const topRes = await fetch(
    `https://hacker-news.firebaseio.com/v0/${type}stories.json`
  );
  const topData = (await topRes.json()) as number[];

  let i = 0;
  const results = [];
  for (const id of topData.slice(1)) {
    if (i > 2) {
      break;
    }
    const result = fetchStory(id);
    results.push(result);
    i++;
  }
  const res = await Promise.all(results);

  return res;
}

export default function getHackerNews({ aiState }: any) {
  return {
    description: "Get Hacker News",
    parameters: z
      .object({
        type: z
          .enum(["top", "new", "best"])
          .describe("type of news stories")
          .default("top"),
      })
      .required(),
    render: async function* ({
      type = "top",
    }: {
      type: "top" | "new" | "best";
    }) {
      console.log("getHackerNews");

      yield (
        <div className="gap-4 grid grid-cols-3 list-none">
          {Array.from({ length: 3 }).map((_, index) => (
            <li key={index}>
              <a className="relative" rel="noopener noreferrer" target="_blank">
                <div className="aspect-video animate-pulse bg-gray-600 w-full" />
              </a>
            </li>
          ))}
        </div>
      );

      const hackerNews = await getHackerNewsApi(type);

      aiState.done([
        ...aiState.get(),
        {
          role: "function",
          name: "get_weather",
          content: hackerNews.map((item) => item.title).join("\n"),
          complete: true,
        },
      ]);

      return <HackerNewsCard items={hackerNews} />;
    },
  };
}
