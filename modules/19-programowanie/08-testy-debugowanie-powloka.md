# 19.08 — Testowanie, debugowanie i wiersz poleceń

## Po co to jest

Kod, którego nikt nie testował, nie działa — tylko jeszcze o tym nie wiadomo. W elektronice błąd oprogramowania wygląda jak błąd sprzętu („płytka się zawiesza”), więc umiejętność szybkiego zawężenia przyczyny jest kluczowa przy uruchamianiu ([16.08](../16-pcb-emc-konstrukcja/08-produkcja-montaz-uruchamianie.md)). Testy jednostkowe na komputerze, sanitizery, debuger i sprawna praca w powłoce skracają to z dni do godzin.

## Teoria w pigułce

### Testy jednostkowe

- Testuje się **małe funkcje w izolacji** — filtr, parser ramki, bufor kołowy, przelicznik — na komputerze, bez sprzętu.
- Kod sprzętowy oddziela się od logiki: funkcja `parse_frame(buf, len, out)` jest testowalna, funkcja czytająca bezpośrednio rejestr UART — nie.
- **Przypadki brzegowe:** zero, jeden element, pełny bufor, wartości maksymalne i minimalne, dane błędne.
- W Pythonie: `pytest` (funkcje `test_...` z `assert`); w C: proste makra `assert` albo biblioteki (Unity, CMocka).
- **Ciągła integracja (CI)** — testy uruchamiane automatycznie przy każdym `push` (np. GitHub Actions; to repozytorium tak sprawdza swoje przykłady).

### Sanitizery i ostrzeżenia

| Narzędzie | Wykrywa |
|---|---|
| `-Wall -Wextra -Wconversion` | Podejrzane konstrukcje, niejawne konwersje |
| `-fsanitize=address` (ASan) | Wyjście poza tablicę, użycie po `free`, wycieki |
| `-fsanitize=undefined` (UBSan) | Przepełnienie liczb ze znakiem, złe przesunięcia, dzielenie przez 0 |
| `valgrind` | Błędy pamięci bez rekompilacji (wolniej) |
| `cppcheck`, `clang-tidy` | Analiza statyczna bez uruchamiania |

### Debuger

- `gcc -g -O0` → `gdb ./program`: `break funkcja`, `run`, `next`, `step`, `print zmienna`, `backtrace` (gdzie program się wysypał), `watch zmienna` (zatrzymaj przy zmianie).
- Na mikrokontrolerze ten sam `gdb` łączy się przez sondę SWD/JTAG (OpenOCD, pyOCD) — pułapki, podgląd rejestrów i pamięci ([09.01](../09-mikrokontrolery-embedded/01-architektura.md)).
- **Strategia:** odtwórz błąd → zawęź (połowienie, `git bisect`) → postaw hipotezę → sprawdź jednym eksperymentem → popraw → dodaj test, który by ten błąd wykrył.

### Powłoka (bash)

| Polecenie | Do czego |
|---|---|
| `ls`, `cd`, `pwd`, `mkdir`, `cp`, `mv`, `rm` | Pliki i katalogi |
| `cat`, `less`, `head`, `tail -f` | Podgląd plików i logów na żywo |
| `grep -rn "wzorzec" katalog` | Wyszukiwanie w plikach |
| `find . -name "*.csv"` | Wyszukiwanie plików |
| `\|` (potok), `>` / `>>` (przekierowanie) | Łączenie programów, zapis wyniku |
| `sort`, `uniq -c`, `wc -l`, `cut`, `awk` | Szybka analiza tekstu |
| `for f in *.csv; do ...; done` | Pętle po plikach |
| `screen /dev/ttyUSB0 115200`, `picocom` | Terminal szeregowy |

## Przykład rozwiązany

**Błąd o jeden (off-by-one) wykryty sanitizerem.** Funkcja liczy średnią z okna, ale czasem zwraca dziwne wartości:

```c
#include <stdio.h>
static int mean(const int *x, int n)
{
    int s = 0;
    for (int i = 0; i <= n; i++) s += x[i];   /* błąd: i <= n */
    return s / n;
}
int main(void) { int a[4] = {1, 2, 3, 4}; printf("%d\n", mean(a, 4)); return 0; }
```

Bez sanitizera program zwykle wypisze jakąś liczbę (czyta „śmieć” spoza tablicy) — błąd ujawni się nieregularnie. Kompilacja `gcc -g -fsanitize=address mean.c && ./a.out` przerywa program z raportem `stack-buffer-overflow ... READ of size 4` i numerem linii pętli. Poprawka `i < n`, wynik `2`. Następny krok: test jednostkowy z oknem długości 1 i z wartościami, dla których wynik jest znany.

## Typowe pułapki

- **Testowanie tylko „szczęśliwej ścieżki”** — błędy siedzą w przypadkach brzegowych.
- **`printf` jako jedyne narzędzie** — w przerwaniach zmienia zależności czasowe i może ukryć błąd.
- **Kompilacja testowa z `-O0`, produkcyjna z `-O2`** — część błędów (UB, brak `volatile`) pojawia się dopiero z optymalizacją; testuj też wersję zoptymalizowaną.
- **Poprawka bez testu** — ten sam błąd wraca po kolejnej zmianie.
- **`rm -rf` ze zmienną**, która okazała się pusta — w skryptach używaj `set -euo pipefail`.

## Ćwiczenie komputerowe

Testy w stylu `pytest` — tutaj uruchamiane zwykłym wywołaniem funkcji, żeby działały bez instalacji:

```python
def ring_mean(samples, window):
    """Średnia ruchoma: zwraca listę średnich z ostatnich `window` próbek (od pierwszej pełnej)."""
    if window <= 0:
        raise ValueError("okno musi być dodatnie")
    out, s = [], 0
    for i, x in enumerate(samples):
        s += x
        if i >= window:
            s -= samples[i - window]
        if i >= window - 1:
            out.append(s / window)
    return out

def test_basic():
    assert ring_mean([1, 2, 3, 4], 2) == [1.5, 2.5, 3.5]

def test_window_one():
    assert ring_mean([5, -1, 7], 1) == [5, -1, 7]

def test_window_longer_than_data():
    assert ring_mean([1, 2], 3) == []

def test_bad_window():
    try:
        ring_mean([1], 0)
    except ValueError:
        return
    raise AssertionError("brak wyjątku dla okna 0")

for t in [test_basic, test_window_one, test_window_longer_than_data, test_bad_window]:
    t()
    print(f"{t.__name__}: OK")
```

Z zainstalowanym `pytest` wystarczy zapisać funkcje `test_...` w pliku `test_ring.py` i uruchomić `pytest`. Ćwiczenie dodatkowe w powłoce: policz, ile linii z błędem jest w logu i które kody błędów występują najczęściej — `grep "ERR" log.txt | cut -d' ' -f3 | sort | uniq -c | sort -rn`.

## Zadania

1. Wymień pięć przypadków testowych dla funkcji `parse_frame` z [19.04](04-c-wskazniki-i-pamiec.md).
2. Program na mikrokontrolerze działa z `-O0`, a z `-O2` zawiesza się w pętli czekającej na flagę z przerwania. Najbardziej prawdopodobna przyczyna?
3. Jak w `gdb` sprawdzić, która funkcja wywołała funkcję, w której program się wysypał?
4. Napisz polecenie powłoki, które w katalogu z plikami CSV wypisze liczbę linii każdego pliku.
5. Dlaczego warto oddzielać logikę (parsowanie, filtry) od kodu dostępu do sprzętu?

<details>
<summary>Odpowiedzi</summary>

1. Poprawna ramka; za krótka (`len < 7`); `NULL` jako bufor lub wynik; temperatura ujemna i graniczna (−32768, 32767); znacznik czasu z najstarszym bitem ustawionym (`0xFFFFFFFF`)
2. Flaga bez `volatile` — kompilator wczytał ją raz przed pętlą ([19.05](05-c-bity-i-sprzet.md))
3. `backtrace` (lub `bt`), potem `frame N` i `print`, aby obejrzeć zmienne wywołującego
4. `wc -l *.csv` (lub `for f in *.csv; do echo "$f $(wc -l < "$f")"; done`)
5. Logikę można testować na komputerze szybko i automatycznie, bez płytki; kod sprzętowy jest cienki i łatwy do przejrzenia; łatwiej przenieść projekt na inny mikrokontroler
</details>

## Źródła

- [MIT — The Missing Semester](https://missing.csail.mit.edu/) — powłoka, skrypty, debugowanie i profilowanie
- [pytest — dokumentacja](https://docs.pytest.org/en/stable/)
- [GDB — dokumentacja](https://sourceware.org/gdb/current/onlinedocs/gdb/)
- [Clang — AddressSanitizer](https://clang.llvm.org/docs/AddressSanitizer.html) — działa też w GCC
- [Interrupt (blog Memfault)](https://interrupt.memfault.com/) — testy jednostkowe i debugowanie firmware
