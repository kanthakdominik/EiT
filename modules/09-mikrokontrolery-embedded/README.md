# 09 — Mikrokontrolery i systemy wbudowane

> **Status:** ✅ pełny

## Cel modułu

Łączyć sprzęt i oprogramowanie: rozumieć architekturę mikrokontrolera, konfigurować peryferia na poziomie rejestrów i bibliotek, obsługiwać interfejsy komunikacyjne, pisać niezawodny kod w C i projektować sprzęt wokół mikrokontrolera. Moduł nie jest przywiązany do jednej rodziny — przykłady liczbowe odnoszą się do typowych układów ARM Cortex-M, ale zasady są uniwersalne.

## Wymagania wstępne

- [05 Technika cyfrowa](../05-technika-cyfrowa/) — zwłaszcza [parametry czasowe](../05-technika-cyfrowa/06-parametry-czasowe.md) i [CMOS i poziomy logiczne](../05-technika-cyfrowa/07-technologia-cmos.md).
- [04 Układy analogowe](../04-uklady-analogowe/) — podstawy (zasilanie, klucze tranzystorowe).
- [07 DSP](../07-cps-dsp/) — dla tematu 04 (przetwornik A/C).
- Język C na poziomie podstawowym.

## Tematy

| # | Temat | Czas (od zera / odświeżenie) |
|---|---|---|
| 01 | [Architektura mikrokontrolera, zegary i zasilanie](01-architektura.md) | 8 h / 2 h |
| 02 | [GPIO i przerwania](02-gpio-i-przerwania.md) | 8 h / 2 h |
| 03 | [Timery i PWM](03-timery-i-pwm.md) | 8 h / 2 h |
| 04 | [Przetwornik A/C, C/A i DMA](04-adc-dac-dma.md) | 8 h / 3 h |
| 05 | [UART, SPI, I²C](05-uart-spi-i2c.md) | 10 h / 3 h |
| 06 | [CAN, RS-485, USB i łączność bezprzewodowa](06-can-rs485-usb-radio.md) | 6 h / 2 h |
| 07 | [Oprogramowanie wbudowane: C, architektura programu, RTOS](07-oprogramowanie-embedded.md) | 12 h / 4 h |
| 08 | [Sprzęt wokół mikrokontrolera](08-sprzet-wokol-mcu.md) | 6 h / 2 h |

## Test wejściowy (diagnoza)

Około 60 minut, bez notatek.

1. Timer taktowany 72 MHz ma generować PWM 20 kHz. Jakie wartości preskalera i rejestru okresu? Jaka rozdzielczość PWM w bitach?
2. Dlaczego zmienna modyfikowana w przerwaniu i czytana w pętli głównej musi być `volatile`? Czy to wystarcza dla zmiennej 32-bitowej na rdzeniu 8-bitowym?
3. Urządzenie pobiera 10 mA przez 1% czasu i 5 µA w uśpieniu. Ile wytrzyma na baterii 2000 mAh?
4. UART 115 200 bit/s, ramka 8N1. Ile bajtów na sekundę maksymalnie?
5. Czym różni się I²C od SPI pod względem liczby linii, adresowania i szybkości?
6. Kwarc wymaga pojemności obciążenia 12 pF, pojemność pasożytnicza płytki 3 pF. Jakie kondensatory zastosować?
7. Co to jest inwersja priorytetów w RTOS i jak się jej zapobiega?

<details>
<summary>Odpowiedzi</summary>

1. PSC = 0, ARR = 3599 → $72\cdot 10^6/3600 = 20$ kHz; $\log_2 3600 \approx 11\text{,}8$ bitu
2. Bez `volatile` kompilator może trzymać wartość w rejestrze i nie zauważyć zmiany. Nie wystarcza — odczyt 32 bitów na rdzeniu 8-bitowym nie jest atomowy; potrzebna sekcja krytyczna
3. Średnio ok. 0,105 mA → ok. 19 000 h ≈ 2,2 roku (bez samorozładowania)
4. 11 520 B/s (10 bitów na bajt)
5. I²C: 2 linie, adresowanie w protokole, typowo 100/400 kHz–1 MHz; SPI: 4 linie (+ CS na każde urządzenie), wybór sygnałem CS, kilka–kilkadziesiąt MHz, pełny dupleks
6. $C_1 = C_2 = 2(C_L - C_{str}) = 18$ pF
7. Zadanie o wysokim priorytecie czeka na zasób trzymany przez zadanie o niskim priorytecie, które jest wywłaszczane przez zadanie o średnim priorytecie. Zapobiega się dziedziczeniu priorytetów w muteksach (priority inheritance)

**Ocena:** zadania 1 — temat 03; 2, 7 — temat 07; 3 — temat 01; 4–5 — temat 05; 6 — temat 08.
</details>

## Projekt modułowy: rejestrator danych

- [ ] Wybierz płytkę z mikrokontrolerem (dowolna rodzina z ADC, timerami, UART i I²C).
- [ ] Czujnik analogowy przez tor kondycjonowania z modułu [04](../04-uklady-analogowe/) lub [08.06](../08-miernictwo/06-czujniki-i-tor-pomiarowy.md) + czujnik cyfrowy na I²C.
- [ ] Próbkowanie A/C wyzwalane timerem, dane przez DMA do bufora podwójnego.
- [ ] Filtr cyfrowy z modułu [07](../07-cps-dsp/) w arytmetyce stałoprzecinkowej.
- [ ] Transmisja przez UART w formacie z sumą kontrolną; odbiór, zapis i wykres w Pythonie.
- [ ] Architektura programu: automat stanów lub RTOS, watchdog, tryb niskiego poboru mocy między pomiarami.
- [ ] Zmierz pobór prądu w każdym trybie i oszacuj czas pracy na baterii.

## Sprawdzian końcowy modułu

- [ ] Konfiguruję drzewo zegarów i wiem, jak wpływa ono na peryferia i pobór mocy.
- [ ] Obsługuję przerwania poprawnie: krótkie procedury, zmienne współdzielone, sekcje krytyczne.
- [ ] Liczę ustawienia timera dla zadanej częstotliwości PWM i mierzę czas metodą przechwytywania.
- [ ] Konfiguruję A/C z wyzwalaniem timerem i DMA, dobieram czas próbkowania do impedancji źródła.
- [ ] Debuguję UART, SPI i I²C analizatorem stanów logicznych.
- [ ] Projektuję architekturę programu (superpętla, automat stanów, RTOS) odpowiednią do zadania.
- [ ] Projektuję schemat zasilania, resetu, zegara i wyjść mocy mikrokontrolera.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [Embedded Systems — Shape the World (J. Valvano, UT Austin)](https://users.ece.utexas.edu/~valvano/Volume1/E-Book/) | Darmowy podręcznik interaktywny: architektura, I/O, przerwania, interfejsy, C |
| [Introduction to Embedded Systems using the MSPM0+ (J. Valvano)](https://users.ece.utexas.edu/~valvano/mspm0/ebook/index.htm) | Nowsza wersja podręcznika na współczesnej rodzinie Cortex-M0+ |
| [Embedded Controllers Using C and Arduino — J. M. Fiore](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html) | Przystępne wprowadzenie z instrukcją laboratoryjną |
| [Mastering the FreeRTOS Real Time Kernel](https://github.com/FreeRTOS/FreeRTOS-Kernel-Book) | Temat 07 — oficjalna darmowa książka o RTOS |
| [Interrupt (blog Memfault)](https://interrupt.memfault.com/) | Praktyka firmware: debugowanie, budowanie, testy, niezawodność |
| [NXP UM10204 — I²C-bus specification](https://www.nxp.com/docs/en/user-guide/UM10204.pdf) | Temat 05 — specyfikacja I²C |
| [Ben Eater](https://eater.net/8bit/) | Architektura komputera i magistrale od strony sprzętu |
| Dokumentacja wybranego mikrokontrolera (reference manual + datasheet + errata) | Podstawowe źródło przy każdym projekcie |
