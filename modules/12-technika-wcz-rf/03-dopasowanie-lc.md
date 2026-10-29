# 12.03 — Dopasowanie impedancji obwodami LC

## Po co to jest

Wejście LNA, wyjście wzmacniacza mocy, antena PCB, wejście mieszacza — prawie nic w torze radiowym nie ma naturalnie 50 Ω. Obwody dopasowujące z dwóch–trzech elementów LC przekształcają impedancję tak, by przekazać maksimum mocy albo uzyskać optymalny współczynnik szumów. To najczęstsze zadanie projektowe w.cz. poniżej kilku GHz, gdzie linie (stuby) byłyby za długie.

## Teoria w pigułce

### Obwód L

Dwa elementy: jeden równolegle do **większej** rezystancji, drugi szeregowo z mniejszą. Dobroć obwodu jest wyznaczona przez stosunek rezystancji:

$$Q = \sqrt{\frac{R_{duża}}{R_{mała}} - 1},\qquad X_{równ} = \frac{R_{duża}}{Q},\qquad X_{szer} = Q\,R_{mała}$$

Cztery warianty: dolnoprzepustowy (L szeregowo, C równolegle — tłumi harmoniczne, przenosi DC), górnoprzepustowy (C szeregowo, L równolegle — blokuje DC) i dwa „odwrócone”.

**Obciążenie zespolone:** najpierw „wchłonięcie” reaktancji obciążenia (dodanie lub odjęcie jej od elementu obwodu) albo kompensacja, potem dopasowanie części rzeczywistej.

### Obwody π i T

Trzy elementy pozwalają **wybrać dobroć** niezależnie od stosunku rezystancji (musi być większa niż dla obwodu L): mniejsze pasmo, ale lepsza filtracja harmonicznych (π w wyjściach nadajników), albo realizowalne wartości elementów. Projektuje się je jako dwa obwody L połączone przez rezystancję wirtualną.

### Pasmo

Szacunkowo $B \approx f_0/Q_L$, przy czym dla obwodu L zakończonego obustronnie dobroć obciążona jest mniejsza od $Q$ projektu (w przybliżeniu $Q_L \approx Q/2$). **Szersze pasmo:** kilka sekcji L o mniejszych stosunkach transformacji (np. 200 → 100 → 50 Ω).

### Na wykresie Smitha

Element szeregowy — ruch po okręgu stałej rezystancji, równoległy — po okręgu stałej konduktancji ([11.04](../11-pole-em-linie-anteny/04-wykres-smitha-i-dopasowanie.md)). Projekt to znalezienie drogi z punktu obciążenia do środka wykresu dwoma–trzema takimi łukami.

### Dopasowanie a straty

Elementy o skończonej dobroci (cewki!) tracą moc. Strata rośnie ze stosunkiem $Q_{obwodu}/Q_{elementu}$: dla dopasowań o dużej dobroci (np. bardzo mała impedancja wejściowa tranzystora mocy) straty sięgają dziesiątych części dB do dB.

## Przykład rozwiązany

Dopasowanie $R_L = 200\ \Omega$ do 50 Ω przy 100 MHz, wariant dolnoprzepustowy.

1. $Q = \sqrt{200/50 - 1} = 1{,}732$.
2. Element równoległy przy 200 Ω: $X_C = 200/1{,}732 = 115{,}5\ \Omega$ → $C = 1/(2\pi\cdot 10^8\cdot 115{,}5) \approx 13{,}8$ pF.
3. Element szeregowy: $X_L = 1{,}732\cdot 50 = 86{,}6\ \Omega$ → $L = 86{,}6/(2\pi\cdot 10^8) \approx 138$ nH.
4. Sprawdzenie: 200 Ω ‖ $(-j115{,}5)$ = $50 - j86{,}6$; dodanie $+j86{,}6$ daje 50 Ω.
5. Pasmo WFS < 2 (z symulacji poniżej): ok. 73–121 MHz, czyli ok. 49 MHz.

## Typowe pułapki

- **Element równoległy po niewłaściwej stronie** (przy mniejszej rezystancji) — obwód L nie zadziała.
- **Wartości obliczone, ale niedostępne lub poniżej SRF** — sprawdź szereg wartości i elementy pasożytnicze ([12.01](01-elementy-bierne-wcz.md)).
- **Dopasowanie do $Z_{we}$ urządzenia zamiast do sprzężenia zespolonego** — dla maksymalnej mocy źródło musi „widzieć” $Z^*$.
- **Pad i ścieżka pominięte** — kilka mm ścieżki przy 2,4 GHz to istotna indukcyjność; stosuje się miejsca na elementy (footprint π) do strojenia na gotowej płytce.
- **LNA dopasowany na maksimum wzmocnienia zamiast minimum szumów** — to różne impedancje źródła ([12.06](06-wzmacniacze-wcz.md)).

## Symulacja

```spice
* Dopasowanie L: 200 Ohm -> 50 Ohm przy 100 MHz
V1 src 0 AC 1
Rs src in 50
L1 in mid 137.8n
C1 mid 0 13.78p
RL mid 0 200
.ac lin 1001 20Meg 300Meg
* Przy 100 MHz V(in) = 0.5 V (dopasowanie). Moc w RL = V(mid)^2/200.
* Zamien na wariant gornoprzepustowy: C szeregowo 18.4p, L rownolegle 184n.
.end
```

## Ćwiczenie komputerowe

```python
import numpy as np
import matplotlib.pyplot as plt

def l_match(Rhigh, Rlow, f0):
    Q = np.sqrt(Rhigh/Rlow - 1); w0 = 2*np.pi*f0
    return Q, (Q*Rlow)/w0, 1/(w0*Rhigh/Q)                  # Q, L szeregowa, C równoległa

Q, L, C = l_match(200, 50, 100e6)
print(f"Q = {Q:.3f}, L = {L*1e9:.1f} nH, C = {C*1e12:.2f} pF")

f = np.linspace(20e6, 300e6, 20001); w = 2*np.pi*f
Zin = 1j*w*L + 1/(1/200 + 1j*w*C)
G = (Zin - 50)/(Zin + 50); vswr = (1 + abs(G))/(1 - abs(G))
i0 = np.argmin(abs(f - 100e6)); lo, hi = i0, i0
while vswr[lo - 1] < 2: lo -= 1
while vswr[hi + 1] < 2: hi += 1
print(f"WFS < 2: {f[lo]/1e6:.1f}–{f[hi]/1e6:.1f} MHz")

# wersja dwusekcyjna 200 -> 100 -> 50 (szersze pasmo)
Q1, L1, C1 = l_match(200, 100, 100e6); Q2, L2, C2 = l_match(100, 50, 100e6)
Z1 = 1j*w*L1 + 1/(1/200 + 1j*w*C1)                           # 200 -> ok. 100
Zin2 = 1j*w*L2 + 1/(1/Z1 + 1j*w*C2)
G2 = (Zin2 - 50)/(Zin2 + 50); vswr2 = (1 + abs(G2))/(1 - abs(G2))
lo, hi = i0, i0
while vswr2[lo - 1] < 2: lo -= 1
while hi < len(f) - 1 and vswr2[hi + 1] < 2: hi += 1
print(f"dwie sekcje: WFS < 2: {f[lo]/1e6:.1f}–{f[hi]/1e6:.1f} MHz")
plt.plot(f/1e6, vswr, label='1 sekcja'); plt.plot(f/1e6, vswr2, label='2 sekcje')
plt.ylim(1, 4); plt.xlabel('f [MHz]'); plt.ylabel('WFS'); plt.legend(); plt.grid(); plt.show()
```

## Zadania

1. Dopasuj 10 Ω do 50 Ω przy 433 MHz obwodem L dolnoprzepustowym.
2. Obciążenie $Z_L = 25 - j15\ \Omega$ dopasuj do 50 Ω przy 100 MHz (wskazówka: najpierw skompensuj reaktancję albo wchłoń ją w element szeregowy).
3. Dlaczego w wyjściu nadajnika stosuje się obwód π, a nie L?
4. Dopasowanie o $Q = 5$ zbudowano z cewką o $Q_L = 40$. Oszacuj straty (dla małych strat $\approx 10\log(1 + Q/Q_L)$ dB).
5. Pasmo obwodu L z przykładu to ok. 49 MHz. Jak je poszerzyć?

<details>
<summary>Odpowiedzi</summary>

1. $Q = 2$; C równolegle przy 50 Ω: $X = 25\ \Omega$ → 14,7 pF; L szeregowo przy 10 Ω: $X = 20\ \Omega$ → 7,35 nH
2. Np. szeregowa L +15 Ω kompensuje reaktancję → 25 Ω; dalej obwód L 25 → 50: $Q = 1$, szeregowa $X = 25\ \Omega$ (łącznie z kompensacją: $L$ o $X = 40\ \Omega$ → 63,7 nH), C równolegle przy 50 Ω: $X = 50\ \Omega$ → 31,8 pF
3. Możliwość wyboru większej dobroci → lepsze tłumienie harmonicznych (wymagania widmowe) i dostępne wartości elementów
4. ≈ $10\log(1{,}125) \approx 0{,}5$ dB
5. Dwie (lub więcej) sekcje o mniejszych stosunkach transformacji (np. 200 → 100 → 50), linie o stopniowo zmiennej impedancji
</details>

## Źródła

- [Fundamentals of Microwave and RF Design — M. Steer](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-microwave-and-rf-design) — dopasowanie elementami skupionymi, obwody L, π, T
- [Keysight AN 154 — S-Parameter Design](https://www.keysight.com/be/en/assets/7018-06743/application-notes/5952-1087.pdf) — dopasowanie wejścia i wyjścia wzmacniacza
- [scikit-rf](https://scikit-rf.readthedocs.io) — symulacja dopasowań i wykres Smitha
