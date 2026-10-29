# 13.01 — Teoria informacji: entropia, kodowanie źródłowe, pojemność

## Po co to jest

Teoria informacji Shannona odpowiada na dwa fundamentalne pytania: ile naprawdę informacji niesie źródło (czyli do ilu bitów można je skompresować) i ile informacji można bezbłędnie przesłać przez kanał z szumem. Daje granice, do których zbliżają się wszystkie współczesne systemy — i pokazuje, czego żadna sztuczka nie przeskoczy.

## Teoria w pigułce

### Ilość informacji i entropia

Zdarzenie o prawdopodobieństwie $p$ niesie $I = -\log_2 p$ bitów — rzadkie zdarzenia niosą więcej informacji. **Entropia** źródła dyskretnego bez pamięci:

$$H(X) = -\sum_i p_i\log_2 p_i\ \ [\text{bit/symbol}]$$

- $0 \leq H \leq \log_2 M$; maksimum dla symboli równoprawdopodobnych.
- Źródło binarne: $H(p) = -p\log_2p - (1-p)\log_2(1-p)$, maksimum 1 bit przy $p = 0{,}5$.
- Źródła z pamięcią (tekst, obraz) mają mniejszą entropię na symbol niż wynika z częstości pojedynczych symboli — kompresory wykorzystują zależności (kontekst, słowniki, predykcję).

### Kodowanie źródłowe

**Twierdzenie o kodowaniu źródła:** średnia długość kodu bezprefiksowego $\bar L \geq H$ i można się do $H$ dowolnie zbliżyć (kodując bloki symboli).

**Kod Huffmana** (optymalny kod bezprefiksowy dla znanych prawdopodobieństw):
1. Posortuj symbole według prawdopodobieństw.
2. Połącz dwa najmniej prawdopodobne w węzeł o sumie prawdopodobieństw.
3. Powtarzaj, aż zostanie jeden węzeł; gałęziom przypisz 0 i 1.

Inne metody: kodowanie arytmetyczne (bliżej entropii, adaptacyjne), LZ77/LZW (słownikowe — ZIP, PNG), kompresja stratna (JPEG, MP3, AAC, wideo) — transformata + kwantyzacja + kodowanie entropijne, z wykorzystaniem właściwości percepcji.

### Pojemność kanału

**Kanał binarny symetryczny** z prawdopodobieństwem błędu $p$: $C = 1 - H(p)$ bit na użycie kanału.

**Twierdzenie Shannona–Hartleya** (kanał AWGN o paśmie $B$):

$$C = B\log_2\left(1 + \frac{S}{N}\right)\ \ [\text{bit/s}]$$

Przy przepływności $R < C$ istnieją kody o dowolnie małym prawdopodobieństwie błędu; przy $R > C$ — nie istnieją. Wnioski:
- przy dużym SNR pojemność rośnie liniowo z pasmem i logarytmicznie z mocą (+3 dB SNR ≈ +1 bit/s/Hz);
- przy małym SNR pojemność rośnie liniowo z mocą;
- **granica Shannona:** $E_b/N_0 \geq \ln 2 \approx -1{,}59$ dB przy nieskończonym paśmie — poniżej tej wartości bezbłędna transmisja jest niemożliwa;
- efektywność widmowa $\eta = R/B$ wymaga $E_b/N_0 \geq (2^\eta - 1)/\eta$.

Współczesne kody (turbo, LDPC, polarne — [13.06](06-kodowanie-kanalowe.md)) pracują w odległości ułamka dB do ok. 1–2 dB od tej granicy.

## Przykład rozwiązany

**Źródło** {A, B, C, D} z prawdopodobieństwami 0,4; 0,3; 0,2; 0,1.

1. $H = -(0{,}4\log_20{,}4 + 0{,}3\log_20{,}3 + 0{,}2\log_20{,}2 + 0{,}1\log_20{,}1) \approx 1{,}846$ bit/symbol.
2. Huffman: łączymy C+D (0,3), potem B+(CD) (0,6), potem A+(B,C,D). Kody: A = 0, B = 10, C = 110, D = 111.
3. $\bar L = 0{,}4\cdot 1 + 0{,}3\cdot 2 + 0{,}2\cdot 3 + 0{,}1\cdot 3 = 1{,}9$ bitu — 97% sprawności (kod równomierny potrzebowałby 2 bitów).

**Pojemność:** kanał telefoniczny $B = 3{,}1$ kHz, SNR = 30 dB → $C = 3100\log_2 1001 \approx 30{,}9$ kbit/s — stąd granica analogowych modemów telefonicznych (modemy 56k wykorzystywały cyfrowy odcinek sieci).

## Typowe pułapki

- **Logarytm naturalny zamiast dwójkowego** — wynik w natach.
- **SNR w dB wstawiony do wzoru Shannona** — wzór wymaga wartości liniowej.
- **Pojemność traktowana jako przepływność osiągalna dowolną modulacją bez kodowania** — to granica dla optymalnego kodowania z nieskończenie długimi blokami.
- **Kompresja danych już skompresowanych** (ZIP pliku JPEG) — entropia jest bliska maksimum, zysku nie ma.
- **Kod, który nie jest bezprefiksowy** — niejednoznaczne dekodowanie.

## Ćwiczenie komputerowe

Entropia, kod Huffmana i pojemność kanału:

```python
import heapq, math
from collections import Counter
import numpy as np

def huffman(probs):
    heap = [(p, i, {s: ''}) for i, (s, p) in enumerate(probs.items())]
    heapq.heapify(heap); k = len(heap)
    while len(heap) > 1:
        p1, _, c1 = heapq.heappop(heap); p2, _, c2 = heapq.heappop(heap)
        merged = {s: '0' + c for s, c in c1.items()} | {s: '1' + c for s, c in c2.items()}
        heapq.heappush(heap, (p1 + p2, k, merged)); k += 1
    return heap[0][2]

H = lambda p: -sum(x*math.log2(x) for x in p if x > 0)
probs = {'A': 0.4, 'B': 0.3, 'C': 0.2, 'D': 0.1}
code = huffman(probs)
L = sum(probs[s]*len(c) for s, c in code.items())
print("kod:", code, f"H = {H(probs.values()):.3f}, średnia długość = {L:.3f}")

text = "telekomunikacja i teoria informacji to podstawa elektroniki i telekomunikacji"
cnt = Counter(text); n = len(text)
p_text = {c: v/n for c, v in cnt.items()}
code_t = huffman(p_text)
bits = sum(len(code_t[c]) for c in text)
print(f"tekst: H = {H(p_text.values()):.3f} bit/znak, Huffman {bits/n:.3f} bit/znak, ASCII 8 bit/znak")

for B, snr_db in [(3.1e3, 30), (1e6, 20), (20e6, 25)]:
    print(f"B = {B/1e6:g} MHz, SNR = {snr_db} dB: C = {B*np.log2(1 + 10**(snr_db/10))/1e6:.3f} Mbit/s")
for eta in [0.5, 1, 2, 4, 6]:
    print(f"eta = {eta} bit/s/Hz: Eb/N0 min = {10*np.log10((2**eta - 1)/eta):5.2f} dB")
print(f"granica Shannona: {10*np.log10(np.log(2)):.2f} dB")
```

## Zadania

1. Entropia źródła binarnego z $p = 0{,}1$. Ile maksymalnie można zyskać kompresją?
2. Zbuduj kod Huffmana dla prawdopodobieństw 0,5; 0,25; 0,125; 0,125 i policz średnią długość.
3. Kanał binarny symetryczny z $p = 0{,}01$. Jaka jest pojemność na bit?
4. Łącze 20 MHz ma przenosić 100 Mbit/s. Jakiego minimalnego SNR wymaga granica Shannona?
5. Jaka jest minimalna wartość $E_b/N_0$ dla efektywności widmowej 4 bit/s/Hz?

<details>
<summary>Odpowiedzi</summary>

1. $H(0{,}1) \approx 0{,}469$ bitu — kompresja do ok. 47% (kodując bloki symboli)
2. 0, 10, 110, 111; $\bar L = 1{,}75 = H$ (prawdopodobieństwa są potęgami 1/2)
3. $1 - H(0{,}01) \approx 1 - 0{,}081 = 0{,}919$ bitu
4. $\eta = 5$ → SNR $\geq 2^5 - 1 = 31$ ≈ 14,9 dB
5. $(2^4 - 1)/4 = 3{,}75$ ≈ 5,7 dB
</details>

## Źródła

- [MIT 6.02 Digital Communication Systems](https://ocw.mit.edu/courses/6-02-introduction-to-eecs-ii-digital-communication-systems-fall-2012/) — informacja, entropia, kod Huffmana, LZW
- [MIT 6.450 Principles of Digital Communications I](https://ocw.mit.edu/courses/6-450-principles-of-digital-communications-i-fall-2006/) — kodowanie źródłowe i pojemność kanału
- [Fundamentals of Electrical Engineering I — D. Johnson](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-electrical-engineering-1) — rozdział o teorii informacji
- C. E. Shannon, „A Mathematical Theory of Communication”, *Bell System Technical Journal*, 1948 — praca źródłowa
