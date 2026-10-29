# M05.07 — OFDM w SDR: synchronizacja i estymacja kanału

## Po co to jest

OFDM ([13.07](../../modules/13-telekomunikacja/07-ofdm-i-wielodostep.md)) jest podstawą Wi-Fi, LTE, 5G NR, DVB-T i DAB. W symulacji z idealną synchronizacją wystarczą IFFT, prefiks cykliczny i FFT. W SDR dochodzą: nieznany początek symbolu, przesunięcie częstotliwości, które niszczy ortogonalność podnośnych, różnica zegarów próbkowania, szum fazowy i kanał wielodrogowy z głębokimi zanikami. Ten temat pokazuje, jak rozwiązuje to klasyczna metoda Schmidla–Coxa i estymacja kanału na symbolach treningowych i pilotach — tak jak w odbiornikach 802.11a/g.

## Teoria w pigułce

### Wrażliwość OFDM

- **Czas:** początek okna FFT może leżeć w dowolnym miejscu prefiksu cyklicznego, który nie jest „zabrudzony” odpowiedzią kanału — przesunięcie w tym zakresie to tylko liniowa faza na podnośnych (korektor ją usuwa). Poza nim — ISI i ICI.
- **CFO:** przesunięcie o ułamek $\epsilon$ odstępu podnośnych $\Delta f$ daje wspólny obrót fazy narastający z symbolu na symbol oraz **interferencję międzypodnośną** (ICI) o mocy ok. $\tfrac{\pi^2\epsilon^2}{3}$ (dla małych $\epsilon$); $\epsilon = 0\text{,}3$ zamienia czytelną konstelację w chmurę. Część całkowita CFO przesuwa podnośne o całe indeksy.
- **Zegar próbkowania** (SFO): obrót fazy rosnący z indeksem podnośnej i z czasem — śledzony pilotami.
- **Szum fazowy:** wspólny błąd fazy (CPE) w każdym symbolu (korygowany pilotami) i ICI.

### Metoda Schmidla–Coxa

Symbol synchronizacyjny z danymi tylko na parzystych podnośnych ma w czasie **dwie identyczne połowy** długości $L = N/2$. Metryka:

$$P(d) = \sum_{m=0}^{L-1}r^*_{d+m}\,r_{d+m+L},\qquad M(d) = \frac{\lvert P(d)\rvert^2}{R(d)^2}$$

($R$ — energia okna). $M(d)$ ma płaski szczyt długości prefiksu (okno w dowolnym miejscu CP daje tę samą korelację); środek szczytu wskazuje pozycję symbolu. Faza $P$ to obrót między połowami: $\hat\epsilon = \arg P/\pi$ — zakres $\lvert\epsilon\rvert < 1$. Część całkowitą wyznacza drugi symbol treningowy (różnicowo kodowana sekwencja na podnośnych parzystych) lub przeszukiwanie przesunięć widma.

### Estymacja kanału i korekcja

- **LS na symbolu treningowym:** $\hat H_k = Y_k/X_k$; uśrednianie dwóch symboli (jak w 802.11) zmniejsza szum o 3 dB; wygładzanie (filtracja w dziedzinie czasu do długości CP) — kolejne dB.
- **Piloty** rozmieszczone w symbolach danych: śledzenie CPE i SFO; w systemach mobilnych (LTE, NR) — także zmian kanału w czasie (interpolacja 2D).
- **Korektor jednowspółczynnikowy** $Z_k = Y_k/\hat H_k$ (ZF) lub MMSE; na podnośnych w głębokim zaniku szum jest wzmacniany — bez kodowania i przeplotu po podnośnych te podnośne dominują błędy.

## Przykład rozwiązany

OFDM jak w 802.11a: $N = 64$, CP = 16, 52 podnośne (48 danych + 4 piloty), QPSK, 20 symboli; kanał 4-drogowy krótszy od CP (najgłębszy zanik na podnośnej −14,9 dB), SNR 20 dB, ramka zaczyna się w nieznanym miejscu.

| CFO (ułamek $\Delta f$) | estymata | EVM z korekcją | błędy z korekcją | bez korekcji CFO |
|---|---|---|---|---|
| 0 | 0,000 | 25,3% | 10/1920 | — |
| 0,3 | 0,297 | 26,6% | 3/1920 | EVM 156%, 517 błędów |
| 1,3 | −0,702 | 165% | 955/1920 | — |

- Początek symbolu wyznaczony dokładnie (próbka 316) we wszystkich przypadkach.
- EVM ok. 25% przy SNR 20 dB to nie błąd synchronizacji: korektor wzmacnia szum na podnośnych w zaniku (średnio $\overline{1/\lvert H\rvert^2} = 2\text{,}8$, czyli 4,5 dB), a estymata LS z jednego symbolu dodaje drugie tyle szumu (3 dB) — efektywny SNR ok. 12,5 dB.
- CFO 1,3 jest estymowane jako −0,7 (różnica dokładnie 2 odstępów — niejednoznaczność metody); bez estymacji części całkowitej odbiornik zawodzi.

## Typowe pułapki

- **Okno FFT w części CP zajętej przez odpowiedź kanału** — ISI; okno ustawia się kilka próbek przed końcem CP, nie na samym końcu.
- **Estymata kanału z jednego symbolu bez wygładzania** — 3 dB i więcej straty.
- **Pominięcie CPE** — obrót konstelacji między symbolami narastający przez całą ramkę.
- **Moc nadajnika SDR za blisko nasycenia** — OFDM ma duży stosunek mocy szczytowej do średniej (PAPR ok. 10 dB) — odrost widma i EVM nadajnika; potrzebny zapas mocy.
- **Brak ochrony podnośnej DC** w odbiorniku zero-IF — składowa stała trafia w dane.

## Ćwiczenie komputerowe

OFDM z synchronizacją Schmidla–Coxa, estymacją kanału LS i korekcją CPE z pilotów:

```python
import numpy as np

rng = np.random.default_rng(7)
N, CP = 64, 16                                   # jak w Wi-Fi 802.11a/g: 64 podnośne, CP 0,8 us przy 20 MS/s
uzyte = np.r_[1:27, 38:64]                       # 52 podnośne (bez DC i pasm ochronnych)
piloty = np.array([7, 21, 43, 57])
dane = np.setdiff1d(uzyte, piloty)               # 48 podnośnych danych
qpsk = lambda b: ((1 - 2 * b[0::2]) + 1j * (1 - 2 * b[1::2])) / np.sqrt(2)

def symbol(X):
    x = np.fft.ifft(X) * np.sqrt(N)
    return np.r_[x[-CP:], x]

# Preambuła Schmidla–Coxa: tylko parzyste podnośne -> dwie identyczne połowy w czasie
X_sc = np.zeros(N, complex)
parz = uzyte[uzyte % 2 == 0]
X_sc[parz] = np.sqrt(2) * qpsk(rng.integers(0, 2, 2 * parz.size))
X_tr = np.zeros(N, complex)                      # symbol treningowy do estymacji kanału
X_tr[uzyte] = qpsk(rng.integers(0, 2, 2 * uzyte.size))

Nsym = 20
bity = rng.integers(0, 2, 2 * dane.size * Nsym)
ramki = [symbol(X_sc), symbol(X_tr)]
Xd = []
for k in range(Nsym):
    X = np.zeros(N, complex)
    X[dane] = qpsk(bity[2 * dane.size * k:2 * dane.size * (k + 1)])
    X[piloty] = 1.0
    Xd.append(X); ramki.append(symbol(X))
tx = np.concatenate(ramki)

def kanal(tx, eps, snr_db):
    h = np.array([1.0, 0.0, 0.5j, 0.0, 0.0, -0.3, 0.0, 0.15])   # wielodrogowość krótsza niż CP
    h = h / np.linalg.norm(h)
    x = np.convolve(np.r_[np.zeros(300), tx, np.zeros(100)], h)
    n = np.arange(x.size)
    x = x * np.exp(2j * np.pi * eps * n / N)                      # CFO w ułamku odstępu podnośnych
    s2 = np.mean(np.abs(tx)**2) * 10**(-snr_db / 10)
    return x + np.sqrt(s2 / 2) * (rng.standard_normal(x.size) + 1j * rng.standard_normal(x.size)), h

def odbiornik(r, korekcja_cfo=True):
    L = N // 2
    # metryka Schmidla–Coxa: korelacja połówek
    P = np.array([np.sum(np.conj(r[d:d + L]) * r[d + L:d + 2 * L]) for d in range(r.size - N)])
    R = np.array([0.5 * np.sum(np.abs(r[d:d + 2 * L])**2) for d in range(r.size - N)])
    M = np.abs(P)**2 / R**2
    plateau = np.flatnonzero(M > 0.9 * M.max())
    d0 = int(np.round(plateau.mean())) + CP // 2  # środek płaskiego szczytu leży w CP -> początek symbolu
    eps = np.angle(P[d0]) / np.pi if korekcja_cfo else 0.0
    n = np.arange(r.size)
    r = r * np.exp(-2j * np.pi * eps * n / N)
    start = d0 + N - 4                             # początek symbolu treningowego, z zapasem w CP
    sym = lambda k: np.fft.fft(r[start + k * (N + CP) + CP:start + k * (N + CP) + CP + N]) / np.sqrt(N)
    H = np.zeros(N, complex)
    H[uzyte] = sym(0)[uzyte] / X_tr[uzyte]         # estymata LS kanału
    wy = []
    for k in range(1, Nsym + 1):
        Y = sym(k)
        Z = np.zeros(N, complex)
        Z[uzyte] = Y[uzyte] / H[uzyte]             # korektor jednowspółczynnikowy
        cpe = np.angle(np.sum(Z[piloty]))          # wspólny błąd fazy z pilotów
        wy.append(Z[dane] * np.exp(-1j * cpe))
    wy = np.concatenate(wy)
    bh = np.empty(2 * wy.size, int)
    bh[0::2], bh[1::2] = wy.real < 0, wy.imag < 0
    return d0, eps, bh, wy

for eps in (0.0, 0.3, 1.3):
    r, h = kanal(tx, eps, 20)
    d0, eps_est, bh, wy = odbiornik(r)
    _, _, bh0, wy0 = odbiornik(r, korekcja_cfo=False)
    evm = lambda w: 100 * np.sqrt(np.mean(np.abs(w - qpsk(bity))**2))
    print(f"CFO {eps:.1f} odstępu: estymata {eps_est:+.3f}, początek ramki {d0} (prawdziwy 316)")
    print(f"   z korekcją: EVM {evm(wy):5.1f} %, błędy {np.sum(bh != bity):4d}/{bity.size};"
          f"   bez korekcji: EVM {evm(wy0):5.1f} %, błędy {np.sum(bh0 != bity):4d}")
```

Rozszerzenia: dodaj estymację całkowitej części CFO (drugi symbol treningowy z różnicową sekwencją); uśrednij kanał z dwóch symboli treningowych i wygładź go w dziedzinie czasu (obetnij odpowiedź impulsową do długości CP) — zmierz zysk EVM; dodaj różnicę zegarów 50 ppm i śledzenie nachylenia fazy na pilotach; prześlij ramkę przez Pluto w pętli kablowej.

## Zadania

1. Ile wynosi odstęp podnośnych i czas symbolu (z CP) dla $N = 64$ przy 20 MS/s, CP = 16?
2. Oscylatory mają błąd ±20 ppm przy 2,4 GHz. Ile to odstępów podnośnych 802.11a?
3. Dlaczego metryka Schmidla–Coxa ma płaski szczyt, a nie ostre maksimum?
4. Kanał ma opóźnienie rozproszone 1,2 µs. Czy CP 0,8 µs wystarczy? Co się stanie?
5. Jaka moc ICI (względem sygnału) powstaje przy $\epsilon = 0\text{,}05$?

<details>
<summary>Odpowiedzi</summary>

1. $\Delta f = 20\ \text{MHz}/64 = 312\text{,}5$ kHz; symbol $80/20\ \text{MHz} = 4$ µs (3,2 µs + 0,8 µs CP)
2. Względny błąd do 40 ppm → $2\text{,}4\cdot 10^9\cdot 40\cdot 10^{-6} = 96$ kHz ≈ 0,31 odstępu — część ułamkowa wystarcza (stąd w 802.11 krótka preambuła do zgrubnej i długa do dokładnej estymacji)
3. Dla każdego położenia okna w obrębie CP dwie połowy symbolu (przedłużonego cyklicznie) są wciąż identyczne — korelacja ma tę samą wartość na długości CP minus długość kanału
4. Nie — odpowiedź kanału wychodzi poza CP; powstaje ISI i ICI zależna od mocy dalekich ech; potrzeba dłuższego CP (np. tryby z długim GI) lub korektora w dziedzinie czasu
5. $\pi^2\cdot 0\text{,}05^2/3 \approx 8\text{,}2\cdot 10^{-3}$ → ok. −21 dB — ogranicza SNR do ok. 21 dB nawet bez szumu
</details>

## Źródła

- [PySDR: A Guide to SDR and DSP using Python](https://pysdr.org) — rozdziały o OFDM i synchronizacji
- [MIT 6.450 Principles of Digital Communication I (2006)](https://ocw.mit.edu/courses/6-450-principles-of-digital-communications-i-fall-2006/)
- [13.07 OFDM i wielodostęp](../../modules/13-telekomunikacja/07-ofdm-i-wielodostep.md)
- T. M. Schmidl, D. C. Cox — *Robust Frequency and Timing Synchronization for OFDM*, IEEE Trans. Communications, 1997 (płatny artykuł)
