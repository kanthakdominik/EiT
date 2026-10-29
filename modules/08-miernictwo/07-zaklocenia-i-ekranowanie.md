# 08.07 — Zakłócenia, masa i ekranowanie w pomiarach

## Po co to jest

Gdy mierzy się sygnały rzędu mikrowoltów albo prądy rzędu pikoamperów, zakłócenia sieciowe, pętle masy i siły termoelektryczne są większe niż sygnał. Ten temat to praktyczna strona pomiarów — i wstęp do kompatybilności elektromagnetycznej z modułu [16](../16-pcb-emc-konstrukcja/).

## Teoria w pigułce

### Mechanizmy sprzężenia

| Sprzężenie | Przyczyna | Jak ograniczyć |
|---|---|---|
| **Przez wspólną impedancję (masę)** | Prąd innego obwodu płynie przez wspólny przewód masy | Osobne powroty prądu, masa w gwiazdę, pomiar różnicowy |
| **Pojemnościowe (pole E)** | Napięcie zakłócające przez pojemność pasożytniczą | Ekran połączony z masą, mniejsze impedancje węzłów |
| **Indukcyjne (pole B)** | Zmienny strumień przez pętlę obwodu | Mała powierzchnia pętli, skręcanie przewodów, odległość |
| Promieniowane | Fale EM (RF) | Ekranowanie, filtracja wejść |

### Pętla masy

Dwa przyrządy połączone z uziemieniem sieci i ze sobą przez ekran kabla tworzą pętlę. Indukowany w niej prąd (50 Hz i harmoniczne) płynie przez ekran lub przewód masy i odkłada spadek napięcia, który dodaje się do sygnału.

Rozwiązania: pomiar różnicowy (wzmacniacz pomiarowy, oscyloskop z sondą różnicową), separacja galwaniczna (izolowany przetwornik, zasilanie bateryjne), przerwanie pętli w jednym punkcie (z zachowaniem bezpieczeństwa — **nigdy przez odłączenie przewodu ochronnego!**).

### Sygnały wspólne i różnicowe

Zakłócenie wspólne (common mode) pojawia się tak samo na obu przewodach sygnałowych. Wzmacniacz różnicowy tłumi je współczynnikiem CMRR — ale tylko jeśli impedancje obu przewodów są równe. Niesymetria zamienia zakłócenie wspólne w różnicowe.

### Ekranowanie

- Ekran przed polem elektrycznym łączy się z masą **w jednym punkcie** (przy niskich częstotliwościach), zwykle po stronie odbiornika.
- Przy wysokich częstotliwościach ekran łączy się na obu końcach (krótko, obwodowo).
- Pole magnetyczne niskiej częstotliwości ekranuje się materiałami o dużej przenikalności (mu-metal) albo — skuteczniej — zmniejszeniem pętli.

### Inne źródła błędów przy małych sygnałach

- **Siły termoelektryczne** na złączach różnych metali (µV/K) — symetryczne złącza, stała temperatura, pomiar z odwracaniem.
- **Upływy** na powierzchni płytki przy pomiarach pA — pierścienie ochronne (guard) na potencjale sygnału.
- **Efekt tryboelektryczny** w ruchomych kablach.
- **Szum 1/f** — modulacja (chopper) albo pomiar AC (lock-in).

## Przykład rozwiązany

**Wspólna impedancja masy.** Wzmacniacz mocy pobiera 1 A, a jego prąd wraca tym samym przewodem masy (0,1 Ω), co masa czujnika. Spadek 100 mV dodaje się do sygnału czujnika — dla tensometru dającego 2,5 mV to zakłócenie 40 razy większe od sygnału. Rozwiązanie: osobny przewód powrotny dla prądu mocy, połączenie mas w jednym punkcie przy zasilaczu, pomiar różnicowy czujnika.

**Pętla indukcyjna.** Pętla o powierzchni 100 cm² w polu 50 Hz o indukcji 1 µT: $e = \omega BA = 2\pi\cdot 50\cdot 10^{-6}\cdot 10^{-2} \approx 3\text{,}1\ \mu$V. Skrętka zmniejsza efektywną powierzchnię pętli o rzędy wielkości.

## Typowe pułapki

- **Masa „to masa”** — każdy przewód ma rezystancję i indukcyjność, a prąd szuka drogi o najmniejszej impedancji.
- **Ekran połączony na obu końcach przy pomiarze niskoczęstotliwościowym** — pętla masy przez ekran.
- **Odłączanie przewodu ochronnego** przyrządu, aby usunąć pętlę masy — zagrożenie życia.
- **Wzmacniacz różnicowy z niesymetrycznymi impedancjami wejść** — CMRR katalogowy nie jest osiągany.

## Ćwiczenie praktyczne

- [ ] Zmierz oscyloskopem napięcie na rozwartej sondzie trzymanej w ręce, potem z grotem zwartym do przewodu masy — zobacz zakłócenie 50 Hz sprzężone pojemnościowo.
- [ ] Zbuduj tor z małym sygnałem (dzielnik dający 1 mV) i odbiornikiem zasilanym z sieci. Porównaj zakłócenia przy połączeniu pojedynczym przewodem masy, skrętką i z pomiarem różnicowym.
- [ ] W LTspice zamodeluj wspólną impedancję masy (0,1 Ω) z prądem obciążenia 1 A i zobacz jej wpływ na sygnał czujnika.

## Zadania

1. Prąd 1 A płynie przez wspólny przewód masy 0,1 Ω. Jaki błąd dodaje się do sygnału czujnika?
2. Pętla 100 cm² w polu 50 Hz o indukcji 1 µT. Jakie napięcie się indukuje?
3. Wzmacniacz różnicowy ma CMRR 80 dB. Jakie zakłócenie pojawi się na wyjściu (odniesione do wejścia) przy napięciu wspólnym 1 V?
4. Złącze miedź–cyna ma współczynnik ok. 3 µV/K. Różnica temperatur między dwoma złączami wynosi 2 K. Jaki błąd?
5. Dlaczego przy pomiarach niskoczęstotliwościowych ekran kabla łączy się z masą tylko po jednej stronie?

<details>
<summary>Odpowiedzi</summary>

1. 100 mV
2. ≈ 3,1 µV
3. $1\ \text{V}\cdot 10^{-4} = 100\ \mu$V
4. 6 µV
5. Połączenie po obu stronach tworzy pętlę masy przez ekran — prąd wyrównawczy płynący ekranem indukuje zakłócenia w żyłach. Jednostronne połączenie wystarcza do ekranowania pola elektrycznego przy niskich częstotliwościach
</details>

## Źródła

- [Modular Electronics Learning (ModEL) Project](https://ibiblio.org/kuphaldt/socratic/model/) — moduły o zakłóceniach, ekranowaniu i uziemieniach
- [All About Circuits Textbook](https://www.allaboutcircuits.com/textbook/) — rozdziały o sygnałach przyrządowych i zakłóceniach
- [MIT 8.02 Physics II: Electricity and Magnetism](https://ocw.mit.edu/courses/8-02-physics-ii-electricity-and-magnetism-spring-2007/) — fizyka sprzężeń pojemnościowych i indukcyjnych
