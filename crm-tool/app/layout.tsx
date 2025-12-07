// app/layout.tsx
import "./globals.css";
import type { Metadata } from "next";
import { Providers } from "./providers";

export const metadata: Metadata = {
  title: "CRM Tool",
  description: "LearnLynk technical test dashboard",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        {/* Only pass JSX children (a plain object), not QueryClient */}
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
