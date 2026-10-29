# 18.01 — Proces projektu i harmonogram

## Po co to jest

Projekty elektroniczne prawie zawsze trwają dłużej, niż się planowało: płytka wraca z błędem, element ma inny pinout, przetwornica zakłóca radio. Uporządkowany proces z punktami kontrolnymi (przeglądami) i harmonogramem z rezerwą nie usuwa niespodzianek, ale sprawia, że wykrywa się je wcześnie, gdy poprawka kosztuje godzinę, a nie nową wersję płytki.

## Teoria w pigułce

### Fazy i punkty kontrolne

| Faza | Wynik | Przegląd (bramka) |
|---|---|---|
| 1. Wymagania | Specyfikacja z kryteriami akceptacji | Czy wymagania są kompletne, mierzalne, realne? |
| 2. Architektura | Schemat blokowy, budżety, wybór kluczowych układów, lista ryzyk | Czy architektura spełni wymagania z zapasem? |
| 3. Prototypy ryzyk | Wyniki testów bloków niepewnych | Czy ryzyka zostały usunięte lub zaakceptowane? |
| 4. Projekt szczegółowy | Schemat, obliczenia, BOM | **Przegląd schematu** |
| 5. Płytka | Projekt PCB, pliki produkcyjne | **Przegląd płytki** (DRC, EMC, DFM) |
| 6. Uruchomienie i oprogramowanie | Działający prototyp | Czy wszystkie bloki działają? |
| 7. Weryfikacja | Wyniki pomiarów, macierz zgodności | Czy wymagania są spełnione? |
| 8. Dokumentacja | Raport, pliki, wnioski | Odbiór |

Typowo potrzebne są **dwie wersje płytki**: pierwsza ujawnia błędy i nieprzewidziane zjawiska, druga jest „właściwa”. Planuj to od początku.

### Zarządzanie ryzykiem

Lista ryzyk: co może nie zadziałać, prawdopodobieństwo, skutek, działanie (prototyp, alternatywa, zapas). Najwcześniej sprawdza się to, co jest **najbardziej niepewne i najdroższe do zmiany** — np. zasięg radia, szum toru analogowego, termika, dostępność kluczowego układu.

### Harmonogram

- Rozbij projekt na zadania ≤ 1–2 tygodnie, z zależnościami (płytka czeka na schemat, oprogramowanie częściowo równolegle na module ewaluacyjnym).
- **Szacowanie trzypunktowe (PERT):** $t = (t_{opt} + 4t_{najb} + t_{pes})/6$; odchylenie $\sigma = (t_{pes} - t_{opt})/6$.
- Uwzględnij czasy zewnętrzne: produkcja płytki i dostawa elementów (dni–tygodnie), montaż.
- Rezerwa 20–30% na nieprzewidziane problemy.
- Ścieżka krytyczna harmonogramu — zadania, których opóźnienie opóźnia całość.

### Narzędzia pracy

- **System kontroli wersji** (git) dla wszystkiego: schematy, płytka, kod, dokumentacja; znaczniki wersji (tag) przy każdym zamówieniu płytki.
- **Lista zadań i problemów** (np. Issues w repozytorium), dziennik projektu.
- Jedno miejsce na dokumenty i karty katalogowe użytych elementów (wersje się zmieniają).
- Wersja sprzętu na płytce (opis na warstwie opisowej lub rezystory kodujące) i w oprogramowaniu.

## Przykład rozwiązany

**Harmonogram rejestratora z radiem** (szacunki trzypunktowe w dniach roboczych po ok. 3 h):

| Zadanie | opt / najb. / pes. | PERT |
|---|---|---|
| Wymagania i architektura | 3 / 5 / 10 | 5,5 |
| Prototyp radia i czujnika na modułach | 4 / 7 / 15 | 7,8 |
| Schemat + przegląd | 5 / 8 / 14 | 8,5 |
| PCB + przegląd | 5 / 8 / 15 | 8,7 |
| Produkcja i montaż (czas zewnętrzny) | 7 / 10 / 20 | 11,2 |
| Oprogramowanie (częściowo równolegle) | 10 / 15 / 30 | 16,7 |
| Uruchomienie | 3 / 6 / 15 | 7,0 |
| Weryfikacja i dokumentacja | 5 / 8 / 15 | 8,7 |

Ścieżka krytyczna (bez oprogramowania, które idzie równolegle po prototypach): ok. 57 dni; z rezerwą 25% — ok. 71 dni, czyli ok. 3,5 miesiąca przy pracy kilka dni w tygodniu. Druga wersja płytki dodaje ok. 20–30 dni.

## Typowe pułapki

- **Płytka zamówiona przed sprawdzeniem ryzyk** na modułach ewaluacyjnych.
- **Harmonogram bez czasu na produkcję i dostawy.**
- **Brak wersjonowania** — „która wersja schematu jest na tej płytce?”.
- **Rozszerzanie zakresu w trakcie** („dodam jeszcze Wi-Fi”) bez zmiany planu.
- **Przegląd „we własnej głowie”** zaraz po narysowaniu — błędy widać dopiero po przerwie lub oczami innej osoby.

## Ćwiczenie komputerowe

Szacowanie harmonogramu metodą PERT i symulacja Monte Carlo prawdopodobieństwa dotrzymania terminu:

```python
import numpy as np

tasks = {  # nazwa: (opt, najb., pes., poprzedniki)
    'wymagania': (3, 5, 10, []), 'prototypy': (4, 7, 15, ['wymagania']),
    'schemat': (5, 8, 14, ['prototypy']), 'pcb': (5, 8, 15, ['schemat']),
    'produkcja': (7, 10, 20, ['pcb']), 'firmware': (10, 15, 30, ['prototypy']),
    'uruchomienie': (3, 6, 15, ['produkcja', 'firmware']), 'weryfikacja': (5, 8, 15, ['uruchomienie'])}

def finish_time(dur):
    end = {}
    for t in tasks:                                         # kolejność słownika zgodna z zależnościami
        start = max([end[p] for p in tasks[t][3]], default=0)
        end[t] = start + dur[t]
    return end['weryfikacja']

pert = {t: (a + 4*m + b)/6 for t, (a, m, b, _) in tasks.items()}
print(f"czas wg PERT (wartości oczekiwane): {finish_time(pert):.1f} dni")
rng = np.random.default_rng(0)
samples = []
for _ in range(20000):                                       # rozkład trójkątny dla każdego zadania
    samples.append(finish_time({t: rng.triangular(a, m, b) for t, (a, m, b, _) in tasks.items()}))
samples = np.array(samples)
for p in [50, 80, 95]:
    print(f"z prawdopodobieństwem {p}% projekt skończy się w {np.percentile(samples, p):.0f} dni")
```

## Zadania

1. Przygotuj listę 5 największych ryzyk dla własnego tematu projektu z działaniami ograniczającymi.
2. Policz czas PERT dla zadania szacowanego na 4 / 6 / 14 dni. Ile wynosi σ?
3. Dlaczego planuje się dwie wersje płytki?
4. Które zadania mogą biec równolegle z projektowaniem płytki?
5. Zaproponuj schemat znakowania wersji sprzętu i oprogramowania, który pozwoli za rok odtworzyć dowolny egzemplarz.

<details>
<summary>Odpowiedzi</summary>

1. —
2. $(4 + 24 + 14)/6 = 7$ dni; $\sigma = 10/6 \approx 1\text{,}7$ dnia
3. Pierwsza płytka prawie zawsze ujawnia błędy (footprinty, połączenia, zjawiska analogowe/EMC, potrzeby oprogramowania); druga wprowadza poprawki — planowanie jednej wersji prowadzi do „łatania” i niewiarygodnych pomiarów
4. Oprogramowanie na module ewaluacyjnym, przygotowanie stanowiska pomiarowego i testów, obudowa, dokumentacja użytkownika, zamówienia elementów
5. Np. wersja sprzętu `HW A`, `HW B` na płytce i w repozytorium (tag git przy każdym zamówieniu), rezystory kodujące wersję odczytywane przez mikrokontroler, wersja oprogramowania z hasha commita i daty w pliku binarnym, numer seryjny egzemplarza z listą wprowadzonych poprawek
</details>

## Źródła

- [Interrupt (blog Memfault)](https://interrupt.memfault.com/) — wersjonowanie firmware, procesy, testy
- [KiCad — dokumentacja](https://docs.kicad.org/) — praca z wersjami projektu, eksport dokumentacji
- H. Scott — *Designing Electronics That Work* (płatna) — planowanie, przeglądy, wersje sprzętu
