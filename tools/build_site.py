#!/usr/bin/env python3
"""Przygotowuje stronę GitHub Pages (MkDocs Material) z plików .md repozytorium.

Pliki źródłowe w repozytorium się nie zmieniają. Skrypt kopiuje je do katalogu _site/src,
zamienia README.md na index.md, poprawia odnośniki (katalogi → index.md, pliki spoza strony →
GitHub), włącza Markdown wewnątrz <details> i zapisuje _site/mkdocs.yml z menu.
Użycie: python3 tools/build_site.py && mkdocs build -f _site/mkdocs.yml
"""
import glob
import os
import re
import shutil

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OUT = os.path.join(ROOT, "_site")
SRC = os.path.join(OUT, "src")
REPO = "https://github.com/kanthakdominik/EiT"
LINK = re.compile(r"(\]\()([^)\s]+)(\))")

PLIKI_GLOWNE = ["README.md", "ROADMAP.md", "RESOURCES.md", "TOOLS.md", "LICENSE.md"]


def cel_strony(sciezka_repo):
    """Ścieżka pliku w repozytorium → ścieżka na stronie (README.md → index.md)."""
    katalog, nazwa = os.path.split(sciezka_repo)
    return os.path.join(katalog, "index.md") if nazwa == "README.md" else sciezka_repo


def popraw_link(cel, plik_repo):
    if cel.startswith(("http://", "https://", "mailto:", "#")):
        return cel
    sciezka, _, kotwica = cel.partition("#")
    kotwica = "#" + kotwica if kotwica else ""
    katalog = os.path.dirname(plik_repo)
    pelna = os.path.normpath(os.path.join(ROOT, katalog, sciezka))
    rel_repo = os.path.relpath(pelna, ROOT)
    if os.path.isdir(pelna) and os.path.exists(os.path.join(pelna, "README.md")):
        rel_repo = os.path.join(rel_repo, "README.md")
    elif not rel_repo.endswith(".md") or not os.path.exists(pelna):
        return f"{REPO}/blob/main/{rel_repo}{kotwica}"           # pliki spoza strony (skrypty, konfiguracja)
    nowy = os.path.relpath(cel_strony(rel_repo), os.path.dirname(cel_strony(plik_repo)))
    return nowy + kotwica


LISTA = re.compile(r"^( *)([-*+]|\d+[.)]) +")


def dostosuj_markdown(tekst):
    """Różnice między Markdownem GitHuba a Python-Markdown (MkDocs): listy, tabele i bloki $$ muszą być
    oddzielone pustą linią od akapitu, a listy zagnieżdżone wymagają wcięcia o 4 spacje."""
    wynik, w_kodzie, w_wzorze = [], False, False
    for linia in tekst.split("\n"):
        poprz = wynik[-1] if wynik else ""
        if linia.lstrip().startswith("```"):
            w_kodzie = not w_kodzie
            wynik.append(linia)
            continue
        if w_kodzie:
            wynik.append(linia)
            continue
        m = LISTA.match(linia)
        if m and 0 < len(m.group(1)) < 4 and LISTA.match(poprz):
            linia = "    " + linia.lstrip()                       # lista zagnieżdżona: wcięcie 4 spacje
            m = LISTA.match(linia)
        pusta_przed = poprz.strip() != "" and not poprz.lstrip().startswith(">")
        if m and pusta_przed and not LISTA.match(poprz) and not poprz.startswith("    ") and not poprz.lstrip().startswith("<"):
            wynik.append("")
        elif linia.startswith("|") and pusta_przed and not poprz.startswith("|"):
            wynik.append("")
        elif linia.strip().startswith("$$"):
            if not w_wzorze and pusta_przed:
                wynik.append("")
            jedna = linia.strip() != "$$" and linia.strip().endswith("$$") and len(linia.strip()) > 4
            if not jedna:
                w_wzorze = not w_wzorze
        elif poprz.strip().endswith("$$") and not w_wzorze and linia.strip() and poprz.strip() != "":
            wynik.append("")
        wynik.append(linia)
    return "\n".join(wynik)


KOD = re.compile(r"`[^`\n]+`")


def potoki_w_tabelach(tekst):
    """GitHub wymaga \\| wewnątrz `kodu` w tabelach, Python-Markdown — zwykłego | (ukośnik byłby widoczny)."""
    return "\n".join(KOD.sub(lambda m: m.group(0).replace("\\|", "|"), l) if l.startswith("|") else l
                     for l in tekst.split("\n"))


def kopiuj(plik_repo):
    tekst = open(os.path.join(ROOT, plik_repo), encoding="utf-8").read()
    tekst = LINK.sub(lambda m: m.group(1) + popraw_link(m.group(2), plik_repo) + m.group(3), tekst)
    tekst = potoki_w_tabelach(dostosuj_markdown(tekst)).replace("<details>", '<details markdown="1">')
    cel = os.path.join(SRC, cel_strony(plik_repo))
    os.makedirs(os.path.dirname(cel), exist_ok=True)
    open(cel, "w", encoding="utf-8").write(tekst)


def tytul(plik_repo):
    pierwsza = open(os.path.join(ROOT, plik_repo), encoding="utf-8").readline().lstrip("# ").strip()
    return pierwsza.replace('"', "'")


shutil.rmtree(OUT, ignore_errors=True)
pliki = (PLIKI_GLOWNE + sorted(glob.glob("modules/*/*.md", root_dir=ROOT))
         + sorted(glob.glob("modules/*/*/*.md", root_dir=ROOT))         # np. szablony modułu 18
         + ["masters/README.md"] + sorted(glob.glob("masters/*/*.md", root_dir=ROOT)))
for p in pliki:
    kopiuj(p)


def menu_modulow(katalog_glowny, wciecie="    "):
    wiersze = []
    for d in sorted(glob.glob(f"{katalog_glowny}/*/", root_dir=ROOT)):
        d = d.rstrip("/")
        wiersze.append(f'{wciecie}- "{tytul(d + "/README.md")}":')
        wiersze.append(f"{wciecie}  - {d}/index.md")
        for t in sorted(glob.glob(f"{d}/[0-9]*.md", root_dir=ROOT)):
            wiersze.append(f'{wciecie}  - "{tytul(t)}": {t}')
        for t in sorted(glob.glob(f"{d}/*/*.md", root_dir=ROOT)):    # podkatalogi (szablony)
            wiersze.append(f'{wciecie}  - "{tytul(t)}": {t}')
    return wiersze


# menu
nav = ["nav:", "  - Start: index.md", "  - Roadmapa: ROADMAP.md", "  - Moduły:"]
nav += menu_modulow("modules")
nav += ["  - Ścieżka magisterska:", "    - masters/index.md"]
nav += menu_modulow("masters")
nav += ["  - Materiały:", "    - Źródła: RESOURCES.md", "    - Narzędzia: TOOLS.md", "    - Licencja: LICENSE.md"]

os.makedirs(os.path.join(SRC, "javascripts"), exist_ok=True)
shutil.copy(os.path.join(ROOT, "tools", "site", "mathjax.js"), os.path.join(SRC, "javascripts", "mathjax.js"))
shutil.copy(os.path.join(ROOT, "tools", "site", "extra.css"), os.path.join(SRC, "javascripts", "extra.css"))
konfig = open(os.path.join(ROOT, "tools", "site", "mkdocs.base.yml"), encoding="utf-8").read()
nav += ['  - "← Wszystkie bazy wiedzy": https://kanthakdominik.github.io/']
open(os.path.join(OUT, "mkdocs.yml"), "w", encoding="utf-8").write(konfig.rstrip() + "\n\n" + "\n".join(nav) + "\n")
print(f"stron: {len(pliki)}, katalog: {SRC}")
