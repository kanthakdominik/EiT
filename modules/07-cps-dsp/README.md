# 07 — Cyfrowe przetwarzanie sygnałów (CPS / DSP)

> **Status:** ✅ pełny

## Cel modułu

Przetwarzać sygnały spróbkowane: świadomie dobierać przetwornik A/C, mierzyć widmo, projektować filtry cyfrowe FIR i IIR, zmieniać częstotliwość próbkowania i implementować algorytmy na mikrokontrolerze w arytmetyce stałoprzecinkowej.

## Wymagania wstępne

- [06 Sygnały i systemy](../06-sygnaly-i-systemy/) — zwłaszcza [próbkowanie](../06-sygnaly-i-systemy/06-probkowanie.md) i [transformata Z](../06-sygnaly-i-systemy/07-czas-dyskretny-i-transformata-z.md).
- Python z NumPy, SciPy i Matplotlib; dla tematu 06 i 08 — podstawy C.

## Tematy

| # | Temat | Czas (od zera / odświeżenie) |
|---|---|---|
| 01 | [Przetwarzanie A/C i C/A](01-przetwarzanie-ac.md) | 8 h / 2 h |
| 02 | [DFT i FFT](02-dft-i-fft.md) | 8 h / 2 h |
| 03 | [Okna czasowe i analiza widmowa](03-okna-i-analiza-widmowa.md) | 6 h / 2 h |
| 04 | [Filtry FIR](04-filtry-fir.md) | 8 h / 3 h |
| 05 | [Filtry IIR](05-filtry-iir.md) | 8 h / 3 h |
| 06 | [Realizacja filtrów i arytmetyka stałoprzecinkowa](06-realizacja-filtrow.md) | 8 h / 3 h |
| 07 | [Zmiana częstotliwości próbkowania](07-zmiana-czestotliwosci-probkowania.md) | 6 h / 2 h |
| 08 | [Zastosowania: Goertzel, filtry adaptacyjne, praktyka](08-zastosowania.md) | 8 h / 3 h |

## Test wejściowy (diagnoza)

Około 60 minut, bez notatek.

1. Jaki jest teoretyczny SNR idealnego przetwornika 12-bitowego? Ile wynosi ENOB przy zmierzonym SINAD 70 dB?
2. $f_s = 1$ kHz, $N = 256$. Jaka jest rozdzielczość częstotliwościowa FFT? W którym prążku wypadnie 50 Hz?
3. Dlaczego przed FFT stosuje się okno czasowe? Co się traci?
4. Filtr FIR o liniowej fazie ma 65 współczynników, $f_s = 8$ kHz. Jakie wprowadza opóźnienie?
5. Projektujesz filtr IIR metodą biliniową, $f_s = 8$ kHz, $f_c = 1$ kHz. Jaką częstotliwość graniczną musi mieć prototyp analogowy?
6. Zapisz współczynnik 0,3 w formacie Q15.
7. Sygnał próbkowany z 48 kHz ma zostać zredukowany do 8 kHz. Co trzeba zrobić przed odrzuceniem próbek?

<details>
<summary>Odpowiedzi</summary>

1. $6\text{,}02\cdot 12 + 1\text{,}76 = 74$ dB; $\text{ENOB} = (70 - 1\text{,}76)/6\text{,}02 \approx 11\text{,}3$ bitu
2. ≈ 3,91 Hz; $50/3\text{,}91 = 12\text{,}8$ — między prążkami 12 i 13 (przeciek widma)
3. Aby ograniczyć przeciek widma wynikający z ucięcia sygnału; kosztem szerszego listka głównego (gorszej rozdzielczości) i strat amplitudy
4. 32 próbki = 4 ms
5. $f_a = \dfrac{f_s}{\pi}\tan\dfrac{\pi f_c}{f_s} \approx 1055$ Hz (predistorsja)
6. $\text{round}(0\text{,}3\cdot 32768) = 9830$ (`0x2666`)
7. Filtr dolnoprzepustowy (antyaliasingowy) z granicą poniżej 4 kHz, dopiero potem decymacja ×6

**Ocena:** zadanie 1 — temat 01; 2–3 — tematy 02–03; 4 — temat 04; 5 — temat 05; 6 — temat 06; 7 — temat 07.
</details>

## Projekt modułowy: analizator i filtr sygnału zaszumionego

- [ ] Wygeneruj w Pythonie sygnał: sinus 50 Hz + 3. harmoniczna + składowa 1 kHz + szum biały, $f_s = 8$ kHz, kwantyzacja 12-bitowa.
- [ ] Wyznacz widmo (FFT z oknem Hann i metodą Welcha). Zmierz SNR i THD, porównaj z teorią kwantyzacji.
- [ ] Zaprojektuj filtr dolnoprzepustowy usuwający składową 1 kHz w dwóch wersjach: FIR (okno lub Parks–McClellan) i IIR (Butterworth/eliptyczny, biliniowa). Porównaj rząd, opóźnienie, fazę i liczbę mnożeń na próbkę.
- [ ] Zaimplementuj wybrany filtr w C w arytmetyce Q15 (struktura biquad dla IIR). Porównaj wynik z referencją zmiennoprzecinkową i zmierz błąd.
- [ ] Rozszerzenie: uruchom filtr na mikrokontrolerze z danymi z przetwornika A/C (moduł [09](../09-mikrokontrolery-embedded/)).

## Sprawdzian końcowy modułu

- [ ] Dobieram rozdzielczość i częstotliwość próbkowania przetwornika, interpretuję ENOB i SINAD z dokumentacji.
- [ ] Dobieram długość FFT i okno do wymaganej rozdzielczości i dynamiki pomiaru.
- [ ] Projektuję filtr FIR i IIR o zadanych pasmach i tłumieniu i porównuję koszt obliczeniowy.
- [ ] Implementuję filtr w stałym przecinku i kontroluję przepełnienia.
- [ ] Projektuję decymację i interpolację, w tym w kilku etapach.
- [ ] Stosuję algorytm Goertzela i rozumiem działanie filtru adaptacyjnego LMS.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [The Scientist and Engineer's Guide to DSP — S. W. Smith](http://www.dspguide.com/) | Cały moduł, praktycznie i z małą ilością matematyki |
| [Think DSP — A. Downey](https://greenteapress.com/wp/think-dsp/) | Darmowa książka z kodem w Pythonie |
| [MIT RES.6-008 Digital Signal Processing (Oppenheim)](https://ocw.mit.edu/courses/res-6-008-digital-signal-processing-spring-2011/) | Klasyczne wykłady akademickie: DFT, FFT, projektowanie filtrów |
| [MIT 6.003 Signals and Systems](https://ocw.mit.edu/courses/6-003-signals-and-systems-fall-2011/) | Podstawy czasu dyskretnego |
| [Analog Devices — Electronics I and II](https://wiki.analog.com/university/courses/electronics/text/electronics-toc) | Rozdziały o przetwornikach A/C i C/A |
| [SciPy — `scipy.signal`](https://docs.scipy.org/doc/scipy/reference/signal.html) | Narzędzia do projektowania i analizy filtrów |
