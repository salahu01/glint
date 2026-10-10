/* eslint-disable @next/next/no-img-element -- static export: plain <img> with basePath-aware src */
import LiveClock from "@/components/LiveClock";
import Reveal from "@/components/Reveal";
import { DOWNLOAD, REPO, VERSION, asset, faqs, features, installSteps, site, states } from "@/lib/site";

const gallery = [
  { src: "/media/indigo.png", alt: "Glint in the Indigo theme, calm state", cap: "Calm · Indigo" },
  { src: "/media/buildup.png", alt: "Glint during the final ten seconds of a minute, washed amber to red", cap: "Buildup · last 10 s" },
  { src: "/media/flash.png", alt: "Glint flashing teal as the minute changes", cap: "Minute flash" },
  { src: "/media/timer.png", alt: "Glint in Dial Mode, a red disk depleting toward zero", cap: "Dial Mode" },
  { src: "/media/disk.png", alt: "Glint in the Midnight theme with a depleting disk", cap: "Disk depletion · Midnight" },
  { src: "/media/forest.png", alt: "Glint in the Forest theme showing time sitting", cap: "Time sitting · Forest" },
];

const stats = [
  { n: "0", p: "network requests. Nothing leaves your Mac" },
  { n: "$0", p: "forever. Free and open source under MIT" },
  { n: "3.5", suf: "MB", p: "universal app for Apple silicon and Intel" },
  { n: "0", p: "audio files. Every tick and chime is synthesised" },
];

export default function Home() {
  return (
    <>
      <Reveal />
      <nav aria-label="Main">
        <div className="wrap">
          <a className="brand" href="#top"><img src={asset("/glint-icon.png")} alt="" width={34} height={34} />Glint</a>
          <div className="bar">
            <a href="#how">How it works</a>
            <a href="#features">Features</a>
            <a href="#faq">FAQ</a>
            <a href={REPO}>GitHub</a>
            <a className="btn sm" href={DOWNLOAD}>Download</a>
          </div>
        </div>
      </nav>

      <main id="main">
        <section id="top" className="hero">
          <div className="wrap hero-grid">
            <div>
              <p className="eyebrow">Always-on-top clock for Mac</p>
              <h1>Feel time <em>pass.</em></h1>
              <p className="lead">
                For anyone who looks up and realises three hours just vanished. Glint floats above every window, ticks like a
                real clock, and <b>flashes the moment a minute or hour changes</b>, so time taps you on the shoulder even when you
                forget to look.
              </p>
              <div className="cta-row">
                <a className="btn" href={DOWNLOAD}>⬇ Download for Mac</a>
                <a className="btn ghost" href={REPO}>★ Star on GitHub</a>
              </div>
              <p className="meta">Free · open source · {site.requirements} · v{VERSION}</p>
            </div>
            <LiveClock />
          </div>
        </section>

        <section className="manifesto" aria-label="Why Glint">
          <div className="wrap">
            <p data-reveal>
              A normal clock just sits there. You have to <em>remember</em> to look, and remembering is exactly what you can&apos;t
              do when you&apos;re absorbed. Glint doesn&apos;t wait to be checked. <em>It reaches out to you.</em>
            </p>
          </div>
        </section>

        <section id="how" className="sec" aria-labelledby="how-h">
          <div className="wrap">
            <p className="eyebrow">How it works</p>
            <h2 id="how-h">Five states. <em>Zero</em> effort.</h2>
            <p className="lead narrow">You don&apos;t read Glint. You notice it, in your peripheral vision, the way you notice a light change.</p>
            <ol className="states">
              {states.map((s) => (
                <li key={s.name} data-reveal>
                  <span className="swatch" style={{ background: `linear-gradient(135deg, ${s.from}, ${s.to})` }} />
                  <div>
                    <h3>{s.name} <small>{s.when}</small></h3>
                    <p>{s.what}</p>
                  </div>
                </li>
              ))}
            </ol>
          </div>
        </section>

        <section className="sec gallery-sec" aria-labelledby="gal-h">
          <div className="wrap">
            <p className="eyebrow">Screenshots</p>
            <h2 id="gal-h">Glanceable in <em>every</em> mood.</h2>
            <div className="gallery">
              {gallery.map((g) => (
                <figure key={g.src} data-reveal>
                  <img src={asset(g.src)} alt={g.alt} loading="lazy" />
                  <figcaption>{g.cap}</figcaption>
                </figure>
              ))}
            </div>
          </div>
        </section>

        <section id="features" className="sec" aria-labelledby="feat-h">
          <div className="wrap">
            <p className="eyebrow">Features</p>
            <h2 id="feat-h">Small clock. <em>Big</em> awareness.</h2>
            <div className="features">
              {features.map((f) => (
                <article key={f.title} data-reveal>
                  <span className="fi" aria-hidden="true">{f.icon}</span>
                  <h3>{f.title}</h3>
                  <p>{f.body}</p>
                </article>
              ))}
            </div>
          </div>
        </section>

        <section className="sec research" aria-labelledby="res-h">
          <div className="wrap grid2">
            <div data-reveal>
              <p className="eyebrow">Number-free time</p>
              <h2 id="res-h">See time <em>run out.</em></h2>
              <p className="lead">
                Research behind visual timers suggests that watching remaining time shrink, rather than decoding digits, helps
                self-regulation and lowers anxiety. Glint can show the hour, your nudge interval or a focus block as a shrinking
                ring, an emptying disk, or a full dial, with the numbers hidden entirely if you like.
              </p>
            </div>
            <div className="duo" data-reveal>
              <img src={asset("/media/timer.png")} alt="Glint Dial Mode" loading="lazy" />
              <img src={asset("/media/slate.png")} alt="Glint showing only a depleting disk, no numbers" loading="lazy" />
            </div>
          </div>
        </section>

        <section className="sec" aria-labelledby="proof-h">
          <div className="wrap">
            <p className="eyebrow">Private by design</p>
            <h2 id="proof-h">Tiny, native, <em>offline.</em></h2>
            <div className="stats">
              {stats.map((s) => (
                <div className="stat" key={s.p} data-reveal>
                  <div className="n">{s.n}{s.suf && <sup>{s.suf}</sup>}</div>
                  <p>{s.p}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        <section id="install" className="sec" aria-labelledby="inst-h">
          <div className="wrap">
            <p className="eyebrow">Install</p>
            <h2 id="inst-h">Running in <em>a minute.</em></h2>
            <ol className="steps">
              {installSteps.map((s, i) => (
                <li key={s.name} data-reveal><span className="sn">{i + 1}</span><h3>{s.name}</h3><p>{s.text}</p></li>
              ))}
            </ol>
          </div>
        </section>

        <section id="faq" className="sec" aria-labelledby="faq-h">
          <div className="wrap faq-grid">
            <div>
              <p className="eyebrow">FAQ</p>
              <h2 id="faq-h">Questions, <em>answered.</em></h2>
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

        <section className="cta" aria-labelledby="cta-h">
          <div className="wrap">
            <img className="icon" src={asset("/glint-icon.png")} alt="Glint app icon" width={112} height={112} />
            <h2 id="cta-h">Stop losing <em>hours.</em></h2>
            <p className="lead">Free forever. Sits quietly in the corner until a minute goes by.</p>
            <a className="btn big" href={DOWNLOAD}>⬇ Download Glint for Mac</a>
            <p className="note">
              First launch: right-click Glint in Applications → <b>Open</b> → <b>Open</b>. Requires {site.requirements}.
            </p>
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
