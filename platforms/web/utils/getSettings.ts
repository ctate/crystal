import { existsSync } from "fs";
import { readFile } from "fs/promises";
import { join } from "path";

export default async function getSettings() {
  const file = join(process.cwd(), ".crystal/settings.json");
  const content = existsSync(file) ? await readFile(file, "utf8") : "{}";
  const data = JSON.parse(content) as {
    voice?: "alloy" | "echo" | "fable" | "onyx" | "nova" | "shimmer";
  };
  return data;
}
