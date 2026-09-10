import type { Metadata } from "next";
import type { ReactNode } from "react";
import "./globals.css";

export const metadata: Metadata = {
  title: "Kelime Rotası",
  description: "LGS 8. sınıf İngilizce kelime çalışma uygulaması",
};

type Props = Readonly<{
  children: ReactNode;
}>;

export default function RootLayout({ children }: Props) {
  return (
    <html lang="tr">
      <body>{children}</body>
    </html>
  );
}
