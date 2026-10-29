# 05.01 — Systemy liczbowe, kody i arytmetyka binarna

## Po co to jest

Wszystko w układach cyfrowych to bity. Rejestry mikrokontrolera opisuje się szesnastkowo, wyniki przetwornika A/C bywają w kodzie U2, enkodery obrotowe używają kodu Graya, wyświetlacze — BCD. Błędne rozumienie zapisu ze znakiem to klasyczne źródło błędów w oprogramowaniu wbudowanym.

## Teoria w pigułce

### Systemy pozycyjne

$N = \sum d_i\cdot b^i$. Przydatne: jedna cyfra szesnastkowa = 4 bity, jedna ósemkowa = 3 bity.

| Dziesiętnie | Binarnie | Szesnastkowo |
|---|---|---|
| 10 | 1010 | A |
| 15 | 1111 | F |
| 47 | 0010 1111 | 2F |
| 255 | 1111 1111 | FF |

### Liczby ze znakiem

| Kod | 8-bitowy zakres | $-5$ | Uwagi |
|---|---|---|---|
| Znak-moduł | −127…+127 | 1000 0101 | Dwa zera, trudna arytmetyka |
| U1 (uzupełnienie do 1) | −127…+127 | 1111 1010 | Dwa zera |
| **U2 (uzupełnienie do 2)** | **−128…+127** | **1111 1011** | Standard: dodawanie i odejmowanie tym samym sumatorem |

Negacja w U2: zaneguj bity i dodaj 1. **Rozszerzenie znakowe:** kopiuj najstarszy bit (−5 na 16 bitach: `FFFB`).

**Przepełnienie** w U2: suma dwóch liczb tego samego znaku daje wynik o przeciwnym znaku (np. 100 + 50 na 8 bitach → −106). Sprzętowo: przeniesienie do bitu znaku ≠ przeniesienie z bitu znaku.

### Liczby ułamkowe

- **Stały przecinek (Qm.n):** np. Q15 — liczba 16-bitowa reprezentuje zakres [−1, 1) z krokiem $2^{-15}$. Standard w DSP na mikrokontrolerach ([07.06](../07-cps-dsp/06-realizacja-filtrow.md)).
- **Zmienny przecinek (IEEE 754):** znak, wykładnik, mantysa. `float` ma ok. 7 cyfr znaczących, `double` ok. 16.

### Kody

| Kod | Właściwość | Zastosowanie |
|---|---|---|
| NKB (naturalny binarny) | Wagi $2^i$ | Arytmetyka |
| BCD | Każda cyfra dziesiętna na 4 bitach | Wyświetlacze, zegary RTC |
| **Gray** | Sąsiednie wartości różnią się jednym bitem: $g = b \oplus (b \gg 1)$ | Enkodery, liczniki przekraczające domeny zegarowe, tablice Karnaugha |
| One-hot | Dokładnie jeden bit = 1 | Kodowanie stanów automatów w FPGA |
| ASCII / UTF-8 | Znaki | Komunikacja tekstowa |
| Parzystość, CRC, Hamming | Wykrywanie / korekcja błędów | Transmisja, pamięci (moduł [13](../13-telekomunikacja/)) |

## Przykład rozwiązany

Oblicz w U2 na 8 bitach: $45 - 70$.

1. $45 = 0010\,1101$, $70 = 0100\,0110$, $-70 = 1011\,1001 + 1 = 1011\,1010$.
2. $0010\,1101 + 1011\,1010 = 1110\,0111$.
3. Wynik ujemny: negacja $0001\,1000 + 1 = 0001\,1001 = 25$ → wynik $-25$ ✓. Przepełnienia brak (składniki różnych znaków).

## Typowe pułapki

- **Mieszanie typów ze znakiem i bez znaku** w C — porównanie `int8_t` z `uint8_t` lub przesunięcie w prawo liczby ujemnej.
- **Brak rozszerzenia znakowego** przy przepisywaniu 12-bitowego wyniku A/C w U2 do zmiennej 16-bitowej.
- **Przepełnienie w akumulatorze filtra** — w DSP stosuje się szersze akumulatory lub nasycanie zamiast zawijania.
- **Gray traktowany jak NKB** przy odczycie enkodera.

## Ćwiczenie komputerowe

```python
def u2(x, bits=8): return format(x & ((1 << bits) - 1), f'0{bits}b')
def from_u2(s): v = int(s, 2); return v - (1 << len(s)) if s[0] == '1' else v
gray = lambda b: b ^ (b >> 1)
print(u2(-5), from_u2('11100111'), [format(gray(i), '03b') for i in range(8)])
```

## Zadania

1. Zamień $0\text{x}2F$ na dziesiętny i binarny, a $200_{10}$ na szesnastkowy.
2. Zapisz $-5$ i $-128$ w U2 na 8 bitach. Czy da się zapisać $+128$?
3. Oblicz w U2 (8 bitów) $100 + 50$. Czy wystąpiło przepełnienie? Jaki wynik pokaże rejestr?
4. Zakoduj liczbę 59 w BCD i podaj kod Graya dla $1011_2$.
5. 12-bitowy przetwornik zwraca wynik w U2: `0xF9C`. Jaka to wartość? Jak ją poprawnie zapisać w zmiennej 16-bitowej?
6. Ile wynosi najmniejszy krok i zakres liczby w formacie Q15? Jak zapisać 0,3?

<details>
<summary>Odpowiedzi</summary>

1. 47 i 101111; $200 = \text{C8}_{16}$
2. $1111\,1011$, $1000\,0000$; nie (zakres do +127)
3. Przepełnienie — rejestr pokaże $1001\,0110 = -106$
4. $0101\,1001$; $1110$
5. $\text{F9C} = 1111\,1001\,1100$ → ujemna: negacja $0000\,0110\,0011 + 1 = 100$ → $-100$; w 16 bitach `0xFF9C` (rozszerzenie znakowe)
6. Krok $2^{-15} \approx 3\text{,}05\cdot 10^{-5}$, zakres [−1, 1); $0\text{,}3 \approx 9830/32768$ (`0x2666`)
</details>

## Źródła

- [All About Circuits — tom Digital, rozdziały *Numeration Systems* i *Binary Arithmetic*](https://www.allaboutcircuits.com/textbook/)
- [MIT 6.004 Computation Structures](https://ocw.mit.edu/courses/6-004-computation-structures-spring-2017/) — reprezentacja informacji, kodowanie liczb
- [nand2tetris](https://www.nand2tetris.org/) — rozdział o arytmetyce binarnej i budowie ALU
