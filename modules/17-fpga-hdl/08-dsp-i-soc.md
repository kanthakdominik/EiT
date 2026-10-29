# 17.08 — Przetwarzanie sygnałów w FPGA i systemy SoC

## Po co to jest

FPGA są królami przetwarzania sygnałów w czasie rzeczywistym przy dużych szybkościach: filtrują i demodulują sygnały radiowe, przetwarzają obraz z kamer, liczą FFT dla radarów. Wymaga to przeniesienia algorytmów z modułu [07](../07-cps-dsp/) do arytmetyki stałoprzecinkowej i potoków. Z kolei układy SoC FPGA łączą procesor z logiką programowalną — procesor obsługuje sieć i interfejs użytkownika, logika — szybkie przetwarzanie.

## Teoria w pigułce

### Arytmetyka stałoprzecinkowa

Liczby w formacie Q$m$.$n$ (np. Q1.15: 1 bit znaku/całości, 15 bitów ułamka) — [07.06](../07-cps-dsp/06-realizacja-filtrow.md). Zasady szerokości:
- mnożenie $a$-bitowej przez $b$-bitową → $a + b$ bitów;
- suma $N$ składników → $\lceil\log_2N\rceil$ bitów zapasu (lub suma modułów współczynników);
- na wyjściu: zaokrąglanie (nie obcinanie — obcinanie daje przesunięcie średniej) i **nasycenie** zamiast zawijania przy przepełnieniu.

Bloki DSP (np. mnożarka 18 × 18 lub 18 × 25 z akumulatorem 48 bit) wyznaczają naturalne szerokości. W Verilogu: `signed`, `>>>`, rozszerzanie znaku.

### Filtry FIR w sprzęcie

| Struktura | Cechy |
|---|---|
| Bezpośrednia z drzewem sumatorów | Linia opóźniająca na wejściu, mnożenia równoległe, suma drzewem z rejestrami — jak [hdl/fir5.v](hdl/fir5.v) |
| **Transponowana** | Mnożenie próbki przez wszystkie współczynniki, łańcuch sumatorów z rejestrami — krótka ścieżka krytyczna, dobrze mapuje się na łańcuchy DSP |
| Systoliczna | Regularna, łatwa do potokowania przy wielu współczynnikach |
| Symetryczna | Dla współczynników symetrycznych (liniowa faza) — dodawanie par próbek przed mnożeniem, o połowę mniej mnożeń |
| Multipleksowana w czasie | Jeden DSP obsługuje wiele współczynników, gdy $f_{clk} \gg f_s$ |
| Polifazowa / CIC | Decymacja i interpolacja ([07.07](../07-cps-dsp/07-zmiana-czestotliwosci-probkowania.md)); CIC bez mnożeń |

Inne bloki: NCO/DDS (akumulator fazy + tablica sinusa) i mieszacz cyfrowy (DDC/DUC w radiu programowalnym — [12.08](../12-technika-wcz-rf/08-filtry-i-architektury.md)), CORDIC (obrót wektora: sin/cos, moduł i faza bez mnożarek), FFT (rdzenie potokowe producentów).

### Procesory w FPGA i SoC

| Rozwiązanie | Przykłady | Zastosowanie |
|---|---|---|
| **Soft-procesor** | RISC-V (np. otwarte rdzenie), MicroBlaze, Nios V | Sterowanie, protokoły, interfejs użytkownika — w logice FPGA |
| **SoC FPGA** (twardy procesor) | Układy z rdzeniami ARM Cortex-A/R obok logiki | Linux + akceleratory w logice; łączone magistralą **AXI** |
| HLS (synteza wysokiego poziomu) | C/C++ → HDL | Szybkie tworzenie akceleratorów algorytmicznych |

Podział zadań: **logika** — wszystko, co musi być szybkie, równoległe i deterministyczne (akwizycja, filtry, sterowanie w nanosekundach); **procesor** — złożone, sekwencyjne, zmienne (sieć, system plików, konfiguracja, decyzje). Wymiana danych: rejestry konfiguracyjne (AXI-Lite), strumienie (AXI-Stream), DMA do pamięci.

## Przykład rozwiązany

**Filtr [hdl/fir5.v](hdl/fir5.v)**: współczynniki [1 4 6 4 1]/16 — dolnoprzepustowy, wzmocnienie DC = 1, mnożenia przez 4 i 6 to w praktyce przesunięcia i sumy (synteza nie zużyje bloków DSP). Szerokości: wejście 12 bitów, iloczyny ≤ 6 · 2047 = 12 282 (16 bitów ze znakiem), suma ≤ 16 · 2047 = 32 752 (18 bitów z zapasem), wyjście po podzieleniu przez 16 — wróci do zakresu wejścia. Potok 4 etapów: wynik po 4 taktach, nowa próbka co takt. Testbench porównuje wynik z modelem dla skoków ±1000 (wyjście dochodzi do ±1000 po 4 próbkach) i 40 losowych próbek.

**Kwantyzacja współczynników:** filtr FIR 63 współczynników zaprojektowany oknem Kaisera na ok. 100 dB tłumienia (skrypt poniżej) po zaokrągleniu współczynników do Q1.15 ma już tylko ok. 75 dB, w Q1.11 — ok. 52 dB, w Q1.9 — ok. 43 dB: każdy bit współczynników to w przybliżeniu 6 dB tłumienia w paśmie zaporowym. Wymagane tłumienie wyznacza więc szerokość współczynników (i często wybór bloków DSP 18-bitowych).

## Typowe pułapki

- **Przepełnienie akumulatora** — brak bitów zapasu na sumę.
- **Obcinanie zamiast zaokrąglania** na wyjściu — przesunięcie składowej stałej.
- **Mieszanie liczb ze znakiem i bez znaku w Verilogu** — jedno `unsigned` w wyrażeniu i arytmetyka staje się bez znaku.
- **Brak rejestrów wewnątrz bloków DSP** (potok) — niska częstotliwość pracy.
- **Za mała rozdzielczość współczynników** dla wymaganego tłumienia filtra.
- **Wszystko w procesorze SoC „bo łatwiej”** — utrata zalet FPGA; albo odwrotnie — złożona logika sterująca w HDL, którą lepiej napisać w C.

## Ćwiczenie komputerowe

Wpływ kwantyzacji współczynników na charakterystykę filtra FIR oraz generowanie wektorów testowych dla testbenchu (model `fir5` w arytmetyce całkowitej):

```python
import numpy as np
from scipy import signal

h = signal.firwin(63, 0.2, window=('kaiser', 10))           # filtr dolnoprzepustowy o dużym tłumieniu
w, H = signal.freqz(h, worN=4096)
stop = w > 0.32*np.pi
print(f"zmiennoprzecinkowo: tłumienie w paśmie zaporowym {-20*np.log10(abs(H[stop]).max()):.1f} dB")
for bits in [16, 12, 10, 8]:
    q = np.round(h*2**(bits - 1))/2**(bits - 1)
    _, Hq = signal.freqz(q, worN=4096)
    print(f"Q1.{bits - 1}: tłumienie {-20*np.log10(abs(Hq[stop]).max()):5.1f} dB, "
          f"maks. błąd współczynnika {abs(q - h).max():.2e}")

# wektory testowe dla fir5 (np. do pliku i $readmemh w testbenchu)
x = np.concatenate([np.full(10, 1000), np.full(10, -1000)]).astype(int)
xp = np.concatenate([np.zeros(4, int), x])
y = [(xp[k + 4] + 4*xp[k + 3] + 6*xp[k + 2] + 4*xp[k + 1] + xp[k]) >> 4 for k in range(len(x))]
print("fir5 — wyjście dla skoku +1000/−1000:", [int(v) for v in y])
```

## Zadania

1. Ile bitów potrzebuje akumulator filtra 64 współczynników, wejście 14 bitów, współczynniki 16 bitów (suma modułów współczynników ≤ 1 w Q1.15)?
2. Dlaczego struktura transponowana FIR ma krótszą ścieżkę krytyczną niż bezpośrednia z łańcuchem sumatorów?
3. Zaprojektuj NCO: akumulator fazy 32 bity, zegar 100 MHz. Jaka rozdzielczość częstotliwości? Jakie słowo dla 1 MHz?
4. Które zadania w systemie SDR na SoC FPGA przydzielisz logice, a które procesorowi?
5. Uruchom skrypt (dodaj do listy 13, 14 i 15 bitów) i porównaj tłumienie. Ile bitów współczynników wybierzesz dla tłumienia 60 dB?

<details>
<summary>Odpowiedzi</summary>

1. Iloczyn 14 + 16 = 30 bitów; przy sumie modułów współczynników ≤ 1 wynik mieści się w zakresie wejścia razy 1 — w praktyce 30 bitów + 1–2 bity zapasu (bez tego założenia: + $\log_2 64 = 6$ bitów, czyli 36)
2. W strukturze transponowanej każdy etap to jedno mnożenie i jedno dodawanie z rejestrem — ścieżka nie zależy od liczby współczynników; w bezpośredniej z łańcuchem sumatorów ścieżka rośnie z liczbą współczynników (chyba że zastosuje się drzewo z rejestrami)
3. $\Delta f = 10^8/2^{32} \approx 0\text{,}023$ Hz; słowo $= 10^6\cdot 2^{32}/10^8 \approx 42\,949\,673$
4. Logika: interfejs przetwornika A/C, DDC (NCO, mieszacz, filtry CIC/FIR, decymacja), synchronizacja i demodulacja przy dużych szybkościach, FFT; procesor: sterowanie (strojenie, wzmocnienie), protokoły wyższych warstw, interfejs użytkownika, sieć, zapis danych
5. Dla tego filtra: 12 bitów — ok. 52 dB, 13 — ok. 58 dB, 14 — ok. 63 dB; na 60 dB z zapasem wybierz 14–15 bitów (Q1.13–Q1.14). Zawsze sprawdzaj dla konkretnego filtra
</details>

## Źródła

- [ZipCPU](https://zipcpu.com/) — filtry w FPGA, CORDIC, potokowanie, arytmetyka stałoprzecinkowa
- [Project F](https://github.com/projf/projf-explore) — arytmetyka stałoprzecinkowa i grafika w FPGA
- [07.06 Realizacja filtrów](../07-cps-dsp/06-realizacja-filtrow.md) — kwantyzacja i formaty stałoprzecinkowe
- [PySDR](https://pysdr.org) — algorytmy SDR, które w praktyce realizuje się w FPGA (DDC, filtry, synchronizacja)
