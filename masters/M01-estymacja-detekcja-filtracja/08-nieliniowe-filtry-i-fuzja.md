# M01.08 — Nieliniowe filtry Kalmana i fuzja czujników

## Po co to jest

Prawie wszystkie rzeczywiste problemy estymacji stanu są nieliniowe: radar mierzy odległość i kąt, a stan to współrzędne kartezjańskie; orientacja w przestrzeni to obroty; model baterii ma nieliniową krzywą napięcia od stanu naładowania; GNSS mierzy pseudoodległości. Rozszerzony (EKF) i bezśladowy (UKF) filtr Kalmana przenoszą ideę z tematu 07 na takie układy. Fuzja czujników łączy czujniki o różnych zaletach — szybki, ale dryfujący żyroskop z wolnym, ale stabilnym akcelerometrem czy GNSS — w jedną estymatę lepszą od każdego z osobna.

## Teoria w pigułce

### EKF (rozszerzony filtr Kalmana)

Model $\mathbf x_k = f(\mathbf x_{k-1}, \mathbf u_k) + \mathbf w_k$, $\mathbf z_k = h(\mathbf x_k) + \mathbf v_k$. Linearyzacja wokół bieżącej estymaty:

$$\mathbf F_k = \frac{\partial f}{\partial\mathbf x}\Big|_{\hat{\mathbf x}_{k-1|k-1}}, \qquad \mathbf H_k = \frac{\partial h}{\partial\mathbf x}\Big|_{\hat{\mathbf x}_{k|k-1}}$$

Predykcja stanu i innowacja z funkcjami nieliniowymi ($\hat{\mathbf x}_{k|k-1} = f(\cdot)$, $\boldsymbol\nu = \mathbf z - h(\hat{\mathbf x}_{k|k-1})$), kowariancje i wzmocnienie z jakobianów.

- Działa dobrze, gdy nieliniowość jest słaba w skali niepewności.
- Problemy: błędy linearyzacji przy dużej niepewności (np. start), rozbieżność, ręczne liczenie jakobianów (błędy!), kąty (zawijanie do $[-\pi, \pi)$).

### UKF (bezśladowy filtr Kalmana)

Zamiast linearyzacji — zestaw $2n + 1$ punktów sigma (wybranych tak, by miały średnią i kowariancję estymaty) przepuszczonych przez prawdziwą funkcję nieliniową; z wyników liczy się średnią i kowariancję. Dokładność drugiego rzędu (EKF — pierwszego), bez jakobianów, porównywalny koszt.

### Filtr cząsteczkowy

Rozkład a posteriori reprezentowany przez wiele próbek z wagami (sekwencyjne Monte Carlo) — dla silnie nieliniowych i wielomodalnych problemów (lokalizacja robota na mapie, śledzenie wielu celów); koszt rośnie wykładniczo z wymiarem stanu.

### Fuzja czujników

| Przykład | Czujniki | Idea |
|---|---|---|
| **Orientacja (AHRS)** | Żyroskop + akcelerometr (+ magnetometr) | Żyroskop całkowany daje szybką, ale dryfującą orientację; akcelerometr (kierunek grawitacji) — stabilną, ale zaszumioną i zakłócaną przyspieszeniami. Filtr komplementarny (dolnoprzepustowy na akcelerometrze + górnoprzepustowy na żyroskopie) lub Kalman z dryfem żyroskopu w stanie |
| **Nawigacja INS/GNSS** | IMU 100–1000 Hz + GNSS 1–10 Hz | IMU w predykcji, GNSS w aktualizacji; estymacja dryfów IMU; luźne (położenie) lub ścisłe (pseudoodległości) sprzężenie |
| **Śledzenie radarowe** | Radar (r, θ) + ewentualnie kamera | EKF/UKF z pomiarami we współrzędnych biegunowych |
| **Stan baterii** | Prąd (całkowanie) + napięcie (model OCV) | Licznik ładunku dryfuje, napięcie zależy nieliniowo od SoC — EKF łączy oba |

Zasady: wspólny czas (znaczniki czasu, opóźnienia czujników), kalibracja (osie, dryfy, skale), spójność kowariancji (test NIS), odporność na pomiary odstające (bramkowanie innowacji: odrzuć pomiar, jeśli NIS > próg $\chi^2$).

## Przykład rozwiązany

**Śledzenie celu radarem:** cel w odległości ok. 2,2 km, radar mierzy odległość ($\sigma = 5$ m) i azymut ($\sigma = 1°$) co 0,5 s; stan $[x, y, v_x, v_y]$, model stałej prędkości.

- Błąd poprzeczny pojedynczego pomiaru: $r\sigma_\theta = 2236\cdot 0\text{,}0175 \approx 39$ m — dominuje nad błędem odległości (5 m); przeliczony pomiar ma błąd RMS ok. 32 m.
- EKF z jakobianem $h(\mathbf x) = [\sqrt{x^2 + y^2},\ \mathrm{atan2}(y, x)]$: błąd położenia ok. 7 m — 4–5 razy lepiej, bo filtr uśrednia pomiary zgodnie z modelem ruchu i z właściwą, „wydłużoną” elipsą niepewności każdego pomiaru.

## Typowe pułapki

- **Różnica kątów bez zawijania** — przy przejściu przez ±180° innowacja równa ok. 360° rozbija filtr.
- **Błąd w jakobianie** — filtr „prawie działa”; sprawdzaj jakobiany numerycznie (różnice skończone).
- **Zbyt pewna inicjalizacja** EKF daleko od prawdy — rozbieżność; inicjalizuj z pierwszych pomiarów z dużą kowariancją.
- **Ignorowanie opóźnień i niezsynchronizowanych zegarów czujników** — przy 10 m/s opóźnienie 50 ms to 0,5 m błędu.
- **Fuzja skorelowanych pomiarów jak niezależnych** (np. dwa czujniki z tym samym źródłem błędu) — zbyt optymistyczna kowariancja.
- **Akcelerometr jako „czujnik pochylenia” podczas przyspieszania** — fałszywa orientacja; zmniejsz jego wagę, gdy moduł przyspieszenia odbiega od $g$.

## Ćwiczenie komputerowe

EKF dla śledzenia celu z pomiarów odległości i azymutu:

```python
import numpy as np

rng = np.random.default_rng(7)
dt, N = 0.5, 200
F = np.block([[np.eye(2), dt*np.eye(2)], [np.zeros((2, 2)), np.eye(2)]])     # stan: x, y, vx, vy
q = 0.05
Q = q**2*np.block([[dt**4/4*np.eye(2), dt**3/2*np.eye(2)], [dt**3/2*np.eye(2), dt**2*np.eye(2)]])
s_r, s_b = 5.0, np.radians(1.0)                     # radar: odległość ±5 m, azymut ±1°
R = np.diag([s_r**2, s_b**2])

def h(x):
    return np.array([np.hypot(x[0], x[1]), np.arctan2(x[1], x[0])])
def Hjac(x):
    r2 = x[0]**2 + x[1]**2; r = np.sqrt(r2)
    return np.array([[x[0]/r, x[1]/r, 0, 0], [-x[1]/r2, x[0]/r2, 0, 0]])

x = np.array([2000.0, 1000.0, -15.0, 8.0]); truth, meas = [], []
for _ in range(N):
    x = F @ x + rng.multivariate_normal(np.zeros(4), Q)
    truth.append(x.copy()); meas.append(h(x) + rng.normal(0, [s_r, s_b]))
truth, meas = np.array(truth), np.array(meas)

z0 = meas[0]
xh = np.array([z0[0]*np.cos(z0[1]), z0[0]*np.sin(z0[1]), 0, 0]); P = np.diag([400, 400, 400, 400.0])
est = []
for z in meas:
    xh = F @ xh; P = F @ P @ F.T + Q
    Hk = Hjac(xh)
    y = z - h(xh); y[1] = (y[1] + np.pi) % (2*np.pi) - np.pi          # różnica kątów w [−π, π)
    S = Hk @ P @ Hk.T + R; K = P @ Hk.T @ np.linalg.inv(S)
    xh = xh + K @ y; P = (np.eye(4) - K @ Hk) @ P
    est.append(xh.copy())
est = np.array(est)
raw = np.column_stack([meas[:, 0]*np.cos(meas[:, 1]), meas[:, 0]*np.sin(meas[:, 1])])
sl = slice(20, None)
err_raw = np.hypot(*(raw[sl] - truth[sl, :2]).T); err_ekf = np.hypot(*(est[sl, :2] - truth[sl, :2]).T)
print(f"błąd położenia RMS: pomiar przeliczony {np.sqrt(np.mean(err_raw**2)):.1f} m, EKF {np.sqrt(np.mean(err_ekf**2)):.1f} m")
print(f"błąd poprzeczny pomiaru ≈ r·σθ = {np.hypot(2000, 1000)*s_b:.0f} m — dlatego kąt dominuje nad błędem odległości")
```

Rozszerzenie: zaimplementuj UKF dla tego samego problemu (punkty sigma, wagi) i porównaj z EKF przy większej niepewności początkowej oraz bliżej radaru (silniejsza nieliniowość).

## Zadania

1. Wyznacz jakobian funkcji pomiaru $h(\mathbf x) = \sqrt{x^2 + y^2}$ względem $(x, y)$.
2. Ile punktów sigma wymaga UKF dla stanu 6-wymiarowego?
3. Zaprojektuj filtr komplementarny kąta pochylenia: żyroskop (dryf 0,01°/s), akcelerometr (szum 0,5°). Jaka stała czasowa jest rozsądna?
4. Dlaczego EKF może się rozbiec, a filtr Kalmana dla układu liniowego — nie (przy poprawnym modelu)?
5. Jak odrzucić pojedynczy błędny pomiar GNSS (odbicie od budynku) w filtrze nawigacyjnym?

<details>
<summary>Odpowiedzi</summary>

1. $\mathbf H = [x/r,\ y/r]$, $r = \sqrt{x^2 + y^2}$
2. $2n + 1 = 13$
3. $\theta = \alpha(\theta + \omega\Delta t) + (1 - \alpha)\theta_{acc}$, stała czasowa $\tau = \Delta t\,\alpha/(1 - \alpha)$; kompromis: przy $\tau$ = kilka sekund dryf żyroskopu daje błąd rzędu $0\text{,}01°/\text{s}\cdot\tau$ (kilka setnych stopnia), a szum akcelerometru jest uśredniany ok. $\tau/\Delta t$ razy; typowo $\tau \approx 0\text{,}5$–2 s, więcej, gdy występują duże przyspieszenia ruchu
4. W układzie liniowym kowariancja nie zależy od estymaty i jest dokładna; w EKF jakobiany liczone w złym punkcie (duży błąd estymaty) dają złą kowariancję i wzmocnienie — błąd może się wzmacniać zamiast maleć
5. Bramkowanie innowacji: oblicz NIS $= \boldsymbol\nu^T\mathbf S^{-1}\boldsymbol\nu$ i odrzuć pomiar, gdy przekracza próg z rozkładu $\chi^2$ (np. 99,9% dla 2 lub 3 stopni swobody); ewentualnie zwiększ $\mathbf R$ dla podejrzanych pomiarów (estymacja odporna)
</details>

## Źródła

- [R. Labbe — Kalman and Bayesian Filters in Python](https://github.com/rlabbe/Kalman-and-Bayesian-Filters-in-Python) — EKF, UKF, filtr cząsteczkowy
- [G. Welch, G. Bishop — An Introduction to the Kalman Filter](https://www.cs.unc.edu/~welch/kalman/kalmanIntro.html) — EKF
- [MIT 2.160 Identification, Estimation, and Learning](https://ocw.mit.edu/courses/2-160-identification-estimation-and-learning-spring-2006/)
- D. Simon — *Optimal State Estimation* (płatna) — filtry nieliniowe
