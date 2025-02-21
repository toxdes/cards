import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Cards | Home",
  description: "Access all your saved cards instantly.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
