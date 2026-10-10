/* eslint-disable @next/next/no-img-element -- static export: plain <img> with basePath-aware src */
import LiveClock from "@/components/LiveClock";
import Showreel from "@/components/Showreel";
import { DOWNLOAD, REPO, VERSION, asset, faqs, features, site, states } from "@/lib/site";

const marquee = ["tick", "tock", "a minute passed", "time check", "focus", "stay aware", "an hour passed", "breathe", "feel time pass"];

/** One mini composition per feature panel in the horizontal reel. */
const reel = [
  { n: "01", tag: "Always there", title: <>Above <em>everything.</em></>, body: features[0].body, vis: "float" },
  { n: "02", tag: "Interval nudges", title: <>A tap on the <em>shoulder.</em></>, body: features[2].body, vis: "nudge" },
  { n: "03", tag: "Focus blocks", title: <>Watch it <em>empty.</em></>, body: features[3].body + " " + features[6].body, vis: "ring" },
  { n: "04", tag: "Dial Mode", title: <>No numbers. <em>Just time.</em></>, body: features[7].body, vis: "dial" },
  { n: "05", tag: "Auto-mute", title: <>Quiet in <em>calls.</em></>, body: features[8].body, vis: "mute" },
];

const extras = [features[1], features[4], features[5], features[9], features[10], features[11]];

const journey = [
  { t: "00:00", h: "Download", p: "Grab the 3.5 MB universal DMG from GitHub Releases." },
  { t: "00:10", h: "Drag", p: "Drop Glint into Applications. That's the whole install." },
  { t: "00:20", h: "Open", p: "Right-click → Open the first time. The clock lands top-right." },
  { t: "∞", h: "Feel time pass", p: "Every minute, a glint. Every hour, a burst. You stay in your day." },
];

const stats = [
  { n: 0, p: "network requests. Nothing ever leaves your Mac" },
  { n: 0, pre: "$", p: "forever. Free and open source under MIT" },
  { n: 5, p: "states that turn time into light" },
  { n: 0, p: "audio files. Every tick and chime is synthesised" },
];

export default function Home() {
  return (
    <>
      <Showreel />
      <div className="grain" aria-hidden="true" style={{ backgroundImage: `url(${asset("/grain.png")})` }} />
      <div className="flashfx" aria-hidden="true" />
      <div className="cursor" aria-hidden="true"><svg viewBox="0 0 40 40"><circle className="track" cx="20" cy="20" r="17" /><circle className="sweep" cx="20" cy="20" r="17" pathLength={60} /></svg><span className="cl" /></div>

      <nav aria-label="Main">
        <div className="wrap">
          <a className="brand" href="#top" data-magnetic><img src={asset("/glint-icon.png")} alt="" width={34} height={34} /><span>Glint</span></a>
          <div className="bar">
            <a href="#states">States</a>
            <a href="#features">Features</a>
            <a href="#showcase">Showcase</a>
            <a href="#faq">FAQ</a>
            <a className="btn sm" href={DOWNLOAD} data-magnetic><span className="lbl">Download</span></a>
          </div>
        </div>
      </nav>

      <main id="main">
        {/* ── 1 · Opening frame ─────────────────────────────── */}
        <section id="top" className="hero">
          <div className="aura a1" data-depth="-30" />
          <div className="aura a2" data-depth="40" />
          <div className="hero-ticks" aria-hidden="true">{Array.from({ length: 60 }, (_, i) => <i key={i} style={{ transform: `rotate(${i * 6}deg)` }} className={i % 5 ? "" : "big"} />)}</div>
          <div className="wrap hero-grid">
            <div className="hero-copy">
              <p className="eyebrow" data-hero-in>Always-on-top clock for Mac · v{VERSION}</p>
              <h1 className="mega" data-mega>
                <span className="l1">Feel time</span>
                <span className="l2"><em>pass.</em></span>
              </h1>
              <p className="lead" data-hero-in>
                For anyone who looks up and realises three hours just vanished. Glint floats above every window, ticks like a
                real clock and <b>flashes the moment a minute or hour changes.</b>
              </p>
              <div className="cta-row" data-hero-in>
                <a className="btn" href={DOWNLOAD} data-magnetic data-cursor="Get it"><span className="lbl">⬇ Download for Mac</span></a>
                <a className="btn ghost" href={REPO} data-magnetic><span className="lbl">★ Star on GitHub</span></a>
              </div>
              <p className="meta" data-hero-in>Free · open source · {site.requirements}</p>
            </div>
            <div className="hero-clock" data-hero-clock data-depth="18">
              <LiveClock />
            </div>
          </div>
          <div className="marquee" aria-hidden="true">
            <div className="track">{[0, 1].map((k) => marquee.map((m, i) => <span key={`${k}${i}`} className={i % 2 ? "o" : ""}>{m}</span>))}</div>
          </div>
        </section>

        {/* ── 2 · Time-lapse: the hours vanish as you scroll ── */}
        <section id="lapse" className="lapse" aria-labelledby="lapse-h">
          <div className="sky" data-sky />
          <div className="lapse-inner">
            <p className="eyebrow">The problem</p>
            <div className="lapse-clock" aria-hidden="true"><span data-lapse>9:00</span><small data-lapse-ampm>AM</small></div>
            <h2 id="lapse-h" className="lapse-text" data-words>
              You sat down at nine. You blinked. A normal clock just sits there, waiting for you to <em>remember</em> to look.
              Glint doesn&apos;t wait. <em>It reaches out to you.</em>
            </h2>
          </div>
        </section>

        {/* ── 3 · One card, five states ─────────────────────── */}
        <section id="states" className="states-scene" aria-labelledby="states-h">
          <div className="wrap states-grid">
            <div>
              <p className="eyebrow">How it works</p>
              <h2 id="states-h" data-split>Five states.<br /><em>Zero</em> effort.</h2>
              <ol className="state-list">
                {states.map((s, i) => (
                  <li key={s.name} data-state-item={i} className={i === 0 ? "on" : ""}>
                    <span className="dot" style={{ background: `linear-gradient(135deg, ${s.from}, ${s.to})` }} />
                    <div><h3>{s.name} <small>{s.when}</small></h3><p>{s.what}</p></div>
                  </li>
                ))}
              </ol>
            </div>
            <div className="stage" data-stage>
              <div className="stage-card">
                {states.map((s, i) => (
                  <div key={s.name} className="layer" data-layer={i} style={{ background: `linear-gradient(135deg, ${s.from}, ${s.to})`, opacity: i === 0 ? 1 : 0 }} />
                ))}
                <div className="stage-hm">10:59</div>
                <div className="stage-ss"><span data-stage-ss>42</span> AM</div>
                <div className="stage-name" data-stage-name>Calm</div>
              </div>
              <div className="pulse" data-pulse />
            </div>
          </div>
        </section>

        {/* ── 4 · Feature reel (horizontal on desktop) ───────── */}
        <section id="features" className="reel-sec" aria-labelledby="reel-h">
          <div className="wrap reel-head">
            <p className="eyebrow">Features</p>
            <h2 id="reel-h" data-split>Small clock. <em>Big</em> awareness.</h2>
          </div>
          <div className="reel" data-reel>
            {reel.map((p) => (
              <article className="panel" key={p.n} data-panel>
                <span className="num" aria-hidden="true">{p.n}</span>
                <div className="pcopy">
                  <p className="eyebrow">{p.tag}</p>
                  <h3>{p.title}</h3>
                  <p>{p.body}</p>
                </div>
                <div className={`vis vis-${p.vis}`} data-tilt aria-hidden="true">
                  {p.vis === "float" && (<>
                    <div className="win w1" data-par="-8"><i /><i /><i /><b /><b /><b /><b /></div>
                    <div className="win w2" data-par="6"><i /><i /><i /><b /><b /><b /></div>
                    <img className="glintf" src={asset("/media/indigo.png")} alt="" data-par="16" />
                  </>)}
                  {p.vis === "nudge" && (<>
                    <img src={asset("/media/indigo.png")} alt="" />
                    <span className="wave" /><span className="wave d2" /><span className="wave d3" />
                    <div className="chip glass" data-par="14">⏰ every 25 min</div>
                  </>)}
                  {p.vis === "ring" && (<>
                    <svg viewBox="0 0 200 200"><circle cx="100" cy="100" r="80" className="rbg" /><circle cx="100" cy="100" r="80" className="rfg" pathLength={100} /></svg>
                    <div className="rtxt">25:00</div>
                    <div className="chip glass" data-par="14">🎯 focus block</div>
                  </>)}
                  {p.vis === "dial" && <img src={asset("/media/timer.png")} alt="" className="spin" />}
                  {p.vis === "mute" && (<>
                    <div className="call glass"><span className="av">🧑‍💻</span><span className="av">👩‍🎨</span><span className="mic">🎙️ live</span></div>
                    <div className="hush">tick · <s>tock</s> · <em>shh</em></div>
                  </>)}
                </div>
              </article>
            ))}
          </div>
        </section>

        <section className="extras" aria-label="More features">
          <div className="wrap">
            <div className="cards">
              {extras.map((f) => (
                <article key={f.title} className="xcard" data-stagger data-spot>
                  <span className="fi" aria-hidden="true">{f.icon}</span>
                  <h3>{f.title}</h3>
                  <p>{f.body}</p>
                </article>
              ))}
            </div>
          </div>
        </section>

        {/* ── 5 · Showcase: Glint living on a desktop ─────────── */}
        <section id="showcase" className="showcase" aria-labelledby="show-h">
          <div className="wrap">
            <p className="eyebrow">Showcase</p>
            <h2 id="show-h" data-split>Lives on top.<br /><em>Never</em> in the way.</h2>
          </div>
          <div className="desk-wrap" data-desk-wrap>
            <div className="desk" data-desk>
              <div className="menubar"><span></span><span>Glint</span><span>File</span><span>Edit</span><b>⏱︎ 10:59</b></div>
              <div className="dwin code" data-par="-5">
                <div className="tl"><i /><i /><i /></div>
                {Array.from({ length: 11 }, (_, i) => <b key={i} style={{ width: `${30 + ((i * 37) % 55)}%`, marginLeft: `${(i % 4) * 6}%` }} />)}
              </div>
              <div className="dwin doc" data-par="4"><div className="tl"><i /><i /><i /></div><b /><b /><b /><b /><b /></div>
              <div className="glint-on-desk" data-par="12">
                {["indigo", "disk", "forest", "timer"].map((s, i) => (
                  <img key={s} src={asset(`/media/${s}.png`)} alt={i === 0 ? "Glint floating above a code editor on a Mac desktop" : ""} data-desk-shot={i} />
                ))}
              </div>
              <div className="floater f1 glass" data-par="20">✨ Minute flash</div>
              <div className="floater f2 glass" data-par="-14">🎯 Focus · 18:42 left</div>
              <div className="floater f3 glass" data-par="10">🔇 Auto-muted · in a call</div>
            </div>
            <div className="desk-caps" data-desk-caps>
              <span className="on">Indigo · calm</span><span>Midnight · disk</span><span>Forest · time sitting</span><span>Dial Mode</span>
            </div>
          </div>
        </section>

        {/* ── 6 · Process: from download to feeling time ──────── */}
        <section id="setup" className="setup" aria-labelledby="setup-h">
          <div className="wrap">
            <p className="eyebrow">Setup</p>
            <h2 id="setup-h" data-split>Thirty seconds to <em>awareness.</em></h2>
            <div className="path" data-path>
              <svg className="path-line" viewBox="0 0 1000 120" preserveAspectRatio="none" aria-hidden="true">
                <path d="M0 78 C 80 22, 170 22, 250 78 S 420 134, 500 78 S 670 22, 750 78 S 920 134, 1000 78" pathLength={1} data-path-line />
              </svg>
              {journey.map((j) => (
                <div className="stop" key={j.h} data-stop>
                  <span className="pt" />
                  <div className="time">{j.t}</div>
                  <h3>{j.h}</h3>
                  <p>{j.p}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* ── 7 · Proof ───────────────────────────────────────── */}
        <section className="proof" aria-labelledby="proof-h">
          <div className="wrap">
            <p className="eyebrow">Private by design</p>
            <h2 id="proof-h" data-split>Tiny. Native. <em>Offline.</em></h2>
            <div className="stats">
              {stats.map((s) => (
                <div className="stat" key={s.p} data-stagger data-spot>
                  <div className="n">{s.pre ?? ""}<span data-count={s.n}>{s.n}</span></div>
                  <p>{s.p}</p>
                </div>
              ))}
            </div>
            <blockquote className="quote" data-words>
              &ldquo;Inspired by research showing that watching time <em>visibly</em> shrink, rather than decoding digits, helps
              self-regulation and lowers anxiety.&rdquo;
            </blockquote>
          </div>
        </section>

        {/* ── FAQ ─────────────────────────────────────────────── */}
        <section id="faq" className="faq-sec" aria-labelledby="faq-h">
          <div className="wrap faq-grid">
            <div>
              <p className="eyebrow">FAQ</p>
              <h2 id="faq-h" data-split>Questions, <em>answered.</em></h2>
            </div>
            <div className="faq">
              {faqs.map((f, i) => (
                <details key={f.q} open={i === 0}>
                  <summary><h3>{f.q}</h3></summary>
                  <p>{f.a}</p>
                </details>
              ))}
            </div>
          </div>
        </section>

        {/* ── 8 · Closing frame ───────────────────────────────── */}
        <section id="cta" className="cta" aria-labelledby="cta-h">
          <div className="deplete" data-deplete aria-hidden="true" />
          <div className="wrap">
            <img className="icon" src={asset("/glint-icon.png")} alt="Glint app icon" width={112} height={112} data-stagger />
            <h2 id="cta-h" className="final" data-final>Stop losing <em>hours.</em></h2>
            <p className="lead">Free forever. Sits quietly in the corner until a minute goes by.</p>
            <a className="btn big" href={DOWNLOAD} data-magnetic data-cursor="Get it"><span className="lbl">⬇ Download Glint for Mac</span></a>
            <p className="note">First launch: right-click Glint in Applications → <b>Open</b> → <b>Open</b>. Requires {site.requirements}.</p>
          </div>
        </section>
      </main>

      <footer>
        <div className="wrap">
          <span>© 2026 {site.author.name} · MIT licensed · <a href={site.author.url}>More apps</a></span>
          <span><a href={REPO}>Source</a><a href={`${REPO}/releases`}>Releases</a><a href={`${REPO}/issues`}>Feedback</a></span>
        </div>
      </footer>
    </>
  );
}
