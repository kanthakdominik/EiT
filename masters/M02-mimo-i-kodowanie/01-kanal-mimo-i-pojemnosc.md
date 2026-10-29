# M02.01 — Kanał MIMO i jego pojemność

## Po co to jest

Wi-Fi z kilkoma antenami, LTE 4 × 4, 5G z 64 antenami stacji bazowej — wiele anten po obu stronach łącza pozwala przesyłać kilka strumieni danych w tym samym paśmie i czasie. Teoria pojemności MIMO mówi, ile można zyskać (w bogatym środowisku rozproszeń pojemność rośnie liniowo z liczbą anten), od czego to zależy (rząd i uwarunkowanie kanału, SNR, wiedza o kanale) i jak osiągnąć granicę (kanały własne z SVD, rozlewanie mocy).

## Teoria w pigułce

### Model

$$\mathbf y = \mathbf H\mathbf x + \mathbf w, \qquad \mathbf H \in \mathbb C^{n_r\times n_t}, \quad \mathbf w \sim \mathcal{CN}(\mathbf 0, N_0\mathbf I)$$

Element $h_{ij}$ — zespolone wzmocnienie między anteną nadawczą $j$ a odbiorczą $i$ (kanał płaski, np. jedna podnośna OFDM). W środowisku z wieloma rozproszeniami i antenami odległymi o ≥ λ/2 elementy są w przybliżeniu niezależne $\mathcal{CN}(0, 1)$ (Rayleigh i.i.d.).

### Pojemność

**Kanał nieznany u nadajnika** (moc $P$ dzielona równo):

$$C = \log_2\det\left(\mathbf I_{n_r} + \frac{\mathrm{SNR}}{n_t}\mathbf H\mathbf H^H\right) = \sum_i\log_2\left(1 + \frac{\mathrm{SNR}}{n_t}\lambda_i\right)\ \text{[b/s/Hz]}$$

$\lambda_i$ — wartości własne $\mathbf H\mathbf H^H$ (kwadraty wartości osobliwych $\mathbf H$).

**Kanał znany u nadajnika:** SVD $\mathbf H = \mathbf U\boldsymbol\Sigma\mathbf V^H$; prekodowanie $\mathbf x = \mathbf V\tilde{\mathbf x}$ i filtracja $\tilde{\mathbf y} = \mathbf U^H\mathbf y$ dają **równoległe kanały skalarne** $\tilde y_i = \sigma_i\tilde x_i + \tilde w_i$. Optymalny podział mocy — **rozlewanie (water-filling)**: $p_i = \left(\mu - N_0/\sigma_i^2\right)^+$, $\sum p_i = P$. Przy niskim SNR cała moc idzie do najsilniejszego kanału (kształtowanie wiązki), przy wysokim — prawie równo.

### Wnioski

- **Zysk multipleksacji:** przy wysokim SNR $C \approx \min(n_t, n_r)\log_2\mathrm{SNR}$ — nachylenie (stopnie swobody) równe rzędowi kanału.
- **Kanał o małym rzędzie** (widoczność bezpośrednia bez rozproszeń, anteny blisko siebie, efekt „keyhole”) — zysk znika; liczy się rozrzut wartości osobliwych, nie liczba anten.
- **Pojemność ergodyczna** (średnia po realizacjach kanału — długie kodowanie przez wiele zaników) vs **pojemność przerwy** $C_\epsilon$ (kanał wolnozmienny: przepływność osiągana z prawdopodobieństwem $1 - \epsilon$).
- Przy niskim SNR zysk z wielu anten odbiorczych to głównie zysk mocy (macierz anten zbiera więcej energii).

## Przykład rozwiązany

**Pojemność ergodyczna kanału Rayleigha i.i.d.** (wynik symulacji):

| SNR | 1 × 1 | 2 × 2 | 4 × 4 | 8 × 8 |
|---|---|---|---|---|
| 10 dB | 2,9 | 5,5 | 11,0 | 21,8 b/s/Hz |
| 20 dB | 5,9 | 11,3 | 22,1 | 43,9 b/s/Hz |
| 30 dB | 9,1 | 17,8 | 34,9 | 69,2 b/s/Hz |

Pojemność rośnie praktycznie liniowo z liczbą anten. Dla 1 × 1 zaniki kosztują ok. 0,8 b/s/Hz przy 20 dB względem kanału AWGN (6,66 b/s/Hz).

**Kanał 2 × 2** $\mathbf H = \begin{bmatrix} 1 & 0\text{,}4 \\ 0\text{,}2 & 0\text{,}6\end{bmatrix}$: wartości osobliwe 1,167 i 0,446 ($\lambda$ = 1,361 i 0,199). Przy $P/N_0 = 5$ rozlewanie daje moce 4,65 i 0,35 i pojemność 2,97 b/s/Hz wobec 2,72 przy równym podziale; przy $P/N_0 = 0\text{,}5$ — cała moc w jeden kanał (0,75 vs 0,49 b/s/Hz); przy $P/N_0 = 50$ różnica znika (7,72 vs 7,71).

## Typowe pułapki

- **Liczenie zysku z liczby anten bez sprawdzenia rzędu kanału** — w linii widzenia z bliskimi antenami $\mathbf H$ jest prawie rzędu 1.
- **Mylenie SNR na antenę i całkowitego** — we wzorze moc całkowita $P$ jest dzielona na $n_t$ anten.
- **Pojemność ergodyczna jako przepływność dla wolnego kanału** — przy statycznym kanale liczy się prawdopodobieństwo przerwy.
- **Założenie idealnej wiedzy o kanale** — estymacja kosztuje piloty (narzut rośnie z $n_t$) i daje błędy; ograniczenie Massive MIMO (temat 05).
- **Korelacja anten** (za mały odstęp, mały rozrzut kątowy) — mniejsze wartości osobliwe niż w modelu i.i.d.

## Ćwiczenie komputerowe

Pojemność ergodyczna MIMO i rozlewanie mocy dla konkretnego kanału:

```python
import numpy as np

rng = np.random.default_rng(0)
def ergodic_capacity(nt, nr, snr_db, trials=5000):
    snr = 10**(snr_db/10)
    H = (rng.normal(size=(trials, nr, nt)) + 1j*rng.normal(size=(trials, nr, nt)))/np.sqrt(2)
    G = np.eye(nr) + snr/nt*H @ np.conj(np.transpose(H, (0, 2, 1)))     # moc równo między anteny (bez CSI u nadajnika)
    return np.mean(np.log2(np.real(np.linalg.det(G))))

for snr_db in (10, 20, 30):
    caps = {f"{n}×{n}": ergodic_capacity(n, n, snr_db) for n in (1, 2, 4, 8)}
    print(f"SNR {snr_db} dB: " + ", ".join(f"{k}: {v:5.1f} b/s/Hz" for k, v in caps.items()))
print(f"(AWGN SISO przy 20 dB: {np.log2(1 + 100):.2f} b/s/Hz)")

# konkretny kanał 2×2: SVD i rozlewanie mocy (water-filling) przy znajomości kanału u nadajnika
H = np.array([[1.0, 0.4], [0.2, 0.6]])
U, s, Vh = np.linalg.svd(H)
print("wartości osobliwe:", np.round(s, 4), "→ wzmocnienia kanałów własnych λ = σ²:", np.round(s**2, 4))

def waterfill(gains, P, N0=1.0):
    g = np.sort(gains)[::-1]
    for k in range(len(g), 0, -1):
        mu = (P + np.sum(N0/g[:k]))/k
        p = mu - N0/g[:k]
        if p[-1] > 0:
            return np.concatenate([p, np.zeros(len(g) - k)]), mu
for P in (0.5, 5, 50):
    p, mu = waterfill(s**2, P)
    C_wf = np.sum(np.log2(1 + p*np.sort(s**2)[::-1]))
    C_eq = np.sum(np.log2(1 + P/2*s**2))
    print(f"P = {P:4}: moce {np.round(p, 3)}, C(water-filling) = {C_wf:.3f}, C(równy podział) = {C_eq:.3f} b/s/Hz")
```

## Zadania

1. Kanał $\mathbf H = \mathrm{diag}(2, 1)$, $P/N_0 = 2$. Policz pojemność przy równym podziale mocy i przy rozlewaniu.
2. Ile stopni swobody ma kanał 4 × 2? A 4 × 4 o rzędzie 2?
3. Dlaczego przy niskim SNR optymalne jest skupienie mocy w jednym kanale własnym?
4. Anteny terminala są odległe o λ/10. Czego spodziewasz się po wartościach osobliwych kanału?
5. Kanał 2 × 2 o wartościach własnych $\mathbf H\mathbf H^H$ równych 4 i 1, SNR = 10 (moc całkowita). Pojemność przy równym podziale?

<details>
<summary>Odpowiedzi</summary>

1. $\lambda = 4, 1$. Równo: $\log_2(1 + 4) + \log_2(1 + 1) = 3\text{,}32$. Rozlewanie: $p_i = \mu - 1/\lambda_i$, $2\mu - 1\text{,}25 = 2$ → $\mu = 1\text{,}625$, $p = 1\text{,}375$ i $0\text{,}625$ → $\log_2(1 + 5\text{,}5) + \log_2(1\text{,}625) = 2\text{,}70 + 0\text{,}70 = 3\text{,}40$ b/s/Hz
2. 2; 2
3. Przy niskim SNR $\log_2(1 + x) \approx x\log_2e$ — liniowe w mocy, więc zysk z każdej jednostki mocy jest proporcjonalny do $\lambda_i$; opłaca się wszystko oddać kanałowi o największym $\lambda$ (kształtowanie wiązki)
4. Silna korelacja: jedna duża wartość osobliwa i druga bardzo mała — kanał praktycznie rzędu 1, brak zysku multipleksacji (zostaje zysk mocy/kształtowania wiązki)
5. $\log_2(1 + 5\cdot 4) + \log_2(1 + 5\cdot 1) = 4\text{,}39 + 2\text{,}58 = 6\text{,}98$ b/s/Hz
</details>

## Źródła

- [D. Tse, P. Viswanath — Fundamentals of Wireless Communication](https://web.stanford.edu/~dntse/wireless_book.html) — rozdziały 7–8 (MIMO)
- [MIT 6.450 Principles of Digital Communication I](https://ocw.mit.edu/courses/6-450-principles-of-digital-communications-i-fall-2006/)
- [13.08 Kanał radiowy i systemy](../../modules/13-telekomunikacja/08-kanal-radiowy-i-systemy.md)
