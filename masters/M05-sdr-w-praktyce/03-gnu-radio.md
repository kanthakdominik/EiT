# M05.03 — GNU Radio: grafy przepływu i własne bloki

## Po co to jest

GNU Radio to otwarty zestaw narzędzi do budowy systemów radiowych z gotowych bloków przetwarzania sygnałów, łączonych w **grafy przepływu** (flowgraphs) — graficznie w GNU Radio Companion (GRC) lub w Pythonie. Działa z niemal każdym SDR (RTL-SDR, HackRF, Pluto, USRP, LimeSDR), ma setki gotowych bloków (filtry, modulatory, synchronizatory, OFDM, kodowanie) i jest standardem w dydaktyce, prototypowaniu i badaniach. Kto rozumie, jak działa planista strumieni i jak napisać własny blok, może szybko przejść od algorytmu w numpy do odbiornika pracującego w czasie rzeczywistym.

## Teoria w pigułce

### Graf przepływu

- **Bloki** z portami wejścia/wyjścia o określonym typie próbek: `complex` (float32 I + Q), `float`, `short`, `byte`.
- **Źródła** (SDR — np. *Soapy*/*osmocom*/*UHD*/*PlutoSDR Source*, plik, generator sygnału), **przetwarzanie** (filtry, *Frequency Xlating FIR*, demodulatory, *Symbol Sync*, *Costas Loop*), **ujścia** (*QT GUI Frequency/Time/Constellation Sink*, karta dźwiękowa, plik, UDP/ZMQ).
- **Planista** (scheduler) uruchamia bloki w osobnych wątkach i przekazuje dane przez bufory cykliczne; każdy blok przetwarza **porcję o zmiennej długości** — dlatego bloki muszą przechowywać stan (fazę NCO, linię opóźniającą filtru, fazę decymacji) między wywołaniami.
- **Typy bloków:** *sync* (1:1), *decim* (M:1), *interp* (1:L), *general* (dowolny stosunek, sam zgłasza zużyte wejście).
- **Znaczniki strumienia** (stream tags) — metadane przypięte do konkretnej próbki (np. „tu zaczyna się ramka”, czas odbioru); **komunikaty** (PMT) — asynchroniczne pakiety, np. zdekodowane ramki.
- W symulacji bez sprzętu potrzebny jest blok *Throttle*, który ogranicza szybkość — inaczej graf zajmie cały procesor.

### Typowy odbiornik w GRC

*Źródło SDR* (2,4 MS/s) → *Frequency Xlating FIR Filter* (przesunięcie, filtr kanałowy i decymacja w jednym) → demodulator (*WBFM Receive*, *Quadrature Demod*, *Symbol Sync* + *Costas Loop* + *Constellation Decoder*) → *Rational Resampler* → *Audio Sink* lub dekoder ramek; równolegle wskaźniki *QT GUI*. Parametry (częstotliwość, wzmocnienie) jako *Variable* z suwakami *QT GUI Range*.

### Własne bloki

- **Embedded Python Block** w GRC — klasa dziedzicząca z `gr.sync_block` (lub `decim_block`, `basic_block`) z metodą `work`; najszybsza droga od numpy do działającego grafu.
- **Moduły OOT** (out-of-tree) tworzone narzędziem `gr_modtool` — bloki w C++ (wydajność) lub Pythonie, z testami i plikami opisu dla GRC.
- Wydajność: numpy w `work` operuje na całych porcjach; pętle Pythona po próbkach są za wolne przy MS/s — wtedy C++ lub biblioteki wektorowe (VOLK).

## Przykład rozwiązany

**Strumień a wsad.** Odbiornik: przesunięcie o −150 kHz, filtr FIR 63 współczynniki z decymacją 8× (1 MS/s → 125 kS/s), moduł kwadrat. Ten sam łańcuch wykonany raz na całym sygnale i w porcjach o losowej długości 1–4095 próbek (jak planista GNU Radio) z blokami pamiętającymi stan:

- liczba próbek wyjściowych identyczna (25 000),
- maksymalna różnica wyników $3\text{,}5\cdot 10^{-12}$ (błędy zaokrągleń akumulacji fazy).

Bez przechowywania fazy NCO i stanu filtru (każda porcja „od zera”) wynik miałby nieciągłości co porcję — typowy błąd pierwszego własnego bloku.

## Typowe pułapki

- **Brak bloku Throttle** w symulacji (zajęty procesor, „zawieszony” GUI) lub Throttle **w grafie ze sprzętem** (dwa zegary — przepełnienia i niedobory buforów).
- **Niezgodne typy portów** (`complex` z `float`) i niezgodne szybkości próbkowania między blokami — GRC pokazuje błąd typu, ale szybkości nie sprawdza.
- **Blok Python z pętlą po próbkach** — nie nadąża w czasie rzeczywistym (komunikaty „O”/„U” — overflow/underflow).
- **Zwrócenie z `work` złej liczby próbek** lub zapis poza `output_items` — zawieszenie grafu lub błędne dane.
- **Wzmocnienie sprzętu ustawione na stałe** przy zmiennym poziomie sygnału — przesterowanie albo sygnał w szumie kwantyzacji.

## Ćwiczenie komputerowe

Model strumieniowego przetwarzania jak w GNU Radio — bloki z pamięcią stanu, porcje o losowej długości:

```python
import numpy as np
from scipy import signal

# Model przepływu strumieniowego jak w GNU Radio: bloki z pamięcią stanu, dane w porcjach
class Rotator:                                    # odpowiednik bloku "Rotator" / "Frequency Xlating"
    def __init__(self, f, fs):
        self.dphi, self.phi = -2 * np.pi * f / fs, 0.0
    def work(self, x):
        ph = self.phi + self.dphi * np.arange(len(x))
        self.phi = (self.phi + self.dphi * len(x)) % (2 * np.pi)   # ciągłość fazy między porcjami
        return x * np.exp(1j * ph)

class FirDecim:                                   # odpowiednik "Decimating FIR Filter"
    def __init__(self, h, M):
        self.h, self.M = h, M
        self.zi = np.zeros(len(h) - 1, complex)
        self.offset = 0                           # która próbka porcji jest pierwszą do zachowania
    def work(self, x):
        y, self.zi = signal.lfilter(self.h, 1, x, zi=self.zi)
        out = y[self.offset::self.M]
        self.offset = (self.offset - len(x)) % self.M
        return out

class Magnitude:                                  # "Complex to Mag^2"
    def work(self, x):
        return np.abs(x)**2

fs, M = 1e6, 8
rng = np.random.default_rng(3)
n = np.arange(200_000)
x = np.exp(2j * np.pi * 150e3 * n / fs) + 0.1 * (rng.standard_normal(n.size) + 1j * rng.standard_normal(n.size))
h = signal.firwin(63, 0.8 / M)

# Przetwarzanie wsadowe (cały sygnał naraz)
ref = Magnitude().work(signal.lfilter(h, 1, x * np.exp(-2j * np.pi * 150e3 * n / fs))[::M])

# Przetwarzanie strumieniowe porcjami o losowej długości (jak planista GNU Radio)
graf = [Rotator(150e3, fs), FirDecim(h, M), Magnitude()]
wyjscie, i = [], 0
while i < len(x):
    porcja = x[i:i + rng.integers(1, 4096)]
    i += len(porcja)
    for blok in graf:
        porcja = blok.work(porcja)
    wyjscie.append(porcja)
wyjscie = np.concatenate(wyjscie)

print(f"próbek wyjściowych: {len(wyjscie)} (oczekiwane {len(ref)})")
print(f"maks. różnica strumień - wsad: {np.max(np.abs(wyjscie - ref)):.2e}")
print(f"średnia moc po filtrze: {wyjscie[100:].mean():.3f} (ton 1 + szum w paśmie ok. {0.02 * 0.8 / M:.4f})")
```

Ten sam blok jako *Embedded Python Block* w GNU Radio (wymaga zainstalowanego GNU Radio, nie jest uruchamiany automatycznie):

```python
import numpy as np
from gnuradio import gr

class blk(gr.sync_block):
    """Bramka szumowa: zeruje próbki o module poniżej progu."""
    def __init__(self, prog=0.1):
        gr.sync_block.__init__(self, name="Bramka szumowa",
                               in_sig=[np.complex64], out_sig=[np.complex64])
        self.prog = prog                    # parametr widoczny w GRC

    def work(self, input_items, output_items):
        x = input_items[0]
        output_items[0][:] = np.where(np.abs(x) > self.prog, x, 0)
        return len(output_items[0])         # liczba wyprodukowanych próbek
```

Ćwiczenia w GRC: (1) graf z *Signal Source*, *Noise Source*, *Throttle* i *QT GUI Frequency Sink* — obserwuj zysk przetwarzania przy zmianie rozdzielczości FFT; (2) odbiornik FM ([04](04-demodulacja-analogowa.md)) z RTL-SDR; (3) zapis próbek do pliku (*File Sink*) i przetwarzanie ich offline w numpy (`np.fromfile(..., dtype=np.complex64)`).

## Zadania

1. Blok decymujący 8× dostaje porcję 1003 próbek. Ile próbek wyprodukuje i od której próbki następnej porcji musi zacząć?
2. Dlaczego bloki w GNU Radio pracują na porcjach zmiennej długości, a nie na stałych ramkach?
3. Do czego służą znaczniki strumienia? Podaj przykład.
4. Graf ze źródłem RTL-SDR i blokiem Throttle zgłasza przepełnienia. Dlaczego?
5. Jak przenieść algorytm napisany w numpy do działającego odbiornika GNU Radio, nie pisząc C++?

<details>
<summary>Odpowiedzi</summary>

1. Zależnie od fazy decymacji 125 lub 126 próbek (1003 = 125·8 + 3); faza dla następnej porcji wynika z liczby próbek „pozostałych” po ostatniej zachowanej — tak jak `offset` w ćwiczeniu
2. Planista dostosowuje porcje do dostępnych danych i miejsca w buforach, co minimalizuje opóźnienia i pozwala różnym blokom pracować z różną szybkością
3. Do przenoszenia metadanych zsynchronizowanych z próbką — np. synchronizator ramki oznacza początek pakietu, a dekoder dalej wie, od której próbki czytać nagłówek; źródło UHD oznacza czas odbioru
4. Sprzęt narzuca szybkość (zegar przetwornika); Throttle wprowadza drugi, programowy zegar i spowalnia graf — dane ze źródła nie są odbierane na czas
5. Embedded Python Block z operacjami wektorowymi numpy w `work` (stan w polach obiektu) albo moduł OOT w Pythonie przez `gr_modtool`
</details>

## Źródła

- [GNU Radio — Guided Tutorial GRC](https://wiki.gnuradio.org/index.php?title=GRC) i [Your First Flowgraph](https://wiki.gnuradio.org/index.php/Your_First_Flowgraph)
- [GNU Radio — Guided Tutorial GNU Radio in Python](https://wiki.gnuradio.org/index.php/Guided_Tutorial_GNU_Radio_in_Python)
- [PySDR: A Guide to SDR and DSP using Python](https://pysdr.org) — rozdział o GNU Radio
