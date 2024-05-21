import saveSettings from "@/utils/saveSettings";

export async function POST(req: Request) {
  const { key, value } = (await req.json()) as {
    key: string;
    value: string;
  };

  await saveSettings(key, value);

  return Response.json({});
}
