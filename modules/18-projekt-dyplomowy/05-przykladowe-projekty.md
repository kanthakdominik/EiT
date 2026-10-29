# 18.05 — Przykładowe projekty z wymaganiami

Każdy temat ma przykładowe wymagania z liczbami, bloki, moduły ścieżki, z których korzysta, kamienie milowe i typowe ryzyka. Wymagania są punktem wyjścia — dostosuj je do swoich możliwości i sprzętu, ale **zachowaj ich mierzalność**.

---

## 1. Rejestrator danych środowiskowych z łącznością radiową

**Wymagania:** temperatura −10…+50 °C z niepewnością ≤ 0,5 °C (k = 2); wilgotność ±3% RH; pomiar co 10 min, wysyłka co 1 h; zasięg ≥ 500 m w terenie otwartym; ≥ 12 miesięcy na ogniwie 2000 mAh; obudowa IP54; zapis lokalny przy braku łączności (≥ 7 dni).

**Bloki:** czujniki (cyfrowy + analogowy z torem kondycjonowania), mikrokontroler w trybach niskiego poboru, moduł LoRa, pamięć Flash, zasilanie bateryjne, bramka odbiorcza z serwerem.

**Moduły:** [04](../04-uklady-analogowe/), [08](../08-miernictwo/), [09](../09-mikrokontrolery-embedded/), [11](../11-pole-em-linie-anteny/), [13](../13-telekomunikacja/), [15](../15-energoelektronika-zasilanie/), [16](../16-pcb-emc-konstrukcja/).

**Kamienie milowe:** budżet energii i łącza → prototyp na modułach (pobór, zasięg) → PCB → firmware z trybami uśpienia → kalibracja w komorze → test terenowy.

**Ryzyka:** prąd uśpienia (pływające piny, czujniki); antena w obudowie; dokładność wilgotności (kondensacja).

---

## 2. Analizator widma audio na mikrokontrolerze

**Wymagania:** pasmo 20 Hz – 20 kHz; zakres dynamiki ≥ 70 dB; rozdzielczość ≤ 10 Hz (tryb szczegółowy); odświeżanie ≥ 10 razy/s; wyświetlanie widma (dB) i THD dla sygnału sinusoidalnego (THD ≥ 0,1% z niepewnością ≤ 0,02%); wejście liniowe 1 V rms i mikrofonowe.

**Bloki:** przedwzmacniacz i filtr antyaliasingowy, przetwornik A/C (wbudowany lub zewnętrzny 16–24 bity), DMA, FFT z oknem, wyświetlacz, interfejs USB.

**Moduły:** [04](../04-uklady-analogowe/), [06](../06-sygnaly-i-systemy/), [07](../07-cps-dsp/), [09](../09-mikrokontrolery-embedded/).

**Kamienie milowe:** symulacja toru i filtra → analiza w Pythonie na danych z przetwornika → implementacja FFT stałoprzecinkowej → wyświetlanie → weryfikacja generatorem o niskich zniekształceniach.

**Ryzyka:** szum zasilania w torze analogowym, przeciek widma, wydajność FFT.

---

## 3. Odbiornik SDR z własnym torem wejściowym

**Wymagania:** pasmo 433 lub 868 MHz; NF toru ≤ 4 dB; IIP3 ≥ −15 dBm; odrzucanie sygnału lustrzanego/pozapasmowego ≥ 40 dB; demodulacja FM i prostego sygnału cyfrowego (FSK) z BER ≤ 10⁻³ przy zadanym poziomie; pomiar czułości.

**Bloki:** filtr wejściowy (SAW), LNA z dopasowaniem, mieszacz/odbiornik I/Q lub gotowy układ RF + przetwornik, oprogramowanie DSP w Pythonie lub na FPGA.

**Moduły:** [11](../11-pole-em-linie-anteny/), [12](../12-technika-wcz-rf/), [13](../13-telekomunikacja/), [07](../07-cps-dsp/), opcjonalnie [17](../17-fpga-hdl/).

**Kamienie milowe:** budżet szumów i IIP3 → projekt dopasowania LNA na parametrach S → PCB w.cz. (4 warstwy, linie 50 Ω) → pomiary VNA → oprogramowanie demodulacji → pomiar czułości i BER.

**Ryzyka:** stabilność LNA, układ płytki w.cz., dostęp do przyrządów (tani VNA, generator).

---

## 4. Zasilacz laboratoryjny z regulacją cyfrową

**Wymagania:** 0–20 V, 0–2 A; nastawa z rozdzielczością 10 mV / 1 mA; tętnienia ≤ 5 mV p-p; ograniczenie prądowe z czasem reakcji ≤ 1 ms; pomiar U i I z niepewnością ≤ 0,5% + 2 cyfry; zabezpieczenie termiczne; interfejs USB z poleceniami SCPI.

**Bloki:** przetwornica wstępna + stopień liniowy (niskie tętnienia), pętle napięcia i prądu (analogowe lub cyfrowe), przetworniki A/C i C/A, mikrokontroler, termika i radiator.

**Moduły:** [04](../04-uklady-analogowe/), [08](../08-miernictwo/), [10](../10-automatyka/), [15](../15-energoelektronika-zasilanie/), [16](../16-pcb-emc-konstrukcja/).

**Kamienie milowe:** symulacja pętli w LTspice i Pythonie → stopień mocy → regulacja → kalibracja → testy skoku obciążenia, zwarcia, termiki.

**Ryzyka:** stabilność przy różnych obciążeniach (pojemnościowe!), straty mocy przy niskim napięciu i dużym prądzie, bezpieczeństwo.

---

## 5. Generator funkcyjny DDS na FPGA

**Wymagania:** sinus, prostokąt, trójkąt; 1 Hz – 5 MHz z rozdzielczością ≤ 0,1 Hz; SFDR ≥ 50 dBc dla sinusa do 1 MHz; amplituda 0–5 V p-p na 50 Ω; modulacja AM/FM/przemiatanie; sterowanie przez UART.

**Bloki:** akumulator fazy i tablica sinusa w FPGA, przetwornik C/A 10–14 bitów (≥ 50 MS/s), filtr rekonstrukcyjny, wzmacniacz wyjściowy, interfejs UART.

**Moduły:** [05](../05-technika-cyfrowa/), [07](../07-cps-dsp/), [17](../17-fpga-hdl/), [04](../04-uklady-analogowe/), [08](../08-miernictwo/).

**Kamienie milowe:** model w Pythonie (widmo, SFDR w funkcji bitów tablicy i fazy) → HDL z testbenchem → płytka przetwornika i filtra → pomiar widma analizatorem/SDR.

**Ryzyka:** filtr rekonstrukcyjny, szybki układ płytki przetwornika, wzmacniacz o szerokim paśmie.

---

## 6. Łącze radiowe LoRa z pomiarem budżetu łącza

**Wymagania:** dwa węzły z pomiarem RSSI i SNR; test zasięgu w terenie dla SF7–SF12; porównanie pomiaru z budżetem łącza (różnica wyjaśniona); antena własna z S11 ≤ −10 dB w paśmie; czas nadawania zgodny z limitem cyklu pracy.

**Moduły:** [09](../09-mikrokontrolery-embedded/), [11](../11-pole-em-linie-anteny/), [12](../12-technika-wcz-rf/), [13](../13-telekomunikacja/), [14](../14-sieci-telekomunikacyjne/).

**Kamienie milowe:** budżet łącza → anteny i pomiar S11 → firmware z logowaniem → pomiary terenowe → analiza (model log-distance, strefa Fresnela).

---

## 7. Miernik impedancji (LCR)

**Wymagania:** 100 Hz, 1 kHz, 10 kHz; zakres 1 Ω – 1 MΩ; niepewność ≤ 1% w zakresie 10 Ω – 100 kΩ; wyświetlanie modułu, fazy, L/C/R i dobroci; kalibracja zwarcie–rozwarcie.

**Bloki:** generator sinusoidalny (DDS lub tablica), wzmacniacz transimpedancyjny z przełączanymi zakresami, dwa kanały przetwornika A/C, detekcja synchroniczna (I/Q) w oprogramowaniu.

**Moduły:** [01](../01-teoria-obwodow/), [04](../04-uklady-analogowe/), [06](../06-sygnaly-i-systemy/), [08](../08-miernictwo/).

**Kamienie milowe:** symulacja toru i budżet błędów → prototyp → algorytm detekcji synchronicznej → kalibracja → porównanie z miernikiem wzorcowym.

---

## 8. Sterownik silnika BLDC z regulacją prędkości

**Wymagania:** 12–24 V, do 5 A; komutacja bezczujnikowa lub z czujnikami Halla; regulacja prędkości PI z uchybem ≤ 1% w stanie ustalonym; zabezpieczenia nadprądowe (reakcja ≤ 10 µs), podnapięciowe, termiczne; telemetria przez UART/CAN.

**Moduły:** [03](../03-przyrzady-polprzewodnikowe/), [09](../09-mikrokontrolery-embedded/), [10](../10-automatyka/), [15](../15-energoelektronika-zasilanie/), [16](../16-pcb-emc-konstrukcja/).

**Ryzyka:** przewodzenie skrośne (czas martwy), zakłócenia od przełączania w pomiarze prądu, termika tranzystorów.

---

## Jak wybrać temat

- Coś, co **naprawdę chcesz mieć lub rozumieć** — motywacja na 150–300 godzin.
- Co najmniej **jeden blok trudny** (analogowy, w.cz., zasilanie lub FPGA) i co najmniej jeden **mierzalny parametr**, który da się porównać z obliczeniami.
- **Dostępne przyrządy** — bez analizatora widma czy VNA lepiej nie wybierać tematów wymagających precyzyjnych pomiarów w.cz. (choć tanie przyrządy amatorskie wiele zmieniają).
- Zakres na jeden semestr; rozszerzenia jako „może” w specyfikacji.
