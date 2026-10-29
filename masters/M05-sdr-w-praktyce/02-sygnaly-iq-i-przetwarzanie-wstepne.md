# M05.02 — Sygnały I/Q i przetwarzanie wstępne

## Po co to jest

Każdy program SDR zaczyna od tych samych kroków: przesunięcie wybranego kanału do zera (NCO), odfiltrowanie i zmniejszenie szybkości próbkowania (decymacja), usunięcie składowej stałej i korekcja niezrównoważenia toru I/Q. Błędy na tym etapie — alias przy decymacji, nieciągła faza oscylatora, lustro sygnału — przenoszą się na wszystko dalej. Ten temat to „rzemiosło” obowiązkowe przed demodulacją.

## Teoria w pigułce

### Reprezentacja zespolona

Sygnał pasmowy $x(t) = \mathrm{Re}\{s(t)e^{j2\pi f_ct}\}$ jest w pełni opisany obwiednią zespoloną $s(t) = I(t) + jQ(t)$ ([13](../../modules/13-telekomunikacja/)). Próbki zespolone przy szybkości $f_s$ obejmują pasmo od $-f_s/2$ do $+f_s/2$ — **częstotliwości ujemne są różne od dodatnich** (w sygnale rzeczywistym widmo jest symetryczne). Moc chwilowa $\lvert s\rvert^2$, faza $\arg s$, częstotliwość chwilowa to pochodna fazy.

### NCO i przesunięcie częstotliwości

Mnożenie przez $e^{-j2\pi f_0n/f_s}$ przesuwa widmo o $-f_0$. W implementacji: akumulator fazy (np. 32-bitowy, rozdzielczość $f_s/2^{32}$) i tablica sinusów lub CORDIC. Faza musi być **ciągła między blokami danych** — inaczej co blok pojawia się skok fazy ([03](03-gnu-radio.md)).

### Decymacja i zmiana szybkości

- Przed zmniejszeniem szybkości $M$ razy filtr dolnoprzepustowy musi stłumić wszystko powyżej nowej częstotliwości Nyquista $f_s/(2M)$ — inaczej aliasy wpadają do pasma ([07.07 Zmiana częstotliwości próbkowania](../../modules/07-cps-dsp/07-zmiana-czestotliwosci-probkowania.md)).
- Wydajnie: filtry wielofazowe (oblicza się tylko zachowywane próbki), kaskada półpasmowych FIR (co drugi współczynnik zerowy), CIC w sprzęcie (FPGA) z korekcją FIR.
- Zmiana o ułamek $L/M$: `scipy.signal.resample_poly` — np. 2,4 MS/s → 48 kS/s to $1/50$.

### Wady toru analogowego i ich korekcja

- **Składowa stała** (przeciek oscylatora do wejścia mieszacza, offsety) — prążek na 0 Hz. Usuwanie: odjęcie średniej lub filtr DC $y[n] = x[n] - x[n-1] + \alpha y[n-1]$, $\alpha \approx 0\text{,}999$; albo strojenie z przesunięciem o kilkadziesiąt kHz i cyfrowe przesunięcie kanału.
- **Niezrównoważenie I/Q:** błąd wzmocnienia $g$ i fazy $\varphi$ toru Q. Model: $y = \mu s + \nu s^*$, $\mu = \tfrac12(1 + ge^{-j\varphi})$, $\nu = \tfrac12(1 - ge^{j\varphi})$. Sygnał na $+f$ ma lustro na $-f$ o względnym poziomie $\lvert\nu\rvert^2/\lvert\mu\rvert^2$; **tłumienie lustra** IRR $= 10\log_{10}(\lvert\mu\rvert^2/\lvert\nu\rvert^2)$. Typowo 25–40 dB bez korekcji.
- **Korekcja ślepa:** dla sygnału o własnościach kołowych (większość sygnałów telekomunikacyjnych i szum) $E[I^2] = E[Q^2]$ i $E[IQ] = 0$; z momentów drugiego rzędu toru odebranego estymuje się $g$ i $\sin\varphi$ i odwraca przekształcenie. Układy AD936x robią to sprzętowo (kalibracja ćwiartkowa).

## Przykład rozwiązany

Ton +200 kHz (2,4 MS/s), błąd wzmocnienia 5% i fazy 3°, składowe stałe 0,05 i −0,03:

- Teoretyczny IRR: 28,9 dB; zmierzone lustro na −200 kHz: −28,9 dBc, składowa stała −24,3 dBc.
- Po usunięciu średnich i korekcji z momentów (estymaty $g = 1\text{,}0500$, $\varphi = 3\text{,}001°$): lustro −81,8 dBc, DC −85,6 dBc — ograniczone szumem.

Decymacja 10× (do 240 kS/s) z zakłóceniem 320 kHz od kanału: bez filtru alias na 80 kHz ma poziom ok. −8 dB względem sygnału (praktycznie pełne zakłócenie); z filtrem FIR 101 współczynników — −84 dB.

## Typowe pułapki

- **Decymacja przez wybieranie co $M$-tej próbki bez filtru** — najczęstszy błąd w pierwszych programach SDR.
- **Faza NCO liczona od zera w każdym bloku** — trzaski w dźwięku, rozmyte widmo.
- **Mylenie częstotliwości ujemnych i dodatnich** po zamianie I z Q (sprzężenie widma) — sygnał „po złej stronie” środka.
- **Korekcja I/Q estymowana na sygnale, który nie jest kołowy** (np. czysty BPSK albo pojedynczy ton bez szumu) — estymaty obciążone.
- **Filtr DC o zbyt szerokim paśmie** — wycina też użyteczną część widma przy 0 Hz.

## Ćwiczenie komputerowe

Niezrównoważenie I/Q, składowa stała, ich korekcja oraz decymacja z filtrem i bez:

```python
import numpy as np
from scipy import signal

rng = np.random.default_rng(2)
fs, N = 2.4e6, 2**16
n = np.arange(N)
f0 = 200e3
s = np.exp(2j * np.pi * f0 * n / fs)
s = s + 0.01 * (rng.standard_normal(N) + 1j * rng.standard_normal(N))

# 1) Niezrównoważenie I/Q i składowa stała odbiornika z przemianą bezpośrednią
g, phi = 1.05, np.deg2rad(3)                        # błąd wzmocnienia i fazy toru Q
yI = s.real + 0.05                                  # przeciek oscylatora -> składowa stała
yQ = g * (s.imag * np.cos(phi) + s.real * np.sin(phi)) - 0.03
y = yI + 1j * yQ

def widmo_db(x, f):
    X = np.fft.fftshift(np.abs(np.fft.fft(x * np.hanning(len(x)))))
    fx = np.fft.fftshift(np.fft.fftfreq(len(x), 1 / fs))
    return 20 * np.log10(X[np.argmin(np.abs(fx - f))])

def raport(x, nazwa):
    p_sig, p_img, p_dc = widmo_db(x, f0), widmo_db(x, -f0), widmo_db(x, 0)
    print(f"{nazwa:22s} odbicie lustrzane {p_img - p_sig:6.1f} dBc, składowa stała {p_dc - p_sig:6.1f} dBc")

raport(y, "przed korekcją:")
mu = (1 + g * np.exp(-1j * phi)) / 2
nu = (1 - g * np.exp(1j * phi)) / 2
print(f"teoretyczne tłumienie odbicia (IRR): {10 * np.log10(abs(mu)**2 / abs(nu)**2):.1f} dB")

# 2) Korekcja: usunięcie średniej, estymacja g i phi z momentów drugiego rzędu (bez znajomości sygnału)
yI, yQ = yI - yI.mean(), yQ - yQ.mean()
g_est = np.sqrt(np.mean(yQ**2) / np.mean(yI**2))
sin_est = np.mean(yI * yQ) / np.sqrt(np.mean(yI**2) * np.mean(yQ**2))
yQ_kor = (yQ / g_est - yI * sin_est) / np.sqrt(1 - sin_est**2)
print(f"estymaty: g = {g_est:.4f}, phi = {np.rad2deg(np.arcsin(sin_est)):.3f} st.")
raport(yI + 1j * yQ_kor, "po korekcji:")

# 3) Przesunięcie NCO i decymacja: zakłócenie na 520 kHz
z = s + 0.5 * np.exp(2j * np.pi * 520e3 * n / fs)
bb = z * np.exp(-2j * np.pi * f0 * n / fs)          # sygnał -> 0 Hz, zakłócenie -> 320 kHz
M = 10                                              # 2,4 MS/s -> 240 kS/s
bez_filtru = bb[::M]
h = signal.firwin(101, 0.8 / M)                     # pasmo przepustowe do 0,8 nowej częstotl. Nyquista
z_filtrem = signal.lfilter(h, 1, bb)[::M]
for nazwa, x in (("bez filtru", bez_filtru), ("z filtrem FIR", z_filtrem)):
    X = np.abs(np.fft.fft(x[100:]))
    fx = np.fft.fftfreq(len(x) - 100, M / fs)
    k = np.argmin(np.abs(fx - 80e3))                # 320 kHz - 240 kHz = 80 kHz (alias)
    print(f"decymacja {nazwa:14s}: alias zakłócenia na 80 kHz {20 * np.log10(X[k] / X[0]):6.1f} dB względem sygnału")
```

Rozszerzenie: zamiast korekcji „wsadowej” zaimplementuj adaptacyjną (wykładniczo ważone średnie momentów, jak w bloku *IQ Imbalance* w GNU Radio) i zbadaj, jak szybko się zbiega; zastąp FIR kaskadą trzech filtrów półpasmowych i porównaj liczbę mnożeń na próbkę wyjściową.

## Zadania

1. Jaki IRR daje błąd wzmocnienia 1% i fazy 1°?
2. NCO ma akumulator 24-bitowy przy $f_s = 10$ MS/s. Ile wynosi rozdzielczość częstotliwości?
3. Odbierasz 2,4 MS/s, kanał ma 12,5 kHz. Zaproponuj decymację do 48 kS/s.
4. Dlaczego przy strojeniu z przesunięciem (offset tuning) składowa stała przestaje przeszkadzać?
5. Sygnał odebrany ma prążek na +150 kHz i słabszy o 30 dB na −150 kHz. Co to oznacza i jak to sprawdzić?

<details>
<summary>Odpowiedzi</summary>

1. ok. 40 dB — dla małych błędów $\mathrm{IRR} \approx 4/(\epsilon^2 + \varphi^2)$, $\epsilon = 0\text{,}01$, $\varphi = 0\text{,}0175$ rad → $4/4\text{,}05\cdot 10^{-4} \approx 9900$ (dokładnie 39,96 dB)
2. $10^7/2^{24} \approx 0\text{,}6$ Hz
3. Np. NCO przesuwa kanał do 0 Hz, potem decymacja 2,4 MS/s → 240 kS/s (filtr do ok. 100 kHz) i 240 → 48 kS/s (filtr kanałowy 6–8 kHz); łącznie 50×, w dwóch etapach znacznie taniej niż jednym filtrem
4. Kanał leży z dala od 0 Hz; po cyfrowym przesunięciu kanału do zera składowa stała przesuwa się na częstotliwość równą przesunięciu i zostaje odfiltrowana filtrem kanałowym
5. Najprawdopodobniej lustro wywołane niezrównoważeniem I/Q (IRR ok. 30 dB); sprawdzenie: przestrój odbiornik o $\Delta f$ — prawdziwy sygnał przesunie się o $-\Delta f$, a lustro w przeciwną stronę
</details>

## Źródła

- [PySDR: A Guide to SDR and DSP using Python](https://pysdr.org) — rozdziały o próbkowaniu I/Q, filtrach, zmianie szybkości
- [T. Collins i in. — Software-Defined Radio for Engineers](https://www.analog.com/sdrforengineers) — rozdziały o niedoskonałościach toru i kalibracji
- [07 Cyfrowe przetwarzanie sygnałów](../../modules/07-cps-dsp/)
