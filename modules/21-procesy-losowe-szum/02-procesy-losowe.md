# 21.02 — Procesy losowe: stacjonarność i ergodyczność

## Po co to jest

Szum na wyjściu wzmacniacza, sygnał mowy, strumień bitów, zakłócenia sieci — to sygnały, których przebiegu nie da się przewidzieć, ale których **właściwości statystyczne** są stałe i mierzalne. Proces losowy to model takiego sygnału. Dwa pojęcia z tego tematu decydują o tym, czy w ogóle wolno mierzyć: **stacjonarność** (statystyki nie zmieniają się w czasie) i **ergodyczność** (wystarczy jedna długa realizacja zamiast tysiąca egzemplarzy).

## Teoria w pigułce

### Definicja

Proces losowy $X(t)$ to rodzina zmiennych losowych indeksowana czasem — albo, równoważnie, zbiór (zespół) możliwych przebiegów (**realizacji**) $x(t; \zeta)$.

- Ustalone $t$ → zmienna losowa $X(t_1)$ (przekrój przez zespół).
- Ustalona realizacja → zwykły sygnał $x(t)$ (to, co widzi oscyloskop).

Opis drugiego rzędu (wystarczający dla procesów gaussowskich i do liczenia mocy):

- Średnia $\mu_X(t) = E[X(t)]$.
- **Autokorelacja** $R_X(t_1, t_2) = E[X(t_1)X(t_2)]$, autokowariancja $C_X = R_X - \mu_X(t_1)\mu_X(t_2)$.

### Stacjonarność

- **W ścisłym sensie:** wszystkie rozkłady niezmienne względem przesunięcia w czasie.
- **W szerokim sensie (WSS):** $\mu_X$ stała i $R_X(t_1, t_2) = R_X(\tau)$ zależy tylko od $\tau = t_2 - t_1$. To założenie wystarcza do analizy widmowej (temat 03).
- Moc średnia procesu WSS: $E[X^2] = R_X(0)$.
- **Procesy cyklostacjonarne** — statystyki okresowe (sygnał zmodulowany cyfrowo z okresem symbolu, szum w układach przełączanych: mieszacze, przetwornice, układy z próbkowaniem). Po uśrednieniu po okresie traktuje się je jak WSS.

### Ergodyczność

Proces jest ergodyczny (w średniej, w autokorelacji), gdy średnie czasowe jednej realizacji są równe średnim po zespole:

$$\lim_{T\to\infty}\frac{1}{T}\int_0^T x(t)\,dt = \mu_X, \qquad \lim_{T\to\infty}\frac1T\int_0^T x(t)x(t + \tau)\,dt = R_X(\tau)$$

Każdy pomiar szumu jednym przyrządem zakłada ergodyczność. Warunek wystarczający dla średniej: autokowariancja zanika ($C_X(\tau) \to 0$ dla $\tau \to \infty$) — odległe w czasie próbki „zapominają” o sobie.

### Przykłady

| Proces | Stacjonarny (WSS)? | Ergodyczny? |
|---|---|---|
| Szum termiczny rezystora w stałej temperaturze | Tak | Tak |
| $A\cos(\omega t + \Theta)$, $\Theta$ jednostajne na $[0, 2\pi)$ | Tak: $\mu = 0$, $R = \tfrac{A^2}{2}\cos\omega\tau$ | Tak (w średniej i autokorelacji) |
| $A\cos(\omega t)$ z losową amplitudą $A$ | Nie ($E[X^2]$ zależy od $t$) | — |
| Stała losowa $X(t) = C$ (np. offset egzemplarza) | Tak | **Nie** — średnia czasowa daje $C$ danego egzemplarza, nie średnią po zespole |
| Szum z dryfem temperatury | Nie (w długiej skali) | — |
| Szum $1/f$ | Na granicy — wariancja rośnie z czasem obserwacji | Problematyczny |

## Przykład rozwiązany

**Sinusoida o losowej fazie** $X(t) = A\cos(\omega_0t + \Theta)$, $\Theta \sim U[0, 2\pi)$.

- Średnia: $E[X(t)] = \dfrac{A}{2\pi}\displaystyle\int_0^{2\pi}\cos(\omega_0t + \theta)\,d\theta = 0$ — dla każdego $t$.
- Autokorelacja: $E[X(t)X(t+\tau)] = A^2E[\cos(\omega_0t + \Theta)\cos(\omega_0t + \omega_0\tau + \Theta)] = \dfrac{A^2}{2}\cos\omega_0\tau$ (człon z $2\Theta$ uśrednia się do zera).
- Zależy tylko od $\tau$ → proces WSS. Moc $R_X(0) = A^2/2$ — zgodnie z wartością skuteczną sinusoidy.
- Średnia czasowa jednej realizacji: też 0, a autokorelacja czasowa — też $\tfrac{A^2}{2}\cos\omega_0\tau$ → ergodyczny.

To jest model nośnej odbieranej w nieznanej chwili, sygnału zegara widzianego przez niezsynchronizowany układ, interferencji z sieci 50 Hz.

## Typowe pułapki

- **Mylenie średniej po zespole ze średnią czasową** dla procesów nieergodycznych — offset jednego egzemplarza wzmacniacza nie mówi nic o rozrzucie w serii.
- **Pomiar za krótki** — średnia czasowa ma własny rozrzut; im silniej skorelowane próbki (wolny proces), tym dłużej trzeba mierzyć.
- **Traktowanie dryfu jak szumu** — proces niestacjonarny; widmo z długiego zapisu jest wtedy zdominowane przez trend (usuń trend przed analizą: `scipy.signal.detrend`).
- **Szum w układach przełączanych** analizowany jak stacjonarny bez uwzględnienia cykliczności — błędny wynik w pobliżu częstotliwości przełączania i jej harmonicznych.

## Ćwiczenie komputerowe

Zespół realizacji: średnie po zespole i po czasie dla procesu ergodycznego i nieergodycznego:

```python
import numpy as np

rng = np.random.default_rng(0)
M, N, fs, f0 = 2000, 4000, 10_000, 50            # 2000 realizacji po 4000 próbek
t = np.arange(N)/fs

# proces 1: sinusoida o losowej fazie + szum biały
theta = rng.uniform(0, 2*np.pi, (M, 1))
X = np.cos(2*np.pi*f0*t + theta) + 0.3*rng.normal(size=(M, N))

# proces 2: stała losowa (offset egzemplarza) + szum
C = rng.normal(0, 1, (M, 1))
Y = C + 0.3*rng.normal(size=(M, N))

for name, P in [("sinusoida + szum", X), ("offset losowy + szum", Y)]:
    ens_mean = P[:, 1000].mean()                  # średnia po zespole w chwili t = 0,1 s
    time_mean = P[0].mean()                       # średnia po czasie z 1 realizacji
    ens_pow = (P[:, 1000]**2).mean(); time_pow = (P[0]**2).mean()
    print(f"{name:22s}: średnia zespół {ens_mean:+.3f}, czas {time_mean:+.3f} | moc zespół {ens_pow:.3f}, czas {time_pow:.3f}")

# autokorelacja czasowa procesu 1 dla opóźnienia 5 ms (ćwierć okresu 50 Hz) i 10 ms
x = X[0]
for lag_ms in (0, 5, 10):
    L = int(lag_ms*1e-3*fs)
    r = np.mean(x[:N - L]*x[L:])
    print(f"R({lag_ms} ms) = {r:+.3f}  (teoria: {0.5*np.cos(2*np.pi*f0*lag_ms*1e-3) + (0.09 if L == 0 else 0):+.3f})")
```

Dla procesu 1 średnie i moce zgadzają się (ergodyczność). Dla procesu 2 średnia po czasie jednej realizacji to offset tego egzemplarza, a nie zero — pomiar jednego urządzenia nie zastąpi statystyki serii.

## Zadania

1. Czy proces $X(t) = A\cos(\omega_0t + \Theta)$ z losową amplitudą $A$ (o $E[A^2] = 2$) i niezależną fazą jednostajną jest WSS? Podaj $R_X(\tau)$.
2. Proces $X(t) = W\cdot t$, gdzie $W \sim \mathcal N(0, 1)$. Czy jest stacjonarny?
3. Szum biały o wariancji $\sigma^2$ uśredniasz przez $N$ niezależnych próbek. Jakie jest odchylenie standardowe średniej? Ile próbek trzeba, by było 100 razy mniejsze od $\sigma$?
4. Dlaczego do oceny rozrzutu offsetu wzmacniaczy w serii trzeba zmierzyć wiele egzemplarzy, a do oceny szumu jednego wzmacniacza wystarczy długi zapis?
5. Wartość średnia procesu WSS wynosi 2, a $R_X(0) = 13$. Ile wynosi wariancja?

<details>
<summary>Odpowiedzi</summary>

1. Tak: $R_X(\tau) = \tfrac{E[A^2]}{2}\cos\omega_0\tau = \cos\omega_0\tau$ (losowa faza czyni proces stacjonarnym; ergodyczny w autokorelacji jednak nie jest — każda realizacja ma własną amplitudę)
2. Nie — $E[X^2] = t^2$ zależy od czasu
3. $\sigma/\sqrt N$; $N = 10\,000$
4. Offset to w obrębie jednego egzemplarza stała (proces nieergodyczny względem serii) — średnia czasowa daje tylko jego wartość. Szum jednego wzmacniacza jest procesem ergodycznym, więc średnie czasowe zastępują średnie po zespole
5. $\sigma^2 = R_X(0) - \mu^2 = 13 - 4 = 9$
</details>

## Źródła

- [MIT 6.011 Signals, Systems and Inference](https://ocw.mit.edu/courses/6-011-signals-systems-and-inference-spring-2018/) — procesy losowe, stacjonarność
- [MIT 6.041 Probabilistic Systems Analysis](https://ocw.mit.edu/courses/6-041-probabilistic-systems-analysis-and-applied-probability-fall-2010/) — procesy losowe (Bernoulli, Poisson, Markov)
- [06.08 Sygnały losowe i szum](../06-sygnaly-i-systemy/08-sygnaly-losowe.md) — wprowadzenie
