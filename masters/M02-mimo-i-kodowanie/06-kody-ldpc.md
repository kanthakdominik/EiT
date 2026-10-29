# M02.06 — Kody LDPC i dekodowanie iteracyjne

## Po co to jest

Kody LDPC (o rzadkiej macierzy kontrolnej) pracują w odległości ułamka decybela od granicy Shannona. Wymyślone przez Gallagera w 1962 r., zapomniane i odkryte ponownie w latach 90., są dziś w kanałach danych 5G NR, Wi-Fi (802.11n/ac/ax), DVB-S2/T2, 10GBASE-T, dyskach SSD i łączach satelitarnych. Kluczem jest dekodowanie iteracyjne: wymiana miękkich wiadomości po grafie Tannera — algorytm równoległy, idealny do realizacji w sprzęcie ([17 FPGA](../../modules/17-fpga-hdl/)).

## Teoria w pigułce

### Kod i graf Tannera

- Kod liniowy: słowa $\mathbf c$ spełniające $\mathbf H\mathbf c^T = \mathbf 0$ (mod 2); $\mathbf H$ — $m\times n$, **rzadka** (stała mała liczba jedynek w kolumnie $w_c$ i wierszu $w_r$ dla kodu regularnego); sprawność $R \geq 1 - m/n$.
- **Graf Tannera:** węzły zmiennych (bity, kolumny) i węzły kontrolne (równania, wiersze), krawędź dla każdej jedynki w $\mathbf H$.
- **Cykle** w grafie (szczególnie krótkie, długości 4) pogarszają dekodowanie — konstrukcje unikają ich (obwód grafu, *girth*).
- **Kody nieregularne** (różne stopnie węzłów, optymalizowane metodą ewolucji gęstości) zbliżają się do pojemności bardziej niż regularne.
- **Kody quasi-cykliczne (QC-LDPC)** — $\mathbf H$ złożona z przesuniętych macierzy jednostkowych: proste kodowanie i równoległy dekoder; 5G NR używa dwóch grafów bazowych z podnoszeniem (lifting) i różnymi rozmiarami.

### Dekodowanie propagacją przekonań (BP, sum-product)

Wejście: LLR z kanału $L_i = \ln\dfrac{P(c_i = 0\mid y_i)}{P(c_i = 1\mid y_i)}$ (dla BPSK w AWGN: $2y_i/\sigma^2$). Iteracja:

1. **Węzeł kontrolny → zmienna:** $r_{j\to i} = 2\,\mathrm{artanh}\prod_{i'\ne i}\tanh(q_{i'\to j}/2)$ — „jaka wartość bitu $i$ spełnia równanie $j$, sądząc po pozostałych bitach”.
2. **Zmienna → węzeł kontrolny:** $q_{i\to j} = L_i + \sum_{j'\ne j}r_{j'\to i}$.
3. Decyzja $\hat c_i = [L_i + \sum_jr_{j\to i} < 0]$; stop, gdy $\mathbf H\hat{\mathbf c}^T = \mathbf 0$.

**Min-sum** (w sprzęcie): $r_{j\to i} = \alpha\prod\mathrm{sgn}(q)\cdot\min\lvert q\rvert$ (bez własnej krawędzi), $\alpha \approx 0\text{,}75$–0,85 koryguje przeszacowanie; tylko porównania i dodawania — stąd prosta implementacja.

### Własności

- **Próg** (z ewolucji gęstości): $E_b/N_0$, powyżej którego przy nieskończonej długości dekodowanie zbiega; dla kodu regularnego (3, 6) w AWGN ok. 1,1 dB (granica Shannona dla BPSK i $R = 1/2$ — 0,19 dB).
- **Spadek wodospadowy** (waterfall) FER powyżej progu, stromszy dla dłuższych kodów.
- **Podłoga błędów** (error floor) przy wysokim SNR — struktury pułapkujące (trapping sets) w grafie; ważne dla zastosowań z FER < $10^{-10}$.

## Przykład rozwiązany

**Regularny kod Gallagera (3, 6), $n = 1200$, $R = 1/2$,** dekoder min-sum ($\alpha = 0\text{,}8$, maks. 30 iteracji), BPSK w AWGN (symulacja, 200 ramek na punkt):

| $E_b/N_0$ | 1,0 dB | 1,5 dB | 2,0 dB | 2,5 dB |
|---|---|---|---|---|
| FER | ok. 0,8 | ok. 0,2 | ok. 0,03 | < 0,005 |

Bez kodowania przy 2,5 dB BER wynosi $3\cdot 10^{-2}$; z kodem — ani jednego błędu w 200 ramkach. Wodospad leży ok. 1,5–2 dB od granicy Shannona dla BPSK (0,19 dB): kod jest regularny, krótki, a dekoder uproszczony. Kody 5G (nieregularne, dłuższe, dekoder z warstwowym harmonogramem) są bliżej granicy.

Trik symulacyjny: dla kodu liniowego w kanale symetrycznym i symetrycznego dekodera prawdopodobieństwo błędu nie zależy od słowa kodowego — wystarczy symulować słowo zerowe (bez kodera).

## Typowe pułapki

- **Losowa macierz $\mathbf H$ z cyklami długości 4** — wyraźnie gorsze dekodowanie; stosuj konstrukcje z kontrolą obwodu (PEG, QC).
- **Złe skalowanie LLR** (błędna wariancja szumu) — min-sum jest na to odporny, sum-product nie.
- **Zbyt mało iteracji** w implementacji sprzętowej — strata kilku dziesiątych dB; harmonogram warstwowy zbiega ok. 2 razy szybciej.
- **Ocena tylko BER bez FER** — w systemach pakietowych liczy się FER.
- **Symulacja zbyt krótka** do oceny podłogi błędów — FER $10^{-6}$ wymaga milionów ramek (symulacja na GPU/FPGA).

## Ćwiczenie komputerowe

Kod LDPC Gallagera (3, 6) i wektorowy dekoder min-sum po krawędziach grafu Tannera:

```python
import numpy as np

rng = np.random.default_rng(5)
def gallager_H(n, wc, wr):
    """Regularny kod LDPC Gallagera: wc pasm, każde to permutacja kolumn macierzy blokowej."""
    m = n*wc//wr
    base = np.zeros((m//wc, n), dtype=np.uint8)
    for i in range(m//wc):
        base[i, i*wr:(i+1)*wr] = 1
    return np.vstack([base] + [base[:, rng.permutation(n)] for _ in range(wc - 1)])

n, wc, wr = 1200, 3, 6                                    # kod o sprawności 1/2
H = gallager_H(n, wc, wr)
rows, cols = np.nonzero(H)                                 # krawędzie grafu Tannera
m = H.shape[0]

def decode_min_sum(llr, iters=30, alpha=0.8):
    msg_vc = llr[cols].copy()
    for _ in range(iters):
        # węzły kontrolne: znak = iloczyn znaków, moduł = minimum (bez własnej krawędzi), skalowanie alpha
        sgn = np.sign(msg_vc); sgn[sgn == 0] = 1
        mag = np.abs(msg_vc)
        prod_sign = np.ones(m); np.multiply.at(prod_sign, rows, sgn)
        order = np.lexsort((mag, rows))
        r_sorted, m_sorted = rows[order], mag[order]
        first = np.r_[True, r_sorted[1:] != r_sorted[:-1]]
        idx_first = np.nonzero(first)[0]
        min1 = np.full(m, np.inf); min2 = np.full(m, np.inf)
        min1[r_sorted[idx_first]] = m_sorted[idx_first]
        min2[r_sorted[idx_first]] = m_sorted[idx_first + 1]
        own_min = np.where(mag == min1[rows], min2[rows], min1[rows])
        msg_cv = alpha*prod_sign[rows]*sgn*own_min
        total = llr + np.bincount(cols, weights=msg_cv, minlength=n)
        hard = (total < 0).astype(np.uint8)
        if not np.any(np.bincount(rows, weights=hard[cols], minlength=m) % 2):
            return hard                                    # wszystkie równania kontrolne spełnione
        msg_vc = total[cols] - msg_cv
    return hard

R = 0.5
for EbN0_db in (1.0, 1.5, 2.0, 2.5):
    sigma = np.sqrt(1/(2*R*10**(EbN0_db/10)))
    frames, bit_err, frame_err = 200, 0, 0
    for _ in range(frames):                                # słowo zerowe (kod liniowy, kanał symetryczny)
        y = 1 + rng.normal(0, sigma, n)                    # BPSK: bit 0 → +1
        dec = decode_min_sum(2*y/sigma**2)
        bit_err += dec.sum(); frame_err += dec.any()
    print(f"Eb/N0 = {EbN0_db} dB: BER = {bit_err/(frames*n):.2e}, FER = {frame_err/frames:.2f}")
from scipy.special import erfc
print(f"bez kodowania przy 2,5 dB: BER = {0.5*erfc(np.sqrt(10**0.25)):.2e}")
```

Rozszerzenie: zaimplementuj dekoder sum-product (z $\tanh$) i porównaj z min-sum; zbadaj wpływ $\alpha$ i liczby iteracji; zwiększ $n$ do 4800 i porównaj stromość wodospadu.

## Zadania

1. Macierz $\mathbf H$ ma 600 wierszy i 1200 kolumn, w każdej kolumnie 3 jedynki. Ile jedynek w wierszu i jaka sprawność kodu?
2. Dlaczego cykl długości 4 w grafie Tannera szkodzi dekodowaniu?
3. Dlaczego dekoder min-sum potrzebuje współczynnika skalującego $\alpha < 1$?
4. Kod ma próg 1,1 dB. Czy krótki kod (n = 200) z tej samej rodziny osiągnie FER $10^{-3}$ przy 1,2 dB?
5. Jak sprawdzić, czy dekoder trafił w słowo kodowe, bez znajomości nadanych bitów?

<details>
<summary>Odpowiedzi</summary>

1. $1200\cdot 3/600 = 6$ jedynek w wierszu; $R = 1 - 600/1200 = 1/2$ (jeśli wiersze są liniowo niezależne)
2. Wiadomości krążą w krótkiej pętli — po dwóch iteracjach węzeł dostaje z powrotem informację, którą sam wysłał, a założenie niezależności wiadomości (na którym opiera się BP) przestaje obowiązywać
3. Przybliżenie min-sum zawyża moduł wiadomości węzła kontrolnego względem dokładnego wzoru z $\tanh$ (minimum jest większe niż wynik iloczynu tanh); skalowanie lub odejmowanie stałej (offset min-sum) koryguje tę nadmierną pewność
4. Raczej nie — próg dotyczy długości dążącej do nieskończoności; krótkie kody mają łagodniejszy wodospad i potrzebują więcej (często 1–2 dB) do niskiej FER (temat 08)
5. Obliczyć syndrom $\mathbf H\hat{\mathbf c}^T$ — zero oznacza słowo kodowe (choć możliwie inne niż nadane — błąd niewykrywalny, bardzo rzadki dla dobrych kodów; dodatkowo stosuje się CRC)
</details>

## Źródła

- [MIT 6.451 Principles of Digital Communication II](https://ocw.mit.edu/courses/6-451-principles-of-digital-communication-ii-spring-2005/) — kody na grafach, LDPC, dekodowanie iteracyjne
- [NVIDIA Sionna (GitHub)](https://github.com/NVlabs/sionna) — koder i dekoder LDPC 5G NR
- T. Richardson, R. Urbanke — *Modern Coding Theory* (płatna)
- [13.06 Kodowanie kanałowe](../../modules/13-telekomunikacja/06-kodowanie-kanalowe.md)
