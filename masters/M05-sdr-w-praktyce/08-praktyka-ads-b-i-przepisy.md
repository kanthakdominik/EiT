# M05.08 — Praktyka: dekodowanie ADS-B, sygnały do odbioru i przepisy

## Po co to jest

Najlepszy sprawdzian odbiornika to prawdziwe sygnały. Wokół nas nadaje się ich mnóstwo — samoloty (ADS-B), statki (AIS), radiosondy, czujniki w paśmie 433 MHz, stacje FM z RDS, satelity — i wiele z nich można legalnie odbierać tanim RTL-SDR i dekodować własnym kodem. Temat pokazuje pełne dekodowanie ramek ADS-B od próbek do znaku wywoławczego samolotu i zbiera zasady, których trzeba przestrzegać: **odbiór i nadawanie podlegają przepisom**.

## Teoria w pigułce

### ADS-B (Mode S Extended Squitter, 1090 MHz)

- Samoloty co ok. 0,5 s nadają swoje położenie, wysokość, prędkość i identyfikację.
- Modulacja **PPM** 1 Mb/s: bit 1 — impuls w pierwszej połowie mikrosekundy, bit 0 — w drugiej; preambuła 8 µs z impulsami w 0; 1; 3,5; 4,5 µs. RTL-SDR przy 2 MS/s daje dokładnie dwie próbki na bit, a odbiornik pracuje na obwiedni $\lvert I + jQ\rvert$ (bez synchronizacji nośnej).
- Ramka 112 bitów: **DF** (5 b, 17 = rozszerzony squitter), CA (3 b), **adres ICAO** (24 b, unikalny dla samolotu), **ME** (56 b danych; pierwsze 5 bitów to *type code*: 1–4 identyfikacja, 9–18 położenie w powietrzu, 19 prędkość), **PI** (24 b CRC, wielomian 0x1FFF409).
- Położenie kodowane formatem **CPR** (dwie ramki „parzysta” i „nieparzysta” lub położenie odniesienia).
- Gotowe dekodery: dump1090, readsb; biblioteka pyModeS.

### Inne sygnały warte odbioru

| Sygnał | Częstotliwość | Modulacja / format | Co ćwiczy |
|---|---|---|---|
| Radiofonia FM + RDS | 87,5–108 MHz | FM, BPSK 1187,5 b/s na 57 kHz | Demodulacja FM, multipleks, synchronizacja bitów |
| DAB+ | ok. 174–240 MHz | OFDM, DQPSK | OFDM, synchronizacja ([07](07-ofdm-w-sdr.md)) |
| AIS (statki) | 161,975 i 162,025 MHz | GMSK 9600 b/s, HDLC | Demodulacja FSK/GMSK, ramki HDLC, CRC |
| Radiosondy meteorologiczne | ok. 400–406 MHz | FSK | Odbiór telemetrii, śledzenie lotu |
| Czujniki ISM (termometry, piloty) | 433,92 MHz, 868 MHz | OOK/FSK | Analiza nieznanych protokołów (np. rtl_433) |
| GNSS (GPS L1) | 1575,42 MHz | DSSS (C/A, 1,023 Mchip/s), sygnał pod szumem | Korelacja, akwizycja kodu, zysk rozpraszania |

### Przepisy (zasady ogólne — sprawdź aktualne przepisy krajowe)

- **Odbiór:** w wielu krajach, także w Polsce, odbiór emisji przeznaczonych do publicznego odbioru (radiofonia, ADS-B, AIS, sygnały satelitów pogodowych) jest dozwolony. Treść komunikacji, która nie jest przeznaczona dla odbierającego, jest objęta **tajemnicą komunikacji** — nie wolno jej utrwalać, ujawniać ani wykorzystywać; nie wolno też łamać zabezpieczeń.
- **Nadawanie** wymaga uprawnień: pozwolenia radiowego (np. w służbie amatorskiej — po egzaminie krótkofalarskim) albo spełnienia warunków pracy bez pozwolenia (urządzenia krótkiego zasięgu w pasmach ISM/SRD, z limitami mocy i współczynnika wypełnienia). SDR do celów dydaktycznych łączy się **kablem przez tłumik** lub umieszcza w komorze ekranowanej.
- **Tanie SDR nie spełniają norm czystości widma** — harmoniczne i emisje pozapasmowe mogą zakłócać służby bezpieczeństwa (lotnictwo, GNSS, łączność ratunkowa). Celowe zakłócanie jest zabronione i karane.
- W Polsce gospodarką widmem zarządza Urząd Komunikacji Elektronicznej (UKE); podstawą jest ustawa *Prawo komunikacji elektronicznej* i rozporządzenia wykonawcze.

## Przykład rozwiązany

**Ramka `8D4840D6202CC371C32CE0576098`** (przykład z książki *The 1090 Megahertz Riddle*), zmodulowana PPM, próbkowana 2 MS/s z szumem i losową fazą nośnej:

1. Korelacja obwiedni z wzorcem preambuły (impulsy +1, przerwy −1) → kandydaci na początek ramki.
2. Demodulacja: porównanie dwóch próbek każdego bitu.
3. Kontrola CRC-24 — reszta 0, ramka poprawna (dla kandydatów fałszywych CRC odrzuca wynik).
4. Pola: DF = 17, ICAO = 4840D6, TC = 4 (identyfikacja), znak wywoławczy **KLM1023** (8 znaków po 6 bitów).

Skuteczność dekodowania w funkcji SNR impulsu (300 ramek na punkt): 6 dB — 0%, 8 dB — 10,7%, 10 dB — 65%, 12 dB — 96%, 14 dB — 100%. Ramka ma 112 bitów bez korekcji błędów, więc jeden błędny bit ją odrzuca — próg jest ostry.

## Typowe pułapki

- **Antena do 1090 MHz „z zestawu”** i długi kabel — straty kilku dB zmniejszają zasięg o połowę; lepsza prosta antena ćwierćfalowa (ok. 6,9 cm) na zewnątrz i krótki kabel lub LNA przy antenie.
- **Wzmocnienie na maksimum przy lotnisku lub nadajniku GSM** — przesterowanie i utrata ramek.
- **Brak walidacji CRC** — fałszywe ramki z szumu z losowymi adresami.
- **Zapominanie, że położenie CPR wymaga dwóch ramek** lub położenia odniesienia — błędne współrzędne.
- **Nadawanie „na próbę” przez antenę** — naruszenie przepisów, nawet przy małej mocy.

## Ćwiczenie komputerowe

Dekoder ADS-B: preambuła, PPM, CRC-24 i pola ramki oraz skuteczność w funkcji SNR:

```python
import numpy as np

# Odbiór ADS-B (Mode S, 1090 MHz): modulacja PPM 1 Mb/s, próbkowanie 2 MS/s (jak w RTL-SDR)
rng = np.random.default_rng(8)
msg = "8D4840D6202CC371C32CE0576098"            # przykładowa ramka z książki „The 1090 MHz Riddle”
bity = np.array([int(b) for b in bin(int(msg, 16))[2:].zfill(112)])

def crc24(b):                                 # wielomian generujący Mode S: 0x1FFF409
    g = [int(x) for x in bin(0x1FFF409)[2:]]
    r = list(b)
    for i in range(len(r) - 24):
        if r[i]:
            for j in range(25):
                r[i + j] ^= g[j]
    return int("".join(map(str, r[-24:])), 2)

# Nadajnik: preambuła 8 us (impulsy w 0; 1; 3,5; 4,5 us), potem 112 bitów po 1 us
pre = np.zeros(16); pre[[0, 2, 7, 9]] = 1
chipy = np.concatenate([pre] + [[1, 0] if b else [0, 1] for b in bity])
start, amp = 1234, 0.3
r = np.zeros(4000, complex)
r[start:start + chipy.size] = amp * chipy * np.exp(1j * rng.uniform(0, 2 * np.pi))
r += 0.05 * (rng.standard_normal(r.size) + 1j * rng.standard_normal(r.size))
mag = np.abs(r)                               # odbiornik pracuje na obwiedni |I + jQ|

# 1) Wykrycie preambuły: korelacja obwiedni z wzorcem (impulsy +1, przerwy -1);
# 2) demodulacja PPM: porównanie obwiedni w pierwszej i drugiej połowie bitu;
#    kilku najlepszych kandydatów sprawdza się sumą CRC (jak w dekoderze dump1090)
wzor = 2 * pre - 1

def dekoduj(mag, kandydaci=5):
    c = np.correlate(mag, wzor, mode="valid")
    for k in np.argsort(c)[::-1][:kandydaci]:
        if k + 16 + 224 > mag.size:
            continue
        d = mag[k + 16:k + 16 + 224].reshape(112, 2)
        b = (d[:, 0] > d[:, 1]).astype(int)
        if crc24(b) == 0:
            return int(k), b
    return None, None

k, odebrane = dekoduj(mag)
print(f"ramka w próbce {k} (prawdziwa {start}), błędne bity: {np.sum(odebrane != bity)}, CRC poprawne")

# 3) Dekodowanie pól
pole = lambda a, n: int("".join(map(str, odebrane[a:a + n])), 2)
df, icao, tc = pole(0, 5), pole(8, 24), pole(32, 5)
znaki = "#ABCDEFGHIJKLMNOPQRSTUVWXYZ##### ###############0123456789######"
znak_wywolawczy = "".join(znaki[pole(40 + 6 * i, 6)] for i in range(8)).strip("_ #")
print(f"DF = {df} (rozszerzony squitter), ICAO = {icao:06X}, TC = {tc} (identyfikacja), znak: {znak_wywolawczy}")

# 4) Skuteczność w funkcji SNR: ile ramek przechodzi test CRC
for snr_db in (6, 8, 10, 12, 14):
    sigma = amp / 10**(snr_db / 20) / np.sqrt(2)
    ok = 0
    for _ in range(300):
        x = np.zeros(400, complex)
        x[50:50 + chipy.size] = amp * chipy * np.exp(1j * rng.uniform(0, 2 * np.pi))
        m = np.abs(x + sigma * (rng.standard_normal(400) + 1j * rng.standard_normal(400)))
        ok += dekoduj(m)[0] is not None
    print(f"SNR impulsu {snr_db:2d} dB: poprawnych ramek {100 * ok / 300:5.1f} %")
```

Z prawdziwym sygnałem: RTL-SDR, 1090 MHz, 2 MS/s, zapis kilku sekund próbek, wykrywanie wszystkich ramek w nagraniu funkcją `dekoduj` (przesuwając okno) i zestawienie adresów ICAO; porównanie z dump1090. Rozszerzenie: dekodowanie położenia CPR z par ramek parzystych i nieparzystych (algorytm w *The 1090 Megahertz Riddle*).

## Zadania

1. Jaki jest zasięg radiowy (horyzont) odbioru samolotu na wysokości 10 km anteną na wysokości 10 m? Wzór: $d \approx 4\text{,}12(\sqrt{h_1} + \sqrt{h_2})$ km, $h$ w metrach.
2. Ile bitów i ile mikrosekund trwa ramka ADS-B z preambułą?
3. Dlaczego odbiornik ADS-B może pracować na obwiedni sygnału bez synchronizacji nośnej?
4. Jaką długość ma antena ćwierćfalowa dla 1090 MHz?
5. Zakładając niezależne błędy bitów, jakie prawdopodobieństwo błędu bitu odpowiada 96% poprawnych ramek?

<details>
<summary>Odpowiedzi</summary>

1. $4\text{,}12\cdot(100 + 3\text{,}2) \approx 425$ km (w praktyce zwykle 200–400 km, zależnie od anteny i przeszkód)
2. 112 bitów po 1 µs + 8 µs preambuły = 120 µs
3. PPM niesie informację w położeniu impulsu w czasie, a nie w fazie — wystarczy porównać energię w dwóch połowach bitu
4. $\lambda/4 = 0\text{,}275\ \text{m}/4 \approx 6\text{,}9$ cm
5. $(1 - p)^{112} = 0\text{,}96$ → $p \approx 3\text{,}6\cdot 10^{-4}$
</details>

## Źródła

- [J. Sun — The 1090 Megahertz Riddle: A Guide to Decoding Mode S and ADS-B Signals (TU Delft OPEN, darmowa)](https://books.open.tudelft.nl/home/catalog/book/11)
- [RTL-SDR Quick Start Guide](https://www.rtl-sdr.com/rtl-sdr-quick-start-guide/) — instalacja, sterowniki, pierwsze odbiory
- [PySDR: A Guide to SDR and DSP using Python](https://pysdr.org) — rozdziały o RTL-SDR i dekodowaniu sygnałów
- [MIT 6.450 Principles of Digital Communication I (2006)](https://ocw.mit.edu/courses/6-450-principles-of-digital-communications-i-fall-2006/)
