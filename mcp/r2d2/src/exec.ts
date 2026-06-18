import { execFile } from "node:child_process";
import { access } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

export function r2d2Path(): string {
  return process.env.R2D2_PATH ?? join(homedir(), ".local", "share", "r2-d2");
}

export const COMMANDS = {
  lock_screen: "r2-d2-lock-screen",
  screenshot: "r2-d2-cmd-screenshot",
  battery_remaining: "r2-d2-battery-remaining",
  toggle_nightlight: "r2-d2-toggle-nightlight",
  toggle_waybar: "r2-d2-toggle-waybar",
  toggle_notification_silencing: "r2-d2-toggle-notification-silencing",
  notification_dismiss: "r2-d2-notification-dismiss",
  theme_bg_set: "r2-d2-theme-bg-set",
  system_reboot: "r2-d2-system-reboot",
  system_shutdown: "r2-d2-system-shutdown",
  launch_or_focus: "r2-d2-launch-or-focus",
  theme_accent_from_bg: "r2-d2-theme-accent-from-bg",
  volume_set: "r2-d2-volume-set",
  volume_toggle_mute: "r2-d2-volume-toggle-mute",
  media_play_pause: "r2-d2-media-play-pause",
  clipboard_set: "r2-d2-clipboard-set",
} as const;

export type R2d2Command = keyof typeof COMMANDS;

const DESTRUCTIVE: R2d2Command[] = ["system_reboot", "system_shutdown"];

export function isDestructive(name: R2d2Command): boolean {
  return DESTRUCTIVE.includes(name);
}

async function scriptExists(name: R2d2Command): Promise<boolean> {
  const script = join(r2d2Path(), "bin", COMMANDS[name]);
  try {
    await access(script);
    return true;
  } catch {
    return false;
  }
}

export async function runR2d2Script(
  name: R2d2Command,
  args: string[] = [],
  confirm = false,
): Promise<string> {
  if (!(await scriptExists(name))) {
    throw new Error(`Tool not installed: ${name} (${COMMANDS[name]})`);
  }

  if (isDestructive(name) && !confirm) {
    throw new Error(`${name} requires confirm: true`);
  }

  const script = join(r2d2Path(), "bin", COMMANDS[name]);
  const { stdout, stderr } = await execFileAsync(script, args, {
    timeout: 60_000,
    env: process.env,
  });
  return (stdout || stderr).trim();
}

export async function hyprctlJson(args: string[]): Promise<string> {
  const { stdout } = await execFileAsync("hyprctl", args, { timeout: 10_000, env: process.env });
  return stdout.trim();
}
