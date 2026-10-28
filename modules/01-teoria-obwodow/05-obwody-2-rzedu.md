# 01.05 — Obwody 2. rzędu (RLC)

## Po co to jest

Dwa elementy reaktancyjne dają możliwość oscylacji. Obwody RLC opisują filtry 2. rzędu, obwody rezonansowe w radiu, dzwonienie na zboczach sygnałów cyfrowych, odpowiedź stabilizatorów i przetwornic na skok obciążenia. Pojęcia $\omega_0$, $\zeta$ i przeregulowania wracają w automatyce.

## Teoria w pigułce

### Szeregowy RLC

$$\omega_0 = \frac{1}{\sqrt{LC}}, \qquad \alpha = \frac{R}{2L}, \qquad \zeta = \frac{\alpha}{\omega_0} = \frac{R}{2}\sqrt{\frac{C}{L}}$$

Rezystancja krytyczna: $R_{kr} = 2\sqrt{L/C}$.

### Równoległy RLC

$$\omega_0 = \frac{1}{\sqrt{LC}}, \qquad \alpha = \frac{1}{2RC}, \qquad \zeta = \frac{1}{2R}\sqrt{\frac{L}{C}}$$

Uwaga: w obwodzie równoległym **większe** $R$ oznacza **mniejsze** tłumienie.

### Odpowiedź na skok (napięcie na kondensatorze, szeregowy RLC, warunki zerowe)

| Przypadek | Odpowiedź |
|---|---|
| $\zeta < 1$ | $u_C = E\left[1 - e^{-\alpha t}\left(\cos\omega_d t + \dfrac{\alpha}{\omega_d}\sin\omega_d t\right)\right]$, $\omega_d = \omega_0\sqrt{1 - \zeta^2}$ |
| $\zeta = 1$ | $u_C = E\left[1 - (1 + \omega_0 t)e^{-\omega_0 t}\right]$ |
| $\zeta > 1$ | Suma dwóch wykładników o stałych czasowych $-1/s_1$, $-1/s_2$ |

Dla $\zeta < 1$:
- **przeregulowanie:** $M_p = e^{-\pi\zeta/\sqrt{1 - \zeta^2}}$,
- **czas do pierwszego maksimum:** $t_p = \pi/\omega_d$.

| $\zeta$ | Przeregulowanie |
|---|---|
| 0,1 | 73% |
| 0,3 | 37% |
| 0,5 | 16% |
| 0,707 | 4,3% |
| 1 | 0% |

### Warunki początkowe dla pochodnych

Równanie 2. rzędu potrzebuje dwóch warunków. Drugi bierze się z praw komutacji:

$$\left.\frac{du_C}{dt}\right|_{0^+} = \frac{i_C(0^+)}{C}, \qquad \left.\frac{di_L}{dt}\right|_{0^+} = \frac{u_L(0^+)}{L}$$

## Przykład rozwiązany

Szeregowy RLC: $R = 100\ \Omega$, $L = 10$ mH, $C = 1\ \mu$F, skok napięcia 10 V, warunki zerowe.

1. $\omega_0 = \dfrac{1}{\sqrt{10^{-2}\cdot 10^{-6}}} = 10^4$ rad/s.
2. $\alpha = \dfrac{100}{2\cdot 0{,}01} = 5000\ \text{s}^{-1}$, $\zeta = 0{,}5$ — obwód niedotłumiony.
3. $\omega_d = 10^4\sqrt{0{,}75} \approx 8660$ rad/s.
4. $u_C(t) = 10\left[1 - e^{-5000t}\left(\cos 8660t + 0{,}577\sin 8660t\right)\right]$ V.
5. Przeregulowanie $e^{-\pi\cdot 0{,}5/0{,}866} \approx 0{,}163$ → maksimum $\approx 11{,}6$ V po czasie $t_p = \pi/8660 \approx 0{,}36$ ms.
6. Rezystancja krytyczna: $R_{kr} = 2\sqrt{10^{-2}/10^{-6}} = 200\ \Omega$.

## Typowe pułapki

- **Wzór na $\zeta$ obwodu szeregowego użyty do równoległego** (odwrotna zależność od $R$).
- **Oscylacje z pulsacją $\omega_0$** zamiast $\omega_d$.
- **Brak drugiego warunku początkowego** — trzeba go wyprowadzić z prądu kondensatora lub napięcia cewki w chwili $0^+$.
- **Napięcie na kondensatorze większe od napięcia zasilania** wydaje się błędem — w obwodzie niedotłumionym jest normalne.

## Symulacja

```spice
* 01.05 szeregowy RLC - odpowiedz skokowa dla kilku R
V1 in 0 PULSE(0 10 0 1n 1n 10m 20m)
R1 in a {R}
L1 a b 10m
C1 b 0 1u
.step param R list 20 100 200 400
.tran 0 3m
.end
```

Ćwiczenie: odczytaj przeregulowanie dla każdego $R$ i porównaj z tabelą. Sprawdź, że dla $R = 200\ \Omega$ nie ma przeregulowania.

## Zadania

1. Szeregowy RLC: $L = 1$ mH, $C = 1\ \mu$F. Wyznacz $f_0$ i rezystancję krytyczną.
2. Ten sam obwód z $R = 10\ \Omega$: wyznacz $\zeta$, $\omega_d$ i przeregulowanie odpowiedzi skokowej.
3. Równoległy RLC: $R = 250\ \Omega$, $L = 10$ mH, $C = 100$ nF. Wyznacz $\omega_0$, $\alpha$, $\zeta$ i $\omega_d$.
4. Szeregowy RLC (warunki zerowe) dołączony w $t = 0$ do źródła 10 V, $L = 10$ mH. Wyznacz $\dfrac{du_C}{dt}(0^+)$ oraz $\dfrac{di}{dt}(0^+)$.
5. Dobierz $R$ szeregowego obwodu z $L = 10$ mH i $C = 1\ \mu$F tak, aby $\zeta = 0{,}707$. Jakie będzie przeregulowanie?

<details>
<summary>Odpowiedzi</summary>

1. $f_0 = \dfrac{1}{2\pi\sqrt{10^{-9}}} \approx 5033$ Hz, $R_{kr} = 2\sqrt{1000} \approx 63{,}2\ \Omega$
2. $\alpha = 5000$, $\omega_0 \approx 31\,623$ rad/s, $\zeta \approx 0{,}158$, $\omega_d \approx 31\,225$ rad/s, przeregulowanie ≈ 60%
3. $\omega_0 \approx 31\,623$ rad/s, $\alpha = \dfrac{1}{2\cdot 250\cdot 10^{-7}} = 20\,000\ \text{s}^{-1}$, $\zeta \approx 0{,}632$, $\omega_d \approx 24\,495$ rad/s
4. $\dfrac{du_C}{dt}(0^+) = i(0^+)/C = 0$; $\dfrac{di}{dt}(0^+) = E/L = 1000$ A/s (całe napięcie odkłada się na cewce)
5. $R = 2\zeta\sqrt{L/C} \approx 141\ \Omega$; przeregulowanie ≈ 4,3%
</details>

## Źródła

- [MIT 6.002 Circuits and Electronics](https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/) — wykłady o dynamice układów 2. rzędu
- [Analog Devices — Engineering University Program](https://wiki.analog.com/university) — rozdział o obwodach 2. rzędu: pulsacja drgań własnych, tłumienie, czas narastania
- [MIT RES.18-009 Learn Differential Equations](https://ocw.mit.edu/courses/res-18-009-learn-differential-equations-up-close-with-gilbert-strang-and-cleve-moler-fall-2015/) — matematyka równań 2. rzędu
