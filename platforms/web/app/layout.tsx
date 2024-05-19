import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { AI } from "./action";
import classNames from "@/utils/classNames";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Crystal",
  description: "Your personal open source virtual assistant",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={classNames("min-h-dvh", inter.className)}>
        <AI>{children}</AI>
      </body>
    </html>
  );
}
