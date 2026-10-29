# 24 — Elektroakustyka

> **Status:** ✅ pełny

## Cel modułu

Projektować i oceniać tor audio od fali dźwiękowej do fali dźwiękowej: mikrofon, przedwzmacniacz, przetwarzanie cyfrowe, wzmacniacz mocy, zwrotnica, głośnik w obudowie i pomieszczenie. Liczyć poziomy w dB SPL, czułości i szumy przetworników, parametry obudów z modelu Thiele'a–Smalla, elementy zwrotnic, moc i straty wzmacniaczy oraz czas pogłosu. Moduł korzysta z teorii obwodów, filtrów, wzmacniaczy i DSP — i jest dobrym poligonem, bo wynik można usłyszeć.

## Wymagania wstępne

- [00.07 Decybele](../00-matematyka/07-decybele.md), [02.04 Drgania i fale](../02-fizyka-i-materialy/04-drgania-i-fale.md).
- [04.05 Stopnie wyjściowe](../04-uklady-analogowe/05-stopnie-wyjsciowe.md), [04.09 Filtry aktywne](../04-uklady-analogowe/09-filtry-aktywne.md).
- [07 Cyfrowe przetwarzanie sygnałów](../07-cps-dsp/) — próbkowanie, filtry, FFT.
- [21.06 Szum w układach elektronicznych](../21-procesy-losowe-szum/06-szum-w-ukladach-elektronicznych.md).

## Tematy

| # | Temat | Czas (od zera / odświeżenie) |
|---|---|---|
| 01 | [Podstawy akustyki](01-podstawy-akustyki.md) | 5 h / 2 h |
| 02 | [Słuch i psychoakustyka](02-sluch-i-psychoakustyka.md) | 4 h / 1 h |
| 03 | [Mikrofony](03-mikrofony.md) | 5 h / 2 h |
| 04 | [Głośniki i obudowy](04-glosniki-i-obudowy.md) | 7 h / 2 h |
| 05 | [Zwrotnice głośnikowe](05-zwrotnice.md) | 5 h / 2 h |
| 06 | [Wzmacniacze audio](06-wzmacniacze-audio.md) | 7 h / 2 h |
| 07 | [Audio cyfrowe](07-audio-cyfrowe.md) | 5 h / 2 h |
| 08 | [Akustyka pomieszczeń i pomiary](08-akustyka-pomieszczen-i-pomiary.md) | 6 h / 2 h |

## Test wejściowy (diagnoza)

Około 40 minut.

1. Jakiemu poziomowi dB SPL odpowiada ciśnienie akustyczne 1 Pa?
2. Jaka jest długość fali dźwięku 1 kHz w powietrzu?
3. Dwa jednakowe, nieskorelowane źródła dają razem jaki poziom, jeśli każde daje 80 dB SPL?
4. Ile razy trzeba zwiększyć moc wzmacniacza, by poziom wzrósł o 10 dB?
5. Jaka jest maksymalna teoretyczna sprawność wzmacniacza klasy B dla sinusoidy?
6. Jaki jest teoretyczny zakres dynamiki zapisu 16-bitowego?
7. Co to jest czas pogłosu?

<details>
<summary>Odpowiedzi</summary>

1. 94 dB SPL
2. $343/1000 = 0\text{,}34$ m
3. 83 dB SPL (moce się dodają: +3 dB)
4. 10 razy
5. $\pi/4 \approx 78\text{,}5\%$
6. Ok. 98 dB (6,02·16 + 1,76)
7. Czas, po którym poziom dźwięku w pomieszczeniu po wyłączeniu źródła spada o 60 dB (RT60)

**Ocena:** 1–4 — temat 01; 5 — 06; 6 — 07; 7 — 08.
</details>

## Projekt modułowy: aktywny zestaw głośnikowy

- [ ] **Obudowa (temat 04):** dobór głośnika niskotonowego na podstawie parametrów Thiele'a–Smalla, obliczenie obudowy zamkniętej (lub bass-reflex), symulacja charakterystyki w Pythonie.
- [ ] **Zwrotnica (temat 05):** cyfrowa (DSP, np. mikrokontroler z kodekiem lub moduł DSP) lub analogowa aktywna Linkwitz–Riley 4. rzędu; dobór częstotliwości podziału do głośników.
- [ ] **Wzmacniacze (temat 06):** dwa kanały klasy D (moduły scalone) z zasilaczem; obliczenie mocy, strat i radiatora.
- [ ] **Pomiar (temat 08):** charakterystyka częstotliwościowa mikrofonem pomiarowym (np. z programem REW), sygnał przemiatany wykładniczo, pomiar w pomieszczeniu z oknowaniem odpowiedzi; korekcja w DSP.
- [ ] **Raport:** charakterystyki symulowane i zmierzone, THD w funkcji mocy, wnioski.

## Sprawdzian końcowy modułu

- [ ] Przeliczam ciśnienie, natężenie i moc akustyczną na dB SPL; sumuję poziomy; liczę spadek z odległością.
- [ ] Rozumiem krzywe równej głośności, ważenie A i maskowanie; wiem, jak wpływają na pomiar i kodowanie.
- [ ] Porównuję mikrofony po czułości, szumie własnym, AOP i charakterystyce kierunkowej; dobieram przedwzmacniacz.
- [ ] Liczę poziom głośnika z czułości i mocy, projektuję obudowę zamkniętą z parametrów Thiele'a–Smalla.
- [ ] Projektuję zwrotnicę pasywną i aktywną (Butterworth, Linkwitz–Riley), rozumiem sumowanie w punkcie podziału.
- [ ] Porównuję klasy wzmacniaczy, liczę moc, napięcia zasilania i straty; projektuję filtr wyjściowy klasy D.
- [ ] Dobieram parametry audio cyfrowego: częstotliwość próbkowania, rozdzielczość, zegary I²S, opóźnienia.
- [ ] Liczę czas pogłosu i mody pomieszczenia; mierzę charakterystykę metodą sygnału przemiatanego.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [MIT 21M.380 Music and Technology: Sound Design (2016)](https://ocw.mit.edu/courses/21m-380-music-and-technology-sound-design-spring-2016/) | Dźwięk, nagrywanie, przetwarzanie — ujęcie praktyczne |
| [Stanford CCRMA — książki online J. O. Smitha](https://ccrma.stanford.edu/~jos/EE201/Related_Online_Books_CCRMA.html) | Akustyka fizyczna i DSP audio — tematy 01, 07, 08 |
| [Elliott Sound Products (spis artykułów)](https://sound-au.com/site-map.htm) | Setki artykułów o wzmacniaczach, zwrotnicach, zasilaczach audio — tematy 04–06 |
| [Linkwitz Lab — Crossovers](https://linkwitzlab.com/crossovers.htm) | Zwrotnice, sumowanie przetworników — temat 05 |
| [TDK InvenSense — AN-1112: Microphone Specifications Explained](https://invensense.tdk.com/?p=6991) | Parametry mikrofonów MEMS — temat 03 |
| [Texas Instruments — A comprehensive study of class D amplifier technology (PDF)](https://e2e.ti.com/cfs-file/__key/communityserver-discussions-components-files/6/A-comprehensive-study-of-class-D-amplifier-technology.pdf) | Wzmacniacze klasy D — temat 06 |
| [sengpielaudio — kalkulatory i tabele dB](https://sengpielaudio.com/Calculations03.htm) | Przeliczanie poziomów — tematy 01, 03 |
| [UCF Physics — Physics of Hearing](https://pressbooks.online.ucf.edu/phy2053bc/chapter/hearing/) | Słuch i fizyka dźwięku — tematy 01–02 |
| D. Self — *Audio Power Amplifier Design* (płatna) | Projektowanie wzmacniaczy mocy |
| V. Dickason — *The Loudspeaker Design Cookbook* (płatna) | Projektowanie zestawów głośnikowych |
| F. A. Everest, K. C. Pohlmann — *Master Handbook of Acoustics* (płatna) | Akustyka pomieszczeń |
