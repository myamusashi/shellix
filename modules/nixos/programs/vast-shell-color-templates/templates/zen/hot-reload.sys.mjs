// background module (Sine main process). Polls enabled mods' css files and
// re-applies mod styles live when any of them changes on disk.
//
// No top-level await (importESModule rejects async modules) and no window
// timers: main-process scopes only have the ones from Timer.sys.mjs.
const MODS_JSON_POLL_MS = 1000;

const { setTimeout } = ChromeUtils.importESModule(
  "resource://gre/modules/Timer.sys.mjs"
);

const enabledStyleFiles = (mods, chromeDir) => {
  const files = [];
  for (const mod of Object.values(mods)) {
    if (!mod.enabled || !mod.style) continue;
    for (const relativePath of Object.values(mod.style)) {
      if (relativePath) files.push(PathUtils.join(chromeDir, "sine-mods", mod.id, relativePath));
    }
  }
  return files;
};

const collect = async (chromeDir) => {
  const mods = await IOUtils.readJSON(PathUtils.join(chromeDir, "sine-mods", "mods.json"));
  const modifiedTimes = new Map();
  for (const path of enabledStyleFiles(mods, chromeDir)) {
    try {
      modifiedTimes.set(path, (await IOUtils.stat(path)).lastModified);
    } catch {
      // file not rendered yet or mod removed
    }
  }
  return modifiedTimes;
};

const hasChanged = (previous, current) => {
  if (previous.size !== current.size) return true;
  for (const [path, modifiedTime] of current) {
    if (previous.get(path) !== modifiedTime) return true;
  }
  return false;
};

try {
  const sheets = ChromeUtils.importESModule(
    "chrome://userscripts/content/services/stylesheets.sys.mjs"
  ).default;
  const chromeDir = Services.dirsvc.get("UChrm", Ci.nsIFile).path;

  (async () => {
    let previousTimes = await collect(chromeDir);

    const tick = async () => {
      try {
        const currentTimes = await collect(chromeDir);
        if (hasChanged(previousTimes, currentTimes)) {
          await sheets.rebuildMods(true);
          // the rebuild may rewrite these files; don't treat that as a user change
          previousTimes = await collect(chromeDir);
        }
      } catch (error) {
        console.warn("[zen-matugen] watcher tick failed:", error);
      }
      setTimeout(tick, MODS_JSON_POLL_MS);
    };

    setTimeout(tick, MODS_JSON_POLL_MS);
  })();
} catch (error) {
  console.error("[zen-matugen] watcher failed to start:", error);
}
