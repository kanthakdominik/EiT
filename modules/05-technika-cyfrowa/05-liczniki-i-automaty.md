# 05.05 — Liczniki i automaty stanów

## Po co to jest

Automat stanów to sposób myślenia o każdym układzie sekwencyjnym: sterownik protokołu komunikacyjnego, kontroler pamięci, obsługa klawiatury, sekwencer zasilania. Ten sam model stosuje się w oprogramowaniu mikrokontrolerów (moduł [09](../09-mikrokontrolery-embedded/)) i w HDL (moduł [17](../17-fpga-hdl/)).

## Teoria w pigułce

### Liczniki

| Licznik | Budowa | Właściwości |
|---|---|---|
| Asynchroniczny (ripple) | Wyjście przerzutnika T taktuje następny | Prosty, ale stany przejściowe i narastające opóźnienie |
| **Synchroniczny** | Wszystkie przerzutniki na wspólnym zegarze, logika stanu następnego | Standard |
| Modulo N | Liczy 0…N−1, potem wraca do 0 | Potrzeba $\lceil\log_2 N\rceil$ przerzutników |
| Rewersyjny, z ładowaniem | Kierunek liczenia, wpis wartości początkowej | Timery, dzielniki programowalne |

Licznik modulo N jest dzielnikiem częstotliwości przez N. Kasowanie przez **synchroniczne** ładowanie zera przy stanie N−1 — nie asynchronicznym resetem przy N (powstaje krótka szpilka).

### Automaty stanów

- **Moore** — wyjścia zależą tylko od stanu. Bezpieczne, wyjścia zmieniają się synchronicznie.
- **Mealy** — wyjścia zależą od stanu i wejść. Mniej stanów, szybsza reakcja, ale wyjścia mogą mieć szpilki od wejść.

### Procedura projektowania

1. Opis słowny → **graf stanów** (węzły — stany, krawędzie — warunki przejść).
2. **Tablica przejść** (stan bieżący + wejścia → stan następny, wyjścia).
3. **Minimalizacja** liczby stanów (stany równoważne).
4. **Kodowanie stanów:** binarne ($\lceil\log_2 N\rceil$ przerzutników), Graya (jedna zmiana bitu między kolejnymi stanami), one-hot ($N$ przerzutników, prosta logika — typowe w FPGA).
5. Funkcje wzbudzeń przerzutników (dla D: $D = Q^+$) → minimalizacja → schemat.
6. Sprawdzenie stanów nieużywanych — automat musi z nich wychodzić do stanu bezpiecznego.

## Przykład rozwiązany

**Detektor sekwencji „101”** (z nakładaniem) na wejściu szeregowym $x$, automat Moore'a, wyjście $y = 1$ po wykryciu.

| Stan | Znaczenie | $x = 0$ → | $x = 1$ → | $y$ |
|---|---|---|---|---|
| S0 | nic | S0 | S1 | 0 |
| S1 | odebrano „1” | S2 | S1 | 0 |
| S2 | odebrano „10” | S0 | S3 | 0 |
| S3 | odebrano „101” | S2 | S1 | 1 |

Z S3 przy $x = 0$ przechodzimy do S2 (końcowe „10” może być początkiem kolejnej sekwencji), przy $x = 1$ do S1. Kodowanie binarne: 2 przerzutniki; wyjście $y = Q_1Q_0$ (przy kodzie S3 = 11).

## Typowe pułapki

- **Zapomniane przejścia** — z każdego stanu musi wychodzić krawędź dla każdej kombinacji wejść.
- **Stany nieużywane bez obsługi** — po zakłóceniu automat może utknąć w stanie nieistniejącym w projekcie.
- **Licznik modulo N z asynchronicznym kasowaniem.**
- **Wejścia asynchroniczne** (przyciski, sygnały z innej domeny zegarowej) podane wprost do logiki stanu następnego ([05.06](06-parametry-czasowe.md)).

## Ćwiczenie w symulatorze

- [ ] Zbuduj synchroniczny licznik modulo 10 z przerzutników D i sprawdź, że po 9 wraca do 0.
- [ ] Zbuduj detektor „101” z przykładu i przetestuj ciąg `1101011010`.
- [ ] Przepisz detektor na automat Mealy'ego — ile stanów wystarczy?

## Zadania

1. Ile przerzutników potrzeba do licznika modulo 10, modulo 60 i modulo 1000?
2. Zaprojektuj synchroniczny licznik modulo 6 na przerzutnikach D (podaj funkcje wzbudzeń).
3. Licznik modulo 1000 taktowany zegarem 1 MHz. Jaka jest częstotliwość na wyjściu przeniesienia?
4. Zaprojektuj detektor sekwencji „110” jako automat Moore'a (graf i tablica przejść).
5. Automat ma 6 stanów. Ile przerzutników przy kodowaniu binarnym i one-hot? Kiedy wybrałbyś one-hot?

<details>
<summary>Odpowiedzi</summary>

1. 4, 6, 10
2. Stany 0–5 (000–101), stany 110 i 111 jako nieokreślone (lub z przejściem do 000). Wynik minimalizacji z użyciem nieokreśloności: $D_0 = \overline{Q_0}$, $D_1 = \overline{Q_2}\,(Q_1 \oplus Q_0)$, $D_2 = Q_2\overline{Q_0} + Q_1Q_0$. Sprawdzenie stanów nieużywanych: 110 → 101, 111 → 100 — licznik sam wraca do cyklu
3. 1 kHz
4. S0 (nic) –1→ S1, –0→ S0; S1 („1”) –1→ S2, –0→ S0; S2 („11”) –1→ S2, –0→ S3; S3 („110”, $y = 1$) –1→ S1, –0→ S0
5. 3 i 6; one-hot w FPGA, gdzie przerzutników jest dużo, a liczy się prosta i szybka logika stanu następnego
</details>

## Źródła

- [All About Circuits — tom Digital, rozdziały *Counters* i *Sequential Circuits*](https://www.allaboutcircuits.com/textbook/)
- [MIT 6.004 Computation Structures](https://ocw.mit.edu/courses/6-004-computation-structures-spring-2017/) — automaty skończone
- [MIT 6.111 Introductory Digital Systems Laboratory](https://ocw.mit.edu/courses/6-111-introductory-digital-systems-laboratory-spring-2006/) — projektowanie automatów i kodowanie stanów
