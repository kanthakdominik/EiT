# 11.06 — Linie praktyczne i falowody

## Po co to jest

Projektując płytkę w.cz., kabel czy złącze, trzeba umieć wybrać typ linii i policzyć jej wymiary dla zadanej impedancji. Na najwyższych częstotliwościach i mocach zamiast przewodów stosuje się falowody — rury, w których fala biegnie bez przewodu środkowego, ale tylko powyżej częstotliwości odcięcia.

## Teoria w pigułce

### Typy linii

| Linia | Impedancja | Zastosowania | Uwagi |
|---|---|---|---|
| **Koncentryczna** | $Z_0 = \dfrac{60}{\sqrt{\varepsilon_r}}\ln\dfrac{D}{d}$ | Kable w.cz., pomiarowe, antenowe | Pole zamknięte w ekranie — małe promieniowanie i przesłuchy |
| **Mikropaskowa** | Wzory przybliżone (Hammerstada, Wheelera) lub kalkulator | Ścieżki na zewnętrznej warstwie PCB | Fala quasi-TEM, $\varepsilon_{eff}$ między 1 a $\varepsilon_r$ |
| **Paskowa (stripline)** | Wzory przybliżone | Ścieżki wewnętrzne między płaszczyznami masy | Czysta TEM, wolniejsza, lepiej ekranowana |
| **Koplanarna (CPW, GCPW)** | Kalkulator | W.cz. na PCB, sondy mikrofalowe | Masa obok ścieżki, łatwe przyłączanie elementów |
| **Para różnicowa** | $Z_{diff} \approx 2Z_{odd}$ | USB (90 Ω), Ethernet i LVDS (100 Ω) | Odporność na zakłócenia wspólne |
| Skrętka, linia dwuprzewodowa | ok. 100–120 Ω, 300–600 Ω | Sieci, antenowe linie symetryczne | |

**Mikropasek — wzór przybliżony** (Hammerstad, dla $W/h \geq 1$):

$$\varepsilon_{eff} = \frac{\varepsilon_r + 1}{2} + \frac{\varepsilon_r - 1}{2}\left(1 + 12\frac{h}{W}\right)^{-1/2},\qquad Z_0 = \frac{120\pi}{\sqrt{\varepsilon_{eff}}\left(\frac Wh + 1\text{,}393 + 0\text{,}667\ln\left(\frac Wh + 1\text{,}444\right)\right)}$$

Na FR-4 ($\varepsilon_r \approx 4\text{,}2$–4,6, zależne od częstotliwości i producenta) 50 Ω wymaga $W \approx 1\text{,}9h$: ok. 3 mm na laminacie 1,6 mm, ok. 0,39 mm na dielektryku 0,2 mm (płytki wielowarstwowe). Dokładne wartości — z kalkulatora producenta płytek, z uwzględnieniem grubości miedzi i maski.

### Straty i ograniczenia FR-4

Tangens strat FR-4 ok. 0,015–0,02 → tłumienie dielektryczne rośnie liniowo z częstotliwością; powyżej kilku GHz stosuje się laminaty w.cz. (np. na bazie PTFE lub ceramiki, $\tan\delta \approx 0\text{,}001$–0,004) o stabilnym $\varepsilon_r$. Chropowatość miedzi dodatkowo zwiększa straty przewodnika.

### Falowody

Rura metalowa o przekroju prostokątnym $a\times b$ ($a > b$). Fala nie jest TEM — rodzaje TE$_{mn}$ i TM$_{mn}$ propagują się tylko powyżej **częstotliwości odcięcia**:

$$f_{c,mn} = \frac{c}{2}\sqrt{\left(\frac ma\right)^2 + \left(\frac nb\right)^2}$$

Rodzaj podstawowy TE$_{10}$: $f_c = c/(2a)$ — szerokość falowodu to pół długości fali odcięcia. Zakres pracy jednomodowej: od ok. $1\text{,}25f_c$ do ok. $0\text{,}95$ częstotliwości odcięcia następnego rodzaju.

Długość fali w falowodzie: $\lambda_g = \dfrac{\lambda_0}{\sqrt{1 - (f_c/f)^2}}$ (dłuższa niż w próżni); prędkość grupowa (energii) mniejsza od $c$.

Zalety: bardzo małe straty i duża dopuszczalna moc (radary, łącza satelitarne, akceleratory). Wady: rozmiar, sztywność, wąskie pasmo. Ta sama zasada odcięcia działa w **światłowodzie** (falowód dielektryczny) i decyduje o skuteczności otworów wentylacyjnych w ekranach (otwór poniżej odcięcia tłumi falę).

## Przykład rozwiązany

**Kabel koncentryczny** typu RG-58: żyła $d = 0\text{,}9$ mm, dielektryk PE ($\varepsilon_r = 2\text{,}25$) o średnicy $D = 2\text{,}95$ mm.

1. $Z_0 = \dfrac{60}{1\text{,}5}\ln\dfrac{2\text{,}95}{0\text{,}9} = 40\cdot 1\text{,}187 \approx 47\text{,}5\ \Omega$ (w katalogu: nominalnie 50 Ω — rzeczywista żyła jest linką, a wymiary nieco inne).
2. $v = c/1\text{,}5 \approx 2\cdot 10^8$ m/s (współczynnik skrócenia 0,66); 1 m kabla to ok. 5 ns.
3. $C' = 2\pi\varepsilon/\ln(D/d) \approx 105$ pF/m, $L' = \dfrac{\mu_0}{2\pi}\ln\dfrac Dd \approx 237$ nH/m.

**Falowód WR-90** ($a = 22\text{,}86$ mm, $b = 10\text{,}16$ mm):
$f_c(\text{TE}_{10}) = 6\text{,}56$ GHz, $f_c(\text{TE}_{20}) = 13\text{,}1$ GHz, $f_c(\text{TE}_{01}) = 14\text{,}8$ GHz → zakres pracy 8,2–12,4 GHz (pasmo X). Przy 10 GHz: $\lambda_0 = 30$ mm, $\lambda_g = 39\text{,}7$ mm.

## Typowe pułapki

- **Szerokość ścieżki 50 Ω skopiowana z innej płytki** — zależy od grubości dielektryka do najbliższej płaszczyzny masy.
- **Brak ciągłej płaszczyzny masy pod linią** (podziały, szczeliny) — prąd powrotny omija przerwę, impedancja i promieniowanie rosną.
- **$\varepsilon_r$ FR-4 przyjęte jako stałe** — zmienia się z częstotliwością i między producentami.
- **Falowód używany poniżej odcięcia** — fala zanika wykładniczo (zasada działania filtrów i otworów ekranujących, ale w torze sygnałowym to błąd).
- **Para różnicowa o niesymetrycznych długościach** — konwersja na sygnał wspólny, promieniowanie.

## Ćwiczenie komputerowe

Kalkulator mikropasku (Hammerstad) i falowodu prostokątnego:

```python
import numpy as np
from scipy.optimize import brentq

def microstrip(W, h, er):
    u = W/h
    ee = (er + 1)/2 + (er - 1)/2*(1 + 12/u)**-0.5
    if u <= 1: Z = 60/np.sqrt(ee)*np.log(8/u + u/4)
    else:      Z = 120*np.pi/(np.sqrt(ee)*(u + 1.393 + 0.667*np.log(u + 1.444)))
    return Z, ee

for h in [1.6e-3, 0.2e-3]:
    W = brentq(lambda W: microstrip(W, h, 4.4)[0] - 50, h/20, 20*h)
    Z, ee = microstrip(W, h, 4.4)
    print(f"h={h*1e3:.1f} mm: W(50 Ohm) = {W*1e3:.2f} mm, eps_eff = {ee:.2f}, v = {3e8/np.sqrt(ee)/1e9*100:.1f} cm/ns")

c = 299792458
a, b = 22.86e-3, 10.16e-3
modes = sorted([(c/2*np.hypot(m/a, n/b), f"TE{m}{n}") for m in range(3) for n in range(3) if m or n])
print("częstotliwości odcięcia WR-90:", [(name, round(fc/1e9, 2)) for fc, name in modes[:4]])
f = 10e9; fc = c/(2*a)
print(f"lambda_g przy 10 GHz = {c/f/np.sqrt(1 - (fc/f)**2)*1e3:.1f} mm")
```

## Zadania

1. Kabel z dielektrykiem PTFE ($\varepsilon_r = 2\text{,}1$) ma mieć $Z_0 = 50\ \Omega$. Jaki stosunek $D/d$?
2. Policz impedancję mikropasku o szerokości 3 mm na FR-4 1,6 mm ($\varepsilon_r = 4\text{,}4$).
3. Częstotliwość odcięcia TE$_{10}$ falowodu o szerokości 15,8 mm.
4. Otwór wentylacyjny w ekranie ma średnicę 5 mm. Dla jakich częstotliwości działa jako falowód poniżej odcięcia? (dla falowodu kołowego $f_c \approx 1\text{,}841c/(\pi D)$)
5. Dlaczego para różnicowa 100 Ω nie składa się z dwóch niezależnych ścieżek 50 Ω?

<details>
<summary>Odpowiedzi</summary>

1. $\ln(D/d) = 50\sqrt{2\text{,}1}/60 = 1\text{,}208$ → $D/d \approx 3\text{,}35$
2. ≈ 51 Ω, $\varepsilon_{eff} \approx 3\text{,}32$
3. $c/(2\cdot 0\text{,}0158) \approx 9\text{,}49$ GHz (falowód WR-62, pasmo Ku)
4. $f_c \approx 1\text{,}841\cdot 3\cdot 10^8/(\pi\cdot 0\text{,}005) \approx 35$ GHz — poniżej tej częstotliwości otwór tłumi falę (tym silniej, im dłuższy „kanał” otworu)
5. Ścieżki są sprzężone polem: impedancja różnicowa to $2Z_{odd}$, gdzie $Z_{odd} < Z_0$ pojedynczej ścieżki; przy bliskim prowadzeniu ścieżki muszą być węższe niż dla 50 Ω pojedynczej linii
</details>

## Źródła

- [Fundamentals of Microwave and RF Design — M. Steer](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-microwave-and-rf-design) — linie planarne, mikropaski, materiały
- [Electromagnetics, Vol. 2 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-2) — falowody prostokątne i światłowody
- [MIT 6.013 Electromagnetics and Applications](https://ocw.mit.edu/courses/6-013-electromagnetics-and-applications-fall-2005/) — falowody i rezonatory
- Kalkulatory impedancji udostępniane przez producentów płytek i laminatów — do wartości projektowych
