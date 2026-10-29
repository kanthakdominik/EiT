# 06.01 — Sygnały: klasyfikacja i operacje

## Po co to jest

Zanim przeanalizuje się układ, trzeba umieć opisać sygnał: czy jest okresowy, czy ma skończoną energię, jak wygląda po przesunięciu i skalowaniu. Sygnały elementarne (skok, delta, wykładniczy zespolony) to „alfabet”, z którego składa się wszystkie inne.

## Teoria w pigułce

### Klasyfikacja

| Kryterium | Rodzaje |
|---|---|
| Czas | Ciągły $x(t)$ / dyskretny $x[n]$ |
| Wartości | Analogowy / skwantowany (cyfrowy) |
| Przewidywalność | Deterministyczny / losowy |
| Powtarzalność | Okresowy ($x(t + T) = x(t)$) / nieokresowy |
| Symetria | Parzysty $x(-t) = x(t)$ / nieparzysty $x(-t) = -x(t)$; każdy sygnał = część parzysta + nieparzysta |
| Energia i moc | Energii (skończona $E$) / mocy (skończona niezerowa $P$) |

$$E = \int_{-\infty}^{\infty}\lvert x(t)\rvert^2dt, \qquad P = \lim_{T\to\infty}\frac{1}{2T}\int_{-T}^{T}\lvert x(t)\rvert^2dt$$

Impulsy mają skończoną energię (i zerową moc), sygnały okresowe — skończoną moc (i nieskończoną energię).

### Sygnały elementarne

| Sygnał | Definicja | Rola |
|---|---|---|
| Skok jednostkowy $u(t)$ | 0 dla $t < 0$, 1 dla $t \geq 0$ | Włączenie, odpowiedź skokowa |
| Delta Diraca $\delta(t)$ | Nieskończenie krótki impuls o polu 1; $\int x(t)\delta(t - t_0)dt = x(t_0)$ | Odpowiedź impulsowa, próbkowanie |
| Delta Kroneckera $\delta[n]$ | 1 dla $n = 0$, 0 poza | Odpowiedź impulsowa układów dyskretnych |
| Wykładniczy zespolony $e^{st}$ | $s = \sigma + j\omega$ | **Funkcja własna układów LTI** — przechodzi przez układ bez zmiany kształtu |
| Sinusoida | $A\cos(\omega t + \varphi)$ | Suma dwóch wykładników zespolonych |

$\delta(t) = \dfrac{du(t)}{dt}$ i $u(t) = \int_{-\infty}^{t}\delta(\tau)d\tau$.

### Operacje na zmiennej niezależnej

- **Przesunięcie:** $x(t - t_0)$ — opóźnienie o $t_0$ (w prawo).
- **Odbicie:** $x(-t)$.
- **Skalowanie:** $x(at)$ — ściśnięcie dla $\lvert a\rvert > 1$.
- Złożenie $x(at - b) = x\left(a(t - b/a)\right)$: najpierw przesuń o $b$, potem skaluj — albo najpierw skaluj, potem przesuń o $b/a$.

**Okresowość sygnałów dyskretnych:** $\cos(\omega_0 n)$ jest okresowy tylko gdy $\omega_0/2\pi$ jest liczbą wymierną. Częstotliwości $\omega_0$ i $\omega_0 + 2\pi$ dają w czasie dyskretnym **ten sam** sygnał — zapowiedź aliasingu.

## Przykład rozwiązany

Impuls prostokątny o amplitudzie 2 i czasie trwania 3 s oraz sinusoida o amplitudzie $A$.

1. Energia impulsu: $E = 2^2\cdot 3 = 12$ J (przy jednostkowej rezystancji); moc średnia: 0.
2. Sinusoida: energia nieskończona, moc $P = A^2/2$ — to kwadrat wartości skutecznej.
3. Sygnał $x(2t - 4)$, gdy $x(t)$ to impuls na przedziale [0, 3]: warunek $0 \leq 2t - 4 \leq 3$ → impuls na przedziale [2; 3,5], o czasie trwania 1,5 s.

## Typowe pułapki

- **Złożenie przesunięcia i skalowania w złej kolejności** — $x(2t - 4)$ to przesunięcie o 2, a nie o 4, po ściśnięciu.
- **Delta Diraca traktowana jak zwykła funkcja o wartości 1** — jej „wartość” jest nieskończona, ma sens tylko pod całką.
- **Okresowość sinusoidy dyskretnej** zakładana automatycznie.

## Ćwiczenie komputerowe

```python
import numpy as np, matplotlib.pyplot as plt
t = np.linspace(-2, 6, 2000)
x = lambda t: np.where((t >= 0) & (t <= 3), 2.0, 0.0)
plt.plot(t, x(t), label="x(t)"); plt.plot(t, x(2*t - 4), label="x(2t-4)")
plt.legend(); plt.grid(); plt.show()
print("energia:", np.sum(x(t)**2)*(t[1] - t[0]))
n = np.arange(20)
print(np.allclose(np.cos(0.3*n), np.cos((0.3 + 2*np.pi)*n)))   # True — ta sama sinusoida dyskretna
```

## Zadania

1. Oblicz energię i moc impulsu prostokątnego o amplitudzie 2 i czasie trwania 3 s.
2. Jaka jest moc sygnału $x(t) = 3 + 4\cos(\omega t)$?
3. Naszkicuj $x(2t - 4)$ dla impulsu na przedziale [0, 3].
4. Czy sygnał $x(t) = e^{t}u(t)$ jest sygnałem energii, mocy, czy żadnym z nich?
5. Czy $x[n] = \cos(0\text{,}25\pi n)$ jest okresowy? A $\cos(0\text{,}25n)$?
6. Zapisz $\cos(\omega t)$ i $\sin(\omega t)$ jako kombinacje wykładników zespolonych.

<details>
<summary>Odpowiedzi</summary>

1. $E = 12$, $P = 0$
2. $P = 9 + 16/2 = 17$ (moce składowej stałej i sinusoidy się sumują)
3. Impuls o amplitudzie 2 na przedziale [2; 3,5]
4. Żadnym — energia i moc są nieskończone (sygnał rośnie wykładniczo)
5. Tak, okres $N = 8$; nie — $0\text{,}25/(2\pi)$ jest niewymierne
6. $\cos\omega t = \tfrac12(e^{j\omega t} + e^{-j\omega t})$, $\sin\omega t = \tfrac{1}{2j}(e^{j\omega t} - e^{-j\omega t})$
</details>

## Źródła

- [MIT 6.003 Signals and Systems](https://ocw.mit.edu/courses/6-003-signals-and-systems-fall-2011/) — wykład 1: sygnały i systemy
- [MIT RES.6-007 Signals and Systems](https://ocw.mit.edu/courses/res-6-007-signals-and-systems-spring-2011/) — wykłady 2–3: sygnały ciągłe i dyskretne, sinusoidy dyskretne
- [Fundamentals of Electrical Engineering I — D. Johnson](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-electrical-engineering-1) — rozdział o sygnałach
