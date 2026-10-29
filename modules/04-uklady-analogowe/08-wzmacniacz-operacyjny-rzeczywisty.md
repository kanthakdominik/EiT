# 04.08 — Wzmacniacz operacyjny: parametry rzeczywiste

## Po co to jest

Model idealny mówi, co układ ma robić. Parametry rzeczywiste mówią, jak dokładnie to zrobi: do jakiej częstotliwości, z jakim błędem stałym, jakim szumem i przy jakich amplitudach. Dobór wzmacniacza operacyjnego to w praktyce kompromis między tymi parametrami, poborem prądu i ceną.

## Teoria w pigułce

### Parametry dynamiczne

**Iloczyn wzmocnienia i pasma (GBW).** Wzmacniacz skompensowany dominującym biegunem ma pasmo:

$$f_{-3\text{dB}} \approx \frac{\text{GBW}}{G_n}, \qquad G_n = 1 + \frac{R_2}{R_1} \text{ (wzmocnienie szumowe)}$$

Uwaga: dla wzmacniacza odwracającego o wzmocnieniu $-R_2/R_1$ pasmo wyznacza wzmocnienie szumowe $1 + R_2/R_1$, a nie $\lvert R_2/R_1\rvert$.

**Szybkość narastania (slew rate, SR)** — maksymalna szybkość zmian napięcia wyjściowego [V/µs]. Ogranicza amplitudę sygnałów szybkich:

$$f_{max} = \frac{SR}{2\pi U_p} \quad \text{(pasmo pełnej mocy)}$$

### Błędy stałe

| Parametr | Skutek na wyjściu | Jak ograniczyć |
|---|---|---|
| Napięcie niezrównoważenia $U_{OS}$ | $U_{OS}\cdot G_n$ | Wzmacniacz precyzyjny (chopper, zero-drift), kalibracja |
| Prądy polaryzacji $I_B$ | $I_B\cdot R$ (na rezystancjach widzianych z wejść) | Równe rezystancje widziane z obu wejść; wzmacniacz z wejściem CMOS/JFET |
| Prąd niezrównoważenia $I_{OS}$ | $I_{OS}\cdot R$ (po kompensacji) | j.w. |
| Dryft temperaturowy | µV/K, pA/K | Wzmacniacze zero-drift |
| CMRR, PSRR | Błąd od napięcia wspólnego i od zasilania | Wybór wzmacniacza, filtracja zasilania |

### Szum

Gęstości szumu napięciowego $e_n$ [nV/√Hz] i prądowego $i_n$ [pA/√Hz], plus szum termiczny rezystorów $\sqrt{4kTR}$ (ok. 4 nV/√Hz dla 1 kΩ w 300 K). Niezależne źródła sumuje się w kwadratach ([00.06](../00-matematyka/06-prawdopodobienstwo-i-statystyka.md)). Szum biały w paśmie $B$: $U_n = e_n\sqrt{B}$ (z poprawką na kształt filtra, np. 1,57× pasmo dla filtra 1. rzędu). Przy niskich częstotliwościach dominuje szum 1/f.

Reguła doboru: dla źródeł niskoomowych liczy się $e_n$ (wzmacniacz bipolarny), dla wysokoomowych — $i_n$ (wejście JFET/CMOS).

### Ograniczenia zakresów

Zakres napięć wejściowych (wspólnych), zakres wyjściowy przy danym obciążeniu (rail-to-rail lub nie), prąd wyjściowy, minimalne stabilne wzmocnienie, obciążenie pojemnościowe.

## Przykład rozwiązany

Wzmacniacz o GBW = 1 MHz, SR = 0,5 V/µs, $U_{OS} = 2$ mV, $I_B = 100$ nA, $e_n = 10$ nV/√Hz.

1. Wzmacniacz nieodwracający o wzmocnieniu 10: pasmo ≈ 100 kHz.
2. Wzmacniacz odwracający o wzmocnieniu −10: $G_n = 11$ → pasmo ≈ 91 kHz.
3. Sinus o amplitudzie 10 V: $f_{max} = \dfrac{0\text{,}5\cdot 10^6}{2\pi\cdot 10} \approx 8$ kHz — **slew rate ogranicza tu bardziej niż GBW**.
4. Wzmocnienie 101 ($R_2 = 100$ kΩ, $R_1 = 1$ kΩ): offset na wyjściu $2\ \text{mV}\cdot 101 = 202$ mV; prąd polaryzacji przez 100 kΩ daje dodatkowo do 10 mV (można skompensować rezystorem ≈ 990 Ω w wejściu nieodwracającym).
5. Szum wejściowy w paśmie 10 kHz (tylko $e_n$): $10\ \text{nV}\cdot\sqrt{10^4} = 1\ \mu$V RMS, na wyjściu ×101 ≈ 0,1 mV RMS.

## Typowe pułapki

- **GBW zamiast slew rate** przy dużych amplitudach (i odwrotnie przy małych).
- **Wzmocnienie odwracające zamiast szumowego** w obliczeniach pasma i offsetu.
- **Wzmacniacz „uniwersalny” przy zasilaniu 3,3 V** — wiele klasycznych układów wymaga kilku woltów zapasu od szyn.
- **Wysokoomowe rezystory sprzężenia z wejściem bipolarnym** — błąd od $I_B$ przewyższa offset.
- **Pominięcie szumu rezystorów** — przy wysokich wartościach rezystorów dominuje nad szumem wzmacniacza.

## Symulacja

Weź z biblioteki LTspice dwa wzmacniacze o różnych parametrach (np. ogólnego przeznaczenia i precyzyjny o małym szumie). Dla wzmacniacza nieodwracającego o wzmocnieniu 101:

- `.ac` — porównaj pasmo z GBW/101,
- `.tran` z sinusem o rosnącej amplitudzie i częstotliwości — znajdź granicę slew rate,
- `.noise V(out) VIN dec 100 1 100k` — porównaj gęstość szumu i szum całkowity (Ctrl + klik na nazwie przebiegu daje wartość całkowaną).

## Zadania

1. GBW = 1 MHz. Pasmo wzmacniacza nieodwracającego o wzmocnieniu 10 i odwracającego o wzmocnieniu −10?
2. SR = 0,5 V/µs. Pasmo pełnej mocy dla amplitudy 10 V i 1 V?
3. $U_{OS} = 2$ mV, wzmocnienie szumowe 101. Jaki offset na wyjściu?
4. $I_B = 100$ nA, rezystor sprzężenia 100 kΩ, rezystor wejściowy 1 kΩ, wejście nieodwracające do masy. Błąd na wyjściu od $I_B$? Jaki rezystor kompensacyjny?
5. $e_n = 10$ nV/√Hz, pasmo 10 kHz, wzmocnienie 101. Szum na wyjściu (bez rezystorów)?
6. Jaka jest gęstość szumu termicznego rezystora 10 kΩ w 300 K? Porównaj ze wzmacniaczem z zadania 5.

<details>
<summary>Odpowiedzi</summary>

1. 100 kHz i ≈ 91 kHz
2. ≈ 8 kHz i ≈ 80 kHz
3. 202 mV
4. $100\ \text{nA}\cdot 100\ \text{k}\Omega = 10$ mV; rezystor $R_1\parallel R_2 \approx 990\ \Omega$ w wejściu nieodwracającym (zostaje błąd od $I_{OS}$)
5. ≈ 0,1 mV RMS
6. $\sqrt{4\cdot 1\text{,}38\cdot 10^{-23}\cdot 300\cdot 10^4} \approx 12\text{,}9$ nV/√Hz — więcej niż szum wzmacniacza; przy takich rezystorach to one dominują
</details>

## Źródła

- [Operational Amplifiers & Linear ICs — J. M. Fiore, rozdział 5 *Practical Limitations of Op Amp Circuits*](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html)
- [Analog Devices — Electronics I and II](https://wiki.analog.com/university/courses/electronics/text/electronics-toc)
- [LTspice](https://www.analog.com/en/resources/design-tools-and-calculators/ltspice-simulator.html) — tutorial analizy AC i szumów
