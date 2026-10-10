"use client";
import { useCallback, useEffect, useRef, useState } from "react";
import { themes } from "@/lib/site";

type Flash = { id: number; kind: "minute" | "hour" | "nudge" } | null;
type Face = "clock" | "ring" | "dial";

const FLASH = {
  minute: "linear-gradient(135deg,#2EC4B6,#00F5D4)",
  hour: "linear-gradient(135deg,#FB5607,#FF006E)",
  nudge: "linear-gradient(135deg,#7B2FF7,#00F5D4)",
};

/** Same synthesis idea as the app's TickPlayer: decaying sine bursts for ticks, a harmonic ring for chimes. */
function useSound(enabled: boolean) {
  const ctx = useRef<AudioContext | null>(null);
  const play = useCallback(
    (freqs: number[], dur: number, gain: number, delays: number[] = [0]) => {
      if (!enabled) return;
      ctx.current ??= new AudioContext();
      const c = ctx.current;
      for (const d of delays)
        for (const [i, f] of freqs.entries()) {
          const o = c.createOscillator();
          const g = c.createGain();
          const t = c.currentTime + d;
          o.frequency.value = f;
          g.gain.setValueAtTime(gain / (i + 1), t);
          g.gain.exponentialRampToValueAtTime(0.0001, t + dur);
          o.connect(g).connect(c.destination);
          o.start(t);
          o.stop(t + dur);
        }
    },
    [enabled],
  );
  return {
    tick: (high: boolean) => play([high ? 2400 : 1700], 0.035, 0.05),
    chime: (times: number) => play([880, 1760, 2640], 1.1, 0.12, Array.from({ length: times }, (_, i) => i * 0.32)),
  };
}

export default function LiveClock({ compact = false }: { compact?: boolean }) {
  const [now, setNow] = useState<Date | null>(null);
  const [theme, setTheme] = useState(0);
  const [face, setFace] = useState<Face>("clock");
  const [h24, setH24] = useState(false);
  const [sound, setSound] = useState(false);
  const [flash, setFlash] = useState<Flash>(null);
  const last = useRef<Date | null>(null);
  const { tick, chime } = useSound(sound);
  const reduced = useRef(false);

  const fire = useCallback((kind: "minute" | "hour" | "nudge") => {
    setFlash({ id: Date.now(), kind });
    chime(kind === "minute" ? 1 : kind === "hour" ? 2 : 3);
  }, [chime]);

  // Align to real second boundaries, like the app's tick loop.
  useEffect(() => {
    reduced.current = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    let t: ReturnType<typeof setTimeout>;
    const loop = () => {
      const d = new Date();
      setNow(d);
      t = setTimeout(loop, 1000 - d.getMilliseconds() + 5);
    };
    loop();
    return () => clearTimeout(t);
  }, []);

  useEffect(() => {
    if (!now) return;
    const p = last.current;
    last.current = now;
    if (!p || p.getSeconds() === now.getSeconds()) return;
    tick(now.getSeconds() % 2 === 0);
    if (p.getMinutes() !== now.getMinutes()) fire(now.getMinutes() === 0 ? "hour" : "minute");
  }, [now, tick, fire]);

  useEffect(() => {
    if (!flash) return;
    const t = setTimeout(() => setFlash(null), flash.kind === "minute" ? 900 : 1500);
    return () => clearTimeout(t);
  }, [flash]);

  const th = themes[theme];
  const d = now ?? new Date(2026, 0, 1, 10, 9, 41);
  const s = d.getSeconds();
  const hr = h24 ? d.getHours() : d.getHours() % 12 || 12;
  const hm = `${h24 ? String(hr).padStart(2, "0") : hr}:${String(d.getMinutes()).padStart(2, "0")}`;
  const ss = String(s).padStart(2, "0");
  const buildup = s >= 50 ? (s - 49) / 10 : 0;
  // Depletion over the hour, like the app's default target.
  const left = 1 - (d.getMinutes() * 60 + s) / 3600;

  return (
    <div className={`live ${compact ? "compact" : ""}`}>
      <div className="live-stage" aria-label={`Glint clock showing ${hm}`} role="img">
        {face === "dial" ? (
          <Dial left={left} />
        ) : (
          <div
            className="card"
            style={{ background: `linear-gradient(160deg, ${th.top}, ${th.bottom})`, ["--glow" as string]: th.glow }}
          >
            <div className="wash" style={{ opacity: buildup * 0.9 }} />
            {flash && !reduced.current && <div key={flash.id} className={`burst ${flash.kind}`} style={{ background: FLASH[flash.kind] }} />}
            {face === "ring" && <Ring left={left} glow={th.glow} />}
            <div className="hm">{hm}</div>
            <div className="ss">
              <span style={{ color: buildup ? "#fff" : th.glow }}>{ss}</span>
              {!h24 && <span>{d.getHours() < 12 ? "AM" : "PM"}</span>}
              <span className="spk" aria-hidden="true">{sound ? "🔊" : "🔈"}</span>
            </div>
          </div>
        )}
      </div>

      <div className="live-ctl" role="group" aria-label="Try Glint">
        <div className="seg" role="radiogroup" aria-label="Face">
          {(["clock", "ring", "dial"] as Face[]).map((f) => (
            <button key={f} role="radio" aria-checked={face === f} className={face === f ? "on" : ""} onClick={() => setFace(f)}>
              {f === "clock" ? "Clock" : f === "ring" ? "Ring" : "Dial"}
            </button>
          ))}
        </div>
        {face !== "dial" && (
          <div className="swatches" role="radiogroup" aria-label="Colour theme">
            {themes.map((t, i) => (
              <button
                key={t.name}
                role="radio"
                aria-checked={theme === i}
                aria-label={t.name}
                title={t.name}
                className={theme === i ? "on" : ""}
                style={{ background: `linear-gradient(135deg, ${t.top} 45%, ${t.glow})` }}
                onClick={() => setTheme(i)}
              />
            ))}
          </div>
        )}
        <div className="seg">
          <button onClick={() => fire("minute")}>Minute flash</button>
          <button onClick={() => fire("hour")}>Hour</button>
          <button onClick={() => fire("nudge")}>Nudge</button>
        </div>
        <div className="seg">
          <button aria-pressed={sound} className={sound ? "on" : ""} onClick={() => setSound((v) => !v)}>
            {sound ? "Sound on" : "Sound off"}
          </button>
          <button aria-pressed={h24} className={h24 ? "on" : ""} onClick={() => setH24((v) => !v)}>24h</button>
        </div>
      </div>
    </div>
  );
}

function Ring({ left, glow }: { left: number; glow: string }) {
  return <div className="ring" aria-hidden="true" style={{ background: `conic-gradient(${glow} ${left * 360}deg, transparent 0)` }} />;
}

/** Mirrors TimeTimerFace.swift: red disk depleting toward 0, 0–55 ring, ticks, pointer. */
function Dial({ left }: { left: number }) {
  const r = 33;
  const a = left * 2 * Math.PI;
  const x = 50 - r * Math.sin(a);
  const y = 50 - r * Math.cos(a);
  const wedge = left >= 0.9999 ? `M50 17 A33 33 0 1 0 50.01 17 Z` : `M50 50 L50 17 A33 33 0 ${left > 0.5 ? 1 : 0} 0 ${x} ${y} Z`;
  const ang = -left * 360;
  return (
    <svg className="dial" viewBox="0 0 100 100" aria-hidden="true">
      <rect x="1" y="1" width="98" height="98" rx="16" fill="#f5f5f5" stroke="#ddd" />
      {Array.from({ length: 60 }, (_, i) => {
        const big = i % 5 === 0;
        const t = (-i * 6 * Math.PI) / 180;
        const r1 = big ? 34.5 : 36, r2 = 38;
        return <line key={i} x1={50 - r1 * Math.sin(t)} y1={50 - r1 * Math.cos(t)} x2={50 - r2 * Math.sin(t)} y2={50 - r2 * Math.cos(t)}
          stroke={big ? "#222" : "#999"} strokeWidth={big ? 1.2 : 0.4} strokeLinecap="round" />;
      })}
      <path d={wedge} fill="#D64F3F" />
      {Array.from({ length: 12 }, (_, i) => {
        const t = (i * 30 * Math.PI) / 180;
        return <text key={i} x={50 - 43.5 * Math.sin(t)} y={50 - 43.5 * Math.cos(t) + 1.6} fontSize="4.6" fontWeight="800"
          textAnchor="middle" fill="#111">{i * 5}</text>;
      })}
      <g transform={`rotate(${ang} 50 50)`}><line x1="50" y1="50" x2="50" y2="18" stroke="rgba(0,0,0,.25)" strokeWidth="2.4" strokeLinecap="round" /><line x1="50" y1="50" x2="50" y2="18" stroke="#fff" strokeWidth="1.4" strokeLinecap="round" /></g>
      <circle cx="50" cy="50" r="4" fill="#3f3f3f" /><circle cx="50" cy="50" r="1.4" fill="#fff" />
      <text x="50" y="64" fontSize="3.6" fontWeight="800" textAnchor="middle" fill="rgba(0,0,0,.45)">GLINT</text>
    </svg>
  );
}
