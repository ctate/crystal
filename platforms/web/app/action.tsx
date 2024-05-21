import { OpenAI } from "openai";
import { createAI, getMutableAIState, render } from "ai/rsc";
import { ReactNode } from "react";
import getWeather from "./tools/getWeather";
import getHackerNews from "./tools/getHackerNews";
import summarize from "./tools/summarize";
import summarizeScreenshot from "./tools/summarizeScreenshot";
import generateId from "./tools/generateId";
import generateImage from "./tools/generateImage";
import searchImages from "./tools/searchImages";
import searchWeb from "./tools/searchWeb";
import Markdown from "react-markdown";
import classNames from "@/utils/classNames";
import visitWebsite from "./tools/visitWebsite";
import searchYouTube from "./tools/searchYouTube";
import { ChatCompletionContentPart } from "ai/prompts";
import generateAppIcon from "./tools/generateAppIcon";
import renderAppIcon from "./tools/renderAppIcon";
import changeVoice from "./tools/changeVoice";
import saveVoiceSetting from "./tools/saveVoiceSetting";
import pokedex from "./tools/pokedex";
import makeRecipe from "./tools/recipe";
import getSettings from "@/utils/getSettings";
import saveSettings from "@/utils/saveSettings";

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY || "",
});

export async function saveSetting(key: string, value: string): Promise<void> {
  "use server";

  await saveSettings(key, value);
}

async function submitUserImage(
  input: string,
  imageUrl: string
): Promise<UIState> {
  "use server";

  const aiState = getMutableAIState<typeof AI>();

  aiState.update([
    ...aiState.get().map((state) => ({
      role: state.role,
      content: state.content,
      name: state.name,
    })),
    {
      role: "user",
      content: [
        {
          text: input,
          type: "text",
        },
        {
          type: "image_url",
          image_url: {
            url: imageUrl,
          },
        },
      ],
    },
  ]);

  const ui = render({
    model: "gpt-4-turbo-2024-04-09",
    provider: openai,
    messages: [
      {
        role: "system",
        content: `You are a virtual assistant. Today's date: ${new Date().toDateString()}`,
      },
      ...(aiState as any).get(),
    ],
    text: ({ content, done }) => {
      if (done) {
        setTimeout(
          () =>
            aiState.done([
              ...aiState.get(),
              {
                role: "assistant",
                content,
                complete: true,
              },
            ]),
          100
        );
      }

      return (
        <div>
          <Markdown
            components={{
              pre: ({ className, ...props }) => (
                <pre
                  {...props}
                  className={classNames(
                    className,
                    "bg-black my-4 p-4 text-left text-sm"
                  )}
                />
              ),
            }}
          >
            {content}
          </Markdown>
        </div>
      );
    },
    tools: {
      pokedex: pokedex({ aiState }),
    },
  });

  return Promise.resolve({
    id: Date.now(),
    display: ui,
    role: "assistant",
  });
}

async function submitUserMessage(input: string): Promise<UIState> {
  "use server";

  const aiState = getMutableAIState<typeof AI>();

  aiState.update([
    ...aiState
      .get()
      .filter((state) => typeof state.content === "string")
      .map((state) => ({
        role: state.role,
        content: state.content,
        name: state.name,
      })),
    {
      role: "user",
      content: input,
    },
  ]);

  const { model } = await getSettings();

  const ui = render({
    model,
    provider: openai,
    messages: [
      {
        role: "system",
        content: `You are a virtual assistant. Today's date: ${new Date().toDateString()}`,
      },
      ...(aiState as any).get(),
    ],
    text: ({ content, done }) => {
      if (done) {
        setTimeout(
          () =>
            aiState.done([
              ...aiState.get(),
              {
                role: "assistant",
                content,
                complete: true,
              },
            ]),
          100
        );
      }

      return (
        <div className="text-center">
          <Markdown
            components={{
              pre: ({ className, ...props }) => (
                <pre
                  {...props}
                  className={classNames(
                    className,
                    "bg-black my-4 p-4 text-left text-sm"
                  )}
                />
              ),
            }}
          >
            {content}
          </Markdown>
        </div>
      );
    },
    tools: {
      change_voice: changeVoice({ aiState }),
      generate_app_icon: generateAppIcon({ aiState }),
      generate_id: generateId({ aiState }),
      generate_image: generateImage({ aiState }),
      get_hacker_news: getHackerNews({ aiState }),
      get_weather: getWeather({ aiState }),
      make_recipe: makeRecipe({ aiState }),
      render_app_icon: renderAppIcon({ aiState }),
      save_voice_setting: saveVoiceSetting({ aiState }),
      search_images: searchImages({ aiState }),
      search_you_tube: searchYouTube({ aiState }),
      search_web: searchWeb({ aiState }),
      summarize: summarize({ aiState }),
      summarize_screenshot: summarizeScreenshot({ aiState }),
      visit_website: visitWebsite({ aiState }),
    },
  });

  return Promise.resolve({
    id: Date.now(),
    display: ui,
    role: "assistant",
  });
}

async function submitUserVoice(form: FormData): Promise<string> {
  "use server";

  const file = form.get("file") as File;

  const transcription = await openai.audio.transcriptions.create({
    file,
    model: "whisper-1",
  });

  return transcription.text;
}

interface AIState {
  role: "user" | "assistant" | "system" | "function";
  content: string | Array<ChatCompletionContentPart>;
  id?: string;
  name?: string;
  complete?: boolean;
}

interface UIState {
  id: number;
  display: ReactNode;
  role: string;
}

const initialAIState: AIState[] = [];

const initialUIState: UIState[] = [];

export const AI = createAI<
  AIState[],
  UIState[],
  {
    submitUserImage: (input: string, imageUrl: string) => Promise<UIState>;
    submitUserMessage: (input: string) => Promise<UIState>;
    submitUserVoice: (form: FormData) => Promise<string>;
  }
>({
  actions: {
    submitUserImage,
    submitUserMessage,
    submitUserVoice,
  },
  initialUIState,
  initialAIState,
});
