# 10.03 — Stabilność: Routh, Nyquist, zapasy

## Po co to jest

Sprzężenie zwrotne może zdestabilizować obiekt sam w sobie stabilny — wzmacniacz zaczyna oscylować, przetwornica „śpiewa”, temperatura faluje. Kryteria stabilności pozwalają to przewidzieć z modelu albo z pomiaru charakterystyki pętli otwartej, a zapasy fazy i wzmocnienia mówią, jak daleko jesteśmy od granicy.

## Teoria w pigułce

### Definicja

Układ liniowy jest stabilny (BIBO), gdy wszystkie bieguny układu zamkniętego leżą w lewej półpłaszczyźnie: $\text{Re}(s_i) < 0$. Bieguny układu zamkniętego to pierwiastki **równania charakterystycznego** $1 + L(s) = 0$.

### Kryterium Routha–Hurwitza

Pozwala sprawdzić znaki pierwiastków wielomianu bez ich liczenia — i znaleźć zakres parametru (np. wzmocnienia) dającego stabilność.

Dla $a_3s^3 + a_2s^2 + a_1s + a_0$: stabilny ⇔ wszystkie $a_i > 0$ i $a_2a_1 > a_3a_0$.

Warunek konieczny dla każdego rzędu: wszystkie współczynniki tego samego znaku i niezerowe. Pełna tablica Routha: liczba zmian znaku w pierwszej kolumnie = liczba pierwiastków w prawej półpłaszczyźnie.

### Kryterium Nyquista

Wykres $L(j\omega)$ na płaszczyźnie zespolonej dla $\omega$ od $-\infty$ do $\infty$. Liczba biegunów układu zamkniętego w prawej półpłaszczyźnie:

$$Z = N + P$$

$N$ — liczba okrążeń punktu $-1$ zgodnie z ruchem wskazówek zegara, $P$ — liczba niestabilnych biegunów pętli otwartej. Dla stabilnej pętli otwartej ($P = 0$): **układ zamknięty stabilny, gdy wykres nie obejmuje punktu −1**.

Zaleta: działa z **pomiaru** charakterystyki częstotliwościowej i z opóźnieniem ($e^{-Ls}$ — wielomianowe kryteria tego nie obsłużą).

### Zapasy stabilności

| Zapas | Definicja | Typowe wymaganie |
|---|---|---|
| **Zapas fazy (PM)** | $180° + \arg L(j\omega_c)$, gdzie $\lvert L(j\omega_c)\rvert = 1$ | 45–60° |
| **Zapas wzmocnienia (GM)** | $-20\log\lvert L(j\omega_{180})\rvert$, gdzie $\arg L = -180°$ | ≥ 6–10 dB |
| Zapas modułu | $\min\lvert 1 + L(j\omega)\rvert = 1/\max\lvert S\rvert$ | ≥ 0,5 ($\lvert S\rvert _{max} \leq 2$, czyli 6 dB) |

**Zapas fazy a tłumienie:** dla typowej pętli $\zeta \approx PM/100$ (PM w stopniach, dla PM < ok. 60°). PM = 45° → ok. 20% przeregulowania, PM = 60° → ok. 10% (reguła przybliżona, wyprowadzona dla pętli drugiego rzędu).

**Opóźnienie** $e^{-Ls}$ ma moduł 1 i fazę $-\omega L$: zmniejsza zapas fazy o $\omega_cL$ (w radianach). Maksymalne dopuszczalne opóźnienie: $L_{max} = PM/\omega_c$.

## Przykład rozwiązany

$L(s) = \dfrac{K}{(s+1)^3}$, ujemne sprzężenie zwrotne.

1. **Routh:** $s^3 + 3s^2 + 3s + (1 + K) = 0$ → $3\cdot 3 > 1 + K$ → **$K < 8$**.
2. Na granicy ($K = 8$) para biegunów na osi urojonej: $3s^2 + 9 = 0$ → $\omega = \sqrt 3$ rad/s — częstotliwość oscylacji.
3. **Z charakterystyki:** $\arg L = -3\arctan\omega = -180°$ → $\omega_{180} = \sqrt 3$; $|L(j\sqrt 3)| = K/8$. Dla $K = 4$: GM = $20\log 2 = 6\text{,}02$ dB.
4. Pulsacja odcięcia dla $K = 4$: $(1 + \omega^2)^{3/2} = 4$ → $\omega_c = 1\text{,}233$ rad/s; faza $-3\arctan 1\text{,}233 = -152\text{,}9°$ → **PM ≈ 27°** — mało, spodziewaj się dużego przeregulowania (ok. 54% według symulacji).
5. Dopuszczalne dodatkowe opóźnienie: $0\text{,}473\ \text{rad}/1\text{,}233 \approx 0\text{,}38$ s.

## Typowe pułapki

- **Stabilność oceniana z biegunów pętli otwartej** zamiast zamkniętej.
- **Odczyt zapasu fazy przy kilku przecięciach 0 dB** — liczy się najgorszy przypadek; przy takich układach używaj Nyquista lub zapasu modułu.
- **Pominięcie opóźnień** (czas obliczeń, próbkowanie, filtr czujnika) — rzeczywisty zapas fazy mniejszy niż w modelu.
- **Pętla otwarta niestabilna** ($P \neq 0$) — wtedy wykres *musi* okrążać −1, i to odpowiednią liczbę razy.
- **GM i PM spełnione, ale wykres przechodzi blisko −1 „pomiędzy”** — sprawdź $|S|_{max}$.

## Ćwiczenie komputerowe

Bode i Nyquist pętli $K/(s+1)^3$ z automatycznym odczytem zapasów:

```python
import numpy as np
from scipy import signal
import matplotlib.pyplot as plt

def margins(num, den, w=np.logspace(-2, 2, 100001)):
    _, H = signal.freqresp((num, den), w)
    mag, ph = np.abs(H), np.unwrap(np.angle(H))
    i180 = np.argmin(abs(ph + np.pi))
    cross = np.where((mag[:-1] > 1) & (mag[1:] <= 1))[0]          # przecięcie 0 dB z góry
    if len(cross): ic = cross[0]; wc, pm = w[ic], 180 + np.degrees(ph[ic])
    else: wc, pm = np.nan, np.inf                                  # |L| nigdy nie przekracza 1
    return wc, pm, w[i180], -20*np.log10(mag[i180]), 1/np.min(abs(1 + H))

den = np.poly([-1, -1, -1])
for K in [1, 4, 7]:
    wc, pm, w180, gm, Smax = margins([K], den)
    print(f"K={K}: wc={wc:.3f}, PM={pm:5.1f} deg, w180={w180:.3f}, GM={gm:5.2f} dB, |S|max={Smax:.2f}")
print("bieguny zamknięte K=4:", np.roots(np.polyadd(den, [4])).round(3))

w = np.logspace(-2, 2, 2000)
_, H = signal.freqresp(([4], den), w)
plt.plot(H.real, H.imag, label='ω>0'); plt.plot(H.real, -H.imag, '--', label='ω<0')
plt.plot(-1, 0, 'rx', ms=10); plt.axis('equal'); plt.grid(); plt.legend()
plt.title('Nyquist, K=4'); plt.show()
```

## Zadania

1. Zakres $K$ stabilności dla $L(s) = \dfrac{K}{(s+1)^3}$ i częstotliwość oscylacji na granicy.
2. Zapasy fazy i wzmocnienia dla $K = 1$ i $K = 4$.
3. Pętla ma $\omega_c = 100$ rad/s i PM = 50°. Jakie maksymalne opóźnienie toleruje?
4. Równanie charakterystyczne $s^3 + 2s^2 + 4s + K = 0$. Zakres stabilności?
5. Dlaczego kryterium Nyquista jest użyteczne dla wzmacniacza, którego model nie jest znany dokładnie?

<details>
<summary>Odpowiedzi</summary>

1. $0 < K < 8$ (ogólniej $-1 < K < 8$); $\omega = \sqrt 3 \approx 1\text{,}73$ rad/s
2. $K = 1$: $|L(j\omega)| < 1$ dla wszystkich $\omega > 0$ — brak przecięcia 0 dB, PM nieskończony, GM = 18,06 dB; $K = 4$: PM ≈ 27°, GM ≈ 6,02 dB
3. $0\text{,}873/100 \approx 8\text{,}7$ ms
4. $0 < K < 8$
5. Charakterystykę pętli otwartej można zmierzyć (analizator, wstrzyknięcie sygnału — [08.04](../08-miernictwo/04-generatory-i-analizatory.md)) i zastosować kryterium bezpośrednio do pomiaru
</details>

## Źródła

- [Feedback Systems — Åström, Murray](https://www.cds.caltech.edu/~murray/amwiki/Second_Edition.html) — rozdział 10 (kryterium Nyquista, zapasy stabilności)
- [MIT 6.302 Feedback Systems](https://ocw.mit.edu/courses/6-302-feedback-systems-spring-2007/) — stabilność wzmacniaczy, kompensacja
- [Brian Douglas — Control Systems Lectures](https://www.youtube.com/results?search_query=Brian+Douglas+Control+System+Lectures) — Nyquist, zapasy fazy i wzmocnienia
- Powiązane: [04.06 Sprzężenie zwrotne i stabilność wzmacniaczy](../04-uklady-analogowe/06-sprzezenie-zwrotne-i-stabilnosc.md)
