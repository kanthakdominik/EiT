# 22 — Optoelektronika i fotonika

> **Status:** ✅ pełny

## Cel modułu

Projektować i liczyć układy, w których sygnałem jest światło: sterowanie diod LED i laserowych, tor z fotodiodą i wzmacniaczem transimpedancyjnym, łącze światłowodowe z budżetem mocy, izolację galwaniczną transoptorem, czujniki optyczne i obrazowe. Moduł łączy fizykę półprzewodników ([02.05](../02-fizyka-i-materialy/05-pasma-i-polprzewodniki.md)), przyrządy ([03.08](../03-przyrzady-polprzewodnikowe/08-jfet-elementy-mocy-opto.md)), układy analogowe ([04](../04-uklady-analogowe/)) i szumy ([21](../21-procesy-losowe-szum/)).

## Wymagania wstępne

- [02.05 Pasma i półprzewodniki](../02-fizyka-i-materialy/05-pasma-i-polprzewodniki.md) — przerwa energetyczna, generacja i rekombinacja.
- [03.01 Złącze p-n](../03-przyrzady-polprzewodnikowe/01-zlacze-pn.md), [03.02 Dioda](../03-przyrzady-polprzewodnikowe/02-dioda-modele.md).
- [04.07–04.08 Wzmacniacz operacyjny](../04-uklady-analogowe/08-wzmacniacz-operacyjny-rzeczywisty.md) i [04.06 Stabilność](../04-uklady-analogowe/06-sprzezenie-zwrotne-i-stabilnosc.md) — dla tematu 05.
- [21.06 Szum w układach elektronicznych](../21-procesy-losowe-szum/06-szum-w-ukladach-elektronicznych.md) — szum śrutowy i termiczny.

## Tematy

| # | Temat | Czas (od zera / odświeżenie) |
|---|---|---|
| 01 | [Światło: foton, wielkości radiometryczne i fotometryczne](01-swiatlo-i-fotometria.md) | 5 h / 2 h |
| 02 | [Diody LED i ich sterowanie](02-diody-led.md) | 6 h / 2 h |
| 03 | [Lasery półprzewodnikowe](03-lasery-polprzewodnikowe.md) | 5 h / 2 h |
| 04 | [Fotodetektory](04-fotodetektory.md) | 6 h / 2 h |
| 05 | [Wzmacniacz transimpedancyjny](05-wzmacniacz-transimpedancyjny.md) | 8 h / 3 h |
| 06 | [Światłowody i łącze optyczne](06-swiatlowody-i-lacze-optyczne.md) | 6 h / 2 h |
| 07 | [Transoptory i izolacja galwaniczna](07-transoptory-i-izolacja.md) | 4 h / 1 h |
| 08 | [Czujniki optyczne i obrazowe](08-czujniki-optyczne-i-obrazowe.md) | 6 h / 2 h |

## Test wejściowy (diagnoza)

Około 45 minut.

1. Jaka jest energia fotonu (w eV) światła o długości fali 1240 nm? A 620 nm?
2. Dlaczego krzemowa fotodioda nie wykrywa światła 1550 nm?
3. Czerwona dioda LED ($U_F = 2$ V przy 10 mA) ma świecić z zasilania 5 V. Jaki rezystor szeregowy?
4. Fotodioda daje 1 µA. Jakie napięcie da wzmacniacz transimpedancyjny z rezystorem 100 kΩ?
5. Ile wynosi tłumienie łącza: 10 km światłowodu 0,35 dB/km i dwa złącza po 0,5 dB?
6. Co oznacza CTR = 100% w transoptorze?
7. Czym różni się lumen od wata?

<details>
<summary>Odpowiedzi</summary>

1. $E[\text{eV}] \approx 1240/\lambda[\text{nm}]$: 1 eV; 2 eV
2. Energia fotonu (0,8 eV) jest mniejsza od przerwy energetycznej krzemu (1,12 eV) — foton nie wytworzy pary elektron–dziura
3. $(5 - 2)/0\text{,}01 = 300$ Ω (szereg E24: 300 Ω)
4. $1\ \mu\text{A}\cdot 100\ \text{k}\Omega = 0\text{,}1$ V
5. $3\text{,}5 + 1 = 4\text{,}5$ dB
6. Prąd kolektora fototranzystora równy prądowi diody LED wejściowej
7. Wat mierzy moc promieniowania, lumen — strumień świetlny ważony czułością ludzkiego oka (maks. 683 lm/W przy 555 nm)

**Ocena:** 1, 7 — temat 01; 2 — 04; 3 — 02; 4 — 05; 5 — 06; 6 — 07.
</details>

## Projekt modułowy: optyczne łącze danych z pomiarem

- [ ] **Nadajnik (tematy 02–03):** dioda LED IR (850–940 nm) sterowana źródłem prądowym z modulacją z mikrokontrolera (UART 9600–115 200 b/s lub PWM); pomiar prądu i czasu narastania.
- [ ] **Odbiornik (tematy 04–05):** fotodioda PIN + wzmacniacz transimpedancyjny zaprojektowany na pasmo 3× szybkości transmisji; dobór $C_f$, symulacja w LTspice (pasmo, przeregulowanie, szum), komparator z histerezą ([04.10](../04-uklady-analogowe/10-komparatory-i-generatory.md)).
- [ ] **Łącze (temat 06):** transmisja w powietrzu lub przez tani światłowód plastikowy (POF); budżet mocy, pomiar zasięgu i stopy błędów w funkcji odległości.
- [ ] **Pomiar:** przebiegi oscyloskopem w punktach toru, wykres oka, porównanie pasma i szumu z obliczeniami; raport z budżetem i wnioskami.

## Sprawdzian końcowy modułu

- [ ] Przeliczam długość fali na energię fotonu, moc na liczbę fotonów, waty na lumeny; liczę natężenie oświetlenia.
- [ ] Projektuję sterowanie LED (rezystor, źródło prądowe, PWM) i oceniam wpływ rozrzutu $U_F$ i temperatury.
- [ ] Wyznaczam moc lasera z prądu progowego i sprawności różniczkowej; wiem, dlaczego laser wymaga stabilizacji mocy.
- [ ] Liczę responsywność, prąd ciemny, pasmo i NEP fotodiody; wybieram tryb pracy.
- [ ] Projektuję wzmacniacz transimpedancyjny: pasmo, kompensację $C_f$, szum.
- [ ] Liczę budżet mocy łącza światłowodowego, aperturę numeryczną i ograniczenia dyspersyjne.
- [ ] Projektuję izolację z transoptorem z uwzględnieniem minimalnego CTR i starzenia.
- [ ] Liczę zakres dynamiki i SNR czujnika obrazu; rozumiem zasadę pomiaru czasu przelotu (ToF).

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [RP Photonics Encyclopedia](https://www.rp-photonics.com/encyclopedia.html) | Hasła z fotoniki: lasery, LED, fotodetektory, światłowody — wszystkie tematy |
| [MIT 6.161 Modern Optics Project Laboratory (2005)](https://ocw.mit.edu/courses/6-161-modern-optics-project-laboratory-fall-2005/) | Optyka, lasery, detekcja — wykłady i laboratorium |
| [Hamamatsu — Si photodiodes: technical information (PDF)](https://www.hamamatsu.com/resources/pdf/ssd/si_pd_kspd0001e.pdf) | Fotodiody: responsywność, prąd ciemny, pojemność, układy pracy — temat 04 |
| [Texas Instruments — Transimpedance Considerations for High-Speed Amplifiers (SBOA122)](https://www.ti.com/lit/sboa122) | Pasmo i kompensacja TIA — temat 05 |
| [Texas Instruments — Precision Labs: Op Amps](https://www.ti.com/video/series/precision-labs/ti-precision-labs-op-amps.html) | Stabilność i szum wzmacniaczy (także TIA) — temat 05 |
| [The FOA Reference Guide to Fiber Optics](https://www.thefoa.org/tech/ref/contents.html) | Światłowody, złącza, budżet łącza, pomiary — temat 06 |
| [Vishay — AN04: Impact of Current Transfer Ratio on Optocouplers (PDF)](https://www.vishay.com/docs/80579/an04_impactcurrenttransferratiooptocouplers.pdf) | CTR, dobór rezystorów, starzenie — temat 07 |
| B. E. A. Saleh, M. C. Teich — *Fundamentals of Photonics* (płatna) | Klasyczny podręcznik fotoniki |
| G. Keiser — *Optical Fiber Communications* (płatna) | Telekomunikacja światłowodowa |
| J. Graeme — *Photodiode Amplifiers: Op Amp Solutions* (płatna) | Projektowanie wzmacniaczy fotodiodowych |
