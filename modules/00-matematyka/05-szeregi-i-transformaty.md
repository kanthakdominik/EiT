# 00.05 — Szeregi Fouriera i transformata Laplace'a

## Po co to jest

- **Szereg Fouriera** rozkłada sygnał okresowy na sinusoidy. Dzięki temu obwód liniowy można analizować dla każdej harmonicznej osobno i zsumować wyniki.
- **Transformata Laplace'a** zamienia równania różniczkowe w równania algebraiczne. W analizie obwodów (metoda operatorowa) kondensator staje się impedancją $\dfrac{1}{sC}$, cewka — $sL$, a warunki początkowe — dodatkowymi źródłami.

Ten temat to tylko narzędzie matematyczne. Pełne zastosowanie: [01.08 Metoda operatorowa](../01-teoria-obwodow/08-laplace-w-obwodach.md) i moduł [06 Sygnały i systemy](../06-sygnaly-i-systemy/).

## Teoria w pigułce

### Szereg Fouriera

Sygnał okresowy o okresie $T$ ($\omega_0 = 2\pi/T$):

$$f(t) = a_0 + \sum_{k=1}^{\infty}\left[a_k\cos(k\omega_0 t) + b_k\sin(k\omega_0 t)\right]$$

$$a_0 = \frac{1}{T}\int_0^T f\,dt, \quad a_k = \frac{2}{T}\int_0^T f\cos(k\omega_0 t)\,dt, \quad b_k = \frac{2}{T}\int_0^T f\sin(k\omega_0 t)\,dt$$

- Funkcja parzysta → tylko $a_k$ (kosinusy). Nieparzysta → tylko $b_k$ (sinusy).
- Symetria półokresowa → tylko harmoniczne nieparzyste.

Fala prostokątna ±$A$ (nieparzysta, z symetrią półokresową):

$$f(t) = \frac{4A}{\pi}\left(\sin\omega_0 t + \frac{1}{3}\sin 3\omega_0 t + \frac{1}{5}\sin 5\omega_0 t + \dots\right)$$

### Transformata Laplace'a

$$F(s) = \mathcal{L}\{f(t)\} = \int_0^\infty f(t)e^{-st}\,dt$$

| $f(t)$ | $F(s)$ |
|---|---|
| $\delta(t)$ | $1$ |
| $\mathbb{1}(t)$ (skok) | $\dfrac{1}{s}$ |
| $t$ | $\dfrac{1}{s^2}$ |
| $e^{-at}$ | $\dfrac{1}{s + a}$ |
| $\sin\omega t$ | $\dfrac{\omega}{s^2 + \omega^2}$ |
| $\cos\omega t$ | $\dfrac{s}{s^2 + \omega^2}$ |
| $e^{-at}\sin\omega t$ | $\dfrac{\omega}{(s + a)^2 + \omega^2}$ |
| $e^{-at}\cos\omega t$ | $\dfrac{s + a}{(s + a)^2 + \omega^2}$ |

| Własność | Wzór |
|---|---|
| Pochodna | $\mathcal{L}\{f'\} = sF(s) - f(0^-)$ |
| Druga pochodna | $\mathcal{L}\{f''\} = s^2F(s) - sf(0^-) - f'(0^-)$ |
| Całka | $\mathcal{L}\left\{\int_0^t f\,d\tau\right\} = \dfrac{F(s)}{s}$ |
| Przesunięcie w czasie | $\mathcal{L}\{f(t - t_0)\mathbb{1}(t - t_0)\} = e^{-st_0}F(s)$ |
| Wartość końcowa | $\lim_{t\to\infty} f(t) = \lim_{s\to 0} sF(s)$ (gdy granica istnieje) |
| Wartość początkowa | $f(0^+) = \lim_{s\to\infty} sF(s)$ |

**Transformata odwrotna** — rozkład na ułamki proste i odczyt z tabeli.

## Przykład rozwiązany

Wyznacz $\mathcal{L}^{-1}\left\{\dfrac{s + 3}{(s + 1)(s + 2)}\right\}$.

1. $\dfrac{s + 3}{(s + 1)(s + 2)} = \dfrac{A}{s + 1} + \dfrac{B}{s + 2}$.
2. Metoda „zasłaniania”: $A = \left.\dfrac{s + 3}{s + 2}\right|_{s = -1} = \dfrac{2}{1} = 2$; $B = \left.\dfrac{s + 3}{s + 1}\right|_{s = -2} = \dfrac{1}{-1} = -1$.
3. Wynik: $f(t) = 2e^{-t} - e^{-2t}$ dla $t \geq 0$.

## Typowe pułapki

- **Zapominanie o warunkach początkowych** we wzorze na transformatę pochodnej.
- **Twierdzenie o wartości końcowej stosowane do układu niestabilnego** albo oscylacyjnego — daje fałszywy wynik. Sprawdź najpierw, czy bieguny $sF(s)$ leżą w lewej półpłaszczyźnie.
- **Bieguny zespolone rozkładane na siłę na ułamki z liczbami zespolonymi.** Prościej uzupełnić do pełnego kwadratu i skorzystać z par $e^{-at}\sin\omega t$, $e^{-at}\cos\omega t$.

## Symulacja / ćwiczenie komputerowe

```python
import numpy as np
import matplotlib.pyplot as plt

t = np.linspace(0, 2, 2000)
f = np.zeros_like(t)
for k in range(1, 40, 2):
    f += 4/np.pi * np.sin(2*np.pi*k*t) / k
plt.plot(t, f); plt.grid(); plt.title("Fala prostokątna — 20 harmonicznych"); plt.show()
```

Zwróć uwagę na przerosty przy skokach (zjawisko Gibbsa) — nie znikają przy zwiększaniu liczby harmonicznych, tylko się zwężają.

```python
import sympy as sp
s, t = sp.symbols('s t')
print(sp.apart((s + 3)/((s + 1)*(s + 2))))
print(sp.inverse_laplace_transform((s + 3)/((s + 1)*(s + 2)), s, t))
```

## Zadania

1. Wyznacz $\mathcal{L}\{3e^{-4t}\}$.
2. Wyznacz $\mathcal{L}^{-1}\left\{\dfrac{1}{s(s + 2)}\right\}$.
3. Rozwiąż metodą Laplace'a: $\dot{y} + 2y = 0$, $y(0) = 3$.
4. Wyznacz wartość końcową $f(t)$, jeśli $F(s) = \dfrac{10}{s(s + 5)}$.
5. Wyznacz $\mathcal{L}^{-1}\left\{\dfrac{1}{s^2 + 2s + 5}\right\}$.
6. Fala prostokątna ma amplitudę ±1 V. Jaka jest amplituda składowej podstawowej i trzeciej harmonicznej?

<details>
<summary>Odpowiedzi</summary>

1. $\dfrac{3}{s + 4}$
2. $\dfrac{0{,}5}{s} - \dfrac{0{,}5}{s + 2} \Rightarrow 0{,}5\left(1 - e^{-2t}\right)$
3. $sY - 3 + 2Y = 0 \Rightarrow Y = \dfrac{3}{s + 2} \Rightarrow y = 3e^{-2t}$
4. $\lim_{s\to 0} sF(s) = 10/5 = 2$
5. $s^2 + 2s + 5 = (s + 1)^2 + 4 \Rightarrow f(t) = \tfrac{1}{2}e^{-t}\sin 2t$
6. $4/\pi \approx 1{,}273$ V oraz $4/(3\pi) \approx 0{,}424$ V
</details>

## Źródła

- [Paul's Online Math Notes — Laplace Transforms](https://tutorial.math.lamar.edu/Classes/DE/LaplaceIntro.aspx) — definicja, tabele, transformata odwrotna
- [Paul's Online Math Notes — Solving IVPs with Laplace Transforms](https://tutorial.math.lamar.edu/Classes/DE/IVPWithLaplace.aspx)
- [Paul's Online Math Notes — zadania z Laplace'a](https://tutorial.math.lamar.edu/Problems/DE/LaplaceIntro.aspx)
- [MIT 6.003 Signals and Systems](https://ocw.mit.edu/courses/6-003-signals-and-systems-fall-2011/) — szereg Fouriera i Laplace w kontekście sygnałów
- [MIT RES.6-007 Signals and Systems (Oppenheim)](https://ocw.mit.edu/courses/res-6-007-signals-and-systems-spring-2011/)
