# M06.08 — Uczenie ze wzmocnieniem i uczenie maszynowe na mikrokontrolerach

## Po co to jest

Dwa kierunki, w których sterowanie i uczenie maszynowe spotykają się w praktyce inżynierskiej. **Uczenie ze wzmocnieniem** (RL) uczy polityki sterowania z doświadczenia, gdy modelu nie ma lub jest zbyt złożony — od gier i robotów kroczących po zarządzanie energią, dobór parametrów łącza radiowego i strojenie regulatorów; jego matematyka to programowanie dynamiczne, z którego wywodzi się też LQR ([01](01-lqr-i-lqg.md)). **ML wbudowane** (TinyML) uruchamia wyuczone modele na mikrokontrolerach z kilkudziesięcioma kB pamięci: wykrywanie słów kluczowych, klasyfikacja drgań, gestów, anomalii prądu — co wymaga kwantyzacji i arytmetyki stałoprzecinkowej ([19.05](../../modules/19-programowanie/05-c-bity-i-sprzet.md)).

## Teoria w pigułce

### Procesy decyzyjne Markowa i programowanie dynamiczne

Stan $s$, akcja $a$, przejście $P(s'\mid s, a)$, nagroda $r$, współczynnik dyskontowania $\gamma$. Funkcja wartości akcji spełnia **równanie Bellmana**

$$Q^*(s, a) = \mathbb E\left[r + \gamma\max_{a'}Q^*(s', a')\right].$$

Gdy model jest znany — **iteracja wartości** lub polityki (programowanie dynamiczne). LQR to szczególny przypadek: liniowy model, kwadratowy koszt, $V(x) = x^TPx$, a równanie Bellmana staje się równaniem Riccatiego.

### Uczenie bez modelu

- **Q-learning:** $Q(s, a) \leftarrow Q(s, a) + \alpha\left[r + \gamma\max_{a'}Q(s', a') - Q(s, a)\right]$ — uczy się z przejść, bez znajomości $P$; eksploracja $\varepsilon$-zachłanna (z malejącym $\varepsilon$). Zbieżny do $Q^*$ przy odpowiednich warunkach (każda para odwiedzana nieskończenie często, malejący krok).
- **Aproksymacja funkcji** (sieć neuronowa zamiast tablicy) — DQN; **metody gradientu polityki** i aktor–krytyk (PPO, SAC) dla akcji ciągłych.
- **W sterowaniu:** RL wymaga wielu prób — uczy się w symulacji, potem przenosi na obiekt (problem *sim-to-real*); bezpieczeństwo podczas uczenia i brak gwarancji stabilności to główne przeszkody; często łączy się RL z klasycznym regulatorem (RL stroi lub koryguje).

### ML wbudowane

- **Kwantyzacja int8:** $x \approx s\cdot q$, $q \in [-127, 127]$; wagi — skala na tensor lub na kanał; aktywacje — skala z danych kalibracyjnych (kwantyzacja po uczeniu) lub uczenie świadome kwantyzacji (QAT).
- **Arytmetyka:** iloczyny int8 × int8 sumowane w akumulatorze int32, bias w int32 ze skalą $s_xs_w$, przeskalowanie do int8 mnożnikiem stałoprzecinkowym i przesunięciem bitowym — bez jednostki zmiennoprzecinkowej.
- **Korzyści:** 4 × mniej pamięci, szybsze obliczenia (instrukcje SIMD, np. w Cortex-M4/M7/M55, biblioteka CMSIS-NN), mniejszy pobór energii; typowa strata dokładności — ułamek procenta.
- **Budżet:** pamięć Flash (wagi), RAM (największe aktywacje), czas wnioskowania w stosunku do okresu próbkowania; narzędzia: LiteRT (dawniej TensorFlow Lite) dla mikrokontrolerów, CMSIS-NN, kompilatory modeli producentów układów.

## Przykład rozwiązany

**A. Q-learning:** wózek na torze 0–20 (prędkość −3…3, przyspieszenie −1, 0, +1), cel: zatrzymać się w $x = 10$, nagroda −1 za krok. Iteracja wartości (model znany) daje średnio 5,52 kroku do celu ze wszystkich stanów; Q-learning po 4000 epizodach (bez modelu) — również 5,52, polityka optymalna ze 100% stanów.

**B. Kwantyzacja int8** sieci 2–16–16–1 (337 parametrów), klasyfikującej punkty wewnątrz okręgu:

| Wersja | Dokładność | Pamięć parametrów |
|---|---|---|
| float32 | 99,56% | 1348 B |
| int8 (biasy int32) | 99,46% | 436 B |

Decyzje zgodne w 99,60% przypadków — różnice tylko przy samej granicy klas.

## Typowe pułapki

- **Nagroda źle zaprojektowana** — agent „oszukuje” (znajduje sposób na nagrodę bez wykonania zadania).
- **Za mało eksploracji** — Q-learning utyka w polityce suboptymalnej; za dużo do końca — polityka nie zbiega.
- **RL tam, gdzie wystarczy LQR/MPC** — gdy model jest znany, metody klasyczne są szybsze, pewniejsze i mają gwarancje.
- **Skale aktywacji z niereprezentatywnych danych kalibracyjnych** — nasycenia int8 i gwałtowny spadek dokładności.
- **Przepełnienie akumulatora** w długich iloczynach skalarnych lub zapomniane zaokrąglenie przy przeskalowaniu — błędy systematyczne.

## Ćwiczenie komputerowe

Q-learning porównany z iteracją wartości oraz kwantyzacja int8 sieci z wnioskowaniem w arytmetyce całkowitej:

```python
import numpy as np

rng = np.random.default_rng(8)

# A) Q-learning: dojazd wózka do punktu x = 10 i zatrzymanie (położenia 0..20, prędkości -3..3)
XS, VS, AKCJE = np.arange(21), np.arange(-3, 4), (-1, 0, 1)
def krok(x, v, a):
    v2 = int(np.clip(v + a, -3, 3))
    x2 = int(np.clip(x + v2, 0, 20))
    if x2 in (0, 20) and x2 != x + v2:
        v2 = 0                                          # uderzenie w ogranicznik zatrzymuje wózek
    return x2, v2, (x2 == 10 and v2 == 0)
idx = lambda x, v: (x, v + 3)

# Rozwiązanie optymalne (model znany): iteracja wartości, nagroda -1 za każdy krok
V = np.zeros((21, 7))
for _ in range(200):
    Vn = np.zeros_like(V)
    for x in XS:
        for v in VS:
            if x == 10 and v == 0:
                continue
            Vn[idx(x, v)] = max(-1 + V[idx(*krok(x, v, a)[:2])] for a in AKCJE)
    V = Vn

# Q-learning (model nieznany, tylko doświadczenie)
Qt = np.zeros((21, 7, 3))
alfa, gamma = 0.5, 1.0
for ep in range(4000):
    x, v = rng.integers(0, 21), rng.integers(-3, 4)
    eps = max(0.05, 1 - ep / 2000)                       # malejąca eksploracja
    for _ in range(200):
        if x == 10 and v == 0:
            break
        a = rng.integers(3) if rng.random() < eps else int(np.argmax(Qt[idx(x, v)]))
        x2, v2, koniec = krok(x, v, AKCJE[a])
        cel = -1 + (0 if koniec else gamma * Qt[idx(x2, v2)].max())
        Qt[idx(x, v)][a] += alfa * (cel - Qt[idx(x, v)][a])
        x, v = x2, v2

def kroki_polityki(Qt, x, v):
    for n in range(100):
        if x == 10 and v == 0:
            return n
        x, v, _ = krok(x, v, AKCJE[int(np.argmax(Qt[idx(x, v)]))])
    return 100
starty = [(x, v) for x in XS for v in VS if not (x == 10 and v == 0)]
opt = np.mean([-V[idx(x, v)] for x, v in starty])
ql = np.mean([kroki_polityki(Qt, x, v) for x, v in starty])
zgodne = np.mean([kroki_polityki(Qt, x, v) == -V[idx(x, v)] for x, v in starty])
print(f"średnia liczba kroków do celu: optimum {opt:.2f}, Q-learning {ql:.2f};"
      f" polityka optymalna z {100 * zgodne:.0f}% stanów")

# B) Uczenie maszynowe wbudowane: kwantyzacja int8 małej sieci (2-16-16-1)
X = rng.uniform(-1, 1, (4000, 2)); Y = (np.sum(X**2, 1) < 0.5).astype(float)   # punkt wewnątrz okręgu
W = [rng.normal(0, 1, (2, 16)), rng.normal(0, 0.35, (16, 16)), rng.normal(0, 0.35, (16, 1))]
b = [np.zeros(16), np.zeros(16), np.zeros(1)]
def fwd(X, W, b):
    a1 = np.maximum(X @ W[0] + b[0], 0); a2 = np.maximum(a1 @ W[1] + b[1], 0)
    return a1, a2, (a2 @ W[2] + b[2]).ravel()
for it in range(3000):                                  # pełny spadek gradientu, strata logistyczna
    a1, a2, z = fwd(X, W, b)
    d3 = (1 / (1 + np.exp(-z)) - Y)[:, None] / len(Y)
    d2 = (d3 @ W[2].T) * (a2 > 0); d1 = (d2 @ W[1].T) * (a1 > 0)
    for Wi, bi, a, d in ((W[2], b[2], a2, d3), (W[1], b[1], a1, d2), (W[0], b[0], X, d1)):
        Wi -= 1.0 * a.T @ d; bi -= 1.0 * d.sum(0)

Xt = rng.uniform(-1, 1, (20000, 2)); Yt = np.sum(Xt**2, 1) < 0.5
z_f = fwd(Xt, W, b)[2]

def q(x, s):                                            # kwantyzacja symetryczna do int8
    return np.clip(np.round(x / s), -127, 127).astype(np.int32)
s_in = 1 / 127                                           # wejścia w zakresie -1..1
_, a2c, _ = fwd(X, W, b); a1c = fwd(X, W, b)[0]
s_a = [a1c.max() / 127, a2c.max() / 127]                 # skale aktywacji z danych kalibracyjnych
s_w = [np.abs(Wi).max() / 127 for Wi in W]
Wq = [q(Wi, s) for Wi, s in zip(W, s_w)]
def fwd_int8(Xf):
    x = q(Xf, s_in); s_x = s_in
    for i in range(3):
        acc = x @ Wq[i] + np.round(b[i] / (s_x * s_w[i])).astype(np.int32)   # akumulator int32
        if i == 2:
            return (acc * s_x * s_w[i]).ravel()
        x = q(np.maximum(acc, 0) * s_x * s_w[i], s_a[i])        # przeskalowanie do int8 (w MCU: mnożnik + przesunięcie)
        s_x = s_a[i]
z_q = fwd_int8(Xt)
par = sum(Wi.size + bi.size for Wi, bi in zip(W, b))
print(f"dokładność float32 {100 * np.mean((z_f > 0) == Yt):.2f} %, int8 {100 * np.mean((z_q > 0) == Yt):.2f} %,"
      f" zgodność decyzji {100 * np.mean((z_f > 0) == (z_q > 0)):.2f} %")
print(f"parametrów {par}: pamięć float32 {4 * par} B, int8 (+ biasy int32) {sum(Wi.size for Wi in W) + 4 * sum(bi.size for bi in b)} B")
```

Rozszerzenia: dodaj losowe poślizgi (przejścia stochastyczne) i porównaj Q-learning z iteracją wartości; zastąp tablicę Q aproksymacją liniową cech; przenieś wnioskowanie int8 do C na mikrokontroler (moduł [09](../../modules/09-mikrokontrolery-embedded/)) i zmierz czas — porównaj z float na Cortex-M bez FPU; użyj kwantyzacji na kanał (osobna skala dla każdej kolumny wag) i sprawdź wpływ na dokładność.

## Zadania

1. Zapisz równanie Bellmana dla LQR ($V(x) = x^TPx$) i pokaż, że prowadzi do równania Riccatiego.
2. Dlaczego w Q-learningu stosuje się $\max_{a'}$, a w algorytmie SARSA — akcję faktycznie wybraną? Jaka jest konsekwencja?
3. Wagi warstwy mają zakres −0,8…+1,2. Jaka jest skala kwantyzacji symetrycznej int8 i maksymalny błąd kwantyzacji wagi?
4. Ile bitów potrzebuje akumulator, by bez przepełnienia zsumować 256 iloczynów int8 × int8?
5. Sieć ma 50 000 parametrów, a mikrokontroler 128 kB Flash i 32 kB RAM. Czy zmieści się w float32? A w int8?

<details>
<summary>Odpowiedzi</summary>

1. $x^TPx = \min_u\left[x^TQx + u^TRu + (Ax + Bu)^TP(Ax + Bu)\right]$; minimum przy $u = -(R + B^TPB)^{-1}B^TPAx$; podstawienie daje DARE z tematu 01
2. Q-learning uczy się wartości polityki zachłannej (off-policy) niezależnie od eksploracji; SARSA — wartości faktycznie wykonywanej polityki z eksploracją (on-policy), więc wybiera ostrożniejsze ścieżki tam, gdzie losowe ruchy są groźne
3. $s = 1\text{,}2/127 \approx 9\text{,}45\cdot 10^{-3}$; błąd maks. $s/2 \approx 4\text{,}7\cdot 10^{-3}$
4. Iloczyn ma co najwyżej $127^2 = 16\,129$ (14 bitów + znak); 256 iloczynów: $256\cdot 16\,129 \approx 4\text{,}1\cdot 10^6$ → 22 bity + znak = 23 bity; int32 wystarcza z zapasem
5. float32: 200 kB > 128 kB Flash — nie; int8: ok. 50 kB — tak (o ile aktywacje zmieszczą się w 32 kB RAM)
</details>

## Źródła

- [R. S. Sutton, A. G. Barto — Reinforcement Learning: An Introduction (darmowa wersja online)](http://incompleteideas.net/book/the-book.html)
- [R. Tedrake — Underactuated Robotics](https://underactuated.mit.edu/) — programowanie dynamiczne, związek RL ze sterowaniem optymalnym
- [CMSIS-NN (GitHub)](https://github.com/ARM-software/CMSIS-NN) — wydajne jądra sieci int8 dla Cortex-M
- [19.05 C: bity i sprzęt](../../modules/19-programowanie/05-c-bity-i-sprzet.md) — arytmetyka stałoprzecinkowa
