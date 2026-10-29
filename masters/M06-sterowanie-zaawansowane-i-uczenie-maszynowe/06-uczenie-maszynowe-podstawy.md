# M06.06 — Uczenie maszynowe: podstawy dla inżyniera sygnałów

## Po co to jest

Uczenie maszynowe w elektronice i telekomunikacji to nie magia, tylko estymacja i detekcja ([M01](../M01-estymacja-detekcja-filtracja/)) z modelami o wielu parametrach, dopasowywanymi do danych zamiast wyprowadzanymi z fizyki. Zastosowania: klasyfikacja modulacji i sygnałów radarowych, wykrywanie usterek z drgań i prądów silników, kalibracja czujników, predykcja obciążenia sieci, korekcja nieliniowości wzmacniaczy, rozpoznawanie słów kluczowych na mikrokontrolerze. Zanim sięgnie się po sieci głębokie, trzeba opanować podstawy, które decydują o sukcesie każdej metody: podział danych, przeuczenie, regularyzację, walidację i porównanie z rozwiązaniem optymalnym.

## Teoria w pigułce

### Zadanie uczenia nadzorowanego

Dane $\{(x_i, y_i)\}$, model $\hat y = f_\theta(x)$, funkcja straty (MSE dla regresji, entropia krzyżowa dla klasyfikacji), minimalizacja **ryzyka empirycznego** $\frac1N\sum\ell(y_i, f_\theta(x_i))$ — ale celem jest mały błąd na **nowych** danych (uogólnianie).

### Obciążenie, wariancja, regularyzacja

- Błąd oczekiwany = obciążenie² + wariancja + szum nieredukowalny. Model za prosty — duże obciążenie (niedouczenie), za złożony — duża wariancja (przeuczenie).
- **Regularyzacja grzbietowa** (L2, Tichonow): $\min\lVert y - X\theta\rVert^2 + \lambda\lVert\theta\rVert^2$, rozwiązanie $(X^TX + \lambda I)^{-1}X^Ty$ — to estymator MAP z gaussowskim a priori ([M01.04](../M01-estymacja-detekcja-filtracja/04-estymacja-bayesowska.md)). **L1 (lasso)** daje rozwiązania rzadkie (wybór cech).
- **Walidacja krzyżowa** $k$-krotna: dobór hiperparametrów ($\lambda$, rząd, architektura) bez dotykania zbioru testowego. Podział: uczący / walidacyjny / testowy — test używany **raz**, na końcu.

### Klasyfikacja

- **Regresja logistyczna:** $P(y = 1\mid x) = \sigma(w^Tx + b)$, $\sigma(z) = 1/(1 + e^{-z})$; strata — entropia krzyżowa, gradient $X^T(p - y)/N$ (wypukła — jedno minimum).
- Dla dwóch klas gaussowskich o wspólnej kowariancji granica Bayesa jest liniowa, a logarytm ilorazu wiarygodności ma dokładnie postać logistyczną — regresja logistyczna jest wtedy **modelem poprawnym** i zbliża się do optimum.
- Miary: dokładność, macierz pomyłek, precyzja/czułość, krzywa ROC ([M01.01](../M01-estymacja-detekcja-filtracja/01-teoria-detekcji.md)) — przy niezrównoważonych klasach sama dokładność myli.

### Dane i cechy

Normalizacja cech (średnia 0, wariancja 1), dobór cech z wiedzy dziedzinowej (widmo, kumulanty, cechy statystyczne okna czasowego), **wyciek danych** (informacja ze zbioru testowego w procesie uczenia, np. normalizacja liczona na całości, sąsiednie okna tego samego nagrania w obu zbiorach).

## Przykład rozwiązany

**A. Regresja wielomianowa** $y = \sin(\pi x)$ + szum (wariancja 0,04), 30 punktów uczących:

| Stopień | MSE uczący | MSE testowy |
|---|---|---|
| 1 | 0,170 | 0,231 |
| 3 | 0,032 | 0,053 |
| 5 | 0,020 | 0,048 |
| 9 | 0,017 | 0,054 |
| 15 | 0,004 | 0,360 |

Stopień 15 bez regularyzacji „zapamiętuje” szum (MSE uczący poniżej wariancji szumu!). Z regularyzacją grzbietową i $\lambda = 0\text{,}1$ dobranym 5-krotną walidacją krzyżową — MSE testowy 0,064, mimo 16 parametrów na 30 punktów.

**B. Regresja logistyczna od zera** na dwóch klasach gaussowskich (400 próbek uczących): wagi $[-0\text{,}013;\ 2\text{,}147;\ -0\text{,}239]$ wobec granicy Bayesa $[0;\ 2\text{,}073;\ -0\text{,}122]$; dokładność testowa 83,98% przy optimum Bayesa 84,21%.

## Typowe pułapki

- **Ocena na danych uczących** lub wielokrotne „podglądanie” zbioru testowego przy strojeniu.
- **Wyciek danych** przez normalizację, losowy podział skorelowanych w czasie próbek albo te same urządzenia w obu zbiorach.
- **Brak punktu odniesienia** — sieć z dokładnością 84% wydaje się słaba lub dobra, dopóki nie porówna się jej z optimum Bayesa lub prostym modelem.
- **Nieznormalizowane cechy** — wolna zbieżność gradientu, regularyzacja działa nierówno.
- **Niezrównoważone klasy** (usterki są rzadkie) — klasyfikator „zawsze OK” ma 99% dokładności.

## Ćwiczenie komputerowe

Przeuczenie, regularyzacja i walidacja krzyżowa w regresji; regresja logistyczna od zera porównana z optimum Bayesa:

```python
import numpy as np
from numpy.polynomial import legendre
from scipy.stats import norm

rng = np.random.default_rng(6)

# A) Regresja wielomianowa: przeuczenie, regularyzacja grzbietowa, walidacja krzyżowa
f = lambda x: np.sin(np.pi * x)
x_tr = rng.uniform(-1, 1, 30); y_tr = f(x_tr) + 0.2 * rng.standard_normal(30)
x_te = rng.uniform(-1, 1, 2000); y_te = f(x_te) + 0.2 * rng.standard_normal(2000)
cechy = lambda x, d: legendre.legvander(x, d)           # wielomiany Legendre'a: dobre uwarunkowanie

def ridge(X, y, lam):
    I = np.eye(X.shape[1]); I[0, 0] = 0                 # wyrazu wolnego nie regularyzujemy
    return np.linalg.solve(X.T @ X + lam * I, X.T @ y)

mse = lambda y, yh: np.mean((y - yh)**2)
print("stopień | MSE uczący | MSE testowy  (bez regularyzacji; szum 0,04)")
for d in (1, 3, 5, 9, 15):
    w = ridge(cechy(x_tr, d), y_tr, 0.0)
    print(f"   {d:2d}   |   {mse(y_tr, cechy(x_tr, d) @ w):.4f}   |   {mse(y_te, cechy(x_te, d) @ w):.4f}")

def cv(d, lam, k=5):
    idx = np.array_split(rng.permutation(30), k)
    bl = 0
    for i in range(k):
        te = idx[i]; tr = np.setdiff1d(np.arange(30), te)
        w = ridge(cechy(x_tr[tr], d), y_tr[tr], lam)
        bl += mse(y_tr[te], cechy(x_tr[te], d) @ w) / k
    return bl

lams = 10.0**np.linspace(-8, 1, 28)
bledy = [cv(15, lam) for lam in lams]
lam_best = lams[int(np.argmin(bledy))]
w = ridge(cechy(x_tr, 15), y_tr, lam_best)
print(f"stopień 15, lambda z 5-krotnej walidacji krzyżowej = {lam_best:.1e}: MSE testowy {mse(y_te, cechy(x_te, 15) @ w):.4f}")

# B) Regresja logistyczna od zera (spadek gradientu) a klasyfikator optymalny Bayesa
mu = np.array([1.0, 0.5]); Sig = np.array([[1.0, 0.6], [0.6, 2.0]])
def dane(n):
    yk = rng.integers(0, 2, n)
    X = rng.multivariate_normal(np.zeros(2), Sig, n) + np.where(yk[:, None] == 1, mu, -mu)
    return X, yk
X, yk = dane(400); Xt, ykt = dane(20000)
Xb, Xtb = np.column_stack([np.ones(len(X)), X]), np.column_stack([np.ones(len(Xt)), Xt])
w = np.zeros(3)
sigm = lambda z: 1 / (1 + np.exp(-z))
for it in range(3000):
    p = sigm(Xb @ w)
    grad = Xb.T @ (p - yk) / len(yk)                    # gradient entropii krzyżowej
    w -= 0.5 * grad
acc = np.mean((sigm(Xtb @ w) > 0.5) == ykt)
w_bayes = np.linalg.solve(Sig, 2 * mu)                  # granica Bayesa dla wspólnej kowariancji
delta = np.sqrt((2 * mu) @ np.linalg.solve(Sig, 2 * mu))   # odległość Mahalanobisa między klasami
print(f"regresja logistyczna: w = {np.round(w, 3)} (Bayes: [0, {w_bayes[0]:.3f}, {w_bayes[1]:.3f}])")
print(f"dokładność testowa {100 * acc:.2f} %, optimum Bayesa {100 * (1 - norm.sf(delta / 2)):.2f} %")
```

Rozszerzenia: wykreśl krzywe uczenia (błąd w funkcji liczby próbek) dla stopnia 5 i 15; dodaj regularyzację L1 (spadek współrzędnościowy) i sprawdź, które współczynniki zostają zerowe; wyznacz krzywą ROC regresji logistycznej i porównaj z teoretyczną dla klasyfikatora Bayesa.

## Zadania

1. Dlaczego MSE na zbiorze uczącym może być mniejszy od wariancji szumu, a testowy — nie?
2. Wykaż, że regresja grzbietowa jest estymatorem MAP dla a priori $\theta \sim \mathcal N(0, \sigma_\theta^2I)$. Ile wynosi $\lambda$?
3. Dla klas $\mathcal N(\pm\mu, \Sigma)$ wyprowadź, że $\ln\dfrac{P(1\mid x)}{P(0\mid x)}$ jest liniowe w $x$.
4. Jakie zjawisko pokazuje wynik stopnia 15 bez regularyzacji?
5. Czujnik drgań daje 1 rekord na minutę z każdego z 20 silników; usterki są w 3 silnikach. Jak podzielić dane na uczące i testowe?

<details>
<summary>Odpowiedzi</summary>

1. Model o dużej liczbie parametrów dopasowuje się do konkretnych realizacji szumu w danych uczących; na nowych danych szum jest inny, więc błąd nie może spaść poniżej jego wariancji
2. $-\ln p(\theta\mid y) = \tfrac{1}{2\sigma^2}\lVert y - X\theta\rVert^2 + \tfrac{1}{2\sigma_\theta^2}\lVert\theta\rVert^2 + \text{const}$ → $\lambda = \sigma^2/\sigma_\theta^2$
3. $\ln\dfrac{p(x\mid 1)}{p(x\mid 0)} = -\tfrac12(x - \mu)^T\Sigma^{-1}(x - \mu) + \tfrac12(x + \mu)^T\Sigma^{-1}(x + \mu) = 2\mu^T\Sigma^{-1}x$ (plus logarytm ilorazu prawdopodobieństw a priori) — liniowe, $w = 2\Sigma^{-1}\mu$
4. Przeuczenie (duża wariancja estymatora) — wielomian oscyluje między punktami, szczególnie przy brzegach przedziału (zjawisko Rungego, [20.04](../../modules/20-metody-numeryczne/04-interpolacja-i-aproksymacja.md))
5. Według silników, nie według rekordów — np. 15 silników (w tym 2 z usterką) do uczenia, 5 (w tym 1) do testu; inaczej model „rozpoznaje silnik”, a nie usterkę
</details>

## Źródła

- [MIT 6.036 Introduction to Machine Learning (2020)](https://ocw.mit.edu/courses/6-036-introduction-to-machine-learning-fall-2020/) — regresja, klasyfikacja, regularyzacja, walidacja
- [S. L. Brunton, J. N. Kutz — Data-Driven Science and Engineering](https://www.cambridge.org/core/books/datadriven-science-andengineering/77D52B171B60A496EAFE4DB662ADC36E) (płatna) — uczenie maszynowe w inżynierii i sterowaniu
- [Dive into Deep Learning](https://d2l.ai) — darmowa interaktywna książka (od regresji liniowej)
- [M01.03 ML i najmniejsze kwadraty](../M01-estymacja-detekcja-filtracja/03-ml-i-najmniejsze-kwadraty.md)
