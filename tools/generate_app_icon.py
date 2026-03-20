from __future__ import annotations

from dataclasses import dataclass

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont


@dataclass(frozen=True)
class RGB:
    r: int
    g: int
    b: int

    def with_a(self, a: int) -> tuple[int, int, int, int]:
        return (self.r, self.g, self.b, a)


BG = RGB(0x0E, 0x10, 0x13)
OFFWHITE = RGB(0xF2, 0xF4, 0xF7)
POISON = RGB(0xB8, 0x5C, 0x5C)
POISON_DARK = RGB(0xA5, 0x52, 0x52)


def clamp(v: float, lo: float, hi: float) -> float:
    return max(lo, min(hi, v))


def lerp(a: int, b: int, t: float) -> int:
    t = clamp(t, 0.0, 1.0)
    return int(round(a + (b - a) * t))


def lerp_rgb(c1: RGB, c2: RGB, t: float) -> tuple[int, int, int, int]:
    return (
        lerp(c1.r, c2.r, t),
        lerp(c1.g, c2.g, t),
        lerp(c1.b, c2.b, t),
        255,
    )


def generate(size: int = 1024) -> Image.Image:
    img = Image.new("RGBA", (size, size), BG.with_a(255))
    cx, cy = size // 2, size // 2

    # Top glow (radial-like) — consistent with app pages.
    glow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    dg = ImageDraw.Draw(glow)
    gx, gy = cx, int(size * 0.16)
    gr = int(size * 0.52)
    dg.ellipse(
        (gx - gr, gy - gr, gx + gr, gy + gr),
        fill=POISON.with_a(92),
    )
    glow = glow.filter(ImageFilter.GaussianBlur(radius=int(size * 0.10)))
    img = Image.alpha_composite(img, glow)

    # Subtle bottom vignette to keep the canvas deep.
    vignette = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    dv = ImageDraw.Draw(vignette)
    dv.ellipse(
        (int(-size * 0.20), int(size * 0.30), int(size * 1.20), int(size * 1.40)),
        fill=(0, 0, 0, 150),
    )
    vignette = vignette.filter(ImageFilter.GaussianBlur(radius=int(size * 0.12)))
    img = Image.alpha_composite(img, vignette)

    # Bowl mask (filled).
    bowl_mask = Image.new("L", (size, size), 0)
    dm = ImageDraw.Draw(bowl_mask)

    bowl_box = (
        int(size * 0.28),
        int(size * 0.50),
        int(size * 0.72),
        int(size * 0.88),
    )
    dm.chord(bowl_box, start=180, end=360, fill=255)

    stand_w = int(size * 0.22)
    stand_h = int(size * 0.028)
    stand_box = (
        cx - stand_w // 2,
        int(size * 0.86),
        cx + stand_w // 2,
        int(size * 0.86) + stand_h,
    )
    dm.rounded_rectangle(stand_box, radius=stand_h // 2, fill=255)

    # Bowl fill gradient (subtle).
    bowl_fill = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    df = ImageDraw.Draw(bowl_fill)
    y0, y1 = bowl_box[1], bowl_box[3]
    for y in range(y0, y1 + 1):
        t = (y - y0) / max(1, (y1 - y0))
        df.line((0, y, size, y), fill=lerp_rgb(POISON, POISON_DARK, t))
    bowl_fill.putalpha(bowl_mask)

    # Bowl shadow.
    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    shadow.paste((0, 0, 0, 140), (0, 0), bowl_mask)
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=int(size * 0.012)))
    img = Image.alpha_composite(img, ImageChops.offset(shadow, 0, int(size * 0.012)))

    img = Image.alpha_composite(img, bowl_fill)

    # Bowl highlight.
    hi = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    dhi = ImageDraw.Draw(hi)
    dhi.ellipse(
        (
            int(size * 0.34),
            int(size * 0.56),
            int(size * 0.62),
            int(size * 0.80),
        ),
        fill=OFFWHITE.with_a(26),
    )
    hi = hi.filter(ImageFilter.GaussianBlur(radius=int(size * 0.02)))
    hi_alpha = hi.split()[3]
    hi.putalpha(ImageChops.multiply(hi_alpha, bowl_mask))
    img = Image.alpha_composite(img, hi)

    # Quote-steam (font glyph) — clean and consistent.
    steam = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ds = ImageDraw.Draw(steam)

    def load_font(px: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
        candidates = [
            r"C:\Windows\Fonts\segoeuib.ttf",
            r"C:\Windows\Fonts\segoeui.ttf",
            r"C:\Windows\Fonts\arialbd.ttf",
            r"C:\Windows\Fonts\arial.ttf",
        ]
        for p in candidates:
            try:
                return ImageFont.truetype(p, px)
            except OSError:
                continue
        return ImageFont.load_default()

    quote = "”"
    font = load_font(int(size * 0.34))
    left, top, right, bottom = ds.textbbox((0, 0), quote, font=font)
    tw, th = right - left, bottom - top
    tx, ty = cx - tw // 2, int(size * 0.14)

    # Shadow.
    shadow_q = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    dqs = ImageDraw.Draw(shadow_q)
    dqs.text((tx, ty + int(size * 0.014)), quote, font=font, fill=(0, 0, 0, 140))
    shadow_q = shadow_q.filter(ImageFilter.GaussianBlur(radius=int(size * 0.012)))
    img = Image.alpha_composite(img, shadow_q)

    ds.text((tx, ty), quote, font=font, fill=OFFWHITE.with_a(255))
    img = Image.alpha_composite(img, steam)

    # Poison droplet.
    drop = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    dd = ImageDraw.Draw(drop)
    dr = int(size * 0.018)
    dx, dy = int(size * 0.65), int(size * 0.30)
    dd.ellipse((dx - dr, dy - dr, dx + dr, dy + dr), fill=POISON.with_a(255))
    dd.polygon(
        [(dx - dr, dy + dr - 2), (dx + dr, dy + dr - 2), (dx, dy + dr + int(dr * 1.6))],
        fill=POISON.with_a(255),
    )
    drop = drop.filter(ImageFilter.GaussianBlur(radius=1))
    img = Image.alpha_composite(img, drop)

    return img


if __name__ == "__main__":
    import os

    out_path = os.path.join("assets", "app_icon_v3.png")
    icon = generate(1024)
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    icon.save(out_path, "PNG", optimize=True)
    print(f"wrote: {out_path}")

