import { DOWNLOAD, REPO, VERSION, absoluteUrl, faqs, features, site, states } from "@/lib/site";

export const dynamic = "force-static";

/** llms.txt: concise, LLM-friendly summary (https://llmstxt.org). */
export function GET() {
  const body = [
    `# ${site.name}`,
    "",
    `> ${site.description}`,
    "",
    `- Platform: ${site.requirements}`,
    `- Price: free, open source (MIT)`,
    `- Latest version: ${VERSION}`,
    `- Download: ${DOWNLOAD}`,
    `- Source code: ${REPO}`,
    `- Privacy: works offline, no network requests, no analytics, no account`,
    "",
    "## How it signals time",
    ...states.map((s) => `- ${s.name} (${s.when}): ${s.what}`),
    "",
    "## Features",
    ...features.map((f) => `- ${f.title}: ${f.body}`),
    "",
    "## FAQ",
    ...faqs.flatMap((f) => [`### ${f.q}`, f.a, ""]),
    `- [Website](${absoluteUrl("/")})`,
    "",
  ].join("\n");
  return new Response(body, { headers: { "Content-Type": "text/plain; charset=utf-8" } });
}
