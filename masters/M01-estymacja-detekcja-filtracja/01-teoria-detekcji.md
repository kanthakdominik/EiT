# M01.01 — Teoria detekcji: Neyman–Pearson, ROC, filtr dopasowany

## Po co to jest

Czy w odbieranym sygnale jest echo celu? Czy bit to 0, czy 1? Czy w danych z czujnika drgań pojawiła się usterka? Detekcja to decyzja między hipotezami na podstawie zaszumionych danych. Teoria daje dwie rzeczy: przepis na **optymalny detektor** (zwykle test ilorazu wiarygodności, który dla sygnału w szumie gaussowskim staje się filtrem dopasowanym) i **przewidywanie jakości** — prawdopodobieństwa wykrycia przy zadanym prawdopodobieństwie fałszywego alarmu, zanim zbuduje się system.

## Teoria w pigułce

### Testowanie hipotez

$\mathcal H_0$: $\mathbf x = \mathbf w$ (sam szum), $\mathcal H_1$: $\mathbf x = \mathbf s + \mathbf w$.

- **Prawdopodobieństwo fałszywego alarmu** $P_{FA} = P(\text{decyzja }\mathcal H_1\mid\mathcal H_0)$, **wykrycia** $P_D = P(\text{decyzja }\mathcal H_1\mid\mathcal H_1)$.
- **Lemat Neymana–Pearsona:** przy ograniczeniu $P_{FA} \leq \alpha$ największe $P_D$ daje test ilorazu wiarygodności $\Lambda(\mathbf x) = \dfrac{p(\mathbf x\mid\mathcal H_1)}{p(\mathbf x\mid\mathcal H_0)} \gtrless \gamma$, próg $\gamma$ wyznacza się z $P_{FA}$.
- **Podejście bayesowskie** (koszty i prawdopodobieństwa a priori): ten sam iloraz, inny próg; dla równych kosztów — minimalne prawdopodobieństwo błędu (MAP), jak w odbiorniku cyfrowym ([13.05](../../modules/13-telekomunikacja/05-detekcja-i-ber.md)).
- **Krzywa ROC** — $P_D$ w funkcji $P_{FA}$ dla wszystkich progów; opisuje detektor niezależnie od wyboru progu.

### Znany sygnał w szumie białym gaussowskim

Logarytm ilorazu wiarygodności prowadzi do statystyki **filtru dopasowanego (korelatora)**: $T(\mathbf x) = \mathbf s^T\mathbf x \gtrless \gamma'$.

- Pod $\mathcal H_0$: $T \sim \mathcal N(0, \sigma^2E)$, pod $\mathcal H_1$: $\mathcal N(E, \sigma^2E)$, $E = \mathbf s^T\mathbf s$.
- $P_D = Q\!\left(Q^{-1}(P_{FA}) - \sqrt{d^2}\right)$, **współczynnik odchylenia** $d^2 = E/\sigma^2$ (w ciągłym czasie $2E/N_0$).
- Jakość zależy **tylko od energii sygnału** względem szumu, nie od jego kształtu — kształt decyduje o tym, jak zbudować filtr.
- **Szum kolorowy** (kowariancja $\mathbf C$): $T = \mathbf s^T\mathbf C^{-1}\mathbf x$ — najpierw wybielanie, potem filtr dopasowany; $d^2 = \mathbf s^T\mathbf C^{-1}\mathbf s$.

### Sygnał nieznany lub z nieznanymi parametrami

- **Detektor energii** $T = \lVert\mathbf x\rVert^2$ — gdy nic nie wiadomo o kształcie; znacznie słabszy (rozkład $\chi^2$).
- **GLRT** (uogólniony test ilorazu wiarygodności) — nieznane parametry (amplituda, faza, opóźnienie, częstotliwość) zastępuje się ich estymatami ML; np. nieznana faza → detektor obwiedni korelatorów I/Q; nieznane opóźnienie → maksimum filtru dopasowanego w czasie (radar, synchronizacja).
- **CFAR** (stały poziom fałszywych alarmów) — próg skalowany szacunkiem szumu z komórek sąsiednich, gdy moc szumu jest nieznana lub zmienna ([21.08](../../modules/21-procesy-losowe-szum/08-szum-waskopasmowy-i-procesy-punktowe.md)).

## Przykład rozwiązany

**Ile energii potrzeba?** Wymagane $P_{FA} = 10^{-3}$ i $P_D = 0\text{,}9$.

$$\sqrt{d^2} = Q^{-1}(10^{-3}) - Q^{-1}(0\text{,}9) = 3\text{,}090 - (-1\text{,}282) = 4\text{,}372 \quad\Rightarrow\quad d^2 = 19\text{,}1\ (12\text{,}8\ \text{dB})$$

Impuls 64 próbek o amplitudzie 0,75 w szumie $\sigma = 1$: $E = 18\text{,}1$ (pojedyncza próbka ma SNR −5,5 dB!), $P_D = 0\text{,}877$ — symulacja Monte Carlo potwierdza. Detektor energii przy tym samym sygnale osiąga tylko $P_D \approx 0\text{,}06$: znajomość kształtu sygnału jest warta bardzo dużo.

## Typowe pułapki

- **Próg ustawiony na „ładnie wyglądający” poziom** zamiast z $P_{FA}$ i liczby testów (komórek, chwil) — w radarze z milionem komórek na sekundę $P_{FA} = 10^{-3}$ to tysiąc fałszywych alarmów na sekundę.
- **Filtr dopasowany do niewłaściwego sygnału** (zniekształcenia kanału, przesunięcie Dopplera) — straty kilku dB.
- **Założenie szumu białego**, gdy jest kolorowy — detektor nie jest optymalny, a $P_{FA}$ się nie zgadza.
- **Mylenie $d^2$ z SNR pojedynczej próbki** — zysk z integracji to $10\log_{10}N$ dla sygnału spójnego.
- **Ocena detektora jednym punktem** zamiast krzywej ROC.

## Ćwiczenie komputerowe

Wymagane $d^2$, $P_D$ w funkcji $d^2$, symulacja filtru dopasowanego i porównanie z detektorem energii:

```python
import numpy as np
from scipy.stats import norm

# Neyman–Pearson: znany sygnał w szumie białym gaussowskim, filtr dopasowany
Pfa, Pd_req = 1e-3, 0.9
d = norm.isf(Pfa) - norm.isf(Pd_req)
print(f"wymagany współczynnik odchylenia d = {d:.3f} → d² = {d**2:.1f} ({10*np.log10(d**2):.1f} dB)")
for d2_db in (6, 10, 13, 16):
    d_ = np.sqrt(10**(d2_db/10))
    print(f"d² = {d2_db:2d} dB: Pd = {norm.sf(norm.isf(Pfa) - d_):.4f} przy Pfa = 1e-3")

# symulacja: sygnał s[n] (impuls sinusoidalny) w szumie, statystyka T = sᵀx, próg z Pfa
rng = np.random.default_rng(0)
N, sigma = 64, 1.0
s = 0.75*np.sin(2*np.pi*0.1*np.arange(N))
E = s @ s
d_sim = np.sqrt(E)/sigma
thr = sigma*np.sqrt(E)*norm.isf(Pfa)
M = 200_000
T0 = rng.normal(0, sigma, (M, N)) @ s
T1 = (s + rng.normal(0, sigma, (M, N))) @ s
print(f"E/σ² = {E/sigma**2:.1f} (d = {d_sim:.2f}); symulacja: Pfa = {np.mean(T0 > thr):.2e}, Pd = {np.mean(T1 > thr):.4f}; "
      f"teoria Pd = {norm.sf(norm.isf(Pfa) - d_sim):.4f}")

# detektor energii (sygnał nieznany) przy tym samym E: znacznie gorszy
from scipy.stats import chi2, ncx2
thr_e = chi2.isf(Pfa, N)
print(f"detektor energii: Pd = {ncx2.sf(thr_e, N, E/sigma**2):.4f} (ten sam sygnał, bez znajomości jego kształtu)")
```

Rozszerzenie: narysuj krzywe ROC obu detektorów dla $E/\sigma^2$ = 5, 10 i 20 oraz dodaj wariant z nieznaną fazą (detektor obwiedni I/Q).

## Zadania

1. Wymagane $P_{FA} = 10^{-6}$, $P_D = 0\text{,}99$. Ile wynosi $d^2$ w dB?
2. Szum ma kowariancję $\mathbf C = \mathrm{diag}(1, 4)$, sygnał $\mathbf s = [1, 1]^T$. Podaj statystykę optymalną i $d^2$.
3. Dlaczego przy nieznanej fazie nośnej detektor optymalny używa obwiedni dwóch korelatorów (I i Q)?
4. Radar sprawdza $10^6$ komórek na sekundę. Jakie $P_{FA}$ na komórkę daje jeden fałszywy alarm na minutę?
5. Ile razy dłuższy (przy tej samej amplitudzie) musi być impuls, by $d^2$ wzrosło o 3 dB?

<details>
<summary>Odpowiedzi</summary>

1. $Q^{-1}(10^{-6}) = 4\text{,}753$, $Q^{-1}(0\text{,}99) = -2\text{,}326$ → $\sqrt{d^2} = 7\text{,}08$, $d^2 = 50\text{,}1$ (17 dB)
2. $T = \mathbf s^T\mathbf C^{-1}\mathbf x = x_1 + x_2/4$; $d^2 = 1 + 1/4 = 1\text{,}25$ (próbka bardziej zaszumiona ma mniejszą wagę)
3. Statystyka GLRT po maksymalizacji względem fazy to $\sqrt{(\mathbf s_I^T\mathbf x)^2 + (\mathbf s_Q^T\mathbf x)^2}$ — obwiednia nie zależy od fazy; strata względem przypadku znanej fazy jest niewielka (ok. 1 dB przy typowych $P_D$)
4. $1/(60\cdot 10^6) \approx 1\text{,}7\cdot 10^{-8}$
5. 2 razy ($E$ rośnie liniowo z długością)
</details>

## Źródła

- [MIT 6.432 Stochastic Processes, Detection, and Estimation](https://ocw.mit.edu/courses/6-432-stochastic-processes-detection-and-estimation-spring-2004/) — testy hipotez, detekcja w szumie
- [MIT 6.011 Signals, Systems and Inference](https://ocw.mit.edu/courses/6-011-signals-systems-and-inference-spring-2018/) — testowanie hipotez, filtr dopasowany
- S. M. Kay — *Fundamentals of Statistical Signal Processing, t. II: Detection Theory* (płatna)
