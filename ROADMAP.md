# Roadmapa — kolejność, zależności i czas

## Graf zależności

```mermaid
graph TD
    M00[00 Matematyka] --> M01[01 Teoria obwodów]
    M00 --> M02[02 Fizyka i materiały]
    M02 --> M03[03 Przyrządy półprzewodnikowe]
    M01 --> M03
    M03 --> M04[04 Układy analogowe]
    M01 --> M05[05 Technika cyfrowa]
    M01 --> M06[06 Sygnały i systemy]
    M00 --> M06
    M06 --> M07[07 CPS / DSP]
    M04 --> M08[08 Miernictwo]
    M06 --> M08
    M05 --> M09[09 Mikrokontrolery]
    M04 --> M09
    M06 --> M10[10 Automatyka]
    M02 --> M11[11 Pole EM, linie, anteny]
    M01 --> M11
    M11 --> M12[12 Technika w.cz.]
    M04 --> M12
    M07 --> M13[13 Telekomunikacja]
    M06 --> M13
    M13 --> M14[14 Sieci telekomunikacyjne]
    M04 --> M15[15 Energoelektronika]
    M15 --> M16[16 PCB i EMC]
    M09 --> M16
    M05 --> M17[17 FPGA i HDL]
    M16 --> M18[18 Projekt końcowy]
    M17 --> M18
    M12 --> M18
    M19[19 Programowanie] --> M09
    M19 --> M20[20 Metody numeryczne]
    M00 --> M20
    M20 --> M07
    M00 --> M21[21 Procesy losowe i szum]
    M06 --> M21
    M21 --> M13
    M21 --> M12
    M03 --> M22[22 Optoelektronika i fotonika]
    M04 --> M22
    M22 --> M14
    M03 --> M23[23 Technologia mikroelektroniczna]
    M04 --> M24[24 Elektroakustyka]
    M07 --> M24
```

## Proponowany układ „semestralny”

Odpowiada typowemu 7-semestralnemu programowi inżynierskiemu EiT. Kolejność wewnątrz semestru można zmieniać.

| Semestr | Moduły | Uwagi |
|---|---|---|
| 1 | 00 Matematyka (część 1), 02 Fizyka (mechanika, elektrostatyka), 01 Teoria obwodów (prąd stały), 19 Programowanie (Python, podstawy C) | Fundament — nie skracaj |
| 2 | 00 Matematyka (część 2), 01 Teoria obwodów (AC, stany nieustalone), 05 Technika cyfrowa (kombinacyjna), 19 Programowanie (C, struktury danych, git) | Liczby zespolone muszą być „w palcach” |
| 3 | 03 Przyrządy półprzewodnikowe, 05 Technika cyfrowa (sekwencyjna), 06 Sygnały i systemy (czas ciągły), 20 Metody numeryczne | |
| 4 | 04 Układy analogowe, 06 Sygnały i systemy (czas dyskretny), 11 Pole EM, 23 Technologia mikroelektroniczna | Najtrudniejszy semestr |
| 5 | 07 CPS/DSP, 08 Miernictwo, 09 Mikrokontrolery, 10 Automatyka, 21 Procesy losowe i szum | Dużo praktyki |
| 6 | 12 Technika w.cz., 13 Telekomunikacja, 15 Energoelektronika, 17 FPGA, 22 Optoelektronika i fotonika | Wybór specjalizacji |
| 7 | 14 Sieci, 16 PCB i EMC, 18 Projekt końcowy, 24 Elektroakustyka (obieralny) | |

## Szacowany nakład pracy

Szacunki dla osoby uczącej się od zera. Przy odświeżaniu wiedzy po studiach liczy się zwykle 40–60% tego czasu.

| Moduł | Godziny |
|---|---|
| 00 Matematyka | 120–200 |
| 01 Teoria obwodów | 100–150 |
| 02 Fizyka i materiały | 60–100 |
| 03 Przyrządy półprzewodnikowe | 50–80 |
| 04 Układy analogowe | 100–150 |
| 05 Technika cyfrowa | 60–90 |
| 06 Sygnały i systemy | 80–120 |
| 07 CPS/DSP | 60–90 |
| 08 Miernictwo | 40–60 |
| 09 Mikrokontrolery | 60–100 |
| 10 Automatyka | 40–60 |
| 11 Pole EM, linie, anteny | 70–100 |
| 12 Technika w.cz. | 50–80 |
| 13 Telekomunikacja | 60–90 |
| 14 Sieci telekomunikacyjne | 40–60 |
| 15 Energoelektronika | 40–60 |
| 16 PCB i EMC | 40–60 |
| 17 FPGA i HDL | 50–80 |
| 18 Projekt końcowy | 80–150 |
| 19 Programowanie | 80–120 |
| 20 Metody numeryczne | 50–80 |
| 21 Procesy losowe i szum | 50–80 |
| 22 Optoelektronika i fotonika | 40–60 |
| 23 Technologia mikroelektroniczna | 40–60 |
| 24 Elektroakustyka | 40–60 |
| **Razem** | **~1500–2400** |

## Przykładowy rytm tygodnia (16–20 h, 5 sesji)

| Sesja | Czas | Zawartość |
|---|---|---|
| 1. Teoria i wyprowadzenia | 3 h | Notatki z modułu, wyprowadzenie wzorów, własna ściąga |
| 2. Zadania rachunkowe | 4 h | Wzory z pamięci → zadania → analiza błędów |
| 3. Symulacje | 4 h | LTspice / Python / symulator logiki, porównanie z rachunkami |
| 4. Praktyka i projekt | 4 h | Datasheety, płytka stykowa, pomiary, dokumentacja |
| 5. Test i powtórka | 3 h | Test bez notatek, zadanie łączące tematy, plan na kolejny tydzień |

Dla 8–10 h tygodniowo: połącz sesje 1+2 oraz 3+4, a test zrób co dwa tygodnie.

## Kamienie milowe

- [ ] Rozwiązuję obwody prądu stałego i zmiennego dowolną metodą i sprawdzam wynik w symulatorze (moduły 00–01).
- [ ] Analizuję układy z diodami, tranzystorami i wzmacniaczami operacyjnymi (03–04).
- [ ] Projektuję i symuluję układy kombinacyjne i sekwencyjne (05).
- [ ] Przechodzę swobodnie między dziedziną czasu i częstotliwości, rozumiem próbkowanie (06–07).
- [ ] Mierzę świadomie: znam niepewności, ograniczenia przyrządów i techniki pomiarowe (08).
- [ ] Buduję układ z mikrokontrolerem, czujnikiem i interfejsem komunikacyjnym (09).
- [ ] Rozumiem propagację fal, linie transmisyjne, dopasowanie i podstawy anten (11–12).
- [ ] Opisuję tor telekomunikacyjny: modulacja, szum, pojemność kanału, budżet łącza (13–14).
- [ ] Projektuję PCB z zasilaniem i uwzględnieniem EMC (15–16).
- [ ] Piszę i testuję programy w Pythonie i C, pracuję w git (19).
- [ ] Rozumiem, jak symulator liczy obwód, i oceniam wiarygodność wyniku numerycznego (20).
- [ ] Liczę budżet szumów toru i mierzę widmo szumu (21).
- [ ] Projektuję tor optyczny: źródło, fotodetektor z TIA, łącze światłowodowe (22).
- [ ] Rozumiem, jak powstaje układ scalony i skąd biorą się jego ograniczenia, koszt i niezawodność (23).
- [ ] Projektuję i mierzę tor audio od mikrofonu do głośnika w pomieszczeniu (24).
- [ ] Realizuję projekt od wymagań do weryfikacji pomiarowej (18).
