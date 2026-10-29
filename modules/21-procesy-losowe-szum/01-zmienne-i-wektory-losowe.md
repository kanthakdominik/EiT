# 21.01 — Zmienne i wektory losowe w praktyce inżynierskiej

## Po co to jest

Rezystory mają tolerancję, napięcie odniesienia dryfuje, offset wzmacniacza jest losowy od egzemplarza do egzemplarza, a próbka szumu w danej chwili to zmienna losowa. Projektant musi odpowiedzieć na pytania: jaki rozrzut będzie miała seria 10 000 urządzeń? Ile z nich nie spełni specyfikacji? Jak sumują się błędy z kilku źródeł? Ten temat przypomina podstawy z [00.06](../00-matematyka/06-prawdopodobienstwo-i-statystyka.md) i rozszerza je na wiele zmiennych — kowariancję, rozkład wielowymiarowy i propagację rozrzutu.

## Teoria w pigułce

### Momenty i rozkłady

- Wartość oczekiwana $\mu = E[X]$, wariancja $\sigma^2 = E[(X - \mu)^2]$, wartość skuteczna szumu o zerowej średniej = $\sigma$.
- **Rozkład normalny** $\mathcal N(\mu, \sigma^2)$: $P(\lvert X - \mu\rvert > 2\sigma) \approx 4\text{,}6\%$, $> 3\sigma$: 0,27%, $> 6\sigma$: $2\cdot 10^{-9}$.
- **Rozkład jednostajny** na $[-a, a]$: $\sigma = a/\sqrt 3$ (tolerancja elementów przy braku innych informacji, błąd kwantyzacji: $a = q/2 \Rightarrow \sigma = q/\sqrt{12}$).
- **Centralne twierdzenie graniczne:** suma wielu niezależnych składników o porównywalnych wariancjach ma rozkład bliski normalnemu — dlatego szum termiczny i suma tolerancji są gaussowskie.

### Wiele zmiennych

- **Kowariancja** $\mathrm{cov}(X, Y) = E[(X - \mu_X)(Y - \mu_Y)]$, **współczynnik korelacji** $\rho = \mathrm{cov}/(\sigma_X\sigma_Y) \in [-1, 1]$.
- Wariancja sumy: $\mathrm{var}(X + Y) = \sigma_X^2 + \sigma_Y^2 + 2\rho\sigma_X\sigma_Y$. Niezależne → wariancje się dodają (**suma geometryczna**, RSS). Całkowicie skorelowane → dodają się odchylenia.
- **Macierz kowariancji** $\mathbf\Sigma = E[(\mathbf X - \boldsymbol\mu)(\mathbf X - \boldsymbol\mu)^T]$; dla $\mathbf Y = \mathbf A\mathbf X$: $\mathbf\Sigma_Y = \mathbf A\mathbf\Sigma_X\mathbf A^T$.
- **Wielowymiarowy rozkład normalny** jest całkowicie opisany przez $\boldsymbol\mu$ i $\mathbf\Sigma$; zmienne gaussowskie nieskorelowane są niezależne.

### Propagacja rozrzutu

Dla $Y = f(X_1, \ldots, X_n)$ z małymi rozrzutami (linearyzacja, jak w [08.01](../08-miernictwo/01-metrologia-i-niepewnosc.md)):

$$\sigma_Y^2 \approx \sum_i \left(\frac{\partial f}{\partial X_i}\right)^2\sigma_i^2 + 2\sum_{i<j}\frac{\partial f}{\partial X_i}\frac{\partial f}{\partial X_j}\mathrm{cov}(X_i, X_j)$$

Trzy podejścia do tolerancji projektu:

| Metoda | Wynik | Kiedy |
|---|---|---|
| **Najgorszy przypadek (worst case)** | Granice na pewno nieprzekroczone | Bezpieczeństwo, małe serie, zasilanie |
| **RSS (statystyczna)** | Rozrzut $\sigma$ przy niezależnych składnikach | Duże serie, wiele składników |
| **Monte Carlo** | Pełny rozkład, także dla nieliniowych zależności | Złożone obwody (`.mc` w SPICE) |

## Przykład rozwiązany

**Dzielnik 10 kΩ / 10 kΩ z rezystorów 1%** (przyjmujemy rozkład jednostajny w granicach tolerancji). Stosunek $k = R_2/(R_1 + R_2) = 0\text{,}5$.

- Pochodne: $\partial k/\partial R_2 = R_1/(R_1+R_2)^2$, $\partial k/\partial R_1 = -R_2/(R_1+R_2)^2$; dla równych rezystorów względna czułość na każdy rezystor wynosi 0,5.
- Najgorszy przypadek: $R_2$ = +1%, $R_1$ = −1% → $k = 1\text{,}01/2 = 0\text{,}505$, czyli **±1%**.
- RSS: $\sigma_R = 1\%/\sqrt 3 = 0\text{,}577\%$; $\sigma_k/k = \sqrt{0\text{,}5^2 + 0\text{,}5^2}\cdot 0\text{,}577\% = 0\text{,}408\%$.
- Monte Carlo (200 000 losowań): $\sigma_k/k = 0\text{,}408\%$, a 99,73% egzemplarzy mieści się w ±0,95% — rozkład różnicy dwóch jednostajnych jest trójkątny, nie normalny, więc „3σ” (1,22%) przeszacowuje.

**Szereg 10 rezystorów 1%:** najgorszy przypadek ±1%, ale $\sigma = 0\text{,}577\%/\sqrt{10} = 0\text{,}18\%$ — błędy niezależne się uśredniają. Gdyby rezystory były z jednej partii i miały wspólne przesunięcie, korelacja zniweczyłaby ten zysk.

## Typowe pułapki

- **Dodawanie odchyleń zamiast wariancji** dla niezależnych źródeł — przeszacowanie (lub odwrotnie: RSS dla źródeł skorelowanych — niedoszacowanie).
- **Założenie rozkładu normalnego** dla tolerancji elementów — producenci często odrzucają elementy spoza węższej klasy (rozkład „z dziurą” w środku dla 5%).
- **Pominięcie korelacji** — dryf temperaturowy rezystorów z jednej partii, wspólne napięcie odniesienia.
- **„3σ” w małej serii** — dla 10 urządzeń wszystkie zmieszczą się w 3σ z dużym prawdopodobieństwem, dla 1 000 000 — ok. 2700 nie.
- **Linearyzacja przy dużych rozrzutach** — dla silnie nieliniowych funkcji użyj Monte Carlo.

## Ćwiczenie komputerowe

```python
import numpy as np
from scipy import stats

rng = np.random.default_rng(0); n = 200_000
print(f"P(|X| > 3σ) = {2*stats.norm.sf(3)*100:.3f}%,  P(|X| > 2σ) = {2*stats.norm.sf(2)*100:.2f}%")

# dzielnik 10k/10k, rezystory 1% (rozkład jednostajny)
R1 = 10e3*(1 + rng.uniform(-0.01, 0.01, n)); R2 = 10e3*(1 + rng.uniform(-0.01, 0.01, n))
k = R2/(R1 + R2); dev = (k - 0.5)/0.5*100
print(f"dzielnik: sigma = {dev.std():.3f}% (RSS: {0.5*np.sqrt(2)*1/np.sqrt(3):.3f}%), "
      f"99,73% w ±{np.percentile(np.abs(dev), 99.73):.2f}%, najgorszy przypadek ±1%")

# szereg 10 rezystorów: niezależne i z korelacją (wspólne przesunięcie partii ±0,8% + własny rozrzut ±0,2%)
Rind = 10e3*(1 + rng.uniform(-0.01, 0.01, (n, 10))).sum(axis=1)
shift = rng.uniform(-0.008, 0.008, (n, 1))
Rcor = 10e3*(1 + shift + rng.uniform(-0.002, 0.002, (n, 10))).sum(axis=1)
print(f"szereg 10 × 10 kΩ: niezależne sigma = {Rind.std()/1e5*100:.3f}%, z korelacją sigma = {Rcor.std()/1e5*100:.3f}%")

# macierz kowariancji: przekształcenie liniowe
S = np.array([[1.0, 0.8], [0.8, 1.0]])                      # dwie skorelowane zmienne
A = np.array([[1, 1], [1, -1]])                             # suma i różnica
print("kowariancja sumy i różnicy:\n", A @ S @ A.T)
```

Korelacja (wspólna partia) sprawia, że rozrzut szeregu wynosi ok. 0,46% — 2,5 raza więcej niż dla rezystorów niezależnych i niewiele mniej niż rozrzut pojedynczego rezystora (0,58%). Z macierzy widać też, że różnica silnie skorelowanych zmiennych ma małą wariancję — na tym polega układ różnicowy i dopasowane pary elementów.

## Zadania

1. Napięcie odniesienia 2,5 V ± 0,2% (normalny, granica = 3σ) i dzielnik z poprzedniego przykładu. Jaki jest rozrzut (σ) napięcia na wyjściu dzielnika?
2. Trzy niezależne źródła błędu: 1 mV, 2 mV, 2 mV (σ). Jaki jest błąd sumaryczny? A najgorszy przypadek przy granicach 3σ?
3. Ile egzemplarzy z miliona przekroczy granicę $\pm 4\sigma$ (rozkład normalny)?
4. Dlaczego para tranzystorów w jednej obudowie (dopasowana) daje mniejszy offset wzmacniacza różnicowego niż dwa osobne tranzystory?
5. Błąd kwantyzacji ADC z krokiem $q$ ma rozkład jednostajny. Ile wynosi jego wartość skuteczna?

<details>
<summary>Odpowiedzi</summary>

1. $\sigma_{ref} = 0\text{,}2\%/3 = 0\text{,}067\%$; łącznie $\sqrt{0\text{,}067^2 + 0\text{,}408^2} \approx 0\text{,}41\%$ (dominuje dzielnik)
2. $\sqrt{1 + 4 + 4} = 3$ mV; najgorszy przypadek $3\cdot(1 + 2 + 2) = 15$ mV
3. $2\cdot Q(4) \approx 6\cdot 10^{-5}$ → ok. 63
4. Parametry tranzystorów z jednego kryształu są silnie skorelowane (ten sam proces, temperatura); offset zależy od **różnicy** parametrów, której wariancja $\sigma_1^2 + \sigma_2^2 - 2\rho\sigma_1\sigma_2$ jest mała przy $\rho \to 1$
5. $q/\sqrt{12}$
</details>

## Źródła

- [MIT 6.041 Probabilistic Systems Analysis and Applied Probability](https://ocw.mit.edu/courses/6-041-probabilistic-systems-analysis-and-applied-probability-fall-2010/) — wykłady 1–12
- [NIST/SEMATECH e-Handbook of Statistical Methods](https://www.itl.nist.gov/div898/handbook/) — rozkłady, propagacja niepewności
- [JCGM 100:2008 (GUM)](https://www.bipm.org/en/doi/10.59161/jcgm100-2008e) — propagacja niepewności z korelacjami
