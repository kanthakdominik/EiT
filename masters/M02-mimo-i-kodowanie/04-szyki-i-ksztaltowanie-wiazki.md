# M02.04 — Szyki antenowe, kształtowanie wiązki i estymacja kierunku

## Po co to jest

Szyk antenowy to antena, której charakterystykę kształtuje się elektronicznie: wiązkę kieruje się na użytkownika bez obracania anteny, zera charakterystyki ustawia się na zakłócenia, a z różnic faz między antenami wyznacza się kierunek nadejścia sygnału. To technologia radarów z elektronicznym sterowaniem wiązki, stacji bazowych 5G (szczególnie w paśmie milimetrowym), łączy satelitarnych, sonarów, radioastronomii i szyków mikrofonowych ([24.03](../../modules/24-elektroakustyka/03-mikrofony.md)).

## Teoria w pigułce

### Szyk liniowy równomierny (ULA)

$N$ anten co $d$ (w długościach fali). Fala z kierunku $\theta$ (od normalnej) dociera do anteny $n$ z przesunięciem fazy $2\pi nd\sin\theta$ — **wektor sterujący** $\mathbf a(\theta) = [1, e^{j2\pi d\sin\theta}, \ldots, e^{j2\pi(N-1)d\sin\theta}]^T$.

- **Kształtowanie wiązki** (beamforming): sygnał wyjściowy $y = \mathbf w^H\mathbf x$; charakterystyka $AF(\theta) = \lvert\mathbf w^H\mathbf a(\theta)\rvert$.
- **Opóźnij i zsumuj** (konwencjonalny): $\mathbf w = \mathbf a(\theta_0)/N$ — maksimum w kierunku $\theta_0$, zysk szyku $10\log_{10}N$ dB.
- Szerokość wiązki −3 dB (przy $d = \lambda/2$, na osi): ok. $\dfrac{0\text{,}886\cdot 2}{N}$ rad ≈ $\dfrac{101°}{N}$; przy odchyleniu o $\theta_0$ rośnie jak $1/\cos\theta_0$.
- Listki boczne −13,3 dB (okno prostokątne); okna (Czebyszew, Taylor) obniżają je kosztem szerszej wiązki — dokładnie jak w analizie widmowej ([07.03](../../modules/07-cps-dsp/03-okna-i-analiza-widmowa.md)).
- **Listki siatkowe** (grating lobes) dla $d > \lambda/2$ przy dużych odchyleniach — aliasing przestrzenny.

### Kształtowanie adaptacyjne

- **MVDR (Capon):** $\mathbf w = \dfrac{\mathbf R^{-1}\mathbf a(\theta_0)}{\mathbf a^H\mathbf R^{-1}\mathbf a}$ — minimalna moc wyjściowa przy zachowaniu sygnału z $\theta_0$: zera automatycznie na zakłócenia.
- Wrażliwe na błędy kalibracji i niedokładny kierunek — regularyzacja (diagonal loading).

### Estymacja kierunku nadejścia (DoA)

- **Skanowanie wiązką** — maksimum mocy; rozdzielczość ograniczona szerokością wiązki.
- **MUSIC:** wartości własne macierzy kowariancji $\mathbf R$: $K$ dużych (źródła) i $N - K$ małych (szum); kierunki źródeł to te, dla których $\mathbf a(\theta)$ jest ortogonalny do podprzestrzeni szumu: maksima $P(\theta) = 1/\lVert\mathbf E_n^H\mathbf a(\theta)\rVert^2$. Rozdzielczość lepsza niż szerokość wiązki (superrozdzielczość), wymaga dobrej kalibracji i dostatecznej liczby migawek.
- ESPRIT, estymacja ML, metody rzadkie.

### Architektury

- **Cyfrowa** — przetwornik na każdą antenę: pełna elastyczność, duży pobór mocy.
- **Analogowa** — przesuwniki fazy w torze w.cz., jedna wiązka.
- **Hybrydowa** — kilka torów cyfrowych × wiele anten analogowo; standard w paśmie milimetrowym 5G (szyki 64–256 elementów).

## Przykład rozwiązany

**Szyk 8 anten co λ/2:**

- Zysk szyku: $10\log_{10}8 = 9$ dB.
- Szerokość wiązki −3 dB na osi: 12,7° (wzór: $101°/8 = 12\text{,}7°$); po skierowaniu na 30°: 14,7° ($12\text{,}7°/\cos 30° = 14\text{,}7°$).
- Najwyższy listek boczny: −12,8 dB (dla $N = 8$; asymptotycznie −13,3 dB).
- **MUSIC** dla dwóch źródeł na −10° i 15° (25° odstępu — dwie szerokości wiązki), 200 migawek, SNR 10 dB: wyznaczone kierunki −10,1° i 15,0°; dwie wartości własne (9,4 i 6,9) wyraźnie odstają od sześciu szumowych (ok. 0,1).

## Typowe pułapki

- **Odstęp anten > λ/2** w szyku sterowanym szeroko — listki siatkowe (fałszywe wiązki).
- **Brak kalibracji** amplitud i faz torów — zniekształcona wiązka, zera w złych miejscach, błędy MUSIC.
- **Sprzężenia wzajemne** anten — rzeczywista charakterystyka elementu w szyku różni się od pojedynczej anteny.
- **MUSIC przy źródłach skorelowanych** (wielodrogowość, to samo źródło) — macierz kowariancji traci rząd; potrzebne uśrednianie podszyków (spatial smoothing).
- **Szyk wąskopasmowy dla sygnału szerokopasmowego** — przesunięcie fazy zależy od częstotliwości (zezowanie wiązki, beam squint); potrzebne opóźnienia rzeczywiste (true time delay).

## Ćwiczenie komputerowe

Charakterystyka szyku sterowanego i estymacja kierunków metodą MUSIC:

```python
import numpy as np

N, d = 8, 0.5                                             # 8 anten, odstęp λ/2
theta = np.radians(np.linspace(-90, 90, 3601))
def steer(th):
    return np.exp(2j*np.pi*d*np.arange(N)[:, None]*np.sin(np.atleast_1d(th)))

for th0 in (0, 30):
    w = steer(np.radians(th0))[:, 0]/N                    # kształtowanie wiązki opóźniająco-sumacyjne
    AF = np.abs(np.conj(w) @ steer(theta))
    AFdb = 20*np.log10(AF + 1e-12)
    main = np.where(AFdb > -3)[0]
    sl = AFdb[np.abs(np.degrees(theta) - th0) > 20].max()
    print(f"wiązka na {th0:2d}°: szerokość −3 dB = {np.degrees(theta[main[-1]] - theta[main[0]]):.1f}°, "
          f"najwyższy listek boczny {sl:.1f} dB, zysk szyku {10*np.log10(N):.1f} dB")

# MUSIC: dwa źródła na −10° i 15°, 200 migawek, SNR 10 dB
rng = np.random.default_rng(3)
src = np.radians([-10, 15]); K = 200
A = steer(src)
S = (rng.normal(size=(2, K)) + 1j*rng.normal(size=(2, K)))/np.sqrt(2)
X = A @ S + (rng.normal(size=(N, K)) + 1j*rng.normal(size=(N, K)))*np.sqrt(0.1/2)
R = X @ X.conj().T/K
ev, V = np.linalg.eigh(R)
En = V[:, :N - 2]                                         # podprzestrzeń szumu
P = 1/np.sum(np.abs(En.conj().T @ steer(theta))**2, axis=0)
peaks = [i for i in range(1, len(P) - 1) if P[i] > P[i-1] and P[i] > P[i+1]]
top = sorted(peaks, key=lambda i: P[i])[-2:]
print("MUSIC: kierunki", [float(v) for v in sorted(np.round(np.degrees(theta[top]), 1))], "° (prawdziwe: −10°, 15°)")
print("wartości własne R:", np.round(ev[::-1], 2))
```

Rozszerzenie: dodaj zakłócenie o mocy 20 dB większej niż sygnał z kierunku 40° i porównaj wyjściowy stosunek sygnału do zakłócenia dla kształtowania konwencjonalnego i MVDR.

## Zadania

1. Ile anten (co λ/2) potrzeba na wiązkę o szerokości ok. 3°?
2. Szyk 16 elementów pracuje przy 28 GHz. Jaka jest jego długość?
3. Odstęp anten wynosi 0,7λ. Przy jakim kącie odchylenia pojawi się listek siatkowy na −90°?
4. Dlaczego MUSIC potrafi rozdzielić źródła bliższe niż szerokość wiązki?
5. Jaką wartość zysku szyku uzyska się przy odbiorze (szum niezależny w antenach) dla $N = 64$?

<details>
<summary>Odpowiedzi</summary>

1. $N \approx 101°/3° \approx 34$
2. $\lambda = c/f = 10\text{,}7$ mm; długość $(16 - 1)\cdot\lambda/2 \approx 80$ mm
3. Listek siatkowy, gdy $d(\sin\theta_0 - \sin\theta_g) = \pm 1$; dla $\theta_g = -90°$: $\sin\theta_0 = 1/0\text{,}7 - 1 = 0\text{,}43$ → $\theta_0 \approx 25°$
4. Wykorzystuje strukturę modelu (sygnały w podprzestrzeni o wymiarze $K$, ortogonalnej do podprzestrzeni szumu) zamiast filtrowania przestrzennego; ograniczają go SNR, liczba migawek i błędy modelu, a nie szerokość wiązki
5. $10\log_{10}64 = 18$ dB
</details>

## Źródła

- [D. Tse, P. Viswanath — Fundamentals of Wireless Communication](https://web.stanford.edu/~dntse/wireless_book.html) — rozdział 7 (modelowanie szyków)
- [E. Björnson, J. Hoydis, L. Sanguinetti — Massive MIMO Networks](https://nowpublishers.com/article/Details/SIG-093) — modele kanałów szyków
- [11.07 Anteny](../../modules/11-pole-em-linie-anteny/07-anteny.md)
