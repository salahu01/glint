import type { NextConfig } from "next";

// Static export for GitHub Pages (https://salahu01.github.io/glint). Override the base path with
// NEXT_PUBLIC_BASE_PATH="" if the site moves to a custom domain.
const basePath = (process.env.NEXT_PUBLIC_BASE_PATH ?? "/glint").replace(/\/$/, "");

const nextConfig: NextConfig = {
  output: "export",
  trailingSlash: true,
  basePath,
  images: { unoptimized: true },
  poweredByHeader: false,
  reactStrictMode: true,
};

export default nextConfig;
