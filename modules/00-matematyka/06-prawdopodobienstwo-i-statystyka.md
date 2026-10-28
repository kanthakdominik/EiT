# 00.06 — Prawdopodobieństwo i statystyka

## Po co to jest

- **Szumy** w układach elektronicznych to sygnały losowe — opisuje się je wartością skuteczną, rozkładem i gęstością widmową.
- **Niepewność pomiaru** wyznacza się metodami statystycznymi.
- **Stopa błędów (BER)** w telekomunikacji to prawdopodobieństwo.
- **Rozkład Poissona** opisuje zliczanie zdarzeń: impulsy z detektora promieniowania, fotony, pakiety w sieci.

## Teoria w pigułce

| Pojęcie | Wzór | Znaczenie w elektronice |
|---|---|---|
| Wartość oczekiwana | $\mu = E[X]$ | Składowa stała sygnału |
| Wariancja | $\sigma^2 = E[(X - \mu)^2]$ | Moc składowej zmiennej (szumu) |
| Odchylenie standardowe | $\sigma$ | Wartość skuteczna szumu o zerowej średniej |
| Średnia z $n$ pomiarów | $\bar{x} = \frac{1}{n}\sum x_i$ | Estymata wartości mierzonej |
| Odchylenie standardowe średniej | $\sigma_{\bar{x}} = \sigma/\sqrt{n}$ | Uśrednianie zmniejsza szum $\sqrt{n}$ razy |

**Suma niezależnych zmiennych losowych:** wariancje się dodają, $\sigma^2 = \sigma_1^2 + \sigma_2^2$. W praktyce: **niezależne szumy dodaje się „pod pierwiastkiem”** (RSS — root sum of squares).

**Rozkład normalny (Gaussa):** w przedziale $\mu \pm \sigma$ leży 68,3% wyników, $\mu \pm 2\sigma$ — 95,4%, $\mu \pm 3\sigma$ — 99,7%. Szum termiczny ma rozkład normalny.

**Rozkład Poissona** (liczba zdarzeń o średniej $\lambda$ w danym czasie):

$$P(k) = \frac{\lambda^k e^{-\lambda}}{k!}, \quad \mu = \lambda, \quad \sigma = \sqrt{\lambda}$$

Wniosek praktyczny: przy zliczeniu $N$ zdarzeń względna niepewność wynosi $1/\sqrt{N}$.

**Rozkład dwumianowy** — $k$ sukcesów w $n$ niezależnych próbach o prawdopodobieństwie $p$. Dla małego $p$ i dużego $n$ przechodzi w rozkład Poissona z $\lambda = np$.

## Przykład rozwiązany

Wzmacniacz ma na wejściu dwa niezależne źródła szumu: szum rezystora 3 µV RMS i szum własny wzmacniacza 4 µV RMS (w tym samym paśmie). Jaki jest szum całkowity?

$$U_n = \sqrt{3^2 + 4^2} = 5\ \mu\text{V RMS}$$

Gdyby dodać je arytmetycznie (7 µV), wynik byłby zawyżony o 40%.

## Typowe pułapki

- **Arytmetyczne dodawanie szumów** zamiast RSS. Arytmetycznie dodaje się tylko sygnały w pełni skorelowane.
- **Mylenie $\sigma$ i $\sigma_{\bar{x}}$** — rozrzut pojedynczego pomiaru to co innego niż niepewność średniej.
- **Zakładanie rozkładu normalnego dla małej liczby zliczeń.** Dla $\lambda < 10$ rozkład Poissona jest wyraźnie asymetryczny.

## Symulacja / ćwiczenie komputerowe

```python
import numpy as np
rng = np.random.default_rng(0)

# uśrednianie szumu
x = 1.0 + rng.normal(0, 2e-3, size=(10_000, 100))   # 10 000 serii po 100 pomiarów
print(x.std(), x.mean(axis=1).std())                # ≈ 2e-3 oraz ≈ 2e-4

# rozkład Poissona
k = rng.poisson(400, size=100_000)
print(k.std() / k.mean())                           # ≈ 0.05
```

## Zadania

1. Dwa niezależne źródła szumu: 3 µV i 4 µV RMS. Jaki jest szum całkowity?
2. Pojedynczy pomiar napięcia ma odchylenie standardowe 2 mV. Jaka jest niepewność średniej ze 100 pomiarów?
3. Jakie jest prawdopodobieństwo, że wynik z rozkładu normalnego odchyli się od średniej o więcej niż $2\sigma$?
4. Zdarzenia występują średnio 4 razy na sekundę (Poisson). Jakie jest prawdopodobieństwo, że w danej sekundzie nie wystąpi żadne?
5. Detektor zliczył 400 impulsów. Jaka jest względna niepewność statystyczna wyniku? Ile impulsów trzeba zliczyć, żeby zejść do 1%?
6. Łącze ma BER = $10^{-3}$, błędy są niezależne. Jakie jest prawdopodobieństwo bezbłędnego przesłania pakietu 1000 bitów?

<details>
<summary>Odpowiedzi</summary>

1. $\sqrt{9 + 16} = 5$ µV RMS
2. $2/\sqrt{100} = 0{,}2$ mV
3. $1 - 0{,}954 \approx 4{,}6\%$
4. $P(0) = e^{-4} \approx 0{,}018$
5. $1/\sqrt{400} = 5\%$; dla 1% potrzeba $N = 10\,000$ impulsów
6. $(1 - 10^{-3})^{1000} \approx e^{-1} \approx 0{,}368$
</details>

## Źródła

- [The Scientist and Engineer's Guide to DSP — rozdział 2: *Statistics, Probability and Noise*](http://www.dspguide.com/)
- [Fundamentals of Electrical Engineering I — D. Johnson](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-electrical-engineering-1) — prawdopodobieństwo w kontekście komunikacji
