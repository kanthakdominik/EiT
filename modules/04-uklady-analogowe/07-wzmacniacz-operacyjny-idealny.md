# 04.07 — Wzmacniacz operacyjny: układy podstawowe

## Po co to jest

Wzmacniacz operacyjny to uniwersalny blok analogowy: wzmacnia, sumuje, odejmuje, całkuje, filtruje, zamienia prąd na napięcie. Większość torów analogowych w nowoczesnych urządzeniach buduje się na wzmacniaczach operacyjnych, a nie na dyskretnych tranzystorach.

## Teoria w pigułce

### Model idealny i „złote reguły”

Wzmacniacz idealny: nieskończone wzmocnienie, nieskończona rezystancja wejściowa, zerowa wyjściowa, nieskończone pasmo. W układzie z **ujemnym** sprzężeniem zwrotnym:

1. **Wejścia nie pobierają prądu.**
2. **Napięcia na obu wejściach są równe** (wzmacniacz robi wszystko, by tak było).

Reguła 2 obowiązuje tylko przy ujemnym sprzężeniu i gdy wyjście nie jest nasycone.

### Układy podstawowe

| Układ | Wzór | Uwagi |
|---|---|---|
| Wzmacniacz odwracający | $u_{wy} = -\dfrac{R_2}{R_1}u_{we}$ | $R_{we} = R_1$; wejście „−” to masa wirtualna |
| Wzmacniacz nieodwracający | $u_{wy} = \left(1 + \dfrac{R_2}{R_1}\right)u_{we}$ | $R_{we}$ bardzo duża |
| Wtórnik (bufor) | $u_{wy} = u_{we}$ | Bufor o dużej $R_{we}$ i małej $R_{wy}$ |
| Sumator odwracający | $u_{wy} = -R_f\left(\dfrac{u_1}{R_1} + \dfrac{u_2}{R_2} + \dots\right)$ | Miksery, przetworniki C/A |
| Wzmacniacz różnicowy (odejmujący) | $u_{wy} = \dfrac{R_2}{R_1}(u_2 - u_1)$ przy dopasowanych parach rezystorów | CMRR zależy od dopasowania rezystorów |
| Wzmacniacz pomiarowy (3 wzm. op.) | $u_{wy} = \left(1 + \dfrac{2R}{R_G}\right)\dfrac{R_3}{R_2}(u_2 - u_1)$ | Bardzo duża $R_{we}$ obu wejść, wzmocnienie jednym rezystorem $R_G$ |
| Przetwornik prąd–napięcie (TIA) | $u_{wy} = -i_{we}R_f$ | Fotodiody, pomiar małych prądów |
| Integrator | $u_{wy} = -\dfrac{1}{RC}\int u_{we}\,dt$ | W praktyce z rezystorem równoległym do $C$ |
| Różniczkator | $u_{wy} = -RC\dfrac{du_{we}}{dt}$ | W praktyce z rezystorem szeregowym — inaczej wzbudza się i szumi |

### Zasilanie pojedyncze

Przy zasilaniu jednym napięciem (np. 3,3 V) sygnał prowadzi się wokół połowy zasilania (sztuczna masa $V_{CC}/2$ z dzielnika i bufora) albo stosuje się wzmacniacze z wejściem i wyjściem „rail-to-rail”. Sygnały sprzęga się kondensatorami lub przesuwa poziom wzmacniaczem z przesunięciem.

## Przykład rozwiązany

**Wzmacniacz pomiarowy** dla mostka tensometrycznego: sygnał różnicowy do 10 mV, wyjście do przetwornika 0–2 V (przy zasilaniu symetrycznym pomijamy na razie przesunięcie).

1. Potrzebne wzmocnienie: 200.
2. Stopień różnicowy z $R_2 = R_3$ (wzmocnienie 1), stopień wejściowy: $1 + 2R/R_G = 200$.
3. Przy $R = 25$ kΩ: $R_G = \dfrac{2\cdot 25\ \text{k}}{199} \approx 251\ \Omega$ → 249 Ω (szereg E96), wzmocnienie ≈ 202.

**Integrator:** $R = 10$ kΩ, $C = 10$ nF, na wejściu skok 1 V. Wyjście opada liniowo z szybkością $\dfrac{1}{RC} = 10^4$ V/s, czyli 10 V/ms — po ok. 1,2 ms dojdzie do nasycenia przy zasilaniu ±12 V. Rezystor 1 MΩ równolegle do $C$ ograniczy wzmocnienie dla DC do 100 i zapobiegnie dryftowi do nasycenia od offsetu.

## Typowe pułapki

- **Reguła „równych napięć” przy dodatnim sprzężeniu** (komparator z histerezą) lub przy nasyconym wyjściu.
- **Wzmacniacz różnicowy z rezystorów 5%** — CMRR spada do kilkudziesięciu dB.
- **Wtórnik napięciowy z dużym obciążeniem pojemnościowym** — wzbudzenie.
- **Integrator bez ścieżki dla DC** — offset i prądy polaryzacji ładują kondensator, wyjście dryfuje do szyny.
- **Zakres napięć wejściowych i wyjściowych** — wiele wzmacniaczy nie działa poprawnie blisko szyn zasilania.

## Symulacja

```spice
* 04.07 wzmacniacz odwracajacy i integrator (model idealny)
VIN in 0 PULSE(-1 1 0 1u 1u 0.5m 1m)
R1 in n1 10k
R2 n1 out1 100k
E1 out1 0 0 n1 1e5
R3 in n2 10k
C3 n2 out2 10n
R4 n2 out2 1meg
E2 out2 0 0 n2 1e5
.tran 0 3m
.end
```

Źródła `E` modelują wzmacniacze o wzmocnieniu $10^5$ bez ograniczeń. Następnie zastąp je modelem rzeczywistego wzmacniacza z biblioteki LTspice (np. z zasilaniem ±12 V) i porównaj — zobaczysz nasycenie i ograniczoną szybkość narastania.

## Zadania

1. Wzmacniacz odwracający: $R_1 = 10$ kΩ, $R_2 = 100$ kΩ. Wzmocnienie i rezystancja wejściowa?
2. Wzmacniacz nieodwracający o wzmocnieniu 11 — dobierz rezystory.
3. Sumator: $R_1 = R_2 = 10$ kΩ, $R_f = 20$ kΩ, $u_1 = 0\text{,}5$ V, $u_2 = -0\text{,}2$ V. Ile wynosi $u_{wy}$?
4. Wzmacniacz pomiarowy: $R = 25$ kΩ, $R_G = 500\ \Omega$, stopień różnicowy o wzmocnieniu 1. Jakie jest wzmocnienie?
5. Fotodioda daje 0,5 µA. Jaki rezystor TIA da 1 V na wyjściu?
6. Integrator $R = 10$ kΩ, $C = 10$ nF, wejście +1 V. Z jaką szybkością zmienia się wyjście i w którą stronę?

<details>
<summary>Odpowiedzi</summary>

1. −10, 10 kΩ
2. Np. $R_1 = 10$ kΩ, $R_2 = 100$ kΩ
3. $-20\left(\dfrac{0\text{,}5}{10} - \dfrac{0\text{,}2}{10}\right) = -0\text{,}6$ V
4. $1 + 50\ \text{k}/500 = 101$
5. 2 MΩ (napięcie ujemne przy kierunku prądu wpływającego do wejścia „−”)
6. −10 V/ms (narasta w kierunku ujemnym)
</details>

## Źródła

- [Operational Amplifiers & Linear ICs — J. M. Fiore, rozdziały 4 *Basic Op Amp Circuits* i 6 *Specialized Op Amps*](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html) — w tym zasilanie pojedyncze i wzmacniacze pomiarowe
- [MIT 6.002 Circuits and Electronics](https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/) — wykłady o abstrakcji wzmacniacza operacyjnego i jego układach
- [Analog Devices — Electronics I and II](https://wiki.analog.com/university/courses/electronics/text/electronics-toc)
- [Falstad — demonstracje wzmacniaczy operacyjnych](https://falstad.com/circuit/e-index.html)
