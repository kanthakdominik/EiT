# 21.06 — Szum w układach elektronicznych

## Po co to jest

Szum wyznacza najmniejszy sygnał, który da się zmierzyć: rozdzielczość wagi tensometrycznej, czułość odbiornika, zakres dynamiki toru audio, dokładność termometru. Projektant toru analogowego ([04 Układy analogowe](../04-uklady-analogowe/)) musi umieć policzyć budżet szumów z danych katalogowych i wskazać źródło dominujące — bo tylko jego zmniejszanie ma sens. Temat uzupełnia ujęcie w.cz. ([12.04](../12-technika-wcz-rf/04-szumy.md)) o układy niskiej częstotliwości i pomiarowe.

## Teoria w pigułce

### Fizyczne źródła szumu

| Szum | Gęstość (jednostronna) | Pochodzenie | Przykład wartości |
|---|---|---|---|
| **Termiczny** (Johnsona–Nyquista) | $e_n = \sqrt{4kTR}$ [V/√Hz], $i_n = \sqrt{4kT/R}$ | Ruchy cieplne nośników w każdym rezystorze | 1 kΩ, 300 K: 4,07 nV/√Hz |
| **Śrutowy** | $i_n = \sqrt{2qI}$ [A/√Hz] | Ziarnistość ładunku przy przejściu przez barierę (złącze p-n, fotodioda) | 1 mA: 17,9 pA/√Hz; 1 µA: 0,57 pA/√Hz |
| **$1/f$ (migotania)** | $e_n^2(f) = e_w^2\,f_c/f$ | Pułapki w półprzewodnikach, styki, rezystory grubowarstwowe | Narożnik $f_c$: 1–1000 Hz |
| **Wybuchowy (popcorn)** | Przeskoki dwustanowe | Defekty w półprzewodniku | Widoczny na oscyloskopie jako „schodki” |
| **$kT/C$** | $v_n = \sqrt{kT/C}$ (całkowity) | Szum termiczny ograniczony pojemnością ([21.04](04-procesy-w-ukladach-liniowych.md)) | 10 pF: 20 µV |

- Rezystory idealne (reaktancje) nie szumią; rezystancja dynamiczna złącza $r_d = U_T/I$ nie szumi termicznie, tylko śrutowo — $\sqrt{2qI}\cdot r_d = \sqrt{2kT r_d}$, czyli „połowa” szumu termicznego.
- Szum $1/f$ w rezystorach zależy od technologii: cienkowarstwowe i metalowe — mały, grubowarstwowe i węglowe — duży, zależny od prądu stałego.

### Model szumowy wzmacniacza

Wzmacniacz bezszumowy + dwa źródła na wejściu: napięciowe $e_n$ (szeregowo) i prądowe $i_n$ (równolegle), zwykle nieskorelowane. Szum wejściowy przy rezystancji źródła $R_S$:

$$e_{n,in}^2 = e_n^2 + (i_nR_S)^2 + 4kTR_S$$

- Małe $R_S$: dominuje $e_n$ (wzmacniacze bipolarne, niskoszumne, np. 1 nV/√Hz).
- Duże $R_S$: dominuje $i_n R_S$ (wybierz wzmacniacz JFET/CMOS z $i_n$ rzędu fA/√Hz).
- **Optymalna rezystancja źródła** $R_{opt} = e_n/i_n$ — tu wzmacniacz wnosi najmniej względem szumu termicznego źródła.
- **Współczynnik szumów** $F = \dfrac{e_{n,in}^2}{4kTR_S}$, $NF = 10\log_{10}F$ ([12.04](../12-technika-wcz-rf/04-szumy.md)).
- Szum $1/f$ wzmacniacza: $e_n^2(f) = e_w^2(1 + f_c/f)$; całka w paśmie $[f_L, f_H]$: $e_w^2\left[(f_H - f_L) + f_c\ln(f_H/f_L)\right]$.
- Rezystory sprzężenia zwrotnego też szumią: we wzmacniaczu nieodwracającym ich równoległe połączenie działa jak dodatkowa rezystancja źródła.

### Szum w wartościach międzyszczytowych

Szum gaussowski nie ma maksimum; praktycznie przyjmuje się $V_{p\text{-}p} \approx 6\text{,}6\,\sigma$ (przekroczenia przez 0,1% czasu). Karty katalogowe podają często szum 0,1–10 Hz w wartości p-p.

## Przykład rozwiązany

**Budżet szumów wzmacniacza czujnika:** $R_S = 10$ kΩ, wzmacniacz: $e_w = 10$ nV/√Hz, narożnik $1/f$ przy 100 Hz, $i_n = 1$ pA/√Hz (biały); pasmo 0,1 Hz–10 kHz (filtr idealny); wzmocnienie 100; $T = 300$ K.

| Składnik | Obliczenie | Wartość (wejście, RMS) |
|---|---|---|
| $e_n$ z $1/f$ | $10\ \text{nV}\sqrt{9999\text{,}9 + 100\ln 10^5}$ | 1,06 µV |
| Szum termiczny $R_S$ | $12\text{,}87\ \text{nV}\cdot\sqrt{9999\text{,}9}$ | 1,29 µV |
| $i_n R_S$ | $10\ \text{nV/√Hz}\cdot\sqrt{9999\text{,}9}$ | 1,00 µV |
| **Razem** | suma kwadratów | **1,94 µV** |

Na wyjściu: 194 µV RMS, ok. 1,3 mV p-p. Współczynnik szumów: $NF = 10\log_{10}(1\text{,}94^2/1\text{,}29^2) = 3\text{,}6$ dB. Wszystkie trzy składniki są porównywalne; $R_{opt} = e_w/i_n = 10$ kΩ — wzmacniacz jest dobrze dobrany do źródła. Udział szumu $1/f$ jest niewielki, bo pasmo sięga 10 kHz; dla pasma 0,1–10 Hz zdominowałby budżet.

## Typowe pułapki

- **Dodawanie szumów liniowo** zamiast geometrycznie (dla nieskorelowanych źródeł).
- **Pominięcie szumu rezystorów sprzężenia zwrotnego** — przy dużych wartościach (100 kΩ) może przewyższyć $e_n$ wzmacniacza.
- **Wybór wzmacniacza po samym $e_n$** przy wysokoomowym źródle — decyduje $i_n$.
- **Pasmo szumu = pasmo sygnału** — bez filtru szum zbiera się z całego pasma wzmacniacza.
- **Szum $1/f$ zignorowany w torze DC** (termometry, tensometry) — dominuje; rozwiązaniem są wzmacniacze z autozerowaniem/chopperem albo modulacja sygnału.
- **Rezystory grubowarstwowe w torze niskoszumnym** — nadmiarowy szum $1/f$ zależny od prądu.

## Ćwiczenie komputerowe

```python
import numpy as np

k, q, T = 1.380649e-23, 1.602176634e-19, 300
print(f"szum termiczny 1 kΩ: {np.sqrt(4*k*T*1e3)*1e9:.2f} nV/√Hz;  10 kΩ: {np.sqrt(4*k*T*1e4)*1e9:.2f} nV/√Hz")
print(f"szum śrutowy 1 mA: {np.sqrt(2*q*1e-3)*1e12:.1f} pA/√Hz;  1 µA: {np.sqrt(2*q*1e-6)*1e12:.2f} pA/√Hz")

def budget(Rs, ew, fc, i_n, fL, fH, gain):
    v_e = ew*np.sqrt((fH - fL) + fc*np.log(fH/fL))
    v_r = np.sqrt(4*k*T*Rs*(fH - fL))
    v_i = i_n*Rs*np.sqrt(fH - fL)
    tot = np.sqrt(v_e**2 + v_r**2 + v_i**2)
    print(f"Rs = {Rs/1e3:6.1f} kΩ, pasmo {fL}–{fH} Hz: e_n {v_e*1e6:.3f}, R_s {v_r*1e6:.3f}, i_n·R_s {v_i*1e6:.3f} → "
          f"razem {tot*1e6:.3f} µV (wejście), {tot*gain*1e3:.3f} mV (wyjście), NF = {10*np.log10(tot**2/v_r**2):.1f} dB")

budget(10e3, 10e-9, 100, 1e-12, 0.1, 1e4, 100)     # przykład z tekstu
budget(10e3, 10e-9, 100, 1e-12, 0.1, 10, 100)      # tor wolnozmienny: dominuje 1/f
budget(100, 10e-9, 100, 1e-12, 0.1, 1e4, 100)      # mała rezystancja źródła: dominuje e_n
budget(1e6, 10e-9, 100, 1e-12, 0.1, 1e4, 100)      # duża rezystancja: dominuje i_n

# szum gaussowski: wartość p-p a RMS
rng = np.random.default_rng(0)
x = rng.normal(0, 1, 1_000_000)
lo, hi = np.percentile(x, [0.05, 99.95])
print(f"przedział zawierający 99,9% próbek: {hi - lo:.2f} σ (reguła 6,6 σ)")
```

## Zadania

1. Ile wynosi gęstość szumu termicznego rezystora 50 Ω w 300 K? A w paśmie 1 MHz (RMS)?
2. Fotodioda o prądzie 10 nA pracuje z rezystorem transimpedancyjnym 10 MΩ. Porównaj gęstość szumu śrutowego prądu fotodiody z szumem termicznym rezystora (oba jako prąd).
3. Wzmacniacz ma $e_n = 4$ nV/√Hz i $i_n = 0\text{,}5$ pA/√Hz. Ile wynosi $R_{opt}$? Jaki jest NF przy $R_S = 1$ kΩ (pomiń $1/f$)?
4. Szum 0,1–10 Hz wzmacniacza wynosi 0,5 µV p-p. Ile to RMS?
5. Dlaczego wzmacniacz z autozerowaniem (chopper) usuwa szum $1/f$, ale zwykle ma wyższy szum biały i zakłócenia przy częstotliwości przełączania?

<details>
<summary>Odpowiedzi</summary>

1. $\sqrt{4kT\cdot 50} = 0\text{,}91$ nV/√Hz; w 1 MHz: 0,91 µV
2. Śrutowy: $\sqrt{2q\cdot 10^{-8}} = 57$ fA/√Hz; termiczny rezystora jako prąd: $\sqrt{4kT/10^7} = 41$ fA/√Hz — porównywalne, śrutowy nieco większy
3. $R_{opt} = 4\ \text{nV}/0\text{,}5\ \text{pA} = 8$ kΩ; przy 1 kΩ: $e_{n,in}^2 = 16 + 0\text{,}25 + 16\text{,}6 = 32\text{,}8$ (nV)²/Hz, $NF = 10\log_{10}(32\text{,}8/16\text{,}6) = 3$ dB
4. $0\text{,}5/6\text{,}6 \approx 0\text{,}076$ µV RMS
5. Sygnał jest okresowo modulowany i demodulowany (lub offset jest okresowo mierzony i odejmowany), więc wolne składowe szumu $1/f$ i offset przesuwają się do częstotliwości przełączania i są odfiltrowywane; za to próbkowanie składa szum szerokopasmowy (wyższy poziom białego), a przełączanie wprowadza wstrzykiwanie ładunku i prążki przy $f_{chop}$
</details>

## Źródła

- [Analog Devices — MT-048 Op Amp Noise Relationships](https://www.analog.com/media/en/training-seminars/tutorials/MT-048.pdf) — szum $1/f$ i biały
- [Texas Instruments — Precision Labs: Op Amps](https://www.ti.com/video/series/precision-labs/ti-precision-labs-op-amps.html) — seria wykładów o szumie wzmacniaczy
- [12.04 Szumy w torze w.cz.](../12-technika-wcz-rf/04-szumy.md)
- C. D. Motchenbacher, J. A. Connelly — *Low-Noise Electronic System Design* (płatna)
