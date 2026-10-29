# 19.03 — C: podstawy, kompilacja, typy

## Po co to jest

C jest językiem oprogramowania mikrokontrolerów ([moduł 09](../09-mikrokontrolery-embedded/)), sterowników, systemów czasu rzeczywistego i bibliotek numerycznych. Daje pełną kontrolę nad pamięcią i sprzętem — i dokładnie tyle samo odpowiedzialności: kompilator nie sprawdzi zakresów tablic ani przepełnień. Ten temat uczy pisać i budować proste programy na komputerze; te same programy (bez `printf`) działają potem na mikrokontrolerze.

## Teoria w pigułce

### Od źródła do programu

1. **Preprocesor** — `#include`, `#define`, `#if`: tekstowe podstawienia.
2. **Kompilacja** — każdy plik `.c` osobno → plik obiektowy `.o`.
3. **Linkowanie** — łączenie obiektów i bibliotek w plik wykonywalny (na MCU: plik `.elf`/`.bin`).

```text
gcc -std=c11 -Wall -Wextra -O2 -c adc.c -o adc.o
gcc -std=c11 -Wall -Wextra -O2 -c main.c -o main.o
gcc adc.o main.o -o pomiar -lm
```

**Zawsze z ostrzeżeniami** (`-Wall -Wextra`) — większość błędów początkującego kompilator zgłasza jako ostrzeżenie.

### Plik nagłówkowy i podział na moduły

- `adc.h` — **deklaracje** (prototypy funkcji, typy, stałe) + strażnik `#ifndef ADC_H / #define ADC_H / #endif`.
- `adc.c` — **definicje**; `static` przy funkcji lub zmiennej globalnej = widoczna tylko w tym pliku.
- `main.c` — `#include "adc.h"` i korzysta z interfejsu.

### Typy, operatory, sterowanie

| Typ | Typowy rozmiar (PC / ARM Cortex-M) | Uwagi |
|---|---|---|
| `char` | 8 bit | Znakowość zależy od platformy! |
| `int` | 32 bit (na AVR: 16 bit) | Rozmiar zależny od platformy |
| `long` | 64 / 32 bit | Też zależny |
| `float`, `double` | 32 / 64 bit | Cortex-M4F ma sprzętowo tylko `float` |
| `uint8_t`, `int16_t`, `uint32_t` … | Dokładnie tyle bitów | Z `<stdint.h>` — **używaj w kodzie sprzętowym** |

- Dzielenie całkowite obcina w stronę zera: `-7 / 2 == -3`, `-7 % 2 == -1`.
- `if/else`, `switch` (pamiętaj o `break`), `for`, `while`, `do … while`.
- Zmienne lokalne nie są inicjalizowane — zawsze nadaj wartość początkową.
- `const` dla wartości, które się nie zmieniają; `#define` tylko dla stałych preprocesora i makr.

## Przykład rozwiązany

**Przeliczenie odczytu ADC na miliwolty bez liczb zmiennoprzecinkowych.** ADC 12-bitowy, napięcie odniesienia 3300 mV, odczyt 2048.

$$U = \frac{\text{raw}\cdot U_{ref}}{4096} = \frac{2048\cdot 3300}{4096} = 1650\ \text{mV}$$

```c
#include <stdint.h>
#include <stdio.h>

#define VREF_MV  3300u
#define ADC_FULL 4096u

static uint32_t adc_to_mv(uint16_t raw)
{
    return ((uint32_t)raw * VREF_MV) / ADC_FULL;   /* najpierw mnożenie, potem dzielenie */
}

int main(void)
{
    uint16_t samples[] = {0, 1, 2048, 4095};
    for (unsigned i = 0; i < sizeof samples / sizeof samples[0]; i++)
        printf("raw = %4u -> %4u mV\n", (unsigned)samples[i], (unsigned)adc_to_mv(samples[i]));
    return 0;
}
```

Dlaczego tak: `raw / 4096 * 3300` dałoby 0 dla każdego odczytu poniżej 4096 (dzielenie całkowite). Iloczyn $4095\cdot 3300 = 13\,513\,500$ mieści się w 32 bitach, ale **nie** w 16 — dlatego rzutowanie na `uint32_t` przed mnożeniem (na 8-bitowym AVR `int` ma 16 bitów i bez rzutowania wynik byłby błędny).

## Typowe pułapki

- **Kolejność dzielenia i mnożenia** w arytmetyce całkowitej (przykład wyżej).
- **`=` zamiast `==`** w warunku — `-Wall` ostrzega (`-Wparentheses`).
- **Brak `break` w `switch`** — wykonanie „przelatuje” do następnego `case`.
- **Niezainicjalizowana zmienna lokalna** — wartość przypadkowa, błąd pojawia się nieregularnie.
- **`printf` z błędnym formatem** (`%d` dla `uint32_t`) — użyj rzutowania lub makr `PRIu32` z `<inttypes.h>`.
- **Średnik po `if (...)`** — `if (x > 0); y = 1;` zawsze przypisuje.

## Ćwiczenie komputerowe

Program liczący dzielnik i moc strat — podział na pliki i budowanie przez `make`. Utwórz trzy pliki:

```c
/* divider.h */
#ifndef DIVIDER_H
#define DIVIDER_H
double divider_vout(double vin, double r1, double r2);
double divider_power(double vin, double r1, double r2);
#endif
```

```c
/* divider.c */
#include "divider.h"
double divider_vout(double vin, double r1, double r2) { return vin * r2 / (r1 + r2); }
double divider_power(double vin, double r1, double r2) { return vin * vin / (r1 + r2); }
```

```c
/* main.c */
#include <stdio.h>
#include "divider.h"
int main(void)
{
    const double vin = 5.0, r1 = 4700.0, r2 = 9100.0;
    printf("Uwy = %.4f V, P = %.2f mW\n", divider_vout(vin, r1, r2), 1e3 * divider_power(vin, r1, r2));
    return 0;
}
```

```text
# Makefile (wcięcia tabulatorem!)
CFLAGS = -std=c11 -Wall -Wextra -O2
pomiar: main.o divider.o
	$(CC) $^ -o $@
clean:
	rm -f *.o pomiar
```

Oczekiwany wynik: `Uwy = 3.2971 V, P = 1.81 mW`. Zmień potem `r1` na `0` i zobacz, czy program się nie wysypie — a jeśli działa, zastanów się, co by było przy `r1 = r2 = 0`.

## Zadania

1. Ile wynoszą w C: `7 / 2`, `-7 / 2`, `7 % -2`, `7 / 2.0`, `(double)(7 / 2)`?
2. Napisz funkcję `uint16_t mv_to_dac(uint32_t mv)` dla 12-bitowego DAC z $U_{ref}$ = 3300 mV, z zaokrągleniem do najbliższej wartości i ograniczeniem do 4095.
3. Do czego służy słowo `static` przy funkcji w pliku `.c`, a do czego przy zmiennej lokalnej?
4. Program kompiluje się, ale linker zgłasza `undefined reference to 'divider_vout'`. Co jest nie tak?
5. Dlaczego w kodzie dla mikrokontrolerów używa się `uint16_t` zamiast `unsigned int`?

<details>
<summary>Odpowiedzi</summary>

1. `3`, `-3`, `1`, `3.5`, `3.0`
2. `uint32_t v = (mv * 4095u + 1650u) / 3300u; return v > 4095u ? 4095u : (uint16_t)v;` (dodanie połowy dzielnika daje zaokrąglenie)
3. Przy funkcji (i zmiennej globalnej): widoczność tylko w danym pliku (brak konfliktów nazw). Przy zmiennej lokalnej: zmienna żyje przez cały czas programu i zachowuje wartość między wywołaniami
4. Nie dołączono `divider.o` (lub `divider.c`) do linkowania, albo nazwa/sygnatura w definicji różni się od deklaracji
5. Rozmiar `unsigned int` zależy od platformy (16 bit na AVR, 32 bit na ARM); typy z `<stdint.h>` mają gwarantowaną szerokość — ważne przy rejestrach, protokołach i przepełnieniach
</details>

## Źródła

- [Beej's Guide to C Programming](https://beej.us/guide/bgc/) — rozdziały 1–9
- [Harvard CS50 (YouTube)](https://www.youtube.com/results?search_query=CS50+Harvard+lecture) — wykłady o C
- [GCC — Warning Options](https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html)
- [GNU make — manual](https://www.gnu.org/software/make/manual/make.html)
