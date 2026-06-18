import { readFile } from "node:fs/promises";
import { join } from "node:path";
import { parse } from "smol-toml";
import { r2d2Path } from "./exec.js";

export async function loadEnabledTools(allTools: string[]): Promise<Set<string>> {
  const configPath = join(r2d2Path(), "config", "r2-d2", "mcp.toml");
  try {
    const text = await readFile(configPath, "utf8");
    const raw = parse(text) as { tools?: Record<string, boolean> };
    const tools = raw.tools ?? {};
    const enabled = new Set<string>();

    for (const name of allTools) {
      if (tools[name] === false) {
        continue;
      }
      if (tools[name] === true || !(name in tools)) {
        enabled.add(name);
      }
    }

    return enabled;
  } catch (err) {
    if ((err as NodeJS.ErrnoException).code === "ENOENT") {
      return new Set(allTools);
    }
    throw err;
  }
}
