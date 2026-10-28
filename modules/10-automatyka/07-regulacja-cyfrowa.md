# 10.07 — Regulacja cyfrowa

## Po co to jest

Prawie każdy współczesny regulator to kod w mikrokontrolerze: próbkuje pomiar, liczy sterowanie i wystawia je przez PWM lub przetwornik C/A. Próbkowanie, kwantyzacja i czas obliczeń wpływają na stabilność, a sposób dyskretyzacji i implementacji decyduje, czy regulator zachowa się tak jak w projekcie.

## Teoria w pigułce

### Pętla cyfrowa

Przetwornik A/C → algorytm → przetwornik C/A z **ekstrapolatorem zerowego rzędu (ZOH)** (wartość trzymana przez okres $T$). Podstawy próbkowania i transformaty Z — [06.06](../06-sygnaly-i-systemy/06-probkowanie.md), [06.07](../06-sygnaly-i-systemy/07-czas-dyskretny-i-transformata-z.md).

**Opóźnienie fazowe próbkowania:** ZOH działa jak opóźnienie o $T/2$ → strata fazy $\omega_cT/2$ przy pulsacji odcięcia. Do tego czas obliczeń (często cały okres, jeśli sterowanie wystawiane jest na początku następnego cyklu).

### Dobór okresu próbkowania

- Reguła praktyczna: $\omega_cT \approx 0{,}05$–$0{,}3$, czyli 20–120 próbek na okres pulsacji odcięcia; lub 4–10 próbek na czas narastania.
- Filtr antyaliasingowy przed przetwornikiem A/C, ale jego faza też wchodzi do pętli.
- Za szybkie próbkowanie: problemy numeryczne (bieguny dyskretne blisko 1, kwantyzacja różnicy w członie D).

### Metody dyskretyzacji regulatora

| Metoda | Podstawienie | Cechy |
|---|---|---|
| Euler w przód | $s \to \dfrac{z - 1}{T}$ | Najprostsza; może zdestabilizować stabilny regulator |
| Euler wstecz | $s \to \dfrac{z - 1}{zT}$ | Zawsze stabilna; dobra dla całkowania i różniczkowania z filtrem |
| **Tustin (biliniowa)** | $s \to \dfrac{2}{T}\dfrac{z - 1}{z + 1}$ | Najwierniejsza charakterystyka; zniekształcenie skali częstotliwości ([07.05](../07-cps-dsp/05-filtry-iir.md)) |
| ZOH (dla obiektu) | Dokładna dyskretyzacja z ZOH | Do projektowania bezpośrednio w dziedzinie z |

### PID w postaci dyskretnej

Postać pozycyjna (z całkowaniem Eulera wstecz i różniczkowaniem z filtrem):

$$I_k = I_{k-1} + \frac{K_pT}{T_i}e_k,\qquad D_k = \frac{T_f}{T_f + T}D_{k-1} - \frac{K_pT_d}{T_f + T}(y_k - y_{k-1}),\qquad u_k = K_pe_k + I_k + D_k$$

($T_f = T_d/N$; różniczkowanie wyjścia). Postać przyrostowa $\Delta u_k$ naturalnie ogranicza windup i ułatwia przełączanie trybów.

### Implementacja

- **Stała częstotliwość wywołań** — z przerwania timera lub zadania RTOS o stałym okresie ([09.03](../09-mikrokontrolery-embedded/03-timery-i-pwm.md), [09.07](../09-mikrokontrolery-embedded/07-oprogramowanie-embedded.md)), nie z pętli głównej.
- Odczyt → obliczenie → zapis sterowania jak najbliżej siebie w czasie; minimalizuj jitter.
- Arytmetyka: zmiennoprzecinkowa (jeśli rdzeń ma FPU) lub stałoprzecinkowa ze skalowaniem i nasyceniem ([07.06](../07-cps-dsp/06-realizacja-filtrow.md)).
- Ograniczenie sterowania, anti-windup, obsługa awarii czujnika (wartość spoza zakresu → bezpieczny stan).

## Przykład rozwiązany

**Strata fazy:** pętla z $\omega_c = 10$ rad/s, $T = 10$ ms: ZOH daje $\omega_cT/2 = 0{,}05$ rad ≈ **2,9°**. Jeśli obliczenia zajmują jeszcze cały okres: łącznie $1{,}5\omega_cT = 0{,}15$ rad ≈ 8,6°. Przy $T = 100$ ms strata wyniosłaby 29° (lub 86°) — pętla, która miała PM = 50°, staje się prawie niestabilna.

**Regulator temperatury** z [10.05](05-regulatory-pid.md): $\tau = 100$ s, $L = 10$ s, $\lambda = 10$ s; $\omega_c \approx 1/\lambda = 0{,}1$ rad/s. $T = 1$ s daje stratę 0,05 rad ≈ 3° — w zupełności wystarcza.

## Typowe pułapki

- **Regulator wywoływany z pętli głównej o zmiennym czasie obiegu** — zmienny $T$, a nastawy liczone dla stałego.
- **Zmiana okresu próbkowania bez przeliczenia współczynników** ($K_pT/T_i$, $T_d/T$).
- **Człon D liczony z różnicy jednej próbki przy szybkim próbkowaniu** — kwantyzacja przetwornika daje impulsy sterowania; filtr lub wolniejsze próbkowanie pochodnej.
- **Przepełnienie w arytmetyce stałoprzecinkowej** całki.
- **Pominięcie opóźnienia obliczeń** w analizie stabilności.

## Ćwiczenie komputerowe

Dyskretyzacja regulatora PI metodą Tustina i porównanie charakterystyk:

```python
import numpy as np
from scipy import signal

Kp, Ti, T = 2.5, 80.0, 1.0
num, den = [Kp*Ti, Kp], [Ti, 0]                  # Kp(1 + 1/(Ti s)) = Kp(Ti s + 1)/(Ti s)
bd, ad, _ = signal.cont2discrete((num, den), T, method='bilinear')
print("Tustin: b =", np.ravel(bd).round(5), " a =", np.ravel(ad).round(5))
# u[k] = u[k-1] + b0 e[k] + b1 e[k-1]

for w in [0.01, 0.1, 0.5]:
    _, Hc = signal.freqs(num, den, [w])
    _, Hd = signal.freqz(np.ravel(bd), np.ravel(ad), [w*T])
    print(f"w={w}: |C| ciągły {abs(Hc[0]):.3f}, dyskretny {abs(Hd[0]):.3f}; "
          f"faza {np.angle(Hc[0], deg=True):6.1f} / {np.angle(Hd[0], deg=True):6.1f} deg")
for wc, Tp in [(10, 0.01), (10, 0.1), (0.1, 1.0)]:
    print(f"wc={wc}, T={Tp}: strata fazy ZOH = {np.degrees(wc*Tp/2):.1f} deg")
```

## Ćwiczenie — kod C (testowany na komputerze)

Regulator PI z ograniczeniem i anti-windup + prosty model obiektu do testu:

```c
#include <stdio.h>

typedef struct { float kp, ki_t, umin, umax, integ; } pi_t;   /* ki_t = Kp*T/Ti */

float pi_step(pi_t *c, float r, float y) {
    float e = r - y;
    float v = c->kp*e + c->integ;
    float u = v > c->umax ? c->umax : (v < c->umin ? c->umin : v);
    if (u == v) c->integ += c->ki_t*e;          /* całkowanie warunkowe */
    return u;
}

int main(void) {                                 /* model: 2/(100s+1), bez opóźnienia, T = 1 s */
    pi_t c = { 2.5f, 2.5f*1.0f/80.0f, 0.0f, 20.0f, 0.0f };
    float x = 0.0f, ymax = 0.0f;
    for (int k = 0; k < 600; k++) {
        float u = pi_step(&c, 30.0f, x);
        for (int i = 0; i < 10; i++) x += 0.1f*(-x + 2.0f*u)/100.0f;   /* 10 kroków po 0,1 s */
        if (x > ymax) ymax = x;
        if (k % 100 == 99) printf("t=%3d s  T=%6.2f K  P=%5.2f W\n", k + 1, x, u);
    }
    printf("maksimum: %.2f K\n", ymax);
    return 0;
}
```

`gcc -Wall -o pi pi.c && ./pi`. Na mikrokontrolerze `pi_step` wywołuj w przerwaniu timera co $T$, wynik zamieniaj na wypełnienie PWM.

## Zadania

1. Strata fazy ZOH dla $\omega_c = 10$ rad/s przy $T = 10$ ms i $T = 100$ ms.
2. Pętla przetwornicy ma $\omega_c = 2\pi\cdot 10$ kHz, regulator cyfrowy próbkuje z 200 kHz, obliczenia zajmują jeden okres. Ile wynosi strata fazy?
3. Zdyskretyzuj integrator $1/s$ metodą Eulera wstecz i Tustina. Zapisz równania różnicowe.
4. Dlaczego Euler w przód może dać niestabilny regulator dyskretny z regulatora stabilnego?
5. Regulator temperatury ma $\lambda = 10$ s. Zaproponuj okres próbkowania i uzasadnij.

<details>
<summary>Odpowiedzi</summary>

1. 2,9° i 29°
2. $1{,}5\cdot\omega_cT = 1{,}5\cdot 2\pi\cdot 10^4\cdot 5\ \mu\text{s} = 0{,}47$ rad ≈ 27° — znacząca część zapasu fazy, stąd w cyfrowych zasilaczach dąży się do minimalnego opóźnienia obliczeń
3. Euler wstecz: $y_k = y_{k-1} + Tx_k$; Tustin: $y_k = y_{k-1} + \dfrac T2(x_k + x_{k-1})$
4. Odwzorowuje lewą półpłaszczyznę s na półpłaszczyznę $\text{Re}(z) < 1$, nie na wnętrze koła jednostkowego — szybkie bieguny ($|sT| > 2$) trafiają poza koło
5. Np. $T = 0{,}5$–1 s: $\omega_c \approx 0{,}1$ rad/s, strata fazy ≤ 3°; szybciej nie ma sensu (szum, kwantyzacja), wolniej niż ok. 2–3 s zaczyna zjadać zapas fazy
</details>

## Źródła

- [Feedback Systems — Åström, Murray](https://www.cds.caltech.edu/~murray/amwiki/Second_Edition.html) — implementacja cyfrowa PID (rozdział 11)
- [MIT 6.003 Signals and Systems](https://ocw.mit.edu/courses/6-003-signals-and-systems-fall-2011/) — układy dyskretne, transformata Z, sprzężenie zwrotne w czasie dyskretnym
- [SciPy — scipy.signal.cont2discrete](https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.cont2discrete.html)
- [Interrupt (blog Memfault)](https://interrupt.memfault.com/) — implementacja zadań okresowych i pomiar czasu wykonania w firmware
