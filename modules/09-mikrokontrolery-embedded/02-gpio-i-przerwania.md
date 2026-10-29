# 09.02 — GPIO i przerwania

## Po co to jest

Piny wejścia/wyjścia to podstawowy kontakt mikrokontrolera ze światem, a przerwania pozwalają reagować na zdarzenia bez ciągłego sprawdzania. Błędy w obsłudze przerwań (zbyt długie procedury, wyścigi na zmiennych współdzielonych) dają usterki, które pojawiają się raz na tydzień i są bardzo trudne do znalezienia.

## Teoria w pigułce

### Konfiguracja GPIO

| Ustawienie | Opcje | Kiedy |
|---|---|---|
| Kierunek | Wejście / wyjście / funkcja alternatywna (peryferium) / analogowy | Analogowy dla A/C i dla nieużywanych pinów (najmniejszy pobór) |
| Typ wyjścia | **Push-pull** / **open-drain** | Open-drain: I²C, linie wspólne, zmiana poziomu ([05.07](../05-technika-cyfrowa/07-technologia-cmos.md)) |
| Rezystory | Pull-up / pull-down / brak | Wewnętrzne mają typowo 30–50 kΩ — za słabe dla szybkich magistral |
| Szybkość zboczy | Niska / średnia / wysoka | Najniższa wystarczająca — mniej zakłóceń EMI |
| Wydajność prądowa | Typowo kilka–kilkanaście mA na pin, ograniczenie łączne na port i układ | LED-y bezpośrednio; większe obciążenia przez tranzystor |

**Operacje atomowe:** rejestry ustawiania/kasowania bitów (np. BSRR) zmieniają pojedyncze piny bez ryzyka nadpisania innych przez przerwanie w trakcie operacji odczyt–modyfikacja–zapis.

### Przerwania

1. Zdarzenie ustawia flagę w peryferium.
2. Kontroler przerwań sprawdza priorytet i, jeśli trzeba, wywłaszcza bieżący kod.
3. Rdzeń zapisuje kontekst i skacze do procedury obsługi (ISR) z tablicy wektorów.
4. ISR obsługuje zdarzenie i **kasuje flagę** (inaczej przerwanie wywoła się ponownie).
5. Powrót do przerwanego kodu.

**Opóźnienie obsługi:** dla Cortex-M typowo 12 cykli zegara od zdarzenia do pierwszej instrukcji ISR (przy braku przerwań o wyższym priorytecie i oczekiwania pamięci).

### Zasady pisania procedur obsługi przerwań

- ISR jak najkrótsza: zapisz dane, ustaw flagę, wyjdź. Resztę rób w pętli głównej lub zadaniu.
- Bez długich pętli, `printf`, oczekiwania na inne zdarzenia.
- Zmienne współdzielone z kodem głównym: `volatile` + **dostęp atomowy** (sekcja krytyczna, wyłączenie przerwań na kilka instrukcji, instrukcje atomowe, kolejki).
- Priorytety: krótkie, krytyczne czasowo zdarzenia — wyższe.

### Drgania styków

Przycisk mechaniczny przy zmianie stanu daje serię impulsów przez ok. 1–20 ms. Rozwiązania: filtr RC + wejście Schmitta, programowo — próbkowanie co ok. 5–10 ms i akceptacja stanu stabilnego przez kilka próbek (nie przerwanie na każde zbocze).

## Przykład rozwiązany

**Wyścig na zmiennej współdzielonej.** Przerwanie timera zwiększa licznik `ticks` (32 bity), pętla główna liczy różnicę czasu. Na rdzeniu 32-bitowym odczyt jest atomowy. Na rdzeniu 8-bitowym odczyt 32-bitowej zmiennej to 4 instrukcje — jeśli przerwanie zmieni ją pomiędzy nimi (np. z 0x00FF_FFFF na 0x0100_0000), program odczyta 0x01FF_FFFF lub 0x0000_0000. Rozwiązanie: wyłączyć przerwania na czas kopiowania zmiennej.

**Opóźnienie:** 12 cykli przy 72 MHz to ok. 167 ns.

## Typowe pułapki

- **Brak skasowania flagi przerwania** — procesor w nieskończoność wchodzi do ISR.
- **Flaga kasowana na samym końcu ISR** na szybkich rdzeniach z buforem zapisu — przerwanie może wywołać się drugi raz; kasuj na początku albo upewnij się, że zapis dotarł.
- **Brak `volatile`** — optymalizator wyrzuca odczyt zmiennej z pętli.
- **Przerwanie od przycisku bez filtracji drgań.**
- **Pin wyjściowy obciążony ponad katalogową wydajność** — spadek napięcia, przegrzanie, zakłócenia innych pinów.

## Ćwiczenie — kod (działa na komputerze)

Programowa eliminacja drgań styków wywoływana co 5 ms z przerwania timera:

```c
#include <stdint.h>
#include <stdio.h>

typedef struct { uint8_t history; uint8_t state; } debounce_t;

/* wywoływane co 5 ms; raw = surowy odczyt pinu (0/1)
   zwraca 1, gdy wykryto stabilne naciśnięcie (zbocze 0 -> 1) */
int debounce_update(debounce_t *d, uint8_t raw) {
    d->history = (uint8_t)((d->history << 1) | (raw & 1u));
    if (d->history == 0xFF && d->state == 0) { d->state = 1; return 1; }
    if (d->history == 0x00) d->state = 0;
    return 0;
}

int main(void) {
    /* symulacja: drgania przy wciśnięciu, stabilnie wciśnięty, drgania przy puszczeniu */
    const uint8_t samples[] = {0,0,1,0,1,1,0,1,1,1,1,1,1,1,1,1,1,0,1,0,0,0,0,0,0,0,0,0};
    debounce_t d = {0, 0};
    int presses = 0;
    for (unsigned i = 0; i < sizeof samples; i++) presses += debounce_update(&d, samples[i]);
    printf("wykryte naciśnięcia: %d\n", presses);   /* oczekiwane: 1 */
    return 0;
}
```

Skompiluj: `gcc -Wall -o debounce debounce.c && ./debounce`. Na mikrokontrolerze `debounce_update` wywołuj w przerwaniu timera, a wynik przekazuj do pętli głównej przez zmienną `volatile`.

## Zadania

1. Ile wynosi opóźnienie obsługi przerwania 12 cykli przy 72 MHz i przy 16 MHz?
2. Dlaczego zapis `GPIOA->ODR |= (1 << 5);` w pętli głównej może zepsuć stan innego pinu zmienianego w przerwaniu? Jak tego uniknąć?
3. Wyjście mikrokontrolera ma ograniczenie 8 mA na pin. Dioda LED (2 V) ma świecić z 3,3 V przy maksymalnym dozwolonym prądzie. Dobierz rezystor.
4. Przycisk drga przez 10 ms. Co ile próbkować i ile zgodnych próbek wymagać w algorytmie z ćwiczenia?
5. Zaprojektuj komunikację ISR → pętla główna dla danych odbieranych z UART (wiele bajtów).

<details>
<summary>Odpowiedzi</summary>

1. ≈ 167 ns i 750 ns
2. Operacja odczyt–modyfikacja–zapis: jeśli przerwanie zmieni inny pin między odczytem a zapisem, zapis przywróci starą wartość. Użyj rejestru atomowego ustawiania/kasowania bitów lub sekcji krytycznej
3. $(3\text{,}3 - 2)/8\ \text{mA} \approx 163\ \Omega$ → 180 Ω (z zapasem, ok. 7 mA)
4. Np. co 5 ms i 8 zgodnych próbek (40 ms) — z zapasem ponad czas drgań; krótsze okno (np. 4 próbki × 5 ms) też zadziała
5. Bufor kołowy (FIFO): ISR wpisuje bajt i przesuwa indeks zapisu, pętla główna czyta i przesuwa indeks odczytu; każdy indeks modyfikuje tylko jedna strona — przy indeksach o rozmiarze słowa procesora nie trzeba wyłączać przerwań
</details>

## Źródła

- [Embedded Systems — Shape the World (J. Valvano)](https://users.ece.utexas.edu/~valvano/Volume1/E-Book/) — porty wejścia/wyjścia, przerwania, synchronizacja
- [Interrupt (blog Memfault)](https://interrupt.memfault.com/) — m.in. szczegółowe wpisy o przerwaniach w Cortex-M
- [Embedded Controllers Using C and Arduino — J. M. Fiore](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html) — operacje bitowe, porty, przerwania
