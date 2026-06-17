import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import { hyprctlJson, runR2d2Script } from "./exec.js";

function textResult(text: string) {
  return { content: [{ type: "text" as const, text }] };
}

export function createR2d2Server(): McpServer {
  const server = new McpServer({
    name: "r2d2",
    version: "0.1.0",
  });

  server.tool(
    "lock_screen",
    "Lock the Hyprland session",
    {},
    async () => textResult(await runR2d2Script("lock_screen")),
  );

  server.tool(
    "screenshot",
    "Capture a screenshot",
    {},
    async () => textResult(await runR2d2Script("screenshot")),
  );

  server.tool(
    "battery_remaining",
    "Get battery percentage as an integer",
    {},
    async () => textResult(await runR2d2Script("battery_remaining")),
  );

  server.tool(
    "toggle_nightlight",
    "Toggle night light filter",
    {},
    async () => textResult(await runR2d2Script("toggle_nightlight")),
  );

  server.tool(
    "toggle_waybar",
    "Toggle the top bar visibility",
    {},
    async () => textResult(await runR2d2Script("toggle_waybar")),
  );

  server.tool(
    "toggle_notification_silencing",
    "Toggle do-not-disturb / notification silencing",
    {},
    async () => textResult(await runR2d2Script("toggle_notification_silencing")),
  );

  server.tool(
    "notification_dismiss",
    "Dismiss all notifications",
    {},
    async () => textResult(await runR2d2Script("notification_dismiss")),
  );

  server.tool(
    "theme_set_background",
    "Set desktop wallpaper from an image path",
    { path: z.string().describe("Absolute path to wallpaper image") },
    async ({ path }) => textResult(await runR2d2Script("theme_bg_set", [path])),
  );

  server.tool(
    "desktop_windows",
    "List open Hyprland windows as JSON",
    {},
    async () => textResult(await hyprctlJson(["clients", "-j"])),
  );

  server.tool(
    "system_reboot",
    "Reboot the system (requires confirm: true)",
    { confirm: z.boolean().describe("Must be true to proceed") },
    async ({ confirm }) => textResult(await runR2d2Script("system_reboot", [], confirm)),
  );

  server.tool(
    "system_shutdown",
    "Shut down the system (requires confirm: true)",
    { confirm: z.boolean().describe("Must be true to proceed") },
    async ({ confirm }) => textResult(await runR2d2Script("system_shutdown", [], confirm)),
  );

  return server;
}
