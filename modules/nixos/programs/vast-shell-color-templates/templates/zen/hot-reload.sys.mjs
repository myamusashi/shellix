// background module (Sine main process). Polls enabled mods' css files and
// re-applies mod styles live when any of them changes on disk.
//
// No top-level await (importESModule rejects async modules) and no window
// timers: main-process scopes only have the ones from Timer.sys.mjs.
const MODS_JSON_POLL_MS = 1000;

const { setInterval } = ChromeUtils.importESModule(
  "resource://gre/modules/Timer.sys.mjs"
);

const enabledStyleFiles = (mods, chromeDir) => {
  const files = [];
  for (const mod of Object.values(mods)) {
    if (!mod.enabled || !mod.style) continue;
    for (const rel of Object.values(mod.style)) {
      if (rel) files.push(PathUtils.join(chromeDir, "sine-mods", mod.id, rel));
    }
  }
  return files;
};

const collect = async (chromeDir) => {
  const mods = await IOUtils.readJSON(PathUtils.join(chromeDir, "sine-mods", "mods.json"));
  const seen = new Map();
  for (const path of enabledStyleFiles(mods, chromeDir)) {
    try {
      seen.set(path, (await IOUtils.stat(path)).lastModified);
    } catch {
      // file not rendered yet (first run) or mod removed: no state
    }
  }
  return seen;
};

try {
  const sheets = ChromeUtils.importESModule(
    "chrome://userscripts/content/services/stylesheets.sys.mjs"
  ).default;
  const chromeDir = Services.dirsvc.get("UChrm", Ci.nsIFile).path;

  (async () => {
    try {
      const lastMtimes = await collect(chromeDir); // prime: startup must not force a rebuild

      setInterval(async () => {
        try {
          const next = await collect(chromeDir);
          let changed = false;
          for (const [path, mtime] of next) {
            if (lastMtimes.get(path) !== mtime) changed = true;
          }
          for (const [path, mtime] of lastMtimes) {
            if (!next.has(path) || next.get(path) !== mtime) changed = true;
          }
          for (const [path, mtime] of next) lastMtimes.set(path, mtime);
          if (changed) await sheets.rebuildMods(true);
        } catch (err) {
          console.warn("[zen-matugen] watcher tick failed:", err);
        }
      }, MODS_JSON_POLL_MS);
    } catch (err) {
      console.error("[zen-matugen] watcher failed to start:", err);
    }
  })();
} catch (err) {
  console.error("[zen-matugen] watcher failed to start:", err);
}
