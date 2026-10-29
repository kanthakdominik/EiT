# M02.07 — Kody polarne

## Po co to jest

Kody polarne (Arıkan, 2009) to pierwsza konstrukcja, dla której udowodniono osiąganie pojemności dowolnego binarnego kanału symetrycznego z dekoderem o złożoności $O(N\log N)$. W 5G NR chronią kanały sterujące (PDCCH, PUCCH, PBCH) — krótkie wiadomości, dla których dekoder z listą i CRC jest bardzo dobry. Idea **polaryzacji kanału** — z $N$ jednakowych kanałów rekurencyjnie robi się kanały prawie doskonałe i prawie bezużyteczne — jest elegancka i daje się zaimplementować w kilkudziesięciu liniach.

## Teoria w pigułce

### Polaryzacja

Podstawowa transformacja dwóch bitów: $x_1 = u_1\oplus u_2$, $x_2 = u_2$ (macierz $\mathbf F = \begin{bmatrix} 1 & 0 \\ 1 & 1\end{bmatrix}$). Z punktu widzenia dekodera sekwencyjnego powstają dwa kanały syntetyczne:

- $W^-$ (dla $u_1$, bez znajomości $u_2$) — **gorszy** od $W$,
- $W^+$ (dla $u_2$, przy znanym $u_1$) — **lepszy** od $W$,

przy zachowaniu sumy pojemności. Dla kanału z wymazaniami (BEC) z prawdopodobieństwem wymazania $z$: $z^- = 2z - z^2$, $z^+ = z^2$. Po $n$ krokach ($N = 2^n$, transformacja $\mathbf F^{\otimes n}$) pojemności kanałów syntetycznych dążą do 0 lub 1, a ułamek dobrych kanałów — do pojemności $C$.

### Kodowanie

- Wybierz $K$ najlepszych kanałów (**bity informacyjne**), pozostałe $N - K$ **zamrożone** (znane zera).
- $\mathbf x = \mathbf u\,\mathbf F^{\otimes n}$ — koder bez mnożeń, struktura „motylkowa” jak FFT, $\tfrac N2\log_2N$ operacji XOR.
- **Konstrukcja** (wybór zbioru informacyjnego) zależy od kanału: parametr Bhattacharyyi (przybliżenie BEC), aproksymacja gaussowska, ewolucja gęstości; 5G używa stałej sekwencji niezawodności dla $N \leq 1024$.

### Dekodowanie

- **SC (sukcesywne kasowanie):** bity dekodowane kolejno; dla zamrożonych decyzja jest znana. Rekurencja na drzewie: funkcja $f(a, b) = \mathrm{sgn}(a)\,\mathrm{sgn}(b)\min(\lvert a\rvert, \lvert b\rvert)$ (górna gałąź) i $g(a, b, \hat u) = b + (1 - 2\hat u)a$ (dolna). Złożoność $O(N\log N)$, ale jakość dla krótkich kodów przeciętna.
- **SCL (z listą):** $L$ najlepszych ścieżek (np. 8), z **CRC** wybierającym właściwą — dla krótkich bloków bije LDPC i turbo; to wariant w 5G.
- Opóźnienie: dekodowanie z natury sekwencyjne — wersje uproszczone (Fast-SSC) i równoległe.

## Przykład rozwiązany

**Kod polarny (256, 128),** konstrukcja Bhattacharyyi, dekoder SC, BPSK w AWGN (symulacja, 300 ramek):

| $E_b/N_0$ | 1 dB | 2 dB | 3 dB | 4 dB |
|---|---|---|---|---|
| FER | ok. 0,54 | ok. 0,17 | ok. 0,02 | < 0,003 |

Kod jest pięciokrotnie krótszy od kodu LDPC z tematu 06 i dekodowany prostym SC — wodospad leży ok. 1 dB dalej. Lista $L = 8$ z CRC poprawia wynik o ok. 1 dB i więcej przy tej długości.

Uwaga implementacyjna: kolejność indeksów w konstrukcji musi odpowiadać kolejności w koderze i dekoderze (z odwróceniem bitów lub bez) — pomyłka daje kod praktycznie bezużyteczny, co łatwo wykryć symulacją.

## Typowe pułapki

- **Niespójna numeracja kanałów** (odwrócenie bitów) między konstrukcją, koderem a dekoderem.
- **Konstrukcja dla innego SNR** niż pracy — dla krótkich kodów niewielka strata; dla długich istotna.
- **SC dla krótkich bloków** — wyraźnie gorszy od SCL; w praktyce zawsze lista z CRC.
- **Długość nie będąca potęgą dwójki** — potrzebne skracanie (shortening), nakłuwanie (puncturing) lub powtarzanie, jak w 5G (dopasowanie szybkości).
- **Porównanie z LDPC przy różnych długościach i sprawnościach.**

## Ćwiczenie komputerowe

Konstrukcja, koder i dekoder SC kodu polarnego (256, 128):

```python
import numpy as np

rng = np.random.default_rng(6)
N, K = 256, 128                                          # kod polarny (256, 128), sprawność 1/2
n = int(np.log2(N))

def bhattacharyya_order(N, z0):
    """Konstrukcja przez parametr Bhattacharyyi (przybliżenie kanałem BEC): z⁻ = 2z − z², z⁺ = z²."""
    z = np.array([z0])
    for _ in range(int(np.log2(N))):
        z = np.ravel(np.column_stack([2*z - z**2, z**2]))
    return np.argsort(z)                                 # od najlepszego kanału

def polar_encode(u):
    x = u.copy()
    step = 1
    while step < len(x):
        for i in range(0, len(x), 2*step):
            x[i:i+step] ^= x[i+step:i+2*step]
        step *= 2
    return x

def sc_decode(llr, frozen):
    """Dekoder SC (rekurencyjny, aproksymacja min-sum dla f)."""
    def rec(l, fz):
        if len(l) == 1:
            u = np.array([0 if fz[0] else int(l[0] < 0)], dtype=np.uint8)
            return u, u
        h = len(l)//2
        a, b = l[:h], l[h:]
        la = np.sign(a)*np.sign(b)*np.minimum(np.abs(a), np.abs(b))       # f: węzeł „górny”
        u1, x1 = rec(la, fz[:h])
        lb = b + (1 - 2*x1.astype(float))*a                                # g: węzeł „dolny”
        u2, x2 = rec(lb, fz[h:])
        return np.concatenate([u1, u2]), np.concatenate([x1 ^ x2, x2])
    return rec(llr, frozen)[0]

R = K/N
for EbN0_db in (1.0, 2.0, 3.0, 4.0):
    snr = R*10**(EbN0_db/10); sigma = np.sqrt(1/(2*snr))
    order = bhattacharyya_order(N, np.exp(-snr))         # parametr Bhattacharyyi kanału AWGN: exp(−Es/N0)
    info = np.sort(order[:K]); frozen = np.ones(N, bool); frozen[info] = False
    errs, fe, frames = 0, 0, 300
    for _ in range(frames):
        u = np.zeros(N, np.uint8); bits = rng.integers(0, 2, K, dtype=np.uint8); u[info] = bits
        x = polar_encode(u)
        y = (1 - 2*x.astype(float)) + rng.normal(0, sigma, N)
        u_hat = sc_decode(2*y/sigma**2, frozen)
        e = np.sum(u_hat[info] != bits); errs += e; fe += e > 0
    print(f"Eb/N0 = {EbN0_db} dB: BER = {errs/(frames*K):.2e}, FER = {fe/frames:.3f}")
```

Rozszerzenie: zaimplementuj dekoder SCL z listą 4–8 i CRC-8 (wybór ścieżki z poprawnym CRC) i porównaj FER z SC.

## Zadania

1. Kanał BEC z $z = 0\text{,}5$. Oblicz parametry wymazań kanałów syntetycznych po dwóch krokach polaryzacji (N = 4). Które kanały wybierzesz na 2 bity informacyjne?
2. Ile operacji XOR wykonuje koder polarny dla $N = 1024$?
3. Dlaczego dekodowanie SC jest sekwencyjne i co to oznacza dla opóźnienia?
4. Po co CRC w dekoderze SCL?
5. Dlaczego w 5G kody polarne używane są w kanałach sterujących, a LDPC w kanałach danych?

<details>
<summary>Odpowiedzi</summary>

1. Krok 1: $z^- = 0\text{,}75$, $z^+ = 0\text{,}25$. Krok 2: z 0,75 → 0,9375 i 0,5625; z 0,25 → 0,4375 i 0,0625. Najlepsze: 0,0625 i 0,4375 (kanały „++” i „+−”)
2. $\tfrac N2\log_2N = 512\cdot 10 = 5120$
3. Decyzja o bicie $u_i$ wymaga decyzji o wszystkich bitach $u_1 \ldots u_{i-1}$ (funkcja $g$ zależy od wcześniejszych decyzji) — opóźnienie rośnie z $N$; stąd uproszczenia (rozpoznawanie węzłów z samymi zamrożonymi lub informacyjnymi bitami)
4. Lista zawiera kilka kandydatów; najbardziej prawdopodobny według metryki nie zawsze jest poprawny — CRC wskazuje kandydata, który jest prawidłowym słowem, co daje duży zysk dla krótkich bloków (kosztem kilku bitów)
5. Wiadomości sterujące są krótkie (dziesiątki–setki bitów), gdzie SCL + CRC jest bardzo dobry i daje też wykrywanie błędów; dane mają długie bloki i wysokie przepływności — LDPC ma tam lepsze właściwości i dekodowanie bardzo równoległe (wysoka przepustowość, HARQ z nadmiarowością przyrostową)
</details>

## Źródła

- [MIT 6.451 Principles of Digital Communication II](https://ocw.mit.edu/courses/6-451-principles-of-digital-communication-ii-spring-2005/) — podstawy teorii kodów i kanałów
- [NVIDIA Sionna (GitHub)](https://github.com/NVlabs/sionna) — kody polarne 5G NR (SC, SCL, konstrukcja 5G)
- 3GPP TS 38.212 — *NR; Multiplexing and channel coding* (specyfikacja) — kody polarne w 5G
- W. Ryan, S. Lin — *Channel Codes: Classical and Modern* (płatna)
