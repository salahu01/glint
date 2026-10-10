# Glint website

Marketing site for [Glint](https://github.com/salahu01/glint-app), the always-on-top Mac clock that flashes
when a minute or hour changes. Live at **https://salahu01.github.io/glint/**.

Next.js static export with a live, in-browser replica of the Glint clock (buildup wash, minute/hour/nudge
flashes, ring and dial faces, all five themes and synthesised tick sound).

```bash
npm install
npm run dev        # http://localhost:3000/glint/
npm run deploy     # build and publish out/ to the gh-pages branch
```

Copy, SEO metadata, JSON-LD and `llms.txt` all come from `lib/site.ts`. Screenshots in `public/media/`
are captured from the real app (see the app repo's `docs/`).

MIT licensed.
