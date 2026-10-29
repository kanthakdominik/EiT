#!/usr/bin/env python3
"""Uruchamia wszystkie bloki ```python z plików .md w repozytorium.

Bloki wymagające sprzętu lub bibliotek spoza numpy/scipy/matplotlib (pyvisa, sympy,
gnuradio, pyadi-iio, pyrtlsdr) są pomijane. Wykresy są tworzone bez wyświetlania (backend Agg).
Użycie: python3 tools/check_snippets.py [katalog]
"""
import glob
import os
import re
import subprocess
import sys

SKIP = ("pyvisa", "sympy", "gnuradio", "import adi", "rtlsdr")
root = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), "..")
files = sorted(glob.glob(os.path.join(root, "modules", "**", "*.md"), recursive=True)
               + glob.glob(os.path.join(root, "masters", "**", "*.md"), recursive=True))
ok = fail = skipped = 0
for path in files:
    blocks = re.findall(r"```python\n(.*?)```", open(path, encoding="utf-8").read(), re.S)
    for i, code in enumerate(blocks):
        if any(s in code for s in SKIP):
            skipped += 1
            continue
        prog = "import matplotlib\nmatplotlib.use('Agg')\n" + code.replace("plt.show()", "pass")
        r = subprocess.run([sys.executable, "-c", prog], capture_output=True, text=True, timeout=600)
        rel = os.path.relpath(path, root)
        if r.returncode == 0:
            ok += 1
        else:
            fail += 1
            print(f"FAIL {rel} [blok {i}]\n{r.stderr[-1500:]}")
print(f"bloki OK: {ok}, błędy: {fail}, pominięte: {skipped}")
sys.exit(1 if fail else 0)
