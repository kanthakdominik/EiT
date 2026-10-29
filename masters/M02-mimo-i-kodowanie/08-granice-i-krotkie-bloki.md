# M02.08 — Granice kodowania, krótkie bloki i HARQ

## Po co to jest

Twierdzenie Shannona mówi, ile da się przesłać przy nieskończenie długich blokach. Systemy rzeczywiste mają bloki od kilkudziesięciu bitów (sterowanie, IoT, komunikacja o niskim opóźnieniu URLLC) do kilku tysięcy — i dla nich granica jest wyraźnie niższa. Znajomość granic pozwala ocenić, ile jeszcze można zyskać lepszym kodem, a ile ogranicza sama długość bloku. HARQ (hybrydowe automatyczne powtarzanie) łączy kodowanie z retransmisjami i adaptuje się do kanału, którego nie znamy dokładnie.

## Teoria w pigułce

### Granice Shannona

- **AWGN, wejście gaussowskie:** $C = \tfrac12\log_2(1 + \mathrm{SNR})$ b/wymiar rzeczywisty; wymagane $\dfrac{E_b}{N_0} \geq \dfrac{2^{2R} - 1}{2R}$; przy $R \to 0$: $\ln 2$ = **−1,59 dB**.
- **Wejście BPSK** (kanał binarny z szumem gaussowskim): pojemność liczona całką, nasyca się przy 1 b/symbol. Dla $R = 1/2$: min. $E_b/N_0$ = 0,19 dB (wejście gaussowskie: 0 dB).
- Wysokie sprawności z małą konstelacją są drogie: dla $R = 0\text{,}9$ BPSK wymaga 3,2 dB, a wejście gaussowskie — 1,4 dB; stąd modulacje wyższego rzędu z kodowaniem (BICM) i kształtowanie konstelacji (probabilistic shaping).

### Skończona długość bloku

Aproksymacja normalna (Polyanskiy, Poor, Verdú, 2010): największa sprawność przy długości $n$ i prawdopodobieństwie błędu ramki $\varepsilon$:

$$R^*(n, \varepsilon) \approx C - \sqrt{\frac{V}{n}}\,Q^{-1}(\varepsilon) + \frac{\log_2n}{2n}$$

$V$ — dyspersja kanału (dla AWGN: $V = \dfrac{\mathrm{SNR}(\mathrm{SNR} + 2)}{2(\mathrm{SNR} + 1)^2}\log_2^2e$). Strata rośnie jak $1/\sqrt n$ — dla bloków 100-symbolowych sprawność spada prawie o połowę względem pojemności.

### HARQ

- **ARQ:** retransmisja ramki z błędem (wykrytym przez CRC).
- **HARQ typu I / łączenie Chase'a:** retransmisja tej samej ramki, odbiornik sumuje LLR (zysk SNR).
- **HARQ z nadmiarowością przyrostową (IR):** każda retransmisja niesie nowe bity parzystości (wersje nadmiarowości) — kod „staje się” coraz silniejszy (niższa sprawność), dopóki dekodowanie się nie powiedzie. LDPC 5G zaprojektowano z myślą o IR (graf bazowy z rozszerzeniem).
- Efekt: przepływność bliska pojemności chwilowej kanału bez dokładnej znajomości SNR, kosztem opóźnienia.
- **Adaptacja modulacji i kodowania** (AMC, tablice MCS) na podstawie raportów o kanale + HARQ jako „poprawka”.

## Przykład rozwiązany

**Minimalne $E_b/N_0$** (obliczenie numeryczne):

| Sprawność $R$ | Wejście BPSK | Wejście gaussowskie |
|---|---|---|
| 1/3 | −0,50 dB | −0,55 dB |
| 1/2 | 0,19 dB | 0,00 dB |
| 3/4 | 1,63 dB | 0,86 dB |
| 0,9 | 3,20 dB | 1,40 dB |

**Krótkie bloki:** SNR 0 dB (pojemność 0,5 b/symbol), FER $10^{-3}$:

| $n$ | 100 | 500 | 2000 | 10 000 |
|---|---|---|---|---|
| $R^*$ [b/symbol] | 0,26 | 0,39 | 0,44 | 0,47 |

Kod LDPC z tematu 06 ($n = 1200$, $R = 1/2$, FER ok. 0,03 przy 2 dB) i kod polarny z tematu 07 ($n = 256$) można porównać z tymi granicami — dla krótkich kodów rzeczywista „luka do Shannona” jest mniejsza, niż sugeruje porównanie z pojemnością.

## Typowe pułapki

- **Porównanie krótkiego kodu z granicą dla nieskończonej długości** — myląca „strata 2 dB”, z której większość jest nieunikniona.
- **Mylenie $E_s/N_0$, $E_b/N_0$ i SNR** przy porównywaniu systemów o różnej sprawności i modulacji.
- **Pomijanie narzutu** (CRC, piloty, nagłówki) w efektywności widmowej.
- **HARQ bez limitu retransmisji** — rosnące opóźnienie; w URLLC liczy się niezawodność w zadanym czasie.
- **Ocena kodu przy jednym SNR** — interesuje cały wodospad i podłoga błędów.

## Ćwiczenie komputerowe

Granice Shannona dla BPSK i wejścia gaussowskiego oraz aproksymacja normalna dla krótkich bloków:

```python
import numpy as np
from scipy.stats import norm

# pojemność kanału AWGN z wejściem BPSK (całka numeryczna) i bez ograniczenia wejścia
y = np.linspace(-30, 30, 60_001)
def C_bpsk(snr):                                   # snr = Es/N0, szum o wariancji 1/(2·snr)
    s2 = 1/(2*snr)
    p = lambda m: np.exp(-(y - m)**2/(2*s2))/np.sqrt(2*np.pi*s2)
    p1, p0 = p(1), p(-1)
    f = p1*np.log2(2*p1/(p1 + p0 + 1e-300) + 1e-300)
    return np.trapezoid(f, y)

def min_ebn0(R, cap):
    lo, hi = 1e-3, 100.0
    for _ in range(80):                            # bisekcja po Es/N0: szukamy C(snr) = R
        mid = np.sqrt(lo*hi)
        lo, hi = (mid, hi) if cap(mid) < R else (lo, mid)
    return 10*np.log10(hi/R)                       # Eb/N0 = Es/N0 / R

for R in (1/3, 1/2, 3/4, 0.9):
    print(f"R = {R:.3f}: min Eb/N0 — wejście BPSK {min_ebn0(R, C_bpsk):5.2f} dB, wejście gaussowskie "
          f"{10*np.log10((2**(2*R) - 1)/(2*R)):5.2f} dB")
print(f"granica dla R → 0: {10*np.log10(np.log(2)):.2f} dB")

# aproksymacja normalna dla krótkich bloków (Polyanskiy–Poor–Verdú), kanał AWGN rzeczywisty z wejściem gaussowskim
def max_rate(snr, n, eps):
    C = 0.5*np.log2(1 + snr)
    V = snr*(snr + 2)/(2*(snr + 1)**2)*np.log2(np.e)**2
    return C - np.sqrt(V/n)*norm.isf(eps) + np.log2(n)/(2*n)

snr = 10**(0/10)
for n in (100, 500, 2000, 10_000):
    print(f"SNR 0 dB, FER 1e-3: n = {n:6d} → maks. sprawność ≈ {max_rate(snr, n, 1e-3):.3f} b/symbol "
          f"(pojemność {0.5*np.log2(1 + snr):.3f})")
```

## Zadania

1. Jakie jest minimalne $E_b/N_0$ dla sprawności 2 b/s/Hz (wejście gaussowskie, kanał zespolony: $C = \log_2(1 + \mathrm{SNR})$)?
2. Ile wynosi pojemność kanału BPSK przy bardzo wysokim SNR i dlaczego?
3. O ile spada maksymalna sprawność dla $n = 400$ w porównaniu z $n = 100$ (strata $\propto 1/\sqrt n$)?
4. Dlaczego HARQ z nadmiarowością przyrostową jest lepszy od łączenia Chase'a przy dużym niedopasowaniu SNR?
5. Kod pracuje 1,2 dB od granicy dla swojej długości bloku. Co bardziej się opłaca: lepszy kod czy dłuższy blok?

<details>
<summary>Odpowiedzi</summary>

1. $\mathrm{SNR} = 2^2 - 1 = 3$; $E_b/N_0 = \mathrm{SNR}/R = 3/2$ → 1,76 dB
2. 1 b/symbol — wejście binarne niesie co najwyżej 1 bit niezależnie od SNR
3. Strata względem pojemności maleje 2 razy (z ok. 0,24 do ok. 0,12 b/symbol przy SNR 0 dB i FER $10^{-3}$)
4. Chase dodaje tylko energię (SNR rośnie 3 dB z każdą kopią), a IR obniża sprawność kodu (dodaje nowe bity parzystości) — przy dużym niedopasowaniu zysk z obniżenia sprawności jest znacznie większy niż z samego zwiększenia energii
5. Zależy od wymagań opóźnienia: jeśli dopuszczalny jest dłuższy blok, granica dla dłuższego bloku jest bliżej pojemności; jeśli długość jest ustalona (np. sterowanie, URLLC), pozostaje poprawa kodu/dekodera (np. SCL z większą listą) — 1,2 dB to typowa luka, którą da się częściowo odzyskać
</details>

## Źródła

- [MIT 6.451 Principles of Digital Communication II](https://ocw.mit.edu/courses/6-451-principles-of-digital-communication-ii-spring-2005/) — granice Shannona, kody bliskie pojemności
- [MIT 6.450 Principles of Digital Communication I](https://ocw.mit.edu/courses/6-450-principles-of-digital-communications-i-fall-2006/) — teoria informacji
- [13.01 Teoria informacji](../../modules/13-telekomunikacja/01-teoria-informacji.md)
