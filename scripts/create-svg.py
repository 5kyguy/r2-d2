#!/usr/bin/env python3

from PIL import Image
import base64
from io import BytesIO

# Threshold for separating background from foreground text
# Dark pixels (luminance < THRESHOLD) become transparent background.
THRESHOLD = 64

def load_logo(path: str) -> Image.Image:
    return Image.open(path).convert("RGBA")

def extract_foreground_alpha(img: Image.Image) -> Image.Image:
    """Return an image whose alpha channel marks the non-background pixels."""
    width, height = img.size
    pixels = img.load()

    # We'll build a new image that only cares about alpha (RGBA for convenience)
    alpha_img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    alpha_pixels = alpha_img.load()

    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]

            if a == 0:
                # Already transparent, keep it transparent
                continue

            luminance = int(0.299 * r + 0.587 * g + 0.114 * b)

            if luminance >= THRESHOLD:
                # Foreground (text): keep alpha, color will be set later
                alpha_pixels[x, y] = (255, 255, 255, a)
            # else: background stays fully transparent

    return alpha_img

def colorize_foreground(alpha_img: Image.Image, color) -> Image.Image:
    """Apply a solid color (R, G, B) to all non-transparent pixels of alpha_img."""
    width, height = alpha_img.size
    src_pixels = alpha_img.load()

    colored = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    dst_pixels = colored.load()

    cr, cg, cb = color

    for y in range(height):
        for x in range(width):
            _, _, _, a = src_pixels[x, y]
            if a == 0:
                continue
            dst_pixels[x, y] = (cr, cg, cb, a)

    return colored

def png_to_svg_data_uri(img: Image.Image) -> str:
    """Encode a PIL image as a PNG data URI suitable for embedding in SVG."""
    buffer = BytesIO()
    img.save(buffer, format="PNG")
    b64 = base64.b64encode(buffer.getvalue()).decode("ascii")
    return f"data:image/png;base64,{b64}"

def save_svg_with_embedded_png(img: Image.Image, svg_path: str):
    width, height = img.size
    data_uri = png_to_svg_data_uri(img)

    svg_content = f"""<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">
  <image href="{data_uri}" width="{width}" height="{height}" />
</svg>
"""
    with open(svg_path, "w", encoding="utf-8") as f:
        f.write(svg_content)

def main():
    img = load_logo("assets/logo.png")
    alpha_img = extract_foreground_alpha(img)

    colors = {
        "white": (255, 255, 255),
        "silver": (192, 192, 192),
        "black": (0, 0, 0),
        "blue": (15, 0, 255),
    }

    for color in colors.keys():
        colored_img = colorize_foreground(alpha_img, colors[color])
        save_svg_with_embedded_png(colored_img, f"assets/logo-{color}.svg")

    icon_img = Image.open("assets/icon.png")
    alpha_img = extract_foreground_alpha(icon_img)
    colored_img = colorize_foreground(alpha_img, colors["black"])
    save_svg_with_embedded_png(colored_img, "assets/icon.svg")

if __name__ == "__main__":
    main()
