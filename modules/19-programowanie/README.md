# 19 — Programowanie dla elektronika

> **Status:** ✅ pełny

## Cel modułu

Pisać poprawne, czytelne programy w **Pythonie** (obliczenia, analiza pomiarów, automatyzacja) i w **C** (oprogramowanie mikrokontrolerów, kod blisko sprzętu), znać podstawowe struktury danych i algorytmy oraz pracować z kodem jak inżynier: wersjonowanie w git, testy, debugowanie. Moduł jest pomyślany do przerobienia **na początku** ścieżki — z Pythona korzystają ćwiczenia komputerowe we wszystkich modułach, a C jest podstawą modułu [09 Mikrokontrolery](../09-mikrokontrolery-embedded/).

## Wymagania wstępne

- Brak. Wystarczy komputer z systemem Linux, macOS lub Windows (zalecane WSL) — instalacja narzędzi w [TOOLS.md](../../TOOLS.md).
- Przydatne: [00.04 Algebra liniowa](../00-matematyka/04-algebra-liniowa.md) przy tablicach `numpy`, system dwójkowy z [05 Techniki cyfrowej](../05-technika-cyfrowa/).

## Tematy

| # | Temat | Czas (od zera / odświeżenie) |
|---|---|---|
| 01 | [Python — podstawy języka](01-python-podstawy.md) | 12 h / 3 h |
| 02 | [Python naukowy: numpy, matplotlib, dane pomiarowe](02-python-naukowy.md) | 12 h / 3 h |
| 03 | [C — podstawy, kompilacja, typy](03-c-podstawy.md) | 12 h / 3 h |
| 04 | [C — wskaźniki, tablice, struktury, pamięć](04-c-wskazniki-i-pamiec.md) | 14 h / 4 h |
| 05 | [C blisko sprzętu: bity, typy całkowite, stałoprzecinkowe](05-c-bity-i-sprzet.md) | 10 h / 3 h |
| 06 | [Struktury danych i algorytmy](06-struktury-danych-i-algorytmy.md) | 12 h / 3 h |
| 07 | [Git i praca z repozytorium](07-git.md) | 6 h / 2 h |
| 08 | [Testowanie, debugowanie i wiersz poleceń](08-testy-debugowanie-powloka.md) | 8 h / 3 h |

## Test wejściowy (diagnoza)

Około 45 minut. Możesz pisać na kartce lub w edytorze, bez uruchamiania.

1. Co wypisze Python: `print(7 // 2, 7 / 2, -7 // 2)`?
2. Napisz w Pythonie funkcję, która zwraca listę wartości z listy `v` większych od progu `p`.
3. Ile wynosi w C `5 / 2` dla typu `int`, a ile `5 / 2.0`?
4. Jaka jest wartość `x` po `uint8_t x = 250; x += 10;`?
5. Co robi wyrażenie `reg |= (1u << 5);`, a co `reg &= ~(1u << 5);`?
6. Czym różni się `int *p` od `int p[10]` przekazanego do funkcji?
7. Ile porównań w najgorszym przypadku potrzebuje wyszukiwanie binarne w posortowanej tablicy 1000 elementów?
8. Do czego służy `git commit`, a do czego `git push`?

<details>
<summary>Odpowiedzi</summary>

1. `3 3.5 -4` (dzielenie całkowite zaokrągla w dół, w stronę $-\infty$)
2. `def above(v, p): return [x for x in v if x > p]`
3. `2` oraz `2.5`
4. `4` — arytmetyka modulo 256 dla typu bez znaku
5. Ustawia bit 5; zeruje bit 5, pozostałe bity bez zmian
6. Parametr tablicowy jest w C i tak przekazywany jako wskaźnik — funkcja nie zna rozmiaru, trzeba go przekazać osobno; `sizeof` daje w niej rozmiar wskaźnika
7. $\lceil \log_2 1001 \rceil = 10$
8. `commit` zapisuje migawkę zmian w lokalnym repozytorium; `push` wysyła zapisane commity do repozytorium zdalnego

**Ocena:** 1–2 — tematy 01–02; 3–4 — 03 i 05; 5 — 05; 6 — 04; 7 — 06; 8 — 07.
</details>

## Projekt modułowy: rejestrator pomiarów od czujnika do wykresu

- [ ] **C (temat 03–06):** program w C symulujący czujnik — generuje próbki (szum + wolny trend), filtruje je średnią ruchomą w buforze kołowym i wypisuje linie CSV `czas,surowe,filtrowane`. Bez alokacji dynamicznej, typy o stałej szerokości.
- [ ] **Testy (temat 08):** testy jednostkowe bufora kołowego i filtra (przypadki brzegowe: pusty, pełny, przepełnienie); kompilacja z `-Wall -Wextra -fsanitize=address,undefined`.
- [ ] **Python (temat 01–02):** skrypt wczytuje CSV, liczy statystyki (średnia, odchylenie, zakres), wykrywa wartości odstające i rysuje wykres z opisanymi osiami; zapis do PNG.
- [ ] **Git (temat 07):** całość w repozytorium z `README.md` (jak zbudować i uruchomić), `.gitignore`, sensowną historią commitów i jedną gałęzią funkcji połączoną przez merge.
- [ ] **Makefile:** `make` buduje program, `make test` uruchamia testy, `make plot` generuje wykres.

## Sprawdzian końcowy modułu

- [ ] Piszę w Pythonie funkcje, pętle, listy i słowniki; czytam i zapisuję pliki tekstowe i CSV.
- [ ] Używam `numpy` bez pętli (wektoryzacja) i rysuję czytelne wykresy w `matplotlib`.
- [ ] Kompiluję program w C z ostrzeżeniami, rozumiem etapy: preprocesor, kompilacja, linkowanie.
- [ ] Posługuję się wskaźnikami, tablicami i strukturami; wiem, kiedy pamięć jest na stosie, statyczna lub dynamiczna.
- [ ] Ustawiam, zeruję i sprawdzam bity rejestrów; znam pułapki promocji typów i przepełnień; liczę w formacie Q15.
- [ ] Dobieram strukturę danych do problemu i oceniam złożoność $O(\cdot)$ algorytmu.
- [ ] Pracuję w git: commit, gałąź, merge, rozwiązywanie konfliktu, praca z repozytorium zdalnym.
- [ ] Piszę testy jednostkowe, debuguję w `gdb` i używam sanitizerów; sprawnie korzystam z powłoki.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [The Python Tutorial (python.org)](https://docs.python.org/3/tutorial/) | Oficjalny kurs języka — tematy 01 |
| [MIT 6.0001 Introduction to Computer Science and Programming in Python (2016)](https://ocw.mit.edu/courses/6-0001-introduction-to-computer-science-and-programming-in-python-fall-2016/) | Programowanie od zera, z wykładami wideo i zadaniami |
| [NumPy — Absolute Beginner's Guide](https://numpy.org/doc/stable/user/absolute_beginners.html) | Tablice i wektoryzacja — temat 02 |
| [Matplotlib — Tutorials](https://matplotlib.org/stable/tutorials/index.html) | Wykresy — temat 02 |
| [Harvard CS50 (YouTube)](https://www.youtube.com/results?search_query=CS50+Harvard+lecture) | C, pamięć, struktury danych — tematy 03–06 |
| [Beej's Guide to C Programming](https://beej.us/guide/bgc/) | Darmowy podręcznik C, bardzo przystępny |
| [Pro Git — S. Chacon, B. Straub](https://git-scm.com/book/en/v2) | Pełny podręcznik git — temat 07 |
| [MIT — The Missing Semester of Your CS Education](https://missing.csail.mit.edu/) | Powłoka, edytory, git, debugowanie — tematy 07–08 |
| B. W. Kernighan, D. M. Ritchie — *The C Programming Language* (płatna) | Klasyka C |
