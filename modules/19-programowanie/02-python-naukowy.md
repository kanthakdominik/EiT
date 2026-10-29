# 19.02 — Python naukowy: numpy, matplotlib, dane pomiarowe

## Po co to jest

Pomiar z oscyloskopu to kilkadziesiąt tysięcy próbek, symulacja — miliony. Pętla w czystym Pythonie liczy to wolno i nieczytelnie; **numpy** wykonuje operacje na całych tablicach naraz (w skompilowanym kodzie), a **matplotlib** zamienia wynik w wykres do raportu. Ten zestaw, razem ze **scipy** (filtry, optymalizacja, całkowanie), zastępuje w tym repozytorium MATLAB-a.

## Teoria w pigułce

### Tablice numpy

```python
import numpy as np
t = np.linspace(0, 1e-3, 1001)        # 1001 punktów od 0 do 1 ms
v = 5 * (1 - np.exp(-t / 100e-6))     # ładowanie kondensatora — bez pętli
```

- **Wektoryzacja:** operacje `+ - * / **`, `np.sin`, `np.exp` działają element po elemencie.
- **Rozgłaszanie (broadcasting):** tablica `(N, 1)` z tablicą `(1, M)` daje `(N, M)` — np. siatka częstotliwości × wartości kondensatora.
- **Indeksowanie logiczne:** `v[v > 3]`, `t[np.argmax(v > 0.632*5)]`.
- **Redukcje:** `v.mean()`, `v.std()`, `v.max()`, `np.sum(...)`, `np.cumsum`, `np.diff`.
- **Kształt:** `a.shape`, `a.reshape(...)`, `a.T`; mnożenie macierzy `A @ x`, rozwiązanie układu `np.linalg.solve(A, b)`.
- Liczby zespolone: `np.abs(H)`, `np.angle(H, deg=True)` — charakterystyki częstotliwościowe.

### Wykresy, które da się czytać

```python
import numpy as np
import matplotlib.pyplot as plt
t = np.linspace(0, 1e-3, 1001)
v = 5 * (1 - np.exp(-t / 100e-6))
fig, ax = plt.subplots()
ax.plot(t * 1e3, v, label="$u_C(t)$")
ax.set_xlabel("czas [ms]"); ax.set_ylabel("napięcie [V]")
ax.grid(True); ax.legend()
fig.savefig("ladowanie.png", dpi=150)
```

Zasady: opis osi z jednostkami, przeliczenie na wygodne jednostki (ms zamiast 0,001 s), `semilogx`/`loglog` dla charakterystyk, legenda, siatka. Do raportu — plik PNG/PDF z kodu, nie zrzut ekranu.

### Dane pomiarowe

- CSV z oscyloskopu: `np.loadtxt("scope.csv", delimiter=",", skiprows=2)` lub `np.genfromtxt` (brakujące wartości).
- Duże zbiory z kolumnami nazwanymi: biblioteka `pandas` (`pd.read_csv`) — wygodna, ale do większości ćwiczeń wystarczy numpy.
- Zapis: `np.savetxt`, `np.save` (format binarny `.npy`).

## Przykład rozwiązany

**Wartość skuteczna napięcia sieci z harmoniczną.** Przebieg: amplituda 325 V, 50 Hz, plus 5% trzeciej harmonicznej. Ile wynosi wartość skuteczna?

Analitycznie: $U_{RMS} = \dfrac{325}{\sqrt 2}\sqrt{1 + 0\text{,}05^2} \approx 230\text{,}10$ V. Numerycznie — jedna linijka na całym okresie:

```python
import numpy as np
t = np.arange(0, 0.02, 1e-5)                                   # jeden okres, 2000 próbek
v = 325*np.sin(2*np.pi*50*t) + 0.05*325*np.sin(2*np.pi*150*t)
print(f"U_RMS = {np.sqrt(np.mean(v**2)):.2f} V")               # 230.10 V
print(f"U_max = {v.max():.1f} V, współczynnik szczytu = {v.max()/np.sqrt(np.mean(v**2)):.3f}")
```

Uwaga: średnia musi obejmować **całkowitą liczbę okresów** — inaczej wynik zależy od miejsca ucięcia (to samo zjawisko co przeciek widma, [07.03](../07-cps-dsp/03-okna-i-analiza-widmowa.md)).

## Typowe pułapki

- **Pętla `for` po próbkach** tam, gdzie działa wektoryzacja — kod 100× wolniejszy.
- **`np.arange` z krokiem zmiennoprzecinkowym** — liczba punktów bywa o jeden inna niż oczekiwana; gdy liczy się liczba punktów, użyj `np.linspace`.
- **Dzielenie przez zero** w tablicy daje `inf`/`nan` z ostrzeżeniem, a nie błąd — sprawdzaj `np.isfinite`.
- **Widoki zamiast kopii:** wycinek `b = a[10:20]` współdzieli pamięć z `a`; modyfikacja `b` zmienia `a`.
- **Wykres bez jednostek** albo z osią w sekundach dla zjawisk mikrosekundowych.

## Ćwiczenie komputerowe

Wyznaczenie stałej czasowej z „pomiaru” ładowania kondensatora (dane z szumem), dwiema metodami — odczyt 63,2% i dopasowanie prostej do logarytmu:

```python
import numpy as np
import matplotlib.pyplot as plt

rng = np.random.default_rng(1)
tau_true, U0 = 220e-6, 5.0
t = np.linspace(0, 1.5e-3, 1500)
v = U0*(1 - np.exp(-t/tau_true)) + rng.normal(0, 0.02, t.size)   # „pomiar”

# metoda 1: pierwszy punkt powyżej 63,2% wartości końcowej
tau1 = t[np.argmax(v > 0.632*U0)]
# metoda 2: ln(U0 - v) = ln U0 - t/tau  -> prosta; tylko obszar, gdzie U0 - v jest wyraźnie > szum
mask = (U0 - v) > 0.2
slope, _ = np.polyfit(t[mask], np.log(U0 - v[mask]), 1)
tau2 = -1/slope
print(f"tau (63,2%) = {tau1*1e6:.0f} µs, tau (dopasowanie) = {tau2*1e6:.1f} µs, prawdziwe = 220 µs")

fig, ax = plt.subplots()
ax.plot(t*1e3, v, ".", ms=2, label="pomiar")
ax.plot(t*1e3, U0*(1 - np.exp(-t/tau2)), label=f"model, τ = {tau2*1e6:.0f} µs")
ax.set_xlabel("czas [ms]"); ax.set_ylabel("$u_C$ [V]"); ax.grid(True); ax.legend()
plt.show()
```

Metoda 2 korzysta z wielu punktów, więc jest mniej wrażliwa na szum niż odczyt jednego punktu.

## Zadania

1. Utwórz tablicę częstotliwości 10 Hz–1 MHz, 200 punktów logarytmicznie, i policz $\lvert H\rvert$ w dB filtru RC (R = 1 kΩ, C = 100 nF). Przy jakiej częstotliwości $\lvert H\rvert = -3$ dB?
2. Dla tablicy `v` z 10 000 próbek policz liczbę przejść przez zero z dołu do góry bez pętli.
3. Masz macierz 5 × 3 pomiarów (5 serii, 3 kanały). Jak policzyć średnią każdego kanału, a jak każdej serii?
4. Dlaczego `np.arange(1, 1.3, 0.1)` zwraca 4 elementy (łącznie z 1,3), choć koniec przedziału miał być wyłączony?
5. Narysuj na jednym rysunku dwa wykresy jeden pod drugim (moduł i faza) ze wspólną osią częstotliwości.

<details>
<summary>Odpowiedzi</summary>

1. `f = np.logspace(1, 6, 200)`, `H = 1/(1 + 2j*np.pi*f*1e3*100e-9)`, `20*np.log10(np.abs(H))`; $f_c = 1/(2\pi RC) \approx 1592$ Hz
2. `np.count_nonzero((v[:-1] < 0) & (v[1:] >= 0))`
3. `A.mean(axis=0)` — kanały (3 wartości); `A.mean(axis=1)` — serie (5 wartości)
4. Liczba elementów to `ceil((stop − start)/krok)`, a w arytmetyce zmiennoprzecinkowej $(1\text{,}3 - 1)/0\text{,}1 = 3\text{,}0000000000000004$, więc wychodzą 4 elementy. Gdy liczy się liczba punktów, używa się `np.linspace`
5. `fig, (a1, a2) = plt.subplots(2, 1, sharex=True)`, `a1.semilogx(f, 20*np.log10(abs(H)))`, `a2.semilogx(f, np.angle(H, deg=True))`
</details>

## Źródła

- [NumPy — Absolute Beginner's Guide](https://numpy.org/doc/stable/user/absolute_beginners.html)
- [Matplotlib — Tutorials](https://matplotlib.org/stable/tutorials/index.html)
- [SciPy — User Guide](https://docs.scipy.org/doc/scipy/tutorial/index.html) — `signal`, `optimize`, `integrate`
- [Scientific Python Lectures](https://lectures.scientific-python.org/) — kompletny kurs Pythona naukowego
