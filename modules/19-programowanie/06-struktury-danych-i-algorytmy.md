# 19.06 — Struktury danych i algorytmy

## Po co to jest

Odbiornik UART buforuje bajty w **buforze kołowym**, filtr liczy **średnią ruchomą**, przelicznik termistora przeszukuje **tablicę** wartości, stos protokołu trzyma pakiety w **kolejce**, a planista zadań RTOS — w **kolejce priorytetowej**. Dobór struktury decyduje, czy kod zmieści się w czasie przerwania. Do tego potrzebna jest umiejętność oceny złożoności — ile operacji wykona algorytm dla N danych.

## Teoria w pigułce

### Złożoność obliczeniowa

| Złożoność | Przykład | N = 1000 → operacji |
|---|---|---|
| $O(1)$ | Dostęp do elementu tablicy, zapis do bufora kołowego | 1 |
| $O(\log N)$ | Wyszukiwanie binarne | ~10 |
| $O(N)$ | Przejście przez tablicę, średnia | 1000 |
| $O(N\log N)$ | Sortowanie (quicksort, mergesort), FFT | ~10 000 |
| $O(N^2)$ | Sortowanie bąbelkowe, DFT wprost, splot wprost | 1 000 000 |
| $O(N^3)$ | Rozwiązanie układu równań metodą Gaussa ([20.03](../20-metody-numeryczne/03-uklady-rownan-liniowych.md)) | $10^9$ |

Przykład z DSP: DFT o długości 4096 wprost to ok. 16,8 mln mnożeń zespolonych, FFT — ok. 25 tys. ([07.02](../07-cps-dsp/02-dft-i-fft.md)).

### Podstawowe struktury

| Struktura | Operacje | Zastosowanie |
|---|---|---|
| Tablica | Dostęp $O(1)$, wstawienie w środek $O(N)$ | Próbki, tablice wartości (LUT) |
| **Bufor kołowy (ring buffer)** | Zapis i odczyt $O(1)$, stały rozmiar | UART, DMA, średnia ruchoma, opóźnienie |
| Stos (LIFO) | push/pop $O(1)$ | Wywołania funkcji, parser wyrażeń |
| Kolejka (FIFO) | enqueue/dequeue $O(1)$ | Zdarzenia, komunikaty między zadaniami |
| Lista łączona | Wstawienie $O(1)$, wyszukanie $O(N)$ | Listy zadań w RTOS (bez alokacji: elementy statyczne) |
| Tablica mieszająca (słownik) | Średnio $O(1)$ | Konfiguracja, cache, `dict` w Pythonie |
| Kopiec (kolejka priorytetowa) | Wstaw/zdejmij min $O(\log N)$ | Planowanie zdarzeń, timery programowe |
| Drzewo binarne poszukiwań | $O(\log N)$ (zrównoważone) | Uporządkowane zbiory |

### Bufor kołowy z rozmiarem potęgi dwójki

Indeksy `head` (zapis) i `tail` (odczyt) rosną bez ograniczeń, a pozycję liczy się maską: `buf[head & (N-1)]`. Liczba elementów = `head - tail` (działa też po przepełnieniu licznika dzięki arytmetyce bez znaku). Przy jednym producencie (przerwanie) i jednym konsumencie (pętla główna) taki bufor nie wymaga blokowania — każdy indeks modyfikuje tylko jedna strona.

### Algorytmy, które warto znać

- **Wyszukiwanie binarne** w posortowanej tablicy — $\lceil\log_2(N+1)\rceil$ porównań.
- **Interpolacja liniowa w tablicy (LUT)** — szybki przelicznik nieliniowych charakterystyk (termistor, linearyzacja czujnika).
- **Średnia ruchoma rekurencyjna** — suma aktualizowana: `sum += x_new - x_old` (koszt $O(1)$ niezależnie od długości okna).
- **Mediana z małego okna** — usuwanie pojedynczych zakłóceń impulsowych.
- **Sortowanie przez wstawianie** — najlepsze dla małych (N < 20) lub prawie posortowanych tablic.

## Przykład rozwiązany

**Przelicznik NTC przez tablicę i interpolację.** Termistor 10 kΩ, B = 3950 K. Wyznacz temperaturę dla R = 8000 Ω z tablicy co 20 °C i co 5 °C (od −20 do 60 °C).

Wartość dokładna z modelu B: $T = \left(\dfrac{\ln(R/R_{25})}{B} + \dfrac{1}{298\text{,}15}\right)^{-1} - 273\text{,}15 = 30\text{,}11$ °C.

- Tablica co 20 °C: sąsiednie punkty 20 °C (12 535 Ω) i 40 °C (5301 Ω), interpolacja liniowa → **32,54 °C** (błąd 2,4 °C — charakterystyka jest silnie nieliniowa).
- Tablica co 5 °C: punkty 30 °C (8037 Ω) i 35 °C (6506 Ω) → **30,12 °C** (błąd 0,01 °C).

Wniosek: 17 wartości `uint16_t` (34 bajty Flash) i interpolacja zastępują logarytm zmiennoprzecinkowy z dokładnością lepszą niż sam czujnik. Wyszukanie przedziału: binarne, 5 porównań.

```python
import numpy as np
B, R25 = 3950, 10e3
R_of_T = lambda t: R25*np.exp(B*(1/(t + 273.15) - 1/298.15))
exact = 1/(np.log(8000/R25)/B + 1/298.15) - 273.15
for step in (20, 5):
    T = np.arange(-20, 61, step); R = R_of_T(T)
    t_lut = np.interp(8000, R[::-1], T[::-1])        # interp wymaga rosnących x
    print(f"krok {step:2d} °C: {t_lut:.2f} °C (błąd {t_lut - exact:+.2f} °C)")
print(f"dokładnie: {exact:.2f} °C")
```

## Typowe pułapki

- **Bufor kołowy bez rozróżnienia „pełny/pusty”** — przy indeksach w zakresie 0…N−1 oba stany dają `head == tail`; rozwiązania: liczniki bez ograniczeń (jak wyżej) albo jedno pole zawsze wolne.
- **Średnia ruchoma rekurencyjna na `float`** — błędy zaokrągleń kumulują się; licz sumę na liczbach całkowitych.
- **Algorytm $O(N^2)$ ukryty w pętli** (np. `list.remove` lub `x in lista` w pętli w Pythonie).
- **Optymalizacja bez pomiaru** — najpierw zmierz, gdzie program traci czas.

## Ćwiczenie komputerowe

Bufor kołowy w C z rozmiarem potęgi dwójki i średnią ruchomą na nim:

```c
#include <stdint.h>
#include <stdio.h>

#define RB_SIZE 8u                          /* potęga dwójki */
typedef struct { int16_t buf[RB_SIZE]; uint32_t head, tail; } ring_t;

static int rb_put(ring_t *r, int16_t v)
{
    if (r->head - r->tail == RB_SIZE) return -1;     /* pełny */
    r->buf[r->head & (RB_SIZE - 1u)] = v; r->head++;
    return 0;
}
static int rb_get(ring_t *r, int16_t *v)
{
    if (r->head == r->tail) return -1;              /* pusty */
    *v = r->buf[r->tail & (RB_SIZE - 1u)]; r->tail++;
    return 0;
}

/* średnia ruchoma z 4 próbek, suma aktualizowana rekurencyjnie */
typedef struct { int16_t win[4]; uint8_t idx; int32_t sum; } mavg_t;
static int16_t mavg(mavg_t *m, int16_t x)
{
    m->sum += x - m->win[m->idx];
    m->win[m->idx] = x;
    m->idx = (uint8_t)((m->idx + 1u) & 3u);
    return (int16_t)(m->sum / 4);
}

int main(void)
{
    ring_t rb = {0};
    mavg_t ma = {0};
    for (int16_t i = 0; i < 10; i++)
        if (rb_put(&rb, (int16_t)(i * 10)) != 0) printf("pełny przy %d\n", i);
    int16_t v;
    while (rb_get(&rb, &v) == 0) printf("%d -> średnia %d\n", v, mavg(&ma, v));
    return 0;
}
```

Bufor przyjmie 8 próbek (0…70), próby zapisu 80 i 90 zgłoszą „pełny”. Średnia ruchoma narasta w pierwszych 3 próbkach (okno wypełnione zerami), potem wynosi kolejno 15, 25, …, 55.

## Zadania

1. Ile porównań wymaga wyszukiwanie binarne w tablicy 1 000 000 elementów?
2. Ile czasu zajmie DFT wprost dla N = 1024 na procesorze wykonującym 100 mln mnożeń zespolonych na sekundę, a ile FFT?
3. Dlaczego w buforze kołowym rozmiar będący potęgą dwójki ułatwia życie?
4. Zaprojektuj strukturę do przechowywania 10 ostatnich zdarzeń błędów (kod + czas), nadpisującą najstarsze.
5. Czujnik zwraca czasem pojedyncze próbki o wartości 0 (błąd transmisji). Jaki filtr je usunie, a średnia ruchoma nie?

<details>
<summary>Odpowiedzi</summary>

1. $\lceil\log_2(10^6 + 1)\rceil = 20$
2. DFT: $1024^2 \approx 1\text{,}05\cdot 10^6$ mnożeń → ok. 10 ms; FFT: $\tfrac{N}{2}\log_2 N = 5120$ → ok. 51 µs
3. Indeks liczy się maską `& (N−1)` zamiast dzielenia modulo (szybsze), a liczniki bez znaku mogą się przepełniać — różnica `head − tail` pozostaje poprawna
4. Bufor kołowy 10 (lub 16) struktur `{uint16_t code; uint32_t t;}` z zapisem bez sprawdzania „pełny” — nadpisuje najstarszy; dodatkowo licznik wszystkich zdarzeń
5. Filtr medianowy (np. z 3 lub 5 próbek); średnia ruchoma tylko „rozmyje” błąd na kilka próbek
</details>

## Źródła

- [Harvard CS50 (YouTube)](https://www.youtube.com/results?search_query=CS50+Harvard+data+structures) — struktury danych w C
- [MIT 6.006 Introduction to Algorithms (2020)](https://ocw.mit.edu/courses/6-006-introduction-to-algorithms-spring-2020/) — złożoność, sortowanie, struktury
- [Interrupt (blog Memfault)](https://interrupt.memfault.com/) — bufory i struktury w systemach wbudowanych
- T. H. Cormen i in. — *Introduction to Algorithms* (płatna)
