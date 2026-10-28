# 11.03 — Linie transmisyjne w stanie ustalonym

## Po co to jest

Kabel antenowy, ścieżka na płytce z sygnałem zegarowym, łącze Ethernet i przewód USB to linie transmisyjne. Gdy ich długość jest porównywalna z długością fali, impedancja widziana na wejściu zależy od długości linii, a niedopasowanie powoduje odbicia, straty mocy i zniekształcenia. Teoria linii to podstawowe narzędzie techniki w.cz.

## Teoria w pigułce

### Model o parametrach rozłożonych

Odcinek $dz$ linii: rezystancja $R'$, indukcyjność $L'$ (szeregowo), konduktancja $G'$, pojemność $C'$ (równolegle) — wszystko na jednostkę długości. Z praw Kirchhoffa dla odcinka wynikają **równania telegrafistów**:

$$\frac{\partial v}{\partial z} = -R'i - L'\frac{\partial i}{\partial t},\qquad \frac{\partial i}{\partial z} = -G'v - C'\frac{\partial v}{\partial t}$$

Rozwiązanie: fala padająca i odbita, $V(z) = V^+e^{-\gamma z} + V^-e^{\gamma z}$.

| Parametr | Wzór ogólny | Linia bezstratna |
|---|---|---|
| Stała propagacji | $\gamma = \sqrt{(R' + j\omega L')(G' + j\omega C')}$ | $j\beta$, $\beta = \omega\sqrt{L'C'}$ |
| **Impedancja charakterystyczna** | $Z_0 = \sqrt{\dfrac{R' + j\omega L'}{G' + j\omega C'}}$ | $\sqrt{L'/C'}$ — rzeczywista |
| Prędkość fazowa | $\omega/\beta$ | $1/\sqrt{L'C'} = c/\sqrt{\varepsilon_{eff}}$ |

$Z_0$ to stosunek napięcia do prądu **fali biegnącej** — nie rezystancja, którą zmierzy omomierz. Typowe: 50 Ω (w.cz.), 75 Ω (wideo, TV), 90–100 Ω różnicowo (USB, Ethernet, LVDS), 120 Ω (RS-485, CAN).

### Współczynnik odbicia i fala stojąca

$$\Gamma_L = \frac{Z_L - Z_0}{Z_L + Z_0}$$

| Obciążenie | $\Gamma_L$ |
|---|---|
| $Z_L = Z_0$ (dopasowanie) | 0 |
| Zwarcie | −1 |
| Rozwarcie | +1 |
| Czysto reaktancyjne | $|\Gamma| = 1$ |

| Miara niedopasowania | Wzór | Przykład $|\Gamma| = 1/3$ |
|---|---|---|
| **WFS (VSWR)** | $\dfrac{1 + |\Gamma|}{1 - |\Gamma|}$ | 2,0 |
| **Tłumienie odbiciowe (return loss)** | $-20\log|\Gamma|$ | 9,5 dB |
| Straty niedopasowania | $-10\log(1 - |\Gamma|^2)$ | 0,51 dB |

Interpretacja WFS: stosunek maksimum do minimum amplitudy napięcia wzdłuż linii. WFS 2 oznacza, że do obciążenia nie trafia 11% mocy — dla anteny nadawczej zwykle akceptowalne, dla wzmacniacza mocy bywa groźne.

### Impedancja wejściowa

Linia bezstratna o długości $l$ obciążona $Z_L$:

$$Z_{we} = Z_0\frac{Z_L + jZ_0\tan\beta l}{Z_0 + jZ_L\tan\beta l}$$

| Przypadek | Wynik |
|---|---|
| $l = \lambda/2$ | $Z_{we} = Z_L$ (impedancja powtarza się co $\lambda/2$) |
| **$l = \lambda/4$** | $Z_{we} = Z_0^2/Z_L$ — **transformator ćwierćfalowy**, zwarcie ↔ rozwarcie |
| Zwarta, $l < \lambda/4$ | $jZ_0\tan\beta l$ — indukcyjność |
| Rozwarta, $l < \lambda/4$ | $-jZ_0\cot\beta l$ — pojemność |
| Bardzo krótka ($\beta l \ll 1$) | Wracamy do teorii obwodów: rozwarta = $C'l$, zwarta = $L'l$ |

Odcinki zwarte i rozwarte (**stuby**) realizują na w.cz. indukcyjności, pojemności i obwody rezonansowe.

### Straty

Dla małych strat: $\alpha \approx \dfrac{R'}{2Z_0} + \dfrac{G'Z_0}{2}$ — część od przewodników (rośnie jak $\sqrt f$ przez naskórkowość) i od dielektryka (rośnie jak $f$). Kable podaje się w dB/100 m przy danej częstotliwości.

## Przykład rozwiązany

Linia 50 Ω o długości $\lambda/8$ obciążona rezystancją 100 Ω.

1. $\beta l = \pi/4$, $\tan\beta l = 1$.
2. $Z_{we} = 50\dfrac{100 + j50}{50 + j100} = 40 - j30\ \Omega$.
3. $\Gamma_L = 1/3$, WFS = 2 — wzdłuż linii zmienia się impedancja, ale $|\Gamma|$ i WFS są stałe (linia bezstratna).
4. **Dopasowanie transformatorem λ/4:** linia o $Z_0' = \sqrt{50\cdot 100} = 70{,}7\ \Omega$ i długości $\lambda/4$ zamienia 100 Ω na 50 Ω — ale tylko w wąskim paśmie wokół częstotliwości projektowej.

## Typowe pułapki

- **Długość elektryczna liczona dla prędkości w próżni** — w kablu z PE $v \approx 0{,}66c$, w mikropasku na FR-4 ok. $0{,}55c$.
- **Pomiar $Z_0$ omomierzem** — bez sensu; $Z_0$ mierzy się reflektometrem (TDR) albo z $C'$ i $L'$.
- **Kabel 75 Ω w torze 50 Ω** — WFS 1,5 na każdym przejściu.
- **Zapominanie, że WFS na wejściu długiego stratnego kabla wygląda lepiej niż przy obciążeniu** — fala odbita jest tłumiona dwukrotnie.

## Symulacja

Impedancja wejściowa linii λ/4 i transformatora ćwierćfalowego w LTspice (linia bezstratna `T` z opóźnieniem 2,5 ns = λ/4 dla 100 MHz):

```spice
* Transformator cwiercfalowy 100 Ohm -> 50 Ohm przy 100 MHz
V1 src 0 AC 1
Rs src in 50
T1 in 0 out 0 Td=2.5n Z0=70.7
RL out 0 100
.ac lin 401 1Meg 300Meg
* Zin = V(in)/I(Rs). Przy 100 MHz Zin = 50 Ohm, V(in) = 0.5 V.
* Sprawdz tez: Z0=50 i RL=0 (zwarcie) -> Zin = nieskonczonosc przy 100 MHz
.end
```

Wykreśl `V(in)/I(Rs)` (moduł) i znajdź pasmo, w którym WFS < 1,5.

## Ćwiczenie komputerowe

```python
import numpy as np
import matplotlib.pyplot as plt

def zin(ZL, Z0, bl):
    t = np.tan(bl)
    return Z0*(ZL + 1j*Z0*t)/(Z0 + 1j*ZL*t)

f0 = 100e6; f = np.linspace(10e6, 300e6, 1000)
bl = np.pi/2*f/f0                           # odcinek lambda/4 przy f0
Z = zin(100, 70.7, bl)
G = (Z - 50)/(Z + 50); vswr = (1 + abs(G))/(1 - abs(G))
i0 = np.argmin(abs(f - f0)); lo, hi = i0, i0            # ciągły przedział wokół f0
while lo > 0 and vswr[lo - 1] < 1.5: lo -= 1
while hi < len(f) - 1 and vswr[hi + 1] < 1.5: hi += 1
print(f"Zin(f0) = {zin(100, 70.7, np.pi/2):.2f} Ohm; pasmo WFS<1.5: {f[lo]/1e6:.0f}–{f[hi]/1e6:.0f} MHz")
print("lambda/8, 100 Ohm na 50 Ohm:", np.round(zin(100, 50, np.pi/4), 2))
plt.plot(f/1e6, vswr); plt.ylim(1, 3); plt.xlabel('f [MHz]'); plt.ylabel('WFS'); plt.grid(); plt.show()
```

## Zadania

1. $L' = 250$ nH/m, $C' = 100$ pF/m. Impedancja charakterystyczna i prędkość?
2. Linia 50 Ω obciążona 25 Ω: Γ, WFS, tłumienie odbiciowe, straty niedopasowania.
3. Impedancja wejściowa linii 50 Ω o długości $\lambda/4$ obciążonej $Z_L = 25 + j25\ \Omega$.
4. Zaprojektuj transformator λ/4 dopasowujący 300 Ω do 75 Ω przy 100 MHz w kablu o $v = 0{,}66c$ (impedancja i długość fizyczna).
5. Jaką długość musi mieć zwarty odcinek linii 50 Ω, aby przy 1 GHz zachowywał się jak indukcyjność 4 nH? ($v = 0{,}66c$)

<details>
<summary>Odpowiedzi</summary>

1. $Z_0 = 50\ \Omega$, $v = 2\cdot 10^8$ m/s
2. $\Gamma = -1/3$, WFS = 2, RL = 9,5 dB, ML = 0,51 dB
3. $Z_0^2/Z_L = 2500/(25 + j25) = 50 - j50\ \Omega$
4. $\sqrt{300\cdot 75} = 150\ \Omega$; $l = \lambda/4 = 0{,}66\cdot 3\ \text{m}/4 \approx 0{,}495$ m
5. $X = \omega L = 25{,}1\ \Omega$ → $\tan\beta l = 0{,}503$ → $\beta l = 0{,}466$ rad; $\lambda = 0{,}198$ m → $l \approx 14{,}7$ mm
</details>

## Źródła

- [Electromagnetics, Vol. 1 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-1) — rozdział 3 (linie transmisyjne) z zadaniami
- [Fundamentals of Microwave and RF Design — M. Steer](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-microwave-and-rf-design) — linie transmisyjne i ich parametry
- [MIT 6.013 Electromagnetics and Applications](https://ocw.mit.edu/courses/6-013-electromagnetics-and-applications-fall-2005/) — linie TEM
- [Lessons in Electric Circuits, tom II — rozdział Transmission Lines](https://www.allaboutcircuits.com/textbook/) — przystępne wprowadzenie
