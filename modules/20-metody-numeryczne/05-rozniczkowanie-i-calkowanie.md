# 20.05 — Różniczkowanie i całkowanie numeryczne

## Po co to jest

Energia impulsu, ładunek pobrany z baterii ([18.03](../18-projekt-dyplomowy/03-weryfikacja-i-pomiary.md)), wartość skuteczna, moc średnia — to całki z próbek. Szybkość narastania, prąd kondensatora $C\,du/dt$, człon D regulatora ([10.05](../10-automatyka/05-regulatory-pid.md)) — to pochodne. Na danych dyskretnych liczy się je numerycznie, a wybór metody i kroku decyduje, czy wynik ma sens. Różniczkowanie jest podstępne: wzmacnia szum.

## Teoria w pigułce

### Różniczkowanie numeryczne

| Wzór | Błąd obcięcia |
|---|---|
| W przód: $f'(x) \approx \dfrac{f(x+h) - f(x)}{h}$ | $O(h)$ |
| Centralny: $f'(x) \approx \dfrac{f(x+h) - f(x-h)}{2h}$ | $O(h^2)$ |
| Druga pochodna: $f''(x) \approx \dfrac{f(x+h) - 2f(x) + f(x-h)}{h^2}$ | $O(h^2)$ |

**Kompromis kroku:** błąd obcięcia maleje z $h$, ale błąd zaokrągleń rośnie jak $\varepsilon\lvert f\rvert/h$. Optymalny krok: w przód $h \sim \sqrt{\varepsilon} \approx 10^{-8}$, centralny $h \sim \varepsilon^{1/3} \approx 10^{-5}$ (względnie do skali $x$).

**Dane z szumem:** szum o odchyleniu $\sigma$ daje w różnicy szum ok. $\sqrt2\,\sigma/h$ — im gęstsze próbkowanie, tym gorzej. Rozwiązanie: najpierw filtr (średnia, Savitzky–Golay `scipy.signal.savgol_filter`), potem pochodna, albo pochodna dopasowanego modelu.

### Całkowanie numeryczne (kwadratury)

Przedział podzielony na $N$ części o szerokości $h$:

| Metoda | Wzór (jeden przedział / para) | Błąd globalny |
|---|---|---|
| Prostokątów | $h\,f(x_i)$ | $O(h)$ |
| **Trapezów** | $\tfrac h2\,[f(x_i) + f(x_{i+1})]$ | $O(h^2)$ |
| **Simpsona** | $\tfrac h3\,[f_0 + 4f_1 + f_2]$ | $O(h^4)$ |
| Gaussa (n punktów) | Optymalne węzły i wagi | Dokładna dla wielomianów stopnia $2n-1$ |

- **Ekstrapolacja Richardsona:** z dwóch wyników trapezów dla $h$ i $h/2$: $I \approx T_{h/2} + (T_{h/2} - T_h)/3$ — to jest dokładnie wzór Simpsona (metoda Romberga powtarza to dalej).
- **Metody adaptacyjne** (`scipy.integrate.quad`) — same zagęszczają podział tam, gdzie funkcja szybko się zmienia; podają szacunek błędu.
- **Całka sygnału okresowego po pełnym okresie** — metoda trapezów jest wtedy wyjątkowo dokładna (zbieżność wykładnicza); stąd dobre wyniki RMS z próbek pełnych okresów.
- Dla **próbek pomiarowych** (bez wzoru funkcji) zwykle trapezy (`scipy.integrate.trapezoid`) lub Simpson (`simpson`); skumulowana całka — `cumulative_trapezoid`.

## Przykład rozwiązany

**$\displaystyle\int_0^\pi \sin x\,dx = 2$** — błąd metod przy $N$ przedziałach:

| $N$ | Trapezy | Simpson |
|---|---|---|
| 4 | −0,104 | $4\text{,}6\cdot 10^{-3}$ |
| 8 | −0,0258 | $2\text{,}7\cdot 10^{-4}$ |
| 16 | −0,0064 | $1\text{,}7\cdot 10^{-5}$ |

Trapezy: podwojenie $N$ → błąd ÷4 ($h^2$). Simpson: ÷16 ($h^4$).

**Pochodna $e^x$ w $x = 1$** — błąd różnicy w przód i centralnej:

| $h$ | W przód | Centralna |
|---|---|---|
| $10^{-1}$ | 0,14 | $4\text{,}5\cdot 10^{-3}$ |
| $10^{-4}$ | $1\text{,}4\cdot 10^{-4}$ | $4\text{,}5\cdot 10^{-9}$ |
| $10^{-8}$ | $6\cdot 10^{-9}$ | $6\cdot 10^{-9}$ |
| $10^{-12}$ | $4\cdot 10^{-4}$ | $2\cdot 10^{-4}$ |

Przy $h = 10^{-12}$ błąd rośnie z powrotem — dominują zaokrąglenia. Mniejszy krok **nie zawsze** jest lepszy.

## Typowe pułapki

- **Różniczkowanie zaszumionych danych** bez wygładzania — wynik to głównie szum.
- **Zbyt mały krok** różnicy skończonej — błąd zaokrągleń.
- **Całkowanie przez nieciągłość** (zbocze sygnału prostokątnego) metodą wysokiego rzędu — zysk z rzędu znika; podziel przedział w miejscu nieciągłości.
- **Simpson z nieparzystą liczbą przedziałów** — wzór klasyczny wymaga parzystej; biblioteki obsługują to poprawką, ręczna implementacja często nie.
- **Całka z wartości bezwzględnej lub kwadratu** liczona po niepełnym okresie — wynik zależy od fazy.

## Ćwiczenie komputerowe

Ładunek pobrany przez urządzenie z profilu prądu (impuls nadawania) i szum pochodnej:

```python
import numpy as np
from scipy.integrate import trapezoid, simpson, cumulative_trapezoid, quad
from scipy.signal import savgol_filter

# zbieżność metod
for N in (4, 8, 16):
    x = np.linspace(0, np.pi, N + 1)
    print(f"N = {N:2d}: trapezy {trapezoid(np.sin(x), x) - 2:+.2e}, Simpson {simpson(np.sin(x), x=x) - 2:+.2e}")
val, err = quad(np.sin, 0, np.pi); print(f"quad: {val:.15f} (szacowany błąd {err:.1e})")

# profil prądu: uśpienie 5 µA, impuls 45 mA przez 1,3 s z narastaniem 5 ms
fs = 10_000; t = np.arange(0, 3, 1/fs)
i = 5e-6 + 45e-3*np.clip(np.minimum((t - 0.5)/5e-3, (1.8 - t)/5e-3), 0, 1)
Q = trapezoid(i, t); q_cum = cumulative_trapezoid(i, t, initial=0)
print(f"ładunek w 3 s: {Q*1e3:.2f} mC (impuls idealny 1,3 s · 45 mA = 58,5 mC)")

# pochodna sygnału z szumem
rng = np.random.default_rng(0)
fs = 100_000; t = np.arange(0, 0.01, 1/fs)
u = np.sin(2*np.pi*200*t) + rng.normal(0, 1e-3, t.size)     # szum 1 mV na sygnale 1 V
du_true = 2*np.pi*200*np.cos(2*np.pi*200*t)
du_raw = np.gradient(u, t)
du_sg = savgol_filter(u, 51, 3, deriv=1, delta=1/fs)
print(f"błąd RMS pochodnej: surowa {np.std(du_raw - du_true):.0f} V/s, Savitzky–Golay {np.std(du_sg - du_true):.1f} V/s "
      f"(amplituda pochodnej {2*np.pi*200:.0f} V/s)")
```

Szum 0,1% w sygnale daje w pochodnej surowej błąd ok. 69 V/s, czyli ok. 5% amplitudy pochodnej (1257 V/s) — szum względny wzrósł 50 razy. Filtr Savitzky'ego–Golaya zmniejsza błąd do ok. 2,4 V/s. Przy częstszym próbkowaniu błąd surowej pochodnej rośnie dalej.

## Zadania

1. Metoda trapezów z $N = 100$ daje błąd $10^{-4}$. Jakie $N$ da błąd $10^{-6}$? A metodą Simpsona (przy błędzie $10^{-4}$ dla $N = 100$)?
2. Oblicz metodą trapezów ładunek z próbek prądu co 1 ms: 0, 2, 4, 4, 2, 0 mA.
3. Sygnał próbkowany z 1 MHz ma szum 1 mV RMS. Jaki jest szum pochodnej liczonej różnicą sąsiednich próbek?
4. Dlaczego całka sinusoidy po pełnym okresie liczona trapezami jest prawie dokładna już dla kilku próbek?
5. Wyprowadź wzór Simpsona z dwóch wyników metody trapezów (ekstrapolacja Richardsona).

<details>
<summary>Odpowiedzi</summary>

1. Trapezy: błąd $\sim N^{-2}$ → $N = 1000$; Simpson: $\sim N^{-4}$ → $N = 100\cdot 100^{1/4} \approx 316$
2. $Q = 1\ \text{ms}\cdot(0/2 + 2 + 4 + 4 + 2 + 0/2)\ \text{mA} = 12$ µC
3. $\sqrt 2\cdot 1\ \text{mV}/1\ \mu\text{s} \approx 1\text{,}4$ kV/s
4. Dla funkcji okresowej całkowanej po pełnym okresie błędy na zboczach rosnących i opadających się znoszą; formalnie metoda trapezów po pełnym okresie jest dokładna dla harmonicznych o rzędzie mniejszym niż liczba próbek na okres (to związek z DFT)
5. $T_h = I + ch^2 + \ldots$, $T_{h/2} = I + ch^2/4 + \ldots$ → $I \approx (4T_{h/2} - T_h)/3$; po rozpisaniu wag daje $\tfrac{h'}{3}(f_0 + 4f_1 + f_2)$ z $h' = h/2$
</details>

## Źródła

- [MIT 18.330 Introduction to Numerical Analysis](https://ocw.mit.edu/courses/18-330-introduction-to-numerical-analysis-spring-2012/) — różniczkowanie i kwadratury
- [SciPy — Integration](https://docs.scipy.org/doc/scipy/tutorial/integrate.html)
- [Numerical Recipes](https://numerical.recipes/) — rozdziały o całkowaniu i różniczkowaniu
