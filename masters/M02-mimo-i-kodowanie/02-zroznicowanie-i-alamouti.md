# M02.02 — Zróżnicowanie: MRC i kody czasoprzestrzenne

## Po co to jest

W kanale z zanikami Rayleigha pojedyncza antena ma „dziury” sygnału: BER maleje tylko jak $1/\mathrm{SNR}$ — dla $10^{-5}$ trzeba ok. 44 dB zamiast 9,6 dB w kanale AWGN. **Zróżnicowanie** (diversity) — wiele niezależnie zanikających kopii sygnału — sprawia, że głęboki zanik wszystkich naraz jest mało prawdopodobny. Daje to zysk liczony w dziesiątkach decybeli i jest podstawą niezawodności łączy bezprzewodowych: od odbiorników z dwiema antenami po kody czasoprzestrzenne w nadajniku.

## Teoria w pigułce

### Rząd zróżnicowania

$$P_e \propto \mathrm{SNR}^{-d}\ \text{(przy wysokim SNR)}$$

$d$ — rząd zróżnicowania: nachylenie krzywej BER na wykresie log–log. Źródła: anteny (przestrzeń), częstotliwość (OFDM + kodowanie, rozpraszanie widma), czas (przeplot + kodowanie), polaryzacja.

### Zróżnicowanie odbiorcze: MRC

$L$ anten odbiorczych, $y_\ell = h_\ell s + w_\ell$. **Łączenie z maksymalnym stosunkiem** (MRC): $z = \sum_\ell h_\ell^*y_\ell$ — każda gałąź ważona swoim wzmocnieniem (filtr dopasowany w przestrzeni). SNR po łączeniu $= \mathrm{SNR}\sum\lvert h_\ell\rvert^2$:

- **Zysk szyku:** średni SNR rośnie $L$ razy.
- **Zysk zróżnicowania:** $d = L$.
- BER BPSK dla Rayleigha: $P_b = \left(\tfrac{1 - \mu}{2}\right)^L\sum_{k=0}^{L-1}\binom{L - 1 + k}{k}\left(\tfrac{1 + \mu}{2}\right)^k$, $\mu = \sqrt{\tfrac{\bar\gamma}{1 + \bar\gamma}}$.
- Prostsze: wybór najlepszej gałęzi (selection combining), łączenie równozyskowe (EGC).

### Zróżnicowanie nadawcze: schemat Alamoutiego

Dwie anteny nadawcze, dwa symbole w dwóch chwilach:

| | Antena 1 | Antena 2 |
|---|---|---|
| Chwila 1 | $s_1$ | $s_2$ |
| Chwila 2 | $-s_2^*$ | $s_1^*$ |

Przy kanale stałym przez dwie chwile odbiornik liniowymi operacjami odzyskuje $s_1$ i $s_2$ osobno, z SNR proporcjonalnym do $\lvert h_1\rvert^2 + \lvert h_2\rvert^2$:

- $d = 2$ (z jedną anteną odbiorczą), pełna szybkość (1 symbol na chwilę), **bez wiedzy o kanale u nadajnika**.
- Moc dzielona na 2 anteny → 3 dB gorzej niż MRC z dwiema antenami odbiorczymi (brak zysku szyku u nadajnika).
- Ortogonalne kody czasoprzestrzenne dla > 2 anten nie mają pełnej szybkości przy sygnałach zespolonych.
- W LTE: SFBC (blokowy kod przestrzenno-częstotliwościowy) — ta sama idea na sąsiednich podnośnych.

### Kompromis zróżnicowanie–multipleksacja

Kanał $n_t \times n_r$ daje maksymalnie $d = n_tn_r$ albo $\min(n_t, n_r)$ strumieni — nie oba naraz (Zheng–Tse). Schemat wybiera się według potrzeby: niezawodność (Alamouti, kształtowanie wiązki) albo przepływność (multipleksacja, temat 03).

## Przykład rozwiązany

**BER BPSK w kanale Rayleigha** (symulacja i teoria):

| $E_b/N_0$ | 1 antena | MRC 2 | MRC 4 | Alamouti 2 × 1 |
|---|---|---|---|---|
| 10 dB | $2\text{,}3\cdot 10^{-2}$ | $1\text{,}6\cdot 10^{-3}$ | $9\text{,}7\cdot 10^{-6}$ | $5\text{,}5\cdot 10^{-3}$ |
| 20 dB | $2\text{,}5\cdot 10^{-3}$ | $1\text{,}8\cdot 10^{-5}$ | $1\text{,}3\cdot 10^{-9}$ | $7\text{,}3\cdot 10^{-5}$ |

Przy +10 dB BER jednej anteny spada 10 razy, MRC 2 — 100 razy, MRC 4 — ok. 10 000 razy: rząd zróżnicowania $d = 1, 2, 4$. Alamouti ma ten sam rząd co MRC 2, ale jest przesunięty o 3 dB (krzywa MRC 2 dla $E_b/N_0$ o 3 dB niższego).

## Typowe pułapki

- **Anteny za blisko** (< λ/2) lub mały rozrzut kątowy — zaniki skorelowane, zysk zróżnicowania znika.
- **Mylenie zysku szyku (przesunięcie krzywej) z zyskiem zróżnicowania (nachylenie).**
- **Alamouti w kanale szybkozmiennym** — kanał zmienia się między chwilami, ortogonalność się psuje (zakłócenia między symbolami).
- **Brak przeplotu przy kodowaniu w czasie** — kod nie dostaje niezależnych zaników, zysk zróżnicowania czasowego znika.
- **Porównanie przy różnych mocach całkowitych** — Alamouti wymaga podziału mocy.

## Ćwiczenie komputerowe

BER BPSK z MRC (1, 2, 4 anteny) i schematem Alamoutiego — symulacja i teoria:

```python
import numpy as np
from math import comb

rng = np.random.default_rng(1)
def ber_mrc_theory(EbN0, L):
    mu = np.sqrt(EbN0/(1 + EbN0))
    return ((1 - mu)/2)**L*sum(comb(L - 1 + k, k)*((1 + mu)/2)**k for k in range(L))

n = 400_000
for EbN0_db in (10, 20):
    g = 10**(EbN0_db/10)
    bits = rng.integers(0, 2, n); s = 1 - 2*bits                          # BPSK
    out = []
    for L in (1, 2, 4):                                                    # MRC z L antenami odbiorczymi
        h = (rng.normal(size=(L, n)) + 1j*rng.normal(size=(L, n)))/np.sqrt(2)
        w = (rng.normal(size=(L, n)) + 1j*rng.normal(size=(L, n)))*np.sqrt(1/(2*g))
        y = h*s + w
        z = np.real(np.sum(np.conj(h)*y, axis=0))
        out.append(f"MRC {L}: {np.mean((z < 0) != bits):.2e} (teoria {ber_mrc_theory(g, L):.2e})")
    # Alamouti 2×1: dwa symbole w dwóch chwilach, moc dzielona na 2 anteny
    s1, s2 = s[0::2], s[1::2]; m = len(s1)
    h1 = (rng.normal(size=m) + 1j*rng.normal(size=m))/np.sqrt(2)
    h2 = (rng.normal(size=m) + 1j*rng.normal(size=m))/np.sqrt(2)
    nz = lambda: (rng.normal(size=m) + 1j*rng.normal(size=m))*np.sqrt(1/(2*g))
    r1 = (h1*s1 + h2*s2)/np.sqrt(2) + nz()
    r2 = (-h1*np.conj(s2) + h2*np.conj(s1))/np.sqrt(2) + nz()
    e1 = np.real(np.conj(h1)*r1 + h2*np.conj(r2)); e2 = np.real(np.conj(h2)*r1 - h1*np.conj(r2))
    dec = np.empty(n); dec[0::2], dec[1::2] = e1, e2
    out.append(f"Alamouti 2×1: {np.mean((dec < 0) != bits):.2e} (teoria ≈ MRC 2 z SNR −3 dB: {ber_mrc_theory(g/2, 2):.2e})")
    print(f"Eb/N0 = {EbN0_db} dB | " + " | ".join(out))
```

## Zadania

1. Ile wynosi przybliżony BER BPSK z jedną anteną w kanale Rayleigha przy 30 dB? Wzór: $P_b \approx 1/(4\bar\gamma)$.
2. Odbiornik z dwiema antenami w MRC. Jaki SNR potrzebny dla $10^{-4}$ w porównaniu z jedną anteną? Skorzystaj z kodu.
3. Pokaż, że w schemacie Alamoutiego statystyka $h_1^*r_1 + h_2r_2^*$ zależy tylko od $s_1$.
4. Kod splotowy o odległości swobodnej 5 z idealnym przeplotem w kanale z szybkimi zanikami. Jaki rząd zróżnicowania?
5. Dlaczego w LTE z 2 antenami nadawczymi przy złym kanale używa się SFBC, a przy dobrym — multipleksacji?

<details>
<summary>Odpowiedzi</summary>

1. $\bar\gamma = 1000$ → ok. $2\text{,}5\cdot 10^{-4}$
2. Jedna antena: ok. 34 dB ($1/(4\bar\gamma) = 10^{-4}$); MRC 2: z przybliżenia $P_b \approx 3/(16\bar\gamma^2)$ ok. 16,4 dB — zysk ok. 17,6 dB (rośnie dla mniejszego BER)
3. $h_1^*r_1 + h_2r_2^* = h_1^*(h_1s_1 + h_2s_2) + h_2(-h_1^*s_2 + h_2^*s_1) + \text{szum} = (\lvert h_1\rvert^2 + \lvert h_2\rvert^2)s_1 + \text{szum}$ (pomijając skalowanie $1/\sqrt2$)
4. $d = 5$ (rząd zróżnicowania = odległość swobodna kodu przy idealnym przeplocie i decyzjach miękkich)
5. Przy niskim SNR i silnych zanikach liczy się niezawodność (zróżnicowanie, jeden strumień); przy wysokim SNR i dobrze uwarunkowanym kanale opłaca się wysłać dwa strumienie (podwojona przepływność) — kompromis zróżnicowanie–multipleksacja, wybierany adaptacyjnie na podstawie raportów o kanale (rank indicator)
</details>

## Źródła

- [D. Tse, P. Viswanath — Fundamentals of Wireless Communication](https://web.stanford.edu/~dntse/wireless_book.html) — rozdział 3 (zróżnicowanie)
- [MIT 6.450 Principles of Digital Communication I](https://ocw.mit.edu/courses/6-450-principles-of-digital-communications-i-fall-2006/) — kanały z zanikami
- [13.08 Kanał radiowy i systemy](../../modules/13-telekomunikacja/08-kanal-radiowy-i-systemy.md)
