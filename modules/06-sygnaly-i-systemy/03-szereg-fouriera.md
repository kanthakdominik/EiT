# 06.03 — Szereg Fouriera

## Po co to jest

Każdy sygnał okresowy to suma sinusoid o częstotliwościach będących wielokrotnościami podstawowej. Dzięki temu odpowiedź układu liniowego na dowolny sygnał okresowy liczy się jako sumę odpowiedzi na pojedyncze harmoniczne. Tak analizuje się zniekształcenia (THD), widmo zasilaczy impulsowych i zegarów, zakłócenia EMC.

## Teoria w pigułce

Matematyka szeregu (współczynniki trygonometryczne) — w [00.05](../00-matematyka/05-szeregi-i-transformaty.md). Tu postać zespolona i jej interpretacja.

### Postać zespolona

$$x(t) = \sum_{k=-\infty}^{\infty}c_ke^{jk\omega_0t}, \qquad c_k = \frac{1}{T}\int_T x(t)e^{-jk\omega_0t}dt$$

Dla sygnału rzeczywistego $c_{-k} = c_k^*$: amplituda harmonicznej $k$ wynosi $2\lvert c_k\rvert$, faza — $\arg c_k$. **Widmo prążkowe** — wykres $\lvert c_k\rvert$ w funkcji $k\omega_0$.

### Twierdzenie Parsevala

$$P = \frac{1}{T}\int_T\lvert x(t)\rvert^2dt = \sum_k\lvert c_k\rvert^2$$

Moc sygnału to suma mocy harmonicznych.

### Typowe widma

| Sygnał (amplituda $A$, okres $T$) | Harmoniczne | Zanikanie |
|---|---|---|
| Fala prostokątna ±$A$ | Tylko nieparzyste: $\dfrac{4A}{\pi k}$ | $1/k$ (skoki) |
| Fala trójkątna ±$A$ | Tylko nieparzyste: $\dfrac{8A}{\pi^2k^2}$ | $1/k^2$ (ciągła, załamania) |
| Piłokształtna | Wszystkie: $\dfrac{2A}{\pi k}$ | $1/k$ |
| Ciąg impulsów o wypełnieniu $D$ | $\propto\dfrac{\sin(\pi kD)}{\pi k}$ | obwiednia sinc, zera przy $k = 1/D, 2/D, \dots$ |

Im gładszy sygnał, tym szybciej zanikają harmoniczne. **Skoki → 1/k, załamania → 1/k², gładkie → szybciej.** To powód, dla którego wolniejsze zbocza zmniejszają emisję zakłóceń.

### Przejście przez układ LTI

Harmoniczna $k$ jest mnożona przez $H(jk\omega_0)$:

$$y(t) = \sum_k c_kH(jk\omega_0)e^{jk\omega_0t}$$

**Zawartość harmonicznych:** $\text{THD} = \dfrac{\sqrt{\sum_{k\geq 2}A_k^2}}{A_1}$.

## Przykład rozwiązany

Fala prostokątna ±1 V, 1 kHz, przez filtr RC o $f_c = 1$ kHz.

1. Moc fali: 1 W (na 1 Ω). Składowa podstawowa ma amplitudę $4/\pi \approx 1{,}273$ V i moc $\dfrac{(4/\pi)^2}{2} \approx 0{,}811$ W — **81% mocy**. Harmoniczne 1, 3, 5 razem: ok. 93%.
2. Filtr: $\lvert H\rvert = 1/\sqrt{1 + k^2}$ dla harmonicznej $k$ (bo $f = kf_c$).
3. Na wyjściu: podstawowa $1{,}273/\sqrt2 \approx 0{,}90$ V, trzecia $0{,}424/\sqrt{10} \approx 0{,}134$ V, piąta $0{,}255/\sqrt{26} \approx 0{,}050$ V.
4. Wyjście jest znacznie bardziej „sinusoidalne” niż wejście: stosunek trzeciej harmonicznej do podstawowej spadł z 33% do ok. 15%.

## Typowe pułapki

- **Amplituda harmonicznej = $\lvert c_k\rvert$** — dla sygnału rzeczywistego wynosi $2\lvert c_k\rvert$ (moc dzieli się między $+k$ i $-k$).
- **Zjawisko Gibbsa** traktowane jako błąd obliczeń — przerost ok. 9% przy skoku nie znika przy zwiększaniu liczby wyrazów.
- **Pominięcie fazy** — dwa sygnały o tych samych amplitudach harmonicznych, ale różnych fazach, wyglądają zupełnie inaczej.

## Ćwiczenie komputerowe

```python
import numpy as np, matplotlib.pyplot as plt
t = np.linspace(0, 2e-3, 4000); f0 = 1e3; fc = 1e3
x = np.zeros_like(t); y = np.zeros_like(t)
for k in range(1, 200, 2):
    ck = 4/(np.pi*k); H = 1/(1 + 1j*k*f0/fc)
    x += ck*np.sin(2*np.pi*k*f0*t)
    y += ck*abs(H)*np.sin(2*np.pi*k*f0*t + np.angle(H))
plt.plot(t*1e3, x, t*1e3, y); plt.xlabel("t [ms]"); plt.grid(); plt.show()
```

Porównaj wynik z symulacją `.tran` filtra RC w LTspice. W LTspice dyrektywa `.four 1k V(out)` wypisuje amplitudy harmonicznych i THD.

## Zadania

1. Jaka część mocy fali prostokątnej przypada na składową podstawową, a jaka na trzy pierwsze niezerowe harmoniczne?
2. Wyznacz amplitudy harmonicznych 1, 3 i 5 fali trójkątnej ±1 V.
3. Ciąg impulsów o wypełnieniu 25%. Które harmoniczne mają zerową amplitudę?
4. Fala prostokątna ±1 V, 1 kHz przechodzi przez filtr RC o $f_c = 1$ kHz. Wyznacz amplitudy harmonicznych 1, 3 i 5 na wyjściu.
5. Sygnał ma harmoniczne o amplitudach: 10 V (podstawowa), 0,3 V (2.), 0,4 V (3.). Ile wynosi THD?
6. Dlaczego sygnał zegara o zboczach 1 ns daje więcej zakłóceń w paśmie 300 MHz niż sygnał o tej samej częstotliwości i zboczach 10 ns?

<details>
<summary>Odpowiedzi</summary>

1. ≈ 81%; ≈ 93%
2. $8/\pi^2 \approx 0{,}811$ V, $0{,}090$ V, $0{,}032$ V
3. 4., 8., 12., … (wielokrotności $1/D = 4$)
4. ≈ 0,90 V, ≈ 0,134 V, ≈ 0,050 V
5. $\sqrt{0{,}09 + 0{,}16}/10 = 0{,}5/10 = 5\%$
6. Krótsze zbocze przesuwa punkt, od którego harmoniczne zaczynają zanikać szybciej (jak $1/k^2$), w stronę wyższych częstotliwości (ok. $1/(\pi t_r)$) — dla 1 ns to ok. 320 MHz, dla 10 ns ok. 32 MHz
</details>

## Źródła

- [MIT 6.003 Signals and Systems](https://ocw.mit.edu/courses/6-003-signals-and-systems-fall-2011/) — szereg Fouriera ciągły i dyskretny
- [MIT RES.6-007 Signals and Systems](https://ocw.mit.edu/courses/res-6-007-signals-and-systems-spring-2011/) — wykłady o szeregu Fouriera
- [The Scientist and Engineer's Guide to DSP — rozdział 13](http://www.dspguide.com/) — szereg Fouriera i typowe widma
- [Fundamentals of Electrical Engineering I — D. Johnson](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-electrical-engineering-1)
