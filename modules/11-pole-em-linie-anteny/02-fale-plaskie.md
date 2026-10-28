# 11.02 — Fale płaskie

## Po co to jest

Fala płaska to najprostsze rozwiązanie równań Maxwella i dobre przybliżenie fali radiowej daleko od anteny. Pozwala policzyć prędkość i tłumienie fali w materiale, grubość ekranu, głębokość wnikania prądu w przewodnik i odbicie od ściany czy obudowy.

## Teoria w pigułce

### Równanie falowe

Z równań Maxwella w ośrodku bez źródeł: $\nabla^2\mathbf E = \mu\varepsilon\,\partial^2\mathbf E/\partial t^2$. Rozwiązanie — fala biegnąca w kierunku $z$:

$$\mathbf E = \hat x E_0 e^{-\alpha z}\cos(\omega t - \beta z),\qquad \gamma = \alpha + j\beta = \sqrt{j\omega\mu(\sigma + j\omega\varepsilon)}$$

| Wielkość | Ośrodek bezstratny |
|---|---|
| Prędkość fazowa | $v = 1/\sqrt{\mu\varepsilon} = c/\sqrt{\mu_r\varepsilon_r}$ |
| Długość fali | $\lambda = v/f$ |
| Stała fazowa | $\beta = 2\pi/\lambda = \omega\sqrt{\mu\varepsilon}$ |
| **Impedancja falowa** | $\eta = E/H = \sqrt{\mu/\varepsilon}$; w próżni $\eta_0 \approx 377\ \Omega$ |

$\mathbf E$, $\mathbf H$ i kierunek propagacji są wzajemnie prostopadłe (fala TEM). Gęstość mocy: $S = E^2/\eta$ (wartości skuteczne).

### Ośrodek stratny i dobry przewodnik

Dielektryk stratny opisuje się **tangensem kąta strat** $\tan\delta = \sigma/(\omega\varepsilon)$ (lub $\varepsilon''/\varepsilon'$). Dla $\tan\delta \ll 1$: $\alpha \approx \tfrac{\beta}{2}\tan\delta$ — tłumienie rośnie z częstotliwością (straty laminatu FR-4 w liniach GHz, [11.06](06-linie-praktyczne-i-falowody.md)).

W **dobrym przewodniku** ($\sigma \gg \omega\varepsilon$) fala zanika na **głębokości wnikania**:

$$\delta = \sqrt{\frac{2}{\omega\mu\sigma}} = \sqrt{\frac{\rho}{\pi f\mu}}$$

| Miedź | 50 Hz | 1 MHz | 100 MHz | 1 GHz |
|---|---|---|---|---|
| $\delta$ | 9,2 mm | 65 µm | 6,5 µm | 2,1 µm |

Skutki: **zjawisko naskórkowości** — prąd w.cz. płynie przy powierzchni, rezystancja przewodu rośnie jak $\sqrt f$; ekranowanie — ekran o grubości kilku $\delta$ tłumi pole bardzo silnie (każda $\delta$ to $e^{-1}$, czyli 8,7 dB).

### Polaryzacja

Kierunek wektora E w czasie: **liniowa** (pionowa, pozioma), **kołowa** (dwie składowe o równej amplitudzie przesunięte o 90°, prawo- lub lewoskrętna), eliptyczna (ogólny przypadek). Niedopasowanie polaryzacji anten: liniowa pionowa vs pozioma — teoretycznie strata nieskończona (w praktyce 20–30 dB), liniowa vs kołowa — 3 dB. Satelity często używają polaryzacji kołowej, bo jonosfera obraca płaszczyznę polaryzacji liniowej.

### Odbicie na granicy ośrodków

Padanie prostopadłe z ośrodka 1 do 2:

$$\Gamma = \frac{\eta_2 - \eta_1}{\eta_2 + \eta_1},\qquad \tau = 1 + \Gamma$$

Te same wzory co dla linii transmisyjnej ([11.03](03-linie-transmisyjne.md)) — impedancja falowa gra rolę impedancji charakterystycznej. Metal: $\eta_2 \approx 0$ → $\Gamma \approx -1$, całkowite odbicie. Padanie ukośne: prawo Snella $n_1\sin\theta_1 = n_2\sin\theta_2$, kąt Brewstera (brak odbicia dla jednej polaryzacji), całkowite wewnętrzne odbicie (światłowód).

## Przykład rozwiązany

**Fala z powietrza na szkło** ($\varepsilon_r = 4$, padanie prostopadłe):

1. $\eta_2 = \eta_0/2 \approx 188{,}5\ \Omega$.
2. $\Gamma = (188{,}5 - 377)/(188{,}5 + 377) = -1/3$.
3. Odbita część mocy $|\Gamma|^2 = 1/9 \approx 11\%$; przechodzi 89%.
4. W szkle: $v = c/2$, $\lambda$ dwa razy krótsza.

**Ekran miedziany 35 µm (folia PCB) przy 100 MHz:** $35/6{,}5 \approx 5{,}4\,\delta$ → tłumienie absorpcyjne ok. $5{,}4\cdot 8{,}7 \approx 47$ dB (do tego dochodzi tłumienie odbiciowe; w praktyce skuteczność ekranu ograniczają szczeliny — [16](../16-pcb-emc-konstrukcja/)).

## Typowe pułapki

- **Mylenie impedancji falowej (Ω, własność ośrodka) z impedancją charakterystyczną linii** (Ω, własność geometrii i ośrodka).
- **Głębokość wnikania liczona dla innej przewodności** — mosiądz, stal, nikiel (ferromagnetyk, $\mu_r \gg 1$!) mają zupełnie inne $\delta$.
- **Ekran „pełny”, ale ze szczelinami** — szczelina o długości porównywalnej z $\lambda/2$ działa jak antena.
- **Pole bliskie anteny** traktowane jak fala płaska — stosunek E/H nie wynosi tam 377 Ω.

## Ćwiczenie komputerowe

Głębokość wnikania i rezystancja przewodu w funkcji częstotliwości:

```python
import numpy as np
import matplotlib.pyplot as plt

mu0 = 4e-7*np.pi
metals = {'miedź': (1.68e-8, 1), 'aluminium': (2.65e-8, 1), 'stal (mu_r=100)': (1.0e-7, 100)}
f = np.logspace(1, 10, 400)
r = 0.5e-3                                       # przewód o promieniu 0,5 mm
for name, (rho, mur) in metals.items():
    d = np.sqrt(rho/(np.pi*f*mu0*mur))
    plt.subplot(1, 2, 1); plt.loglog(f, d*1e6, label=name)
    Rdc = rho/(np.pi*r**2)
    Rac = np.where(d < r, rho/(2*np.pi*r*d), Rdc)   # przybliżenie warstwy przypowierzchniowej
    plt.subplot(1, 2, 2); plt.loglog(f, Rac/Rdc, label=name)
for f0 in [50, 1e6, 1e9]:
    print(f"miedź, {f0:.0e} Hz: delta = {np.sqrt(1.68e-8/(np.pi*f0*mu0))*1e6:.2f} um")
plt.subplot(1, 2, 1); plt.xlabel('f [Hz]'); plt.ylabel('δ [µm]'); plt.grid(which='both'); plt.legend()
plt.subplot(1, 2, 2); plt.xlabel('f [Hz]'); plt.ylabel('R_ac/R_dc'); plt.grid(which='both'); plt.show()
```

## Zadania

1. Prędkość, długość fali i impedancja falowa w ośrodku $\varepsilon_r = 2{,}25$ przy 1 GHz.
2. Głębokość wnikania w miedzi przy 10 kHz i 10 MHz.
3. Jaka część mocy fali odbija się od granicy powietrze–woda ($\varepsilon_r = 81$, bez strat)?
4. Gęstość mocy 1 mW/m² w polu dalekim. Jaka jest wartość skuteczna natężenia pola E?
5. Antena odbiorcza o polaryzacji kołowej odbiera falę o polaryzacji liniowej. Ile wynosi strata polaryzacyjna?

<details>
<summary>Odpowiedzi</summary>

1. $v = 2\cdot 10^8$ m/s, $\lambda = 20$ cm, $\eta = 251\ \Omega$
2. 0,65 mm i 20,6 µm
3. $\eta_2 = 377/9 \approx 41{,}9\ \Omega$, $\Gamma = -0{,}8$, odbija się 64% mocy
4. $E = \sqrt{S\eta_0} = \sqrt{10^{-3}\cdot 377} \approx 0{,}61$ V/m
5. 3 dB
</details>

## Źródła

- [Electromagnetics, Vol. 1 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-1) — fale płaskie, ośrodki stratne, głębokość wnikania, polaryzacja
- [Electromagnetics, Vol. 2 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-2) — odbicie i załamanie, padanie ukośne
- [MIT 6.013 Electromagnetics and Applications](https://ocw.mit.edu/courses/6-013-electromagnetics-and-applications-fall-2005/)
