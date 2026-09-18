#!/usr/bin/env python3
"""Render Amber Protocol's app icon: a slate panel carrying the console's
amber clock ring. Pure stdlib -- signed distance fields into hand-written
PNGs, then `iconutil` assembles the .icns.

    python3 tools/make-icon.py out/icon.icns
"""
import math, os, struct, subprocess, sys, tempfile, zlib

# --- identity, lifted straight from the page's tokens -----------------
PANEL_TOP    = (0x1B, 0x20, 0x29)   # lit from above
PANEL_BOTTOM = (0x0D, 0x10, 0x15)
AMBER        = (0xF0, 0xA9, 0x3B)
HIGHLIGHT    = (0xFF, 0xFF, 0xFF)

CORNER   = 0.2237   # Apple's continuous corner radius, as a fraction of the square
INSET    = 0.085    # breathing room inside the canvas
RING_R   = 0.300    # ring radius, fraction of icon size
RING_W   = 0.072    # ring stroke width
GAP_DEG  = 62.0     # opening at twelve o'clock


def rounded_rect_sdf(x, y, half, radius):
    qx, qy = abs(x) - (half - radius), abs(y) - (half - radius)
    return math.hypot(max(qx, 0.0), max(qy, 0.0)) + min(max(qx, qy), 0.0) - radius


def arc_sdf(x, y, radius, half_w, gap_deg):
    """Round-capped arc centred on the origin, opening at twelve o'clock."""
    gap_half = math.radians(gap_deg / 2.0)
    ang = math.atan2(y, x)                      # maths orientation, y up
    delta = abs(((ang - math.pi / 2) + math.pi) % (2 * math.pi) - math.pi)
    if delta >= gap_half:                       # on the drawn sweep
        return abs(math.hypot(x, y) - radius) - half_w
    cap = math.pi / 2 + gap_half                # the two round caps, mirrored
    cx, cy = radius * math.cos(cap), radius * math.sin(cap)
    return min(math.hypot(x - cx, y - cy), math.hypot(x + cx, y - cy)) - half_w


def coverage(sdf, aa):
    """Signed distance -> alpha, with a one-pixel smooth edge."""
    return max(0.0, min(1.0, 0.5 - sdf / aa))


def over(dst, src, alpha):
    return tuple(round(s * alpha + d * (1 - alpha)) for d, s in zip(dst, src))


def render(size):
    px = bytearray(size * size * 4)
    aa = 1.0 / size                      # one pixel, in normalised units
    half = 0.5 - INSET
    radius = CORNER * (half * 2)
    ring_hw = RING_W / 2
    for row in range(size):
        # sample pixel centres; flip y so maths orientation is upright
        ny = -((row + 0.5) / size - 0.5)
        for col in range(size):
            nx = (col + 0.5) / size - 0.5
            panel = coverage(rounded_rect_sdf(nx, ny, half, radius), aa)
            if panel <= 0.0:
                continue
            # vertical gradient across the panel face
            t = min(1.0, max(0.0, (0.5 - ny) / (half * 2)))
            base = tuple(round(a + (b - a) * t) for a, b in zip(PANEL_TOP, PANEL_BOTTOM))
            # a hairline of light along the top edge, as on the console itself
            edge = coverage(abs(rounded_rect_sdf(nx, ny, half, radius)) - aa * 0.6, aa)
            if edge > 0 and ny > 0:
                base = over(base, HIGHLIGHT, edge * 0.05 * min(1.0, ny / half))
            ring = coverage(arc_sdf(nx, ny, RING_R, ring_hw, GAP_DEG), aa)
            rgb = over(base, AMBER, ring) if ring > 0 else base
            i = (row * size + col) * 4
            px[i:i + 4] = bytes((*rgb, round(panel * 255)))
    return px


def write_png(path, size, px):
    raw = b"".join(b"\x00" + bytes(px[r * size * 4:(r + 1) * size * 4]) for r in range(size))
    def chunk(tag, data):
        return (struct.pack(">I", len(data)) + tag + data
                + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF))
    with open(path, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n")
        f.write(chunk(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0)))
        f.write(chunk(b"IDAT", zlib.compress(raw, 9)))
        f.write(chunk(b"IEND", b""))


# iconset slot -> pixel size
SLOTS = [("icon_16x16.png", 16), ("icon_16x16@2x.png", 32),
         ("icon_32x32.png", 32), ("icon_32x32@2x.png", 64),
         ("icon_128x128.png", 128), ("icon_128x128@2x.png", 256),
         ("icon_256x256.png", 256), ("icon_256x256@2x.png", 512),
         ("icon_512x512.png", 512), ("icon_512x512@2x.png", 1024)]


def main():
    out = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else "icon.icns")
    os.makedirs(os.path.dirname(out) or ".", exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        iconset = os.path.join(tmp, "icon.iconset")
        os.makedirs(iconset)
        cache = {}
        for name, size in SLOTS:
            if size not in cache:
                cache[size] = render(size)
                print("  rendered %4dpx" % size, flush=True)
            write_png(os.path.join(iconset, name), size, cache[size])
        subprocess.run(["iconutil", "-c", "icns", iconset, "-o", out], check=True)
    print("icon ->", out)


if __name__ == "__main__":
    main()
