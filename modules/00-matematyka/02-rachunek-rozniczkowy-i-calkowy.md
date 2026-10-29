# 00.02 — Rachunek różniczkowy i całkowy

## Po co to jest

- Prąd kondensatora to pochodna napięcia: $i_C = C\dfrac{du_C}{dt}$. Napięcie cewki to pochodna prądu: $u_L = L\dfrac{di_L}{dt}$.
- Wartość średnia i skuteczna (RMS) sygnału to całki.
- Energia zgromadzona w kondensatorze i cewce to całki mocy.
- **Linearyzacja** (pierwszy wyraz szeregu Taylora) to dokładnie to, co robimy, tworząc modele małosygnałowe diody i tranzystora.
- Szukanie ekstremum (pochodna = 0) daje warunek dopasowania mocy.

## Teoria w pigułce

**Pochodna** mówi, jak szybko zmienia się wielkość. **Całka** sumuje wielkość w czasie (pole pod wykresem).

Najważniejsze reguły różniczkowania:

| Reguła | Wzór |
|---|---|
| Iloczyn | $(fg)' = f'g + fg'$ |
| Iloraz | $\left(\dfrac{f}{g}\right)' = \dfrac{f'g - fg'}{g^2}$ |
| Funkcja złożona | $\left(f(g(t))\right)' = f'(g(t))\cdot g'(t)$ |
| Typowe | $(e^{at})' = ae^{at}$, $(\sin\omega t)' = \omega\cos\omega t$, $(\cos\omega t)' = -\omega\sin\omega t$, $(\ln t)' = 1/t$ |

Całkowanie przez części: $\int u\,dv = uv - \int v\,du$.

**Szereg Taylora** w otoczeniu punktu $x_0$:

$$f(x) \approx f(x_0) + f'(x_0)(x - x_0) + \frac{f''(x_0)}{2}(x - x_0)^2 + \dots$$

Zachowanie tylko pierwszego wyrazu liniowego to **linearyzacja w punkcie pracy**.

## Wzory i założenia

**Wartość średnia** sygnału okresowego o okresie $T$:

$$U_{AV} = \frac{1}{T}\int_0^T u(t)\,dt$$

**Wartość skuteczna** (RMS) — wartość napięcia stałego, które wydzieli w rezystorze tę samą moc:

$$U_{RMS} = \sqrt{\frac{1}{T}\int_0^T u^2(t)\,dt}$$

| Przebieg (amplituda $U_m$) | $U_{AV}$ (z modułu / po wyprostowaniu) | $U_{RMS}$ |
|---|---|---|
| Sinusoida | $2U_m/\pi$ (po wyprostowaniu dwupołówkowym) | $U_m/\sqrt{2}$ |
| Sinusoida wyprostowana jednopołówkowo | $U_m/\pi$ | $U_m/2$ |
| Prostokąt ±$U_m$ | $U_m$ (z modułu) | $U_m$ |
| Prostokąt 0…$U_m$, wypełnienie $D$ | $DU_m$ | $U_m\sqrt{D}$ |
| Trójkąt symetryczny ±$U_m$ | $U_m/2$ (z modułu) | $U_m/\sqrt{3}$ |

## Przykład rozwiązany

**Rezystancja dynamiczna diody.** Prąd diody opisuje równanie $I = I_S e^{U/U_T}$ (dla przewodzenia, $U_T \approx 26$ mV w temperaturze pokojowej). Jak dioda reaguje na mały przyrost napięcia wokół punktu pracy $I_D = 1$ mA?

1. Linearyzujemy: $\Delta I \approx \dfrac{dI}{dU}\Delta U$.
2. $\dfrac{dI}{dU} = \dfrac{I_S}{U_T}e^{U/U_T} = \dfrac{I}{U_T}$.
3. Rezystancja dynamiczna: $r_d = \dfrac{dU}{dI} = \dfrac{U_T}{I_D} = \dfrac{26\ \text{mV}}{1\ \text{mA}} = 26\ \Omega$.

To jest cały „model małosygnałowy diody” — zwykła pochodna w punkcie pracy.

## Typowe pułapki

- **Wartość średnia sinusoidy w pełnym okresie wynosi 0.** „Średnia” w tabelach dotyczy sygnału wyprostowanego lub modułu.
- **RMS sumy ≠ suma RMS.** Dla składowej stałej $U_0$ i sinusoidy o RMS $U_1$: $U_{RMS} = \sqrt{U_0^2 + U_1^2}$.
- **Pochodna funkcji złożonej.** $\dfrac{d}{dt}\sin(\omega t) = \omega\cos(\omega t)$ — łatwo zgubić $\omega$.
- **Granice całkowania** — całkuj po pełnym okresie albo po przedziale, w którym funkcja ma stały wzór.

## Symulacja / ćwiczenie komputerowe

```python
import numpy as np

T = 1e-3
t = np.linspace(0, T, 100_001)
u = 4 * np.sin(2 * np.pi * t / T)
print("RMS:", np.sqrt(np.mean(u**2)))                    # ≈ 2.828
print("średnia z modułu:", np.mean(np.abs(u)))            # ≈ 2.546 = 8/π
```

W LTspice: źródło sinusoidalne, a w oknie przebiegów **Ctrl + klik na nazwie przebiegu** pokazuje wartość średnią i skuteczną. Sprawdź wartości z tabeli dla kilku przebiegów.

## Zadania

1. Wyznacz wartość skuteczną przebiegu trójkątnego symetrycznego o amplitudzie $A$.
2. Napięcie $u(t) = 10\sin(1000t)$ V jest przyłożone do kondensatora $C = 10\ \mu$F. Wyznacz prąd i jego amplitudę.
3. Wykaż, że energia zgromadzona w kondensatorze naładowanym do napięcia $U$ wynosi $W = \dfrac{CU^2}{2}$.
4. Moc wydzielana w obciążeniu źródła o SEM $E$ i rezystancji wewnętrznej $R_w$ wynosi $P(R_L) = \dfrac{E^2 R_L}{(R_w + R_L)^2}$. Znajdź $R_L$, dla którego moc jest maksymalna.
5. Przybliż $e^{x}$ szeregiem Taylora do wyrazu kwadratowego i oszacuj błąd dla $x = 0\text{,}1$.
6. Przebieg prostokątny ma poziomy 0 i 5 V oraz wypełnienie 20%. Wyznacz wartość średnią i skuteczną.

<details>
<summary>Odpowiedzi</summary>

1. $A/\sqrt{3}$ (na ćwierci okresu $u = 4At/T$; $\frac{4}{T}\int_0^{T/4}(4At/T)^2dt = A^2/3$)
2. $i = C\dfrac{du}{dt} = 10\cdot 10^{-6}\cdot 10\cdot 1000\cos(1000t) = 0\text{,}1\cos(1000t)$ A, amplituda 100 mA
3. $W = \int_0^t u\,i\,dt = \int_0^U u\,C\,du = \dfrac{CU^2}{2}$
4. $\dfrac{dP}{dR_L} = E^2\dfrac{(R_w + R_L) - 2R_L}{(R_w + R_L)^3} = 0 \Rightarrow R_L = R_w$
5. $e^x \approx 1 + x + x^2/2 = 1\text{,}105$; dokładnie $1\text{,}10517$; błąd ok. $1\text{,}7\cdot 10^{-4}$ (rzędu następnego wyrazu $x^3/6$)
6. $U_{AV} = 1$ V, $U_{RMS} = 5\sqrt{0\text{,}2} \approx 2\text{,}24$ V
</details>

## Źródła

- [MIT RES.18-001 Calculus (G. Strang)](https://ocw.mit.edu/courses/res-18-001-calculus-fall-2023/)
- [Paul's Online Math Notes](https://tutorial.math.lamar.edu/) — działy Calculus I i II, z zadaniami i rozwiązaniami
- [3Blue1Brown](https://www.3blue1brown.com/) — seria *Essence of Calculus*
- [Modular Electronics Learning (ModEL)](https://ibiblio.org/kuphaldt/socratic/model/) — moduły matematyczne pod kątem elektroniki
