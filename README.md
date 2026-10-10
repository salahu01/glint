# Glint website

Marketing site for [Glint](https://github.com/salahu01/glint-app), the always-on-top Mac clock that flashes
when a minute or hour changes. Live at **https://salahu01.github.io/glint/**.

A scroll-driven motion showreel (Next.js static export, GSAP ScrollTrigger + SplitText, Lenis):
a live in-browser Glint clock in the hero, a time-lapse that scrubs 9:00 → 12:47 as you scroll,
one card morphing through the five states, a horizontal feature reel, a desktop showcase,
and a closing dial that depletes into the CTA. Respects `prefers-reduced-motion`; full-screen
flashes are throttled to one per 1.5 s.

Motion lives in `components/Showreel.tsx`; all copy is plain HTML in `app/page.tsx`.

```bash
npm install
npm run dev        # http://localhost:3000/glint/
npm run deploy     # build and publish out/ to the gh-pages branch
```

Copy, SEO metadata, JSON-LD and `llms.txt` all come from `lib/site.ts`. Screenshots in `public/media/`
are captured from the real app (see the app repo's `docs/`).

MIT licensed.
