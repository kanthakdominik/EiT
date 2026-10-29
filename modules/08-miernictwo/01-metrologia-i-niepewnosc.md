# 08.01 — Metrologia i niepewność pomiaru

## Po co to jest

Wynik pomiaru bez niepewności jest niepełny — nie wiadomo, czy różnica 1% między dwoma pomiarami to zmiana mierzonej wielkości, czy szum przyrządu. Szacowanie niepewności według przewodnika GUM to wspólny język laboratoriów, dokumentacji przyrządów i odbiorów technicznych.

## Teoria w pigułce

### Pojęcia podstawowe

| Pojęcie | Znaczenie |
|---|---|
| **Błąd** | Różnica między wynikiem a wartością prawdziwą (której nie znamy) |
| **Niepewność** | Parametr opisujący rozrzut wartości, które można rozsądnie przypisać mierzonej wielkości |
| Błąd systematyczny | Stały lub przewidywalny — koryguje się go (kalibracja), a niepewność korekcji wlicza do budżetu |
| Błąd przypadkowy | Zmienny — zmniejsza się przez uśrednianie |
| **Rozdzielczość** | Najmniejsza zmiana, którą przyrząd pokaże |
| **Dokładność** | Zgodność z wartością prawdziwą |
| Precyzja (powtarzalność) | Zgodność wyników powtórzonych pomiarów |
| Spójność pomiarowa (traceability) | Nieprzerwany łańcuch kalibracji do wzorców SI |

### Niepewność typu A (statystyczna)

Z serii $n$ pomiarów: $u_A = \dfrac{s}{\sqrt n}$, gdzie $s$ — odchylenie standardowe z próby.

### Niepewność typu B (z innych informacji)

Ze specyfikacji przyrządu, certyfikatu kalibracji, rozdzielczości. Dla granicy błędu $\pm a$ i rozkładu prostokątnego:

$$u_B = \frac{a}{\sqrt3}$$

Specyfikacja multimetru ma zwykle postać $\pm(\%\ \text{wartości mierzonej} + \text{liczba cyfr})$. Rozdzielczość $q$ wnosi $q/\sqrt{12}$.

### Niepewność złożona i rozszerzona

Niezależne składowe sumuje się w kwadratach: $u_c = \sqrt{u_A^2 + u_{B1}^2 + u_{B2}^2 + \dots}$

Dla wielkości obliczanej $y = f(x_1, x_2, \dots)$ (prawo propagacji):

$$u_c^2(y) = \sum_i\left(\frac{\partial f}{\partial x_i}\right)^2u^2(x_i)$$

Dla iloczynów i ilorazów wygodniej w postaci względnej: dla $y = x_1^ax_2^b$ → $\left(\dfrac{u_y}{y}\right)^2 = a^2\left(\dfrac{u_1}{x_1}\right)^2 + b^2\left(\dfrac{u_2}{x_2}\right)^2$.

**Niepewność rozszerzona** $U = k\cdot u_c$; zwykle $k = 2$ (poziom ufności ok. 95%). Wynik zapisuje się jako $x = \bar x \pm U$ z jedną lub dwiema cyframi znaczącymi niepewności i wynikiem zaokrąglonym do tego samego miejsca.

## Przykład rozwiązany

Multimetr ±(0,5% w.m. + 2 cyfry), zakres 20,00 V (rozdzielczość 0,01 V). Dziesięć odczytów, średnia 12,34 V, $s = 0\text{,}03$ V.

1. Typ A: $u_A = 0\text{,}03/\sqrt{10} \approx 0\text{,}0095$ V.
2. Typ B: $a = 0\text{,}005\cdot 12\text{,}34 + 2\cdot 0\text{,}01 \approx 0\text{,}082$ V; $u_B = 0\text{,}082/\sqrt3 \approx 0\text{,}047$ V. (Rozdzielczość jest już zawarta w składniku „cyfr”.)
3. Złożona: $u_c = \sqrt{0\text{,}0095^2 + 0\text{,}047^2} \approx 0\text{,}048$ V.
4. Rozszerzona ($k = 2$): $U \approx 0\text{,}096$ V → **$U = (12\text{,}34 \pm 0\text{,}10)$ V**.

Wniosek: dominuje specyfikacja przyrządu — więcej powtórzeń niewiele tu poprawi.

## Typowe pułapki

- **Niepewność z samego rozrzutu odczytów**, gdy dominuje dokładność przyrządu (typ B).
- **Dodawanie niepewności arytmetycznie** zamiast w kwadratach (dla składowych niezależnych).
- **Dziesięć cyfr znaczących wyniku** przy niepewności w drugim miejscu po przecinku.
- **Rozdzielczość myląca się z dokładnością** — multimetr 6½ cyfry może mieć dokładność gorszą niż rozdzielczość.

## Ćwiczenie komputerowe

```python
import numpy as np
readings = np.array([12.31, 12.36, 12.33, 12.35, 12.30, 12.37, 12.34, 12.33, 12.36, 12.35])
uA = readings.std(ddof=1)/np.sqrt(len(readings))
a = 0.005*readings.mean() + 0.02; uB = a/np.sqrt(3)
uc = np.hypot(uA, uB)
print(f"U = ({readings.mean():.2f} ± {2*uc:.2f}) V  (uA={uA:.4f}, uB={uB:.4f})")

# Monte Carlo propagacji dla P = U^2/R
rng = np.random.default_rng(0)
U = rng.uniform(12.34 - a, 12.34 + a, 100_000); R = rng.normal(100, 0.5, 100_000)
P = U**2/R
print(f"P = {P.mean():.4f} W ± {P.std():.4f} W (1σ)")
```

## Zadania

1. Policz niepewność rozszerzoną wyniku z przykładu.
2. Rezystor 100 Ω ±1% (wartość z tolerancji, rozkład prostokątny). Ile wynosi $u_B$?
3. Moc $P = U^2/R$; względne niepewności: $U$ — 1%, $R$ — 0,5%. Ile wynosi względna niepewność $P$?
4. Ile pomiarów trzeba uśrednić, aby $u_A$ spadło do 1/5 odchylenia standardowego pojedynczego pomiaru?
5. Przyrząd ma rozdzielczość 1 mV i pomijalny szum. Jaka jest niepewność od rozdzielczości?
6. Zapisz poprawnie wynik: średnia 4,567891 V, $U = 0\text{,}0234$ V.

<details>
<summary>Odpowiedzi</summary>

1. $U \approx 0\text{,}096$ V → $(12\text{,}34 \pm 0\text{,}10)$ V
2. $1/\sqrt3 \approx 0\text{,}58\ \Omega$
3. $\sqrt{(2\cdot 1\%)^2 + 0\text{,}5\%^2} \approx 2\text{,}06\%$
4. 25
5. $1\ \text{mV}/\sqrt{12} \approx 0\text{,}29$ mV
6. $(4\text{,}568 \pm 0\text{,}023)$ V
</details>

## Źródła

- [JCGM 100:2008 — GUM](https://www.bipm.org/en/doi/10.59161/jcgm100-2008e) — oficjalny przewodnik wyrażania niepewności pomiaru
- [BIPM — przewodniki JCGM (GUM, VIM)](https://www.bipm.org/en/web/guest/publications/guides) — w tym słownik metrologii VIM
- [Modular Electronics Learning (ModEL) Project](https://ibiblio.org/kuphaldt/socratic/model/) — moduły o pomiarach i obliczeniach błędów
