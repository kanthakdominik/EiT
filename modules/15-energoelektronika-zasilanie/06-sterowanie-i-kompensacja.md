# 15.06 — Sterowanie i kompensacja pętli

## Po co to jest

Przetwornica bez sprzężenia zwrotnego nie trzyma napięcia przy zmianach obciążenia i napięcia wejściowego, a jej filtr LC rezonuje. Pętla regulacji musi być szybka (mały spadek napięcia przy skoku prądu procesora) i stabilna (bez oscylacji przy każdym kondensatorze i temperaturze). Kompensacja pętli to zastosowanie automatyki ([10](../10-automatyka/)) w najczystszej postaci — i częsta przyczyna problemów z gotowymi układami, gdy zmieni się kondensator wyjściowy.

## Teoria w pigułce

### Model małosygnałowy

Uśrednienie przebiegów w okresie przełączania daje model liniowy (dla częstotliwości ≲ $f_{sw}/5$–$f_{sw}/10$). Dla buck w trybie napięciowym:

$$\frac{\hat u_{wy}}{\hat d} = U_{we}\cdot\frac{1 + sC\cdot ESR}{1 + s\dfrac{L}{R} + s^2LC}$$

Podwójny biegun w $f_0 = \dfrac{1}{2\pi\sqrt{LC}}$ (faza spada o 180°, rezonans tym ostrzejszy, im mniejsze straty i lżejsze obciążenie), zero od ESR w $f_{ESR} = \dfrac{1}{2\pi C\cdot ESR}$. Modulator PWM: wzmocnienie $1/U_{piły}$.

**Boost i buck-boost** mają dodatkowo **zero w prawej półpłaszczyźnie (RHPZ)** w $f_{RHP} = \dfrac{R(1 - D)^2}{2\pi L}$ (boost): faza spada jak dla bieguna, a moduł rośnie — pasmo pętli musi być znacznie poniżej (typowo ≤ 1/5 $f_{RHP}$).

### Tryby sterowania

| Tryb | Zasada | Cechy |
|---|---|---|
| **Napięciowy** (voltage mode) | Wzmacniacz błędu → porównanie z piłą → PWM | Prosty; podwójny biegun LC wymaga regulatora **typu III** (dwa zera) |
| **Prądowy** (peak current mode) | Wewnętrzna pętla porównuje prąd dławika z sygnałem wzmacniacza błędu | Obiekt ≈ pierwszego rzędu → regulator **typu II**; wbudowane ograniczenie prądu, łatwe łączenie równoległe; przy $D > 0\text{,}5$ wymaga **kompensacji zbocza** (inaczej oscylacje subharmoniczne) |
| Stały czas załączenia (COT), histerezowy | Bez klasycznej pętli z piłą | Bardzo szybka odpowiedź, zmienna częstotliwość |
| Cyfrowy | Przetwornik A/C + regulator w mikrokontrolerze/DSP | Elastyczność, telemetria; opóźnienie próbkowania ([10.07](../10-automatyka/07-regulacja-cyfrowa.md)) |

### Regulatory (kompensatory) na wzmacniaczu błędu

| Typ | Transmitancja | Zastosowanie |
|---|---|---|
| Typ I | Integrator | Bardzo wolne pętle |
| **Typ II** | Integrator + zero + biegun | Tryb prądowy, LDO, buck z dużym ESR |
| **Typ III** | Integrator + dwa zera + dwa bieguny | Tryb napięciowy z ceramicznymi kondensatorami (małe ESR) |

Reguły doboru: pulsacja odcięcia $f_c$ ≈ $f_{sw}/10$ – $f_{sw}/5$ (i ≤ 1/5 $f_{RHP}$), zapas fazy 45–60°, zapas wzmocnienia ≥ 10 dB; zera regulatora typu III w okolicy $f_0$, bieguny — na zerze ESR i ok. $f_{sw}/2$. Weryfikacja: pomiar pętli analizatorem z wstrzyknięciem sygnału na małym rezystorze w pętli sprzężenia ([08.04](../08-miernictwo/04-generatory-i-analizatory.md)) lub odpowiedź na skok obciążenia (przeregulowanie ↔ zapas fazy — [10.03](../10-automatyka/03-stabilnosc.md)).

### Odpowiedź na skok obciążenia

Spadek napięcia ≈ $\dfrac{\Delta I}{2\pi f_cC}$ — szybsza pętla albo większa pojemność wyjściowa. Wymagania procesorów (np. ±3% przy skoku kilkudziesięciu A) prowadzą do przetwornic wielofazowych i dużych baterii kondensatorów.

## Przykład rozwiązany

Buck z [15.02](02-przetwornica-buck.md): $L$ = 15 µH, $C$ = 22 µF ceramiczne (ESR 5 mΩ), 500 kHz.

1. $f_0 = 1/(2\pi\sqrt{15\cdot 10^{-6}\cdot 22\cdot 10^{-6}}) \approx 8\text{,}8$ kHz; $f_{ESR} = 1/(2\pi\cdot 22\cdot 10^{-6}\cdot 0\text{,}005) \approx 1\text{,}45$ MHz — ponad częstotliwością przełączania, więc nie pomaga.
2. Tryb napięciowy: regulator typu III, $f_c \approx 50$ kHz (1/10 $f_{sw}$), dwa zera ok. 0,5–1 × $f_0$, bieguny ok. 250 kHz.
3. Spadek przy skoku 0,5 A: $0\text{,}5/(2\pi\cdot 5\cdot 10^4\cdot 22\cdot 10^{-6}) \approx 72$ mV (2,2% z 3,3 V).
4. Boost 3,7 → 5 V / 0,5 A (R = 10 Ω, L = 4,7 µH, D = 0,26): $f_{RHP} = 10\cdot 0\text{,}74^2/(2\pi\cdot 4\text{,}7\cdot 10^{-6}) \approx 185$ kHz → $f_c$ ≤ ok. 37 kHz mimo przełączania 1 MHz.

## Typowe pułapki

- **Wymiana kondensatora wyjściowego** (elektrolit → ceramika) bez przeliczenia kompensacji — znika zero ESR, pętla traci fazę.
- **Pasmo pętli boost blisko RHPZ** — niestabilność przy dużym obciążeniu (RHPZ spada z obciążeniem i wypełnieniem).
- **Tryb prądowy przy D > 0,5 bez kompensacji zbocza** — oscylacje subharmoniczne (co drugi okres).
- **Szum w pomiarze prądu** (szpilka przy załączeniu) — fałszywe wyłączenia; potrzebne wygaszanie (leading-edge blanking).
- **Ocena stabilności tylko przy nominalnym obciążeniu i temperaturze.**

## Ćwiczenie komputerowe

Charakterystyka obiektu buck, regulator typu III i zapasy stabilności pętli (z modułem `scipy.signal`):

```python
import numpy as np
from scipy import signal

Vin, L, C, ESR, R, Vramp, fsw = 12.0, 15e-6, 22e-6, 0.005, 3.3, 1.0, 500e3
Gvd = (np.array([Vin*C*ESR, Vin]), np.array([L*C*(1 + ESR/R), L/R + C*ESR, 1]))
f0 = 1/(2*np.pi*np.sqrt(L*C)); fc = fsw/10
wz, wp = 2*np.pi*0.8*f0, 2*np.pi*fsw/2
# typ III: K (1 + s/wz)^2 / (s (1 + s/wp)^2); K dobrane tak, by |L(j wc)| = 1
num_c = np.polymul([1/wz, 1], [1/wz, 1]); den_c = np.polymul([1, 0], np.polymul([1/wp, 1], [1/wp, 1]))
H = (1/Vramp)*0.3030                                          # dzielnik 0,8 V / 3,3 V z odniesieniem 0,8 V
w = 2*np.pi*np.logspace(2, 6, 20000)
def loop(K):
    _, G = signal.freqs(*Gvd, w); _, Cc = signal.freqs(K*num_c, den_c, w); return G*Cc*H
_, G1 = signal.freqs(*Gvd, [2*np.pi*fc]); _, C1 = signal.freqs(num_c, den_c, [2*np.pi*fc])
K = 1/abs(G1[0]*C1[0]*H)
Lw = loop(K); mag, ph = abs(Lw), np.unwrap(np.angle(Lw))
ic = np.argmin(abs(mag - 1)); i180 = np.argmin(abs(ph + np.pi))
print(f"f0 = {f0/1e3:.1f} kHz, f_ESR = {1/(2*np.pi*C*ESR)/1e6:.2f} MHz, fc = {w[ic]/2/np.pi/1e3:.1f} kHz")
print(f"zapas fazy = {180 + np.degrees(ph[ic]):.1f}°, zapas wzmocnienia = {-20*np.log10(mag[i180]):.1f} dB")
print(f"spadek przy skoku 0,5 A ≈ {0.5/(2*np.pi*fc*C)*1e3:.0f} mV")
print(f"RHPZ boost (R=10, D=0,26, L=4,7 µH): {10*(1 - 0.26)**2/(2*np.pi*4.7e-6)/1e3:.0f} kHz")
```

Zmień położenie zer (0,5–1,5 $f_0$) i obserwuj zapas fazy; zamień ESR na 50 mΩ (elektrolit polimerowy) i zobacz, jak zmienia się faza obiektu.

## Zadania

1. Policz $f_0$ i $f_{ESR}$ dla L = 4,7 µH, C = 47 µF, ESR = 30 mΩ.
2. Dlaczego w trybie prądowym wystarcza regulator typu II?
3. Boost 12 → 24 V, 2 A, L = 10 µH. Gdzie leży RHPZ i jakie maksymalne pasmo pętli przyjmiesz?
4. Wymagany spadek ≤ 50 mV przy skoku 2 A i $f_c$ = 50 kHz. Jaka minimalna pojemność wyjściowa?
5. Co obserwujesz na oscyloskopie przy skoku obciążenia, jeśli zapas fazy wynosi 20°?

<details>
<summary>Odpowiedzi</summary>

1. $f_0 \approx 10\text{,}7$ kHz; $f_{ESR} \approx 113$ kHz
2. Pętla prądowa „zamienia” dławik w sterowane źródło prądu — obiekt widziany przez pętlę napięciową to źródło prądu + kondensator z obciążeniem (jeden dominujący biegun), więc wystarcza integrator z jednym zerem
3. $R = 12\ \Omega$, $D = 0\text{,}5$: $f_{RHP} = 12\cdot 0\text{,}25/(2\pi\cdot 10^{-5}) \approx 48$ kHz → $f_c$ ≤ ok. 10 kHz
4. $C \geq 2/(2\pi\cdot 5\cdot 10^4\cdot 0\text{,}05) \approx 127$ µF
5. Silne, wolno gasnące oscylacje napięcia (dzwonienie) z przeregulowaniem rzędu 50% spadku — mały zapas stabilności
</details>

## Źródła

- [MIT 6.622 Power Electronics](https://ocw.mit.edu/courses/6-622-power-electronics-spring-2023/) — modelowanie i sterowanie przetwornic
- [Introduction to Power Electronics — R. Erickson (Coursera)](https://www.coursera.org/learn/power-electronics) — model uśredniony; kolejne kursy specjalizacji obejmują sterowanie
- [MIT 6.302 Feedback Systems](https://ocw.mit.edu/courses/6-302-feedback-systems-spring-2007/) — kompensacja pętli
- Noty producentów sterowników o kompensacji typu II/III i pomiarze pętli
