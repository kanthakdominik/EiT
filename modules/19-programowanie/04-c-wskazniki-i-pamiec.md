# 19.04 — C: wskaźniki, tablice, struktury, pamięć

## Po co to jest

Wskaźnik to adres w pamięci — a w mikrokontrolerze rejestr układu peryferyjnego **jest** adresem w pamięci. Bufory DMA, ramki protokołów, sterowniki, tablice próbek przekazywane do filtrów — wszystko to wskaźniki i struktury. Większość poważnych błędów w C (zawieszenia, uszkodzone dane, luki bezpieczeństwa) bierze się z niezrozumienia tego tematu.

## Teoria w pigułce

### Wskaźniki

```c
int x = 10;
int *p = &x;    /* p przechowuje adres x */
*p = 20;        /* zapis pod adres -> x == 20 */
```

- `&x` — adres zmiennej; `*p` — wartość pod adresem (dereferencja).
- **Przekazywanie przez wskaźnik** pozwala funkcji zmienić zmienną wywołującego lub zwrócić kilka wyników.
- `NULL` — wskaźnik „donikąd”; dereferencja to błąd.
- `const int *p` — nie zmienisz wartości przez `p`; `int *const p` — nie zmienisz samego `p`.

### Tablice i arytmetyka wskaźników

- Nazwa tablicy w wyrażeniu **zamienia się** we wskaźnik na pierwszy element: `a[i]` ≡ `*(a + i)`.
- `p + 1` przesuwa o **rozmiar elementu**, nie o bajt.
- Funkcja nie zna rozmiaru przekazanej tablicy — przekazuj długość osobno: `void f(const int16_t *x, size_t n)`.
- Napisy to tablice `char` zakończone `'\0'`; bufor musi mieć miejsce na terminator.

### Struktury

```c
typedef struct {
    uint8_t  id;
    int16_t  temp_c10;     /* temperatura w 0,1 °C */
    uint32_t timestamp_ms;
} sample_t;

void print_sample(const sample_t *s) { printf("%u: %d\n", s->id, s->temp_c10); }
```

- Dostęp `s.pole` (zmienna) lub `p->pole` (wskaźnik).
- Kompilator może dodawać **wypełnienie (padding)** — `sizeof(sample_t)` to tu zwykle 8, nie 7. Nie wysyłaj struktury „jak leci” przez UART do innego procesora — serializuj pola.

### Gdzie leży pamięć

| Obszar | Co tam jest | Czas życia |
|---|---|---|
| Statyczny (`.data`, `.bss`) | Zmienne globalne i `static` | Cały program |
| Stos | Zmienne lokalne, argumenty | Do wyjścia z funkcji |
| Sterta (`malloc`/`free`) | Alokacje dynamiczne | Do `free` |
| Flash (`.rodata` na MCU) | Stałe `const`, tablice wartości | Cały program |

W systemach wbudowanych **unika się `malloc`** (fragmentacja, nieprzewidywalny czas, brak pamięci w trakcie pracy) — bufory przydziela się statycznie. Stos jest mały (kilka kB) — duża tablica lokalna potrafi go przepełnić.

## Przykład rozwiązany

**Funkcja zwracająca trzy wyniki: minimum, maksimum i średnią bloku próbek.**

```c
#include <stdint.h>
#include <stddef.h>
#include <stdio.h>

typedef struct { int16_t min, max; int32_t mean; } stats_t;

int block_stats(const int16_t *x, size_t n, stats_t *out)
{
    if (x == NULL || out == NULL || n == 0) return -1;     /* błędne argumenty */
    int16_t mn = x[0], mx = x[0];
    int64_t sum = 0;                                       /* suma n próbek 16-bitowych */
    for (size_t i = 0; i < n; i++) {
        if (x[i] < mn) mn = x[i];
        if (x[i] > mx) mx = x[i];
        sum += x[i];
    }
    out->min = mn; out->max = mx; out->mean = (int32_t)(sum / (int64_t)n);
    return 0;
}

int main(void)
{
    int16_t adc[] = {512, 498, 530, -12, 505, 1023};
    stats_t s;
    if (block_stats(adc, sizeof adc / sizeof adc[0], &s) == 0)
        printf("min %d, max %d, średnia %ld\n", s.min, s.max, (long)s.mean);
    return 0;
}
```

Wynik: `min -12, max 1023, średnia 509`. Elementy wzorca: `const` przy danych wejściowych, długość jako osobny argument, wynik przez wskaźnik na strukturę, kod błędu jako wartość zwracana, suma w szerszym typie.

## Typowe pułapki

- **Zwrócenie adresu zmiennej lokalnej** — po wyjściu z funkcji stos jest nadpisywany.
- **Wyjście poza tablicę** (`i <= n` zamiast `i < n`) — C tego nie sprawdza; nadpisane zostaje coś innego.
- **`sizeof` tablicy w funkcji** — daje rozmiar wskaźnika (4 lub 8 bajtów).
- **Brak miejsca na `'\0'`** w buforze napisu; `strcpy` bez sprawdzenia długości — użyj `snprintf`.
- **Wyciek pamięci** — `malloc` bez `free`; podwójne `free`; użycie po `free`.
- **Rzutowanie bufora bajtów na strukturę** — wyrównanie i kolejność bajtów (endianness) mogą się nie zgadzać.

## Ćwiczenie komputerowe

Parsowanie ramki binarnej z czujnika (bajty w kolejności little-endian) bez rzutowania wskaźników:

```c
#include <stdint.h>
#include <stdio.h>

typedef struct { uint8_t id; int16_t temp_c10; uint32_t timestamp_ms; } sample_t;

static uint16_t rd_u16le(const uint8_t *p) { return (uint16_t)(p[0] | (p[1] << 8)); }
static uint32_t rd_u32le(const uint8_t *p)
{
    return (uint32_t)p[0] | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}

static int parse_frame(const uint8_t *buf, size_t len, sample_t *s)
{
    if (len < 7) return -1;
    s->id = buf[0];
    s->temp_c10 = (int16_t)rd_u16le(&buf[1]);
    s->timestamp_ms = rd_u32le(&buf[3]);
    return 0;
}

int main(void)
{
    const uint8_t frame[] = {0x07, 0x1F, 0xFF, 0x10, 0x27, 0x00, 0x00};   /* id 7, -22.5 °C, 10000 ms */
    sample_t s;
    if (parse_frame(frame, sizeof frame, &s) == 0)
        printf("czujnik %u: %.1f °C, t = %lu ms\n", s.id, s.temp_c10 / 10.0, (unsigned long)s.timestamp_ms);
    printf("sizeof(sample_t) = %zu\n", sizeof(sample_t));
    return 0;
}
```

Sprawdź: `0xFF1F` jako `int16_t` to $-225$, czyli $-22\text{,}5$ °C; `0x00002710` = 10 000. Ramka ma 7 bajtów, a struktura w pamięci — zwykle 8.

## Zadania

1. Napisz `void swap16(int16_t *a, int16_t *b)` zamieniającą wartości.
2. `int16_t buf[100]; int16_t *p = buf + 10;` — który element wskazuje `p[5]`? O ile bajtów `p` jest dalej niż `buf`?
3. Co jest nie tak: `char *name(void) { char s[16]; snprintf(s, 16, "R%d", 5); return s; }`? Podaj dwie poprawki.
4. Dlaczego `sizeof(struct {uint8_t a; uint32_t b;})` wynosi zwykle 8?
5. Masz 32 kB RAM i 4 kB stosu. Czy można w funkcji zadeklarować lokalną tablicę `float x[2048]`?

<details>
<summary>Odpowiedzi</summary>

1. `{ int16_t t = *a; *a = *b; *b = t; }`
2. `buf[15]`; o 20 bajtów (10 elementów × 2 bajty)
3. Zwraca adres tablicy lokalnej. Poprawki: bufor przekazany przez wywołującego (`void name(char *s, size_t n)`) albo `static char s[16]` (uwaga: wspólny dla wszystkich wywołań, nie nadaje się do wielu wątków/przerwań)
4. `uint32_t` wymaga wyrównania do 4 bajtów, więc po `a` kompilator wstawia 3 bajty wypełnienia
5. Nie — $2048 \cdot 4 = 8$ kB > 4 kB stosu; przepełnienie nadpisze inne dane. Tablica statyczna (`static` lub globalna) albo mniejsze bloki
</details>

## Źródła

- [Beej's Guide to C Programming](https://beej.us/guide/bgc/) — wskaźniki, tablice, struktury, pamięć
- J. Gustedt — *Modern C* (płatna) — model pamięci C
- [Interrupt (blog Memfault)](https://interrupt.memfault.com/) — pamięć w systemach wbudowanych, przepełnienia stosu
