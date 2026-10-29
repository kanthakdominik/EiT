# 21.08 — Szum wąskopasmowy, obwiednia i procesy punktowe

## Po co to jest

Po filtrze pośredniej częstotliwości odbiornika szum wygląda jak sinusoida o losowo zmieniającej się amplitudzie i fazie. Detektor obwiedni, próg wykrywania w radarze, wskaźnik RSSI, zanik sygnału w kanale wielodrogowym ([13.08](../13-telekomunikacja/08-kanal-radiowy-i-systemy.md)) — wszystko to opisuje rozkład Rayleigha i Rice'a. Druga część tematu dotyczy zdarzeń losowych w czasie: impulsów z licznika promieniowania, fotonów w fotodetektorze, pakietów w sieci ([14.08](../14-sieci-telekomunikacyjne/08-teoria-ruchu-i-bezpieczenstwo.md)) — tu narzędziem jest proces Poissona, z którego wynika też szum śrutowy.

## Teoria w pigułce

### Reprezentacja szumu wąskopasmowego

Szum pasmowy wokół $f_0$ o paśmie $B \ll f_0$:

$$n(t) = n_I(t)\cos 2\pi f_0t - n_Q(t)\sin 2\pi f_0t = r(t)\cos\left(2\pi f_0t + \varphi(t)\right)$$

- $n_I$, $n_Q$ — niezależne, gaussowskie procesy dolnopasmowe (pasmo $B/2$), każdy o wariancji $\sigma^2$ równej wariancji $n(t)$.
- **Obwiednia** $r = \sqrt{n_I^2 + n_Q^2}$ ma **rozkład Rayleigha**: $p(r) = \dfrac{r}{\sigma^2}e^{-r^2/2\sigma^2}$; średnia $\sigma\sqrt{\pi/2}$, $E[r^2] = 2\sigma^2$.
- **Faza** $\varphi$ — jednostajna na $[0, 2\pi)$.
- Obwiednia zmienia się w tempie rzędu $1/B$ — szum po wąskim filtrze „pływa” wolno.

### Sygnał + szum: rozkład Rice'a

Sinusoida o amplitudzie $A$ plus szum wąskopasmowy: obwiednia ma rozkład Rice'a $p(r) = \dfrac{r}{\sigma^2}e^{-(r^2 + A^2)/2\sigma^2}I_0\!\left(\dfrac{Ar}{\sigma^2}\right)$. Dla $A \gg \sigma$ przechodzi w rozkład normalny wokół $A$; dla $A = 0$ — w Rayleigha. Ten sam model opisuje kanał radiowy: składowa bezpośrednia + rozproszone (współczynnik Rice'a $K = A^2/2\sigma^2$).

### Detekcja progowa

Prawdopodobieństwo fałszywego alarmu (sam szum przekracza próg $r_T$):

$$P_{FA} = e^{-r_T^2/2\sigma^2} \quad\Rightarrow\quad r_T = \sigma\sqrt{2\ln(1/P_{FA})}$$

Dla $P_{FA} = 10^{-6}$: $r_T = 5\text{,}26\sigma$. Prawdopodobieństwo wykrycia sygnału — z rozkładu Rice'a (funkcja Marcuma $Q_1$).

### Proces Poissona

Zdarzenia niezależne, ze stałą średnią intensywnością $\lambda$ [1/s]:

- Liczba zdarzeń w czasie $T$: $P(N = k) = \dfrac{(\lambda T)^k}{k!}e^{-\lambda T}$; $E[N] = \mathrm{var}(N) = \lambda T$.
- **Niepewność zliczania:** $\sigma_N = \sqrt N$, względnie $1/\sqrt N$ — 100 zliczeń: 10%, 10 000: 1%.
- Odstępy między zdarzeniami: **rozkład wykładniczy** o średniej $1/\lambda$ (brak pamięci).
- Suma niezależnych procesów Poissona to proces Poissona o sumie intensywności (tło + źródło).
- **Czas martwy** detektora $\tau$ (licznik nie rejestruje zdarzeń przez $\tau$ po każdym impulsie): dla modelu nieparaliżującego rzeczywista częstość $n = \dfrac{m}{1 - m\tau}$, gdzie $m$ — zmierzona.

### Szum śrutowy z procesu Poissona

Prąd jako ciąg impulsów ładunku $q$ przybywających procesem Poissona z częstością $\lambda = I/q$. Z twierdzenia Campbella: wariancja w paśmie $B$ wynosi $2qIB$ — stąd $i_n = \sqrt{2qI}$ ([21.06](06-szum-w-ukladach-elektronicznych.md)). Szum śrutowy jest więc „szumem zliczania” elektronów lub fotonów: przy małych prądach (fotodetektory, liczniki) wyznacza granicę czułości.

## Przykład rozwiązany

**Licznik promieniowania.** Tło: średnio 0,5 zliczenia/s. Pomiar z próbką: 1000 zliczeń/s (zmierzone), czas martwy 100 µs, czas pomiaru 60 s.

1. Korekcja czasu martwego: $n = \dfrac{1000}{1 - 1000\cdot 10^{-4}} = 1111$ zliczeń/s — błąd 10% bez korekcji.
2. Liczba zliczeń w 60 s: ok. 60 000 → niepewność względna $1/\sqrt{60\,000} = 0\text{,}41\%$.
3. Tło w 60 s: 30 zliczeń ± 5,5 — pomijalne przy tym natężeniu, ale przy słabym źródle (np. 2 zliczenia/s) wynik netto $(2 - 0\text{,}5)$ zliczeń/s ma niepewność $\sqrt{(120 + 30)}/60 = 0\text{,}2$ zliczenia/s, czyli 14%; zmniejszenie do 1% wymaga ok. 200 razy dłuższego pomiaru.
4. Prawdopodobieństwo, że w oknie 1 s przy samym tle nie będzie ani jednego zliczenia: $e^{-0\text{,}5} = 61\%$; przy intensywności 5/s: $e^{-5} = 0\text{,}67\%$.

## Typowe pułapki

- **Uśrednianie obwiedni szumu jako jego wartości skutecznej** — średnia obwiedni to $\sigma\sqrt{\pi/2} = 1\text{,}25\sigma$, a nie $\sqrt2\,\sigma$ (detektor średniej obwiedni zaniża moc szumu o 1,05 dB — poprawka w analizatorach widma).
- **Próg ustawiony „na oko”** bez związku z $P_{FA}$ — liczba fałszywych alarmów rośnie z pasmem i czasem obserwacji.
- **Niepewność $\sqrt N$ dla wartości przeliczonej** (zliczenia/s, dawka) — liczy się liczba zarejestrowanych zdarzeń, nie przeliczony wynik.
- **Pominięcie czasu martwego** przy dużych częstościach — wynik nasyca się, a nawet maleje (model paraliżujący).
- **Odejmowanie tła bez propagacji niepewności** — wariancje tła i pomiaru się dodają.

## Ćwiczenie komputerowe

```python
import numpy as np
from scipy import signal, stats

rng = np.random.default_rng(0)
fs, N = 1e6, 2_000_000
# szum wąskopasmowy: biały przez filtr pasmowy 10 kHz wokół 100 kHz
x = rng.normal(0, 1, N)
sos = signal.butter(4, [95e3, 105e3], btype="bandpass", fs=fs, output="sos")
n = signal.sosfilt(sos, x)[10_000:]
sigma = n.std()
r = np.abs(signal.hilbert(n))                       # obwiednia z sygnału analitycznego
print(f"σ = {sigma:.4f}; średnia obwiedni {r.mean()/sigma:.3f}σ (Rayleigh: {np.sqrt(np.pi/2):.3f}σ); "
      f"E[r²] = {np.mean(r**2)/sigma**2:.3f}σ² (teoria 2)")
for pfa in (1e-2, 1e-3):
    thr = sigma*np.sqrt(2*np.log(1/pfa))
    print(f"P_FA = {pfa:.0e}: próg {thr/sigma:.2f}σ, zmierzony odsetek przekroczeń {np.mean(r > thr):.1e}")

# proces Poissona: zliczenia i odstępy
lam, T, M = 5.0, 1.0, 200_000
counts = rng.poisson(lam*T, M)
print(f"Poisson λT = 5: średnia {counts.mean():.3f}, wariancja {counts.var():.3f}, P(0) = {np.mean(counts == 0):.4f} (teoria {np.exp(-5):.4f})")

# czas martwy (nieparaliżujący): symulacja strumienia 1111/s i licznika z τ = 100 µs
rate, tau, Tm = 1111.0, 100e-6, 60.0
t_ev = np.cumsum(rng.exponential(1/rate, int(rate*Tm*1.1)))
t_ev = t_ev[t_ev < Tm]
registered, last = 0, -1.0
for te in t_ev:
    if te - last >= tau:
        registered += 1; last = te
m = registered/Tm
print(f"rzeczywiste {len(t_ev)/Tm:.0f}/s, zarejestrowane {m:.0f}/s, po korekcji {m/(1 - m*tau):.0f}/s")
```

## Zadania

1. Szum wąskopasmowy ma wartość skuteczną 1 µV. Jakie jest prawdopodobieństwo, że obwiednia przekroczy 3 µV?
2. Radar ma ustawiony próg dla $P_{FA} = 10^{-6}$ na komórkę. Ile fałszywych alarmów na sekundę przy 10⁶ komórkach na sekundę? Jak zmieni się próg dla $10^{-8}$?
3. Ile zliczeń trzeba zebrać, aby niepewność względna wynosiła 0,5%?
4. Zmierzono 2000 zliczeń/s przy czasie martwym 50 µs. Jaka jest częstość rzeczywista?
5. Fotodioda daje średnio 10⁶ fotoelektronów na sekundę. Jaki jest stosunek sygnału do szumu (śrutowego) przy czasie integracji 1 ms?

<details>
<summary>Odpowiedzi</summary>

1. $e^{-9/2} = 1\text{,}1\%$
2. 1 fałszywy alarm na sekundę; próg z $5\text{,}26\sigma$ rośnie do $\sigma\sqrt{2\ln 10^8} = 6\text{,}07\sigma$
3. $1/\sqrt N = 0\text{,}005$ → $N = 40\,000$
4. $n = 2000/(1 - 2000\cdot 5\cdot 10^{-5}) = 2000/0\text{,}9 = 2222$ zliczeń/s
5. $N = 10^6\cdot 10^{-3} = 1000$ elektronów; $\mathrm{SNR} = N/\sqrt N = \sqrt{1000} \approx 31\text{,}6$ (30 dB w mocy)
</details>

## Źródła

- [MIT 6.041 Probabilistic Systems Analysis](https://ocw.mit.edu/courses/6-041-probabilistic-systems-analysis-and-applied-probability-fall-2010/) — proces Poissona
- [MIT 6.450 Principles of Digital Communication I](https://ocw.mit.edu/courses/6-450-principles-of-digital-communications-i-fall-2006/) — szum pasmowy, składowe I/Q
- [NIST/SEMATECH e-Handbook of Statistical Methods](https://www.itl.nist.gov/div898/handbook/) — rozkłady Poissona, wykładniczy, Rayleigha
