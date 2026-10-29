# M05.04 — Demodulacja analogowa: FM, AM, SSB

## Po co to jest

Odbiornik radiofonii FM to „hello world” SDR: w kilkunastu liniach kodu z próbek I/Q powstaje dźwięk. Przy okazji widać w praktyce całą teorię modulacji analogowych ([13.02](../../modules/13-telekomunikacja/02-modulacje-analogowe.md)): reguła Carsona, zysk FM i efekt progowy, pre- i de-emfaza, multipleks stereo z RDS. AM i SSB pozostają w lotnictwie (AM w paśmie 118–137 MHz), krótkofalarstwie (SSB) i radiofonii na falach długich, średnich i krótkich.

## Teoria w pigułce

### FM

- Sygnał $s(t) = A\exp\left(j2\pi\Delta f\int m(\tau)d\tau\right)$; pasmo wg Carsona $B \approx 2(\Delta f + W)$ — dla radiofonii ($\Delta f = 75$ kHz, $W = 15$ kHz) 180 kHz; z multipleksem stereo ($W = 53$ kHz) w praktyce ok. 200–250 kHz.
- **Dyskryminator kwadraturowy** (cyfrowy): $\hat m[n] \propto \arg\left(x[n]x^*[n-1]\right)$ — kąt między kolejnymi próbkami to przyrost fazy, czyli częstotliwość chwilowa. Nie wymaga synchronizacji nośnej i jest odporny na zmiany amplitudy.
- **Zysk FM** powyżej progu: $\mathrm{SNR}_{wy} = 3\beta^2(\beta + 1)\,\mathrm{CNR}$ (CNR w paśmie Carsona, $\beta = \Delta f/W$); dla $\beta = 5$ to 26,5 dB.
- **Efekt progowy:** poniżej CNR ok. 10 dB w dyskryminatorze pojawiają się „kliki” (przeskoki fazy o $2\pi$), a jakość gwałtownie spada.
- **Pre-/de-emfaza:** szum na wyjściu dyskryminatora rośnie z częstotliwością (gęstość ∝ $f^2$); nadajnik podbija wysokie tony (stała czasowa 50 µs w Europie, 75 µs w USA), odbiornik je tłumi — zysk ok. 10 dB.
- **Multipleks stereo:** L+R w paśmie 0–15 kHz, pilot 19 kHz, L−R jako DSB-SC na 38 kHz (nośna odtwarzana z pilota przez podwojenie), RDS na 57 kHz (BPSK, 1187,5 b/s).

### AM i SSB

- **AM:** $s(t) = A[1 + km(t)]$ — detektor obwiedni $\lvert x[n]\rvert$ minus składowa stała; lub detekcja synchroniczna (PLL na nośnej) odporna na zaniki selektywne.
- **SSB:** jedna wstęga bez nośnej; w SDR wystarczy przesunąć sygnał tak, by „zerowa” częstotliwość akustyczna znalazła się na 0 Hz, odfiltrować filtrem zespolonym tylko dodatnie (USB) lub ujemne (LSB) częstotliwości i wziąć część rzeczywistą. Odstrojenie o $\Delta f$ przesuwa wszystkie tony o $\Delta f$ (mowa „kaczkowata”), stąd potrzeba dokładnego strojenia (ok. 50 Hz).
- **Wąskopasmowe FM** (NBFM, łączność 12,5/25 kHz): ten sam dyskryminator, dewiacja 2,5–5 kHz, często z tonem CTCSS.

## Przykład rozwiązany

Odbiornik FM mono (240 kS/s, ton 1 kHz z pełną dewiacją 75 kHz, de-emfaza 50 µs, decymacja do 48 kHz). SNR akustyczny w funkcji CNR (w paśmie 180 kHz):

| CNR | 4 dB | 8 dB | 12 dB | 16 dB | 20 dB | 30 dB |
|---|---|---|---|---|---|---|
| bez de-emfazy | 9,6 dB | 20,8 dB | 38,3 dB | 43,1 dB | 47,1 dB | 57,2 dB |
| z de-emfazą | 14,0 dB | 25,7 dB | 46,0 dB | 52,6 dB | 56,7 dB | 66,6 dB |

Powyżej progu SNR bez de-emfazy ≈ CNR + 27 dB (teoria 26,5 dB), de-emfaza dodaje ok. 9,6 dB. Poniżej ok. 10–12 dB CNR wynik odbiega od prostej o kilkanaście–kilkadziesiąt dB — efekt progowy.

## Typowe pułapki

- **Brak de-emfazy** — dźwięk ostry i szumiący; zła stała czasowa (75 zamiast 50 µs) — zmieniona barwa.
- **Filtr kanałowy węższy niż pasmo Carsona** — zniekształcenia przy dużej dewiacji; szerszy — więcej szumu i sąsiednie stacje.
- **Dyskryminator na sygnale z decymacją do zbyt małej szybkości** — przyrost fazy między próbkami przekracza $\pi$ i dyskryminator się myli (szybkość ≥ ok. 2 × szerokość kanału).
- **Detektor obwiedni na sygnale z przemodulowaniem** (indeks AM > 1) — zniekształcenia, których nie usunie żaden filtr.
- **Głośność zależna od wzmocnienia SDR** w AM — konieczna ARW (normalizacja obwiedni).

## Ćwiczenie komputerowe

Odbiornik FM: dyskryminator, de-emfaza, decymacja i pomiar SNR w funkcji CNR:

```python
import numpy as np
from scipy import signal

# Odbiornik radiofonii FM (mono): dyskryminator kwadraturowy, de-emfaza 50 us, decymacja do 48 kHz
rng = np.random.default_rng(4)
fs, T = 240e3, 1.0
t = np.arange(int(fs * T)) / fs
fa, dev, tau = 1e3, 75e3, 50e-6
audio = np.sin(2 * np.pi * fa * t)

# Nadajnik: pre-emfaza (filtr 1 + s*tau, dyskretnie), następnie modulacja FM
b_pre, a_pre = signal.bilinear([tau, 1], [tau / 20, 1], fs)   # biegun daleko poza pasmem akustycznym
m = signal.lfilter(b_pre, a_pre, audio)
m = m / np.max(np.abs(m[1000:]))                                # pełna dewiacja 75 kHz
x = np.exp(1j * 2 * np.pi * dev * np.cumsum(m) / fs)

b_de, a_de = signal.bilinear([1], [tau, 1], fs)                 # de-emfaza w odbiorniku
h_lp = signal.firwin(129, 15e3, fs=fs)

def odbierz(cnr_db, deemfaza=True):
    B = 180e3                                                    # pasmo Carsona 2(75 + 15) kHz
    sigma2 = 10**(-cnr_db / 10) * fs / B                         # moc szumu w całym fs
    r = x + np.sqrt(sigma2 / 2) * (rng.standard_normal(t.size) + 1j * rng.standard_normal(t.size))
    d = np.angle(r[1:] * np.conj(r[:-1])) * fs / (2 * np.pi * dev)   # dyskryminator
    if deemfaza:
        d = signal.lfilter(b_de, a_de, d)
    y = signal.lfilter(h_lp, 1, d)[::5][2000:]                   # 48 kHz, bez stanu przejściowego
    # SNR akustyczny: dopasowanie tonu 1 kHz metodą najmniejszych kwadratów, reszta to szum
    tt = np.arange(y.size) / 48e3
    A = np.column_stack([np.sin(2 * np.pi * fa * tt), np.cos(2 * np.pi * fa * tt), np.ones_like(tt)])
    c = np.linalg.lstsq(A, y, rcond=None)[0]
    ton = A[:, :2] @ c[:2]
    return 10 * np.log10(np.sum(ton**2) / np.sum((y - A @ c)**2))

for cnr in (4, 8, 12, 16, 20, 30):
    print(f"CNR {cnr:2d} dB -> SNR audio {odbierz(cnr):5.1f} dB (bez de-emfazy {odbierz(cnr, False):5.1f} dB)")
beta = dev / 15e3
print(f"teoria powyżej progu: SNR = CNR + 10log(3 beta^2 (beta + 1)) = CNR + {10 * np.log10(3 * beta**2 * (beta + 1)):.1f} dB (bez de-emfazy)")
```

Z prawdziwym sygnałem: nagraj 2–5 s stacji FM z RTL-SDR (2,4 MS/s, przesunięcie o kilkaset kHz od stacji), przesuń cyfrowo, zdecymuj do 240 kS/s i zdemoduluj kodem powyżej; zapisz wynik jako plik WAV (`scipy.io.wavfile.write`). Rozszerzenia: odtwórz pilot 19 kHz i zdemoduluj stereo; zobacz widmo multipleksu (pilot, L−R, RDS na 57 kHz).

## Zadania

1. Ile wynosi pasmo Carsona dla NBFM z dewiacją 2,5 kHz i pasmem mowy 3 kHz?
2. Dlaczego dyskryminator $\arg(x[n]x^*[n-1])$ nie wymaga odtwarzania nośnej?
3. Ile wynosi zysk de-emfazy dla stałej 50 µs i pasma 15 kHz? (Wzór: $\dfrac{(W/f_1)^3}{3[W/f_1 - \arctan(W/f_1)]}$, $f_1 = 1/(2\pi\tau)$.)
4. Stacja FM jest odbierana z CNR 25 dB. Jaki SNR akustyczny (mono, z de-emfazą) możesz oczekiwać?
5. Jak odróżnić w widmie I/Q sygnał SSB od AM?

<details>
<summary>Odpowiedzi</summary>

1. $2(2\text{,}5 + 3) = 11$ kHz — mieści się w kanale 12,5 kHz
2. Kąt między kolejnymi próbkami zależy tylko od przyrostu fazy w czasie jednej próbki; stała faza nośnej znosi się w iloczynie $x[n]x^*[n-1]$, a niewielkie przesunięcie częstotliwości daje tylko składową stałą na wyjściu
3. $f_1 = 3183$ Hz, $W/f_1 = 4\text{,}71$: $104\text{,}6/(3\cdot(4\text{,}71 - 1\text{,}36)) \approx 10\text{,}4$ → 10,2 dB (w symulacji ok. 9,6 dB, bo pre-emfaza zmniejsza też trochę dewiację tonu 1 kHz)
4. Ok. $25 + 26\text{,}5 + 10 \approx 61$ dB (w symulacji przy 20 i 30 dB: 56,7 i 66,6 dB)
5. AM ma silny prążek nośnej na środku i dwie symetryczne wstęgi; SSB nie ma nośnej, a widmo występuje tylko po jednej stronie częstotliwości odniesienia
</details>

## Źródła

- [PySDR: A Guide to SDR and DSP using Python](https://pysdr.org) — rozdział o odbiorze radiofonii FM z RDS
- [GNU Radio — Guided Tutorial GRC](https://wiki.gnuradio.org/index.php?title=GRC) — bloki *WBFM Receive*, *Quadrature Demod*
- [13.02 Modulacje analogowe](../../modules/13-telekomunikacja/02-modulacje-analogowe.md)
