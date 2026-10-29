# M06.04 — Sterowanie nieliniowe: Lapunow, linearyzacja przez sprzężenie, sterowanie ślizgowe

## Po co to jest

Linearyzacja w punkcie pracy działa, dopóki obiekt pozostaje blisko tego punktu. Ramię robota wykonujące duże ruchy, wahadło, silnik z nasyceniem magnetycznym, przekształtnik w trybie przerywanego prądu czy dron w manewrze są nieliniowe w całym zakresie pracy. Teoria Lapunowa pozwala dowodzić stabilności bez rozwiązywania równań, linearyzacja przez sprzężenie „usuwa” nieliniowość znaną z modelu, a sterowanie ślizgowe daje odporność na nieznane zakłócenia i błędy modelu o ograniczonej wielkości.

## Teoria w pigułce

### Stabilność w sensie Lapunowa

Dla $\dot x = f(x)$, $f(0) = 0$: jeśli istnieje funkcja $V(x) > 0$ ($V(0) = 0$) taka, że $\dot V = \nabla V^Tf(x) < 0$ dla $x \neq 0$, to punkt równowagi jest asymptotycznie stabilny (globalnie, gdy $V \to \infty$ przy $\lVert x\rVert \to \infty$). **Zasada LaSalle'a:** przy $\dot V \leq 0$ trajektorie dążą do największego zbioru niezmienniczego w $\{\dot V = 0\}$. Dla układów liniowych $V = x^TPx$ z równania Lapunowa $A^TP + PA = -Q$. Funkcje Lapunowa szuka się z energii (układy mechaniczne, elektryczne) lub numerycznie (programowanie półokreślone, SOS). **Obszar przyciągania** szacuje się jako zbiór poziomicowy $\{V \leq c\}$, w którym $\dot V < 0$.

### Linearyzacja przez sprzężenie zwrotne

Dla obiektu $\ddot\theta = f(\theta, \dot\theta) + g(\theta)u$ sterowanie $u = \dfrac{1}{g}\left(v - f\right)$ daje $\ddot\theta = v$ — układ liniowy, dla którego $v = \ddot\theta_r - K_d\dot e - K_pe$ zapewnia zadaną dynamikę uchybu (computed torque w robotyce). Ogólnie: stopień względny, postać normalna, **dynamika zer** (musi być stabilna). Wada: wymaga dokładnego modelu — błąd masy czy tarcia zostaje w pętli jako zakłócenie.

### Sterowanie ślizgowe

Powierzchnia $s = \dot e + \lambda e$ (na niej uchyb maleje jak $e^{-\lambda t}$). Sterowanie $u = u_{eq} - k\,\mathrm{sgn}(s)$, gdzie $u_{eq}$ wynika z modelu nominalnego. Dla $V = \tfrac12 s^2$: $\dot V = s\dot s \leq -\eta\lvert s\rvert$ — **warunek osiągalności** — jeśli $k$ przewyższa ograniczenie niepewności modelu. Funkcja $\mathrm{sgn}$ powoduje **drgania** (chattering) — w praktyce zastępuje się ją nasyceniem $\mathrm{sat}(s/\phi)$ (warstwa przyścienna o grubości $\phi$) kosztem małego uchybu ustalonego, lub stosuje algorytmy wyższego rzędu (super-twisting).

### Inne narzędzia

- **Backstepping** — konstrukcja funkcji Lapunowa krok po kroku dla układów w postaci kaskadowej.
- **Funkcja opisująca** — przybliżona analiza cykli granicznych z nieliniowościami statycznymi (przekaźnik, nasycenie, luz); podstawa autotuningu przekaźnikowego PID.
- **Sterowanie energetyczne / pasywność** — np. rozhuśtanie wahadła przez sterowanie energią, przełączenie na LQR przy górnym położeniu.

## Przykład rozwiązany

**Wahadło sterowane momentem** śledzi sinusoidę o amplitudzie 1,2 rad (69°) — daleko od zakresu liniowego. Model do projektu: $m = 1$ kg, tarcie 0,1; obiekt rzeczywisty: masa o 30% większa, tarcie 0,25. Uchyb po stanie przejściowym:

| Regulator | Uchyb RMS | Uchyb maks. | max $\lvert u\rvert$ |
|---|---|---|---|
| PD liniowy ($K_p = 40$, $K_d = 10$) | 164 mrad | 226 mrad | 9,2 N·m |
| Linearyzacja przez sprzężenie (model nominalny) | 66 mrad | 90 mrad | 10,0 N·m |
| Ślizgowy ($\lambda = 5$, $k = 8$, $\phi = 0\text{,}05$) | 2,2 mrad | 3,0 mrad | 10,3 N·m |

Linearyzacja przez sprzężenie usuwa nieliniowość $\sin\theta$, ale błąd masy zostaje. Sterownik ślizgowy, przy porównywalnym momencie, zmniejsza uchyb 30 razy, bo człon $k\,\mathrm{sat}(s/\phi)$ kompensuje niepewność modelu (oszacowanie jej momentu: 3,4 N·m < $k$ = 8 N·m).

## Typowe pułapki

- **Wniosek o stabilności globalnej z linearyzacji** — linearyzacja mówi tylko o otoczeniu punktu.
- **$\dot V \leq 0$ zamiast $< 0$ bez zasady LaSalle'a** — dowodzi tylko stabilności, nie zbieżności.
- **Linearyzacja przez sprzężenie z niestabilną dynamiką zer** — wyjście się zgadza, a stan wewnętrzny rośnie bez ograniczeń.
- **Sterowanie ślizgowe z $\mathrm{sgn}$ w układzie dyskretnym** — drgania o częstotliwości próbkowania, grzanie siłowników, wzbudzanie modów niemodelowanych.
- **Za duże $k$** — zbędnie duże sterowanie i szum; dobiera się je z oszacowania niepewności z zapasem.

## Ćwiczenie komputerowe

PD, linearyzacja przez sprzężenie i sterowanie ślizgowe dla wahadła z błędnym modelem:

```python
import numpy as np

# Wahadło sterowane momentem: m l^2 th'' + b th' + m g l sin(th) = u
g, l = 9.81, 1.0
m_nom, b_nom = 1.0, 0.1                     # model użyty do projektu
m_real, b_real = 1.3, 0.25                  # obiekt rzeczywisty: +30% masy, większe tarcie
ref = lambda t: (1.2 * np.sin(t), 1.2 * np.cos(t), -1.2 * np.sin(t))   # th_r, th_r', th_r''

def dynamika(x, u):
    th, w = x
    return np.array([w, (u - b_real * w - m_real * g * l * np.sin(th)) / (m_real * l**2)])

def pd(t, x):                                # PD z kompensacją grawitacji w punkcie pracy 0 (liniowy)
    r, rd, _ = ref(t)
    return 40 * (r - x[0]) + 10 * (rd - x[1])

def linearyzacja(t, x):                      # linearyzacja przez sprzężenie (computed torque), model nominalny
    r, rd, rdd = ref(t)
    e, ed = x[0] - r, x[1] - rd
    v = rdd - 10 * ed - 25 * e               # bieguny uchybu w -5, -5
    return m_nom * l**2 * v + b_nom * x[1] + m_nom * g * l * np.sin(x[0])

def slizgowy(t, x, lam=5.0, k=8.0, phi=0.05):
    r, rd, rdd = ref(t)
    e, ed = x[0] - r, x[1] - rd
    s = ed + lam * e                          # powierzchnia ślizgowa
    u_eq = m_nom * l**2 * (rdd - lam * ed) + b_nom * x[1] + m_nom * g * l * np.sin(x[0])
    return u_eq - k * np.clip(s / phi, -1, 1)  # nasycenie zamiast sgn: warstwa przyścienna

def symuluj(reg, T=20.0, h=1e-3):
    x = np.array([0.3, 0.0])
    e_hist, u_hist = [], []
    for i in range(int(T / h)):
        t = i * h
        u = reg(t, x)
        k1 = dynamika(x, u); k2 = dynamika(x + h / 2 * k1, u)
        k3 = dynamika(x + h / 2 * k2, u); k4 = dynamika(x + h * k3, u)
        x = x + h / 6 * (k1 + 2 * k2 + 2 * k3 + k4)
        e_hist.append(x[0] - ref(t + h)[0]); u_hist.append(u)
    e, u = np.array(e_hist), np.array(u_hist)
    ust = slice(int(5 / h), None)            # po stanie przejściowym
    return np.sqrt(np.mean(e[ust]**2)), np.max(np.abs(e[ust])), np.max(np.abs(u[ust]))

for nazwa, reg in (("PD liniowy", pd), ("linearyzacja przez sprzężenie", linearyzacja),
                   ("ślizgowy z warstwą przyścienną", slizgowy)):
    rms, emax, umax = symuluj(reg)
    print(f"{nazwa:31s}: uchyb RMS {rms * 1e3:6.2f} mrad, max {emax * 1e3:6.2f} mrad, max|u| {umax:5.1f} N m")

# Dobór k: moment niepewności modelu musi być mniejszy od k (wtedy V = s^2/2 maleje poza warstwą)
th = np.linspace(-1.3, 1.3, 200)
niep = np.abs((m_real - m_nom) * (g * l * np.sin(th) + l**2 * 1.2)) + (b_real - b_nom) * 1.3
print(f"oszacowanie momentu niepewności: max {niep.max():.1f} N m < k = 8 N m — warunek osiągalności spełniony")
```

Rozszerzenia: zastąp $\mathrm{sat}$ funkcją $\mathrm{sgn}$ i wykonaj sterowanie z próbkowaniem 1 kHz — zaobserwuj drgania sygnału $u$; zmniejszaj $k$ poniżej oszacowania niepewności i sprawdź, kiedy uchyb rośnie; dla wahadła bez sterowania z tarciem wykaż numerycznie, że energia mechaniczna jest funkcją Lapunowa ($\dot V \leq 0$).

## Zadania

1. Pokaż, że $V = \tfrac12 x^2$ jest funkcją Lapunowa dla $\dot x = -x^3$. Czy zbieżność jest wykładnicza?
2. Dla $\dot x = Ax$, $A = \begin{bmatrix}0 & 1\\ -2 & -3\end{bmatrix}$ rozwiąż $A^TP + PA = -I$ (wystarczy $P$ numerycznie) i sprawdź dodatnią określoność.
3. Dlaczego linearyzacja przez sprzężenie wymaga dokładnej znajomości $g(\theta)$ i $f$?
4. Co oznacza warunek $s\dot s \leq -\eta\lvert s\rvert$ i ile czasu zajmuje osiągnięcie powierzchni ślizgowej z $s(0) = s_0$?
5. Jaki uchyb ustalony powoduje warstwa przyścienna o grubości $\phi$ przy $\lambda = 5$?

<details>
<summary>Odpowiedzi</summary>

1. $\dot V = x\dot x = -x^4 < 0$ dla $x \neq 0$ — stabilność asymptotyczna globalna; zbieżność nie jest wykładnicza ($x(t) = x_0/\sqrt{1 + 2x_0^2t}$, maleje jak $1/\sqrt t$)
2. $P = \begin{bmatrix}1\text{,}25 & 0\text{,}25\\ 0\text{,}25 & 0\text{,}25\end{bmatrix}$ (np. `scipy.linalg.solve_continuous_lyapunov(A.T, -np.eye(2))`); wartości własne ok. 0,19 i 1,31 > 0
3. Kasowanie nieliniowości jest dokładne tylko wtedy, gdy model jest dokładny; błąd $f$ lub $g$ pozostaje jako nieliniowe zakłócenie w „zlinearyzowanym” układzie
4. $\tfrac{d}{dt}\tfrac12 s^2 \leq -\eta\lvert s\rvert$ ⇒ $\tfrac{d}{dt}\lvert s\rvert \leq -\eta$ — $\lvert s\rvert$ maleje co najmniej liniowo; powierzchnia jest osiągana w czasie skończonym $t \leq \lvert s_0\rvert/\eta$
5. Wewnątrz warstwy $\lvert s\rvert \leq \phi$, a w stanie quasi-ustalonym $\lvert e\rvert \lesssim \phi/\lambda = 0\text{,}01$ rad dla $\phi = 0\text{,}05$ (w symulacji uchyb był mniejszy, bo niepewność nie jest maksymalna przez cały czas)
</details>

## Źródła

- [R. Tedrake — Underactuated Robotics](https://underactuated.mit.edu/) — funkcje Lapunowa, sterowanie energetyczne, linearyzacja przez sprzężenie
- [MIT 6.241J Dynamic Systems and Control (2011)](https://ocw.mit.edu/courses/6-241j-dynamic-systems-and-control-spring-2011/) — stabilność w sensie Lapunowa
- [K. J. Åström, R. M. Murray — Feedback Systems (wyd. 2, darmowe)](https://www.cds.caltech.edu/~murray/amwiki/Second_Edition.html)
- H. K. Khalil — *Nonlinear Systems* (płatna); J.-J. Slotine, W. Li — *Applied Nonlinear Control* (płatna)
