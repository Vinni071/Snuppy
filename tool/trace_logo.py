"""Retrace assets/branding/logo_dark.png into smooth SVG logo/wordmark files.

Requires: pip install potracer numpy pillow
Usage: python3 tool/trace_logo.py assets/branding/logo_dark.png assets/branding/
"""
import sys, numpy as np, potrace
from PIL import Image, ImageFilter
src, out_prefix = sys.argv[1], sys.argv[2]
UP = 6
g = Image.open(src).convert('L')
a = np.array(g)
mask = a > 128
ys, xs = np.nonzero(mask)
# split icon / wordmark by the empty row band between them
rows = mask.any(axis=1)
r = np.nonzero(rows)[0]
gaps = np.nonzero(np.diff(r) > 5)[0]
split = (r[gaps[0]] + r[gaps[0]+1]) // 2
parts = {'logo': (r[0], split), 'nome': (split, r[-1]+1)}
for name, (y0, y1) in parts.items():
    sub = mask[y0:y1]
    cols = np.nonzero(sub.any(axis=0))[0]
    x0, x1 = cols[0], cols[-1]+1
    yy = np.nonzero(sub.any(axis=1))[0]
    y0b, y1b = y0+yy[0], y0+yy[-1]+1
    pad = 4
    crop = g.crop((x0-pad, y0b-pad, x1+pad, y1b+pad))
    big = crop.resize((crop.width*UP, crop.height*UP), Image.LANCZOS)
    big = big.filter(ImageFilter.GaussianBlur(UP*0.6))
    bm = potrace.Bitmap(np.array(big) <= 128)
    plist = bm.trace(turdsize=UP*UP*4, alphamax=1.0, opticurve=True, opttolerance=0.4)
    s = 1/UP
    f = lambda p: f"{p.x*s - pad + 1:.2f} {p.y*s - pad + 1:.2f}"
    d = []
    for c in plist:
        d.append("M" + f(c.start_point))
        for seg in c.segments:
            if seg.is_corner:
                d.append("L" + f(seg.c) + "L" + f(seg.end_point))
            else:
                d.append("C" + f(seg.c1) + " " + f(seg.c2) + " " + f(seg.end_point))
        d.append("Z")
    w, h = x1-x0+2, y1b-y0b+2
    path = "".join(d)
    for theme, fill, label in [('escuro', '#FFFFFF', 'fundo escuro'), ('claro', '#000000', 'fundo claro')]:
        kind = 'logo' if name == 'logo' else 'nome'
        svg = (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}" role="img" aria-labelledby="title">'
               f'<title id="title">Luminthor — {kind} para {label}</title>'
               f'<path fill="{fill}" fill-rule="evenodd" d="{path}"/></svg>\n')
        open(f"{out_prefix}luminthor-{name}-{theme}.svg", 'w').write(svg)
    print(name, w, h, len(plist), 'curves')
