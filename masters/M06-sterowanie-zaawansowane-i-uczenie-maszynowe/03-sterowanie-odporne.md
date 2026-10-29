# M06.03 — Sterowanie odporne: funkcje wrażliwości i norma H∞

## Po co to jest

Model obiektu nigdy nie jest dokładny: wzmocnienie zmienia się z temperaturą i zużyciem, opóźnienia z obciążeniem, dynamika wysokich częstotliwości jest pominięta. Regulator dobrany „na model” może w rzeczywistości oscylować. Sterowanie odporne odpowiada na pytania: jak duże błędy modelu regulator toleruje, jakie są fundamentalne ograniczenia (których nie przeskoczy żaden regulator) i jak projektować z gwarancją stabilności dla całej rodziny obiektów. Wielkość $M_s$ — szczyt funkcji wrażliwości — jest najlepszą pojedynczą miarą „zdrowia” pętli regulacji.

## Teoria w pigułce

### Funkcje wrażliwości

Dla pętli $L = GC$:

- **Wrażliwość** $S = \dfrac{1}{1 + L}$ — od zakłócenia na wyjściu do wyjścia; mówi, ile regulacja tłumi zakłócenia (małe $\lvert S\rvert$ przy niskich częstotliwościach).
- **Komplementarna wrażliwość** $T = \dfrac{L}{1 + L}$ — od wartości zadanej (i szumu pomiaru) do wyjścia. $S + T = 1$: nie da się mieć obu małych przy tej samej częstotliwości.
- $M_s = \lVert S\rVert_\infty$ to odwrotność najmniejszej odległości charakterystyki Nyquista od punktu −1. Gwarantuje zapasy: $\mathrm{GM} \geq \dfrac{M_s}{M_s - 1}$, $\mathrm{PM} \geq 2\arcsin\dfrac{1}{2M_s}$. Typowo $M_s = 1\text{,}2$–$2$ ($M_s = 2$: GM ≥ 2, PM ≥ 29°).

### Ograniczenia fundamentalne

- **Całka Bodego** (efekt łóżka wodnego): $\int_0^\infty\ln\lvert S(j\omega)\rvert d\omega = \pi\sum\mathrm{Re}\,p_i$ (bieguny niestabilne obiektu; dla stabilnego — zero, przy pętli o względnym stopniu ≥ 2). Tłumienie w jednym paśmie oznacza wzmocnienie w innym.
- **Opóźnienie** $\theta$ ogranicza pasmo: $\omega_c \lesssim 1/\theta$; **zero w prawej półpłaszczyźnie** $z$ — $\omega_c \lesssim z/2$; **niestabilny biegun** $p$ — $\omega_c \gtrsim 2p$.

### Niepewność i odporna stabilność

Model niepewności multiplikatywnej: $G_p = G(1 + W\Delta)$, $\lVert\Delta\rVert_\infty \leq 1$. Z **twierdzenia o małym wzmocnieniu**: pętla jest stabilna dla wszystkich takich obiektów wtedy i tylko wtedy, gdy

$$\lvert W(j\omega)T(j\omega)\rvert < 1\quad\text{dla wszystkich }\omega.$$

Odporna jakość: $\lvert W_PS\rvert + \lvert WT\rvert < 1$. Dla niepewności strukturalnej (kilka niezależnych parametrów) — analiza $\mu$ (wartość osobliwa strukturalna).

### Norma H∞ i synteza

$\lVert G\rVert_\infty = \sup_\omega\bar\sigma(G(j\omega))$ — największe wzmocnienie energii sygnału. Liczy się ją dokładnie bisekcją: $\gamma > \lVert G\rVert_\infty$ wtedy i tylko wtedy, gdy macierz Hamiltona $\begin{bmatrix}A & BB^T/\gamma^2\\ -C^TC & -A^T\end{bmatrix}$ (dla $D = 0$) nie ma wartości własnych na osi urojonej. **Synteza H∞** (mieszana wrażliwość: $\min\left\lVert\begin{smallmatrix}W_PS\\ W_uCS\\ WT\end{smallmatrix}\right\rVert_\infty$) prowadzi do dwóch równań Riccatiego (Doyle–Glover–Khargonekar–Francis); kształtowanie pętli metodą McFarlane'a–Glovera to praktyczna wersja dla inżyniera.

## Przykład rozwiązany

Obiekt $G = \dfrac{e^{-0\text{,}2s}}{s + 1}$, dwa regulatory PI z reguł SIMC (Skogestad):

| Regulator | $K_c$, $T_i$ | $M_s$ | GM | PM | $\omega_c$ | zapas opóźnienia | niestabilnych z 300 obiektów |
|---|---|---|---|---|---|---|---|
| agresywny ($\tau_c = \theta$) | 2,50; 1,00 s | 1,59 | 3,14 | 61° | 2,50 rad/s | 0,43 s | 1 |
| ostrożny ($\tau_c = 3\theta$) | 1,25; 1,00 s | 1,25 | 6,28 | 76° | 1,25 rad/s | 1,06 s | 0 |

Obiekty losowane: wzmocnienie 0,7–1,5, stała czasowa 0,8–1,2 s, opóźnienie 0,15–0,4 s. Regulator agresywny traci stabilność w narożniku niepewności (dla $k = 1\text{,}5$, $T = 0\text{,}8$ s, $\theta = 0\text{,}4$ s zapas wzmocnienia spada do 0,88), ostrożny — nigdy, kosztem dwukrotnie węższego pasma. Ograniczenia z $M_s$: GM ≥ 2,7 i PM ≥ 37° (agresywny), GM ≥ 5 i PM ≥ 47° (ostrożny) — zgodnie z wartościami rzeczywistymi.

Norma H∞ układu oscylacyjnego ($\zeta = 0\text{,}1$) metodą Hamiltona: 5,0252 — tyle samo co z gęstej siatki i ze wzoru $1/(2\zeta\sqrt{1 - \zeta^2})$.

## Typowe pułapki

- **Ocena tylko zapasu fazy** — pętla może mieć dobry PM i mały GM (lub odwrotnie); $M_s$ łączy oba.
- **Testy odporności tylko w środku przedziałów** — najgorsze przypadki leżą w narożnikach (duże wzmocnienie + duże opóźnienie).
- **Wymaganie małego $S$ w szerokim paśmie przy opóźnieniu lub zerze nieminimalnofazowym** — niewykonalne; łóżko wodne „wypycha” $\lvert S\rvert$ gdzie indziej.
- **Synteza H∞ bez sensownych wag** — regulator wysokiego rzędu o dobrych normach i złym działaniu; wagi to specyfikacja, nie parametry strojenia „na ślepo”.
- **Norma H∞ z rzadkiej siatki częstotliwości** dla układu o ostrych rezonansach — niedoszacowana; metoda Hamiltona jest dokładna.

## Ćwiczenie komputerowe

Funkcje wrażliwości, zapasy i test odporności Monte Carlo dla dwóch regulatorów PI; norma H∞ metodą Hamiltona:

```python
import numpy as np

# Obiekt inercyjny z opóźnieniem G = k e^{-theta s}/(T s + 1), regulator PI nastawiony metodą SIMC
k, T, theta = 1.0, 1.0, 0.2
w = np.logspace(-2, 2, 20000)
s = 1j * w
G = lambda s, k=k, T=T, th=theta: k * np.exp(-th * s) / (T * s + 1)

def pi_simc(tau_c):
    Kc = T / (k * (tau_c + theta))
    Ti = min(T, 4 * (tau_c + theta))
    return Kc, Ti

def zapasy(L):
    S, Tc = 1 / (1 + L), L / (1 + L)
    i_c = np.argmin(np.abs(np.abs(L) - 1))                        # częstotliwość odcięcia
    pm = 180 + np.degrees(np.angle(L[i_c]))
    ph = np.unwrap(np.angle(L))
    i_180 = np.argmin(np.abs(ph + np.pi))
    gm = 1 / np.abs(L[i_180])
    return np.max(np.abs(S)), np.max(np.abs(Tc)), gm, pm, w[i_c]

rng = np.random.default_rng(3)
for nazwa, tau_c in (("agresywny (tau_c = theta)", theta), ("ostrożny (tau_c = 3 theta)", 3 * theta)):
    Kc, Ti = pi_simc(tau_c)
    C = Kc * (1 + 1 / (Ti * s))
    L = G(s) * C
    Ms, Mt, gm, pm, wc = zapasy(L)
    dt_max = np.radians(pm) / wc                                   # dopuszczalny przyrost opóźnienia
    # Niepewność: wzmocnienie 0,7–1,5, opóźnienie 0,15–0,4 s, stała czasowa 0,8–1,2 s
    niestabilne = 0
    for _ in range(300):
        kp, Tp, thp = rng.uniform(0.7, 1.5), rng.uniform(0.8, 1.2), rng.uniform(0.15, 0.4)
        _, _, gm_p, pm_p, _ = zapasy(G(s, kp, Tp, thp) * C)
        niestabilne += gm_p < 1 or pm_p < 0          # dla tej pętli (faza monotoniczna) równoważne Nyquistowi
    print(f"{nazwa:27s}: Kc = {Kc:.2f}, Ti = {Ti:.2f} s | Ms = {Ms:.2f}, Mt = {Mt:.2f}, GM = {gm:.2f},"
          f" PM = {pm:.0f} st., wc = {wc:.2f} rad/s, zapas opóźnienia {dt_max:.2f} s,"
          f" niestabilnych {niestabilne}/300")

# Norma H-nieskończoność układu w przestrzeni stanów: bisekcja z macierzą Hamiltona
def hinf(A, B, C, tol=1e-6):
    lo, hi = 1e-6, 1e6
    while hi - lo > tol * lo:
        gam = np.sqrt(lo * hi)
        H = np.block([[A, B @ B.T / gam**2], [-C.T @ C, -A.T]])
        if np.any(np.abs(np.linalg.eigvals(H).real) < 1e-8):       # wartości własne na osi urojonej
            lo = gam                                                # gam < ||G||_inf
        else:
            hi = gam
    return np.sqrt(lo * hi)

zeta, w0 = 0.1, 1.0
A = np.array([[0, 1], [-w0**2, -2 * zeta * w0]]); B = np.array([[0], [w0**2]]); C = np.array([[1.0, 0]])
Gw = (C @ np.linalg.solve(1j * w[:, None, None] * np.eye(2) - A, B)).ravel()
print(f"||G||_inf: Hamilton {hinf(A, B, C):.4f}, siatka częstotliwości {np.max(np.abs(Gw)):.4f},"
      f" wzór 1/(2 zeta sqrt(1 - zeta^2)) = {1 / (2 * zeta * np.sqrt(1 - zeta**2)):.4f}")
```

Rozszerzenia: wyznacz wagę niepewności $W(j\omega) = \max\lvert G_p/G - 1\rvert$ z losowanych obiektów i sprawdź warunek $\lvert WT\rvert < 1$ dla obu regulatorów (powinien być spełniony dla ostrożnego); wykreśl $\lvert S\rvert$ i $\lvert T\rvert$ w skali logarytmicznej i zaobserwuj efekt łóżka wodnego przy zwiększaniu $K_c$.

## Zadania

1. Pętla ma $M_s = 1\text{,}4$. Jakie minimalne zapasy wzmocnienia i fazy to gwarantuje?
2. Obiekt ma opóźnienie 50 ms. Jakie jest orientacyjne maksymalne pasmo pętli regulacji?
3. Dlaczego $\lvert S\rvert$ i $\lvert T\rvert$ nie mogą być jednocześnie małe przy tej samej częstotliwości?
4. Wzmocnienie obiektu jest znane z dokładnością ±40%, inne parametry dokładnie. Jaki warunek musi spełniać $T$, by pętla była odpornie stabilna?
5. Zapas fazy wynosi 50° przy $\omega_c = 5$ rad/s. O ile może wzrosnąć opóźnienie, zanim pętla straci stabilność?

<details>
<summary>Odpowiedzi</summary>

1. GM ≥ $1\text{,}4/0\text{,}4 = 3\text{,}5$, PM ≥ $2\arcsin(1/2\text{,}8) \approx 41\text{,}8°$
2. $\omega_c \lesssim 1/\theta = 20$ rad/s (ok. 3 Hz)
3. Bo $S + T = 1$ — jeśli jedna jest bliska zera, druga jest bliska jedności
4. $G_p = G(1 + 0\text{,}4\Delta)$, więc $\lvert T(j\omega)\rvert < 1/0\text{,}4 = 2\text{,}5$ dla wszystkich $\omega$ (dla niepewności rzeczywistej to warunek wystarczający, nieco konserwatywny)
5. $\Delta\theta = \mathrm{PM}/\omega_c = 0\text{,}873/5 \approx 0\text{,}175$ s
</details>

## Źródła

- [K. J. Åström, R. M. Murray — Feedback Systems (wyd. 2, darmowe)](https://www.cds.caltech.edu/~murray/amwiki/Second_Edition.html) — rozdziały o odporności i ograniczeniach fundamentalnych
- [MIT 6.241J Dynamic Systems and Control (2011)](https://ocw.mit.edu/courses/6-241j-dynamic-systems-and-control-spring-2011/) — normy, odporna stabilność, synteza
- [10.03 Stabilność](../../modules/10-automatyka/03-stabilnosc.md) — kryterium Nyquista, zapasy
- S. Skogestad, I. Postlethwaite — *Multivariable Feedback Control: Analysis and Design* (płatna)
