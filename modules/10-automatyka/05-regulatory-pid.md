# 10.05 — Regulatory PID i dobór nastaw

## Po co to jest

Regulator PID realizuje ogromną większość pętli regulacji na świecie — od temperatury lutownicy po napęd przemysłowy. Jest prosty, ale dobre działanie wymaga zrozumienia roli każdego członu, sensownego doboru nastaw i dwóch „detali”, bez których żaden praktyczny PID nie działa: filtra części różniczkującej i ochrony przed nasyceniem całki.

## Teoria w pigułce

### Postać regulatora

$$u(t) = K_p\left(e(t) + \frac{1}{T_i}\int_0^t e\,d\tau + T_d\frac{de}{dt}\right),\qquad C(s) = K_p\left(1 + \frac{1}{T_is} + \frac{T_ds}{1 + T_ds/N}\right)$$

Postać równoległa: $K_p + K_i/s + K_ds$, gdzie $K_i = K_p/T_i$, $K_d = K_pT_d$. **Filtr różniczkowania** ($N$ typowo 5–20) ogranicza wzmocnienie szumu dla wysokich częstotliwości.

### Rola członów

| Człon | Działa na | Efekt | Ryzyko |
|---|---|---|---|
| P | Bieżący uchyb | Szybsza reakcja, mniejszy uchyb (ale nie zero dla obiektu typu 0) | Za duże → oscylacje |
| I | Przeszłość (suma uchybu) | Zerowy uchyb ustalony dla stałych wartości zadanych i zakłóceń | Faza −90° przy niskich częstotliwościach, przeregulowanie, windup |
| D | Trend (pochodna) | Tłumienie, dodatnia faza w okolicy $\omega_c$ | Wzmacnia szum, „kopnięcie” przy skoku wartości zadanej |

### Praktyczne modyfikacje

- **Różniczkowanie wyjścia zamiast uchybu:** $-T_d\,dy/dt$ — brak impulsu sterowania przy skoku wartości zadanej.
- **Ważenie wartości zadanej** w członie P: $K_p(b\,r - y)$, $0 \le b \le 1$ — mniejsze przeregulowanie przy zmianie zadanej, bez zmiany reakcji na zakłócenia.
- **Anti-windup:** gdy element wykonawczy jest w nasyceniu, całka przestaje narastać (całkowanie warunkowe) lub jest korygowana sygnałem $(u_{nas} - u)/T_t$ (back-calculation).
- **Przełączanie ręczne/automatyczne bez uderzenia** (bumpless transfer) — inicjalizacja całki bieżącym sterowaniem.

### Dobór nastaw

**Ziegler–Nichols, metoda wzmocnienia krytycznego.** Regulator P, zwiększaj $K_p$ do granicy oscylacji: $K_u$, okres $T_u$.

| Regulator | $K_p$ | $T_i$ | $T_d$ |
|---|---|---|---|
| P | $0\text{,}5K_u$ | — | — |
| PI | $0\text{,}45K_u$ | $T_u/1\text{,}2$ | — |
| PID | $0\text{,}6K_u$ | $T_u/2$ | $T_u/8$ |

Daje odpowiedź szybką, ale słabo tłumioną (przeregulowanie rzędu 40–60%) — punkt startowy, nie wynik końcowy.

**Dla modelu FOPDT** $\dfrac{Ke^{-Ls}}{\tau s + 1}$ — reguła SIMC (Skogestad), $\lambda$ = żądana stała czasowa układu zamkniętego (kompromis szybkość/odporność, zalecane $\lambda = L$):

$$K_p = \frac{\tau}{K(\lambda + L)},\qquad T_i = \min\left(\tau,\ 4(\lambda + L)\right)$$

Daje PI z umiarkowanym przeregulowaniem i dobrym zapasem stabilności. Inne podejścia: metoda lambda (IMC), AMIGO (Åström–Hägglund), strojenie w dziedzinie częstotliwości (zadane $\omega_c$ i PM), automatyczne strojenie przekaźnikowe (relay autotuning — wyznacza $K_u$, $T_u$ bez doprowadzania do niestabilności).

## Przykład rozwiązany

**1. Ziegler–Nichols dla $P(s) = 1/(s+1)^3$.** Z [10.03](03-stabilnosc.md): $K_u = 8$, $\omega_u = \sqrt 3$ → $T_u = 2\pi/\sqrt 3 = 3\text{,}63$ s.
PID: $K_p = 4\text{,}8$, $T_i = 1\text{,}81$ s, $T_d = 0\text{,}45$ s. Symulacja (z $N = 10$): przeregulowanie ≈ 43%.
Łagodniejszy PI $K_p = 1$, $T_i = 2$ s: przeregulowanie ≈ 13,5%, czas ustalania (2%) ≈ 11 s.

**2. SIMC dla modelu cieplnego** $\dfrac{2e^{-10s}}{100s + 1}$ K/W z [10.01](01-modele-obiektow.md), $\lambda = L = 10$ s:
$K_p = \dfrac{100}{2\cdot 20} = 2\text{,}5$ W/K, $T_i = \min(100,\ 80) = 80$ s.

**3. Nasycenie.** Grzałka ma moc 0–20 W, wartość zadana +30 K (wymaga 15 W w stanie ustalonym). Na początku regulator żąda 75 W, element wykonawczy daje 20 W. Bez anti-windup całka narasta przez cały czas nagrzewania → przeregulowanie ok. 26%; z całkowaniem warunkowym → praktycznie zero (symulacja poniżej).

## Typowe pułapki

- **Człon D bez filtra** na zaszumionym pomiarze — sterowanie „szarpie” element wykonawczy.
- **Brak anti-windup** przy elemencie wykonawczym, który się nasyca (praktycznie zawsze: PWM 0–100%, ograniczenie prądu).
- **Nastawy dobrane na symulacji bez opóźnienia i nasycenia.**
- **Pomylone postaci regulatora** (szeregowa, równoległa, standardowa) przy przenoszeniu nastaw między narzędziami.
- **Człon I tam, gdzie obiekt już całkuje** (np. położenie) — łatwo o oscylacje; często wystarczy PD.
- **Jednostki:** $K_p$ w W/K, %/°C, V/V — przy zmianie skalowania sygnałów nastawy trzeba przeliczyć.

## Ćwiczenie komputerowe

Regulator PI dla modelu cieplnego z opóźnieniem i nasyceniem — porównanie bez i z anti-windup:

```python
import numpy as np
import matplotlib.pyplot as plt

K, tau, L = 2.0, 100.0, 10.0          # obiekt: K e^{-Ls}/(tau s + 1)
dt, Ts = 0.1, 1.0                      # krok symulacji, okres regulatora
Kp, Ti = 2.5, 80.0                     # SIMC, lambda = L
umin, umax, r = 0.0, 20.0, 30.0

def simulate(antiwindup, tend=800):
    n = int(tend/dt); x = 0.0; I = 0.0; u = 0.0
    delay = [0.0]*int(L/dt); y = np.zeros(n); us = np.zeros(n)
    for k in range(n):
        if k % int(Ts/dt) == 0:               # chwila próbkowania regulatora
            e = r - x
            v = Kp*e + I                       # sterowanie przed nasyceniem
            u = min(max(v, umin), umax)
            saturated = (v != u)
            if not (antiwindup and saturated):
                I += Kp*Ts/Ti*e                # całkowanie warunkowe
        delay.append(u); ud = delay.pop(0)
        x += dt*(-x + K*ud)/tau
        y[k], us[k] = x, u
    return y, us

t = np.arange(int(800/dt))*dt
for aw in [False, True]:
    y, us = simulate(aw)
    ts = t[np.where(abs(y - r) > 0.02*r)[0][-1]]
    print(f"anti-windup={aw}: przeregulowanie={100*(y.max() - r)/r:5.1f}%, ts(2%)={ts:.0f} s")
    plt.subplot(2, 1, 1); plt.plot(t, y, label=f'AW={aw}')
    plt.subplot(2, 1, 2); plt.plot(t, us)
plt.subplot(2, 1, 1); plt.axhline(r, color='k', lw=0.5); plt.ylabel('ΔT [K]'); plt.legend(); plt.grid()
plt.subplot(2, 1, 2); plt.ylabel('P [W]'); plt.xlabel('t [s]'); plt.grid(); plt.show()
```

Sprawdź też: $\lambda = 2L$ (wolniej, odporniej) i $\lambda = 0\text{,}5L$; nastawy ZN z metody odpowiedzi skokowej; wpływ szumu pomiaru na człon D.

## Zadania

1. $K_u = 8$, $T_u = 3\text{,}63$ s. Nastawy P, PI i PID wg Zieglera–Nicholsa.
2. Model $\dfrac{3e^{-5s}}{105s + 1}$. Nastawy PI metodą SIMC dla $\lambda = L$ i $\lambda = 3L$.
3. Dlaczego regulator P nie usuwa uchybu ustalonego przy stałym zakłóceniu, a PI usuwa?
4. Regulator ma $K_p = 2$, $T_d = 1$ s, $N = 10$. Jakie jest wzmocnienie dla bardzo wysokich częstotliwości? Co by było bez filtra?
5. Opisz zjawisko windup na przykładzie nagrzewania pieca, którego grzałka pracuje z pełną mocą przez pierwsze 10 minut.

<details>
<summary>Odpowiedzi</summary>

1. P: $K_p = 4$; PI: $K_p = 3\text{,}6$, $T_i = 3\text{,}03$ s; PID: $K_p = 4\text{,}8$, $T_i = 1\text{,}81$ s, $T_d = 0\text{,}45$ s
2. $\lambda = 5$: $K_p = 105/(3\cdot 10) = 3\text{,}5$, $T_i = \min(105, 40) = 40$ s; $\lambda = 15$: $K_p = 105/60 = 1\text{,}75$, $T_i = \min(105, 80) = 80$ s
3. Do skompensowania stałego zakłócenia potrzebne jest stałe dodatkowe sterowanie; regulator P wytworzy je tylko przy niezerowym uchybie. Całka może utrzymywać stałe sterowanie przy zerowym uchybie
4. $K_p(1 + N) = 22$ (człon D dąży do $K_pN$); bez filtra wzmocnienie rośnie bez ograniczenia z częstotliwością (+20 dB/dek) — szum pomiaru przechodzi na sterowanie
5. Przez 10 minut uchyb jest duży i dodatni, całka rośnie, choć moc i tak jest maksymalna. Gdy temperatura osiąga zadaną, całka jest ogromna — grzałka dalej grzeje pełną mocą, aż ujemny uchyb ją „rozładuje”; skutkiem jest duże przeregulowanie i długie ustalanie
</details>

## Źródła

- [Feedback Systems — Åström, Murray](https://www.cds.caltech.edu/~murray/amwiki/Second_Edition.html) — rozdział 11 (PID: nastawy, windup, implementacja)
- [MIT 6.302 Feedback Systems](https://ocw.mit.edu/courses/6-302-feedback-systems-spring-2007/) — kompensacja i regulatory
- [Brian Douglas — Control Systems Lectures](https://www.youtube.com/results?search_query=Brian+Douglas+Control+System+Lectures) — seria o PID
- S. Skogestad, „Simple analytic rules for model reduction and PID controller tuning” (Journal of Process Control, 2003) — źródło reguł SIMC
