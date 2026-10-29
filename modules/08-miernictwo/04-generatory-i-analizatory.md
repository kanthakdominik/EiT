# 08.04 — Generatory, częstościomierze, analizatory widma

## Po co to jest

Żeby zmierzyć układ, trzeba go czymś pobudzić i coś odczytać w dziedzinie częstotliwości. Generator DDS, częstościomierz i analizator widma to podstawowe narzędzia przy pracy z filtrami, generatorami, układami w.cz. i badaniami zakłóceń.

## Teoria w pigułce

### Generator DDS (bezpośrednia synteza cyfrowa)

Akumulator fazy $N$-bitowy zwiększany co takt zegara $f_{clk}$ o słowo $M$; najstarsze bity adresują tablicę sinusa, przetwornik C/A i filtr rekonstrukcyjny dają sygnał analogowy.

$$f_{out} = \frac{M\cdot f_{clk}}{2^N}, \qquad \Delta f = \frac{f_{clk}}{2^N}$$

Maksymalna praktyczna częstotliwość ok. 40% $f_{clk}$. Ograniczenia: składowe pasożytnicze (spurs) od obcinania fazy i nieliniowości C/A.

**Impedancja wyjściowa generatora:** typowo 50 Ω. Ustawienie amplitudy zakłada obciążenie 50 Ω — przy obciążeniu wysokoimpedancyjnym napięcie jest **dwa razy większe**. Większość generatorów ma przełącznik „50 Ω / High-Z” zmieniający tylko sposób wyświetlania.

### Częstościomierz

- **Zliczanie bezpośrednie:** liczba okresów w czasie bramki $T_g$ — błąd ±1 zliczenie, czyli rozdzielczość $1/T_g$ (dla 1 s — 1 Hz). Złe dla niskich częstotliwości.
- **Pomiar okresu / zliczanie odwrotne (reciprocal):** zliczanie impulsów wzorcowych w czasie całkowitej liczby okresów — stała rozdzielczość względna.
- Dokładność ograniczona przez wzorzec czasu (kwarc ppm, TCXO, OCXO, odniesienie GPS).

### Analizator widma

| Parametr | Znaczenie |
|---|---|
| **RBW** (resolution bandwidth) | Szerokość filtra pośredniego — rozdzielczość i poziom szumu |
| VBW | Filtracja wyświetlanej obwiedni (wygładzanie) |
| **DANL** (poziom szumów własnych) | $\approx -174\ \text{dBm/Hz} + \text{NF} + 10\log_{10}\text{RBW}$ |
| Czas przemiatania | Rośnie jak $\text{span}/\text{RBW}^2$ |
| Tłumik wejściowy, punkt kompresji | Duże sygnały → zniekształcenia własne analizatora |

Analizator przemiatany (superheterodyna) vs analizator FFT (w czasie rzeczywistym, zwykle węższe pasmo). Oscyloskop z FFT to w praktyce prosty analizator o małej dynamice (8 bitów ≈ 50 dB).

**−174 dBm/Hz** to szum termiczny $kT$ w 290 K w paśmie 1 Hz — wartość, którą warto znać na pamięć.

## Przykład rozwiązany

**DDS:** akumulator 32-bitowy, zegar 125 MHz.

1. Rozdzielczość: $125\cdot 10^6/2^{32} \approx 0\text{,}029$ Hz.
2. Słowo dla 1 MHz: $M = 10^6\cdot 2^{32}/125\cdot 10^6 \approx 34\,359\,738$.

**Analizator widma:** NF = 20 dB, RBW = 1 kHz → DANL ≈ $-174 + 20 + 30 = -124$ dBm. Zmniejszenie RBW do 10 Hz obniża szum o 20 dB (do −144 dBm), ale wydłuża przemiatanie 10 000 razy.

## Typowe pułapki

- **Amplituda generatora w trybie 50 Ω przy obciążeniu wysokoimpedancyjnym** — dwukrotnie większy sygnał.
- **Pomiar częstotliwości 50 Hz zliczaniem przez 1 s** — rozdzielczość tylko 1 Hz (2%).
- **Zbyt silny sygnał na wejściu analizatora** — harmoniczne generowane przez sam analizator.
- **Odczyt mocy szumu z analizatora bez korekcji** na RBW i detektor (szum odczytywany detektorem szczytowym/logarytmicznym wymaga poprawek).

## Ćwiczenie komputerowe

```python
import numpy as np
N, fclk = 32, 125e6
M = round(1e6*2**N/fclk)
print("f_out:", M*fclk/2**N, "Hz  rozdzielczość:", fclk/2**N, "Hz")

# prosty model DDS z obcięciem fazy do 12 bitów — widmo pasożytnicze
n = np.arange(2**16); acc = (n*M) % 2**N
phase = (acc >> (N - 12))/2**12
y = np.sin(2*np.pi*phase)
Y = 20*np.log10(np.abs(np.fft.rfft(y*np.hanning(len(y)))) + 1e-12); Y -= Y.max()
print("najwyższa składowa pasożytnicza:", round(np.sort(Y)[-6], 1), "dBc")
```

## Zadania

1. DDS 32-bitowy, zegar 125 MHz. Rozdzielczość i słowo $M$ dla 1 MHz?
2. Generator ustawiony na 1 Vpp (50 Ω) podłączony do 1 MΩ. Co pokaże oscyloskop? A jeśli obciążysz go rezystorem 50 Ω?
3. Częstościomierz zliczający z bramką 1 s mierzy 50 Hz. Jaka jest rozdzielczość względna? Jak ją poprawić?
4. Analizator: NF = 20 dB, RBW = 1 kHz. Jaki jest DANL? Jak zmieni się przy RBW = 100 Hz?
5. Dlaczego oscyloskop 8-bitowy z funkcją FFT nie nadaje się do pomiaru harmonicznych na poziomie −70 dBc?

<details>
<summary>Odpowiedzi</summary>

1. ≈ 0,029 Hz; $M \approx 34\,359\,738$
2. 2 Vpp; 1 Vpp
3. 1/50 = 2%; pomiar okresu (zliczanie odwrotne) albo dłuższa bramka
4. −124 dBm; −134 dBm
5. Zakres dynamiki 8-bitowego przetwornika to ok. 50 dB (SNR ≈ 50 dB), a jego nieliniowość też generuje harmoniczne na poziomie ok. −40…−50 dBc
</details>

## Źródła

- [Modular Electronics Learning (ModEL) Project](https://ibiblio.org/kuphaldt/socratic/model/) — moduły o pomiarach RF i analizatorach
- [Tektronix — XYZs of Oscilloscopes](https://www.electronicdesign.com/resources/white-papers/whitepaper/21807643/xyzs-of-oscilloscopes-primer) — FFT w oscyloskopie, ograniczenia
- [The Scientist and Engineer's Guide to DSP — rozdziały 3 i 9](http://www.dspguide.com/) — przetworniki i analiza widmowa
