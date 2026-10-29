# M04.06 — Anteny łatkowe i synteza szyków

## Po co to jest

Antena łatkowa (patch) to prostokąt miedzi na płytce nad płaszczyzną masy — płaska, tania, łatwa do łączenia w szyki. Jest w routerach Wi-Fi, odbiornikach GNSS, radarach samochodowych, terminalach satelitarnych, modułach 5G. Gdy łączy się wiele anten, oprócz kierunku wiązki (sterowanie fazą, [M02.04](../M02-mimo-i-kodowanie/04-szyki-i-ksztaltowanie-wiazki.md)) projektuje się **amplitudy**: rozkład wzbudzenia decyduje o poziomie listków bocznych, a więc o odporności na zakłócenia i wykrywaniu fałszywych celów — kosztem szerokości wiązki i zysku.

## Teoria w pigułce

### Antena łatkowa prostokątna

- Rezonans dla długości ok. $\lambda_g/2$; promieniują krawędzie (szczeliny) na końcach łatki.
- Wzory projektowe (model linii transmisyjnej):
  - szerokość $W = \dfrac{c}{2f_0}\sqrt{\dfrac{2}{\varepsilon_r + 1}}$,
  - $\varepsilon_{eff} = \dfrac{\varepsilon_r + 1}{2} + \dfrac{\varepsilon_r - 1}{2}\left(1 + 12\dfrac hW\right)^{-1/2}$,
  - wydłużenie krawędzi $\Delta L = 0\text{,}412h\dfrac{(\varepsilon_{eff} + 0\text{,}3)(W/h + 0\text{,}264)}{(\varepsilon_{eff} - 0\text{,}258)(W/h + 0\text{,}8)}$,
  - długość $L = \dfrac{c}{2f_0\sqrt{\varepsilon_{eff}}} - 2\Delta L$.
- Zasilanie: linia mikropaskowa z wcięciem (inset — dopasowanie przez wybór punktu zasilania), sonda koncentryczna, sprzężenie przez szczelinę.
- **Pasmo** wąskie (1–5%), rośnie z grubością podłoża i malejącym $\varepsilon_r$; zysk ok. 6–8 dBi; polaryzacja liniowa, kołowa (ścięte narożniki, dwa zasilania z przesunięciem 90° — GNSS).
- Sprawność na FR4 obniżają straty dielektryka; na laminatach w.cz. (PTFE, ceramiczne) jest wyższa.

### Synteza charakterystyki szyku

Charakterystyka szyku liniowego to transformata Fouriera rozkładu wzbudzenia — dokładnie tak jak widmo sygnału okienkowanego ([07.03](../../modules/07-cps-dsp/03-okna-i-analiza-widmowa.md)):

| Rozkład | Listki boczne | Szerokość wiązki | Uwagi |
|---|---|---|---|
| Równomierny | −13,3 dB | Najwęższa | Maksymalny zysk |
| **Dolph–Czebyszew** | Wszystkie równe, zadany poziom | Najwęższa dla danego poziomu | Optymalny w sensie minimaksowym; dla dużych N nierealistyczne wzbudzenia brzegowe |
| **Taylor** ($\bar n$) | Pierwsze $\bar n$ − 1 na zadanym poziomie, dalsze opadają | Prawie jak Czebyszew | Standard w radarach |
| Kosinusowe, Hann | Szybko opadające | Szersza | Proste |

- **Sprawność oświetlenia** (taper efficiency) $\eta = \dfrac{\lvert\sum w_n\rvert^2}{N\sum\lvert w_n\rvert^2}$ — strata zysku za obniżenie listków.
- Szyki planarne: iloczyn rozkładów w dwóch osiach; zysk ≈ zysk elementu + $10\log_{10}N$.
- Sprzężenia wzajemne zmieniają impedancję czynną każdego elementu w zależności od kąta sterowania (skan „ślepy” w szykach gęstych).

## Przykład rozwiązany

**Szyk 8 elementów co λ/2:**

| Rozkład | Szerokość −3 dB | Listki boczne | Strata zysku |
|---|---|---|---|
| Równomierny | 12,8° | −12,8 dB | 0 dB |
| Dolph–Czebyszew −30 dB | 16,4° | −30,0 dB | 0,75 dB |
| Taylor −30 dB, $\bar n = 4$ | 16,2° | −28,3 dB | 0,69 dB |

Obniżenie listków o 17 dB kosztuje 0,75 dB zysku i poszerzenie wiązki o ok. 28%. (Dla tak krótkiego szyku Taylor nie osiąga dokładnie zadanego poziomu — to rozkład projektowany dla dłuższych szyków.)

**Łatka 2,45 GHz na FR4** ($\varepsilon_r = 4\text{,}4$, $h = 1\text{,}6$ mm): $W = 37\text{,}2$ mm, $\varepsilon_{eff} = 4\text{,}08$, $\Delta L = 0\text{,}74$ mm, $L = 28\text{,}8$ mm. Wymiary trzeba potwierdzić symulacją EM (openEMS) i dostroić po pomiarze — rozrzut $\varepsilon_r$ FR4 (4,2–4,7) przesuwa rezonans o 2–3%, czyli o więcej niż pasmo anteny.

## Typowe pułapki

- **Projekt łatki na nominalne $\varepsilon_r$ FR4** bez marginesu na rozrzut — antena nie trafia w pasmo.
- **Zbyt mała płaszczyzna masy** — zmiana charakterystyki i dopasowania.
- **Obudowa (plastik) tuż nad anteną** — przesunięcie rezonansu w dół.
- **Rozkład Czebyszewa dla dużych szyków** — elementy skrajne z nierealistycznie dużym wzbudzeniem; lepiej Taylor.
- **Pominięcie błędów amplitudy i fazy** torów — rzeczywiste listki boczne wyższe o kilka dB od projektu; dla −30 dB potrzebne błędy rzędu 0,5 dB i kilku stopni.

## Ćwiczenie komputerowe

Synteza szyku (równomierny, Dolph–Czebyszew, Taylor) i wymiary anteny łatkowej:

```python
import numpy as np
import warnings
warnings.filterwarnings("ignore", category=UserWarning)   # ostrzeżenie chebwin dotyczy analizy widmowej, nie szyków
from scipy.signal.windows import chebwin, taylor

N, d = 8, 0.5
theta = np.radians(np.linspace(-90, 90, 18001))
psi = 2*np.pi*d*np.sin(theta)
def pattern(w):
    AF = np.abs(np.exp(1j*np.outer(psi, np.arange(N))) @ w)
    return 20*np.log10(AF/AF.max() + 1e-12)

for name, w in (("równomierne", np.ones(N)), ("Dolph–Czebyszew −30 dB", chebwin(N, 30)),
                ("Taylor −30 dB, n̄ = 4", taylor(N, nbar=4, sll=30))):
    P = pattern(w)
    main = np.where(P > -3)[0]
    bw = np.degrees(theta[main[-1]] - theta[main[0]])
    # pierwsze zero od osi: pierwsze minimum lokalne
    i0 = np.argmax(P); k = i0
    while k < len(P) - 1 and P[k+1] < P[k]: k += 1
    sll = P[k:].max()
    taper = (np.sum(w)**2/(N*np.sum(w**2)))
    print(f"{name:24s}: szerokość −3 dB {bw:5.1f}°, listki boczne {sll:6.1f} dB, sprawność oświetlenia {taper*100:5.1f}% "
          f"(strata zysku {abs(10*np.log10(taper)):.2f} dB); wagi {np.round(w/w.max(), 3)}")

# antena łatkowa (prostokątna) na FR4 dla 2,45 GHz — wzory projektowe (model linii transmisyjnej)
c, f0, er, h = 2.99792458e8, 2.45e9, 4.4, 1.6e-3
W = c/(2*f0)*np.sqrt(2/(er + 1))
eeff = (er + 1)/2 + (er - 1)/2*(1 + 12*h/W)**-0.5
dL = 0.412*h*(eeff + 0.3)*(W/h + 0.264)/((eeff - 0.258)*(W/h + 0.8))
L = c/(2*f0*np.sqrt(eeff)) - 2*dL
print(f"łatka 2,45 GHz na FR4 (εr = 4,4, h = 1,6 mm): W = {W*1e3:.1f} mm, ε_eff = {eeff:.3f}, ΔL = {dL*1e3:.2f} mm, L = {L*1e3:.1f} mm")
```

## Zadania

1. Policz wymiary łatki dla 5,8 GHz na laminacie $\varepsilon_r = 3\text{,}0$, $h = 0\text{,}76$ mm (użyj kodu).
2. Szyk 16 elementów o zysku elementu 6 dBi. Jaki jest przybliżony zysk szyku z rozkładem równomiernym? A z rozkładem o sprawności oświetlenia 80%?
3. Dlaczego rozkład wzbudzenia szyku i okno w analizie widmowej to ten sam problem matematyczny?
4. Jak uzyskać polaryzację kołową z jednej łatki?
5. Błędy amplitudy torów wynoszą 1 dB RMS. Czy da się utrzymać listki boczne −35 dB? Uzasadnij jakościowo.

<details>
<summary>Odpowiedzi</summary>

1. Wynik kodu: ok. $W = 18\text{,}3$ mm, $L = 14\text{,}7$ mm (przybliżenie — wymaga potwierdzenia symulacją)
2. $6 + 10\log_{10}16 = 18$ dBi; z $\eta = 0\text{,}8$: ok. 17 dBi
3. Charakterystyka szyku liniowego w funkcji $\psi = kd\sin\theta$ jest dyskretną transformatą Fouriera wag; zmniejszanie wag brzegowych tłumi listki boczne i poszerza listek główny — identycznie jak okno wobec przecieku i rozdzielczości widma
4. Ścięcie dwóch przeciwległych narożników (dwa mody prostopadłe o nieco różnych częstotliwościach z przesunięciem 90°) albo zasilanie dwóch krawędzi z przesunięciem fazy 90° (np. przez sprzęgacz gałęziowy)
5. Raczej nie — losowe błędy amplitudy i fazy tworzą „tło” listków bocznych o poziomie rzędu $\sigma^2/N$ względem listka głównego (dla 1 dB, czyli ok. 12% amplitudy, i kilkunastu elementów: ok. −30 dB), wyżej niż zakładane −35 dB; potrzebna kalibracja torów
</details>

## Źródła

- [S. J. Orfanidis — Electromagnetic Waves and Antennas](https://www.ece.rutgers.edu/~orfanidi/ewa) — szyki, synteza Dolpha–Czebyszewa i Taylora, anteny mikropaskowe
- [openEMS](https://openems.de) — przykłady symulacji anten łatkowych
- C. A. Balanis — *Antenna Theory: Analysis and Design* (płatna) — rozdziały o antenach mikropaskowych i szykach
