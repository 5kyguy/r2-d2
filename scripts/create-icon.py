#!/usr/bin/env python3

from collections import deque
from typing import List, Tuple
import base64
from io import BytesIO

from PIL import Image

LOGO_PATH = "assets/logo.png"


def load_logo(path: str) -> Image.Image:
    # Use RGBA so we can build transparent icons later
    return Image.open(path).convert("RGBA")

def find_letter_bboxes(img: Image.Image) -> List[Tuple[int, int, int, int]]:
    """Return a list of bounding boxes (min_x, min_y, max_x, max_y) for each letter."""
    width, height = img.size
    pixels = img.load()

    visited = [[False] * width for _ in range(height)]
    bboxes: List[Tuple[int, int, int, int]] = []

    def is_foreground(px: Tuple[int, int, int, int]) -> bool:
        r, g, b, _ = px
        return (r, g, b) == (255, 255, 255)

    for y in range(height):
        for x in range(width):
            if visited[y][x]:
                continue

            if not is_foreground(pixels[x, y]):
                continue

            # Start a BFS for this letter
            min_x = max_x = x
            min_y = max_y = y
            queue: deque[Tuple[int, int]] = deque()
            queue.append((x, y))
            visited[y][x] = True

            while queue:
                cx, cy = queue.popleft()

                if cx < min_x:
                    min_x = cx
                if cx > max_x:
                    max_x = cx
                if cy < min_y:
                    min_y = cy
                if cy > max_y:
                    max_y = cy

                for nx, ny in (
                    (cx - 1, cy),
                    (cx + 1, cy),
                    (cx, cy - 1),
                    (cx, cy + 1),
                ):
                    if not (0 <= nx < width and 0 <= ny < height):
                        continue
                    if visited[ny][nx]:
                        continue
                    if not is_foreground(pixels[nx, ny]):
                        continue

                    visited[ny][nx] = True
                    queue.append((nx, ny))

            bboxes.append((min_x, min_y, max_x, max_y))

    return bboxes


def extract_letter_images(
    img: Image.Image, bboxes: List[Tuple[int, int, int, int]]
) -> List[Image.Image]:
    """Crop each letter to its bounding box, with background made transparent."""
    letter_images: List[Image.Image] = []
    pixels = img.load()

    for (min_x, min_y, max_x, max_y) in bboxes:
        w = max_x - min_x + 1
        h = max_y - min_y + 1
        letter_img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        letter_pixels = letter_img.load()

        for y in range(h):
            for x in range(w):
                r, g, b, a = pixels[min_x + x, min_y + y]
                if (r, g, b) == (255, 255, 255):
                    letter_pixels[x, y] = (255, 255, 255, a)
                else:
                    letter_pixels[x, y] = (0, 0, 0, 0)

        letter_images.append(letter_img)

    return letter_images


def png_to_svg_data_uri(img: Image.Image) -> str:
    buffer = BytesIO()
    img.save(buffer, format="PNG")
    b64 = base64.b64encode(buffer.getvalue()).decode("ascii")
    return f"data:image/png;base64,{b64}"


def save_svg_with_embedded_png(img: Image.Image, path: str) -> None:
    width, height = img.size
    data_uri = png_to_svg_data_uri(img)
    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">
  <image href="{data_uri}" width="{width}" height="{height}" />
</svg>
"""
    with open(path, "w", encoding="utf-8") as f:
        f.write(svg)


def build_icon_from_letters(letter_images: List[Image.Image], x_margin: int) -> Image.Image:
    """
    Build a 2x2 quadrant icon from letters R, 2, D, 2.

    We assume bboxes/order: [R, 2, -, D, 2] and ignore the hyphen.
    The first letter (R) has 12 extra pixels of height; that is ignored for
    spacing calculations but visually preserved.
    """
    # Ensure a non-negative margin; this is the "x" distance from the logo top
    # border, reused as padding around each letter.
    if x_margin < 0:
        x_margin = 0

    # Pick letters R, 2, D, 2 (skip index 2 which is the hyphen)
    indices = [0, 1, 2, 3]
    base_letters = [letter_images[i] for i in indices]

    # First, pad each letter with x_margin transparent pixels on all sides so
    # that each has "x" space around it before we place it into quadrants.
    letters: List[Image.Image] = []
    for img in base_letters:
        w, h = img.size
        padded = Image.new("RGBA", (w + 2 * x_margin, h + 2 * x_margin), (0, 0, 0, 0))
        padded.alpha_composite(img, (x_margin, x_margin))
        letters.append(padded)

    # Compute logical sizes for spacing (R has its extra 12px ignored)
    logical_heights = []
    widths = []
    for idx, img in enumerate(letters):
        w, h = img.size
        widths.append(w)
        if idx == 0:
            logical_heights.append(max(h - 12, 1))
        else:
            logical_heights.append(h)

    canonical_w = max(widths)
    canonical_h = max(logical_heights)

    tile_w = canonical_w
    tile_h = canonical_h

    icon_w = tile_w * 2
    icon_h = tile_h * 2

    icon = Image.new("RGBA", (icon_w, icon_h), (0, 0, 0, 255))

    quadrant_centers = [
        (tile_w // 2, tile_h // 2),  # top-left  -> R
        (icon_w - tile_w // 2, tile_h // 2),  # top-right -> first 2
        (tile_w // 2, icon_h - tile_h // 2),  # bottom-left -> D
        (icon_w - tile_w // 2, icon_h - tile_h // 2),  # bottom-right -> second 2
    ]

    for idx, (letter_img, (cx, cy)) in enumerate(zip(letters, quadrant_centers)):
        w, h = letter_img.size
        # Adjust vertical placement for the first letter (R) to ignore the
        # extra 12px leg in spacing calculations but keep it visible.
        if idx == 0:
            layout_offset_y = 6  # half of 12px
        else:
            layout_offset_y = 0

        paste_x = int(cx - w / 2)
        paste_y = int(cy - h / 2 + layout_offset_y)

        icon.alpha_composite(letter_img, (paste_x, paste_y))

    return icon


def make_square_icon(icon: Image.Image) -> Image.Image:
    """Pad left/right (or top/bottom) to make the icon 1:1."""
    w, h = icon.size
    if w == h:
        return icon

    if w < h:
        # Pad left and right to match height (requested case).
        total_pad = h - w
        pad_left = total_pad // 2
        pad_right = total_pad - pad_left
        new_icon = Image.new("RGBA", (h, h), (0, 0, 0, 255))
        new_icon.alpha_composite(icon, (pad_left, 0))
        return new_icon

    # If width > height, pad top/bottom to keep it square.
    total_pad = w - h
    pad_top = total_pad // 2
    pad_bottom = total_pad - pad_top
    new_icon = Image.new("RGBA", (w, w), (0, 0, 0, 255))
    new_icon.alpha_composite(icon, (0, pad_top))
    return new_icon


def is_foreground_pixel(px: Tuple[int, int, int, int]) -> bool:
    """Return True if the pixel is part of the white foreground."""
    r, g, b, _ = px
    return (r, g, b) == (255, 255, 255)


def find_components(img: Image.Image):
    """
    Find connected white components (letters) in an already-built icon image.

    Returns a list of (coords, bbox) where:
      - coords is a list of (x, y) tuples belonging to the component
      - bbox is (min_x, min_y, max_x, max_y)
    """
    width, height = img.size
    pixels = img.load()

    visited: List[List[bool]] = [[False] * width for _ in range(height)]
    components = []

    for y in range(height):
        for x in range(width):
            if visited[y][x]:
                continue
            if not is_foreground_pixel(pixels[x, y]):
                continue

            queue: deque[Tuple[int, int]] = deque()
            queue.append((x, y))
            visited[y][x] = True

            coords: List[Tuple[int, int]] = []
            min_x = max_x = x
            min_y = max_y = y

            while queue:
                cx, cy = queue.popleft()
                coords.append((cx, cy))

                if cx < min_x:
                    min_x = cx
                if cx > max_x:
                    max_x = cx
                if cy < min_y:
                    min_y = cy
                if cy > max_y:
                    max_y = cy

                for nx, ny in (
                    (cx - 1, cy),
                    (cx + 1, cy),
                    (cx, cy - 1),
                    (cx, cy + 1),
                ):
                    if not (0 <= nx < width and 0 <= ny < height):
                        continue
                    if visited[ny][nx]:
                        continue
                    if not is_foreground_pixel(pixels[nx, ny]):
                        continue

                    visited[ny][nx] = True
                    queue.append((nx, ny))

            components.append((coords, (min_x, min_y, max_x, max_y)))

    return components


def compute_top_margin(img: Image.Image) -> int:
    """
    Compute x: the distance between the top border and the letters in the icon.

    This is defined as the smallest y for which a white foreground pixel appears.
    """
    width, height = img.size
    pixels = img.load()

    for y in range(height):
        for x in range(width):
            if is_foreground_pixel(pixels[x, y]):
                return y

    return 0


def transform_icon_pairs(img: Image.Image) -> Image.Image:
    """
    Move the top two letters to the left and the bottom two to the right as pairs.

    - Background is black.
    - Foreground is white.
    - Horizontal margin from border is the same "x" distance as the vertical
      margin between the top border and the first letter.
    """
    width, height = img.size
    components = find_components(img)
    if not components:
        return img

    x_margin = 4 * compute_top_margin(img)

    # Split components into top and bottom groups based on vertical center.
    mid_y = height / 2.0
    top_components = []
    bottom_components = []

    for coords, bbox in components:
        min_x, min_y, max_x, max_y = bbox
        center_y = (min_y + max_y) / 2.0
        if center_y < mid_y:
            top_components.append((coords, bbox))
        else:
            bottom_components.append((coords, bbox))

    # Compute group bounding boxes so each pair moves as a rigid unit.
    def group_bbox(group):
        if not group:
            return None
        g_min_x = min(b[0] for _, b in group)
        g_max_x = max(b[2] for _, b in group)
        return g_min_x, g_max_x

    top_bbox = group_bbox(top_components)
    bottom_bbox = group_bbox(bottom_components)

    dx_top = 0
    dx_bottom = 0

    if top_bbox is not None:
        top_min_x, _ = top_bbox
        # Align the left edge of the top pair to x_margin.
        dx_top = x_margin - top_min_x

    if bottom_bbox is not None:
        _, bottom_max_x = bottom_bbox
        # Align the right edge of the bottom pair to width - 1 - x_margin.
        target_max_x = width - 1 - x_margin
        dx_bottom = target_max_x - bottom_max_x

    # New image: solid black background, letters drawn in white.
    new_img = Image.new("RGBA", (width, height), (0, 0, 0, 255))
    new_pixels = new_img.load()

    # Draw top components with shared horizontal offset.
    for coords, _ in top_components:
        for x, y in coords:
            nx = x + dx_top
            ny = y
            if 0 <= nx < width and 0 <= ny < height:
                new_pixels[nx, ny] = (255, 255, 255, 255)

    # Draw bottom components with shared horizontal offset.
    for coords, _ in bottom_components:
        for x, y in coords:
            nx = x + dx_bottom
            ny = y
            if 0 <= nx < width and 0 <= ny < height:
                new_pixels[nx, ny] = (255, 255, 255, 255)

    return new_img


def main() -> None:
    img = load_logo(LOGO_PATH)

    print("\nDetecting individual letters (connected white components)...")
    bboxes = find_letter_bboxes(img)

    if not bboxes:
        print("No letters (white components) found.")
        return

    for idx, (min_x, min_y, max_x, max_y) in enumerate(bboxes, start=1):
        width = max_x - min_x + 1
        height = max_y - min_y + 1
        print(
            f"Letter {idx}: "
            f"bbox=(min_x={min_x}, min_y={min_y}, max_x={max_x}, max_y={max_y}), "
            f"width={width}, height={height}"
        )

    # Build and save the icon composed of R,2,D,2
    letter_images = extract_letter_images(img, bboxes)
    if len(letter_images) < 5:
        print("Expected at least 5 connected components (R,2,-,D,2); icon not created.")
        return

    # x is the distance of R from the top border of logo.png
    x_margin = bboxes[0][1]

    icon_img = build_icon_from_letters(letter_images, x_margin)
    icon_img = make_square_icon(icon_img)
    icon_img = transform_icon_pairs(icon_img)

    # Save as PNG with .png extension and as SVG
    icon_img.save("assets/icon.png", format="PNG")
    save_svg_with_embedded_png(icon_img, "assets/icon.svg")
    print("\nSaved icon.logo (PNG) and icon.svg.")


if __name__ == "__main__":
    main()

