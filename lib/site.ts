// Single source of truth for page copy, SEO metadata, JSON-LD and llms.txt.

export const BASE_PATH = (process.env.NEXT_PUBLIC_BASE_PATH ?? "/glint").replace(/\/$/, "");
export const SITE_URL = (process.env.NEXT_PUBLIC_SITE_URL ?? "https://salahu01.github.io/glint").replace(/\/$/, "");
export const REPO = "https://github.com/salahu01/glint-app";
export const DOWNLOAD = `${REPO}/releases/latest`;
export const VERSION = "1.6.1";
/** Prefix for files in /public (static export does not add basePath to plain <img> src). */
export const asset = (p: string) => `${BASE_PATH}${p}`;
export const absoluteUrl = (p = "/") => `${SITE_URL}${p === "/" ? "/" : p}`;

export const site = {
  name: "Glint",
  title: "Glint: Always-on-Top Clock for Mac That Makes You Feel Time Pass",
  tagline: "Feel time pass.",
  description:
    "Glint is a free, open-source macOS clock for people who lose track of time. It floats above every window and full-screen app, ticks like a real clock, and flashes when a minute or hour changes, with interval nudges, focus blocks and a visual time-depletion dial.",
  keywords: [
    "always on top clock mac",
    "floating clock mac",
    "time blindness app",
    "adhd time awareness mac",
    "visual timer mac",
    "pomodoro timer mac",
    "hourly chime mac",
    "desktop clock mac",
    "menu bar clock app",
    "focus timer mac",
    "time timer mac",
    "open source mac app",
    "Glint",
  ],
  author: { name: "Muhammed Swalahudheen C V", url: "https://salahu01.github.io", github: "https://github.com/salahu01" },
  themeColor: "#0e0f1d",
  requirements: "macOS 13 Ventura or later · Apple silicon & Intel",
};

/** Mirrors clockThemes in the app (Sources/Glint/ClockModel.swift). */
export const themes = [
  { name: "Indigo", top: "#1A1A2E", bottom: "#16213E", glow: "#00F5D4" },
  { name: "Midnight", top: "#0D1B2A", bottom: "#1B263B", glow: "#E0AAFF" },
  { name: "Forest", top: "#1B2A1B", bottom: "#14241C", glow: "#95D5B2" },
  { name: "Slate", top: "#2B2D42", bottom: "#1D1E2C", glow: "#8ECAE6" },
  { name: "Crimson", top: "#2A0E0E", bottom: "#1A0606", glow: "#FF6B6B" },
];

export const states = [
  { name: "Calm", when: ":00 – :49", what: "Deep base colour, glowing digits, a soft tick and tock every second.", from: "#1A1A2E", to: "#16213E" },
  { name: "Buildup", when: ":50 – :59", what: "A warm amber-to-red wash fades in: a change is coming.", from: "#FF9F1C", to: "#E71D36" },
  { name: "Minute", when: "every minute", what: "A teal burst and a single chime. Another minute, gone.", from: "#2EC4B6", to: "#00F5D4" },
  { name: "Hour", when: "every hour", what: "A bigger orange-to-magenta burst and a double chime.", from: "#FB5607", to: "#FF006E" },
  { name: "Nudge", when: "your interval", what: "A violet blink and a triple chime: time check, maybe a break.", from: "#7B2FF7", to: "#00F5D4" },
];

export const features = [
  { icon: "🪟", title: "Always on top, every Space", body: "A borderless floating panel that rides over every window and full-screen app, like picture-in-picture." },
  { icon: "🔔", title: "A clock you can hear", body: "Real tick and tock every second, chimes on the minute and hour. All sound is synthesised in code." },
  { icon: "⏰", title: "Interval nudges", body: "Every 15, 25, 30 or 60 minutes Glint blinks and chimes: a deliberate time check." },
  { icon: "🎯", title: "Focus blocks", body: "Start a 25 or 50 minute block. A live countdown sits on the face and Glint celebrates when it ends." },
  { icon: "⏱️", title: "Stopwatch", body: "Start, pause, resume and reset a count-up timer right on the clock face." },
  { icon: "⏳", title: "Time sitting", body: "See how long you've been at it this session, with a one-click reset." },
  { icon: "⏲️", title: "Visual time depletion", body: "A shrinking ring or emptying disk shows time running out. You see it instead of reading digits." },
  { icon: "🔴", title: "Dial Mode", body: "The whole face becomes a red-disk dial with a 0–55 minute ring. Pure, glanceable, number-light time." },
  { icon: "📞", title: "Auto-mute in calls", body: "Ticking goes quiet while your mic is in use. No microphone permission: it only reads device state." },
  { icon: "🧘", title: "Calm Mode", body: "Swaps the alarm-style bursts for gentle depletion, so you stay aware without the anxiety." },
  { icon: "🎨", title: "Five colour themes", body: "Indigo, Midnight, Forest, Slate and Crimson. Three sizes, three flash strengths, 12 or 24 hour." },
  { icon: "🚀", title: "Launch at login", body: "One toggle and Glint is always there. Drag it to any corner; it remembers everything." },
];

export const installSteps = [
  { name: "Download", text: "Download the latest Glint .dmg from GitHub Releases." },
  { name: "Install", text: "Open the .dmg and drag Glint into your Applications folder." },
  { name: "Open", text: "Open Glint. The clock appears in the top-right corner and its settings live in the menu bar. On first launch, if macOS cannot verify the developer, right-click Glint → Open → Open." },
];

export const faqs = [
  {
    q: "What is Glint?",
    a: "Glint is a free, open-source macOS clock for people who lose track of time. It floats above every window, ticks like a real mechanical clock, and flashes in bold colour when a minute or hour changes, so you feel time passing without having to remember to look.",
  },
  {
    q: "Does Glint help with time blindness or ADHD?",
    a: "Glint was built for people who look up and realise hours have vanished, including many people with ADHD or time blindness. It makes time ambient: a warm wash before each minute ends, a flash and chime when it changes, interval nudges, and a visual depletion dial inspired by research on number-free timers. It is a tool, not a medical treatment.",
  },
  {
    q: "Is Glint free?",
    a: "Yes. Glint is completely free and open source under the MIT licence. No ads, subscriptions, in-app purchases or accounts.",
  },
  {
    q: "Which Macs and macOS versions does Glint support?",
    a: "Glint runs on macOS 13 Ventura and newer, on both Apple silicon and Intel Macs. The download is a universal app of about 3.5 MB.",
  },
  {
    q: "Will the ticking get into my video calls?",
    a: "Not if you turn on Auto-Mute in Calls. Glint silences itself while your microphone is in use. It checks only whether the input device is running, so it needs no microphone permission and never hears anything. You can also mute ticking any time with ⌘M.",
  },
  {
    q: "Can Glint work as a Pomodoro or focus timer?",
    a: "Yes. Start a 25 or 50 minute focus block from the menu bar. The countdown shows on the clock face, the depletion ring or dial empties as you go, and Glint blinks and chimes when the block ends.",
  },
  {
    q: "Does Glint collect any data?",
    a: "No. Glint makes no network requests and has no analytics or accounts. Its only stored data is your preferences, kept on your Mac.",
  },
  {
    q: "Why does macOS warn me the first time I open it?",
    a: "Glint isn't notarised by Apple yet, which needs a paid developer account. Right-click Glint in Applications → Open → Open, once. On macOS 15 and later you may need System Settings → Privacy & Security → Open Anyway. The source code is public, so you can also build it yourself.",
  },
];
