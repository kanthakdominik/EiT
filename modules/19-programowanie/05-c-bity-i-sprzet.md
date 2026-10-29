# 19.05 — C blisko sprzętu: bity, typy całkowite, liczby stałoprzecinkowe

## Po co to jest

Konfiguracja mikrokontrolera to ustawianie pojedynczych bitów w rejestrach ([09.02](../09-mikrokontrolery-embedded/02-gpio-i-przerwania.md)); protokoły pakują pola w bajty; filtry na procesorach bez FPU liczą w formacie stałoprzecinkowym ([07.06](../07-cps-dsp/06-realizacja-filtrow.md)). Tu zbierają się subtelne reguły C: promocje typów, przepełnienia, przesunięcia — źródło błędów, które ujawniają się dopiero przy pewnych wartościach.

## Teoria w pigułce

### Operacje bitowe

| Cel | Kod |
|---|---|
| Ustaw bit n | `reg \|= (1u << n);` |
| Wyzeruj bit n | `reg &= ~(1u << n);` |
| Przełącz bit n | `reg ^= (1u << n);` |
| Sprawdź bit n | `if (reg & (1u << n))` |
| Wstaw pole o szerokości w na pozycji p | `reg = (reg & ~(mask << p)) \| ((val & mask) << p);`, `mask = (1u << w) - 1` |
| Odczytaj pole | `(reg >> p) & mask` |

Rejestry sprzętowe deklaruje się jako `volatile` (kompilator nie może pominąć ani połączyć dostępów): `#define GPIOA_ODR (*(volatile uint32_t *)0x40020014u)` — w praktyce używa się nagłówków producenta (CMSIS).

### Typy całkowite — reguły, które gryzą

- **Bez znaku:** arytmetyka modulo $2^N$ — przepełnienie jest zdefiniowane („zawija się”).
- **Ze znakiem:** przepełnienie to **zachowanie niezdefiniowane** (UB) — kompilator może założyć, że nie wystąpi, i „zoptymalizować” kod w zaskakujący sposób.
- **Promocja całkowita:** w wyrażeniach `uint8_t` i `int16_t` są najpierw zamieniane na `int`. Stąd `uint8_t a = 0xF0; if ((uint8_t)~a == 0x0F)` działa, a `if (~a == 0x0F)` — nie (`~a` to `0xFFFFFF0F`).
- **Mieszanie ze znakiem i bez znaku:** `-1 < 1u` jest **fałszem** (−1 zamieniane na `UINT_MAX`).
- **Przesunięcia:** przesunięcie o ≥ szerokość typu to UB; przesunięcie w prawo liczby ujemnej zależy od implementacji (zwykle arytmetyczne); `1 << 31` dla 32-bitowego `int` to UB — pisz `1u << 31`.
- **Kod uzupełnień do dwóch:** $-x = \bar x + 1$; zakres `int16_t`: −32768…32767.

### Liczby stałoprzecinkowe (format Q)

Format **Q15**: liczba 16-bitowa ze znakiem reprezentuje wartość $x/2^{15}$, zakres $[-1, 1)$, rozdzielczość $2^{-15} \approx 3\text{,}05\cdot 10^{-5}$.

- Mnożenie: `int32_t p = (int32_t)a * b;` (iloczyn ma format Q30), wynik Q15: `(int16_t)(p >> 15)` — z zaokrągleniem: `(p + (1 << 14)) >> 15`.
- Dodawanie może przepełnić — stosuje się **nasycenie** (ograniczenie do zakresu) zamiast zawijania.
- Q-format ogólnie: Qm.n — m bitów części całkowitej, n ułamkowej.

## Przykład rozwiązany

**Mnożenie 0,5 · 0,25 w Q15.** $0\text{,}5 \to 0\text{,}5 \cdot 32768 = 16384$; $0\text{,}25 \to 8192$. Iloczyn: $16384 \cdot 8192 = 134\,217\,728$ (Q30). Przesunięcie o 15: $134\,217\,728 / 32768 = 4096$, czyli $4096/32768 = 0\text{,}125$ ✓.

Pułapka: gdyby mnożyć `int16_t * int16_t` z wynikiem w `int16_t`, iloczyn przepełniłby typ. Szczególny przypadek: $-1 \cdot -1$ w Q15 daje $+1$, którego **nie da się** zapisać — potrzebne nasycenie do 32767.

## Typowe pułapki

- **`if (x & MASK == MASK)`** — priorytet `==` jest wyższy niż `&`; pisz `if ((x & MASK) == MASK)`.
- **`~` na typie 8-bitowym** bez rzutowania z powrotem (promocja do `int`).
- **Pętla `for (uint8_t i = 0; i < 256; i++)`** — nigdy się nie kończy.
- **Odczyt-modyfikacja-zapis rejestru** współdzielonego z przerwaniem — może zgubić zmianę; użyj rejestrów atomowych (np. BSRR w STM32) lub zablokuj przerwania.
- **Brak `volatile`** przy zmiennej modyfikowanej w przerwaniu — pętla `while (!flag);` może się nigdy nie zakończyć po optymalizacji.

## Ćwiczenie komputerowe

Pakowanie pól w rejestr, Q15 z nasyceniem i demonstracja promocji typów:

```c
#include <stdint.h>
#include <stdio.h>

static uint32_t field_set(uint32_t reg, unsigned pos, unsigned width, uint32_t val)
{
    uint32_t mask = (width >= 32) ? 0xFFFFFFFFu : ((1u << width) - 1u);
    return (reg & ~(mask << pos)) | ((val & mask) << pos);
}

static int16_t q15_mul(int16_t a, int16_t b)
{
    int32_t p = ((int32_t)a * b + (1 << 14)) >> 15;     /* zaokrąglenie */
    if (p > INT16_MAX) p = INT16_MAX;                    /* nasycenie: (-1)*(-1) */
    if (p < INT16_MIN) p = INT16_MIN;
    return (int16_t)p;
}

int main(void)
{
    uint32_t cfg = 0;
    cfg = field_set(cfg, 4, 3, 5);       /* pole 3-bitowe na bitach 6..4 = 101 */
    cfg = field_set(cfg, 0, 2, 2);       /* pole 2-bitowe na bitach 1..0 = 10 */
    printf("cfg = 0x%02X\n", (unsigned)cfg);                         /* 0x52 */

    printf("0.5*0.25 = %d (%.4f)\n", q15_mul(16384, 8192), q15_mul(16384, 8192) / 32768.0);
    printf("(-1)*(-1) = %d\n", q15_mul(INT16_MIN, INT16_MIN));        /* 32767 */

    uint8_t a = 0xF0;
    printf("~a == 0x0F? %d, (uint8_t)~a == 0x0F? %d\n", ~a == 0x0F, (uint8_t)~a == 0x0F);
    printf("-1 < (int)1u? %d\n", -1 < (int)1u);   /* bez rzutowania wynik to 0 */
    return 0;
}
```

Skompiluj z `-Wall -Wextra` i zobacz ostrzeżenie przy `~a == 0x0F`. Następnie usuń rzutowanie `(int)` w ostatniej linii i sprawdź, co się zmieni.

## Zadania

1. Rejestr ma pole prędkości na bitach 9…7. Zapisz wartość 6 bez zmiany pozostałych bitów.
2. Ile wynosi `(uint8_t)(200 + 100)`, a ile `(int8_t)200` (typowa implementacja)?
3. Zapisz 0,3 w Q15 (z zaokrągleniem). Jaki jest błąd reprezentacji?
4. Dlaczego zmienną ustawianą w przerwaniu i sprawdzaną w pętli głównej trzeba oznaczyć `volatile`? Czy `volatile` wystarcza dla zmiennej 64-bitowej na procesorze 32-bitowym?
5. Filtr liczy sumę 16 próbek 12-bitowych bez znaku. Jaki najmniejszy typ pomieści sumę?

<details>
<summary>Odpowiedzi</summary>

1. `reg = (reg & ~(0x7u << 7)) | ((6u & 0x7u) << 7);`
2. `44` (300 mod 256); `-56` (konwersja do typu ze znakiem poza zakresem jest zdefiniowana przez implementację — zwykle modulo)
3. $0\text{,}3 \cdot 32768 = 9830\text{,}4 \to 9830$; $9830/32768 = 0\text{,}299988$, błąd $\approx 1\text{,}2\cdot 10^{-5}$
4. Bez `volatile` kompilator może wczytać zmienną raz i trzymać w rejestrze — pętla nie zobaczy zmiany. `volatile` nie zapewnia atomowości: odczyt 64-bitowy to dwa dostępy i przerwanie może wejść pomiędzy — trzeba krótko zablokować przerwania lub użyć operacji atomowych
5. $16 \cdot 4095 = 65\,520 < 65\,536$ — wystarczy `uint16_t` (na styk; przy 17 próbkach już nie)
</details>

## Źródła

- [Beej's Guide to C Programming](https://beej.us/guide/bgc/) — operatory bitowe, konwersje typów
- [SEI CERT C Coding Standard](https://wiki.sei.cmu.edu/confluence/display/c/SEI+CERT+C+Coding+Standard) — reguły INT (liczby całkowite)
- [Interrupt (blog Memfault)](https://interrupt.memfault.com/) — `volatile`, rejestry, kod wbudowany
- [ARM CMSIS 6 (GitHub)](https://github.com/ARM-software/CMSIS_6) — nagłówki rejestrów, funkcje DSP w Q15/Q31
