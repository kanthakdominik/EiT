# EiT Roadmap — Elektronika i Telekomunikacja od podstaw do dyplomu

Otwarta, samodzielna ścieżka nauki obejmująca **pełny program kierunku Elektronika i Telekomunikacja** (poziom inżynierski, z rozszerzeniami magisterskimi). Repozytorium jest pomyślane jako darmowa alternatywa dla studiów lub jako materiał do odświeżenia wiedzy po latach.

- **Notatki, przykłady i zadania** są napisane po polsku (treść własna repozytorium).
- **Źródła zewnętrzne** (kursy, książki, wykłady wideo, narzędzia) są **wyłącznie anglojęzyczne i darmowe**. Książki płatne są wymienione z tytułem, bez treści.
- Każdy link był sprawdzany przy dodawaniu. Jeśli któryś przestanie działać, zgłoś to w Issues.

---

## Jak korzystać z repozytorium

1. Przeczytaj [ROADMAP.md](ROADMAP.md) — kolejność modułów, zależności między nimi i szacowany czas.
2. Zainstaluj narzędzia z [TOOLS.md](TOOLS.md) (wszystkie darmowe).
3. Przejrzyj [RESOURCES.md](RESOURCES.md) — główne darmowe podręczniki i kursy, do których odwołują się moduły.
4. Przerabiaj moduły po kolei. Każdy temat ma ten sam układ:

| Sekcja | Co zawiera |
|---|---|
| **Po co to jest** | Gdzie temat wraca w dalszych przedmiotach i w praktyce |
| **Teoria w pigułce** | Najważniejsze pojęcia, bez lania wody |
| **Wzory i założenia** | Wzory razem z warunkami, w których obowiązują |
| **Przykład rozwiązany** | Pełne rozwiązanie krok po kroku |
| **Typowe pułapki** | Błędy, które najczęściej kosztują punkty na kolokwium |
| **Symulacja** | Ćwiczenie w LTspice / Pythonie / symulatorze logiki |
| **Zadania** | Zadania z odpowiedziami ukrytymi pod `<details>` |
| **Źródła** | Konkretne rozdziały i wykłady do pogłębienia |

5. Postęp odznaczaj w checklistach (`- [ ]` → `- [x]`) we własnym forku.

---

## Mapa modułów

| # | Moduł | Odpowiednik na studiach | Status |
|---|---|---|---|
| 00 | [Matematyka dla elektronika](modules/00-matematyka/) | Analiza, algebra, równania różniczkowe | ✅ pełny |
| 01 | [Teoria obwodów](modules/01-teoria-obwodow/) | Podstawy elektrotechniki, Teoria obwodów I–II | ✅ pełny |
| 02 | [Fizyka i materiałoznawstwo](modules/02-fizyka-i-materialy/) | Fizyka, Materiały elektroniczne | ✅ pełny |
| 03 | [Przyrządy półprzewodnikowe](modules/03-przyrzady-polprzewodnikowe/) | Elementy elektroniczne | ✅ pełny |
| 04 | [Układy analogowe](modules/04-uklady-analogowe/) | Układy elektroniczne, Elektronika analogowa | ✅ pełny |
| 05 | [Technika cyfrowa](modules/05-technika-cyfrowa/) | Technika cyfrowa, Układy cyfrowe | ✅ pełny |
| 06 | [Sygnały i systemy](modules/06-sygnaly-i-systemy/) | Teoria sygnałów, Teoria systemów | ✅ pełny |
| 07 | [Cyfrowe przetwarzanie sygnałów](modules/07-cps-dsp/) | CPS / DSP | ✅ pełny |
| 08 | [Miernictwo](modules/08-miernictwo/) | Metrologia, Miernictwo elektroniczne | 🟡 szkielet |
| 09 | [Mikrokontrolery i systemy wbudowane](modules/09-mikrokontrolery-embedded/) | Technika mikroprocesorowa | 🟡 szkielet |
| 10 | [Podstawy automatyki](modules/10-automatyka/) | Podstawy automatyki i sterowania | 🟡 szkielet |
| 11 | [Pole EM, linie, anteny](modules/11-pole-em-linie-anteny/) | Pole elektromagnetyczne, Anteny i propagacja | 🟡 szkielet |
| 12 | [Technika w.cz. (RF)](modules/12-technika-wcz-rf/) | Technika mikrofalowa, Układy w.cz. | 🟡 szkielet |
| 13 | [Telekomunikacja](modules/13-telekomunikacja/) | Podstawy telekomunikacji, Teoria informacji | 🟡 szkielet |
| 14 | [Sieci telekomunikacyjne](modules/14-sieci-telekomunikacyjne/) | Sieci i systemy telekomunikacyjne | 🟡 szkielet |
| 15 | [Energoelektronika i zasilanie](modules/15-energoelektronika-zasilanie/) | Układy zasilające, Energoelektronika | 🟡 szkielet |
| 16 | [PCB, EMC i konstrukcja](modules/16-pcb-emc-konstrukcja/) | Konstrukcja urządzeń, Kompatybilność EM | 🟡 szkielet |
| 17 | [FPGA i HDL](modules/17-fpga-hdl/) | Układy programowalne | 🟡 szkielet |
| 18 | [Projekt końcowy](modules/18-projekt-dyplomowy/) | Projekt inżynierski | 🟡 szkielet |

✅ pełny — notatki, przykłady, zadania z odpowiedziami, symulacje, źródła
🟡 szkielet — zakres tematów, cele i główne źródła; treść w kolejnych etapach

---

## Zasady pracy, które naprawdę działają

- **Najpierw policz, potem symuluj.** Symulator weryfikuje rozumowanie, a nie je zastępuje.
- **Rozwiązuj zadania bez notatek.** Obejrzenie wykładu to nie to samo, co umiejętność.
- **Prowadź dziennik błędów.** Zapisuj, czy błąd wynikał z matematyki, fizyki, złego modelu czy pomiaru.
- **Wracaj do starych tematów.** Co tydzień rozwiąż co najmniej jedno zadanie z wcześniejszych modułów.
- **Moduł jest zaliczony**, gdy rozwiązujesz nowe zadania, potrafisz wyjaśnić użyte zależności i sprawdzić wynik inną metodą.

---

## Licencja

Treść własna repozytorium (notatki, przykłady, zadania): **CC BY-SA 4.0**.
Materiały zewnętrzne pozostają własnością ich autorów i są tu tylko linkowane.
