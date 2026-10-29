# 07.01 — Przetwarzanie A/C i C/A

## Po co to jest

Przetwornik to granica między światem analogowym i cyfrowym — jego jakość ogranicza cały system. Wiedza o kwantyzacji, ENOB i architekturach pozwala dobrać przetwornik do zadania i nie oczekiwać od 24-bitowego układu 24 bitów prawdziwej rozdzielczości.

## Teoria w pigułce

### Kwantyzacja

Przetwornik $N$-bitowy o zakresie $U_{FS}$ ma krok $\text{LSB} = U_{FS}/2^N$. Błąd kwantyzacji (dla sygnału „ruchliwego”) jest równomiernie rozłożony w $\pm\text{LSB}/2$:

$$U_{q,RMS} = \frac{\text{LSB}}{\sqrt{12}}$$

**Teoretyczny SNR dla pełnozakresowej sinusoidy:**

$$\text{SNR} = 6\text{,}02N + 1\text{,}76\ \text{dB}$$

Każdy bit to ok. 6 dB. Sygnał o amplitudzie mniejszej niż pełny zakres traci odpowiednio SNR (−6 dB amplitudy = −6 dB SNR).

### Parametry rzeczywistych przetworników

| Parametr | Znaczenie |
|---|---|
| **INL / DNL** | Nieliniowość całkowa i różniczkowa (w LSB); DNL < −1 LSB → brakujące kody |
| Offset, błąd wzmocnienia | Błędy statyczne, kalibrowalne |
| **SINAD** | Stosunek sygnału do szumu i zniekształceń razem |
| **ENOB** | Efektywna liczba bitów: $\text{ENOB} = \dfrac{\text{SINAD} - 1\text{,}76}{6\text{,}02}$ |
| SFDR | Odstęp sygnału od największej składowej pasożytniczej |
| Pasmo wejściowe, czas akwizycji | Ile czasu potrzebuje układ próbkująco-pamiętający |
| Napięcie odniesienia | Jego szum i dryft wprost przechodzą na wynik |

### Architektury przetworników A/C

| Architektura | Rozdzielczość | Szybkość | Zastosowanie |
|---|---|---|---|
| **SAR** (sukcesywnej aproksymacji) | 8–18 bitów | do kilku MS/s | Mikrokontrolery, pomiary ogólne |
| **Sigma-delta** | 16–32 bity | do kilkuset kS/s (wąskie pasmo) | Audio, wagi, precyzyjne pomiary |
| Flash | 4–8 bitów | GS/s | Oscyloskopy, radar |
| Pipeline | 10–16 bitów | dziesiątki–setki MS/s | Telekomunikacja, wideo |
| Całkujący (dual-slope) | wysoka | wolny | Multimetry; tłumi 50 Hz |

### Nadpróbkowanie i kształtowanie szumu

Próbkowanie z częstotliwością $\text{OSR}$ razy większą niż potrzeba rozkłada szum kwantyzacji na szersze pasmo; po filtracji cyfrowej zysk wynosi $10\log_{10}\text{OSR}$ dB (4× → +6 dB, czyli +1 bit). Warunkiem jest obecność szumu (dither), który „rozmywa” sygnał na kilka kodów. Przetworniki sigma-delta dodatkowo **kształtują szum** — wypychają go do wysokich częstotliwości, skąd usuwa go filtr decymacyjny.

### Przetworniki C/A

Drabinka R-2R, łańcuch rezystorów, sigma-delta, PWM z filtrem RC (najprostszy „C/A” w mikrokontrolerze). Wyjście typu zero-order hold — [06.06](../06-sygnaly-i-systemy/06-probkowanie.md).

## Przykład rozwiązany

Przetwornik 12-bitowy, zakres 0–3,3 V.

1. $\text{LSB} = 3\text{,}3/4096 \approx 0\text{,}806$ mV, szum kwantyzacji ≈ 0,233 mV RMS.
2. Teoretyczny SNR = 74 dB. W dokumentacji SINAD = 70 dB → ENOB ≈ 11,3 bitu.
3. Uśrednianie 16 próbek (OSR = 16): zysk 12 dB, czyli ok. 2 bity — pod warunkiem, że szum na wejściu wynosi co najmniej ok. 1 LSB.
4. Pomiar napięcia 10 mV z tego przetwornika: ok. 12 kodów — rozdzielczość względna tylko ok. 8%. Potrzebny wzmacniacz przed przetwornikiem (moduł [04](../04-uklady-analogowe/)).

## Typowe pułapki

- **Rozdzielczość mylona z dokładnością.** 24-bitowy przetwornik z niestabilnym napięciem odniesienia może być mniej dokładny niż 12-bitowy z dobrym.
- **Wysoka impedancja źródła na wejściu SAR** — kondensator próbkujący nie zdąży się naładować w czasie akwizycji.
- **Uśrednianie sygnału bez szumu** — wynik nie poprawia rozdzielczości (wszystkie próbki dają ten sam kod).
- **Sigma-delta do pomiarów multipleksowanych** — filtr cyfrowy potrzebuje czasu na ustalenie po zmianie kanału.

## Ćwiczenie komputerowe

```python
import numpy as np
fs, N, f = 1e6, 2**16, 1e6*1021/2**16      # częstotliwość „koherentna” — całkowita liczba okresów
t = np.arange(N)/fs
for bits in [8, 12, 16]:
    x = np.sin(2*np.pi*f*t)
    q = np.round(x*(2**(bits-1) - 1))/(2**(bits-1) - 1)
    snr = 10*np.log10(np.mean(x**2)/np.mean((q - x)**2))
    print(bits, "bit:", round(snr, 1), "dB  teoria:", round(6.02*bits + 1.76, 1))
```

## Zadania

1. Teoretyczny SNR przetwornika 12- i 16-bitowego?
2. Zmierzono SINAD 70 dB. Ile wynosi ENOB?
3. Przetwornik 12-bitowy, zakres 3,3 V: LSB i szum kwantyzacji RMS.
4. Ile razy trzeba nadpróbkować sygnał, aby zyskać 2 bity rozdzielczości (bez kształtowania szumu)?
5. Sygnał wykorzystuje tylko 1/4 zakresu przetwornika 16-bitowego. Ile wynosi teoretyczny SNR?
6. Dlaczego multimetry stosują przetworniki całkujące z czasem integracji 20 ms (lub jego wielokrotnością)?

<details>
<summary>Odpowiedzi</summary>

1. 74,0 dB i ≈ 98,1 dB
2. ≈ 11,3 bitu
3. ≈ 0,806 mV; ≈ 0,233 mV
4. 16 razy
5. $98\text{,}1 - 12 \approx 86$ dB (amplituda 4 razy mniejsza = −12 dB)
6. Całkowanie przez pełny okres 50 Hz zeruje wpływ zakłóceń sieciowych (filtr o zerze transmisji przy 50 Hz i jej harmonicznych)
</details>

## Źródła

- [The Scientist and Engineer's Guide to DSP — rozdział 3 *ADC and DAC*](http://www.dspguide.com/)
- [Analog Devices — Electronics I and II, rozdziały 18–20](https://wiki.analog.com/university/courses/electronics/text/electronics-toc) — przetworniki C/A i A/C
- [Operational Amplifiers & Linear ICs — J. M. Fiore, rozdział o konwersji A/C i C/A](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html)
