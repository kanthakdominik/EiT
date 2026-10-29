# 20.08 — Optymalizacja i dopasowanie modeli

## Po co to jest

Model diody do symulatora z pomiaru charakterystyki, parametry termistora, stała czasowa i wzmocnienie obiektu do strojenia regulatora ([10.01](../10-automatyka/01-modele-obiektow.md)), dobór elementów filtru pod zadaną charakterystykę, optymalizacja sprawności przetwornicy po częstotliwości — wszystko to **minimalizacja funkcji celu**. Gdy model jest nieliniowy względem parametrów, metoda najmniejszych kwadratów z [20.04](04-interpolacja-i-aproksymacja.md) nie wystarcza i potrzebne są metody iteracyjne.

## Teoria w pigułce

### Zadanie

$$\min_{\mathbf p}\ F(\mathbf p), \qquad \text{np. } F(\mathbf p) = \sum_i \left(\frac{y_i - f(x_i; \mathbf p)}{\sigma_i}\right)^2$$

### Metody

| Metoda | Zasada | Kiedy |
|---|---|---|
| **Gradient (najszybszy spadek)** | $\mathbf p \leftarrow \mathbf p - \alpha\nabla F$ | Proste, ale wolne przy „wąskich dolinach” |
| **Newton** | $\mathbf p \leftarrow \mathbf p - \mathbf H^{-1}\nabla F$ (hesjan) | Szybkie blisko minimum, drogie i niestabilne daleko |
| **Gauss–Newton / Levenberg–Marquardt** | Dla sumy kwadratów: jakobian reszt zamiast hesjanu; LM łączy z gradientem | **Domyślna dla dopasowania** (`scipy.optimize.curve_fit`, `least_squares`) |
| **Nelder–Mead (simpleks)** | Bez pochodnych, przekształcanie simpleksu | Funkcje nieróżniczkowalne, mało parametrów |
| **BFGS** | Przybliżony hesjan z gradientów | Ogólna minimalizacja gładkiej funkcji |
| **Globalne** (ewolucja różnicowa, wyżarzanie) | Losowe przeszukiwanie z selekcją | Wiele minimów lokalnych, parametry dyskretne (szereg E24) |

### Dobre praktyki

- **Skalowanie parametrów:** parametry rzędu $10^{-9}$ (prąd nasycenia) i $10^0$ (współczynnik $n$) w jednym wektorze utrudniają optymalizację — dopasowuj $\log_{10} I_S$.
- **Dobry punkt startowy** — z prostszego modelu (np. linearyzacja logarytmem), z noty katalogowej.
- **Przekształcenie modelu do postaci jawnej:** dla diody z $R_S$ prąd jest funkcją uwikłaną napięcia, ale napięcie jest jawną funkcją prądu: $V = nU_T\ln(I/I_S + 1) + IR_S$ — dopasowuje się $V(I)$.
- **Niepewność parametrów:** macierz kowariancji z dopasowania (`pcov` w `curve_fit`) — pierwiastki z przekątnej to niepewności standardowe (przy poprawnie oszacowanym szumie); silna korelacja parametrów = model źle określony przez dane.
- **Minima lokalne:** start z kilku punktów; porównaj wyniki.
- **Ograniczenia:** parametry fizycznie dodatnie (`bounds`).

## Przykład rozwiązany

**Model diody z pomiaru.** 12 punktów I–U od 1 µA do 100 mA (logarytmicznie), szum pomiaru napięcia 1 mV. Szukamy $I_S$, $n$, $R_S$.

1. **Start z prostej:** dla $I < 1$ mA rezystancja szeregowa jest pomijalna, $V \approx nU_T\ln I - nU_T\ln I_S$ — prosta w zmiennej $\ln I$. Wynik: $n = 1\text{,}740$, $I_S = 2\text{,}39$ nA.
2. **Pełny model** metodą Levenberga–Marquardta, parametry $(\log_{10}I_S, n, R_S)$, start z kroku 1: $I_S = 2\text{,}55$ nA, $n = 1\text{,}753 \pm 0\text{,}007$, $R_S = 0\text{,}596 \pm 0\text{,}024$ Ω (wartości „prawdziwe” użyte do wygenerowania danych: 2,5 nA; 1,75; 0,6 Ω).
3. **Kontrola:** reszty ok. 1,5 mV RMS — rzędu szumu pomiaru, bez wyraźnej struktury; model jest wystarczający.
4. Ta sama minimalizacja metodą Neldera–Meada dała ten sam wynik po 234 wywołaniach funkcji.

Model można wpisać do symulatora: `.model DX D(Is=2.55n N=1.753 Rs=0.596)`.

## Typowe pułapki

- **Brak skalowania** parametrów o różnych rzędach wielkości.
- **Start daleko od rozwiązania** — zbieżność do minimum lokalnego lub brak zbieżności.
- **Zbyt wiele parametrów względem danych** — parametry silnie skorelowane, niepewności ogromne, model „dopasowuje szum”.
- **Ignorowanie zakresu danych:** $R_S$ wyznaczone z punktów do 10 mA jest bezwartościowe — wpływa dopiero przy dużych prądach.
- **Optymalizacja dyskretnych wartości** (szereg E24) metodą ciągłą i zaokrąglenie wyniku — zaokrąglenie może dać rozwiązanie dalekie od optimum; sprawdź sąsiednie kombinacje.

## Ćwiczenie komputerowe

```python
import numpy as np
from scipy.optimize import curve_fit, minimize

VT = 0.025852
Is_true, n_true, Rs_true = 2.5e-9, 1.75, 0.6
I = np.logspace(-6, -1, 12)                                   # 1 µA … 100 mA
rng = np.random.default_rng(3)
V = n_true*VT*np.log(I/Is_true + 1) + I*Rs_true + rng.normal(0, 1e-3, I.size)   # „pomiar”, szum 1 mV

# 1) prosta w zakresie małych prądów (R_S pomijalne): V = n*VT*ln(I) - n*VT*ln(Is)
m = I < 1e-3
slope, icpt = np.polyfit(np.log(I[m]), V[m], 1)
n1 = slope/VT; Is1 = np.exp(-icpt/slope)
print(f"prosta (I < 1 mA): n = {n1:.3f}, Is = {Is1:.2e} A")

# 2) pełny model V(I) — jawny względem V, parametry: log10(Is), n, Rs
def model(I, logIs, n, Rs):
    return n*VT*np.log(I/10**logIs + 1) + I*Rs
p, cov = curve_fit(model, I, V, p0=[np.log10(Is1), n1, 0.1])
err = np.sqrt(np.diag(cov))
print(f"curve_fit: Is = {10**p[0]:.2e} A (log10 ± {err[0]:.3f}), n = {p[1]:.3f} ± {err[1]:.3f}, Rs = {p[2]:.3f} ± {err[2]:.3f} Ω")
res = V - model(I, *p); print(f"reszty RMS = {np.std(res)*1e3:.2f} mV")

# 3) ta sama minimalizacja metodą bez gradientu (Nelder–Mead) — zwykle wolniej
cost = lambda q: np.sum((V - model(I, *q))**2)
r = minimize(cost, [np.log10(Is1), n1, 0.1], method="Nelder-Mead", options={"xatol": 1e-8, "fatol": 1e-14, "maxiter": 20000})
print(f"Nelder–Mead: Is = {10**r.x[0]:.2e} A, n = {r.x[1]:.3f}, Rs = {r.x[2]:.3f} Ω, wywołań funkcji: {r.nfev}")
```

Rozszerzenie: zmierz rzeczywistą diodę (projekt modułowy) i porównaj parametry z modelem producenta; zbadaj, jak niepewność $R_S$ zmienia się, gdy usuniesz punkty powyżej 10 mA.

## Zadania

1. Dlaczego dopasowanie diody prowadzi się jako $V(I)$, a nie $I(V)$?
2. Gradientowa metoda z krokiem $\alpha$ minimalizuje $F(p) = 100p^2$. Dla jakich $\alpha$ jest zbieżna?
3. Dopasowanie zwraca $n = 1\text{,}8 \pm 0\text{,}9$. Co to oznacza i co zrobić?
4. Dobierz numerycznie z szeregu E12 kondensatory filtru, minimalizując błąd częstotliwości granicznej — jaką metodę wybierzesz?
5. Dlaczego warto dopasowywać $\log I_S$, a nie $I_S$?

<details>
<summary>Odpowiedzi</summary>

1. Napięcie jest jawną funkcją prądu ($V = nU_T\ln(I/I_S + 1) + IR_S$), a prąd od napięcia — uwikłaną (przez spadek na $R_S$); dodatkowo błąd pomiaru leży zwykle w napięciu, a prąd zmienia się o rzędy wielkości, więc reszty w $V$ są lepiej zrównoważone
2. $p \leftarrow p - 200\alpha p = (1 - 200\alpha)p$ → zbieżna dla $0 < \alpha < 0\text{,}01$
3. Niepewność rzędu wartości — parametr słabo określony przez dane (za wąski zakres, silna korelacja z innym parametrem, za mało punktów); rozszerzyć zakres pomiaru, ustalić inne parametry lub uprościć model
4. Przeszukiwanie wyczerpujące wszystkich kombinacji (jest ich niewiele) albo metoda globalna dla parametrów dyskretnych; metoda ciągła + zaokrąglenie nie gwarantuje optimum
5. $I_S$ zmienia się o rzędy wielkości i jest rzędu $10^{-9}$, a $n$ rzędu 1 — złe skalowanie; logarytm wyrównuje skale, a przy okazji gwarantuje $I_S > 0$
</details>

## Źródła

- [SciPy — Optimization (scipy.optimize)](https://docs.scipy.org/doc/scipy/tutorial/optimize.html)
- [MIT 18.335J Introduction to Numerical Methods](https://ocw.mit.edu/courses/18-335j-introduction-to-numerical-methods-spring-2019/) — optymalizacja, najmniejsze kwadraty
- [NIST/SEMATECH e-Handbook of Statistical Methods](https://www.itl.nist.gov/div898/handbook/) — nieliniowe dopasowanie, analiza reszt
- S. Boyd, L. Vandenberghe — [Convex Optimization (darmowy PDF)](https://web.stanford.edu/~boyd/cvxbook/) — teoria optymalizacji
