import type { MetadataRoute } from "next";
import { BASE_PATH, site } from "@/lib/site";

export const dynamic = "force-static";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: site.title,
    short_name: site.name,
    description: site.description,
    start_url: `${BASE_PATH}/`,
    display: "standalone",
    background_color: site.themeColor,
    theme_color: site.themeColor,
    icons: [{ src: `${BASE_PATH}/glint-icon.png`, sizes: "1024x1024", type: "image/png" }],
  };
}
