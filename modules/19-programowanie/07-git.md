# 19.07 — Git i praca z repozytorium

## Po co to jest

„Która wersja programu jest na tej płytce?”, „co zmieniłem, że przestało działać?”, „jak połączyć moje zmiany ze zmianami kolegi?” — na te pytania odpowiada system kontroli wersji. W elektronice wersjonuje się wszystko: kod, schematy i płytki KiCad, skrypty pomiarowe, dokumentację ([18.01](../18-projekt-dyplomowy/01-proces-i-harmonogram.md)). To repozytorium też jest w git.

## Teoria w pigułce

### Model git

- **Commit** — migawka całego projektu + opis + wskaźnik na poprzedni commit. Historia to graf commitów.
- **Trzy miejsca:** katalog roboczy → **poczekalnia** (`git add`) → repozytorium (`git commit`).
- **Gałąź** — ruchoma etykieta na commit; `HEAD` — gdzie jesteś teraz.
- **Repozytorium zdalne** (np. GitHub) — `git push` wysyła commity, `git pull` = `fetch` + scalenie.

### Najważniejsze polecenia

| Polecenie | Działanie |
|---|---|
| `git init`, `git clone URL` | Nowe repozytorium / kopia istniejącego |
| `git status`, `git diff` | Co się zmieniło (przed `add` / po `add`: `git diff --staged`) |
| `git add plik`, `git commit -m "opis"` | Zapis zmian |
| `git log --oneline --graph` | Historia |
| `git switch -c nowa-gałąź`, `git switch main` | Tworzenie i zmiana gałęzi |
| `git merge gałąź` | Scalenie gałęzi do bieżącej |
| `git restore plik` | Porzucenie niezapisanych zmian w pliku |
| `git revert <commit>` | Nowy commit odwracający dawny (bezpieczne w historii współdzielonej) |
| `git tag -a hw-v1.0 -m "..."` | Trwała etykieta wersji (np. przy zamówieniu płytki) |
| `git bisect` | Wyszukiwanie binarne commita, który wprowadził błąd |

### Dobre praktyki

- **Małe, spójne commity** z opisem „co i dlaczego” w trybie rozkazującym: „Dodaj filtr medianowy na wejściu ADC”.
- **`.gitignore`** — nie wersjonuje się plików wynikowych (`*.o`, `build/`, `__pycache__/`, kopie zapasowe KiCad `*-backups/`, `*.lck`), haseł ani dużych danych binarnych (do tego Git LFS).
- **Gałąź na funkcję** → przegląd (pull request) → scalenie do `main`; `main` zawsze się buduje.
- Wersja oprogramowania z git: `git describe --tags --dirty` wkompilowane w program — wiadomo, z jakiego kodu powstał plik binarny.

### Konflikt przy scalaniu

Gdy dwie gałęzie zmieniły te same linie, git wstawia znaczniki:

```text
<<<<<<< HEAD
#define FILTER_LEN 8
=======
#define FILTER_LEN 16
>>>>>>> filtr-dluzszy
```

Rozwiązanie: wybierz lub połącz treść, usuń znaczniki, `git add plik`, `git commit`. Konflikt to normalna sytuacja, nie awaria.

## Przykład rozwiązany

**Szukanie commita, który zepsuł pomiar.** Wersja `v1.2` działała, bieżąca (`HEAD`, 40 commitów później) daje błędne odczyty. Ręczne sprawdzanie 40 wersji jest wolne; `git bisect` robi wyszukiwanie binarne:

```text
git bisect start
git bisect bad HEAD
git bisect good v1.2
# git przełącza na commit w połowie: zbuduj, przetestuj, oznacz
git bisect good      # albo: git bisect bad
# ... po ok. log2(40) ≈ 6 krokach git wskazuje winny commit
git bisect reset
```

Jeśli test da się zautomatyzować (skrypt zwracający 0 = dobrze), `git bisect run ./test.sh` zrobi wszystko sam. Warunek skuteczności: małe commity — winny commit z 5 zmienionymi liniami od razu pokazuje błąd.

## Typowe pułapki

- **Jeden wielki commit „zmiany”** na koniec tygodnia — historia bezużyteczna.
- **Zatwierdzanie plików wynikowych i danych prywatnych** (hasła, klucze) — usunięcie z historii jest trudne; sekrety trzeba uznać za ujawnione.
- **`git push --force`** na wspólną gałąź — nadpisuje pracę innych.
- **Praca na `main` bez gałęzi** w projekcie zespołowym.
- **Pliki binarne projektów** (niektóre formaty CAD) — git ich nie scala; ustal, kto edytuje, albo używaj formatów tekstowych (KiCad zapisuje tekstowo).

## Ćwiczenie praktyczne

- [ ] Załóż repozytorium z projektem z [19.03](03-c-podstawy.md), dodaj `.gitignore` (`*.o`, `pomiar`) i zrób pierwszy commit.
- [ ] Utwórz gałąź `zabezpieczenie`, dodaj w `divider_vout` sprawdzenie `r1 + r2 > 0`, zatwierdź.
- [ ] Wróć na `main`, zmień w tej samej linii coś innego, zatwierdź — i scal gałąź. Rozwiąż konflikt.
- [ ] Załóż prywatne repozytorium na GitHub, wypchnij historię, dodaj znacznik `v0.1`.
- [ ] Uruchom `git log --oneline --graph --all` i odczytaj z grafu, gdzie nastąpiło scalenie.

## Zadania

1. Czym różni się `git restore plik` od `git revert <commit>`?
2. Zmieniłeś trzy pliki, ale chcesz zatwierdzić tylko dwa. Jak?
3. Po co oznaczać tagiem commit, z którego wysłano pliki produkcyjne płytki?
4. Ile kroków `git bisect` potrzeba przy 300 commitach między wersją dobrą a złą?
5. Jakie wpisy dodasz do `.gitignore` projektu Python + C + KiCad?

<details>
<summary>Odpowiedzi</summary>

1. `restore` porzuca niezatwierdzone zmiany w katalogu roboczym (bez śladu w historii); `revert` tworzy nowy commit cofający zmiany wskazanego commita (historia zostaje, bezpieczne po `push`)
2. `git add plik1 plik2`, potem `git commit` — trzeci plik zostaje niezatwierdzony
3. Żeby po latach odtworzyć dokładnie ten schemat i płytkę (np. przy naprawie egzemplarza), niezależnie od późniejszych zmian
4. $\lceil\log_2 300\rceil = 9$
5. Np. `__pycache__/`, `.venv/`, `*.o`, `build/`, `*.elf`, `*.bin` (jeśli generowane), `*-backups/`, `*.lck`, `fp-info-cache`, pliki wyjściowe Gerber w katalogu roboczym (archiwizuje się je w wydaniach), `.DS_Store`
</details>

## Źródła

- [Pro Git — S. Chacon, B. Straub](https://git-scm.com/book/en/v2) — rozdziały 1–3, 7.10 (bisect)
- [MIT — The Missing Semester: Version Control (Git)](https://missing.csail.mit.edu/) — model danych git
- [GitHub Docs — Get started](https://docs.github.com/en/get-started) — repozytoria zdalne, pull requesty
- [KiCad — dokumentacja](https://docs.kicad.org/) — struktura plików projektu
