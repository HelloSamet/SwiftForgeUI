"""Color math mirroring SwiftForgeUI's ColorMath.swift (WCAG 2.x, gamma-encoded sRGB compositing)."""
import math

def hx(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))

def tohex(rgb):
    return '%02X%02X%02X' % tuple(max(0, min(255, round(c * 255))) for c in rgb)

def _lin(c):
    c = min(max(c, 0), 1)
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

def _gam(c):
    c = min(max(c, 0), 1)
    return c * 12.92 if c <= 0.0031308 else 1.055 * c ** (1 / 2.4) - 0.055

def lum(rgb):
    r, g, b = (_lin(c) for c in rgb)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b

def composite(top, alpha, bottom):
    return tuple(t * alpha + b * (1 - alpha) for t, b in zip(top, bottom))

def contrast(fg, bg, fg_alpha=1.0):
    fgc = composite(fg, fg_alpha, bg)
    a, b = lum(fgc), lum(bg)
    return (max(a, b) + 0.05) / (min(a, b) + 0.05)

def mix(a, b, t):  # sRGB lerp, like WCAG.mix
    return tuple(x + (y - x) * t for x, y in zip(a, b))

# OKLab
def to_oklab(rgb):
    r, g, b = (_lin(c) for c in rgb)
    l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
    m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
    s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b
    l, m, s = (math.copysign(abs(v) ** (1 / 3), v) for v in (l, m, s))
    return (0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
            1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
            0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s)

def from_oklab(lab):
    L, a, b = lab
    l = (L + 0.3963377774 * a + 0.2158037573 * b) ** 3
    m = (L - 0.1055613458 * a - 0.0638541728 * b) ** 3
    s = (L - 0.0894841775 * a - 1.2914855480 * b) ** 3
    r = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
    g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
    bb = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
    return tuple(_gam(c) for c in (r, g, bb))

STEPS = {50: 0.975, 100: 0.945, 200: 0.89, 300: 0.81, 400: 0.72, 500: 0.63,
         600: 0.54, 700: 0.45, 800: 0.36, 900: 0.27, 950: 0.20}

def _in_gamut(lab):
    L, a, b = lab
    l = (L + 0.3963377774 * a + 0.2158037573 * b) ** 3
    m = (L - 0.1055613458 * a - 0.0638541728 * b) ** 3
    s = (L - 0.0894841775 * a - 1.2914855480 * b) ** 3
    r = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
    g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
    bb = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
    return all(-1e-4 <= c <= 1 + 1e-4 for c in (r, g, bb))

def ramp(anchor, end_chroma=0.3):
    """Steps 50..950 at fixed OKLab lightness, with the anchor's hue and chroma, tapered toward the ends
    and reduced until in the sRGB gamut. Same step = same perceived lightness across hues."""
    L0, a0, b0 = to_oklab(hx(anchor))
    out = {}
    for step, L in STEPS.items():
        dist = abs(L - L0) / max(L0 if L < L0 else 1 - L0, 1e-6)
        k = 1 - min(1, dist) * (1 - end_chroma) * 0.6
        while k > 0 and not _in_gamut((L, a0 * k, b0 * k)):
            k -= 0.01
        out[step] = tohex(from_oklab((L, a0 * max(k, 0), b0 * max(k, 0))))
    return out
