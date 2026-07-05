import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import { hyprctlJson, runR2d2Script } from "./exec.js";
import { loadEnabledTools } from "./config.js";

function textResult(text: string) {
  return { content: [{ type: "text" as const, text }] };
}

interface ToolDef {
  description: string;
  schema: Record<string, z.ZodTypeAny>;
  handler: (args: Record<string, unknown>) => Promise<string>;
}

const TOOL_REGISTRY: Record<string, ToolDef> = {
  lock_screen: {
    description: "Lock the Hyprland session",
    schema: {},
    handler: async () => runR2d2Script("lock_screen"),
  },
  screenshot: {
    description: "Capture a screenshot and return the saved file path",
    schema: {
      mode: z
        .enum(["smart", "region", "windows", "fullscreen"])
        .optional()
        .describe("Capture mode (default: fullscreen for non-interactive agent use)"),
    },
    handler: async ({ mode }) => runR2d2Script("screenshot", [String(mode ?? "fullscreen"), "save"]),
  },
  battery_remaining: {
    description: "Get battery percentage as an integer",
    schema: {},
    handler: async () => runR2d2Script("battery_remaining"),
  },
  toggle_nightlight: {
    description: "Toggle night light filter",
    schema: {},
    handler: async () => runR2d2Script("toggle_nightlight"),
  },
  toggle_waybar: {
    description: "Toggle the top bar visibility",
    schema: {},
    handler: async () => runR2d2Script("toggle_waybar"),
  },
  toggle_notification_silencing: {
    description: "Toggle do-not-disturb / notification silencing",
    schema: {},
    handler: async () => runR2d2Script("toggle_notification_silencing"),
  },
  notification_dismiss: {
    description: "Dismiss all notifications",
    schema: {},
    handler: async () => runR2d2Script("notification_dismiss"),
  },
  theme_set_background: {
    description: "Set desktop wallpaper from an image path",
    schema: { path: z.string().describe("Absolute path to wallpaper image") },
    handler: async ({ path }) => runR2d2Script("theme_bg_set", [String(path)]),
  },
  desktop_windows: {
    description: "List open Hyprland windows as JSON",
    schema: {},
    handler: async () => hyprctlJson(["clients", "-j"]),
  },
  system_reboot: {
    description: "Reboot the system (requires confirm: true)",
    schema: { confirm: z.boolean().describe("Must be true to proceed") },
    handler: async ({ confirm }) => runR2d2Script("system_reboot", [], Boolean(confirm)),
  },
  system_shutdown: {
    description: "Shut down the system (requires confirm: true)",
    schema: { confirm: z.boolean().describe("Must be true to proceed") },
    handler: async ({ confirm }) => runR2d2Script("system_shutdown", [], Boolean(confirm)),
  },
  open_application: {
    description: "Launch or focus an application by window pattern",
    schema: {
      window_pattern: z.string().describe("Window class or title pattern"),
      launch_command: z.string().optional().describe("Optional launch command override"),
    },
    handler: async ({ window_pattern, launch_command }) => {
      const args = [String(window_pattern)];
      if (launch_command) {
        args.push(String(launch_command));
      }
      return runR2d2Script("launch_or_focus", args);
    },
  },
  theme_set_accent: {
    description: "Extract and apply accent color from the current wallpaper",
    schema: {},
    handler: async () => runR2d2Script("theme_accent_from_bg"),
  },
  volume_set: {
    description: "Set default audio sink volume (0-100 or percent string)",
    schema: { percent: z.number().describe("Volume percent (0-100)") },
    handler: async ({ percent }) => runR2d2Script("volume_set", [String(percent)]),
  },
  volume_toggle_mute: {
    description: "Toggle mute on the default audio sink",
    schema: {},
    handler: async () => runR2d2Script("volume_toggle_mute"),
  },
  media_play_pause: {
    description: "Toggle media playback via playerctl",
    schema: {},
    handler: async () => runR2d2Script("media_play_pause"),
  },
  clipboard_set: {
    description: "Copy text to the clipboard",
    schema: { text: z.string().describe("Text to copy") },
    handler: async ({ text }) => runR2d2Script("clipboard_set", [String(text)]),
  },
  ocr: {
    description:
      "Run OCR on a screenshot file to read on-screen text (dialogs, URLs, code). Returns the recognized text.",
    schema: {
      image_path: z
        .string()
        .optional()
        .describe("Absolute path to a PNG to OCR. If omitted, captures a fresh fullscreen screenshot first."),
    },
    handler: async ({ image_path }) => {
      let path = String(image_path ?? "");
      if (!path) {
        // Capture a fresh fullscreen screenshot in agent-friendly save mode.
        path = await runR2d2Script("screenshot", ["fullscreen", "save"]);
      }
      return runR2d2Script("ocr", ["--file", path]);
    },
  },
};

export async function createR2d2Server(): Promise<McpServer> {
  const server = new McpServer({
    name: "r2d2",
    version: "0.2.0",
  });

  const enabled = await loadEnabledTools(Object.keys(TOOL_REGISTRY));

  for (const [name, tool] of Object.entries(TOOL_REGISTRY)) {
    if (!enabled.has(name)) {
      continue;
    }

    server.tool(name, tool.description, tool.schema, async (args) => textResult(await tool.handler(args)));
  }

  return server;
}
