#!/usr/bin/env python3
"""Generate docs/fixtures/contrast-v2.json from real matugen output.

The v2 visual contract uses matugen (Material You) as the theme engine. This
script runs matugen for each sample source color in both dark and light modes
and writes the resulting palette to the committed fixture. Tests compare
r2-d2-theme-state output against that fixture, so the fixture is the source of
truth and tests do not need matugen to run; regenerating it does.

Usage: python3 tests/generate-theme-fixture.py
Requires: matugen (matugen-bin) on PATH.
"""
import json
import os
import subprocess
import tempfile
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
FIXTURE = REPO / "docs/fixtures/contrast-v2.json"

SCHEME = "scheme-tonal-spot"
MATUGEN_VERSION_MIN = "4.2.0"

# Curated Material You role set used by the v2 document and templates.
ROLES = [
    "primary", "on_primary", "primary_container", "on_primary_container",
    "inverse_primary",
    "secondary", "on_secondary", "secondary_container", "on_secondary_container",
    "tertiary", "on_tertiary", "tertiary_container", "on_tertiary_container",
    "error", "on_error", "error_container", "on_error_container",
    "background", "on_background",
    "surface", "on_surface", "surface_variant", "on_surface_variant",
    "surface_container", "surface_container_low", "surface_container_high",
    "surface_container_highest", "surface_container_lowest",
    "surface_dim", "surface_bright", "surface_tint",
    "outline", "outline_variant",
    "inverse_surface", "inverse_on_surface",
    "shadow", "scrim", "source_color",
]

# Same sample set as contrast-v1.json so the two contracts can be compared.
SAMPLES = {
    "saturated_blue": "#1D4ED8",
    "bright_yellow": "#F5E642",
    "saturated_red": "#E11D48",
    "neutral_wallpaper": "#EAEAEA",
    "mid_gray": "#777777",
    "dark_green": "#0B3D2E",
    "pure_white": "#FFFFFF",
    "near_black": "#141414",
}

TEMPLATE_BODY = "{\n" + ",\n".join(
    f'  "{role}": "{{{{colors.{role}.default.hex}}}}"' for role in ROLES
) + "\n}\n"


def render_palette(src_hex: str, mode: str, template: Path, config: Path, out: Path) -> dict:
    config.write_text(
        "[config]\n"
        f'[templates.palette]\n'
        f'input_path = "{template}"\n'
        f'output_path = "{out}"\n'
    )
    subprocess.run(
        ["matugen", "color", "hex", src_hex.lstrip("#"), "--mode", mode,
         "-c", str(config), "-q"],
        check=True, capture_output=True,
    )
    data = json.loads(out.read_text())
    return {role: data[role].upper() for role in ROLES}


def main() -> None:
    version = subprocess.run(["matugen", "--version"], capture_output=True, text=True)
    raw = version.stdout.strip().splitlines()[0] if version.stdout else ""
    matugen_version = raw.split()[-1] if raw.split() else "unknown"

    samples: dict[str, dict] = {}
    with tempfile.TemporaryDirectory(prefix="matugen-fixture-") as tmp:
        tmpdir = Path(tmp)
        template = tmpdir / "palette.json"
        config = tmpdir / "config.toml"
        out = tmpdir / "out.json"
        template.write_text(TEMPLATE_BODY)
        for name, source in SAMPLES.items():
            dark = render_palette(source, "dark", template, config, out)
            light = render_palette(source, "light", template, config, out)
            samples[name] = {"source": source.upper(), "dark": dark, "light": light}

    fixture = {
        "contract": "skyguy-visual",
        "version": 2,
        "engine": "matugen",
        "matugen_version": matugen_version,
        "scheme": SCHEME,
        "modes": ["dark", "light"],
        "roles": ROLES,
        "samples": samples,
    }
    FIXTURE.parent.mkdir(parents=True, exist_ok=True)
    FIXTURE.write_text(json.dumps(fixture, indent=2, ensure_ascii=False) + "\n")
    print(f"Wrote {FIXTURE} ({len(samples)} samples, {len(ROLES)} roles each)")


if __name__ == "__main__":
    main()
