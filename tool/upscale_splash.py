"""Upscale a splash GIF into a full-colour animated WebP that plays once.

Usage: python3 tool/upscale_splash.py <entrada.gif> <saida.webp> <escala>
"""
import sys
from PIL import Image, ImageSequence, ImageFilter, features
src, dst, scale = sys.argv[1], sys.argv[2], int(sys.argv[3])
im = Image.open(src)
frames, durs = [], []
for f in ImageSequence.Iterator(im):
    rgb = f.convert('RGB')
    big = rgb.resize((rgb.width*scale, rgb.height*scale), Image.LANCZOS)
    big = big.filter(ImageFilter.UnsharpMask(radius=1.2, percent=40, threshold=2))
    frames.append(big); durs.append(f.info.get('duration', 40))
frames[0].save(dst, save_all=True, append_images=frames[1:], duration=durs,
               loop=1, quality=92, method=6)
print(dst, frames[0].size, len(frames), sum(durs))
