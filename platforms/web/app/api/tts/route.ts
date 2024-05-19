import getSettings from "@/utils/getSettings";
import { createHash } from "crypto";
import { existsSync } from "fs";
import { mkdir, readFile, writeFile } from "fs/promises";
import OpenAI from "openai";
import { dirname } from "path";

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY || "",
});

function md5(string: string) {
  return createHash("md5").update(string).digest("hex");
}

export async function GET(req: Request) {
  const url = new URL(req.url);
  const input = url.searchParams.get("input")!;

  if (!input) {
    return new Response();
  }

  const settings = await getSettings();
  const voice = settings.voice || "alloy";

  const file = `./audio/${voice}-${md5(input)}.mp3`;
  const dir = dirname(file);

  if (!existsSync(dir)) {
    await mkdir(dir, { recursive: true });
  }

  if (!existsSync(file)) {
    console.log("storing");

    const mp3 = await openai.audio.speech.create({
      model: "tts-1",
      voice,
      input,
      response_format: "mp3",
    });

    await writeFile(file, Buffer.from(await mp3.arrayBuffer()));
  }

  return new Response(await readFile(file));
}
