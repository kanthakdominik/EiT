# 06.04 — Przekształcenie Fouriera

## Po co to jest

Przekształcenie Fouriera rozszerza szereg na sygnały nieokresowe: każdy impuls ma widmo ciągłe. Jego własności tłumaczą modulację (mnożenie przez nośną przesuwa widmo), kompromis między czasem trwania a pasmem impulsu oraz to, dlaczego splot w czasie jest prostym mnożeniem w częstotliwości.

## Teoria w pigułce

$$X(f) = \int_{-\infty}^{\infty}x(t)e^{-j2\pi ft}dt, \qquad x(t) = \int_{-\infty}^{\infty}X(f)e^{j2\pi ft}df$$

(Zapis z $f$; w części literatury z $\omega$ i czynnikiem $1/2\pi$ w transformacie odwrotnej.)

### Pary transformat

| $x(t)$ | $X(f)$ |
|---|---|
| $\delta(t)$ | $1$ |
| $1$ | $\delta(f)$ |
| $\cos(2\pi f_0t)$ | $\tfrac12[\delta(f - f_0) + \delta(f + f_0)]$ |
| Prostokąt: amplituda 1, czas trwania $T$, środek w 0 | $T\,\text{sinc}(fT) = T\dfrac{\sin(\pi fT)}{\pi fT}$ |
| $\text{sinc}$ w czasie | prostokąt w częstotliwości (filtr idealny) |
| $e^{-at}u(t)$ | $\dfrac{1}{a + j2\pi f}$ |
| Gaussian | Gaussian |
| Ciąg delt co $T$ | Ciąg delt co $1/T$ |

### Własności

| Własność | Czas | Częstotliwość |
|---|---|---|
| Liniowość | $ax + by$ | $aX + bY$ |
| Przesunięcie w czasie | $x(t - t_0)$ | $X(f)e^{-j2\pi ft_0}$ — tylko zmiana fazy |
| **Modulacja** | $x(t)\cos(2\pi f_ct)$ | $\tfrac12[X(f - f_c) + X(f + f_c)]$ |
| Skalowanie | $x(at)$ | $\tfrac{1}{\lvert a\rvert}X(f/a)$ |
| **Splot** | $x * h$ | $X\cdot H$ |
| **Iloczyn** | $x\cdot y$ | $X * Y$ |
| Różniczkowanie | $dx/dt$ | $j2\pi f X(f)$ |
| Parseval | $\int\lvert x\rvert^2dt$ | $\int\lvert X\rvert^2df$ |

**Zasada nieoznaczoności czas–częstotliwość:** krótszy sygnał = szersze widmo. Iloczyn czasu trwania i szerokości pasma jest rzędu 1.

### Związki z innymi transformatami

- Szereg Fouriera to transformata sygnału okresowego (prążki = delty).
- Transformata Laplace'a: $s = j2\pi f$ daje Fouriera (gdy oś urojona leży w obszarze zbieżności).
- DTFT i DFT — wersje dyskretne ([06.07](07-czas-dyskretny-i-transformata-z.md), [07.02](../07-cps-dsp/02-dft-i-fft.md)).

## Przykład rozwiązany

**Widmo impulsu radarowego.** Impuls prostokątny o czasie trwania $T = 1\ \mu$s.

1. $\lvert X(f)\rvert = T\lvert\text{sinc}(fT)\rvert$ — pierwsze zero przy $f = 1/T = 1$ MHz.
2. Listek główny ma szerokość 2 MHz (od −1 do +1 MHz), a zawiera ok. 90% energii.
3. Impuls 1 µs zmodulowany nośną 10 GHz (własność modulacji): widmo to ten sam sinc przesunięty do ±10 GHz — odbiornik potrzebuje pasma ok. 2 MHz wokół nośnej.
4. Skrócenie impulsu do 0,1 µs poszerza pasmo dziesięciokrotnie (lepsza rozdzielczość odległości, ale szersze pasmo i więcej szumu).

## Typowe pułapki

- **Mieszanie konwencji $f$ i $\omega$** — różnią się czynnikiem $2\pi$ we wzorach.
- **Ujemne częstotliwości uznane za „niefizyczne”** — są niezbędne do opisu sygnałów rzeczywistych (widmo symetryczne) i modulacji.
- **Przesunięcie w czasie zmienia moduł widma** — nie zmienia, tylko fazę.

## Ćwiczenie komputerowe

```python
import numpy as np, matplotlib.pyplot as plt
fs = 100e6; T = 1e-6
t = np.arange(-20e-6, 20e-6, 1/fs)
x = (np.abs(t) <= T/2).astype(float)
X = np.fft.fftshift(np.fft.fft(x))/fs
f = np.fft.fftshift(np.fft.fftfreq(len(x), 1/fs))
plt.plot(f/1e6, np.abs(X)*1e6, label="FFT")
plt.plot(f/1e6, np.abs(np.sinc(f*T))*T*1e6, "--", label="T·sinc(fT)")
plt.xlim(-5, 5); plt.xlabel("f [MHz]"); plt.legend(); plt.grid(); plt.show()
```

## Zadania

1. Wyznacz $X(f)$ prostokąta o amplitudzie 1 i czasie trwania $T$. Gdzie leżą zera?
2. Impuls trwa 1 µs. Przy jakiej częstotliwości widmo ma pierwsze zero?
3. Sygnał o paśmie 0–4 kHz mnoży się przez $\cos(2\pi\cdot 100\ \text{kHz}\cdot t)$. W jakim zakresie częstotliwości leży wynik?
4. Wyznacz $X(f)$ dla $x(t) = e^{-at}u(t)$ i jego moduł przy $f = a/(2\pi)$.
5. Sygnał $x(t)$ ma widmo $X(f)$. Jakie widmo ma $x(2t)$?
6. Dlaczego filtr o idealnie prostokątnej charakterystyce nie jest realizowalny?

<details>
<summary>Odpowiedzi</summary>

1. $T\,\text{sinc}(fT)$; zera przy $f = \pm 1/T, \pm 2/T, \dots$
2. 1 MHz
3. 96–104 kHz (oraz lustrzanie przy ujemnych częstotliwościach)
4. $\dfrac{1}{a + j2\pi f}$; $\lvert X\rvert = \dfrac{1}{a\sqrt2}$ — to „−3 dB” filtra RC
5. $\tfrac12X(f/2)$ — dwa razy szersze i dwa razy niższe
6. Jego odpowiedź impulsowa to sinc rozciągający się od $-\infty$ do $+\infty$ — układ musiałby reagować przed pobudzeniem (nieprzyczynowy)
</details>

## Źródła

- [MIT 6.003 Signals and Systems](https://ocw.mit.edu/courses/6-003-signals-and-systems-fall-2011/) — przekształcenie Fouriera i jego własności
- [MIT RES.6-007 Signals and Systems](https://ocw.mit.edu/courses/res-6-007-signals-and-systems-spring-2011/) — wykłady o przekształceniu Fouriera, filtracji i modulacji
- [The Scientist and Engineer's Guide to DSP — rozdziały 10–11](http://www.dspguide.com/) — własności i pary transformat
