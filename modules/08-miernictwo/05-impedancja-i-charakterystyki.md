# 08.05 — Pomiary impedancji i charakterystyk częstotliwościowych

## Po co to jest

Projektując filtr, wzmacniacz czy zasilacz, trzeba sprawdzić, czy jego charakterystyka zgadza się z projektem. Pomiar impedancji odpowiada na pytania: jaka jest rzeczywista pojemność kondensatora pod napięciem, ile wynosi ESR, gdzie wypada rezonans własny cewki.

## Teoria w pigułce

### Mostki

**Mostek Wheatstone'a** — równowaga, gdy $\dfrac{R_1}{R_2} = \dfrac{R_3}{R_4}$. Pomiar w stanie równowagi nie zależy od dokładności źródła ani detektora. W stanie niezrównoważonym — czujniki (tensometry, termometry). Mostki AC (Maxwella, Wiena, Scheringa) mierzą pojemności i indukcyjności.

**Tensometr w ćwierćmostku** (mała zmiana $\Delta R/R = \text{GF}\cdot\varepsilon$):

$$U_{wy} \approx \frac{U_{zas}}{4}\cdot\text{GF}\cdot\varepsilon$$

### Mierniki LCR

Mierzą napięcie i prąd (wektorowo) na zadanej częstotliwości: $\underline{Z} = \underline{U}/\underline{I}$. Podają $C$, $L$, $R$, ESR, $D$ (współczynnik strat), $Q$ w modelu szeregowym lub równoległym. **Częstotliwość i napięcie pomiaru zmieniają wynik** (kondensatory ceramiczne, rdzenie ferrytowe). Kalibracja otwarcia i zwarcia usuwa wpływ przewodów.

### Charakterystyka częstotliwościowa

| Metoda | Zasada | Uwagi |
|---|---|---|
| **Punkt po punkcie** | Sinus z generatora, amplituda i faza oscyloskopem | Najprostsza, wolna |
| Przemiatanie (sweep) | Generator przemiata, oscyloskop/analizator rejestruje | Szybka, wymaga synchronizacji |
| Odpowiedź skokowa + FFT | $H = \text{FFT}(dy/dt)$ lub $\text{FFT}(y)/\text{FFT}(x)$ | Szybka, gorszy stosunek sygnału do szumu |
| Szum / chirp / MLS + FFT | Pobudzenie szerokopasmowe | Audio, akustyka |
| **Analizator obwodów (VNA)** | Pomiar parametrów S (moduł [12](../12-technika-wcz-rf/)) | RF, impedancje w szerokim paśmie |
| Analizator odpowiedzi częstotliwościowej (FRA) | Wstrzykiwanie sygnału w pętlę | Stabilność pętli zasilaczy |

**Faza z przesunięcia czasowego:** $\varphi = 360°\cdot\Delta t\cdot f$.

## Przykład rozwiązany

**Faza:** dwie sinusoidy 1 kHz przesunięte o 125 µs → 45°. Przy 10 kHz to samo przesunięcie fazy 45° oznacza 12,5 µs — trzeba zwiększyć rozdzielczość czasową.

**Tensometr:** ćwierćmostek zasilany 5 V, GF = 2, odkształcenie 1000 µm/m → $U_{wy} \approx \tfrac{5}{4}\cdot 2\cdot 10^{-3} = 2\text{,}5$ mV. Taki sygnał wymaga wzmacniacza pomiarowego ([04.07](../04-uklady-analogowe/07-wzmacniacz-operacyjny-idealny.md)) i dbałości o zakłócenia ([08.07](07-zaklocenia-i-ekranowanie.md)).

## Typowe pułapki

- **Pomiar fazy z dwóch kanałów o różnych sondach** (różne opóźnienia) — kalibruj, podając ten sam sygnał na oba kanały.
- **Zbyt duża amplituda pobudzenia** — wzmacniacz wchodzi w nieliniowość lub ograniczenie szybkości narastania.
- **Pomiar kondensatora ceramicznego miernikiem LCR przy 1 V bez polaryzacji DC** — wynik nie mówi nic o pracy przy napięciu znamionowym.
- **Obciążenie wyjścia filtra sondą 1:1.**

## Ćwiczenie komputerowe

Wyznaczenie charakterystyki z odpowiedzi skokowej (symulowanej z szumem):

```python
import numpy as np, matplotlib.pyplot as plt
from scipy import signal
fs = 200e3; t = np.arange(0, 0.05, 1/fs)
sys = signal.TransferFunction([1], [1/(2*np.pi*1e3)**2, 1.414/(2*np.pi*1e3), 1])   # Butterworth 1 kHz
_, y = signal.step(sys, T=t)
y += np.random.default_rng(0).normal(0, 1e-3, len(y))
h = np.diff(y)*fs                                     # odpowiedź impulsowa = pochodna skokowej
f = np.fft.rfftfreq(len(h), 1/fs)
w, Ht = signal.freqs(sys.num, sys.den, worN=2*np.pi*f[1:])
plt.semilogx(f[1:], 20*np.log10(np.abs(np.fft.rfft(h))[1:]/fs), label="z odpowiedzi skokowej")
plt.semilogx(f[1:], 20*np.log10(abs(Ht)), "--", label="teoria")
plt.xlim(10, 50e3); plt.ylim(-80, 5); plt.legend(); plt.grid(which="both"); plt.show()
```

Zwiększ poziom szumu — zobaczysz, że ta metoda szybko traci dokładność w paśmie zaporowym.

## Zadania

1. Przesunięcie czasowe 125 µs przy 1 kHz. Ile stopni?
2. Mostek Wheatstone'a: $R_1 = 1$ kΩ, $R_2 = 2$ kΩ, $R_3 = 1\text{,}5$ kΩ. Przy jakim $R_4$ jest w równowadze?
3. Tensometr w ćwierćmostku: 5 V, GF = 2, $\varepsilon = 1000\ \mu$m/m. Jakie napięcie wyjściowe?
4. Miernik LCR przy 1 kHz pokazuje dla kondensatora: $C = 10\ \mu$F, $D = 0\text{,}05$. Ile wynosi ESR?
5. Dlaczego charakterystykę pętli zasilacza impulsowego mierzy się przez wstrzyknięcie sygnału do pętli, a nie przez „odcięcie” sprzężenia zwrotnego?

<details>
<summary>Odpowiedzi</summary>

1. 45°
2. $R_4 = R_3R_2/R_1 = 3$ kΩ
3. 2,5 mV
4. $\text{ESR} = D\cdot X_C = 0\text{,}05\cdot\dfrac{1}{2\pi\cdot 1000\cdot 10^{-5}} \approx 0\text{,}8\ \Omega$
5. Otwarta pętla nie ma ustalonego punktu pracy (wyjście dryfuje do nasycenia). Wstrzyknięcie małego sygnału w zamkniętej pętli (np. przez rezystor w dzielniku) pozwala zmierzyć wzmocnienie pętli przy zachowanym punkcie pracy
</details>

## Źródła

- [Modular Electronics Learning (ModEL) Project](https://ibiblio.org/kuphaldt/socratic/model/) — mostki, pomiary impedancji
- [All About Circuits — tom DC, rozdział o mostkach](https://www.allaboutcircuits.com/textbook/)
- [Analog Devices — Engineering University Program](https://wiki.analog.com/university) — ćwiczenia z pomiaru charakterystyk częstotliwościowych przyrządami USB
