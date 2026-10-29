# M02.03 — Multipleksacja przestrzenna i detekcja MIMO

## Po co to jest

Multipleksacja przestrzenna wysyła z $n_t$ anten niezależne strumienie danych w tym samym paśmie — tak Wi-Fi i LTE/5G osiągają setki Mb/s i więcej. W odbiorniku strumienie są wymieszane przez kanał i trzeba je rozdzielić. Wybór detektora to klasyczny kompromis: liniowe ZF i MMSE są tanie, ale tracą zróżnicowanie; ML jest optymalny, ale złożoność rośnie wykładniczo; między nimi są SIC (V-BLAST), dekodowanie sferyczne i detektory iteracyjne z miękkimi wyjściami.

## Teoria w pigułce

### Detektory

| Detektor | Operacja | Rząd zróżnicowania ($n_t = n_r = n$) | Złożoność |
|---|---|---|---|
| **ZF** (wymuszanie zera) | $\hat{\mathbf x} = \mathbf H^+\mathbf y = (\mathbf H^H\mathbf H)^{-1}\mathbf H^H\mathbf y$, potem decyzja | $n_r - n_t + 1$ (1 dla kwadratowego) | $O(n^3)$ na kanał |
| **MMSE** | $\hat{\mathbf x} = (\mathbf H^H\mathbf H + N_0\mathbf I)^{-1}\mathbf H^H\mathbf y$ | Jak ZF (przy wysokim SNR), lepszy przy niskim | $O(n^3)$ |
| **SIC / V-BLAST** | Wykryj najsilniejszy strumień, odejmij, powtórz (z porządkowaniem) | Rośnie z kolejnymi strumieniami; propagacja błędów | $O(n^4)$ |
| **ML** | $\min_{\mathbf x\in\mathcal S^{n_t}}\lVert\mathbf y - \mathbf H\mathbf x\rVert^2$ | $n_r$ | $\lvert\mathcal S\rvert^{n_t}$ — wykładnicza |
| **Dekodowanie sferyczne** | ML z przeszukiwaniem drzewa w ograniczonej kuli | $n_r$ | Średnio wielomianowa przy wysokim SNR |

- ZF **wzmacnia szum** w kierunkach słabych wartości osobliwych: SNR strumienia $k$ to $\mathrm{SNR}/[(\mathbf H^H\mathbf H)^{-1}]_{kk}$.
- MMSE równoważy zakłócenia między strumieniami i szum (estymator LMMSE z [M01.04](../M01-estymacja-detekcja-filtracja/04-estymacja-bayesowska.md)).
- **Miękkie wyjścia** (LLR bitów) z detektora są konieczne dla dekodera LDPC/turbo; ML z miękkimi wyjściami: max-log-MAP po kandydatach.
- **Prekodowanie przy znanym kanale** (SVD, temat 01) zamienia problem w równoległe kanały bez interferencji — wymaga jednak informacji zwrotnej (książki kodowe w LTE/5G: PMI).

### Kanał selektywny częstotliwościowo

OFDM ([13.07](../../modules/13-telekomunikacja/07-ofdm-i-wielodostep.md)) zamienia kanał szerokopasmowy w wiele kanałów płaskich — detekcja MIMO odbywa się niezależnie na każdej podnośnej.

## Przykład rozwiązany

**2 × 2, QPSK, kanał Rayleigha** (symulacja, SNR = całkowita moc nadawana / $N_0$):

| SNR | ZF | MMSE | ML |
|---|---|---|---|
| 10 dB | $1\text{,}4\cdot 10^{-1}$ | $9\text{,}9\cdot 10^{-2}$ | $5\text{,}3\cdot 10^{-2}$ |
| 20 dB | $1\text{,}8\cdot 10^{-2}$ | $1\text{,}3\cdot 10^{-2}$ | $1\text{,}0\cdot 10^{-3}$ |

(prawdopodobieństwo błędu symbolu). Przy +10 dB ZF i MMSE poprawiają się ok. 8 razy (rząd zróżnicowania 1), a ML ok. 50 razy (rząd 2). ML przegląda tu tylko $4^2 = 16$ kandydatów; dla 4 × 4 z 64-QAM byłoby ich $64^4 \approx 1\text{,}7\cdot 10^7$ — stąd dekodowanie sferyczne i detektory przybliżone.

## Typowe pułapki

- **ZF przy źle uwarunkowanym kanale** — ogromne wzmocnienie szumu.
- **SIC bez porządkowania** — błąd pierwszego strumienia psuje wszystkie następne.
- **Twarde decyzje przed dekoderem** — strata 2–3 dB względem LLR.
- **Ignorowanie błędów estymacji kanału** w detektorze — MMSE z $N_0$ powiększonym o wariancję błędu estymacji.
- **Liczba strumieni większa niż rząd kanału** — strumienie nie do rozdzielenia; adaptacyjny dobór liczby strumieni (rank adaptation).

## Ćwiczenie komputerowe

Detektory ZF, MMSE i ML dla 2 × 2 z QPSK:

```python
import numpy as np
from itertools import product

rng = np.random.default_rng(2)
nt = nr = 2
qpsk = np.array([1+1j, 1-1j, -1+1j, -1-1j])/np.sqrt(2)
cands = np.array(list(product(qpsk, repeat=nt))).T           # 16 kombinacji dla ML
n = 100_000

for snr_db in (10, 20):
    snr = 10**(snr_db/10); N0 = nt/snr                        # SNR = całkowita moc nadawana (nt symboli o energii 1) / N0
    idx = rng.integers(0, 4, (nt, n)); x = qpsk[idx]
    H = (rng.normal(size=(n, nr, nt)) + 1j*rng.normal(size=(n, nr, nt)))/np.sqrt(2)
    w = (rng.normal(size=(nr, n)) + 1j*rng.normal(size=(nr, n)))*np.sqrt(N0/2)
    y = np.einsum('nij,jn->in', H, x) + w
    Hh = np.conj(np.transpose(H, (0, 2, 1)))
    def slicer(z):
        return np.argmin(np.abs(z[..., None] - qpsk)**2, axis=-1)
    W_zf = np.linalg.pinv(H)
    W_mmse = np.linalg.solve(Hh @ H + N0*np.eye(nt), Hh)
    ser = {}
    for name, W in (("ZF", W_zf), ("MMSE", W_mmse)):
        z = np.einsum('nij,jn->in', W, y)
        ser[name] = np.mean(slicer(z) != idx)
    d = np.abs(y[None, :, :] - np.einsum('nij,jc->cin', H, cands))**2    # odległości dla 16 kandydatów
    best = np.argmin(d.sum(axis=1), axis=0)
    ml_idx = np.array([[np.argmin(np.abs(qpsk - c)) for c in cands[:, b]] for b in range(16)])[best].T
    ser["ML"] = np.mean(ml_idx != idx)
    print(f"2×2 QPSK, SNR = {snr_db} dB: SER ZF {ser['ZF']:.2e}, MMSE {ser['MMSE']:.2e}, ML {ser['ML']:.2e}")
```

Rozszerzenie: dodaj SIC z porządkowaniem według SNR strumieni i porównaj; zmień konfigurację na 2 × 4 (więcej anten odbiorczych) i sprawdź, jak rośnie rząd zróżnicowania ZF.

## Zadania

1. Ile kandydatów przegląda detektor ML dla 4 × 4 z 16-QAM?
2. Kanał $\mathbf H = \begin{bmatrix} 1 & 0\text{,}9 \\ 0\text{,}9 & 1\end{bmatrix}$. Ile wynosi wzmocnienie szumu ZF dla każdego strumienia (element przekątnej $(\mathbf H^H\mathbf H)^{-1}$)?
3. Dlaczego detektor MMSE jest lepszy od ZF przy niskim SNR, a przy wysokim prawie taki sam?
4. Jaki jest rząd zróżnicowania ZF dla konfiguracji 2 × 4?
5. Dlaczego w praktycznych odbiornikach LTE/Wi-Fi stosuje się detektory z miękkimi wyjściami?

<details>
<summary>Odpowiedzi</summary>

1. $16^4 = 65\,536$
2. $\mathbf H^H\mathbf H = \begin{bmatrix} 1\text{,}81 & 1\text{,}8 \\ 1\text{,}8 & 1\text{,}81\end{bmatrix}$, wyznacznik $1\text{,}81^2 - 1\text{,}8^2 = 0\text{,}0361$; $[(\mathbf H^H\mathbf H)^{-1}]_{kk} = 1\text{,}81/0\text{,}0361 \approx 50$ — szum wzmocniony ok. 17 dB (kanał prawie osobliwy)
3. MMSE dodaje $N_0\mathbf I$ przed odwróceniem — przy niskim SNR nie wzmacnia szumu w słabych kierunkach (kompromis interferencja/szum); przy wysokim $N_0 \to 0$ i MMSE → ZF
4. $n_r - n_t + 1 = 3$
5. Dekoder kanałowy (LDPC, turbo) potrzebuje informacji o pewności każdego bitu; twarde decyzje tracą ok. 2–3 dB, a iteracyjna wymiana informacji detektor–dekoder (turbo-detekcja) zbliża jakość do ML
</details>

## Źródła

- [D. Tse, P. Viswanath — Fundamentals of Wireless Communication](https://web.stanford.edu/~dntse/wireless_book.html) — rozdział 8 (architektury odbiorników MIMO)
- [NVIDIA Sionna (GitHub)](https://github.com/NVlabs/sionna) — detektory MIMO z miękkimi wyjściami
- [M01.04 Estymacja bayesowska](../M01-estymacja-detekcja-filtracja/04-estymacja-bayesowska.md)
