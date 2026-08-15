#!/usr/bin/env python3
"""
Regenerates the SVG exports in this folder from the exact geometry and color
math used by the live SwiftUI rig, so these files can be kept in sync if the
app ever changes.

Source of truth (do not let this script drift from these files):
  Movo/Views/Character/CharacterShapeView.swift  (rig geometry, FaceView, GearSet)
  Movo/Models/Stage.swift                        (massScale, gear-unlock flags)
  Movo/Models/Mood.swift                         (mood list)
  Movo/Models/AppSettings.swift                  (AccentOption hex values)
  Movo/Models/CharacterProfile.swift             (lighter/darker/desaturated HSB math)
  Movo/Views/Shared/Components.swift             (EggShape, MovoEggMark, MovoWordmark)

This script only reads nothing from the app — the constants below are
transcribed by hand from those files. It does not modify app source and is
not part of the Xcode target.

Usage: python3 generate_svgs.py
"""
import colorsys
import math
import os

ROOT = os.path.dirname(os.path.abspath(__file__))

# ---------------------------------------------------------------------------
# Color math — mirrors the HSB (hue/saturation/brightness == HSV) derivation
# in Movo/Models/CharacterProfile.swift's Color.darker/.lighter/.desaturated.
# ---------------------------------------------------------------------------

def hex_to_rgb01(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4))


def rgb01_to_hex(rgb):
    return "#%02X%02X%02X" % tuple(min(255, max(0, round(c * 255))) for c in rgb)


def darker(hex_color, amount):
    r, g, b = hex_to_rgb01(hex_color)
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    s2 = min(1.0, s * 1.05)
    v2 = max(0.0, v * (1 - amount))
    return rgb01_to_hex(colorsys.hsv_to_rgb(h, s2, v2))


def lighter(hex_color, amount):
    r, g, b = hex_to_rgb01(hex_color)
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    s2 = max(0.0, s * 0.85)
    v2 = min(1.0, v + (1 - v) * amount)
    return rgb01_to_hex(colorsys.hsv_to_rgb(h, s2, v2))


def desaturated(hex_color):
    r, g, b = hex_to_rgb01(hex_color)
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    return rgb01_to_hex(colorsys.hsv_to_rgb(h, s * 0.28, v * 0.92))


# ---------------------------------------------------------------------------
# Palette — Movo/Models/AppSettings.swift AccentOption + fixed rig colors
# ---------------------------------------------------------------------------

ACCENTS = {
    "lime": "#C6F24E",
    "amber": "#FFB13D",
    "blue": "#57B4FF",
    "pink": "#FF7FC4",
    "cream": "#F3F4F0",
}

HEADBAND_COLOR = "#FFB13D"   # Color.movoAmber, fixed regardless of accent
GOLD_COLOR = "#E8B84B"       # gold band + crown
EYEBROW_COLOR = "#E2472B"
TEAR_COLOR = "#57B4FF"       # Color.movoBlue
SHOE_COLOR = "#F3F4F0"

# ---------------------------------------------------------------------------
# EggShape — Movo/Views/Shared/Components.swift
# Parametric squeeze curve sampled at 120 segments, straight-line polygon
# (matches `path.addLines(points)` — not a smooth bezier in the source).
# ---------------------------------------------------------------------------

def egg_points(cx, cy, rx, ry, n=120):
    pts = []
    for i in range(n + 1):
        t = i / n
        theta = t * 2 * math.pi
        sy = math.sin(theta)
        sx = math.cos(theta)
        squeeze = (1.0 - 0.22 * (-sy)) if sy < 0 else (1.0 + 0.06 * sy)
        x = cx + rx * sx * squeeze
        y = cy + ry * sy
        pts.append((x, y))
    return pts


def points_to_path(pts, close=True):
    d = f"M {pts[0][0]:.2f},{pts[0][1]:.2f} "
    d += " ".join(f"L {x:.2f},{y:.2f}" for x, y in pts[1:])
    if close:
        d += " Z"
    return d


# ---------------------------------------------------------------------------
# Rig geometry — Movo/Views/Character/CharacterShapeView.swift
# Base canvas is 200x232pt, ZStack default-centered; all offsets below are
# transcribed directly from the SwiftUI `.offset(x:,y:)` calls.
# ---------------------------------------------------------------------------

CANVAS_W, CANVAS_H = 200, 232
CENTER = (CANVAS_W / 2, CANVAS_H / 2)  # (100, 116)


def svg_header(width, height, title):
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width:.0f}" height="{height:.0f}" '
        f'viewBox="0 0 {width:.0f} {height:.0f}">\n'
        f"  <title>{title}</title>\n"
    )


def rect_gradient_def(gid, top_hex, bottom_hex):
    return (
        f'  <linearGradient id="{gid}" x1="0" y1="0" x2="0" y2="1">\n'
        f'    <stop offset="0" stop-color="{top_hex}"/>\n'
        f'    <stop offset="1" stop-color="{bottom_hex}"/>\n'
        f"  </linearGradient>\n"
    )


def rounded_rect(x, y, w, h, r, fill):
    return f'  <rect x="{x:.2f}" y="{y:.2f}" width="{w:.2f}" height="{h:.2f}" rx="{r:.2f}" fill="{fill}"/>\n'


def capsule(x, y, w, h, fill, opacity=None, rotate=None, pivot=None, stroke=None, stroke_width=0, stroke_opacity=1):
    r = min(w, h) / 2
    op = f' fill-opacity="{opacity}"' if opacity is not None else ""
    transform = ""
    if rotate is not None:
        px, py = pivot
        transform = f' transform="rotate({rotate:.2f} {px:.2f} {py:.2f})"'
    stroke_attr = f' stroke="{stroke}" stroke-width="{stroke_width}" stroke-opacity="{stroke_opacity}"' if stroke else ""
    return (
        f'  <rect x="{x:.2f}" y="{y:.2f}" width="{w:.2f}" height="{h:.2f}" rx="{r:.2f}" '
        f'fill="{fill}"{op}{stroke_attr}{transform}/>\n'
    )


def circle(cx, cy, r, fill, opacity=None):
    op = f' fill-opacity="{opacity}"' if opacity is not None else ""
    return f'  <circle cx="{cx:.2f}" cy="{cy:.2f}" r="{r:.2f}" fill="{fill}"{op}/>\n'


def ellipse(cx, cy, rx, ry, fill, opacity=None):
    op = f' fill-opacity="{opacity}"' if opacity is not None else ""
    return f'  <ellipse cx="{cx:.2f}" cy="{cy:.2f}" rx="{rx:.2f}" ry="{ry:.2f}" fill="{fill}"{op}/>\n'


def stroke_path(d, color, width, opacity=1, linecap="round"):
    return (
        f'  <path d="{d}" fill="none" stroke="{color}" stroke-width="{width:.2f}" '
        f'stroke-opacity="{opacity}" stroke-linecap="{linecap}"/>\n'
    )


def fill_polygon(pts, fill, opacity=1):
    d = points_to_path(pts)
    return f'  <path d="{d}" fill="{fill}" fill-opacity="{opacity}"/>\n'


def group(gid, content):
    return f'  <g id="{gid}">\n{content}  </g>\n'


# --- shape helpers local to a given anchor point -----------------------

def cape_points(top_left, w=96, h=120):
    ox, oy = top_left
    fr = [(0.5, 0), (0.1, 0.15), (0, 1.0), (0.5, 0.82), (1.0, 1.0), (0.9, 0.15)]
    return [(ox + fx * w, oy + fy * h) for fx, fy in fr]


def crown_points(top_left, w=60, h=34):
    ox, oy = top_left
    fr = [(0, 1.0), (0, 0.45), (0.2, 0.7), (0.35, 0.15), (0.5, 0.55),
          (0.65, 0.15), (0.8, 0.7), (1.0, 0.45), (1.0, 1.0)]
    return [(ox + fx * w, oy + fy * h) for fx, fy in fr]


def teardrop_path(cx_top, y_top, w, h):
    """Approximates Components.swift's TearDrop shape: pointed top, round bottom."""
    mx = cx_top
    minx, maxx = mx - w / 2, mx + w / 2
    midy = y_top + h * 0.6
    r = w / 2
    d = (
        f"M {mx:.2f},{y_top:.2f} "
        f"Q {maxx:.2f},{y_top + h * 0.15:.2f} {maxx:.2f},{midy:.2f} "
        f"A {r:.2f},{r:.2f} 0 0 1 {minx:.2f},{midy:.2f} "
        f"Q {minx:.2f},{y_top + h * 0.15:.2f} {mx:.2f},{y_top:.2f} Z"
    )
    return d


def smile_path(cx, y_top, w, h, curve_up):
    x0, x1 = cx - w / 2, cx + w / 2
    y0 = y_top if curve_up else y_top + h
    cy = y_top + h if curve_up else y_top
    return f"M {x0:.2f},{y0:.2f} Q {cx:.2f},{cy:.2f} {x1:.2f},{y0:.2f}"


# ---------------------------------------------------------------------------
# Face — mirrors FaceView in CharacterShapeView.swift, positioned relative to
# the head circle's own center (head_cx, head_cy).
# ---------------------------------------------------------------------------

def render_face(mood, head_cx, head_cy):
    out = ""
    eyes_dy = -2 if mood == "sulking" else -4

    if mood in ("happy", "firedUp", "annoyed"):
        for dx in (-16.5, 16.5):
            out += circle(head_cx + dx, head_cy + eyes_dy, 5.5, "#000000", 0.85)
    elif mood == "wrecked":
        for dx in (-17.5, 17.5):
            out += capsule(head_cx + dx - 6.5, head_cy + eyes_dy - 2, 13, 4, "#000000", 0.85)
    elif mood == "sulking":
        for dx in (-15, 15):
            out += circle(head_cx + dx, head_cy + eyes_dy, 4, "#000000", 0.7)

    if mood == "happy":
        d = smile_path(head_cx, head_cy + 16, 26, 12, curve_up=True)
        out += stroke_path(d, "#000000", 4, 0.85)
    elif mood == "firedUp":
        out += ellipse(head_cx, head_cy + 16, 8, 6, "#000000", 0.85)
    elif mood == "wrecked":
        out += ellipse(head_cx, head_cy + 18, 10, 7, "#000000", 0.8)
    elif mood == "annoyed":
        out += capsule(head_cx - 11, head_cy + 14, 22, 4, "#000000", 0.85)
    elif mood == "sulking":
        d = smile_path(head_cx, head_cy + 18, 22, 10, curve_up=False)
        out += stroke_path(d, "#000000", 3.5, 0.7)

    if mood == "firedUp":
        out += f'  <path d="{teardrop_path(head_cx + 40, head_cy - 20, 8, 12)}" fill="{TEAR_COLOR}"/>\n'
        for rot in (-14, 14):
            dx = -15 if rot < 0 else 15
            out += capsule(head_cx + dx - 8, head_cy - 20, 16, 4, EYEBROW_COLOR,
                            rotate=rot, pivot=(head_cx + dx, head_cy - 18))
    elif mood == "wrecked":
        out += f'  <path d="{teardrop_path(head_cx - 38, head_cy - 17, 7, 10)}" fill="{TEAR_COLOR}"/>\n'
        out += f'  <path d="{teardrop_path(head_cx + 38, head_cy - 17, 7, 10)}" fill="{TEAR_COLOR}"/>\n'
    elif mood == "annoyed":
        for rot in (-14, 14):
            dx = -15 if rot < 0 else 15
            out += capsule(head_cx + dx - 8, head_cy - 18, 16, 4, EYEBROW_COLOR,
                            rotate=rot, pivot=(head_cx + dx, head_cy - 16))
    elif mood == "sulking":
        out += f'  <path d="{teardrop_path(head_cx - 20, head_cy + 0.5, 7, 11)}" fill="{TEAR_COLOR}"/>\n'

    return out


# ---------------------------------------------------------------------------
# Full rig renderer
# ---------------------------------------------------------------------------

def render_rig(accent_hex, mood, gear, sulking_desaturate=True):
    """Returns SVG body content (no <svg> wrapper) for the 200x232 rig."""
    body_hex = desaturated(accent_hex) if (sulking_desaturate and mood == "sulking") else accent_hex
    cx, cy = CENTER
    out = ""
    defs = ""

    # gradients
    defs += rect_gradient_def("gradHead", lighter(body_hex, 0.18), darker(body_hex, 0.04))
    defs += rect_gradient_def("gradTorso", lighter(body_hex, 0.12), darker(body_hex, 0.05))

    layers = ""

    if gear.get("cape"):
        pts = cape_points((cx - 48, cy + 26 - 60))
        layers += group("cape", fill_polygon(pts, darker(body_hex, 0.15)))

    # legs / shoes
    shoe_w, shoe_h, shoe_gap = 34, 20, 14
    hstack_w = shoe_w * 2 + shoe_gap
    left_x = cx - hstack_w / 2
    right_x = left_x + shoe_w + shoe_gap
    shoe_y = cy + 84 - shoe_h / 2
    shoes = ""
    for x in (left_x, right_x):
        shoes += capsule(x, shoe_y, shoe_w, shoe_h, SHOE_COLOR, stroke="#000000", stroke_width=1, stroke_opacity=0.08)
        if gear.get("runners"):
            stripe_w, stripe_h = 20, 5
            shoes += capsule(x + (shoe_w - stripe_w) / 2, shoe_y + (shoe_h - stripe_h) / 2, stripe_w, stripe_h, body_hex)
    layers += group("legs", shoes)

    # arms
    arm_w, arm_h, hstack2_w = 30, 64, 168
    arms_y = cy + 8 - arm_h / 2
    left_ax = cx - hstack2_w / 2
    right_ax = cx + hstack2_w / 2 - arm_w
    arms = ""
    arms += capsule(left_ax, arms_y, arm_w, arm_h, body_hex, rotate=-14, pivot=(left_ax + arm_w / 2, arms_y))
    arms += capsule(right_ax, arms_y, arm_w, arm_h, body_hex, rotate=14, pivot=(right_ax + arm_w / 2, arms_y))
    layers += group("arms", arms)

    # torso
    torso_w, torso_h = 108, 96
    layers += group("torso", rounded_rect(cx - torso_w / 2, cy + 24 - torso_h / 2, torso_w, torso_h, 34, "url(#gradTorso)"))

    if gear.get("tankTop"):
        tt_w, tt_h = 44, 66
        layers += group("tank_top", rounded_rect(cx - tt_w / 2, cy + 20 - tt_h / 2, tt_w, tt_h, 14, darker(body_hex, 0.32)))

    if gear.get("goldBand"):
        gb_w, gb_h = 100, 12
        layers += group("gold_band", capsule(cx - gb_w / 2, cy + 56 - gb_h / 2, gb_w, gb_h, GOLD_COLOR))

    # head
    head_r = 59
    head_cx, head_cy = cx, cy - 58
    layers += group("head", circle(head_cx, head_cy, head_r, "url(#gradHead)"))
    layers += group("face", render_face(mood, head_cx, head_cy))

    if gear.get("headband"):
        hb_w, hb_h = 108, 16
        layers += group("headband", capsule(cx - hb_w / 2, cy - 104 - hb_h / 2, hb_w, hb_h, HEADBAND_COLOR))

    if gear.get("crown"):
        pts = crown_points((cx - 30, cy - 132 - 17))
        layers += group("crown", fill_polygon(pts, GOLD_COLOR))

    out = f"  <defs>\n{defs}  </defs>\n" + layers
    return out


def render_egg(accent_hex):
    cx, cy = CENTER
    body_hex = accent_hex
    defs = rect_gradient_def("gradEgg", lighter(body_hex, 0.2), darker(body_hex, 0.08))
    pts = egg_points(cx, cy, 64, 80)
    egg = fill_polygon(pts, "url(#gradEgg)")

    crack_color = lighter(body_hex, 0.35)
    # crackMarks VStack (~40 wide, ~30 tall: 12 + 10 spacing + 8), centered at (cx, cy)
    top = cy - 15
    d1 = f"M {cx - 20:.2f},{top + 6:.2f} L {cx:.2f},{top:.2f} L {cx + 20:.2f},{top + 8:.2f}"
    d2_x0 = cx - 6  # second path is 28 wide, offset x:+14 from the (40-wide, centered) VStack column
    d2_y = top + 22
    d2 = f"M {d2_x0:.2f},{d2_y:.2f} L {d2_x0 + 28:.2f},{d2_y + 4:.2f}"
    cracks = stroke_path(d1, crack_color, 5, linecap="round") + stroke_path(d2, crack_color, 5, linecap="round")

    return f"  <defs>\n{defs}  </defs>\n" + group("egg", egg) + group("cracks", cracks)


# ---------------------------------------------------------------------------
# Stage gear presets — GearSet.forStage(_:) in CharacterShapeView.swift,
# driven by the boolean flags on Stage in Stage.swift. This is the
# "showcase everything unlocked at once" mode used for stage-card style
# art (matches the design PDF's 5-stage reference card), not the
# single-item-per-slot rendering used live in the wardrobe/equipped state.
# ---------------------------------------------------------------------------

STAGE_GEAR = {
    "egg": {},
    "hatchling": {"headband": False, "tankTop": False, "goldBand": False, "crown": False, "cape": False, "runners": False},
    "rookie": {"headband": True, "tankTop": True, "goldBand": False, "crown": False, "cape": False, "runners": False},
    "athlete": {"headband": True, "tankTop": True, "goldBand": False, "crown": False, "cape": False, "runners": True},
    "champion": {"headband": True, "tankTop": True, "goldBand": True, "crown": True, "cape": True, "runners": True},
}

STAGE_MASS_SCALE = {
    "egg": 1.0,
    "hatchling": 1.08,
    "rookie": 1.18,
    "athlete": 1.3,
    "champion": 1.45,
}

STAGE_ORDER = ["egg", "hatchling", "rookie", "athlete", "champion"]
MOOD_ORDER = ["happy", "firedUp", "wrecked", "annoyed", "sulking"]

PAD = 24  # side/bottom margin around the rig bbox in every exported file

# The crown (CrownShape, champion gear) is the one element that extends above
# the nominal 200x232 rig frame: in local rig coordinates its top edge sits at
# y = -33 (cy - 132 - 17, see render_rig), vs. the frame's own top at y = 0.
# At the champion stage's 1.45x massScale that's ~48pt of overflow above the
# "top" of the box, which a flat 24pt pad does not cover — so any stage/mood/
# color export that can render a crown needs extra headroom specifically on
# the top edge, not just a bigger uniform pad.
CROWN_TOP_OVERFLOW_LOCAL = 33
PAD_TOP_WITH_CROWN = PAD + int(CROWN_TOP_OVERFLOW_LOCAL * STAGE_MASS_SCALE["champion"]) + 5  # 24 + 47 + 5 = 76


def write_svg(path, width, height, body, title):
    svg = svg_header(width, height, title) + body + "</svg>\n"
    with open(path, "w") as f:
        f.write(svg)
    print("wrote", os.path.relpath(path, ROOT))


def scaled_canvas(scale, pad_top=PAD):
    return CANVAS_W * scale + PAD * 2, CANVAS_H * scale + pad_top + PAD


def wrap_scaled(body_content, scale, pad_top=PAD):
    """Scales+translates the 200x232 rig content to sit centered with PAD margin
    on the sides/bottom and `pad_top` above (larger when a crown can appear)."""
    w, h = scaled_canvas(scale, pad_top)
    tx = (w - CANVAS_W * scale) / 2
    ty = pad_top
    return f'  <g transform="translate({tx:.2f} {ty:.2f}) scale({scale:.4f})">\n{body_content}  </g>\n'


# ---------------------------------------------------------------------------
# 1) Stages
# ---------------------------------------------------------------------------

def build_stages():
    # Uniform top padding across the whole folder (sized for champion's crown)
    # so the 5 files form a consistent filmstrip rather than each being
    # cropped tightest-possible to its own content.
    pad_top = PAD_TOP_WITH_CROWN
    for i, stage in enumerate(STAGE_ORDER, start=1):
        scale = STAGE_MASS_SCALE[stage]
        if stage == "egg":
            content = render_egg(ACCENTS["lime"])
        else:
            content = render_rig(ACCENTS["lime"], "happy", STAGE_GEAR[stage])
        w, h = scaled_canvas(scale, pad_top)
        body = wrap_scaled(content, scale, pad_top)
        write_svg(
            os.path.join(ROOT, "stages", f"{i:02d}-{stage}.svg"),
            w, h, body, f"Movo — {stage.capitalize()} stage"
        )


# ---------------------------------------------------------------------------
# 2) Moods — rendered on the Rookie rig (has a face + base gear), lime accent
# ---------------------------------------------------------------------------

def build_moods():
    scale = STAGE_MASS_SCALE["rookie"]
    w, h = scaled_canvas(scale)
    for i, mood in enumerate(MOOD_ORDER, start=1):
        content = render_rig(ACCENTS["lime"], mood, STAGE_GEAR["rookie"])
        body = wrap_scaled(content, scale)
        slug = "fired-up" if mood == "firedUp" else mood
        write_svg(
            os.path.join(ROOT, "moods", f"{i:02d}-{slug}.svg"),
            w, h, body, f"Movo — {mood} mood"
        )


# ---------------------------------------------------------------------------
# 3) Colors — Rookie rig, happy mood, one file per accent
# ---------------------------------------------------------------------------

def build_colors():
    scale = STAGE_MASS_SCALE["rookie"]
    w, h = scaled_canvas(scale)
    for i, (name, hexval) in enumerate(ACCENTS.items(), start=1):
        content = render_rig(hexval, "happy", STAGE_GEAR["rookie"])
        body = wrap_scaled(content, scale)
        write_svg(
            os.path.join(ROOT, "colors", f"{i:02d}-{name}.svg"),
            w, h, body, f"Movo — {name} accent ({hexval})"
        )


# ---------------------------------------------------------------------------
# 4) Logo
#    - movo-icon.svg: in-app MovoEggMark geometry (Components.swift)
#    - app-icon-1024.svg: matches the shipped AppIcon-1024.png generation
#      (rounded-square gradient bg, black egg, crack marks) at full size
#    - movo-wordmark.svg: icon + "movo" text lockup (MovoWordmark)
# ---------------------------------------------------------------------------

def build_movo_icon_mark(size, accent_hex):
    """Mirrors MovoEggMark in Components.swift exactly (size-parameterized)."""
    r = size * 0.28
    grad_id = "gradIcon"
    defs = rect_gradient_def(grad_id, lighter(accent_hex, 0.25), darker(accent_hex, 0.12))
    # SwiftUI LinearGradient topLeading->bottomTrailing; approximate as a diagonal gradient.
    defs = (
        f'  <linearGradient id="{grad_id}" x1="0" y1="0" x2="1" y2="1">\n'
        f'    <stop offset="0" stop-color="{lighter(accent_hex, 0.25)}"/>\n'
        f'    <stop offset="1" stop-color="{darker(accent_hex, 0.12)}"/>\n'
        f"  </linearGradient>\n"
    )
    bg = rounded_rect(0, 0, size, size, r, f"url(#{grad_id})")

    egg_w, egg_h = size * 0.46, size * 0.58
    pts = egg_points(size / 2, size / 2, egg_w / 2, egg_h / 2)
    egg = fill_polygon(pts, "#000000")

    # two crack strokes, VStack spacing size*0.05, roughly centered
    cy0 = size / 2 - size * 0.02
    d1 = (f"M {size/2 - size*0.08:.2f},{cy0:.2f} "
          f"L {size/2 + size*0.02:.2f},{cy0 - size*0.015:.2f} "
          f"L {size/2 + size*0.08:.2f},{cy0 + 0.01:.2f}")
    cy1 = cy0 + size * 0.07
    d2 = (f"M {size/2 - size*0.03:.2f},{cy1:.2f} "
          f"L {size/2 + size*0.09:.2f},{cy1:.2f}")
    cracks = stroke_path(d1, accent_hex, size * 0.03) + stroke_path(d2, accent_hex, size * 0.03)

    return f"  <defs>\n{defs}  </defs>\n" + group("bg", bg) + group("egg", egg) + group("cracks", cracks)


def build_app_icon_1024(size=1024):
    """Mirrors the shipped AppIcon-1024.png generation (rounded square,
    diagonal gradient, black egg silhouette, two crack strokes)."""
    top_color, bottom_color = "#A7E669", "#56A84A"
    corner = size * 0.225
    defs = (
        f'  <linearGradient id="gradAppIcon" x1="0" y1="0" x2="1" y2="1">\n'
        f'    <stop offset="0" stop-color="{top_color}"/>\n'
        f'    <stop offset="1" stop-color="{bottom_color}"/>\n'
        f"  </linearGradient>\n"
    )
    bg = rounded_rect(0, 0, size, size, corner, "url(#gradAppIcon)")

    cx, cy = size / 2, size / 2 + size * 0.02
    egg_w, egg_h = size * 0.46, size * 0.58
    pts = egg_points(cx, cy, egg_w / 2, egg_h / 2)
    egg = fill_polygon(pts, "#0A0A0A")

    lw = size * 0.02
    y1 = cy - size * 0.02
    x_start = cx - egg_w * 0.30
    d1 = (f"M {x_start:.2f},{y1:.2f} "
          f"L {x_start + egg_w*0.16:.2f},{y1 - size*0.012:.2f} "
          f"L {cx + egg_w*0.10:.2f},{y1 + size*0.008:.2f}")
    y2 = cy + size * 0.045
    x2_start = cx - egg_w * 0.02
    d2 = f"M {x2_start:.2f},{y2:.2f} L {cx + egg_w*0.24:.2f},{y2 - size*0.006:.2f}"
    cracks = stroke_path(d1, top_color, lw) + stroke_path(d2, top_color, lw)

    return f"  <defs>\n{defs}  </defs>\n" + group("bg", bg) + group("egg", egg) + group("cracks", cracks)


def build_wordmark(accent_hex="#C6F24E"):
    icon_size = 64
    gap = 18
    text_size = 44
    text_w_estimate = 128  # approx width of "movo" at this size/weight
    width = icon_size + gap + text_w_estimate
    height = icon_size

    icon_body = build_movo_icon_mark(icon_size, accent_hex)
    icon_group = f'  <g transform="translate(0 0)">\n{icon_body}  </g>\n'

    text = (
        f'  <text x="{icon_size + gap:.0f}" y="{height * 0.72:.0f}" '
        f'font-family="\'Space Grotesk\', \'Helvetica Neue\', Arial, sans-serif" '
        f'font-weight="700" font-size="{text_size}" fill="#FFFFFF">movo</text>\n'
    )
    body = icon_group + text
    return width, height, body


def build_logo_files():
    icon_body = build_movo_icon_mark(512, ACCENTS["lime"])
    write_svg(os.path.join(ROOT, "logo", "movo-icon.svg"), 512, 512, icon_body,
              "Movo — in-app icon mark (MovoEggMark)")

    app_icon_body = build_app_icon_1024()
    write_svg(os.path.join(ROOT, "logo", "app-icon-1024.svg"), 1024, 1024, app_icon_body,
              "Movo — shipped app icon (matches AppIcon-1024.png)")

    w, h, body = build_wordmark()
    write_svg(os.path.join(ROOT, "logo", "movo-wordmark.svg"), w, h, body,
              "Movo — wordmark lockup (icon + \"movo\" text)")

    # Bonus: amber variant of the in-app icon mark, per the brand page's note
    # about a dark/amber variant for seasonal / streak-broken states.
    amber_body = build_movo_icon_mark(512, ACCENTS["amber"])
    write_svg(os.path.join(ROOT, "logo", "movo-icon-amber.svg"), 512, 512, amber_body,
              "Movo — in-app icon mark, amber variant (streak-broken state)")


if __name__ == "__main__":
    build_stages()
    build_moods()
    build_colors()
    build_logo_files()
    print("\nDone.")
