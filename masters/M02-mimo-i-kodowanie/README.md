# M02 — Systemy wieloantenowe (MIMO), kształtowanie wiązki i nowoczesne kodowanie

> **Status:** ✅ pełny · ścieżka magisterska (II stopień)

## Cel modułu

Zrozumieć i policzyć dwa filary współczesnej łączności bezprzewodowej (Wi-Fi 6/7, LTE, 5G NR, przyszłe 6G): **wiele anten** — pojemność kanału MIMO, zróżnicowanie, multipleksacja przestrzenna, detekcja, kształtowanie wiązki i Massive MIMO — oraz **kody zbliżające się do granicy Shannona** — LDPC i kody polarne (oba w standardzie 5G NR), z dekodowaniem iteracyjnym i sekwencyjnym oraz granicami dla krótkich bloków. Moduł rozwija [13 Telekomunikację](../../modules/13-telekomunikacja/) i [11.07 Anteny](../../modules/11-pole-em-linie-anteny/07-anteny.md) do poziomu magisterskiego.

## Wymagania wstępne

- [13 Telekomunikacja](../../modules/13-telekomunikacja/) — modulacje, BER, kanał radiowy z zanikami, OFDM, kodowanie kanałowe ([13.06](../../modules/13-telekomunikacja/06-kodowanie-kanalowe.md)), teoria informacji ([13.01](../../modules/13-telekomunikacja/01-teoria-informacji.md)).
- [M01 Detekcja i estymacja](../M01-estymacja-detekcja-filtracja/) — ML, MMSE, LMMSE.
- [00.04 Algebra liniowa](../../modules/00-matematyka/04-algebra-liniowa.md) — SVD, wartości własne, macierze zespolone.

## Tematy

| # | Temat | Czas |
|---|---|---|
| 01 | [Kanał MIMO i jego pojemność](01-kanal-mimo-i-pojemnosc.md) | 10 h |
| 02 | [Zróżnicowanie: MRC i kody czasoprzestrzenne](02-zroznicowanie-i-alamouti.md) | 8 h |
| 03 | [Multipleksacja przestrzenna i detekcja MIMO](03-multipleksacja-i-detekcja.md) | 8 h |
| 04 | [Szyki antenowe, kształtowanie wiązki i estymacja kierunku](04-szyki-i-ksztaltowanie-wiazki.md) | 10 h |
| 05 | [Massive MIMO i prekodowanie wielu użytkowników](05-massive-mimo.md) | 8 h |
| 06 | [Kody LDPC i dekodowanie iteracyjne](06-kody-ldpc.md) | 10 h |
| 07 | [Kody polarne](07-kody-polarne.md) | 10 h |
| 08 | [Granice kodowania, krótkie bloki i HARQ](08-granice-i-krotkie-bloki.md) | 6 h |

## Test wejściowy (diagnoza)

Około 60 minut.

1. Ile wynosi pojemność kanału AWGN przy SNR 20 dB?
2. Dlaczego w kanale z zanikami Rayleigha BER maleje tylko jak $1/\mathrm{SNR}$?
3. Podaj rozkład SVD macierzy i znaczenie wartości osobliwych.
4. Co to jest macierz kontrolna (parzystości) kodu liniowego i syndrom?
5. Zapisz LLR bitu BPSK odebranego w szumie AWGN o wariancji $\sigma^2$.
6. Jaka jest najmniejsza teoretyczna wartość $E_b/N_0$ dla niezawodnej transmisji?

<details>
<summary>Odpowiedzi</summary>

1. $\log_2(1 + 100) \approx 6\text{,}66$ b/s/Hz
2. Błędy pochodzą głównie z głębokich zaników; prawdopodobieństwo, że wzmocnienie kanału spadnie poniżej progu, jest proporcjonalne do progu — średni BER ok. $1/(4\,\mathrm{SNR})$ dla BPSK
3. $\mathbf H = \mathbf U\boldsymbol\Sigma\mathbf V^H$; wartości osobliwe to wzmocnienia niezależnych „kanałów własnych”, na które kanał MIMO rozkłada się po prekodowaniu $\mathbf V$ i filtracji $\mathbf U^H$
4. $\mathbf H\mathbf c^T = \mathbf 0$ dla każdego słowa kodowego; syndrom $\mathbf s = \mathbf H\mathbf r^T$ — niezerowy wskazuje błąd
5. $L = 2y/\sigma^2$ (przy odwzorowaniu 0 → +1)
6. −1,59 dB (przy sprawności dążącej do zera)

**Ocena:** 1, 3 — temat 01; 2 — 02; 4–5 — 06; 6 — 08.
</details>

## Projekt modułowy: symulator łącza 2 × 2 z kodowaniem LDPC

- [ ] **Nadajnik:** bity → koder LDPC (macierz z tematu 06 lub z biblioteki Sionna) → QPSK/16-QAM → multipleksacja przestrzenna 2 × 2 lub Alamouti.
- [ ] **Kanał:** Rayleigh płaski (blokowo stały) z estymacją kanału na pilotach (LMMSE z [M01.04](../M01-estymacja-detekcja-filtracja/04-estymacja-bayesowska.md)).
- [ ] **Odbiornik:** detektor MMSE z miękkimi wyjściami (LLR) → dekoder min-sum.
- [ ] **Wyniki:** krzywe BER/FER w funkcji $E_b/N_0$ dla: bez kodowania, Alamouti + LDPC, multipleksacja + LDPC; porównanie przepływności przy tej samej FER; wpływ błędów estymacji kanału.
- [ ] **Raport:** porównanie z pojemnością ergodyczną i z granicą dla krótkich bloków (temat 08).

## Sprawdzian końcowy modułu

- [ ] Liczę pojemność MIMO dla kanału znanego i nieznanego u nadajnika, stosuję rozlewanie mocy.
- [ ] Wyznaczam rząd zróżnicowania, liczę BER dla MRC i schematu Alamoutiego.
- [ ] Porównuję detektory ZF, MMSE, SIC i ML pod względem jakości i złożoności.
- [ ] Projektuję szyk liniowy (szerokość wiązki, listki boczne, sterowanie), estymuję kierunki metodą MUSIC.
- [ ] Rozumiem utwardzanie kanału i prekodowanie MRT/ZF w Massive MIMO.
- [ ] Opisuję kod LDPC grafem Tannera, implementuję dekoder min-sum.
- [ ] Rozumiem polaryzację kanału, konstruuję kod polarny i dekoduję SC; znam ideę SCL z CRC.
- [ ] Liczę granice Shannona dla BPSK i wejścia gaussowskiego oraz granice dla skończonej długości bloku.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [D. Tse, P. Viswanath — Fundamentals of Wireless Communication (strona książki)](https://web.stanford.edu/~dntse/wireless_book.html) | Główny podręcznik części MIMO: zaniki, zróżnicowanie, pojemność, multipleksacja |
| [MIT 6.450 Principles of Digital Communication I (2006)](https://ocw.mit.edu/courses/6-450-principles-of-digital-communications-i-fall-2006/) | Kanał radiowy, detekcja, podstawy teorii informacji |
| [MIT 6.451 Principles of Digital Communication II (2005)](https://ocw.mit.edu/courses/6-451-principles-of-digital-communication-ii-spring-2005/) | Kodowanie: kody liniowe, grafy, LDPC, dekodowanie iteracyjne, granice |
| [E. Björnson, J. Hoydis, L. Sanguinetti — Massive MIMO Networks](https://nowpublishers.com/article/Details/SIG-093) | Massive MIMO: estymacja kanału, prekodowanie, skalowanie |
| [NVIDIA Sionna (GitHub)](https://github.com/NVlabs/sionna) | Otwarta biblioteka symulacji warstwy fizycznej: LDPC i kody polarne 5G, MIMO, OFDM |
| T. Richardson, R. Urbanke — *Modern Coding Theory* (płatna) | LDPC i teoria dekodowania iteracyjnego |
| W. Ryan, S. Lin — *Channel Codes: Classical and Modern* (płatna) | Kody klasyczne i nowoczesne, kody polarne |
| 3GPP TS 38.212 — *NR; Multiplexing and channel coding* (specyfikacja) | Kodowanie w 5G NR: LDPC (dane), polarne (sterowanie) |
