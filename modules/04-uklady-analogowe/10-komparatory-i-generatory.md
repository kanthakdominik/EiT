# 04.10 — Komparatory i generatory

## Po co to jest

Komparator zamienia sygnał analogowy na cyfrowy: wykrywa przekroczenie progu, formuje zbocza, jest sercem przetworników i zabezpieczeń. Generatory dostarczają zegarów, nośnych, sygnałów testowych i przebiegów PWM.

## Teoria w pigułce

### Komparator

Wzmacniacz bez ujemnego sprzężenia (lub z dodatnim) — wyjście przyjmuje jeden z dwóch stanów. Dedykowane komparatory są szybsze od wzmacniaczy operacyjnych i mają wyjścia logiczne (często typu otwarty kolektor/dren).

**Przerzutnik Schmitta (komparator z histerezą)** — dodatnie sprzężenie zwrotne daje dwa progi przełączania, dzięki czemu szum na wolno zmieniającym się sygnale nie powoduje wielokrotnych przełączeń.

Wersja odwracająca (sygnał na wejście „−”, dzielnik $R_1$ do masy i $R_2$ z wyjścia na wejście „+”), wyjście $\pm U_{sat}$:

$$U_{prog} = \pm U_{sat}\frac{R_1}{R_1 + R_2}, \qquad \text{histereza} = 2U_{sat}\frac{R_1}{R_1 + R_2}$$

### Generatory sinusoidalne

**Warunek Barkhausena:** pętla o wzmocnieniu $\lvert A\beta\rvert = 1$ i fazie $0°$ (lub 360°) przy częstotliwości generacji. W praktyce na starcie $\lvert A\beta\rvert$ nieco > 1, a amplitudę stabilizuje nieliniowość lub automatyka (żarówka, termistor, JFET, diody).

| Generator | Częstotliwość | Warunek wzmocnienia |
|---|---|---|
| Mostek Wiena | $f = \dfrac{1}{2\pi RC}$ | Wzmacniacz nieodwracający, wzmocnienie 3 ($R_2/R_1 = 2$) |
| Przesuwnik fazy RC (3 ogniwa) | $f = \dfrac{1}{2\pi RC\sqrt6}$ | Wzmocnienie 29 |
| Colpitts | $f = \dfrac{1}{2\pi\sqrt{LC_s}}$, $C_s = \dfrac{C_1C_2}{C_1 + C_2}$ | Zależne od stosunku $C_1/C_2$ |
| Hartley | $f = \dfrac{1}{2\pi\sqrt{(L_1 + L_2)C}}$ | j.w. dla indukcyjności |
| Kwarcowy | Rezonans kryształu | Bardzo duża dobroć, stabilność ppm |

### Generatory relaksacyjne

**Na wzmacniaczu operacyjnym:** przerzutnik Schmitta + integrator RC (kondensator ładowany z wyjścia przez $R$). Przy progach $\pm\beta U_{sat}$, $\beta = R_1/(R_1 + R_2)$:

$$T = 2RC\ln\frac{1 + \beta}{1 - \beta}$$

Dla $\beta = 0{,}5$: $T = 2RC\ln 3 \approx 2{,}2RC$.

**Układ 555 (astabilny):**

$$f = \frac{1{,}44}{(R_A + 2R_B)C}, \qquad D = \frac{R_A + R_B}{R_A + 2R_B}$$

Generator funkcyjny (prostokąt + trójkąt): przerzutnik Schmitta + integrator w pętli.

## Przykład rozwiązany

**Przerzutnik Schmitta:** $U_{sat} = \pm 12$ V, $R_1 = 10$ kΩ, $R_2 = 100$ kΩ → progi $\pm 12\cdot\dfrac{10}{110} \approx \pm 1{,}09$ V, histereza ≈ 2,18 V.

**Mostek Wiena:** $R = 10$ kΩ, $C = 10$ nF → $f \approx 1{,}59$ kHz; wzmacniacz z $R_1 = 10$ kΩ i $R_2 \approx 20$ kΩ (trochę więcej na start, z ogranicznikiem amplitudy).

**555:** $R_A = 1$ kΩ, $R_B = 10$ kΩ, $C = 10$ nF → $f \approx 6{,}86$ kHz, wypełnienie ≈ 52,4%.

## Typowe pułapki

- **Wzmacniacz operacyjny jako komparator** — wolny, wychodzi z nasycenia z opóźnieniem, wejścia mogą mieć ograniczony zakres różnicowy.
- **Komparator z wyjściem otwarty kolektor bez rezystora podciągającego.**
- **Komparator bez histerezy na wolnym, zaszumionym sygnale** — seria przełączeń przy każdym przejściu przez próg.
- **Generator Wiena bez stabilizacji amplitudy** — wyjście ogranicza się do nasycenia i sinus jest mocno zniekształcony albo drgania gasną.
- **Częstotliwość generatora RC traktowana jako dokładna** — zależy od tolerancji elementów; do dokładności potrzebny kwarc.

## Symulacja

```spice
* 04.10 generator relaksacyjny na wzmacniaczu operacyjnym
R1 p 0 10k
R2 out p 10k
R out n 10k
C n 0 100n IC=0.1
E1 x 0 p n 1e5
* ograniczenie wyjscia do +-12 V
B1 out 0 V=limit(V(x),-12,12)
.tran 0 10m UIC
.end
```

Zmierz okres i porównaj z $2RC\ln 3 \approx 2{,}2$ ms ($f \approx 455$ Hz). W [Falstad](https://falstad.com/circuit/e-index.html) obejrzyj gotowe przykłady z układem 555.

## Zadania

1. Przerzutnik Schmitta: $\pm 12$ V, $R_1 = 10$ kΩ, $R_2 = 100$ kΩ. Wyznacz progi i histerezę.
2. Mostek Wiena dla 1 kHz z kondensatorami 10 nF — dobierz $R$ i wzmocnienie.
3. Generator relaksacyjny: $R = 10$ kΩ, $C = 100$ nF, $\beta = 0{,}5$. Częstotliwość?
4. 555 astabilny: $R_A = 1$ kΩ, $R_B = 10$ kΩ, $C = 10$ nF. Częstotliwość i wypełnienie. Czy w tym układzie można uzyskać wypełnienie poniżej 50%?
5. Colpitts: $L = 10\ \mu$H, $C_1 = C_2 = 1$ nF. Częstotliwość?
6. Sygnał z czujnika zmienia się wolno i ma szum ±50 mV. Jaką minimalną histerezę ustawisz, aby uniknąć wielokrotnych przełączeń?

<details>
<summary>Odpowiedzi</summary>

1. ±1,09 V, 2,18 V
2. $R = \dfrac{1}{2\pi\cdot 10^3\cdot 10^{-8}} \approx 15{,}9$ kΩ (np. 16 kΩ); wzmocnienie 3
3. ≈ 455 Hz
4. ≈ 6,86 kHz, ≈ 52,4%; w podstawowym układzie nie (wypełnienie zawsze > 50%) — potrzebna dioda równoległa do $R_B$
5. $C_s = 0{,}5$ nF, $f \approx 2{,}25$ MHz
6. Większą niż międzyszczytowa amplituda szumu, czyli > 100 mV, z zapasem np. 200 mV
</details>

## Źródła

- [Operational Amplifiers & Linear ICs — J. M. Fiore, rozdziały 7 *Non-Linear Circuits* i 9 *Oscillators and Frequency Generators*](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html)
- [MIT 6.002 Circuits and Electronics](https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/) — wykład o dodatnim sprzężeniu zwrotnym we wzmacniaczu operacyjnym
- [Falstad — demonstracje: wzmacniacze operacyjne i układ 555](https://falstad.com/circuit/e-index.html)
