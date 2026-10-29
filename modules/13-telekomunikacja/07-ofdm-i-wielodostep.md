# 13.07 — OFDM, rozpraszanie widma i wielodostęp

## Po co to jest

W kanale radiowym sygnał dociera wieloma drogami, a wielu użytkowników dzieli to samo widmo. OFDM rozwiązuje pierwszy problem, dzieląc szybki strumień na setki wolnych podnośnych, z których każda „nie widzi” wielodrogowości — dlatego jest podstawą Wi-Fi, LTE, 5G, DVB-T i DAB. Rozpraszanie widma i techniki wielodostępu odpowiadają na drugi problem i dają odporność na zakłócenia (GPS, Bluetooth, LoRa).

## Teoria w pigułce

### OFDM

$N$ podnośnych ortogonalnych o odstępie $\Delta f = 1/T_u$ ($T_u$ — czas użytecznej części symbolu). Każda podnośna niesie symbol QAM. **Nadajnik:** symbole QAM → odwrotna FFT ($N$ punktów) → dodanie **prefiksu cyklicznego** (kopii końca symbolu na początku) → C/A. **Odbiornik:** usunięcie prefiksu → FFT → korekcja kanału (jedno mnożenie zespolone na podnośną) → decyzje.

**Dlaczego działa:**
- symbol jest długi ($T_u$ rzędu µs–dziesiątek µs) w porównaniu z rozmyciem opóźnień kanału;
- prefiks dłuższy niż rozmycie opóźnień pochłania ISI i sprawia, że splot z kanałem jest cykliczny → w dziedzinie częstotliwości kanał to mnożenie $Y_k = H_kX_k$ ([07.02](../07-cps-dsp/02-dft-i-fft.md));
- korekcja jest trywialna, a podnośne w głębokich zanikach chroni kodowanie i przeplot po częstotliwości.

**Koszty:** prefiks zmniejsza sprawność ($T_u/(T_u + T_{CP})$); duży **PAPR** (suma wielu sinusoid) — wymaga liniowego PA ([12.06](../12-technika-wcz-rf/06-wzmacniacze-wcz.md)); wrażliwość na błąd częstotliwości i szum fazowy (utrata ortogonalności — interferencja między podnośnymi, ICI).

### Rozpraszanie widma

| Technika | Zasada | Przykłady |
|---|---|---|
| **DSSS** (sekwencja bezpośrednia) | Każdy bit mnożony przez szybki ciąg pseudolosowy (chipy); odbiornik koreluje z tym samym ciągiem | GPS, Wi-Fi 802.11b, CDMA (3G) |
| **FHSS** (skoki częstotliwości) | Nośna przeskakuje po kanałach według sekwencji | Bluetooth Classic, wojskowe |
| CSS (chirp) | Sygnał świergotowy przemiatający pasmo | LoRa |

**Zysk przetwarzania:** $G_p = 10\log\dfrac{R_{chip}}{R_b}$ — o tyle dB odbiornik tłumi wąskopasmowe zakłócenie i o tyle sygnał może leżeć poniżej szumu w paśmie (GPS: ok. 43 dB, sygnał ok. 20 dB poniżej szumu termicznego w paśmie 2 MHz).

### Wielodostęp i dupleks

| Metoda | Podział zasobu | Przykłady |
|---|---|---|
| FDMA | Częstotliwość | Radiofonia, telefonia 1G |
| TDMA | Czas | GSM (z FDMA), DECT |
| CDMA | Kod | 3G (UMTS, CDMA2000), GPS |
| **OFDMA** | Bloki podnośnych × czas | LTE, 5G, Wi-Fi 6 |
| CSMA/CA | Rywalizacja (nasłuch przed nadawaniem) | Wi-Fi |
| ALOHA | Nadawanie bez koordynacji | LoRaWAN, RFID |
| SDMA / MIMO | Przestrzeń (wiązki, strumienie) | LTE, 5G, Wi-Fi |

Dupleks: FDD (osobne pasma dla obu kierunków) lub TDD (te same pasmo, podział czasu).

**MIMO:** wiele anten nadawczych i odbiorczych. Zastosowania: dywersyfikacja (odporność na zaniki — [13.08](08-kanal-radiowy-i-systemy.md)), formowanie wiązki, **multipleksacja przestrzenna** — kilka niezależnych strumieni w tym samym paśmie; przy dużym SNR pojemność rośnie ok. liniowo z $\min(N_t, N_r)$.

## Przykład rozwiązany

**OFDM w Wi-Fi 802.11a/g:** pasmo 20 MHz, FFT 64 punkty → $\Delta f = 312{,}5$ kHz, $T_u = 3{,}2$ µs, prefiks 0,8 µs (symbol 4 µs). 52 podnośne zajęte: 48 danych + 4 piloty. Przy 64-QAM i kodzie 3/4: $48\cdot 6\cdot 0{,}75/4\ \mu\text{s} = 54$ Mbit/s. Prefiks 0,8 µs wystarcza dla rozmycia opóźnień typowego wewnątrz budynków (dziesiątki–setki ns).

**LTE:** $\Delta f = 15$ kHz → $T_u \approx 66{,}7$ µs, prefiks normalny ok. 4,7 µs — odpowiedni dla dużych komórek z rozmyciem opóźnień rzędu µs.

## Typowe pułapki

- **Prefiks krótszy niż rozmycie opóźnień kanału** — ISI i błędy na wszystkich podnośnych.
- **Brak korekcji błędu częstotliwości przed FFT** — ICI, rozmyte konstelacje.
- **Nasycenie PA szczytami OFDM** — wzrost EVM i emisji poza pasmem.
- **Mylenie pasma kanału z pasmem zajętym przez podnośne** — podnośne brzegowe i środkowa (DC) zwykle nie są używane.
- **Zysk przetwarzania traktowany jako „darmowy”** — rozpraszanie poszerza pasmo; w kanale AWGN bez zakłóceń nie poprawia $E_b/N_0$.

## Ćwiczenie komputerowe

Minimalny system OFDM: 64 podnośne, QPSK, prefiks cykliczny, kanał wielodrogowy, korekcja jednym współczynnikiem:

```python
import numpy as np

rng = np.random.default_rng(0)
N, cp, nsym = 64, 16, 200
h = np.array([1, 0, 0.5*np.exp(1j*0.7), 0, 0, 0.7j])        # kanał wielodrogowy (6 próbek)
H = np.fft.fft(h, N)

def run(cp_len, snr_db=25):
    bits = rng.integers(0, 2, (nsym, N, 2))
    X = ((2*bits[..., 0] - 1) + 1j*(2*bits[..., 1] - 1))/np.sqrt(2)     # QPSK na podnośnych
    x = np.fft.ifft(X, axis=1)*np.sqrt(N)
    tx = np.hstack([x[:, N - cp_len:], x]).ravel()                       # prefiks cykliczny
    rx = np.convolve(tx, h)[:tx.size]
    rx += 10**(-snr_db/20)/np.sqrt(2)*(rng.standard_normal(rx.size) + 1j*rng.standard_normal(rx.size))
    r = rx.reshape(nsym, N + cp_len)[:, cp_len:]
    Y = np.fft.fft(r, axis=1)/np.sqrt(N)
    Xh = Y/H                                                              # korekcja: 1 współczynnik na podnośną
    bh = np.stack([Xh.real > 0, Xh.imag > 0], -1)
    return np.mean(bh != bits.astype(bool))

for c in [16, 4, 0]:
    print(f"prefiks {c:2d} próbek (rozmycie kanału {len(h) - 1}): BER = {run(c):.4f}")
print(f"Wi-Fi: delta f = {20e6/64/1e3:.1f} kHz, przepływność 64-QAM 3/4 = {48*6*0.75/4e-6/1e6:.0f} Mbit/s")
print(f"zysk przetwarzania GPS C/A: {10*np.log10(1.023e6/50):.1f} dB")
```

Przy wystarczającym prefiksie pozostałe błędy pochodzą z podnośnych w głębokim zaniku (małe $|H_k|$ — korekcja wzmacnia tam szum). Dlatego OFDM zawsze łączy się z kodowaniem i przeplotem po podnośnych.

## Zadania

1. System OFDM: pasmo 10 MHz, FFT 1024 punkty. Jaki odstęp podnośnych i czas użyteczny symbolu?
2. Rozmycie opóźnień kanału wynosi 3 µs. Jaki minimalny prefiks? Jaka strata sprawności przy $T_u$ = 66,7 µs?
3. Policz przepływność OFDM: 48 podnośnych danych, 16-QAM, kod 1/2, symbol 4 µs.
4. DSSS: 1 Mbit/s danych, 11 Mchip/s. Jaki zysk przetwarzania?
5. Dlaczego OFDM jest bardziej wrażliwe na błąd częstotliwości nośnej niż modulacja z jedną nośną o tej samej przepływności?

<details>
<summary>Odpowiedzi</summary>

1. ≈ 9,77 kHz; ≈ 102,4 µs
2. ≥ 3 µs; $66{,}7/(66{,}7 + 3) \approx 95{,}7\%$ — strata ok. 4,3% (0,19 dB energii)
3. $48\cdot 4\cdot 0{,}5/4\ \mu\text{s} = 24$ Mbit/s
4. $10\log 11 \approx 10{,}4$ dB
5. Podnośne są bardzo blisko siebie (np. 15 kHz); błąd częstotliwości rzędu kilku % odstępu niszczy ich ortogonalność (ICI), podczas gdy dla jednej szerokiej nośnej ten sam błąd jest małym ułamkiem szybkości symbolowej i łatwo go śledzić pętlą
</details>

## Źródła

- [PySDR — rozdział OFDM i Multipath Fading](https://pysdr.org) — OFDM w Pythonie, kanał wielodrogowy
- [MIT 6.02 Digital Communication Systems](https://ocw.mit.edu/courses/6-02-introduction-to-eecs-ii-digital-communication-systems-fall-2012/) — wielodostęp, protokoły dostępu do medium
- [MIT 6.450 Principles of Digital Communications I](https://ocw.mit.edu/courses/6-450-principles-of-digital-communications-i-fall-2006/) — kanały bezprzewodowe, rozpraszanie widma
