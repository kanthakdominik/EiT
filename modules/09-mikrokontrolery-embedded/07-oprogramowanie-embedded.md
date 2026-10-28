# 09.07 — Oprogramowanie wbudowane: C, architektura programu, RTOS

## Po co to jest

Firmware działa latami bez restartu, na ograniczonej pamięci, w kontakcie ze sprzętem i czasem rzeczywistym. Wymaga innych nawyków niż programowanie aplikacji: przewidywalnego zużycia pamięci, świadomego użycia przerwań i współbieżności, ochrony przed zawieszeniem i możliwości diagnozy błędów w terenie.

## Teoria w pigułce

### C dla systemów wbudowanych

| Element | Po co |
|---|---|
| `stdint.h` (`uint8_t`, `int32_t`…) | Jawna szerokość typów |
| `volatile` | Rejestry sprzętowe i zmienne zmieniane w przerwaniach |
| Operacje bitowe (`&`, `\|`, `^`, `~`, `<<`, `>>`) | Konfiguracja rejestrów, maski, flagi |
| `const` | Dane w pamięci Flash zamiast RAM |
| `static` | Ograniczenie zasięgu, zmienne o stałym czasie życia |
| Unikanie `malloc` w działającym systemie | Fragmentacja sterty, nieprzewidywalność |

Ustawienie bitu: `reg |= (1u << n)`, kasowanie: `reg &= ~(1u << n)`, przełączenie: `reg ^= (1u << n)`, test: `if (reg & (1u << n))`.

**Pamięć:** `.text` (kod, Flash), `.rodata` (stałe, Flash), `.data` (zmienne inicjalizowane, RAM + kopia we Flash), `.bss` (zerowane, RAM), stos, sterta. Przepełnienie stosu to częsta przyczyna losowych awarii — mierz zużycie (wypełnianie wzorcem, MPU).

### Architektury programu

| Architektura | Cechy | Kiedy |
|---|---|---|
| **Superpętla** | `while(1)` wywołuje kolejne funkcje; przerwania ustawiają flagi | Proste urządzenia |
| **Automaty stanów** | Każdy moduł to automat, nie blokuje (bez `delay`) | Średnie systemy, protokoły, interfejs użytkownika |
| Planista zdarzeń / kooperacyjny | Kolejka zdarzeń, zadania wywoływane cyklicznie | Systemy z wieloma niezależnymi czynnościami |
| **RTOS** (np. FreeRTOS, Zephyr) | Zadania z priorytetami i wywłaszczaniem, kolejki, semafory, muteksy | Złożone systemy, stosy komunikacyjne, twarde wymagania czasowe |

### RTOS — pojęcia

- **Zadanie (task)** — osobny stos i priorytet; planista uruchamia najwyższy gotowy priorytet.
- **Kolejka** — przekazywanie danych między zadaniami i z przerwań.
- **Semafor** — sygnalizacja zdarzeń; **muteks** — wyłączny dostęp do zasobu, z dziedziczeniem priorytetów.
- **Inwersja priorytetów** — zadanie wysokie czeka na zasób trzymany przez niskie, wywłaszczane przez średnie. Zapobiega jej dziedziczenie priorytetów.
- **Zakleszczenie** — dwa zadania czekają na zasoby trzymane wzajemnie; zapobiega mu stała kolejność zajmowania zasobów.
- Z przerwań wolno wywoływać tylko specjalne wersje funkcji RTOS (np. `...FromISR`).

### Niezawodność

- **Watchdog** — odświeżany tylko wtedy, gdy wszystkie kluczowe zadania potwierdziły działanie (nie z przerwania timera!).
- Obsługa błędów sprzętowych (HardFault) z zapisem przyczyny do pamięci podtrzymywanej.
- Asercje w czasie tworzenia, logowanie, wersja oprogramowania w obrazie, bezpieczna aktualizacja (bootloader z dwiema partycjami).

### Debugowanie i testy

Debuger SWD/JTAG (pułapki, podgląd zmiennych, pułapki na zapis do pamięci), śledzenie (ITM/SWO, RTT), analizator stanów logicznych, przełączanie pinu GPIO do pomiaru czasu oscyloskopem. **Testy jednostkowe logiki na komputerze** (jak w ćwiczeniach tego modułu) — warstwa sprzętowa oddzielona interfejsem.

## Przykład rozwiązany

Nieblokujący automat stanów migający diodą i obsługujący przycisk — bez `delay()`, sterowany czasem systemowym:

```c
#include <stdint.h>
#include <stdio.h>

typedef enum { LED_OFF, LED_ON, LED_BLINK } led_mode_t;
typedef struct { led_mode_t mode; uint32_t last; uint8_t out; } led_t;

void led_on_button(led_t *l) { l->mode = (led_mode_t)((l->mode + 1) % 3); }

void led_update(led_t *l, uint32_t now_ms) {        /* wywoływane w każdym obiegu pętli */
    switch (l->mode) {
    case LED_OFF:   l->out = 0; break;
    case LED_ON:    l->out = 1; break;
    case LED_BLINK:
        if ((uint32_t)(now_ms - l->last) >= 250u) { l->last = now_ms; l->out ^= 1u; }
        break;
    }
}

int main(void) {                                     /* test na komputerze */
    led_t led = {LED_OFF, 0, 0};
    led_on_button(&led); led_on_button(&led);        /* -> LED_BLINK */
    int toggles = 0; uint8_t prev = led.out;
    for (uint32_t t = 0; t < 2000; t++) {            /* 2 s symulowanego czasu */
        led_update(&led, t);
        if (led.out != prev) { toggles++; prev = led.out; }
    }
    printf("przełączeń w 2 s: %d\n", toggles);       /* oczekiwane: 7 (t = 250, 500, …, 1750 ms) */
    return 0;
}
```

Odejmowanie `now_ms - l->last` na liczbach bez znaku działa poprawnie także po przepełnieniu licznika czasu (co ok. 49 dni dla 32 bitów w ms).

## Typowe pułapki

- **`delay()` w pętli głównej** — cały system „zamarza” na czas oczekiwania.
- **Porównanie czasu `if (now > deadline)`** — błędne po przepełnieniu licznika; używaj różnicy bez znaku.
- **Za mały stos zadania RTOS** — losowe awarie; włącz wykrywanie przepełnienia stosu.
- **Watchdog odświeżany w przerwaniu timera** — system z zawieszoną pętlą główną nie zostanie zresetowany.
- **Zmienne współdzielone bez ochrony** między zadaniami.
- **`printf` w przerwaniu** lub w zadaniu o wysokim priorytecie — długie i nieprzewidywalne.

## Ćwiczenie praktyczne

- [ ] Skompiluj i uruchom przykład na komputerze (`gcc -Wall -o led led.c && ./led`), potem przenieś `led_update` na mikrokontroler z licznikiem ms z przerwania SysTick.
- [ ] Przepisz projekt rejestratora z superpętli na FreeRTOS: zadanie akwizycji, zadanie przetwarzania, zadanie komunikacji, kolejki między nimi.
- [ ] Wywołaj celowo HardFault (dostęp do nieprawidłowego adresu) i odczytaj przyczynę z rejestrów błędu w debugerze.

## Zadania

1. Zapisz w C: ustawienie bitów 3 i 5, skasowanie bitu 0, przełączenie bitu 7 rejestru `reg`.
2. Licznik ms jest 32-bitowy. Po ilu dniach się przepełni? Czy `(now - start) >= 1000` działa poprawnie w chwili przepełnienia?
3. Opisz przebieg inwersji priorytetów na przykładzie trzech zadań i jednego muteksu.
4. Dlaczego watchdog należy odświeżać dopiero po potwierdzeniu działania wszystkich kluczowych zadań?
5. Kiedy wybierzesz superpętlę z automatami stanów, a kiedy RTOS?

<details>
<summary>Odpowiedzi</summary>

1. `reg |= (1u << 3) | (1u << 5); reg &= ~1u; reg ^= (1u << 7);`
2. $2^{32}$ ms ≈ 49,7 dnia; tak — arytmetyka bez znaku modulo $2^{32}$ daje poprawną różnicę
3. Zadanie N (niskie) bierze muteks; W (wysokie) chce go i czeka; S (średnie), niepotrzebujące muteksu, wywłaszcza N — W czeka tak długo, jak działa S. Z dziedziczeniem priorytetów N dostaje na chwilę priorytet W i szybko zwalnia muteks
4. Inaczej watchdog nie wykryje zawieszenia jednego z zadań — system będzie wyglądał na żywy, choć nie realizuje funkcji
5. Superpętla: proste urządzenia, niewiele niezależnych czynności, ograniczona pamięć, łatwa analiza. RTOS: wiele niezależnych czynności o różnych wymaganiach czasowych, stosy komunikacyjne (TCP/IP, BLE, USB), praca zespołowa nad modułami
</details>

## Źródła

- [Mastering the FreeRTOS Real Time Kernel](https://github.com/FreeRTOS/FreeRTOS-Kernel-Book) — oficjalna książka o FreeRTOS (zadania, kolejki, semafory, muteksy)
- [Interrupt (blog Memfault)](https://interrupt.memfault.com/) — debugowanie HardFault, testy jednostkowe firmware, watchdogi, budowanie projektów
- [Embedded Systems — Shape the World (J. Valvano)](https://users.ece.utexas.edu/~valvano/Volume1/E-Book/) — automaty stanów, programowanie w C
