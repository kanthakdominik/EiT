# 13.02 — Modulacje analogowe: AM i FM

## Po co to jest

Modulacje analogowe to wciąż radiofonia, łączność lotnicza, krótkofalarstwo i krótkofalówki — a przede wszystkim najlepsza szkoła pojęć: przesunięcie widma, wstęgi boczne, kompromis pasmo–moc–odporność na szum. Te same zasady pracują w modulatorach I/Q modulacji cyfrowych.

## Teoria w pigułce

### Modulacje amplitudy

Sygnał modulujący $m(t)$ (znormalizowany, $|m| \le 1$), nośna $f_c$:

| Modulacja | Sygnał | Pasmo | Uwagi |
|---|---|---|---|
| **AM (DSB z nośną)** | $A_c[1 + \mu m(t)]\cos\omega_ct$ | $2W$ | Detekcja obwiedni (dioda + RC); sprawność $\dfrac{\mu^2\overline{m^2}}{1 + \mu^2\overline{m^2}}$ — dla tonu i $\mu = 1$: 33% |
| DSB-SC | $A_cm(t)\cos\omega_ct$ | $2W$ | Bez nośnej, wymaga detekcji synchronicznej (odtworzenia nośnej) |
| **SSB** | jedna wstęga: $m(t)\cos\omega_ct \mp \hat m(t)\sin\omega_ct$ ($\hat m$ — transformata Hilberta) | $W$ | Połowa pasma, cała moc w informacji; krótkofalarstwo, HF |
| VSB | wstęga + szczątek drugiej | $> W$ | Dawna telewizja analogowa |

$W$ — najwyższa częstotliwość sygnału modulującego, $\mu$ — głębokość modulacji (przemodulowanie $\mu > 1$ zniekształca obwiednię).

**Widmo AM z tonem** $f_m$: nośna i dwa prążki $f_c \pm f_m$ o amplitudach $\mu A_c/2$. Moc: $P = P_c(1 + \mu^2/2)$.

### Modulacje kąta

$$s(t) = A_c\cos\left(\omega_ct + 2\pi k_f\int m\,dt\right)\ \text{(FM)},\qquad A_c\cos(\omega_ct + k_pm(t))\ \text{(PM)}$$

- **Dewiacja częstotliwości** $\Delta f = k_f\max|m|$, **wskaźnik modulacji** $\beta = \Delta f/W$.
- Stała obwiednia — odporność na nieliniowość wzmacniaczy (wzmacniacze klasy C).
- Widmo FM z tonem: prążki $f_c \pm nf_m$ o amplitudach $J_n(\beta)$ (funkcje Bessela); dla $\beta \approx 2{,}405$ nośna znika.
- **Reguła Carsona** (pasmo zawierające ok. 98% mocy): $B \approx 2(\Delta f + W) = 2W(\beta + 1)$.
- FM wąskopasmowa ($\beta \ll 1$): pasmo ≈ $2W$ jak AM; szerokopasmowa: pasmo większe, ale lepszy SNR po demodulacji (wzrost ok. $3\beta^2$ powyżej progu) — wymiana pasma na jakość.
- **Efekt progowy:** poniżej pewnego SNR na wejściu jakość FM gwałtownie się załamuje.
- **Preemfaza/deemfaza** (radiofonia: 50 µs w Europie, 75 µs w USA) — szum demodulatora FM rośnie z częstotliwością, więc wyższe częstotliwości sygnału się podbija przed modulacją.

Demodulacja FM: dyskryminator (różniczkowanie + detektor obwiedni), pętla PLL, cyfrowo — $\Delta\arg$ kolejnych próbek I/Q.

### Przykłady systemów

| System | Modulacja | Parametry |
|---|---|---|
| Radiofonia AM (LW/MW/SW) | AM | Kanały 9 kHz (Europa) / 10 kHz (Ameryka) |
| Radiofonia FM (87,5–108 MHz) | FM, $\Delta f$ = 75 kHz | Stereo: sygnał multipleksowy z podnośną 38 kHz (DSB-SC) i pilotem 19 kHz, RDS na 57 kHz |
| Krótkofalówki, łączność służbowa | NBFM, $\Delta f$ = 2,5–5 kHz | Kanały 12,5/25 kHz |
| Łączność lotnicza VHF | AM | Kanały 8,33/25 kHz |
| Krótkofalarstwo HF | SSB | ok. 2,4–3 kHz |

## Przykład rozwiązany

**AM:** nośna 100 W, ton, $\mu = 0{,}5$. Moc całkowita $100(1 + 0{,}125) = 112{,}5$ W, w wstęgach 12,5 W (11%). Przy $\mu = 1$: 150 W, w wstęgach 50 W (33%). SSB z tymi samymi 50 W „informacji” zajmuje połowę pasma i nie marnuje mocy na nośną.

**FM radiofonia:** $\Delta f = 75$ kHz, $W = 15$ kHz → $\beta = 5$, $B \approx 2(75 + 15) = 180$ kHz (kanały co 200 kHz, z wypełnionym sygnałem stereo pasmo jest większe). **NBFM:** $\Delta f = 2{,}5$ kHz, $W = 3$ kHz → 11 kHz — mieści się w kanale 12,5 kHz.

## Typowe pułapki

- **Mylenie dewiacji z pasmem** — pasmo FM jest większe niż $2\Delta f$.
- **Przemodulowanie AM** — obwiednia przechodzi przez zero, detektor obwiedni zniekształca.
- **Detekcja synchroniczna z błędem fazy** — w DSB-SC błąd $\varphi$ daje tłumienie $\cos\varphi$, przy 90° sygnał znika.
- **Reguła Carsona traktowana jako dokładna** — to przybliżenie (98% mocy); przy ostrych wymaganiach widmowych liczy się prążki Bessela.

## Ćwiczenie komputerowe

Modulacja i demodulacja AM i FM w Pythonie, widma i reguła Carsona:

```python
import numpy as np
from scipy import signal
from scipy.special import jv
import matplotlib.pyplot as plt

fs = 1e6; t = np.arange(50_000)/fs                   # dokładnie 50 okresów tonu 1 kHz
fm, fc = 1e3, 100e3
m = np.cos(2*np.pi*fm*t)

am = (1 + 0.5*m)*np.cos(2*np.pi*fc*t)
env = np.abs(signal.hilbert(am))                          # detektor obwiedni
print(f"AM: odtworzona amplituda modulacji = {(env.max() - env.min())/(env.max() + env.min()):.3f} (oczekiwane 0.5)")

df = 5e3; beta = df/fm
fmsig = np.cos(2*np.pi*fc*t + 2*np.pi*df*np.cumsum(m)/fs)
z = signal.hilbert(fmsig)*np.exp(-2j*np.pi*fc*t)           # przesunięcie do pasma podstawowego
inst_f = np.diff(np.unwrap(np.angle(z)))*fs/(2*np.pi)      # demodulator: pochodna fazy
print(f"FM: zmierzona dewiacja = {np.max(inst_f[1000:-1000]):.0f} Hz (oczekiwane {df:.0f} Hz)")

f, P = signal.periodogram(fmsig, fs, window='boxcar')    # sygnał okresowy w oknie — bez przecieku
band = np.abs(f - fc) <= df + fm
print(f"beta = {beta}: moc w paśmie Carsona = {P[band].sum()/P.sum()*100:.1f}%")
print("teoria — prążki J_n(beta)^2 dla |n| <= beta+1:", f"{sum(jv(n, beta)**2 for n in range(-6, 7))*100:.1f}%")
plt.semilogy(f/1e3, P); plt.xlim(70, 130); plt.ylim(1e-12, 1); plt.xlabel('f [kHz]'); plt.grid(); plt.show()
```

## Zadania

1. Nadajnik AM 1 kW (nośna), $\mu = 0{,}8$. Moc całkowita i moc w wstęgach bocznych.
2. Jakie pasmo zajmuje AM, DSB-SC i SSB dla sygnału mowy 300–3400 Hz?
3. FM: $\Delta f = 5$ kHz, $W = 3$ kHz. Wskaźnik modulacji i pasmo z reguły Carsona.
4. Przy jakim wskaźniku modulacji FM z tonem nośna znika? Jak wykorzystuje się to do kalibracji dewiacji?
5. Dlaczego radiofonia FM daje lepszą jakość niż AM, choć zajmuje znacznie szersze pasmo?

<details>
<summary>Odpowiedzi</summary>

1. $1000(1 + 0{,}32) = 1320$ W; wstęgi 320 W
2. AM i DSB-SC: 6,8 kHz; SSB: 3,1 kHz
3. $\beta \approx 1{,}67$; $B \approx 16$ kHz
4. $\beta \approx 2{,}405$ (pierwsze zero $J_0$); zmieniając dewiację przy znanym $f_m$ szuka się zaniku nośnej na analizatorze widma
5. FM szerokopasmowa wymienia pasmo na SNR po demodulacji (wzrost proporcjonalny do $\beta^2$), jest odporna na zakłócenia amplitudowe (ogranicznik), a wyższa częstotliwość nośnej i preemfaza dodatkowo poprawiają jakość
</details>

## Źródła

- [MIT RES.6-007 Signals and Systems](https://ocw.mit.edu/courses/res-6-007-signals-and-systems-spring-2011/) — wykłady o modulacji amplitudy i częstotliwości
- [Fundamentals of Electrical Engineering I — D. Johnson](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-electrical-engineering-1) — modulacja analogowa
- [Modular Electronics Learning (ModEL) Project](https://ibiblio.org/kuphaldt/socratic/model/) — moduły o AM i FM od strony układów
- [PySDR](https://pysdr.org) — demodulacja FM z próbek I/Q
