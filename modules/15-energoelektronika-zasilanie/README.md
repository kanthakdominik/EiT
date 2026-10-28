# 15 — Energoelektronika i układy zasilające

> **Status:** 🟡 szkielet — zakres, cele i główne źródła. Pełne notatki i zadania w kolejnym etapie.

## Cel modułu

Projektować zasilanie urządzeń elektronicznych: od stabilizatora liniowego po przetwornicę impulsową, z uwzględnieniem sprawności, ciepła i zakłóceń.

## Wymagania wstępne

- [04 Układy analogowe](../04-uklady-analogowe/), [03 Przyrządy półprzewodnikowe](../03-przyrzady-polprzewodnikowe/) (MOSFET jako klucz), [10 Automatyka](../10-automatyka/) (dla pętli regulacji).

## Tematy

- [ ] Zasilacze liniowe: transformator, prostownik, filtr, stabilizator; bilans mocy i ciepła
- [ ] Stabilizatory LDO: stabilność, wymagania na kondensator wyjściowy
- [ ] Przetwornice DC-DC: buck, boost, buck-boost — zasada działania, tryby CCM i DCM
- [ ] Dobór elementów: dławik (prąd nasycenia), kondensatory (ESR), tranzystor, dioda
- [ ] Straty przewodzenia i przełączania, sprawność
- [ ] Przetwornice izolowane: flyback, forward
- [ ] Sterowanie: PWM, sterowanie napięciowe i prądowe, kompensacja pętli
- [ ] Pompy ładunku
- [ ] Odprowadzanie ciepła: rezystancja termiczna, radiatory
- [ ] Zasilanie bateryjne, ładowanie akumulatorów Li-ion
- [ ] Falowniki i sterowanie silnikami — wprowadzenie

## Główne źródła

- [Analog Devices — Electronics I and II](https://wiki.analog.com/university/courses/electronics/text/electronics-toc) — rozdział o układach zarządzania zasilaniem
- [Operational Amplifiers & Linear ICs — J. M. Fiore](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html) — rozdział o regulacji napięcia
- [LTspice](https://www.analog.com/en/resources/design-tools-and-calculators/ltspice-simulator.html) — gotowe modele przetwornic i obwody demonstracyjne producenta

## Ćwiczenie modułowe

Zaprojektuj przetwornicę buck 12 V → 3,3 V / 1 A: oblicz dławik i kondensator wyjściowy dla zadanych tętnień, zasymuluj w LTspice (rozruch, skok obciążenia), oszacuj sprawność i temperaturę tranzystora.

## Sprawdzian umiejętności

- Liczę współczynnik wypełnienia, tętnienia prądu i napięcia w przetwornicy buck.
- Szacuję straty i dobieram radiator.
- Wybieram między LDO a przetwornicą dla zadanych wymagań.
