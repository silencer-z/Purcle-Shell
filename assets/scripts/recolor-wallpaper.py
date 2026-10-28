#!/usr/bin/env python3
"""按当前主题色盘重着色壁纸：保住明暗，有色彩的像素按色相靠到强调色。"""
from __future__ import annotations

import os
import subprocess
import sys
import tempfile

import numpy as np
from PIL import Image

CHROMA_NEUTRAL = 0.028
CHROMA_ACCENT = 0.055


def hex_to_rgb(h: str) -> tuple[int, int, int]:
    h = h.strip()
    if h.startswith("#"):
        h = h[1:]
    if len(h) == 8:
        h = h[2:] if h[:2].lower() == "ff" else h[:6]
    if len(h) != 6:
        raise ValueError(f"bad hex color: {h}")
    return int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)


def srgb_to_linear(c: np.ndarray) -> np.ndarray:
    c = np.clip(c, 0.0, 1.0)
    return np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)


def linear_to_srgb(c: np.ndarray) -> np.ndarray:
    c = np.maximum(c, 0.0)
    return np.where(c <= 0.0031308, 12.92 * c, 1.055 * np.power(c, 1.0 / 2.4) - 0.055)


def linear_to_oklab(rgb: np.ndarray) -> np.ndarray:
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
    m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
    s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b
    l_ = np.cbrt(np.maximum(l, 0.0))
    m_ = np.cbrt(np.maximum(m, 0.0))
    s_ = np.cbrt(np.maximum(s, 0.0))
    L = 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_
    a = 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_
    b = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_
    return np.stack([L, a, b], axis=-1)


def oklab_to_linear(lab: np.ndarray) -> np.ndarray:
    L, a, b = lab[..., 0], lab[..., 1], lab[..., 2]
    l_ = L + 0.3963377774 * a + 0.2158037573 * b
    m_ = L - 0.1055613458 * a - 0.0638541728 * b
    s_ = L - 0.0894841775 * a - 1.2914855480 * b
    l, m, s = l_ ** 3, m_ ** 3, s_ ** 3
    r = +4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
    g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
    b = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
    return np.stack([r, g, b], axis=-1)


def srgb_u8_to_oklab(img: np.ndarray) -> np.ndarray:
    return linear_to_oklab(srgb_to_linear(img.astype(np.float32) / 255.0))


def oklab_to_srgb_u8(lab: np.ndarray) -> np.ndarray:
    rgb = np.clip(linear_to_srgb(oklab_to_linear(lab)), 0.0, 1.0)
    return np.rint(rgb * 255.0).astype(np.uint8)


def unique_palette(hexes: list[str]) -> np.ndarray:
    seen: set[tuple[int, int, int]] = set()
    rows: list[tuple[int, int, int]] = []
    for h in hexes:
        try:
            rgb = hex_to_rgb(h)
        except ValueError:
            continue
        if rgb not in seen:
            seen.add(rgb)
            rows.append(rgb)
    if len(rows) < 2:
        raise SystemExit("recolor-wallpaper: need at least 2 palette colors")
    return np.array(rows, dtype=np.uint8)


def split_palette(pal: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    chroma = np.hypot(pal[:, 1], pal[:, 2])
    accents = pal[chroma >= CHROMA_ACCENT]
    neutrals = pal[chroma < CHROMA_ACCENT]
    if accents.size == 0:
        accents = pal
    if neutrals.size == 0:
        neutrals = pal
    return neutrals, accents


def nearest_by_l(src: np.ndarray, pal: np.ndarray) -> np.ndarray:
    dL = src[:, None, 0] - pal[None, :, 0]
    idx = (dL * dL).argmin(axis=1)
    return pal[idx]


def nearest_by_hue(src: np.ndarray, pal: np.ndarray) -> np.ndarray:
    src_ab = src[:, 1:3]
    pal_ab = pal[:, 1:3]
    src_n = src_ab / np.clip(np.linalg.norm(src_ab, axis=1, keepdims=True), 1e-6, None)
    pal_n = pal_ab / np.clip(np.linalg.norm(pal_ab, axis=1, keepdims=True), 1e-6, None)
    idx = (src_n @ pal_n.T).argmax(axis=1)
    return pal[idx]


def map_oklab(src: np.ndarray, pal: np.ndarray) -> np.ndarray:
    neutrals, accents = split_palette(pal)
    chroma = np.hypot(src[:, 1], src[:, 2])
    t = np.clip((chroma - CHROMA_NEUTRAL) / (CHROMA_ACCENT - CHROMA_NEUTRAL), 0.0, 1.0)
    t = t * t * (3.0 - 2.0 * t)
    neu = nearest_by_l(src, neutrals)
    acc = nearest_by_hue(src, accents)
    mapped = neu.copy()
    mapped[:, 1:3] = (1.0 - t)[:, None] * neu[:, 1:3] + t[:, None] * acc[:, 1:3]
    mapped[:, 0] = src[:, 0]
    return mapped


def load_rgb(path: str) -> np.ndarray:
    try:
        return np.asarray(Image.open(path).convert("RGB"))
    except Exception:
        with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as tmp:
            tmp_path = tmp.name
        try:
            subprocess.run(["magick", path, tmp_path], check=True)
            return np.asarray(Image.open(tmp_path).convert("RGB"))
        finally:
            try:
                os.remove(tmp_path)
            except OSError:
                pass


def main() -> None:
    if len(sys.argv) < 4:
        print("usage: recolor-wallpaper.py <input> <output> <#hex>...", file=sys.stderr)
        raise SystemExit(2)
    src_path, dst_path = sys.argv[1], sys.argv[2]
    hexes = sys.argv[3:]
    if not os.path.isfile(src_path):
        print(f"recolor-wallpaper: input not found: {src_path}", file=sys.stderr)
        raise SystemExit(1)

    palette = unique_palette(hexes)
    img = load_rgb(src_path)
    src = srgb_u8_to_oklab(img).reshape(-1, 3)
    pal = srgb_u8_to_oklab(palette.reshape(1, -1, 3)).reshape(-1, 3)
    mapped = map_oklab(src, pal).reshape(img.shape)
    os.makedirs(os.path.dirname(dst_path) or ".", exist_ok=True)
    Image.fromarray(oklab_to_srgb_u8(mapped), mode="RGB").save(dst_path)


if __name__ == "__main__":
    main()
