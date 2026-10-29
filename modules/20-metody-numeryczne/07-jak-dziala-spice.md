# 20.07 — Jak działa SPICE: symulator od podstaw

## Po co to jest

LTspice, ngspice i symulatory w KiCad robią w środku to samo: składają macierz analizy węzłowej, rozwiązują ją metodą Newtona i całkują w czasie metodą niejawną. Kto rozumie te trzy kroki, ten wie, co znaczą komunikaty „singular matrix”, „time step too small” i „no convergence”, dlaczego symulacja przetwornicy trwa godzinę i kiedy wynikowi nie należy wierzyć. Ten temat łączy tematy [03](03-uklady-rownan-liniowych.md), [02](02-rownania-nieliniowe.md) i [06](06-rownania-rozniczkowe-zwyczajne.md) w działający symulator w ok. 100 liniach Pythona.

## Teoria w pigułce

### Zmodyfikowana analiza węzłowa (MNA)

Niewiadome: napięcia węzłów (względem masy) i prądy elementów, których nie da się opisać przewodnością (źródła napięcia, cewki w DC). Każdy element dodaje do macierzy $\mathbf A$ i wektora $\mathbf z$ swój **wzorzec (stamp)**:

| Element | Wpis do macierzy |
|---|---|
| Przewodność $g$ między węzłami $a$, $b$ | $A_{aa} \mathrel{+}= g$, $A_{bb} \mathrel{+}= g$, $A_{ab} \mathrel{-}= g$, $A_{ba} \mathrel{-}= g$ |
| Źródło prądu $I$ z $a$ do $b$ | $z_a \mathrel{-}= I$, $z_b \mathrel{+}= I$ |
| Źródło napięcia $U$ ($a$ +, $b$ −) | Nowy wiersz/kolumna $k$: $A_{ak} = A_{ka} = 1$, $A_{bk} = A_{kb} = -1$, $z_k = U$ |

Układ $\mathbf A\mathbf x = \mathbf z$ rozwiązuje się rozkładem LU dla macierzy rzadkich.

### Elementy nieliniowe — model zastępczy dla Newtona

W punkcie $V_k$ dioda zastępowana jest styczną: przewodność $G_d = \dfrac{dI}{dV}\Big|_{V_k}$ równolegle ze źródłem prądu $I_{eq} = I(V_k) - G_dV_k$. Rozwiązujemy liniowy obwód, dostajemy nowe $V_{k+1}$, powtarzamy aż do zbieżności. To jest dokładnie metoda Newtona dla całego układu — macierz z wpisanymi $G_d$ to jakobian. Zabezpieczenia: **ograniczanie napięcia złącza** między iteracjami (bez tego wykładnik „wystrzeliwuje” — [20.02](02-rownania-nieliniowe.md)), $g_{min}$ równolegle do złącz, source stepping.

### Elementy reaktancyjne — model zastępczy dla kroku czasowego

Metoda niejawna zamienia kondensator w każdym kroku na przewodność i źródło prądu:

| Metoda | Kondensator $C$ | Cewka $L$ |
|---|---|---|
| Euler wsteczny | $G = C/h$, $I_{eq} = (C/h)\,u_n$ | $G = h/L$, $I_{eq} = i_n$ |
| Trapezy | $G = 2C/h$, $I_{eq} = (2C/h)\,u_n + i_n$ | $G = h/(2L)$, $I_{eq} = i_n + \tfrac{h}{2L}u_n$ |

Każdy krok czasowy to więc **analiza DC obwodu rezystancyjnego** (z Newtonem, jeśli są nieliniowości). Krok dobiera się na podstawie szacunku błędu obcięcia; po nieciągłościach źródeł (punkty przełączeń) SPICE skraca krok i robi pierwszy krok Eulerem wstecznym.

### Analiza AC

Linearyzacja w punkcie pracy, potem dla każdej częstotliwości macierz zespolona: kondensator $j\omega C$, cewka $1/(j\omega L)$. Jedno rozwiązanie układu liniowego na każdą częstotliwość — dlatego `.ac` jest szybka.

### Co znaczą komunikaty

| Komunikat | Przyczyna |
|---|---|
| *Singular matrix* | Węzeł bez ścieżki DC do masy; pętla idealnych źródeł napięcia lub cewek; źródło prądu szeregowo z kondensatorem |
| *No convergence in DC* | Newton nie zbiega (silna nieliniowość, sprzężenie zwrotne, histereza) — pomaga `.nodeset`, `.ic`, source stepping |
| *Time step too small* | Krok zmalał do minimum: ostre przełączenie, nieciągły model, nierealistyczny obwód (idealny klucz bez pojemności) |

## Przykład rozwiązany

**Prostownik jednopołówkowy policzony przez mini-SPICE:** źródło $10\sin(2\pi\cdot 50t)$ V, dioda ($I_S = 10^{-14}$ A), $C = 100$ µF, $R = 1$ kΩ, krok 20 µs, metoda trapezów.

Wynik symulacji (stan ustalony): $U_{max} = 9\text{,}28$ V, $U_{min} = 7\text{,}75$ V, tętnienia 1,52 V p-p.

Sprawdzenie ręczne: szczyt ≈ $10 - 0\text{,}7 = 9\text{,}3$ V ✓; tętnienia ze wzoru przybliżonego $\Delta U \approx \dfrac{I}{fC} = \dfrac{9\text{,}3\ \text{mA}}{50\cdot 100\ \mu\text{F}} = 1\text{,}86$ V — wzór zawyża, bo zakłada rozładowanie przez cały okres stałym prądem; w rzeczywistości kondensator rozładowuje się ok. 16–17 ms, a prąd maleje razem z napięciem: $9\text{,}28\,(1 - e^{-16\text{,}5\ \text{ms}/100\ \text{ms}}) \approx 1\text{,}4$ V. Symulator i dokładniejszy rachunek się zgadzają.

## Typowe pułapki

- **Idealne elementy** (klucz o zerowej rezystancji, źródło bez rezystancji wewnętrznej równolegle z kondensatorem) — macierz osobliwa lub nieskończone prądy; dodaj realne rezystancje pasożytnicze.
- **Wiara w wynik bez sprawdzenia kroku** — zmniejsz `maxstep` dwukrotnie; jeśli wynik się zmienia, był niedokładny.
- **Trapezy po nieciągłości** — bez pierwszego kroku Eulerem wstecznym mini-SPICE daje dla RC $u_C(1\ \text{ms}) = 0\text{,}613$ V zamiast 0,632 V (źródło skokowe uśrednione z wartością sprzed skoku).
- **Złe warunki początkowe** — obwód z kilkoma stanami stabilnymi (przerzutnik, oscylator) startuje w przypadkowym; oscylator idealnie symetryczny może nie wystartować bez zaburzenia.
- **Modele producentów spoza zakresu** (temperatura, częstotliwość) — symulator policzy cokolwiek dokładnie, ale model nie opisuje rzeczywistości.

## Ćwiczenie komputerowe

Kompletny mini-SPICE: rezystory, kondensatory, źródła napięcia i prądu, diody; analiza DC (Newton z ograniczaniem napięcia złącza) i stanów nieustalonych (Euler wsteczny lub trapezy).

```python
import numpy as np

VT = 0.025852

class Circuit:
    """Węzły numerowane 1..N, masa = 0. Elementy: R, C, V (źródło napięcia, funkcja czasu), I, D."""
    def __init__(self):
        self.R, self.C, self.V, self.I, self.D = [], [], [], [], []
        self.nodes = 0
    def _n(self, *ns): self.nodes = max(self.nodes, *ns)
    def res(self, a, b, r):        self._n(a, b); self.R.append((a, b, r))
    def cap(self, a, b, c):        self._n(a, b); self.C.append((a, b, c))
    def vsrc(self, a, b, v):       self._n(a, b); self.V.append((a, b, v if callable(v) else (lambda t, v=v: v)))
    def isrc(self, a, b, i):       self._n(a, b); self.I.append((a, b, i))        # prąd płynie z a do b przez źródło
    def diode(self, a, k, Is=1e-14, n=1.0): self._n(a, k); self.D.append((a, k, Is, n))

def stamp_g(A, a, b, g):
    """Przewodność g między węzłami a i b (indeks 0 = masa jest pomijany)."""
    if a: A[a-1, a-1] += g
    if b: A[b-1, b-1] += g
    if a and b: A[a-1, b-1] -= g; A[b-1, a-1] -= g

def stamp_i(z, a, b, i):
    """Źródło prądu i płynące z węzła a do węzła b (wypływa z a, wpływa do b)."""
    if a: z[a-1] -= i
    if b: z[b-1] += i

def solve(ckt, t=0.0, x0=None, cap_state=None, h=None, method="be", tol=1e-9, kmax=200):
    """Jeden punkt pracy (DC) lub jeden krok czasowy (gdy podano h i stan kondensatorów)."""
    N, M = ckt.nodes, len(ckt.V)
    x = np.zeros(N + M) if x0 is None else x0.copy()
    v = lambda x, node: x[node-1] if node else 0.0
    vd_lin = [v(x, a) - v(x, k) for a, k, _, _ in ckt.D]   # napięcia, w których linearyzujemy diody
    for it in range(1, kmax + 1):
        A = np.zeros((N + M, N + M)); z = np.zeros(N + M)
        for a, b, r in ckt.R: stamp_g(A, a, b, 1/r)
        for a, b, i in ckt.I: stamp_i(z, a, b, i)
        for j, (a, b, f) in enumerate(ckt.V):            # MNA: wiersz i kolumna na prąd źródła
            row = N + j
            if a: A[a-1, row] += 1; A[row, a-1] += 1
            if b: A[b-1, row] -= 1; A[row, b-1] -= 1
            z[row] = f(t)
        if h is not None:                                 # model zastępczy kondensatora
            for m, (a, b, c) in enumerate(ckt.C):
                u_old, i_old = cap_state[m]
                if method == "be": geq, ieq = c/h, c/h*u_old
                else:              geq, ieq = 2*c/h, 2*c/h*u_old + i_old   # trapezy
                stamp_g(A, a, b, geq); stamp_i(z, b, a, ieq)
        for d, (a, k, Is, n) in enumerate(ckt.D):        # model zastępczy diody: G_d równolegle ze źródłem
            vd = vd_lin[d]
            e = np.exp(vd/(n*VT)); idd = Is*(e - 1); gd = Is*e/(n*VT) + 1e-12
            stamp_g(A, a, k, gd); stamp_i(z, a, k, idd - gd*vd)
        x_new = np.linalg.solve(A, z)
        if not ckt.D:
            return x_new, 1                               # obwód liniowy: jedno rozwiązanie
        limited = False
        for d, (a, k, _, _) in enumerate(ckt.D):         # ograniczanie napięcia złącza (jak pnjlim w SPICE)
            vd_new = v(x_new, a) - v(x_new, k)
            if vd_new > 0.5 and vd_new - vd_lin[d] > 0.1:
                vd_new = max(vd_lin[d] + 0.1, 0.5); limited = True
            vd_lin[d] = vd_new
        converged = np.max(np.abs(x_new - x)) < tol and not limited
        x = x_new
        if converged:
            return x, it
    raise RuntimeError("brak zbieżności Newtona")

def transient(ckt, t_stop, h, method="be"):
    x, _ = solve(ckt, 0.0)
    v = lambda x, node: x[node-1] if node else 0.0
    state = [(v(x, a) - v(x, b), 0.0) for a, b, c in ckt.C]
    ts, xs = [0.0], [x]
    for n in range(1, int(round(t_stop/h)) + 1):
        t = n*h
        m = "be" if (n == 1 and method == "tr") else method   # pierwszy krok po starcie: Euler wsteczny
        x, _ = solve(ckt, t, x, state, h, m)
        new = []
        for (a, b, c), (u_old, i_old) in zip(ckt.C, state):
            u = v(x, a) - v(x, b)
            i = c/h*(u - u_old) if m == "be" else 2*c/h*(u - u_old) - i_old
            new.append((u, i))
        state = new; ts.append(t); xs.append(x)
    return np.array(ts), np.array(xs)

# 1) punkt pracy: 5 V -> 1 kΩ -> dioda
c1 = Circuit(); c1.vsrc(1, 0, 5.0); c1.res(1, 2, 1e3); c1.diode(2, 0)
x, it = solve(c1); print(f"DC: V(dioda) = {x[1]:.4f} V, I = {-x[2]*1e3:.3f} mA, iteracje Newtona: {it}")

# 2) RC: skok 1 V w t = 0+, R = 1 kΩ, C = 1 µF (tau = 1 ms)
c2 = Circuit(); c2.vsrc(1, 0, lambda t: 1.0 if t > 0 else 0.0); c2.res(1, 2, 1e3); c2.cap(2, 0, 1e-6)
for method in ("be", "tr"):
    t, xs = transient(c2, 5e-3, 0.1e-3, method)
    k = int(round(1e-3/0.1e-3))
    print(f"RC ({method}): u_C(1 ms) = {xs[k, 1]:.5f} V (dokładnie {1 - np.exp(-1):.5f})")

# 3) prostownik jednopołówkowy: 10 V / 50 Hz, dioda, C = 100 µF, R = 1 kΩ
c3 = Circuit(); c3.vsrc(1, 0, lambda t: 10*np.sin(2*np.pi*50*t)); c3.diode(1, 2); c3.cap(2, 0, 100e-6); c3.res(2, 0, 1e3)
t, xs = transient(c3, 0.2, 20e-6, "tr")
u = xs[:, 1]; last = t > 0.16
print(f"prostownik: U_max = {u[last].max():.2f} V, U_min = {u[last].min():.2f} V, tętnienia = {u[last].max() - u[last].min():.2f} V p-p")
```

Oczekiwane wyniki: DC — 0,6925 V i 4,307 mA w 8 iteracjach (start od zera, dzięki ograniczaniu napięcia złącza); RC z krokiem 0,1 ms — Euler wsteczny 0,6145 V, trapezy 0,6307 V (dokładnie 0,6321 V; błąd trapezów pochodzi głównie z pierwszego kroku Eulerem); prostownik — jak w przykładzie.

Rozszerzenia (projekt modułowy): cewka (model zastępczy z tabeli), analiza AC, adaptacyjny krok czasowy z oszacowaniem błędu przez porównanie Eulera i trapezów, wczytywanie prostej listy połączeń w formacie SPICE (`R1 1 2 1k`).

## Zadania

1. Zapisz macierz MNA dla obwodu: źródło 5 V (węzeł 1), $R_1 = 1$ kΩ (1–2), $R_2 = 1$ kΩ (2–masa). Rozwiąż ją.
2. Jaki jest model zastępczy kondensatora 1 µF w metodzie Eulera wstecznego z krokiem 10 µs, jeśli w poprzednim kroku miał 2 V?
3. Dlaczego obwód z kondensatorem szeregowym między węzłami 1 i 2, gdy węzeł 2 nie ma innej ścieżki do masy, daje „singular matrix” w DC? Jak to naprawia $g_{min}$?
4. Ile układów równań liniowych rozwiązuje symulacja 10 ms z krokiem 1 µs, jeśli Newton potrzebuje średnio 3 iteracji na krok?
5. Dlaczego analiza AC wzmacniacza tranzystorowego wymaga wcześniej analizy DC?

<details>
<summary>Odpowiedzi</summary>

1. Niewiadome $V_1, V_2, I_U$ (mS, V, mA): $\begin{bmatrix} 1 & -1 & 1 \\ -1 & 2 & 0 \\ 1 & 0 & 0 \end{bmatrix}\mathbf x = \begin{bmatrix} 0 \\ 0 \\ 5 \end{bmatrix}$ → $V_1 = 5$ V, $V_2 = 2\text{,}5$ V, $I_U = -2\text{,}5$ mA
2. $G = C/h = 0\text{,}1$ S (10 Ω) równolegle ze źródłem prądu $I_{eq} = 0\text{,}1\cdot 2 = 0\text{,}2$ A
3. W DC kondensator to przerwa — wiersz węzła 2 w macierzy ma same zera (lub węzeł nie ma odniesienia), macierz jest osobliwa. $g_{min}$ (np. $10^{-12}$ S) od każdego węzła do masy daje niezerowy element na przekątnej i jednoznaczne (choć fizycznie umowne) rozwiązanie
4. $10^4$ kroków × 3 = ok. 30 000 (plus odrzucone kroki przy adaptacji)
5. Parametry małosygnałowe (transkonduktancja, rezystancje, pojemności złącz) zależą od punktu pracy; analiza AC to linearyzacja wokół niego
</details>

## Źródła

- [Ngspice — dokumentacja](https://ngspice.sourceforge.io/docs.html) — rozdziały o analizach i opcjach symulatora
- [MIT 6.002 Circuits and Electronics](https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/) — analiza węzłowa, modele przyrostowe
- L. O. Chua, P.-M. Lin — *Computer-Aided Analysis of Electronic Circuits* (płatna)
- L. W. Nagel — *SPICE2: A Computer Program to Simulate Semiconductor Circuits* (raport UC Berkeley, 1975) — oryginalny opis algorytmów SPICE
