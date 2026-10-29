# M05.01 — Architektura odbiornika i nadajnika SDR

## Po co to jest

Radio programowalne (SDR) przenosi większość odbiornika z analogowej elektroniki do oprogramowania: sprzęt tylko przemienia pasmo radiowe na próbki zespolone I/Q, a filtracja, demodulacja i dekodowanie odbywają się w procesorze. Zanim napiszesz pierwszy demodulator, musisz wiedzieć, co dzieje się w urządzeniu: skąd biorą się składowa stała i odbicie lustrzane, dlaczego 8-bitowy odbiornik „głuchnie” przy silnej stacji obok, ile wynosi błąd częstotliwości oscylatora i jaką przepływność danych musi udźwignąć USB. Te same zjawiska ograniczają telefony, stacje bazowe i radary.

## Teoria w pigułce

### Trzy architektury

| Architektura | Zasada | Zalety | Wady |
|---|---|---|---|
| Superheterodyna | Przemiana na stałą częstotliwość pośrednią, filtracja selektywna, druga przemiana lub próbkowanie p.cz. | Duża selektywność, brak problemów z DC | Filtry p.cz., częstotliwość lustrzana, złożoność |
| Przemiana bezpośrednia (zero-IF) | Mieszacz kwadraturowy z oscylatorem na częstotliwości nośnej → I/Q w paśmie podstawowym | Prostota, scalanie (AD936x, telefony) | Składowa stała (przeciek LO), niezrównoważenie I/Q, szum 1/f |
| Bezpośrednie próbkowanie w.cz. | Przetwornik A/C próbkuje sygnał antenowy (lub pasmowo — w strefie Nyquista) | Brak mieszaczy, pełna elastyczność | Bardzo szybkie A/C (GS/s), duża moc, jitter zegara |

Wariant pośredni: **low-IF** — przemiana kwadraturowa na małą częstotliwość (np. kilkaset kHz), która omija problem DC kosztem wymagań na tłumienie lustra.

### Tor odbiorczy i jego ograniczenia

- **LNA i filtr wejściowy** ustalają współczynnik szumów (wzór Friisa, [12](../../modules/12-technika-wcz-rf/)) i odporność na silne sygnały spoza pasma.
- **Oscylator (syntezer PLL)** — błąd wzorca w ppm daje przesunięcie częstotliwości: 1 ppm przy 1 GHz to 1 kHz; szum fazowy oscylatora „rozmazuje” silne sygnały na sąsiednie kanały (mieszanie odwrotne).
- **Przetwornik A/C:** idealny $N$-bitowy daje $\mathrm{SNR} = 6\text{,}02N + 1\text{,}76$ dB dla sinusoidy w pełnym zakresie, w całym paśmie Nyquista. Filtracja do pasma kanału $B$ dodaje **zysk przetwarzania** $10\log_{10}(f_s/B)$ (próbki zespolone).
- **Wzmocnienie i ARW (AGC):** zbyt małe — szum kwantyzacji przykrywa sygnał; zbyt duże — przesterowanie i intermodulacja. Silny sygnał w paśmie przetwornika wymusza małe wzmocnienie i zmniejsza czułość dla słabych sygnałów obok — **zakres dynamiki** jest często ważniejszy niż czułość.

### Typowy sprzęt (orientacyjnie)

| Urządzenie | Zakres | Przetwornik | Pasmo / szybkość | Uwagi |
|---|---|---|---|---|
| RTL-SDR (np. RTL-SDR Blog V4) | ok. 24 MHz – 1,7 GHz (V4 także fale krótkie) | 8 bitów | do ok. 2,4 MS/s stabilnie | Tylko odbiór, najtańszy start |
| HackRF One | 1 MHz – 6 GHz | 8 bitów | do 20 MS/s | Nadawanie i odbiór naprzemiennie (półdupleks) |
| ADALM-Pluto | 325 MHz – 3,8 GHz | 12 bitów (AD9363) | do ok. 20 MHz pasma | Pełny dupleks 1 × 1, dydaktyczny |
| USRP B200/B210 | 70 MHz – 6 GHz | 12 bitów (AD9361) | do 56 MHz pasma | B210: 2 × 2 MIMO, USB 3.0 |

Przepływność: RTL-SDR przy 2,4 MS/s to $2\text{,}4\cdot 10^6 \cdot 2 \cdot 1\ \text{B} = 4\text{,}8$ MB/s; próbki 12-bitowe przesyła się zwykle jako 16-bitowe, więc 20 MS/s to 80 MB/s — więcej niż przepustowość USB 2.0. Szybkość próbkowania dobiera się do potrzebnego pasma, nie „na zapas”.

### Nadajnik SDR

Odwrotny tor: próbki I/Q → przetwornik C/A → filtr → mieszacz kwadraturowy → wzmacniacz mocy. Problemy lustrzane: przeciek nośnej (DC), odbicie lustrzane, harmoniczne C/A, nieliniowość wzmacniacza (odrost widma, [12](../../modules/12-technika-wcz-rf/)). Tanie SDR **nie mają filtrów** spełniających normy emisji — nadawanie bez zewnętrznego filtra i bez uprawnień jest niedopuszczalne ([08](08-praktyka-ads-b-i-przepisy.md)).

## Przykład rozwiązany

**Słaby sygnał obok silnego zakłócenia.** Odbiornik zero-IF próbkuje 2,4 MS/s; zakłócenie o amplitudzie 0,9 pełnego zakresu leży 400 kHz od interesującego nas kanału o szerokości 25 kHz. Zysk przetwarzania: $10\log_{10}(2\text{,}4\cdot 10^6/25\cdot 10^3) = 19\text{,}8$ dB.

Model szumu białego kwantyzacji (z niewielkim szumem analogowym) i symulacja:

| Przetwornik | Sygnał −40 dBc | −60 dBc | −80 dBc |
|---|---|---|---|
| 8 bitów (model) | 28,8 dB | 8,8 dB | −11,2 dB |
| 8 bitów (symulacja) | 22,6 dB | 5,5 dB | sygnał utracony |
| 12 bitów (model) | 51,1 dB | 31,1 dB | 11,1 dB |
| 12 bitów (symulacja) | 51,5 dB | 31,4 dB | 11,4 dB |

12 bitów zgadza się z modelem; przy 8 bitach błąd kwantyzacji nie jest szumem białym (szum analogowy jest mniejszy od kroku kwantyzacji, błąd zależy od sygnału i tworzy prążki), więc wynik jest gorszy od modelu, a sygnał na poziomie −80 dBc ginie. Każdy bit to ok. 6 dB zakresu dynamiki.

## Typowe pułapki

- **Prążek na środku widma** w odbiorniku zero-IF wzięty za sygnał — to składowa stała (przeciek LO); stroi się z przesunięciem i przesuwa cyfrowo ([02](02-sygnaly-iq-i-przetwarzanie-wstepne.md)).
- **Wzmocnienie na maksimum** — przesterowanie i fałszywe sygnały intermodulacyjne w całym paśmie.
- **Zbyt duża szybkość próbkowania** — gubione próbki (przepełnienie bufora, komunikaty „O” lub „overflow”), nieciągłości sygnału.
- **Niewzięty pod uwagę błąd ppm** — sygnał wąskopasmowy poza filtrem kanału; kalibruje się go na znanym nadajniku.
- **Antena „do wszystkiego”** — charakterystyka i dopasowanie anteny zmieniają się silnie z częstotliwością ([11.07](../../modules/11-pole-em-linie-anteny/07-anteny.md)).

## Ćwiczenie komputerowe

Zakres dynamiki przetwornika: słaby sygnał obok silnego zakłócenia przy 8 i 12 bitach:

```python
import numpy as np

# Słaby sygnał obok silnego zakłócenia: ile bitów przetwornika potrzeba?
rng = np.random.default_rng(1)
fs, N = 2.4e6, 2**18
df = fs / N
k_blk, k_sig = 32771, -10923      # ok. +300 kHz i -100 kHz, nieparzyste prążki FFT
n = np.arange(N)

def kwantyzuj(x, bity):
    q = 2.0 / 2**bity                                   # zakres -1...+1
    return np.clip(np.round(x / q) * q, -1, 1 - q)

def snr_w_kanale(bity, poziom_dbc, B=25e3):
    a_blk = 0.9
    a_sig = a_blk * 10**(poziom_dbc / 20)
    x = (a_blk * np.exp(2j * np.pi * k_blk * n / N)
         + a_sig * np.exp(2j * np.pi * k_sig * n / N))
    x = x + 1e-4 * (rng.standard_normal(N) + 1j * rng.standard_normal(N))  # szum analogowy
    y = kwantyzuj(x.real, bity) + 1j * kwantyzuj(x.imag, bity)
    X = np.abs(np.fft.fft(y))**2
    kanal = (np.arange(N) - k_sig + N // 2) % N - N // 2  # odległość od prążka sygnału
    w_kanale = np.abs(kanal) <= B / 2 / df
    p_sig = X[k_sig % N]
    p_szum = X[w_kanale].sum() - p_sig
    return 10 * np.log10(p_sig / p_szum)

zysk = 10 * np.log10(fs / 25e3)
print(f"zysk przetwarzania (2,4 MHz -> 25 kHz): {zysk:.1f} dB")
for bity in (8, 12):
    q = 2.0 / 2**bity
    szum = 2 * q**2 / 12 + 2 * 1e-4**2                  # kwantyzacja + analogowy (I i Q)
    dr = 10 * np.log10(0.81 / szum) + zysk              # zakres dynamiki w kanale względem zakłócenia
    for p in (-40, -60, -80):
        print(f"{bity:2d} bitów, sygnał {p} dBc: SNR w kanale {snr_w_kanale(bity, p):5.1f} dB"
              f" (model szumu białego: {dr + p:5.1f} dB)")
```

Z prawdziwym sprzętem: odczyt próbek przez bibliotekę `pyadi-iio` (ADALM-Pluto) lub `pyrtlsdr` (RTL-SDR) — bloki poniżej wymagają urządzenia i nie są uruchamiane automatycznie:

```python
import adi                                  # pyadi-iio, ADALM-Pluto
sdr = adi.Pluto("ip:192.168.2.1")
sdr.rx_lo = int(100e6)                      # częstotliwość odbioru
sdr.sample_rate = int(1e6)
sdr.rx_rf_bandwidth = int(1e6)
sdr.rx_buffer_size = 2**16
sdr.gain_control_mode_chan0 = "slow_attack"
x = sdr.rx()                                # tablica próbek zespolonych
```

```python
from rtlsdr import RtlSdr                   # pyrtlsdr, RTL-SDR
sdr = RtlSdr()
sdr.sample_rate = 2.4e6
sdr.center_freq = 100e6
sdr.gain = "auto"
x = sdr.read_samples(2**18)
sdr.close()
```

## Zadania

1. Wzorzec 28,8 MHz w RTL-SDR ma błąd 25 ppm. Jakie przesunięcie częstotliwości wystąpi przy odbiorze 1090 MHz?
2. Ile wynosi SNR idealnego przetwornika 12-bitowego przy 20 MS/s, przeliczony na kanał 200 kHz?
3. Dlaczego architektura zero-IF zdominowała scalone układy radiowe mimo problemów z DC i niezrównoważeniem I/Q?
4. HackRF ma przetwornik 8-bitowy, Pluto 12-bitowy. Które urządzenie wybierzesz do odbioru słabych sygnałów przy silnej stacji nadawczej w pobliżu i dlaczego?
5. Jaka przepływność danych (MB/s) jest potrzebna dla USRP przy 30 MS/s i próbkach 16-bitowych I i Q?

<details>
<summary>Odpowiedzi</summary>

1. $1090\cdot 10^6\cdot 25\cdot 10^{-6} \approx 27$ kHz
2. $74 + 10\log_{10}(20\cdot 10^6/200\cdot 10^3) = 74 + 20 = 94$ dB (idealnie; w praktyce szum analogowy i nieliniowości dają znacznie mniej)
3. Brak filtrów p.cz. (których nie da się scalić), mała liczba elementów zewnętrznych, łatwa zmiana pasma i szerokości kanału; problemy DC i I/Q koryguje się cyfrowo
4. Pluto — większy zakres dynamiki przetwornika (ok. 24 dB więcej w modelu idealnym), a odporność na silny sygnał zależy też od filtra wejściowego i liniowości toru
5. $30\cdot 10^6\cdot 2\cdot 2\ \text{B} = 120$ MB/s — wymaga USB 3.0
</details>

## Źródła

- [PySDR: A Guide to SDR and DSP using Python](https://pysdr.org) — rozdziały o sprzęcie, I/Q, PlutoSDR, RTL-SDR i USRP
- [T. Collins, R. Getz, D. Pu, A. Wyglinski — Software-Defined Radio for Engineers (darmowa wersja od Analog Devices)](https://www.analog.com/sdrforengineers)
- [Analog Devices — ADALM-Pluto (wiki)](https://wiki.analog.com/plutosdr)
- [RTL-SDR Quick Start Guide](https://www.rtl-sdr.com/rtl-sdr-quick-start-guide/)
- [12 Technika w.cz.](../../modules/12-technika-wcz-rf/) — szumy, intermodulacja, mieszacze
