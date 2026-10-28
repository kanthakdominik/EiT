# 12 — Technika wielkich częstotliwości (RF)

> **Status:** 🟡 szkielet — zakres, cele i główne źródła. Pełne notatki i zadania w kolejnym etapie.

## Cel modułu

Analizować i projektować bloki toru radiowego: wzmacniacze w.cz., mieszacze, oscylatory, filtry; posługiwać się parametrami S.

## Wymagania wstępne

- [11 Pole EM, linie, anteny](../11-pole-em-linie-anteny/), [04 Układy analogowe](../04-uklady-analogowe/).

## Tematy

- [ ] Elementy bierne na w.cz.: elementy pasożytnicze, dobroć, rezonans własny
- [ ] Parametry S, macierz rozproszenia, pomiar analizatorem obwodów (VNA)
- [ ] Dopasowanie impedancji obwodami LC (L, π, T)
- [ ] Szumy: współczynnik szumów, temperatura szumowa, wzór Friisa dla szumów
- [ ] Nieliniowość: punkt kompresji 1 dB, IP3, zakres dynamiki
- [ ] Wzmacniacze w.cz.: małoszumowe (LNA), mocy, stabilność (kryterium Rolleta)
- [ ] Mieszacze, przemiana częstotliwości, częstotliwość lustrzana
- [ ] Oscylatory, szum fazowy, pętla PLL, syntezery częstotliwości
- [ ] Filtry w.cz.: LC, ceramiczne, SAW, mikropaskowe
- [ ] Architektury odbiorników: superheterodyna, bezpośrednia przemiana, SDR

## Główne źródła

- [All About Circuits — RF textbook](https://www.allaboutcircuits.com/textbook/) — tom o podstawach RF
- [Electromagnetics, Vol. 2 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-2)
- [Modular Electronics Learning (ModEL) Project](https://ibiblio.org/kuphaldt/socratic/model/) — moduły o pomiarach RF

## Ćwiczenie modułowe

Zaprojektuj w LTspice dopasowanie LC między źródłem 50 Ω a obciążeniem zespolonym na zadanej częstotliwości. Sprawdź pasmo dopasowania i porównaj z obliczeniami na wykresie Smitha.

## Sprawdzian umiejętności

- Interpretuję S11 i S21 z pomiaru VNA.
- Liczę współczynnik szumów kaskady stopni.
- Wyznaczam częstotliwość lustrzaną i dobieram filtr wejściowy odbiornika.
