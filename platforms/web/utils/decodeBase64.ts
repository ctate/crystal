export default function decodeBase64(base64String: string): Buffer {
  return Buffer.from(base64String, "base64");
}
