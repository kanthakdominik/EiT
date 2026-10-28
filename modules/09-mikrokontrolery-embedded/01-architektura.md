# 09.01 — Architektura mikrokontrolera, zegary i zasilanie

## Po co to jest

Mikrokontroler to kompletny komputer w jednym układzie: rdzeń, pamięci, zegary i peryferia. Zrozumienie mapy pamięci, drzewa zegarów i trybów zasilania pozwala czytać dokumentację, konfigurować peryferia świadomie i projektować urządzenia, które działają latami na baterii.

## Teoria w pigułce

### Bloki mikrokontrolera

| Blok | Rola |
|---|---|
| Rdzeń (CPU) | Wykonuje instrukcje; np. ARM Cortex-M0/M3/M4/M33, RISC-V, AVR |
| Flash | Program i stałe, zachowuje zawartość bez zasilania |
| SRAM | Zmienne, stos, sterta |
| Magistrale (np. AHB/APB) | Łączą rdzeń, pamięci, DMA i peryferia; peryferia na wolniejszych magistralach |
| Kontroler przerwań (np. NVIC) | Priorytety i obsługa przerwań |
| DMA | Przesyłanie danych bez udziału rdzenia |
| Peryferia | GPIO, timery, ADC/DAC, UART, SPI, I²C, USB, CAN… |
| Układy nadzoru | Reset po włączeniu zasilania, detektor spadku napięcia (brown-out), watchdog |

**Harvard vs von Neumann:** osobne magistrale programu i danych (równoczesny dostęp) vs wspólna. Cortex-M ma architekturę Harvard wewnątrz rdzenia i jedną przestrzeń adresową.

**Mapa pamięci:** każde peryferium ma rejestry pod stałymi adresami. Zapis do rejestru = konfiguracja sprzętu. Biblioteki producenta (HAL, LL) i nagłówki CMSIS nadają tym adresom nazwy.

### Zegary

Źródła: wewnętrzny oscylator RC (szybki start, mała dokładność ±1–2%), zewnętrzny kwarc (ppm), kwarc 32,768 kHz dla RTC. **Pętla PLL** mnoży częstotliwość: np. kwarc 8 MHz × 9 = 72 MHz. Dzielniki dostarczają zegarów magistral i peryferiów — **częstotliwość peryferium zależy od konfiguracji drzewa zegarów**, a od niej ustawienia timerów i prędkości transmisji.

Pamięć Flash przy wysokich częstotliwościach wymaga cykli oczekiwania (wait states); bufory i pamięci podręczne to kompensują.

### Reset i start

Po resecie rdzeń odczytuje wskaźnik stosu i adres procedury startowej z tablicy wektorów. Kod startowy inicjalizuje zmienne (kopiuje `.data` z Flash do RAM, zeruje `.bss`), konfiguruje zegary i wywołuje `main()`. Bootloader może pozwalać na programowanie przez UART/USB.

### Zasilanie i tryby oszczędzania energii

Pobór prądu rośnie liniowo z częstotliwością zegara (moc dynamiczna, [05.07](../05-technika-cyfrowa/07-technologia-cmos.md)). Tryby: uśpienie (rdzeń stoi, peryferia działają), stop (większość zegarów wyłączona, RAM zachowany), czuwanie (prawie wszystko wyłączone, wybudzenie jak reset). Niższy tryb = mniejszy prąd i dłuższe wybudzanie.

**Prąd średni** przy pracy cyklicznej:

$$I_{śr} = D\cdot I_{akt} + (1 - D)\cdot I_{uśp}$$

## Przykład rozwiązany

Czujnik bezprzewodowy: pomiar i wysłanie danych trwa 1% czasu przy 10 mA, w pozostałym czasie uśpienie przy 5 µA, bateria 2000 mAh.

1. $I_{śr} = 0{,}01\cdot 10\ \text{mA} + 0{,}99\cdot 5\ \mu\text{A} \approx 0{,}105$ mA.
2. Czas pracy: $2000/0{,}105 \approx 19\,000$ h ≈ 2,2 roku (w praktyce mniej: samorozładowanie, temperatura, prąd szczytowy radia).
3. Wniosek: przy tak małym wypełnieniu oba składniki są porównywalne — obniżenie prądu uśpienia z 5 do 2 µA wydłuża pracę o kilka procent, a skrócenie czasu aktywności o połowę — prawie dwukrotnie.

## Typowe pułapki

- **Zmiana zegara systemowego bez przeliczenia** ustawień timerów i UART-a.
- **Peryferium bez włączonego zegara** — zapis do rejestrów nic nie daje (w wielu rodzinach zegar każdego peryferium włącza się osobno).
- **Wewnętrzny oscylator RC do USB lub szybkiego UART** — za mała dokładność.
- **Pomiar prądu uśpienia multimetrem na zakresie mA** — rozdzielczość za mała, a spadek napięcia na zakresie µA potrafi zresetować układ przy wybudzeniu.
- **Pływające piny w trybie uśpienia** — pobór prądu rośnie o dziesiątki–setki µA.

## Ćwiczenie praktyczne

- [ ] Znajdź w dokumentacji swojego mikrokontrolera: mapę pamięci, schemat drzewa zegarów, tabelę poboru prądu w trybach.
- [ ] Skonfiguruj zegar systemowy z PLL i sprawdź częstotliwość, wyprowadzając zegar na pin (funkcja MCO lub podobna) i mierząc go oscyloskopem.
- [ ] Zmierz prąd w trybie aktywnym przy kilku częstotliwościach i w trybie uśpienia.

## Zadania

1. Kwarc 8 MHz, PLL ×9. Jaka częstotliwość systemowa? Jak zmieni się częstotliwość timera taktowanego z magistrali z dzielnikiem 2?
2. Prąd aktywny 10 mA przez 1% czasu, uśpienie 5 µA, bateria 2000 mAh. Czas pracy?
3. Mikrokontroler pobiera 150 µA/MHz w trybie aktywnym. Ile przy 72 MHz i ile przy 8 MHz? Kiedy opłaca się pracować szybciej?
4. Co dzieje się między resetem a wywołaniem `main()`?
5. Dlaczego do zegara czasu rzeczywistego stosuje się kwarc 32,768 kHz?

<details>
<summary>Odpowiedzi</summary>

1. 72 MHz; zależy od rodziny — magistrala 36 MHz, a w wielu układach (np. z rodziny STM32) zegar timerów jest wtedy podwajany do 72 MHz. Zawsze sprawdź w schemacie drzewa zegarów
2. ≈ 2,2 roku
3. 10,8 mA i 1,2 mA; jeśli energia na zadanie jest taka sama (zadanie trwa 9 razy krócej), szybsza praca i wcześniejsze uśpienie zwykle daje mniejszą energię — strategia „race to sleep”, zwłaszcza gdy prąd uśpienia jest mały, a stałe składniki poboru duże
4. Odczyt wskaźnika stosu i wektora resetu, kod startowy: inicjalizacja `.data` i `.bss`, konfiguracja zegara (często w `SystemInit`), wywołanie konstruktorów (C++), skok do `main()`
5. $32\,768 = 2^{15}$ — licznik 15-bitowy daje dokładnie 1 Hz; mała częstotliwość = bardzo mały pobór prądu
</details>

## Źródła

- [Embedded Systems — Shape the World (J. Valvano)](https://users.ece.utexas.edu/~valvano/Volume1/E-Book/) — architektura mikrokontrolera, pamięć, zegary
- [Introduction to Embedded Systems using the MSPM0+ (J. Valvano)](https://users.ece.utexas.edu/~valvano/mspm0/ebook/index.htm)
- [Interrupt (blog Memfault)](https://interrupt.memfault.com/) — m.in. wpisy o procesie startu Cortex-M i pomiarze poboru energii
- Reference manual wybranego mikrokontrolera — rozdziały o zegarach (RCC/CLOCK) i zasilaniu (PWR)
