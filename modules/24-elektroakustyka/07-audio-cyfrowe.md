# 24.07 — Audio cyfrowe

## Po co to jest

Prawie każdy tor audio jest dziś cyfrowy między mikrofonem a głośnikiem: przetwornik A/C, przetwarzanie w DSP lub mikrokontrolerze (korekcja, zwrotnica, kompresja dynamiki, redukcja szumu), transmisja (I²S, USB, Bluetooth, sieć), kodek stratny i przetwornik C/A lub wzmacniacz klasy D z wejściem cyfrowym. Projektant musi dobrać częstotliwość próbkowania i rozdzielczość, skonfigurować zegary, policzyć opóźnienie i przepływność oraz uniknąć typowych artefaktów.

## Teoria w pigułce

### Próbkowanie i rozdzielczość

- Standardowe $f_s$: 44,1 kHz (CD), 48 kHz (wideo, profesjonalne), 96/192 kHz (studio — zapas na filtrację i przetwarzanie), 16 kHz (mowa szerokopasmowa), 8 kHz (telefonia).
- Twierdzenie o próbkowaniu ([07.01](../07-cps-dsp/01-przetwarzanie-ac.md)): pasmo do $f_s/2$; filtr antyaliasingowy — w praktyce przetworniki **sigma-delta** z dużym nadpróbkowaniem i filtrem cyfrowym (decymacja) — analogowy filtr może być wtedy prosty.
- Rozdzielczość: 16 bitów — ok. 98 dB, 24 bity — teoretycznie 146 dB (realne przetworniki: 110–130 dB, ograniczenie analogowe). Wewnątrz DSP — 32 bity stałoprzecinkowe lub zmiennoprzecinkowe, żeby przetwarzanie nie dodawało szumu.
- **Dithering** przy obniżaniu rozdzielczości (24 → 16 bitów) — szum o amplitudzie ok. 1 LSB usuwa zniekształcenia kwantyzacji cichych sygnałów ([21.07](../21-procesy-losowe-szum/07-szum-w-systemach-cyfrowych.md)); kształtowanie szumu przesuwa go w mniej słyszalne pasma.

### Interfejsy

| Interfejs | Zastosowanie | Sygnały |
|---|---|---|
| **I²S / TDM** | Między układami na płytce (kodek, DSP, MCU, wzmacniacz) | BCLK, LRCLK (WS), dane; często MCLK = 256·$f_s$ |
| **PDM** | Mikrofony MEMS cyfrowe | Zegar 1–3 MHz + 1-bitowy strumień |
| S/PDIF, AES3 | Między urządzeniami (koncentryk, optyka) | Samotaktujący kod bifazowy |
| USB Audio | Komputer ↔ urządzenie | Tryby izochroniczne, synchronizacja asynchroniczna |
| Bluetooth (A2DP, LE Audio) | Bezprzewodowo | Kodeki SBC, AAC, aptX, LC3 |

Dla I²S: $\text{BCLK} = f_s\cdot(\text{bitów na kanał})\cdot(\text{liczba kanałów})$ — np. 48 kHz, 32 bity, stereo: 3,072 MHz.

### Zegar i jitter

Jitter zegara przetwornika C/A i A/C wprowadza szum zależny od sygnału ([21.07](../21-procesy-losowe-szum/07-szum-w-systemach-cyfrowych.md)); zegary audio generuje się z kwarców o częstotliwościach będących wielokrotnością 44,1 kHz (22,5792 MHz) lub 48 kHz (24,576 MHz), a odbiorniki S/PDIF i USB używają pętli PLL lub buforów z asynchronicznym taktowaniem. Konwersja częstotliwości próbkowania (ASRC) łączy domeny zegarowe ([07.07](../07-cps-dsp/07-zmiana-czestotliwosci-probkowania.md)).

### Opóźnienie

Bufory (DMA, przetwarzanie blokowe), filtry decymacyjne/interpolacyjne przetworników (kilkadziesiąt próbek), kodeki stratne (20–200 ms), transmisja bezprzewodowa. Granice: odsłuch własnego głosu (monitory, aparaty słuchowe) < ok. 10 ms, rozmowa < 150 ms, synchronizacja z obrazem ok. ±40 ms.

### Kodowanie stratne

Modele psychoakustyczne (temat 02), transformata MDCT, kwantowanie poniżej progu maskowania. Przepływność: PCM 44,1 kHz/16 bitów/stereo — 1411 kb/s; MP3/AAC 128–256 kb/s, Opus 32–128 kb/s.

## Przykład rozwiązany

**Konfiguracja toru:** kodek 48 kHz, 24 bity w ramkach 32-bitowych, stereo, przetwarzanie blokami po 256 próbek.

1. BCLK = $48\,000\cdot 32\cdot 2 = 3\text{,}072$ MHz; MCLK = $256\cdot 48\,000 = 12\text{,}288$ MHz.
2. Opóźnienie bloku: $256/48\,000 = 5\text{,}33$ ms; przy podwójnym buforowaniu (wejście + wyjście) ok. 10,7 ms plus filtry przetworników (ok. 0,5–1 ms) — na granicy akceptowalności dla monitoringu na żywo; blok 64 próbek da ok. 3 ms.
3. Przepływność PCM: $48\,000\cdot 24\cdot 2 = 2\text{,}3$ Mb/s danych użytecznych; dla porównania CD: $44\,100\cdot 16\cdot 2 = 1\text{,}41$ Mb/s, a MP3 128 kb/s — 11 razy mniej.

## Typowe pułapki

- **Mieszanie domen 44,1 i 48 kHz** bez konwersji — trzaski, przesunięcia wysokości tonu.
- **Brak ditheru przy redukcji bitów** — zniekształcenia cichych fragmentów (wybrzmiewanie).
- **Obcinanie (clipping) w przetwarzaniu** — suma kanałów i korekcja podbijająca przekraczają pełną skalę; zostaw zapas (headroom) i używaj arytmetyki o większej rozdzielczości.
- **Przekroczenie czasu przetwarzania bloku** w DSP — przerwy w dźwięku (underrun).
- **Masa cyfrowa w torze analogowym** — szum zegarów i prądów impulsowych w sygnale ([16.05](../16-pcb-emc-konstrukcja/05-masa-i-uklady-mieszane.md)).
- **Zbyt wolny zegar I²S lub złe wyrównanie bitów** (I²S vs left-justified) — przesunięcie o bit, sygnał głośny i zniekształcony.

## Ćwiczenie komputerowe

Dither przy redukcji do 16 bitów cichego sygnału i parametry interfejsu I²S:

```python
import numpy as np

fs, N = 48_000, 48_000
t = np.arange(N)/fs
x = 10**(-90/20)*np.sin(2*np.pi*1000*t)              # ton −90 dBFS (ok. 1 LSB w 16 bitach)
q = 2/2**16

def spectrum_harm(y):
    Y = np.abs(np.fft.rfft(y*np.hanning(N)))
    f = np.fft.rfftfreq(N, 1/fs)
    fund = Y[np.argmin(np.abs(f - 1000))]
    h3 = Y[np.argmin(np.abs(f - 3000))]
    return 20*np.log10(h3/fund + 1e-12)

rng = np.random.default_rng(0)
no_dither = np.round(x/q)*q
tpdf = (rng.uniform(-0.5, 0.5, N) + rng.uniform(-0.5, 0.5, N))*q   # dither trójkątny (TPDF) ±1 LSB
with_dither = np.round((x + tpdf)/q)*q
print(f"3. harmoniczna względem tonu: bez ditheru {spectrum_harm(no_dither):+.1f} dB, z ditherem TPDF {spectrum_harm(with_dither):+.1f} dB")

# zegary i opóźnienia
for fs_, bits, ch, block in ((44_100, 16, 2, 512), (48_000, 32, 2, 256), (48_000, 32, 8, 64)):
    print(f"fs = {fs_} Hz, {bits} bit, {ch} kan.: BCLK = {fs_*bits*ch/1e6:.4f} MHz, MCLK(256fs) = {256*fs_/1e6:.4f} MHz, "
          f"blok {block}: {block/fs_*1e3:.2f} ms")
print(f"CD: {44_100*16*2/1e3:.1f} kb/s; MP3 128 kb/s → kompresja {44_100*16*2/128e3:.1f}:1")
```

Bez ditheru ton o amplitudzie rzędu 1 LSB zamienia się w falę prostokątną z silnymi harmonicznymi; z ditherem błąd kwantyzacji staje się szumem, a harmoniczne znikają (kosztem nieco wyższego poziomu szumu).

## Zadania

1. Jaki BCLK potrzebuje interfejs TDM z 8 kanałami 32-bitowymi przy 96 kHz?
2. Ile pamięci zajmuje 1 minuta dźwięku 48 kHz/24 bity/stereo (bez kompresji)?
3. Dlaczego studia nagrywają z $f_s$ 96 kHz, choć słuch kończy się na 20 kHz?
4. Aparat słuchowy przetwarza dźwięk blokami. Jaki maksymalny blok przy 16 kHz, jeśli całkowite opóźnienie ma być < 8 ms, a bufory podwajają opóźnienie bloku?
5. Dlaczego przetwornik sigma-delta pozwala na prosty analogowy filtr antyaliasingowy?

<details>
<summary>Odpowiedzi</summary>

1. $96\,000\cdot 32\cdot 8 = 24\text{,}576$ MHz
2. $48\,000\cdot 3\ \text{B}\cdot 2\cdot 60 = 17\text{,}3$ MB
3. Zapas na filtrację (łagodniejsze filtry antyaliasingowe bez zniekształceń fazowych w paśmie), przetwarzanie nieliniowe (mniej aliasingu produktów zniekształceń), edycję; ostateczny materiał i tak konwertuje się do 44,1/48 kHz
4. $2\cdot B/16\,000 < 8$ ms → $B < 64$ próbek
5. Modulator pracuje z częstotliwością kilkadziesiąt–kilkaset razy większą niż $f_s$; filtr analogowy musi tłumić dopiero w okolicy tej dużej częstotliwości (np. kilka MHz), a ostre filtrowanie do $f_s/2$ wykonuje cyfrowy filtr decymacyjny
</details>

## Źródła

- [Stanford CCRMA — książki online J. O. Smitha](https://ccrma.stanford.edu/~jos/EE201/Related_Online_Books_CCRMA.html) — DSP audio
- [MIT 21M.380 Music and Technology: Sound Design](https://ocw.mit.edu/courses/21m-380-music-and-technology-sound-design-spring-2016/)
- [07.07 Zmiana częstotliwości próbkowania](../07-cps-dsp/07-zmiana-czestotliwosci-probkowania.md)
- [21.07 Szum w systemach cyfrowych](../21-procesy-losowe-szum/07-szum-w-systemach-cyfrowych.md)
