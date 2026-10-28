# 10.01 — Modele obiektów i schematy blokowe

## Po co to jest

Regulator projektuje się do modelu obiektu. Model nie musi być dokładny — wystarczy, że oddaje wzmocnienie, dominujące stałe czasowe i opóźnienie. Typowe człony dynamiczne i umiejętność przekształcania schematów blokowych to słownik całej automatyki.

## Teoria w pigułce

### Podstawowe człony

| Człon | Transmitancja | Odpowiedź skokowa | Przykład w elektronice |
|---|---|---|---|
| Proporcjonalny | $K$ | Natychmiastowy skok | Dzielnik napięcia, wzmacniacz idealny |
| **Inercyjny 1. rzędu** | $\dfrac{K}{\tau s + 1}$ | Narastanie wykładnicze, 63% po $\tau$ | Obwód RC, nagrzewanie radiatora, prędkość silnika |
| **Całkujący** | $\dfrac{K}{s}$ | Rampa | Kondensator ładowany prądem, położenie z prędkości, faza VCO |
| Różniczkujący (rzeczywisty) | $\dfrac{Ks}{\tau s + 1}$ | Impuls zanikający | Układ CR |
| **Oscylacyjny 2. rzędu** | $\dfrac{K\omega_n^2}{s^2 + 2\zeta\omega_n s + \omega_n^2}$ | Oscylacje tłumione dla $\zeta < 1$ | Filtr LC przetwornicy, układ mechaniczny ze sprężystością |
| **Opóźnienie** | $e^{-Ls}$ | Przesunięcie w czasie | Transport ciepła, czas obliczeń, próbkowanie |

**Model FOPDT** (inercja 1. rzędu z opóźnieniem) $G(s) = \dfrac{K e^{-Ls}}{\tau s + 1}$ opisuje zaskakująco wiele obiektów przemysłowych i cieplnych i jest podstawą większości reguł doboru nastaw PID.

### Modele z praw fizyki

- **Cieplny:** $C_{th}\dfrac{dT}{dt} = P - \dfrac{T - T_{ot}}{R_{th}}$ → $\dfrac{\Delta T(s)}{P(s)} = \dfrac{R_{th}}{R_{th}C_{th}s + 1}$ (analogia elektryczna: $P$ ↔ prąd, $T$ ↔ napięcie — [03.09](../03-przyrzady-polprzewodnikowe/09-datasheety-i-termika.md)).
- **Silnik DC** (prędkość od napięcia, pomijając indukcyjność): $\dfrac{\Omega(s)}{U(s)} = \dfrac{K_m}{\tau_m s + 1}$; położenie dodaje całkowanie.
- **Obwody RLC** — [01.05](../01-teoria-obwodow/05-obwody-2-rzedu.md), [01.08](../01-teoria-obwodow/08-laplace-w-obwodach.md).

### Linearyzacja

Obiekty nieliniowe linearyzuje się wokół punktu pracy: $\Delta y \approx \left.\dfrac{\partial f}{\partial x}\right|_{x_0}\Delta x$. Model obowiązuje dla małych odchyłek — zysk obiektu może zmieniać się z punktem pracy (np. dioda, zawór, grzałka zasilana napięciem — moc $\propto U^2$).

### Schematy blokowe

| Połączenie | Transmitancja zastępcza |
|---|---|
| Szeregowe | $G_1G_2$ |
| Równoległe | $G_1 + G_2$ |
| **Ujemne sprzężenie zwrotne** | $\dfrac{G}{1 + GH}$ |

Układ regulacji: regulator $C(s)$, obiekt $P(s)$, czujnik $H(s)$. Pętla otwarta $L = CPH$. Transmitancje układu zamkniętego (dla $H = 1$):

$$T = \frac{L}{1 + L}\ \text{(wartość zadana → wyjście)},\qquad S = \frac{1}{1 + L}\ \text{(funkcja czułości: zakłócenie wyjścia → wyjście)}$$

$S + T = 1$ — nie da się mieć jednocześnie dobrego śledzenia i tłumienia szumu czujnika na tej samej częstotliwości.

### Identyfikacja z odpowiedzi skokowej

1. Skok sterowania $\Delta u$ w punkcie pracy, zapis wyjścia.
2. $K = \Delta y_{ust}/\Delta u$.
3. Opóźnienie $L$ i stała czasowa $\tau$: np. metoda dwóch punktów — czasy osiągnięcia 28,3% i 63,2% zmiany: $\tau = 1{,}5(t_{63} - t_{28})$, $L = t_{63} - \tau$.

## Przykład rozwiązany

Grzałka na bloczku aluminium: $R_{th} = 2$ K/W, $C_{th} = 50$ J/K.

1. $G(s) = \dfrac{2}{100s + 1}$ K/W: $K = 2$ K/W, $\tau = R_{th}C_{th} = 100$ s.
2. Skok mocy 10 W → przyrost temperatury w stanie ustalonym 20 K, 63% (12,6 K) po 100 s, praktycznie ustalony (98%) po $4\tau = 400$ s.
3. Czujnik przyklejony w pewnej odległości od grzałki dodaje opóźnienie — z pomiaru np. $L \approx 10$ s. Model: $\dfrac{2e^{-10s}}{100s + 1}$ (używany w projekcie modułowym i w [10.05](05-regulatory-pid.md)).

## Typowe pułapki

- **Mylenie stałej czasowej z czasem ustalania** ($t_s \approx 4\tau$ dla 2%).
- **Pominięcie opóźnienia** — to ono najczęściej ogranicza osiągalną szybkość regulacji.
- **Identyfikacja przy zbyt małym skoku** (szum) lub zbyt dużym (nieliniowość, nasycenie).
- **Model zlinearyzowany używany daleko od punktu pracy.**
- **Zapomniany znak w węźle sumacyjnym** przy redukcji schematu.

## Ćwiczenie komputerowe

Identyfikacja modelu FOPDT z zaszumionej odpowiedzi skokowej metodą dwóch punktów:

```python
import numpy as np
import matplotlib.pyplot as plt

K, tau, L = 2.0, 100.0, 10.0
t = np.arange(0, 600, 0.5)
y = np.where(t > L, K*10*(1 - np.exp(-(t - L)/tau)), 0.0)   # skok 10 W
rng = np.random.default_rng(0)
ym = y + 0.1*rng.standard_normal(t.size)                     # szum czujnika

dy = np.mean(ym[-50:])
t28 = t[np.argmax(ym >= 0.283*dy)]
t63 = t[np.argmax(ym >= 0.632*dy)]
tau_e = 1.5*(t63 - t28); L_e = t63 - tau_e
print(f"K={dy/10:.2f} K/W, tau={tau_e:.1f} s, L={L_e:.1f} s")

ye = np.where(t > L_e, dy*(1 - np.exp(-(t - L_e)/tau_e)), 0.0)
plt.plot(t, ym, '.', ms=2, label='pomiar'); plt.plot(t, ye, label='model')
plt.xlabel('t [s]'); plt.ylabel('ΔT [K]'); plt.legend(); plt.grid(); plt.show()
```

## Zadania

1. Wyprowadź transmitancję $U_{wy}/U_{we}$ obwodu RC i porównaj z członem inercyjnym.
2. Uprość schemat: regulator $C = K_p$, obiekt $P = \dfrac{1}{s(s+2)}$, czujnik $H = 1$. Podaj transmitancję układu zamkniętego.
3. Odpowiedź skokowa (skok 5 W): przyrost ustalony 15 K, 28,3% osiągnięte po 40 s, 63,2% po 110 s. Wyznacz model FOPDT.
4. Pokaż, że $S + T = 1$.
5. Grzałka zasilana napięciem $U$ ma moc $U^2/R$. Zlinearyzuj zależność mocy od napięcia w punkcie $U_0 = 6$ V, $R = 4$ Ω. Jak sterowanie PWM rozwiązuje problem?

<details>
<summary>Odpowiedzi</summary>

1. $\dfrac{1}{RCs + 1}$ — człon inercyjny z $K = 1$, $\tau = RC$
2. $T = \dfrac{K_p}{s^2 + 2s + K_p}$
3. $K = 3$ K/W; $\tau = 1{,}5\cdot 70 = 105$ s; $L = 110 - 105 = 5$ s
4. $S + T = \dfrac{1}{1+L} + \dfrac{L}{1+L} = 1$
5. $\partial P/\partial U = 2U_0/R = 3$ W/V (moc w punkcie 9 W); wzmocnienie zależy od punktu pracy. Średnia moc przy PWM wynosi $D\cdot U^2/R$ — jest liniowa względem wypełnienia
</details>

## Źródła

- [Feedback Systems — Åström, Murray](https://www.cds.caltech.edu/~murray/amwiki/Second_Edition.html) — rozdziały 2–3 (modelowanie) i 9 (transmitancje, schematy blokowe)
- [MIT 6.302 Feedback Systems](https://ocw.mit.edu/courses/6-302-feedback-systems-spring-2007/) — modele i schematy blokowe układów elektronicznych
- [Brian Douglas — Control Systems Lectures](https://www.youtube.com/results?search_query=Brian+Douglas+Control+System+Lectures) — schematy blokowe, modelowanie
