import { dirname, join } from "path";
import getSettings from "./getSettings";
import { mkdir, writeFile } from "fs/promises";
import { existsSync } from "fs";

export default async function saveSettings(key: string, value: string) {
  const settings = getSettings();
  (settings as any)[key] = value;

  const file = join(process.cwd(), ".crystal/settings.json");
  const dir = dirname(file);
  if (!existsSync(file)) {
    await mkdir(dir, { recursive: true });
  }
  await writeFile(file, JSON.stringify(settings, null, 2));
}
