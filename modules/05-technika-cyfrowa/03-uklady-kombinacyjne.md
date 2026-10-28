# 05.03 — Układy kombinacyjne

## Po co to jest

Multipleksery, dekodery, sumatory i komparatory to bloki, z których buduje się ścieżki danych procesorów, wybór urządzeń na magistrali, wyświetlacze i jednostki arytmetyczne. Ich opóźnienia wyznaczają maksymalną częstotliwość pracy całego systemu.

## Teoria w pigułce

| Blok | Funkcja | Uwagi |
|---|---|---|
| **Multiplekser** $2^n:1$ | Wybiera jedno z $2^n$ wejść według $n$-bitowego adresu | Może zrealizować dowolną funkcję $n$ zmiennych (wejścia danych = kolumna tablicy prawdy) |
| **Demultiplekser** | Kieruje jedno wejście na jedno z $2^n$ wyjść | Dekoder z wejściem zezwalającym |
| **Dekoder** $n \to 2^n$ | Aktywuje jedno wyjście odpowiadające kodowi | Wybór układu na magistrali (chip select), sterowanie wyświetlaczem |
| **Koder priorytetowy** | Podaje numer najwyższego aktywnego wejścia | Obsługa przerwań |
| **Półsumator** | $S = A \oplus B$, $C = AB$ | |
| **Sumator pełny** | $S = A \oplus B \oplus C_{in}$, $C_{out} = AB + C_{in}(A \oplus B)$ | |
| **Sumator kaskadowy** (ripple carry) | $n$ sumatorów pełnych, przeniesienie przechodzi przez wszystkie | Opóźnienie rośnie liniowo z $n$ |
| **Sumator z przeniesieniem przyspieszonym** (carry lookahead) | Sygnały generacji $G = AB$ i propagacji $P = A \oplus B$ | Opóźnienie rośnie logarytmicznie |
| **Komparator** | $A = B$, $A > B$ | Równość: XNOR-y + AND |
| **ALU** | Arytmetyka i logika wybierana kodem operacji | Serce procesora |

**Odejmowanie** realizuje się sumatorem: $A - B = A + \overline{B} + 1$ (negacja bitów i $C_{in} = 1$).

**Ścieżka krytyczna** — najdłuższa droga sygnału od wejścia do wyjścia. W sumatorze kaskadowym to łańcuch przeniesień.

## Przykład rozwiązany

**Funkcja z multipleksera.** Zrealizuj $f(A, B, C) = \sum m(1, 2, 6, 7)$ multiplekserem 4:1 z adresem $A$, $B$.

| $A$ | $B$ | $f$ dla $C = 0$ | $f$ dla $C = 1$ | Wejście danych |
|---|---|---|---|---|
| 0 | 0 | 0 (m0) | 1 (m1) | $D_0 = C$ |
| 0 | 1 | 1 (m2) | 0 (m3) | $D_1 = \overline{C}$ |
| 1 | 0 | 0 (m4) | 0 (m5) | $D_2 = 0$ |
| 1 | 1 | 1 (m6) | 1 (m7) | $D_3 = 1$ |

Jeden multiplekser 4:1 i jeden inwerter zamiast pełnej realizacji bramkowej.

## Typowe pułapki

- **Aktywny stan niski** (oznaczenia z kreską: $\overline{CS}$, $\overline{OE}$) traktowany jak aktywny wysoki.
- **Kolejność bitów adresu** multipleksera zamieniona (MSB/LSB).
- **Szacowanie opóźnienia sumatora kaskadowego jak jednego bitu** — przeniesienie musi przejść przez wszystkie pozycje.

## Ćwiczenie w symulatorze

W Logisim-evolution lub Digital:
- [ ] zbuduj 4-bitowy sumator kaskadowy z sumatorów pełnych i dodaj tryb odejmowania (XOR na wejściu $B$ + $C_{in}$),
- [ ] dodaj wykrywanie przepełnienia w U2 ($C_3 \oplus C_4$),
- [ ] zbuduj dekoder 3→8 i sterownik wyświetlacza 7-segmentowego dla cyfr 0–9 (wartości nieokreślone dla 10–15).

## Zadania

1. Zrealizuj $f(A, B, C) = \sum m(1, 2, 6, 7)$ multiplekserem 4:1.
2. Ile wejść adresowych ma multiplekser 16:1? Ile wyjść ma dekoder 4-bitowy?
3. Sumator kaskadowy 8-bitowy: przeniesienie przez jeden bit zajmuje 1 ns. Jakie jest opóźnienie najgorszego przypadku? Jaki wektor wejściowy je wywołuje?
4. Wyznacz $S$ i $C_{out}$ sumatora pełnego dla $A = 1$, $B = 1$, $C_{in} = 1$.
5. Zaprojektuj komparator równości dwóch liczb 2-bitowych.
6. W systemie z mikroprocesorem trzy układy pamięci zajmują przestrzeń adresową po 16 kB. Które linie adresowe podasz na dekoder wyboru układów?

<details>
<summary>Odpowiedzi</summary>

1. $D_0 = C$, $D_1 = \overline{C}$, $D_2 = 0$, $D_3 = 1$ (adres $AB$)
2. 4 wejścia adresowe; 16 wyjść
3. Ok. 8 ns; np. $A = 1111\,1111$, $B = 0000\,0001$ — przeniesienie przechodzi przez wszystkie pozycje
4. $S = 1$, $C_{out} = 1$
5. $E = \overline{A_1 \oplus B_1}\cdot\overline{A_0 \oplus B_0}$
6. 16 kB = $2^{14}$ — linie $A_0$–$A_{13}$ trafiają do pamięci; wyższe linie (np. $A_{14}$, $A_{15}$) — do dekodera 2→4
</details>

## Źródła

- [All About Circuits — tom Digital, rozdziały o układach kombinacyjnych](https://www.allaboutcircuits.com/textbook/)
- [nand2tetris](https://www.nand2tetris.org/) — projekty 1–2: multipleksery, sumatory, ALU
- [MIT 6.004 Computation Structures](https://ocw.mit.edu/courses/6-004-computation-structures-spring-2017/) — synteza logiki, opóźnienia propagacji
- [Ben Eater](https://eater.net/8bit/) — ALU i dekodery w komputerze z układów 74xx
