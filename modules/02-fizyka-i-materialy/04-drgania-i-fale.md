# 02.04 — Drgania i fale

## Po co to jest

Obwód LC to oscylator harmoniczny — ten sam opis co masa na sprężynie. Fale opisują rozchodzenie się sygnałów w kablach, na ścieżkach PCB i w przestrzeni. Gdy długość fali staje się porównywalna z wymiarami układu, przestaje działać model o parametrach skupionych z teorii obwodów.

## Teoria w pigułce

### Oscylator harmoniczny

| Mechanika | Elektryczność (obwód LC) |
|---|---|
| Masa $m$ | Indukcyjność $L$ |
| Sztywność sprężyny $k$ | Odwrotność pojemności $1/C$ |
| Tarcie $b$ | Rezystancja $R$ |
| Położenie $x$ | Ładunek $q$ |
| $\omega_0 = \sqrt{k/m}$ | $\omega_0 = 1/\sqrt{LC}$ |

Energia przelewa się między postacią kinetyczną i potencjalną (między polem magnetycznym cewki i elektrycznym kondensatora). Tłumienie i rezonans — patrz [01.05](../01-teoria-obwodow/05-obwody-2-rzedu.md) i [01.07](../01-teoria-obwodow/07-rezonans-i-charakterystyki.md).

### Fale

Fala biegnąca: $y(x, t) = A\cos(\omega t - kx)$, liczba falowa $k = 2\pi/\lambda$.

$$v = \lambda f = \frac{\omega}{k}$$

Fala elektromagnetyczna w ośrodku: $v = \dfrac{c}{\sqrt{\varepsilon_r\mu_r}}$, $c \approx 3\cdot 10^8$ m/s.

| Ośrodek | $\varepsilon_r$ (typowo) | Prędkość | Opóźnienie |
|---|---|---|---|
| Próżnia / powietrze | 1 | $c$ | 3,3 ns/m |
| Kabel koncentryczny (PE) | 2,25 | $0{,}67c$ | 5 ns/m |
| Ścieżka na FR-4 (wewnętrzna) | ok. 4,3 | ok. $0{,}48c$ | ok. 6,9 ns/m |

**Fala stojąca** — suma dwóch fal biegnących w przeciwnych kierunkach (np. fali padającej i odbitej). Ma węzły i strzałki w stałych miejscach.

**Prędkość fazowa i grupowa:** gdy prędkość zależy od częstotliwości (dyspersja), impuls rozmywa się podczas propagacji — problem w światłowodach i długich liniach.

### Kiedy model skupiony przestaje działać

Reguła praktyczna: gdy wymiar układu przekracza ok. $\lambda/10$, trzeba uwzględnić propagację fali (linie transmisyjne, moduł 11). Dla sygnałów cyfrowych liczy się czas narastania zbocza $t_r$, a nie częstotliwość zegara: ścieżkę traktuje się jak linię, gdy jej opóźnienie przekracza ok. $t_r/6$.

## Przykład rozwiązany

Sygnał Wi-Fi 2,4 GHz.

1. W powietrzu: $\lambda = 3\cdot 10^8/2{,}4\cdot 10^9 = 12{,}5$ cm. Antena ćwierćfalowa ma ok. 3,1 cm.
2. W kablu z $\varepsilon_r = 2{,}25$: $v = 2\cdot 10^8$ m/s, $\lambda \approx 8{,}3$ cm.
3. Ścieżka 5 cm na płytce (ok. 0,4–0,6 $\lambda$) — zdecydowanie trzeba ją projektować jako linię transmisyjną o kontrolowanej impedancji.

## Typowe pułapki

- **Długość fali z prędkością $c$ w ośrodku** zamiast $c/\sqrt{\varepsilon_r}$.
- **Kryterium „linii” z częstotliwości zegara.** Zbocze 1 ns ma istotne składowe widma do ok. $0{,}35/t_r \approx 350$ MHz niezależnie od tego, czy zegar ma 1 MHz czy 100 MHz.

## Ćwiczenie komputerowe

```python
import numpy as np, matplotlib.pyplot as plt
x = np.linspace(0, 2, 400); t = 0.3
fwd = np.cos(2*np.pi*(t - x)); back = np.cos(2*np.pi*(t + x))
plt.plot(x, fwd, label="padająca"); plt.plot(x, back, label="odbita"); plt.plot(x, fwd + back, label="suma (fala stojąca)")
plt.legend(); plt.xlabel("x [λ]"); plt.show()
```

Zmieniaj `t` i obserwuj, że węzły fali stojącej się nie przesuwają. W Falstad otwórz przykłady linii transmisyjnych z [listy demonstracji](https://falstad.com/circuit/e-index.html).

## Zadania

1. Jaka jest długość fali 2,4 GHz w próżni i w kablu z $\varepsilon_r = 2{,}25$?
2. Jaka jest długość fali sieci 50 Hz w próżni? Czy instalację w budynku trzeba analizować jak linię transmisyjną?
3. Ile wynosi opóźnienie 3 m kabla koncentrycznego z polietylenem?
4. Zbocze sygnału ma czas narastania 1 ns, ścieżka na FR-4 ma 15 cm. Czy trzeba ją traktować jak linię transmisyjną?
5. Obwód LC ma $L = 100\ \mu$H i $C = 100$ pF. Jaka jest częstotliwość drgań własnych i jaka długość fali odpowiada tej częstotliwości w powietrzu?

<details>
<summary>Odpowiedzi</summary>

1. 12,5 cm i 8,3 cm
2. 6000 km — nie, układ jest wielokrotnie mniejszy niż $\lambda/10$
3. $3\cdot 5 = 15$ ns
4. Opóźnienie ≈ $0{,}15\cdot 6{,}9 \approx 1$ ns $> t_r/6 \approx 0{,}17$ ns — tak
5. $f_0 = \dfrac{1}{2\pi\sqrt{10^{-14}}} \approx 1{,}59$ MHz, $\lambda \approx 189$ m (pasmo fal średnich)
</details>

## Źródła

- [MIT 8.02 Physics II: Electricity and Magnetism](https://ocw.mit.edu/courses/8-02-physics-ii-electricity-and-magnetism-spring-2007/) — obwody LC, fale elektromagnetyczne
- [Electromagnetics, Vol. 1 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-1) — rozdziały wstępne o falach i liniach transmisyjnych
- [Falstad — demonstracje linii transmisyjnych](https://falstad.com/circuit/e-index.html)
