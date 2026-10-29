# 13 — Telekomunikacja i teoria informacji

> **Status:** ✅ pełny

## Cel modułu

Opisać tor telekomunikacyjny od źródła informacji do odbiorcy: ile informacji niesie źródło i ile zmieści kanał, jak sygnał moduluje się, przesyła przez kanał z szumem i zanikami, jak się go wykrywa i chroni przed błędami. Rozumieć, na czym opierają się współczesne systemy: radiofonia, Wi-Fi, LTE/5G, łącza satelitarne i IoT.

## Wymagania wstępne

- [06 Sygnały i systemy](../06-sygnaly-i-systemy/) — Fourier, modulacja jako przesunięcie widma, sygnały losowe ([06.08](../06-sygnaly-i-systemy/08-sygnaly-losowe.md)).
- [07 CPS/DSP](../07-cps-dsp/) — DFT/FFT, filtry, zmiana częstotliwości próbkowania.
- [00.06 Prawdopodobieństwo i statystyka](../00-matematyka/06-prawdopodobienstwo-i-statystyka.md).
- Pomocniczo: [11.08 Budżet łącza](../11-pole-em-linie-anteny/08-propagacja-i-budzet-lacza.md), [12.08 Architektury odbiorników](../12-technika-wcz-rf/08-filtry-i-architektury.md).

## Tematy

| # | Temat | Czas (od zera / odświeżenie) |
|---|---|---|
| 01 | [Teoria informacji: entropia, kodowanie źródłowe, pojemność](01-teoria-informacji.md) | 8 h / 2 h |
| 02 | [Modulacje analogowe: AM i FM](02-modulacje-analogowe.md) | 8 h / 2 h |
| 03 | [Transmisja w paśmie podstawowym: ISI, kryterium Nyquista, oko](03-pasmo-podstawowe-i-isi.md) | 6 h / 2 h |
| 04 | [Modulacje cyfrowe: PSK, QAM, FSK](04-modulacje-cyfrowe.md) | 8 h / 3 h |
| 05 | [Detekcja w szumie, BER i synchronizacja](05-detekcja-i-ber.md) | 8 h / 3 h |
| 06 | [Kodowanie kanałowe](06-kodowanie-kanalowe.md) | 10 h / 3 h |
| 07 | [OFDM, rozpraszanie widma i wielodostęp](07-ofdm-i-wielodostep.md) | 8 h / 3 h |
| 08 | [Kanał radiowy i przegląd systemów](08-kanal-radiowy-i-systemy.md) | 6 h / 2 h |

## Test wejściowy (diagnoza)

Około 60 minut, bez notatek.

1. Źródło nadaje cztery symbole z prawdopodobieństwami 1/2, 1/4, 1/8, 1/8. Ile wynosi entropia? Zaproponuj kod.
2. Kanał o paśmie 1 MHz i SNR 20 dB — jaka jest jego pojemność?
3. Jakie pasmo zajmuje sygnał radiofonii FM (dewiacja 75 kHz, sygnał modulujący do 15 kHz)?
4. Jakie pasmo zajmuje sygnał 1 Msym/s z filtrem podniesionego kosinusa o $\alpha = 0\text{,}35$ (po przemianie na nośną)?
5. Ile bitów niesie symbol 64-QAM? Jaka jest efektywność widmowa dla $\alpha = 0$?
6. Jakie $E_b/N_0$ potrzebuje BPSK dla BER = $10^{-5}$ w kanale AWGN?
7. Kod Hamminga (7,4) — ile błędów poprawia, jaka jest sprawność?
8. Do czego w OFDM służy prefiks cykliczny?

<details>
<summary>Odpowiedzi</summary>

1. $H = 1\text{,}75$ bit/symbol; kod Huffmana 0, 10, 110, 111 — średnio 1,75 bitu
2. $C = 10^6\log_2(101) \approx 6\text{,}66$ Mbit/s
3. Reguła Carsona: $2(75 + 15) = 180$ kHz
4. $R_s(1 + \alpha) = 1\text{,}35$ MHz
5. 6 bitów; 6 bit/s/Hz (przy $\alpha = 0$)
6. ≈ 9,6 dB
7. Jeden błąd na słowo; 4/7 ≈ 0,57
8. Pochłania rozmycie impulsu w kanale wielodrogowym (ISI między symbolami OFDM) i zamienia splot liniowy z kanałem na cykliczny — wtedy korekcja to jedno mnożenie zespolone na podnośną

**Ocena:** 1–2 — temat 01; 3 — 02; 4 — 03; 5 — 04; 6 — 05; 7 — 06; 8 — 07.
</details>

## Projekt modułowy: łącze cyfrowe w Pythonie

- [ ] **Nadajnik:** źródło bitów → (opcjonalnie) koder kanałowy → odwzorowanie na symbole QPSK i 16-QAM → nadpróbkowanie i filtr pierwiastkowy podniesionego kosinusa.
- [ ] **Kanał:** AWGN o zadanym $E_b/N_0$; rozszerzenie — przesunięcie częstotliwości i fazy, kanał wielodrogowy, zaniki Rayleigha.
- [ ] **Odbiornik:** filtr dopasowany, próbkowanie, (rozszerzenie: synchronizacja zegara i nośnej), decyzja, dekoder.
- [ ] **Wyniki:** krzywe BER($E_b/N_0$) porównane z teorią, wykresy oka i konstelacji; zysk kodowania kodu Hamminga i kodu splotowego z dekoderem Viterbiego.
- [ ] **Rozszerzenie OFDM:** 64 podnośne, prefiks cykliczny, kanał wielodrogowy, korekcja jednym współczynnikiem na podnośną.
- [ ] **Z prawdziwym radiem (opcjonalnie):** nagraj sygnał odbiornikiem SDR i zdemoduluj go swoim kodem ([PySDR](https://pysdr.org)).

## Sprawdzian końcowy modułu

- [ ] Liczę entropię, buduję kod Huffmana, liczę pojemność kanału i rozumiem granicę Shannona.
- [ ] Liczę moc i pasmo sygnałów AM, DSB, SSB i FM; wiem, jak się je demoduluje.
- [ ] Wyjaśniam ISI, kryterium Nyquista, filtr podniesionego kosinusa i odczytuję wykres oka.
- [ ] Rysuję konstelacje, liczę przepływność i efektywność widmową modulacji cyfrowych.
- [ ] Liczę BER w funkcji $E_b/N_0$, przeliczam $E_b/N_0$ ↔ SNR, rozumiem filtr dopasowany i synchronizację.
- [ ] Koduję i dekoduję kod Hamminga, liczę CRC, rozumiem kody splotowe, Viterbiego i ideę LDPC/turbo.
- [ ] Wyjaśniam OFDM, rozpraszanie widma i metody wielodostępu.
- [ ] Opisuję kanał z zanikami i metody dywersyfikacji; umiem umieścić znane systemy w tej mapie pojęć.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [MIT 6.02 Introduction to EECS II: Digital Communication Systems (2012)](https://ocw.mit.edu/courses/6-02-introduction-to-eecs-ii-digital-communication-systems-fall-2012/) | Główny kurs: kodowanie źródłowe, kody korekcyjne, Viterbi, modulacja, sieci — z notatkami i zadaniami |
| [MIT 6.450 Principles of Digital Communications I (2006)](https://ocw.mit.edu/courses/6-450-principles-of-digital-communications-i-fall-2006/) | Poziom magisterski: kodowanie źródłowe, kanały, detekcja, z wykładami wideo |
| [PySDR — M. Lichtman](https://pysdr.org) | Modulacje cyfrowe, filtry kształtujące, synchronizacja, OFDM — praktycznie, w Pythonie |
| [Fundamentals of Electrical Engineering I — D. Johnson](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-electrical-engineering-1) | Komunikacja analogowa i cyfrowa, teoria informacji, kody korekcyjne — przystępnie |
| [MIT RES.6-007 Signals and Systems (Oppenheim)](https://ocw.mit.edu/courses/res-6-007-signals-and-systems-spring-2011/) | Wykłady o modulacji amplitudy i częstotliwości |
| [Modular Electronics Learning (ModEL) Project](https://ibiblio.org/kuphaldt/socratic/model/) | Moduły o AM i FM od strony układowej |
| J. Proakis, M. Salehi — *Communication Systems Engineering* (płatna) | Klasyczny podręcznik akademicki |
