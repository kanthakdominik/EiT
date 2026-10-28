# 07 — Cyfrowe przetwarzanie sygnałów (CPS / DSP)

> **Status:** 🟡 szkielet — zakres, cele i główne źródła. Pełne notatki i zadania w kolejnym etapie.

## Cel modułu

Przetwarzać sygnały spróbkowane: analiza widmowa, projektowanie filtrów cyfrowych, świadoma praca z przetwornikami A/C i C/A.

## Wymagania wstępne

- [06 Sygnały i systemy](../06-sygnaly-i-systemy/) (zwłaszcza próbkowanie i transformata Z).

## Tematy

### Przetwarzanie A/C i C/A
- [ ] Kwantyzacja, szum kwantyzacji, SNR = 6,02·N + 1,76 dB, ENOB
- [ ] Architektury przetworników: SAR, sigma-delta, flash, pipeline
- [ ] Nadpróbkowanie, decymacja, interpolacja

### Analiza widmowa
- [ ] DFT i jej własności, rozdzielczość częstotliwościowa
- [ ] FFT — algorytm radix-2, złożoność obliczeniowa
- [ ] Okna czasowe, przeciek widma, kompromis rozdzielczość–dynamika
- [ ] Splot szybki z użyciem FFT

### Filtry cyfrowe
- [ ] Filtry FIR: metoda okien, metoda Parksa–McClellana, liniowa faza
- [ ] Filtry IIR: transformacja biliniowa, niezmienność odpowiedzi impulsowej
- [ ] Struktury realizacji, efekty skończonej precyzji, stabilność
- [ ] Filtr uśredniający (moving average) i filtry CIC

### Zastosowania
- [ ] Przetwarzanie audio, detekcja tonów (algorytm Goertzela)
- [ ] Wstęp do filtracji adaptacyjnej (LMS)
- [ ] Implementacja w stałym przecinku na mikrokontrolerze

## Główne źródła

- [The Scientist and Engineer's Guide to DSP — S. W. Smith](http://www.dspguide.com/) — cała książka za darmo
- [MIT RES.6-008 Digital Signal Processing (Oppenheim)](https://ocw.mit.edu/courses/res-6-008-digital-signal-processing-spring-2011/)
- [Fundamentals of Electrical Engineering I — D. Johnson](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-electrical-engineering-1) — rozdziały o przetwarzaniu cyfrowym

## Ćwiczenie modułowe

W Pythonie: sygnał sinusoidalny + harmoniczne + szum. Wyznacz widmo z różnymi oknami, zaprojektuj FIR i IIR o tych samych wymaganiach, porównaj rząd, opóźnienie i charakterystykę fazową. Na koniec zaimplementuj wybrany filtr w C w stałym przecinku.

## Sprawdzian umiejętności

- Dobieram długość FFT i okno do wymaganej rozdzielczości i dynamiki.
- Projektuję filtr FIR o zadanych pasmach i tłumieniu.
- Liczę teoretyczny SNR przetwornika i interpretuję ENOB z datasheetu.
