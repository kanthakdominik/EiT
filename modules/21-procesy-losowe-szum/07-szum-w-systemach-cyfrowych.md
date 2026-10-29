# 21.07 — Szum w systemach cyfrowych i telekomunikacyjnych

## Po co to jest

W systemie cyfrowym szum pojawia się w trzech miejscach: przy **kwantyzacji** (przetwornik A/C, arytmetyka stałoprzecinkowa), w **zegarze** (jitter i szum fazowy oscylatora — [12.07](../12-technika-wcz-rf/07-mieszacze-i-oscylatory.md)) i w **kanale** (szum AWGN odbiornika, który wyznacza stopę błędów — [13.05](../13-telekomunikacja/05-detekcja-i-ber.md)). Wszystkie trzy opisuje się tymi samymi narzędziami: wariancją, gęstością widmową i pasmem.

## Teoria w pigułce

### Szum kwantyzacji

- Krok $q$, błąd jednostajny na $[-q/2, q/2]$: $\sigma_q = q/\sqrt{12}$ — o ile sygnał jest „zajęty” (zmienia się o wiele LSB, nie jest zsynchronizowany z próbkowaniem).
- Dla pełnej sinusoidy i przetwornika $N$-bitowego: $\mathrm{SNR} = 6\text{,}02N + 1\text{,}76$ dB (12 bitów: 74 dB, 16 bitów: 98 dB).
- Szum rozkłada się równomiernie w paśmie $0$–$f_s/2$; gęstość: $\sigma_q^2/(f_s/2)$. **Nadpróbkowanie** z filtrem: SNR rośnie o $10\log_{10}(\mathrm{OSR})$ — 3 dB (pół bitu) na każde podwojenie $f_s$.
- **Dithering:** dodanie szumu o amplitudzie rzędu LSB rozbija korelację błędu z sygnałem (usuwa harmoniczne kwantyzacji, umożliwia rozdzielczość lepszą niż LSB po uśrednieniu).
- **ENOB** z pomiaru: $\mathrm{ENOB} = (\mathrm{SINAD} - 1\text{,}76)/6\text{,}02$ ([07.01](../07-cps-dsp/01-przetwarzanie-ac.md)).

### Jitter zegara próbkującego

Próbkowanie sinusoidy $A\sin 2\pi ft$ w chwili przesuniętej o losowe $\Delta t$ (RMS $\sigma_t$) daje błąd $\approx 2\pi fA\cos(\cdot)\,\Delta t$:

$$\mathrm{SNR}_{jitter} = -20\log_{10}(2\pi f\sigma_t)$$

Przy $\sigma_t = 1$ ps: sygnał 10 MHz — 84 dB, 100 MHz — 64 dB. Jitter, a nie liczba bitów, ogranicza przetworniki próbkujące sygnały w.cz.

### Szum fazowy a jitter

Szum fazowy oscylatora $\mathcal L(f)$ [dBc/Hz] — jednostronna gęstość szumu fazy względem nośnej, w funkcji odstrojenia. Jitter RMS z całki w paśmie $[f_1, f_2]$:

$$\sigma_\varphi = \sqrt{2\int_{f_1}^{f_2}10^{\mathcal L(f)/10}\,df}\ \ [\text{rad}], \qquad \sigma_t = \frac{\sigma_\varphi}{2\pi f_0}$$

Pasmo całkowania wybiera się zgodnie z zastosowaniem (np. 12 kHz–20 MHz dla łączy optycznych) — bez podania pasma wartość jittera nic nie znaczy.

### Szum w kanale (AWGN)

- Moc szumu w paśmie odbiornika: $N = kTB\cdot F$ (−174 dBm/Hz w 290 K + $10\log B$ + NF) — budżet łącza ([11.08](../11-pole-em-linie-anteny/08-propagacja-i-budzet-lacza.md)).
- Na symbol: $E_b/N_0 = \mathrm{SNR}\cdot\dfrac{B}{R_b}$ — stosunek energii bitu do gęstości szumu, wspólna miara dla różnych modulacji.
- BPSK w AWGN: $P_b = Q\left(\sqrt{2E_b/N_0}\right)$; $10^{-6}$ przy $E_b/N_0 \approx 10\text{,}5$ dB.
- **Filtr dopasowany** maksymalizuje SNR w chwili decyzji — wynik bezpośrednio z teorii przejścia szumu przez układ liniowy (temat 04): $\mathrm{SNR}_{max} = 2E/N_0$.

## Przykład rozwiązany

**Jitter z szumu fazowego zegara 100 MHz:** $\mathcal L(f) = -120$ dBc/Hz płasko od 10 kHz do 10 MHz.

$$\sigma_\varphi = \sqrt{2\cdot 10^{-12}\cdot(10^7 - 10^4)} = 4\text{,}47\cdot 10^{-3}\ \text{rad}, \qquad \sigma_t = \frac{4\text{,}47\cdot 10^{-3}}{2\pi\cdot 10^8} = 7\text{,}1\ \text{ps}$$

Taki zegar w przetworniku próbkującym sygnał 70 MHz ogranicza SNR do $-20\log_{10}(2\pi\cdot 7\cdot 10^7\cdot 7\text{,}1\cdot 10^{-12}) = 50$ dB — mniej niż daje 10-bitowy przetwornik (62 dB). Zegar jest tu ważniejszy niż wybór ADC.

## Typowe pułapki

- **Wzór 6,02N + 1,76 dla sygnału innego niż pełna sinusoida** — dla sygnału o mniejszej amplitudzie lub innym współczynniku szczytu SNR jest niższy.
- **Szum kwantyzacji „jednostajny” dla sygnału stałego lub zsynchronizowanego** — błąd staje się deterministyczny (harmoniczne, martwe strefy); pomaga dithering.
- **Jitter bez pasma całkowania** albo porównanie jittera RMS z jitterem p-p różnych źródeł.
- **Pomylenie SNR z $E_b/N_0$** przy porównywaniu modulacji o różnej przepływności.
- **Zegar z syntezatora PLL** z dużym szumem fazowym poza pasmem pętli podany na wejście szybkiego ADC.

## Ćwiczenie komputerowe

```python
import numpy as np
from scipy.special import erfc

rng = np.random.default_rng(0)
fs, N = 1e9, 2**16

def snr_db(x, ref):
    e = x - ref
    return 10*np.log10(np.mean(ref**2)/np.mean(e**2))

# kwantyzacja 12-bitowa pełnej sinusoidy (częstotliwość niezsynchronizowana z fs)
t = np.arange(N)/fs
f_in = 10.123e6
s = np.sin(2*np.pi*f_in*t)
q = 2/2**12
sq = np.round(s/q)*q
print(f"kwantyzacja 12 bit: SNR = {snr_db(sq, s):.1f} dB (teoria {6.02*12 + 1.76:.1f} dB)")

# jitter 1 ps RMS dla 10 MHz i 100 MHz
for f in (10e6, 100e6):
    ref = np.sin(2*np.pi*f*t)
    xj = np.sin(2*np.pi*f*(t + rng.normal(0, 1e-12, N)))
    print(f"jitter 1 ps, {f/1e6:.0f} MHz: SNR = {snr_db(xj, ref):.1f} dB (teoria {-20*np.log10(2*np.pi*f*1e-12):.1f} dB)")

# jitter z szumu fazowego
L = -120; f1, f2, f0 = 1e4, 1e7, 100e6
sphi = np.sqrt(2*10**(L/10)*(f2 - f1))
print(f"szum fazowy -120 dBc/Hz w 10 kHz–10 MHz: σφ = {sphi*1e3:.2f} mrad, jitter = {sphi/(2*np.pi*f0)*1e12:.2f} ps")

# BPSK w AWGN: symulacja a teoria
for EbN0_dB in (4, 7, 9.6):
    EbN0 = 10**(EbN0_dB/10); n = 2_000_000
    bits = rng.integers(0, 2, n); s = 2*bits - 1
    r = s + rng.normal(0, np.sqrt(1/(2*EbN0)), n)
    ber = np.mean((r > 0) != bits)
    print(f"BPSK Eb/N0 = {EbN0_dB:4.1f} dB: BER sym. {ber:.2e}, teoria {0.5*erfc(np.sqrt(EbN0)):.2e}")
```

## Zadania

1. Przetwornik 16-bitowy próbkuje z 48 kHz sygnał audio o paśmie 20 kHz. O ile dB zysk nadpróbkowania poprawia SNR w paśmie sygnału przy próbkowaniu 192 kHz i idealnym filtrze cyfrowym?
2. Jaki jitter RMS zegara jest dopuszczalny, aby próbkować sygnał 50 MHz z SNR ≥ 70 dB?
3. Szum fazowy −100 dBc/Hz od 1 kHz do 1 MHz przy nośnej 1 GHz. Ile wynosi jitter?
4. Odbiornik o paśmie 200 kHz i NF 6 dB w 290 K. Jaka jest moc szumu w dBm? Jaki sygnał jest potrzebny dla SNR 10 dB?
5. Dlaczego dodanie szumu (dithering) może poprawić rozdzielczość pomiaru wolnozmiennego sygnału?

<details>
<summary>Odpowiedzi</summary>

1. Ta sama moc szumu kwantyzacji rozkłada się w paśmie 0–96 kHz zamiast 0–24 kHz, więc w paśmie sygnału zostaje jej 4 razy mniej: zysk $10\log_{10}(192/48) = 6$ dB (jeden bit)
2. $2\pi\cdot 5\cdot 10^7\cdot\sigma_t \leq 10^{-3.5}$ → $\sigma_t \leq 1$ ps
3. $\sigma_\varphi = \sqrt{2\cdot 10^{-10}\cdot 999\,000} = 1\text{,}41\cdot 10^{-2}$ rad; $\sigma_t = 0\text{,}0141/(2\pi\cdot 10^9) = 2\text{,}25$ ps
4. $-174 + 10\log_{10}(2\cdot 10^5) + 6 = -174 + 53 + 6 = -115$ dBm; sygnał −105 dBm
5. Bez szumu stały sygnał między poziomami daje zawsze ten sam kod (błąd systematyczny do ½ LSB). Z szumem rzędu LSB kod przyjmuje sąsiednie wartości z prawdopodobieństwami zależnymi od położenia sygnału między poziomami — średnia z wielu próbek odtwarza wartość z rozdzielczością lepszą niż LSB
</details>

## Źródła

- [Analog Devices — MT-001: SNR = 6.02N + 1.76 dB](https://www.analog.com/media/en/training-seminars/tutorials/MT-001.pdf) — szum kwantyzacji, nadpróbkowanie
- [MIT 6.450 Principles of Digital Communication I](https://ocw.mit.edu/courses/6-450-principles-of-digital-communications-i-fall-2006/) — szum AWGN, filtr dopasowany
- [13.05 Detekcja i BER](../13-telekomunikacja/05-detekcja-i-ber.md) i [12.07 Mieszacze i oscylatory](../12-technika-wcz-rf/07-mieszacze-i-oscylatory.md)
