# 11.04 — Wykres Smitha i dopasowanie impedancji

## Po co to jest

Wykres Smitha to mapa impedancji, na której przesuwanie się wzdłuż linii jest obrotem, a dodawanie elementów szeregowych i równoległych — ruchem po okręgach. Jest językiem analizatorów obwodów (VNA) i najszybszym sposobem projektowania dopasowań. Dopasowanie impedancji maksymalizuje przekazywaną moc, zmniejsza WFS i jest warunkiem poprawnej pracy wzmacniaczy w.cz.

## Teoria w pigułce

### Konstrukcja

Płaszczyzna zespolona współczynnika odbicia $\Gamma$ (koło jednostkowe), na której naniesiono linie stałej rezystancji i reaktancji **znormalizowanej** impedancji $z = Z/Z_0 = r + jx$:

$$\Gamma = \frac{z - 1}{z + 1}$$

- Środek: $z = 1$ (dopasowanie). Lewy skraj: zwarcie, prawy: rozwarcie.
- Górna połowa: reaktancja indukcyjna, dolna: pojemnościowa.
- Okręgi stałego $r$ przechodzą przez punkt rozwarcia; łuki stałego $x$ też.
- Okrąg o środku w środku wykresu = stały $|\Gamma|$ = stały WFS.

### Operacje na wykresie

| Operacja | Ruch na wykresie |
|---|---|
| Przesunięcie o $l$ w stronę generatora (linia bezstratna) | Obrót wokół środka **zgodnie z ruchem wskazówek zegara** o kąt $2\beta l$ (pełny obrót = $\lambda/2$) |
| Element szeregowy L lub C | Ruch po okręgu stałej rezystancji |
| Element równoległy L lub C | Ruch po okręgu stałej konduktancji (na wykresie admitancyjnym) |
| Zamiana impedancji na admitancję | Punkt symetryczny względem środka (obrót o 180°, czyli $\lambda/4$) |

### Metody dopasowania

| Metoda | Zasada | Pasmo |
|---|---|---|
| **Transformator λ/4** | $Z_0' = \sqrt{Z_{we}Z_L}$, wymaga rzeczywistego $Z_L$ (lub najpierw odcinka linii, który obróci impedancję na oś rzeczywistą) | Wąskie; szerzej — wielostopniowy |
| **Stub równoległy** | Odcinek linii o długości $d$ przenosi $y$ na okrąg $g = 1$; zwarty stub o długości $l$ znosi susceptancję | Wąskie |
| Stub podwójny | Dwa stuby w ustalonych miejscach — dla przestrajanych układów | Wąskie |
| **Obwody LC (L, π, T)** | Elementy skupione — w module [12.03](../12-technika-wcz-rf/03-dopasowanie-lc.md) | Zależne od dobroci $Q$ |

Najważniejsza intuicja: **im dalej od środka wykresu, tym trudniej dopasować w szerokim paśmie** (większa dobroć obciążenia).

## Przykład rozwiązany

**Dopasowanie stubem równoległym** $Z_L = 100 + j50\ \Omega$ do linii 50 Ω.

1. $z_L = 2 + j1$; $y_L = 1/z_L = 0\text{,}4 - j0\text{,}2$.
2. Obracamy się w stronę generatora po okręgu stałego $|\Gamma|$ ($|\Gamma_L| = 0\text{,}447$, WFS = 2,62) do przecięcia z okręgiem $g = 1$.
3. Pierwsze przecięcie: $y = 1 + j1$ po $d = 0\text{,}199\lambda$. Potrzebna susceptancja stubu: $-j1$ → zwarty stub: $-j\cot\beta l = -j1$ → $\beta l = \pi/4$, **$l = 0\text{,}125\lambda$**.
4. Drugie rozwiązanie: $y = 1 - j1$ po $d = 0\text{,}375\lambda$, stub $+j1$ → $l = 0\text{,}375\lambda$.
5. Wybieramy krótsze odcinki (pierwsze rozwiązanie) — mniejsze straty i szersze pasmo.

## Typowe pułapki

- **Obrót w złą stronę** — w stronę generatora zgodnie z ruchem wskazówek zegara, w stronę obciążenia przeciwnie.
- **Pomylenie wykresu impedancji z admitancyjnym** przy elementach równoległych.
- **Brak normalizacji** do $Z_0$ (albo normalizacja do innego $Z_0$ niż linia).
- **Kąt $\beta l$ zamiast $2\beta l$** — pełny obrót wykresu to $\lambda/2$, nie $\lambda$.
- **Dopasowanie na jednej częstotliwości uznane za szerokopasmowe.**

## Ćwiczenie komputerowe

Rysowanie wykresu Smitha i obliczenie dopasowania stubem:

```python
import numpy as np
import matplotlib.pyplot as plt

def smith_grid(ax):
    t = np.linspace(0, 2*np.pi, 400)
    ax.plot(np.cos(t), np.sin(t), 'k', lw=1)
    for r in [0.2, 0.5, 1, 2, 5]:                 # okręgi stałej rezystancji
        ax.plot(r/(1 + r) + np.cos(t)/(1 + r), np.sin(t)/(1 + r), color='0.7', lw=0.6)
    for x in [0.2, 0.5, 1, 2, 5]:                 # łuki stałej reaktancji
        for s in (1, -1):
            z = 1e-9 + np.linspace(0, 50, 2000) + 1j*s*x
            G = (z - 1)/(z + 1); ax.plot(G.real, G.imag, color='0.7', lw=0.6)
    ax.axhline(0, color='0.7', lw=0.6); ax.set_aspect('equal'); ax.axis('off')

Z0, ZL = 50, 100 + 50j
zin = lambda ZL, bl: Z0*(ZL + 1j*Z0*np.tan(bl))/(Z0 + 1j*ZL*np.tan(bl))
d = np.linspace(0, 0.5, 20001)
y = Z0/zin(ZL, 2*np.pi*d)
i = np.argmax(abs(y.real - 1) < 2e-4)            # pierwsze przecięcie z g = 1
b = y[i].imag
l = (np.arctan(1/b)/(2*np.pi)) % 0.5             # zwarty stub: y_stub = -j cot(beta l) = -j b
print(f"d = {d[i]:.4f} lambda, y = {y[i]:.3f}, długość stubu l = {l:.4f} lambda")

fig, ax = plt.subplots(); smith_grid(ax)
Gpath = (zin(ZL, 2*np.pi*d[:i+1])/Z0 - 1)/(zin(ZL, 2*np.pi*d[:i+1])/Z0 + 1)
ax.plot(Gpath.real, Gpath.imag, 'b', lw=2, label='odcinek linii d')
ax.plot(Gpath.real[0], Gpath.imag[0], 'ro', label='Z_L'); ax.plot(0, 0, 'g*', ms=12, label='dopasowanie')
ax.legend(loc='lower left'); plt.show()
```

## Zadania

1. Zaznacz na wykresie Smitha (lub policz Γ): $Z = 50$, $25$, $100$, $50 + j50$, $50 - j50$, $0$, $\infty$ przy $Z_0 = 50\ \Omega$.
2. Punkt $z = 0\text{,}5$ przesuwamy o $\lambda/4$ w stronę generatora. Gdzie się znajdzie?
3. Dopasuj $Z_L = 100 + j50\ \Omega$ do 50 Ω stubem równoległym (rozwiązanie z przykładu) — sprawdź obliczeniem, że admitancja w punkcie dołączenia stubu wynosi $1/50$ S.
4. Dlaczego zwarty stub jest zwykle lepszy od rozwartego w technice mikropaskowej i koncentrycznej?
5. Obciążenie $Z_L = 10\ \Omega$ dopasowujemy do 50 Ω transformatorem λ/4. Jaka impedancja odcinka? Dlaczego pasmo będzie węższe niż dla $Z_L = 25\ \Omega$?

<details>
<summary>Odpowiedzi</summary>

1. $\Gamma$: 0; −1/3; 1/3; $0\text{,}2 + j0\text{,}4$; $0\text{,}2 - j0\text{,}4$; −1; +1
2. $z = 1/0\text{,}5 = 2$ (λ/4 odwraca impedancję znormalizowaną)
3. W odległości $d$ admitancja znormalizowana $1 + j1$, stub dodaje $-j1$ → $y = 1$, czyli $Y = 1/50$ S
4. Rozwarty koniec promieniuje i ma pojemność krańcową (efektywnie dłuższy), w kablu rozwarcie jest trudne do zrealizowania dokładnie; zwarty stub daje też ścieżkę DC do masy (np. do polaryzacji). W mikropasku rozwarte stuby bywają jednak wygodniejsze — nie wymagają przelotki do masy
5. $\sqrt{500} \approx 22\text{,}4\ \Omega$; większy stosunek transformacji = większa dobroć i szybsza zmiana impedancji z częstotliwością
</details>

## Źródła

- [Electromagnetics, Vol. 1 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-1) — wykres Smitha, dopasowanie ćwierćfalowe i stubem
- [Fundamentals of Microwave and RF Design — M. Steer](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-microwave-and-rf-design) — dopasowanie impedancji
- [scikit-rf — dokumentacja](https://scikit-rf.readthedocs.io) — biblioteka Pythona z wykresem Smitha i obsługą plików Touchstone
