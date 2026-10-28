# 09.05 — UART, SPI, I²C

## Po co to jest

Te trzy interfejsy łączą mikrokontroler z czujnikami, pamięciami, wyświetlaczami, modułami radiowymi i komputerem. Większość problemów przy uruchamianiu systemów wbudowanych to problemy komunikacyjne — a analizator stanów logicznych z dekoderem protokołu rozwiązuje je w kilka minut, jeśli wiesz, czego szukać.

## Teoria w pigułce

### Porównanie

| | UART | SPI | I²C |
|---|---|---|---|
| Linie | TX, RX (+ RTS/CTS) | SCK, MOSI, MISO, CS (na urządzenie) | SDA, SCL |
| Zegar | Brak (asynchroniczny, uzgodniona prędkość) | Od mastera | Od mastera |
| Topologia | Punkt–punkt | Jeden master, wiele urządzeń (osobne CS) | Wielu uczestników na magistrali, adresy 7/10-bitowe |
| Szybkość typowa | 9,6 kbit/s – kilka Mbit/s | 1–50 MHz | 100 kHz, 400 kHz, 1 MHz (3,4 MHz) |
| Dupleks | Pełny | Pełny | Półdupleks |
| Potwierdzenie | Brak (opcjonalna parzystość) | Brak | ACK/NACK po każdym bajcie |
| Wyjścia | Push-pull | Push-pull | **Open-drain + rezystory podciągające** |

### UART

Ramka: bit startu (0), 5–9 bitów danych (LSB pierwszy), opcjonalna parzystość, 1–2 bity stopu (1). „8N1” = 10 bitów na bajt. **Tolerancja prędkości:** odbiornik synchronizuje się na bicie startu i próbkuje środek bitów; łączny błąd prędkości obu stron powinien być mniejszy niż ok. 2–3% (w zależności od długości ramki i sposobu próbkowania). Poziomy: TTL/CMOS na płytce, RS-232 (±3…±15 V, odwrócona logika) przez kabel, RS-485 — [09.06](06-can-rs485-usb-radio.md). Przejściówki USB–UART do komunikacji z komputerem.

### SPI

Cztery tryby (CPOL — stan spoczynkowy zegara, CPHA — zbocze próbkowania): **tryb musi się zgadzać z urządzeniem**. Dane przesuwane jednocześnie w obu kierunkach — żeby odczytać bajt, trzeba wysłać bajt (np. 0xFF). CS aktywny niski obejmuje całą transakcję. Rozszerzenia: dual/quad SPI dla pamięci Flash.

### I²C

Transakcja: START → adres (7 bitów) + bit R/W → ACK → bajty danych z ACK → STOP. Odczyt rejestru: zapis numeru rejestru, **powtórzony START**, adres z bitem odczytu, odczyt bajtów (ostatni z NACK). Urządzenie może wstrzymać zegar (clock stretching). Dobór rezystorów podciągających — [05.07](../05-technika-cyfrowa/07-technologia-cmos.md).

## Przykład rozwiązany

**UART 115 200 bit/s przy zegarze peryferium 72 MHz** (nadpróbkowanie ×16): dzielnik $72\cdot 10^6/(16\cdot 115\,200) = 39{,}0625$. Rejestr z częścią ułamkową (4 bity) zapisze to dokładnie: $39 + 1/16$. Bez części ułamkowej (dzielnik 39) błąd wyniósłby ok. 0,16% — też akceptowalnie. Przepustowość: 11 520 B/s.

**Czas transakcji I²C** (400 kHz): odczyt 2 bajtów z rejestru czujnika = START + adres+W (9 bitów) + numer rejestru (9) + powtórzony START + adres+R (9) + 2 bajty (18) + STOP ≈ 47 okresów zegara ≈ **118 µs**. Odczyt 100 razy na sekundę zajmuje ok. 1,2% przepustowości magistrali.

## Typowe pułapki

- **TX połączone z TX** zamiast z RX drugiej strony; brak wspólnej masy.
- **Zły tryb SPI** — dane przesunięte o bit lub losowe.
- **Adres I²C 7-bitowy podany jako 8-bitowy** (przesunięty) lub odwrotnie — w dokumentacjach bywa i tak, i tak.
- **Brak rezystorów podciągających I²C** albo podciąganie tylko wewnętrzne (za słabe).
- **Zawieszona magistrala I²C** po resecie mikrokontrolera w trakcie transakcji — urządzenie trzyma SDA nisko; rozwiązanie: 9 impulsów zegara „ręcznie” na GPIO przed inicjalizacją.
- **Odczyt SPI bez wysyłania bajtów** — brak zegara, brak danych.

## Ćwiczenie — kod (działa na komputerze)

Bufor kołowy do odbioru UART w przerwaniu — wersja testowana na komputerze:

```c
#include <stdint.h>
#include <stdio.h>

#define RB_SIZE 64u                      /* potęga dwójki */
typedef struct { volatile uint16_t head, tail; uint8_t buf[RB_SIZE]; } ringbuf_t;

/* wywoływane w przerwaniu odbioru UART */
int rb_put(ringbuf_t *rb, uint8_t b) {
    uint16_t next = (uint16_t)((rb->head + 1u) & (RB_SIZE - 1u));
    if (next == rb->tail) return 0;      /* pełny — bajt tracony */
    rb->buf[rb->head] = b; rb->head = next; return 1;
}
/* wywoływane w pętli głównej */
int rb_get(ringbuf_t *rb, uint8_t *b) {
    if (rb->tail == rb->head) return 0;  /* pusty */
    *b = rb->buf[rb->tail]; rb->tail = (uint16_t)((rb->tail + 1u) & (RB_SIZE - 1u)); return 1;
}

int main(void) {
    ringbuf_t rb = {0};
    const char *msg = "TEMP=23.5\n";
    for (const char *p = msg; *p; p++) rb_put(&rb, (uint8_t)*p);   /* „przerwania” */
    uint8_t c; printf("odebrano: ");
    while (rb_get(&rb, &c)) putchar(c);
    int lost = 0; for (int i = 0; i < 100; i++) lost += !rb_put(&rb, 'x');
    printf("bajtów utraconych przy przepełnieniu: %d\n", lost);  /* 100 - 63 = 37 */
    return 0;
}
```

Każdy indeks modyfikuje tylko jedna strona (ISR — `head`, pętla — `tail`), więc na rdzeniu, który zapisuje 16 bitów atomowo, nie trzeba wyłączać przerwań.

## Zadania

1. UART 115 200, 8N1. Czas jednego bitu, jednego bajtu, przepustowość w B/s.
2. Zegar peryferium 16 MHz, nadpróbkowanie ×16, 115 200 bit/s, dzielnik całkowity. Jaki błąd prędkości? Czy komunikacja zadziała?
3. Policz czas odczytu 6 bajtów (akcelerometr, 3 osie × 16 bitów) przez I²C 400 kHz i przez SPI 8 MHz (z 1 bajtem adresu rejestru).
4. Urządzenie ma w dokumentacji adres „0x90 (zapis) / 0x91 (odczyt)”. Jaki to adres 7-bitowy?
5. Czujnik SPI wymaga CPOL = 1, CPHA = 1. Opisz stan spoczynkowy zegara i zbocze, na którym próbkowane są dane.

<details>
<summary>Odpowiedzi</summary>

1. 8,68 µs; 86,8 µs; 11 520 B/s
2. $16\cdot 10^6/(16\cdot 115\,200) = 8{,}68$ → dzielnik 9 → 111 111 bit/s, błąd −3,5% — za duży, komunikacja zawodna; potrzebny dzielnik ułamkowy, nadpróbkowanie ×8 lub inna prędkość/zegar
3. I²C: START + adres+W + rejestr + rSTART + adres+R + 6 bajtów + STOP ≈ 1 + 9 + 9 + 1 + 9 + 54 + 1 = 84 okresy ≈ 210 µs; SPI: 7 bajtów = 56 bitów ≈ 7 µs (+ czas obsługi CS)
4. 0x48
5. Zegar w spoczynku wysoki; dane zmieniane na zboczu opadającym i próbkowane na narastającym (drugie zbocze w cyklu)
</details>

## Źródła

- [NXP UM10204 — I²C-bus specification and user manual](https://www.nxp.com/docs/en/user-guide/UM10204.pdf) — oficjalna specyfikacja I²C
- [Embedded Systems — Shape the World (J. Valvano)](https://users.ece.utexas.edu/~valvano/Volume1/E-Book/) — komunikacja szeregowa UART, SPI, I²C
- [Interrupt (blog Memfault)](https://interrupt.memfault.com/) — praktyczne wpisy o debugowaniu interfejsów
- [MIT 6.111 Introductory Digital Systems Laboratory](https://ocw.mit.edu/courses/6-111-introductory-digital-systems-laboratory-spring-2006/) — interfejsy szeregowe od strony sprzętu
