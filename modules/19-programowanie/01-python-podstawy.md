# 19.01 — Python: podstawy języka

## Po co to jest

Python jest „kalkulatorem inżyniera”: liczy obwody, analizuje pomiary, steruje przyrządami ([08.08](../08-miernictwo/08-automatyzacja-pomiarow.md)), generuje wykresy do raportu. Wszystkie ćwiczenia komputerowe w tym repozytorium są w Pythonie. Nie trzeba być programistą — wystarczy sprawnie posługiwać się kilkunastoma konstrukcjami, które opisuje ten temat.

## Teoria w pigułce

### Uruchamianie

- **Interpreter interaktywny** (`python3`) lub Jupyter — do szybkich obliczeń.
- **Skrypt** `plik.py` uruchamiany `python3 plik.py` — do wszystkiego, co ma być powtarzalne.
- **Środowisko wirtualne:** `python3 -m venv .venv`, aktywacja, `pip install numpy scipy matplotlib` — każdy projekt ma własne wersje bibliotek.

### Typy i operatory

| Typ | Przykład | Uwagi |
|---|---|---|
| `int` | `42`, `0xFF`, `0b1010` | Dowolnie duże liczby całkowite |
| `float` | `3.3`, `4.7e3` | Podwójna precyzja IEEE 754 ([20.01](../20-metody-numeryczne/01-arytmetyka-i-bledy.md)) |
| `complex` | `3 + 4j` | Impedancje: `abs(z)`, `cmath.phase(z)` |
| `str` | `"R1"`, `f"{U:.2f} V"` | f-stringi do formatowania wyników |
| `bool` | `True`, `False` | |
| `list` | `[1, 2, 3]` | Zmienna, uporządkowana |
| `tuple` | `(470, 910)` | Niezmienna — np. para wartości |
| `dict` | `{"R1": 4700, "C1": 1e-9}` | Odwzorowanie klucz → wartość |

Dzielenie: `/` daje zawsze `float`, `//` dzieli całkowicie (w dół), `%` reszta, `**` potęga.

### Sterowanie i funkcje

```python
def parallel(*rs):
    """Rezystancja zastępcza rezystorów równoległych."""
    return 1 / sum(1 / r for r in rs)

for r in [1e3, 2.2e3, 4.7e3]:
    if r > 2e3:
        print(f"{r:.0f} Ω -> równolegle z 1 kΩ: {parallel(r, 1e3):.1f} Ω")
```

- Bloki wyznacza **wcięcie** (4 spacje).
- `for x in kolekcja`, `range(start, stop, krok)`, `enumerate`, `zip` — zamiast ręcznych indeksów.
- **Wyrażenia listowe:** `[x**2 for x in v if x > 0]`.
- Argumenty domyślne i nazwane: `def divider(vin, r1, r2=10e3)`, wywołanie `divider(5, r1=4.7e3)`.

### Moduły, pliki, wyjątki

- `import math`, `from pathlib import Path`; własny plik `obwody.py` importuje się jako `import obwody`.
- Pliki: `with open("dane.csv") as f: for line in f: ...` — `with` zamyka plik sam.
- Wyjątki: `try: ... except ValueError: ...` — do obsługi błędnych danych, nie do ukrywania błędów.

## Przykład rozwiązany

**Dobór dzielnika napięcia z szeregu E24.** Potrzebne 3,3 V z 5 V, rezystancja całkowita 10–100 kΩ (mały prąd, ale nie za duża impedancja dla wejścia ADC).

Zamiast ręcznego przeszukiwania — pełne przeszukanie wszystkich par:

```python
E24 = [1.0, 1.1, 1.2, 1.3, 1.5, 1.6, 1.8, 2.0, 2.2, 2.4, 2.7, 3.0,
       3.3, 3.6, 3.9, 4.3, 4.7, 5.1, 5.6, 6.2, 6.8, 7.5, 8.2, 9.1]
values = [round(m * 10**d) for d in range(2, 6) for m in E24]   # 100 Ω … 910 kΩ

def vout(vin, r1, r2):
    return vin * r2 / (r1 + r2)

candidates = [(abs(vout(5, r1, r2) - 3.3), r1, r2)
              for r1 in values for r2 in values if 10e3 <= r1 + r2 <= 100e3]
for err, r1, r2 in sorted(candidates)[:3]:
    print(f"R1 = {r1:>6} Ω, R2 = {r2:>6} Ω -> {vout(5, r1, r2):.4f} V (błąd {err*1e3:.1f} mV)")
```

Wynik: najlepsza para to 4,7 kΩ / 9,1 kΩ (3,2971 V, błąd 2,9 mV), dalej 6,2 kΩ / 12 kΩ i 20 kΩ / 39 kΩ. Program sprawdził ok. 9000 par w ułamku sekundy — i pozwala łatwo dodać kolejne kryteria (np. tolerancję albo pobór prądu).

## Typowe pułapki

- **Wcięcia mieszane (spacje i tabulatory)** — błąd `IndentationError` albo, gorzej, inna logika.
- **Domyślny argument zmienny:** `def f(x, acc=[])` — lista jest współdzielona między wywołaniami; użyj `acc=None`.
- **Porównywanie liczb zmiennoprzecinkowych `==`:** `0.1 + 0.2 == 0.3` daje `False`; używaj `math.isclose`.
- **Kopiowanie list:** `b = a` nie kopiuje — obie nazwy wskazują ten sam obiekt; `b = a.copy()` lub `list(a)`.
- **Pętla po indeksach** `for i in range(len(v))` tam, gdzie wystarczy `for x in v` lub `zip`.

## Ćwiczenie komputerowe

Kalkulator kodu paskowego rezystora i najbliższej wartości E24 — słowniki, funkcje, wyjątki:

```python
COLORS = {"czarny": 0, "brązowy": 1, "czerwony": 2, "pomarańczowy": 3, "żółty": 4,
          "zielony": 5, "niebieski": 6, "fioletowy": 7, "szary": 8, "biały": 9}
E24 = [1.0, 1.1, 1.2, 1.3, 1.5, 1.6, 1.8, 2.0, 2.2, 2.4, 2.7, 3.0,
       3.3, 3.6, 3.9, 4.3, 4.7, 5.1, 5.6, 6.2, 6.8, 7.5, 8.2, 9.1]

def decode(bands):
    """Trzy paski: dwie cyfry i mnożnik."""
    try:
        d1, d2, mult = (COLORS[b] for b in bands)
    except KeyError as e:
        raise ValueError(f"nieznany kolor: {e}") from None
    return (10 * d1 + d2) * 10**mult

def nearest_e24(r):
    import math
    decade = 10 ** math.floor(math.log10(r))
    return min((m * decade for m in E24 + [10.0]), key=lambda x: abs(x - r))

print(decode(["żółty", "fioletowy", "czerwony"]))     # 4700
print(nearest_e24(5000))                              # 5100.0
try:
    decode(["różowy", "czarny", "czarny"])
except ValueError as e:
    print("błąd:", e)
```

## Zadania

1. Napisz funkcję `series(*rs)` i `parallel(*rs)` i policz rezystancję: 1 kΩ szeregowo z (2,2 kΩ ∥ 3,3 kΩ).
2. Słownik `{"R1": 4700, "R2": 10000, "R3": 220}` — wypisz elementy posortowane według wartości.
3. Napisz funkcję zwracającą częstotliwość graniczną filtru RC i użyj jej w f-stringu z jednostką i 3 cyframi znaczącymi.
4. Co wypisze `print([i**2 for i in range(5) if i % 2])`?
5. Wczytaj plik tekstowy z jedną liczbą w każdej linii, pomijając puste linie i linie zaczynające się od `#`; zwróć średnią.

<details>
<summary>Odpowiedzi</summary>

1. $1000 + 2200\cdot 3300/5500 = 2320$ Ω
2. `for k, v in sorted(d.items(), key=lambda kv: kv[1]): print(k, v)` → R3, R1, R2
3. `def fc(r, c): return 1 / (2 * math.pi * r * c)`; `print(f"{fc(1e3, 100e-9):.3g} Hz")` → `1.59e+03 Hz`
4. `[1, 9]`
5. `vals = [float(l) for l in open(p) if l.strip() and not l.lstrip().startswith("#")]`, potem `sum(vals) / len(vals)` (lepiej z `with open(...)`)
</details>

## Źródła

- [The Python Tutorial](https://docs.python.org/3/tutorial/) — rozdziały 3–8
- [MIT 6.0001 Introduction to CS and Programming in Python](https://ocw.mit.edu/courses/6-0001-introduction-to-computer-science-and-programming-in-python-fall-2016/) — wykłady 1–8
- [MIT — The Missing Semester](https://missing.csail.mit.edu/) — praca w terminalu i edytorze
