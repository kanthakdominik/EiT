# 18 — Projekt końcowy (odpowiednik projektu inżynierskiego)

> **Status:** ✅ pełny

## Cel modułu

Przeprowadzić samodzielnie pełny projekt elektroniczny — od mierzalnych wymagań przez architekturę, obliczenia, schemat, płytkę i oprogramowanie, po pomiary weryfikacyjne i dokumentację, z której ktoś inny mógłby urządzenie odtworzyć. To zwieńczenie całej ścieżki: tak jak praca inżynierska, sprawdza nie wiedzę z pojedynczych przedmiotów, tylko umiejętność połączenia jej w działający, udokumentowany system.

## Wymagania wstępne

Większość wcześniejszych modułów — zakres zależy od tematu. Minimum dla każdego projektu: [08 Miernictwo](../08-miernictwo/) (weryfikacja z niepewnością), [16 PCB i EMC](../16-pcb-emc-konstrukcja/) (płytka i uruchomienie), oraz moduły merytoryczne tematu.

## Tematy

| # | Temat | Czas |
|---|---|---|
| 01 | [Proces projektu i harmonogram](01-proces-i-harmonogram.md) | 3 h |
| 02 | [Wymagania i architektura](02-wymagania-i-architektura.md) | 4 h |
| 03 | [Weryfikacja i pomiary](03-weryfikacja-i-pomiary.md) | 4 h |
| 04 | [Dokumentacja i prezentacja](04-dokumentacja-i-prezentacja.md) | 3 h |
| 05 | [Przykładowe projekty z wymaganiami](05-przykladowe-projekty.md) | — |
| — | **Realizacja projektu** | ok. 150–300 h (jeden semestr przy ok. 10–20 h tygodniowo) |

## Szablony

Gotowe do skopiowania do własnego repozytorium projektu:

| Szablon | Do czego |
|---|---|
| [Specyfikacja wymagań](szablony/specyfikacja-wymagan.md) | Wymagania mierzalne z priorytetami i metodą weryfikacji |
| [Plan testów i macierz zgodności](szablony/plan-testow.md) | Testy przypisane do wymagań, wyniki z niepewnością |
| [Lista kontrolna przeglądów](szablony/lista-przegladow.md) | Przegląd schematu, płytki, oprogramowania |
| [Dziennik uruchomienia](szablony/dziennik-uruchomienia.md) | Problemy, przyczyny, poprawki — materiał do wersji 2 |
| [Raport techniczny](szablony/raport-techniczny.md) | Struktura dokumentu końcowego |

## Etapy projektu (skrót)

- [ ] **Specyfikacja wymagań** — funkcje, parametry z liczbami i tolerancjami, warunki pracy, ograniczenia (koszt, wymiary, energia), kryteria akceptacji.
- [ ] **Koncepcja i architektura** — schemat blokowy, porównanie wariantów (macierz decyzyjna), budżety: mocy, szumów, błędów, łącza radiowego.
- [ ] **Projekt szczegółowy** — obliczenia i symulacje bloków krytycznych, dobór elementów z uzasadnieniem.
- [ ] **Prototypy ryzykownych bloków** — moduły ewaluacyjne, płytka stykowa, symulacje.
- [ ] **PCB** — schemat, przegląd, płytka, przegląd, produkcja, montaż.
- [ ] **Oprogramowanie / HDL** — architektura, implementacja, testy jednostkowe i na sprzęcie.
- [ ] **Uruchomienie** — procedura krok po kroku, dziennik problemów.
- [ ] **Weryfikacja** — plan testów, pomiary z niepewnościami, macierz zgodności z wymaganiami.
- [ ] **Dokumentacja i prezentacja** — raport, schematy, BOM, kod, instrukcja użytkownika, prezentacja z demonstracją.

## Kryteria oceny (samoocena)

| Kryterium | Pytanie kontrolne | Waga |
|---|---|---|
| Wymagania | Czy wszystkie wymagania są mierzalne i każde zostało zweryfikowane? | 15% |
| Uzasadnienie projektu | Czy każdy kluczowy dobór elementu ma obliczenie lub symulację? Czy rozważono alternatywy? | 20% |
| Realizacja | Czy urządzenie działa zgodnie z wymaganiami? Czy płytka i oprogramowanie są czytelne i poprawne? | 25% |
| Weryfikacja | Czy pomiary mają niepewności? Czy wyniki zgadzają się z obliczeniami, a różnice są wyjaśnione? | 20% |
| Dokumentacja | Czy ktoś inny odtworzy urządzenie z samej dokumentacji? | 15% |
| Wnioski | Czy wiadomo, co zmienić w wersji 2 i dlaczego? | 5% |

Najlepszy test: daj dokumentację innej osobie (lub przeczytaj ją po miesiącu przerwy) i sprawdź, ile pytań trzeba zadać, żeby zrozumieć projekt.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| Moduły [08](../08-miernictwo/), [15](../15-energoelektronika-zasilanie/), [16](../16-pcb-emc-konstrukcja/) tej ścieżki | Pomiary z niepewnością, zasilanie, płytka, EMC, uruchamianie |
| [JCGM 100:2008 (GUM)](https://www.bipm.org/en/doi/10.59161/jcgm100-2008e) | Wyrażanie niepewności pomiaru w raporcie |
| [KiCad — dokumentacja](https://docs.kicad.org/) | Projekt i dokumentacja produkcyjna |
| [Interrupt (blog Memfault)](https://interrupt.memfault.com/) | Praktyka firmware: testy, wersjonowanie, niezawodność |
| [MIT 6.111 — projekty końcowe](https://ocw.mit.edu/courses/6-111-introductory-digital-systems-laboratory-spring-2006/) | Przykłady zakresu i dokumentacji projektów studenckich |
| H. Scott — *Designing Electronics That Work* (płatna) | Proces rozwoju sprzętu od wymagań po produkcję |
