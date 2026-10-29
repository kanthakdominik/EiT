# 06.05 — Transmitancja, bieguny i zera, stabilność

## Po co to jest

Transmitancja $H(s)$ to najzwięźlejszy opis układu liniowego. Z położenia biegunów i zer da się „na oko” odczytać charakter odpowiedzi czasowej, kształt charakterystyki częstotliwościowej i stabilność. Ten sam język stosuje się do filtrów, wzmacniaczy, pętli PLL i regulatorów.

## Teoria w pigułce

$$H(s) = \frac{Y(s)}{X(s)} = \mathcal{L}\{h(t)\} = K\frac{(s - z_1)(s - z_2)\cdots}{(s - p_1)(s - p_2)\cdots}$$

Transmitancję wyznacza się z równania różniczkowego (przy zerowych warunkach początkowych) albo bezpośrednio z obwodu metodą operatorową ([01.08](../01-teoria-obwodow/08-laplace-w-obwodach.md)).

### Bieguny a odpowiedź czasowa

| Położenie bieguna | Składnik odpowiedzi |
|---|---|
| Rzeczywisty ujemny $p = -a$ | $e^{-at}$ — zanik wykładniczy |
| Para zespolona $-\alpha \pm j\omega_d$ | $e^{-\alpha t}\cos(\omega_d t + \varphi)$ — tłumione oscylacje |
| Na osi urojonej $\pm j\omega_0$ | Niegasnące oscylacje (granica stabilności — generator) |
| W prawej półpłaszczyźnie | Narastanie — **niestabilność** |
| Bliżej osi urojonej | Wolniejszy zanik — biegun **dominujący** |

**Stabilność BIBO** układu przyczynowego: wszystkie bieguny w lewej półpłaszczyźnie.

### Bieguny i zera a charakterystyka częstotliwościowa

$H(j\omega)$ — wartość transmitancji na osi urojonej. Geometrycznie: $\lvert H\rvert$ to iloczyn odległości od zer podzielony przez iloczyn odległości od biegunów. Biegun blisko osi urojonej → pik rezonansowy; zero na osi urojonej → zerowe wzmocnienie przy tej częstotliwości (filtr wycinający). Reguły szkicowania Bodego — [01.07](../01-teoria-obwodow/07-rezonans-i-charakterystyki.md).

### Układy minimalnofazowe

Wszystkie zera w lewej półpłaszczyźnie. Zero w prawej półpłaszczyźnie daje odpowiedź skokową, która najpierw idzie „w złą stronę” (np. przetwornica boost) i utrudnia regulację.

### Połączenia układów

Szeregowe: $H_1H_2$; równoległe: $H_1 + H_2$; ze sprzężeniem zwrotnym: $\dfrac{H}{1 + HG}$ ([04.06](../04-uklady-analogowe/06-sprzezenie-zwrotne-i-stabilnosc.md), moduł [10](../10-automatyka/)).

## Przykład rozwiązany

$H(s) = \dfrac{10}{s + 10}$.

1. Biegun $p = -10$; układ stabilny, stała czasowa 0,1 s.
2. Odpowiedź impulsowa: $h(t) = 10e^{-10t}u(t)$; skokowa: $1 - e^{-10t}$.
3. Charakterystyka: $\lvert H(j\omega)\rvert = \dfrac{10}{\sqrt{100 + \omega^2}}$ — filtr dolnoprzepustowy, −3 dB przy $\omega = 10$ rad/s (1,59 Hz), wzmocnienie DC = 1.

$H(s) = \dfrac{1}{s^2 + s - 2} = \dfrac{1}{(s - 1)(s + 2)}$: biegun $s = 1$ w prawej półpłaszczyźnie → odpowiedź zawiera $e^{t}$ → **niestabilny**.

## Typowe pułapki

- **Stabilność oceniana z charakterystyki amplitudowej** — dla układu niestabilnego „charakterystyka” $H(j\omega)$ nie opisuje rzeczywistego zachowania.
- **Skracanie bieguna niestabilnego zerem** w obliczeniach — w rzeczywistym układzie skrócenie nigdy nie jest dokładne i niestabilny tryb zostaje.
- **Zera mylone z biegunami** przy odczytywaniu z wykresu (biegun — ×, zero — ○).

## Ćwiczenie komputerowe

```python
import numpy as np, matplotlib.pyplot as plt
from scipy import signal
sys = signal.TransferFunction([1], [1e-8, 1e-4, 1])     # szeregowy RLC: R=100, L=10m, C=1u
print("bieguny:", sys.poles)
t, y = signal.step(sys, T=np.linspace(0, 3e-3, 1000))
w, mag, ph = signal.bode(sys, w=np.logspace(2, 6, 500))
fig, ax = plt.subplots(1, 2, figsize=(10, 4))
ax[0].plot(t*1e3, y); ax[0].set_xlabel("t [ms]")
ax[1].semilogx(w, mag); ax[1].set_xlabel("ω [rad/s]"); plt.show()
```

Przesuwaj bieguny (zmieniaj $R$) i obserwuj jednocześnie odpowiedź skokową i pik rezonansowy.

## Zadania

1. $H(s) = \dfrac{10}{s + 10}$: biegun, odpowiedź skokowa, częstotliwość −3 dB.
2. Wyznacz bieguny $H(s) = \dfrac{1}{s^2 + s - 2}$. Czy układ jest stabilny?
3. Układ ma bieguny $-2 \pm j10$. Jaka jest częstotliwość oscylacji odpowiedzi i stała czasowa obwiedni?
4. Wyznacz transmitancję układu opisanego równaniem $\ddot{y} + 3\dot{y} + 2y = x$ i jego odpowiedź impulsową.
5. Zaproponuj położenie zer, aby filtr całkowicie tłumił 50 Hz.
6. Dwa układy $H_1 = \dfrac{1}{s + 1}$ i $H_2 = \dfrac{1}{s + 10}$ połączono szeregowo. Który biegun jest dominujący i dlaczego?

<details>
<summary>Odpowiedzi</summary>

1. $p = -10$; $1 - e^{-10t}$; $\omega = 10$ rad/s ≈ 1,59 Hz
2. $s = 1$, $s = -2$; niestabilny
3. $\omega_d = 10$ rad/s (≈ 1,59 Hz); stała czasowa obwiedni $1/2 = 0\text{,}5$ s
4. $H(s) = \dfrac{1}{(s + 1)(s + 2)}$, $h(t) = (e^{-t} - e^{-2t})u(t)$
5. Para zer na osi urojonej $s = \pm j2\pi\cdot 50$
6. $s = -1$ — leży bliżej osi urojonej, jego składnik zanika 10 razy wolniej i decyduje o odpowiedzi
</details>

## Źródła

- [MIT 6.003 Signals and Systems](https://ocw.mit.edu/courses/6-003-signals-and-systems-fall-2011/) — transformata Laplace'a, bieguny i zera, sprzężenie zwrotne
- [MIT RES.6-007 Signals and Systems](https://ocw.mit.edu/courses/res-6-007-signals-and-systems-spring-2011/) — wykłady o transformacie Laplace'a i układach 2. rzędu
- [Paul's Online Math Notes — Laplace Transforms](https://tutorial.math.lamar.edu/Classes/DE/LaplaceIntro.aspx)
