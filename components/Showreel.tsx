"use client";
import { useEffect } from "react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { SplitText } from "gsap/SplitText";
import Lenis from "lenis";
import { states } from "@/lib/site";

/**
 * The motion layer. Markup and copy live in page.tsx (so crawlers see everything);
 * this component choreographs it as one continuous reel about time.
 */
export default function Showreel() {
  useEffect(() => {
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    const fine = window.matchMedia("(hover: hover) and (pointer: fine)").matches;
    const $ = <T extends Element = HTMLElement>(s: string) => document.querySelector<T>(s);
    const $$ = <T extends Element = HTMLElement>(s: string) => Array.from(document.querySelectorAll<T>(s));
    document.documentElement.classList.add("motion");
    if (reduce) { document.documentElement.classList.add("reduced"); return; }

    gsap.registerPlugin(ScrollTrigger, SplitText);

    const lenis = new Lenis({ lerp: 0.085 });
    lenis.on("scroll", ScrollTrigger.update);
    const raf = (t: number) => lenis.raf(t * 1000);
    gsap.ticker.add(raf);
    gsap.ticker.lagSmoothing(0);
    $$<HTMLAnchorElement>('a[href^="#"]').forEach((a) =>
      a.addEventListener("click", (e) => { const t = a.getAttribute("href")!; if (t.length > 1) { e.preventDefault(); lenis.scrollTo(t, { offset: -10 }); } }));

    const mm = gsap.matchMedia();
    const splits: SplitText[] = [];
    const cleanups: (() => void)[] = [];

    // A full-screen "minute flash", the site's signature beat.
    const flashfx = $(".flashfx");
    // Throttled to one per 1.5 s so fast scrolling never strobes (WCAG 2.3.1: max three flashes a second).
    let lastFlash = 0;
    const flash = (bg: string, strength = 0.85) => {
      const now = performance.now();
      if (!flashfx || now - lastFlash < 1500) return;
      lastFlash = now;
      gsap.fromTo(flashfx, { autoAlpha: strength, background: bg }, { autoAlpha: 0, duration: 1.3, ease: "power2.out" });
    };

    const ctx = gsap.context(() => {
      gsap.set("[data-hero-clock]", { transformPerspective: 1200 });
      gsap.set("[data-stage]", { transformPerspective: 1400 });
      gsap.set("[data-desk]", { transformPerspective: 1600 });
      /* ── 1 · Opening sequence ─────────────────────────────── */
      const mega = new SplitText("[data-mega] .l1, [data-mega] .l2", { type: "chars", charsClass: "char", mask: "chars" });
      splits.push(mega);
      const intro = gsap.timeline({ defaults: { ease: "expo.out" } });
      intro
        .from(".hero-ticks i", { scaleY: 0, opacity: 0, duration: 1.2, stagger: { each: 0.012, from: "random" } }, 0)
        .from(".aura", { scale: 0.3, opacity: 0, duration: 2.4, stagger: 0.2 }, 0)
        .from(mega.chars, { yPercent: 120, scaleY: 1.8, transformOrigin: "50% 100%", duration: 1.5, stagger: 0.05 }, 0.2)
        .from("[data-hero-clock]", { y: 120, rotateX: 55, rotateZ: -6, scale: 0.7, opacity: 0, duration: 1.8 }, 0.55)
        .from("[data-hero-in]", { y: 30, opacity: 0, duration: 1.2, stagger: 0.1 }, 0.9)
        .from("nav", { y: -50, opacity: 0, duration: 1 }, 1)
        .from(".marquee", { yPercent: 120, opacity: 0, duration: 1.1 }, 1.2)
        .add(() => flash("linear-gradient(135deg,#2EC4B6,#00F5D4)", 0.3), 1.9)
        .fromTo(".hero-ticks", { rotate: -90 }, { rotate: 0, duration: 3, ease: "expo.out" }, 0);

      // Leaving the hero: headline stretches and blurs away, the tick ring spins with you.
      gsap.to("[data-mega]", { yPercent: -30, scale: 1.15, opacity: 0, filter: "blur(10px)", transformOrigin: "0% 100%", ease: "none",
        scrollTrigger: { trigger: ".hero", start: "top top", end: "bottom top", scrub: true } });
      gsap.to(".hero-ticks", { rotate: 120, scale: 1.4, opacity: 0, ease: "none", scrollTrigger: { trigger: ".hero", start: "top top", end: "bottom top", scrub: true } });
      gsap.to("[data-hero-clock]", { yPercent: 30, rotateX: -25, scale: 0.85, ease: "none",
        scrollTrigger: { trigger: ".hero", start: "center center", end: "bottom top", scrub: true } });

      // Marquee: speed and skew follow scroll velocity.
      const track = $(".marquee .track");
      if (track) {
        const loop = gsap.to(track, { xPercent: -50, duration: 30, ease: "none", repeat: -1 });
        const skew = gsap.quickTo(track, "skewX", { duration: 0.4 });
        ScrollTrigger.create({ onUpdate: (st) => { const v = st.getVelocity() / 300; loop.timeScale(gsap.utils.clamp(-6, 6, 1 + v * st.direction)); skew(gsap.utils.clamp(-14, 14, -v)); } });
      }

      /* ── 2 · Time-lapse: scroll scrubs the clock from 9:00 to 12:47 ── */
      const lapseEl = $("[data-lapse]"), ampm = $("[data-lapse-ampm]");
      const words = new SplitText("#lapse [data-words]", { type: "words", wordsClass: "word" });
      splits.push(words);
      const t0 = 9 * 60, t1 = 12 * 60 + 47;
      let lastMin = -1;
      const lapse = gsap.timeline({ scrollTrigger: { trigger: "#lapse", start: "top top", end: "+=220%", pin: true, scrub: 0.5,
        onUpdate: (st) => {
          const m = Math.round(t0 + (t1 - t0) * st.progress);
          if (m === lastMin || !lapseEl) return;
          if (lastMin >= 0 && Math.floor(m / 60) !== Math.floor(lastMin / 60)) flash("linear-gradient(135deg,#FB5607,#FF006E)", 0.35);
          lastMin = m;
          const h = Math.floor(m / 60), h12 = h % 12 || 12;
          lapseEl.textContent = `${h12}:${String(m % 60).padStart(2, "0")}`;
          if (ampm) ampm.textContent = h < 12 ? "AM" : "PM";
        } } });
      lapse
        .fromTo("[data-sky]", { backgroundPosition: "50% 0%" }, { backgroundPosition: "50% 100%", ease: "none", duration: 1 }, 0)
        .fromTo(".lapse-clock", { scale: 0.7, filter: "blur(0px)" }, { scale: 1.25, filter: "blur(3px)", ease: "none", duration: 1 }, 0)
        .to(words.words, { opacity: 1, color: "#fff", stagger: 0.02, ease: "none", duration: 0.5 }, 0.25);

      /* ── Masked line reveals for section headings ─────────── */
      $$("[data-split]").forEach((h) => {
        const s = new SplitText(h, { type: "lines", linesClass: "line", mask: "lines" });
        splits.push(s);
        gsap.from(s.lines, { yPercent: 115, rotate: 3, duration: 1.3, stagger: 0.1, ease: "expo.out", scrollTrigger: { trigger: h, start: "top 85%" } });
      });

      ScrollTrigger.batch("[data-stagger]", { start: "top 88%",
        onEnter: (els) => gsap.from(els, { y: 70, opacity: 0, rotateX: -25, duration: 1.2, stagger: 0.08, ease: "expo.out", overwrite: true }) });

      /* ── 3 · One card morphs through the five states ───────── */
      const layers = $$("[data-layer]"), items = $$("[data-state-item]");
      const sname = $("[data-stage-name]"), sss = $("[data-stage-ss]");
      const secs = ["42", "54", "00", "00", "00"];
      const hms = ["10:59", "10:59", "11:00", "12:00", "12:25"];
      let cur = 0;
      mm.add("(min-width: 901px)", () => {
        ScrollTrigger.create({ trigger: "#states", start: "top top", end: "+=260%", pin: true, scrub: true,
          onUpdate: (st) => {
            const i = Math.min(states.length - 1, Math.floor(st.progress * states.length));
            if (i === cur) return;
            cur = i;
            layers.forEach((l, k) => gsap.to(l, { opacity: k === i ? 1 : 0, duration: 0.6 }));
            items.forEach((it, k) => it.classList.toggle("on", k === i));
            if (sname) sname.textContent = states[i].name;
            if (sss) sss.textContent = secs[i];
            const hm = $(".stage-hm"); if (hm) hm.textContent = hms[i];
            gsap.fromTo("[data-pulse]", { scale: 0.8, opacity: 0.8, background: `radial-gradient(closest-side, ${states[i].to}, transparent)` }, { scale: 1.8, opacity: 0, duration: 1.2, ease: "expo.out" });
            gsap.fromTo(".stage-card", { scale: 0.96 }, { scale: 1, duration: 0.8, ease: "elastic.out(1,0.5)" });
          } });
        gsap.fromTo("[data-stage]", { rotateY: -25, rotateX: 10 }, { rotateY: 8, rotateX: -4, ease: "none",
          scrollTrigger: { trigger: "#states", start: "top top", end: "+=260%", scrub: true } });
      });

      /* ── 5 · Showcase desk: unmask, flatten, then cycle themes ── */
      const desk = $("[data-desk]");
      if (desk) {
        gsap.fromTo(desk, { clipPath: "inset(22% 26% 22% 26% round 48px)", rotateX: 32, scale: 0.84 },
          { clipPath: "inset(0% 0% 0% 0% round 26px)", rotateX: 0, scale: 1, ease: "none",
            scrollTrigger: { trigger: desk, start: "top 95%", end: "top 20%", scrub: true } });
        const shots = $$("[data-desk-shot]"), caps = $$("[data-desk-caps] span");
        const cyc = gsap.timeline({ scrollTrigger: { trigger: "[data-desk-wrap]", start: "top 8%", end: "+=180%", pin: true, scrub: 0.5,
          onUpdate: (st) => { const i = Math.min(3, Math.floor(st.progress * 4)); caps.forEach((c, k) => c.classList.toggle("on", k === i)); } } });
        shots.slice(1).forEach((s, i) => {
          cyc.to(shots[i], { opacity: 0, scale: 0.94, filter: "blur(10px)", duration: 1 })
            .fromTo(s, { opacity: 0, scale: 1.08, filter: "blur(14px)" }, { opacity: 1, scale: 1, filter: "blur(0px)", duration: 1 }, "<")
            .to({}, { duration: 0.5 });
        });
      }

      /* ── 6 · Setup path draws, stops arrive ─────────────────── */
      gsap.fromTo("[data-path-line]", { strokeDashoffset: 1 }, { strokeDashoffset: 0, ease: "none",
        scrollTrigger: { trigger: "[data-path]", start: "top 75%", end: "bottom 55%", scrub: true } });
      $$("[data-stop]").forEach((s, i) => {
        const tl = gsap.timeline({ scrollTrigger: { trigger: "[data-path]", start: `top ${70 - i * 6}%` } });
        tl.from(s.querySelector(".pt"), { scale: 0, duration: 0.6, ease: "back.out(3)", delay: i * 0.18 })
          .from(s.querySelector(".time"), { yPercent: 100, opacity: 0, duration: 1, ease: "expo.out" }, "<")
          .from(s.querySelectorAll("h3, p"), { y: 30, opacity: 0, stagger: 0.08, duration: 1, ease: "expo.out" }, "<0.1");
      });

      /* ── 7 · Counters + quote ───────────────────────────────── */
      $$("[data-count]").forEach((el) => {
        const end = Number(el.dataset.count), start = end === 0 ? 99 : 0;
        const o = { v: start };
        gsap.to(o, { v: end, duration: 2.2, ease: "expo.out", scrollTrigger: { trigger: el, start: "top 88%" }, onUpdate: () => { el.textContent = String(Math.round(o.v)); } });
      });
      const q = new SplitText(".proof [data-words]", { type: "words", wordsClass: "word" });
      splits.push(q);
      gsap.to(q.words, { opacity: 1, stagger: 0.05, ease: "none", scrollTrigger: { trigger: ".quote", start: "top 80%", end: "bottom 50%", scrub: true } });

      /* ── 8 · Closing frame: the screen depletes like the dial ── */
      gsap.fromTo("[data-deplete]", { "--a": "360deg", opacity: 0.22 }, { "--a": "0deg", opacity: 0, ease: "none", scrollTrigger: { trigger: "#cta", start: "top bottom", end: "center center", scrub: true } });
      const fin = new SplitText("[data-final]", { type: "chars", charsClass: "char", mask: "chars" });
      splits.push(fin);
      gsap.from(fin.chars, { yPercent: 120, scaleY: 1.8, transformOrigin: "50% 100%", stagger: 0.04, duration: 1.4, ease: "expo.out",
        scrollTrigger: { trigger: "#cta", start: "top 55%", onEnter: () => flash("linear-gradient(135deg,#7B2FF7,#00F5D4)", 0.45) } });

      /* ── Feature reel: horizontal on desktop ────────────────── */
      mm.add("(min-width: 901px)", () => {
        const reelEl = $("[data-reel]");
        if (!reelEl) return;
        const dist = () => reelEl.scrollWidth - window.innerWidth;
        const h = gsap.to(reelEl, { x: () => -dist(), ease: "none",
          scrollTrigger: { trigger: reelEl, start: "top top", end: () => `+=${dist()}`, pin: true, scrub: 0.8, invalidateOnRefresh: true, anticipatePin: 1 } });
        $$("[data-panel]").forEach((p) => {
          p.querySelectorAll<HTMLElement>("[data-par]").forEach((el) => {
            const d = Number(el.dataset.par);
            gsap.fromTo(el, { x: d * 10 }, { x: -d * 10, ease: "none", scrollTrigger: { trigger: p, containerAnimation: h, start: "left right", end: "right left", scrub: true } });
          });
          gsap.from(p.querySelectorAll(".pcopy > *"), { y: 60, opacity: 0, stagger: 0.07, duration: 1, ease: "expo.out", scrollTrigger: { trigger: p, containerAnimation: h, start: "left 70%" } });
          gsap.fromTo(p.querySelector(".num"), { xPercent: 50 }, { xPercent: -50, ease: "none", scrollTrigger: { trigger: p, containerAnimation: h, start: "left right", end: "right left", scrub: true } });
          gsap.from(p.querySelector(".vis"), { scale: 0.7, rotate: -8, opacity: 0, duration: 1.4, ease: "expo.out", scrollTrigger: { trigger: p, containerAnimation: h, start: "left 75%" } });
        });
      });
      mm.add("(max-width: 900px)", () => {
        $$("[data-panel]").forEach((p) => gsap.from(p.children, { y: 60, opacity: 0, stagger: 0.1, duration: 1, ease: "expo.out", scrollTrigger: { trigger: p, start: "top 80%" } }));
      });

      // Desk parallax (outside the reel).
      $$("[data-desk] [data-par]").forEach((el) => {
        const d = Number(el.dataset.par);
        gsap.fromTo(el, { y: d * 8 }, { y: -d * 8, ease: "none", scrollTrigger: { trigger: "[data-desk-wrap]", start: "top bottom", end: "bottom top", scrub: true } });
      });

      /* ── Cursor: a tiny Glint that depletes every second ─────── */
      if (fine) {
        const curEl = $(".cursor")!;
        const cx = gsap.quickTo(curEl, "x", { duration: 0.35, ease: "power3" }), cy = gsap.quickTo(curEl, "y", { duration: 0.35, ease: "power3" });
        const sweep = $<SVGCircleElement>(".cursor .sweep"), cl = $(".cursor .cl");
        const tickId = window.setInterval(() => {
          const s = new Date().getSeconds();
          if (sweep) sweep.style.strokeDashoffset = String(s);
          if (cl && !curEl.classList.contains("big")) cl.textContent = "";
        }, 250);
        cleanups.push(() => clearInterval(tickId));
        const floats = $$("[data-depth]").map((el) => ({ d: Number(el.dataset.depth), x: gsap.quickTo(el, "x", { duration: 1.2, ease: "power3" }), y: gsap.quickTo(el, "y", { duration: 1.2, ease: "power3" }) }));
        const move = (e: MouseEvent) => {
          cx(e.clientX); cy(e.clientY);
          const nx = e.clientX / window.innerWidth - 0.5, ny = e.clientY / window.innerHeight - 0.5;
          if (window.scrollY < window.innerHeight) floats.forEach((f) => { f.x(nx * f.d * 2); f.y(ny * f.d * 2); });
        };
        window.addEventListener("mousemove", move);
        cleanups.push(() => window.removeEventListener("mousemove", move));

        $$("a, button, summary, [data-tilt]").forEach((el) => {
          const enter = () => { curEl.classList.add("big"); const c = el.dataset.cursor; if (c && cl) cl.textContent = c; };
          const leave = () => { curEl.classList.remove("big"); if (cl) cl.textContent = ""; };
          el.addEventListener("mouseenter", enter); el.addEventListener("mouseleave", leave);
          cleanups.push(() => { el.removeEventListener("mouseenter", enter); el.removeEventListener("mouseleave", leave); });
        });

        $$("[data-magnetic]").forEach((el) => {
          const mx = gsap.quickTo(el, "x", { duration: 0.6, ease: "elastic.out(1,0.4)" }), my = gsap.quickTo(el, "y", { duration: 0.6, ease: "elastic.out(1,0.4)" });
          const lbl = el.querySelector<HTMLElement>(".lbl");
          const m = (e: MouseEvent) => { const r = el.getBoundingClientRect(); const x = e.clientX - r.left - r.width / 2, y = e.clientY - r.top - r.height / 2;
            mx(x * 0.35); my(y * 0.45); if (lbl) gsap.to(lbl, { x: x * 0.15, y: y * 0.2, duration: 0.4 }); };
          const l = () => { mx(0); my(0); if (lbl) gsap.to(lbl, { x: 0, y: 0, duration: 0.6, ease: "elastic.out(1,0.4)" }); };
          el.addEventListener("mousemove", m); el.addEventListener("mouseleave", l);
          cleanups.push(() => { el.removeEventListener("mousemove", m); el.removeEventListener("mouseleave", l); });
        });

        $$("[data-tilt]").forEach((el) => {
          const rx = gsap.quickTo(el, "rotateX", { duration: 0.5 }), ry = gsap.quickTo(el, "rotateY", { duration: 0.5 });
          gsap.set(el, { transformPerspective: 900 });
          const m = (e: MouseEvent) => { const r = el.getBoundingClientRect(); ry(((e.clientX - r.left) / r.width - 0.5) * 20); rx(-((e.clientY - r.top) / r.height - 0.5) * 20); };
          const l = () => { rx(0); ry(0); };
          el.addEventListener("mousemove", m); el.addEventListener("mouseleave", l);
          cleanups.push(() => { el.removeEventListener("mousemove", m); el.removeEventListener("mouseleave", l); });
        });

        // Spotlight that follows the cursor inside cards.
        $$("[data-spot]").forEach((s) => {
          const mv = (e: MouseEvent) => { const r = s.getBoundingClientRect(); s.style.setProperty("--x", `${e.clientX - r.left}px`); s.style.setProperty("--y", `${e.clientY - r.top}px`); };
          s.addEventListener("mousemove", mv);
          cleanups.push(() => s.removeEventListener("mousemove", mv));
        });
      }
    });

    ScrollTrigger.sort();
    ScrollTrigger.refresh();
    document.fonts?.ready.then(() => { ScrollTrigger.sort(); ScrollTrigger.refresh(); });

    return () => {
      cleanups.forEach((c) => c());
      ctx.revert();
      mm.revert();
      splits.forEach((s) => s.revert());
      gsap.ticker.remove(raf);
      lenis.destroy();
    };
  }, []);
  return null;
}
