#!/usr/bin/env node
// Windows driver for website-to-design-md's styleProbe extraction.
// The vendor script (extract-browser-evidence.mjs) resolves agent-browser via
// `bash -lc "command -v ..."` and spawnSyncs the resulting MSYS-path shell shim,
// which cannot work on win32. This driver reads the SAME styleProbe from the
// vendor script at runtime (no fork/drift) and drives the real win32 exe.
// Usage: node run-styleprobe.mjs <url> [outPath]

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";

const url = process.argv[2];
const outFile = process.argv[3]
  ? path.resolve(process.argv[3])
  : path.resolve(process.cwd(), "design/evidence/site.browser.json");
if (!url) {
  console.error("Usage: node run-styleprobe.mjs <url> [outPath]");
  process.exit(1);
}

const VENDOR_SCRIPT =
  process.env.VENDOR_SCRIPT ||
  path.join(os.homedir(), ".claude", "skills", "website-to-design-md", "scripts", "extract-browser-evidence.mjs");

function resolveAgentBrowser() {
  if (process.platform !== "win32") return "agent-browser";
  const r = spawnSync("bash", ["-lc", "command -v agent-browser"], { encoding: "utf8" });
  const shim = (r.stdout || "").trim().split("\n")[0];
  const m = /^\/([a-zA-Z])\/(.*)$/.exec(shim);
  const winShim = m ? `${m[1].toUpperCase()}:/${m[2]}` : shim;
  const exe = path.join(path.dirname(winShim), "node_modules", "agent-browser", "bin", "agent-browser-win32-x64.exe");
  if (!fs.existsSync(exe)) throw new Error(`agent-browser win32 exe not found at: ${exe}`);
  return exe;
}

function loadStyleProbe() {
  const src = fs.readFileSync(VENDOR_SCRIPT, "utf8");
  const m = /const styleProbe = (`[\s\S]*?`);/.exec(src);
  if (!m) throw new Error(`styleProbe not found in vendor script: ${VENDOR_SCRIPT}`);
  return (0, eval)(m[1]); // trusted local file; decodes template-literal escapes
}

const exe = resolveAgentBrowser();
const session = `dfw-extract-${process.pid}`;

function ab(args, opts = {}) {
  const r = spawnSync(exe, ["--session", session, ...args], {
    encoding: "utf8",
    input: opts.input,
    windowsHide: true,
    maxBuffer: 64 * 1024 * 1024,
    timeout: opts.timeout ?? 60000,
    killSignal: "SIGKILL",
  });
  if (!opts.allowFailure && r.status !== 0) {
    throw new Error(`agent-browser ${args.join(" ")} failed:\n${r.stderr || r.stdout || "(no output)"}`);
  }
  return r;
}

// First command of a session spawns the daemon, which inherits our stdio pipe
// handles and never exits -> spawnSync would wait on pipe EOF forever (win32).
// Bootstrap with stdio ignored so the daemon holds NUL handles instead.
function bootstrapDaemon() {
  spawnSync(exe, ["--session", session, "open"], {
    stdio: "ignore",
    windowsHide: true,
    timeout: 120000,
    killSignal: "SIGKILL",
  });
}

function evalJson(expression) {
  const r = ab(["eval", "--stdin"], { input: `${expression}\n` });
  const lines = (r.stdout || "").split(/\r?\n/).map((l) => l.trim()).filter(Boolean);
  for (let i = lines.length - 1; i >= 0; i -= 1) {
    try { return JSON.parse(JSON.parse(lines[i])); } catch { /* keep scanning */ }
  }
  for (let i = lines.length - 1; i >= 0; i -= 1) {
    try { return JSON.parse(lines[i]); } catch { /* keep scanning */ }
  }
  throw new Error(`eval output was not JSON:\n${(r.stdout || "").slice(-500)}`);
}

function settleAndSweep() {
  ab(["wait", "--load", "networkidle"], { allowFailure: true });
  ab(["wait", "1500"], { allowFailure: true });
  ab(["eval", "--stdin"], { input: "window.scrollTo(0, 0); 'ok';\n", allowFailure: true });
  ab(["scroll", "down", "1400"], { allowFailure: true });
  ab(["wait", "300"], { allowFailure: true });
  ab(["scroll", "down", "2200"], { allowFailure: true });
  ab(["wait", "300"], { allowFailure: true });
  ab(["eval", "--stdin"], { input: "window.scrollTo(0, 0); 'ok';\n", allowFailure: true });
  ab(["wait", "300"], { allowFailure: true });
}

const styleProbe = loadStyleProbe();
const probeExpr = `JSON.stringify(${styleProbe})`;
const results = { url, capturedAt: new Date().toISOString(), pages: {}, tooling: { mode: "agent-browser-cli-win-driver", exe, vendorScript: VENDOR_SCRIPT, session } };

try {
  bootstrapDaemon();
  ab(["open", url], { timeout: 120000 });
  ab(["set", "viewport", "1440", "1400"], { allowFailure: true });
  settleAndSweep();
  results.pages.desktop = evalJson(probeExpr);

  ab(["set", "device", "iPhone 14"], { allowFailure: true });
  ab(["reload"], { allowFailure: true });
  settleAndSweep();
  results.pages.mobile = evalJson(probeExpr);
} finally {
  ab(["close"], { allowFailure: true });
}

fs.mkdirSync(path.dirname(outFile), { recursive: true });
fs.writeFileSync(outFile, JSON.stringify(results, null, 2));
console.log(outFile);
