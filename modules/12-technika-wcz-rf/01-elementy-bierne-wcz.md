# 12.01 — Elementy bierne na wielkich częstotliwościach

## Po co to jest

Na częstotliwościach radiowych żaden element nie jest idealny. Kondensator ma indukcyjność wyprowadzeń i powyżej rezonansu własnego staje się cewką, cewka ma pojemność międzyzwojową i staje się kondensatorem, rezystor ma jedno i drugie, a ścieżka na płytce dodaje swoje. Dobór elementów, ich obudów i ułożenia decyduje o tym, czy obwód w.cz. działa zgodnie z obliczeniami.

## Teoria w pigułce

### Modele rzeczywistych elementów

| Element | Model zastępczy | Konsekwencja |
|---|---|---|
| **Kondensator** | C + ESL + ESR szeregowo | Rezonans własny (SRF) $f = 1/(2\pi\sqrt{ESL\cdot C})$; powyżej — indukcyjny |
| **Cewka** | L + R szeregowo, równolegle $C_p$ | SRF $= 1/(2\pi\sqrt{LC_p})$; powyżej — pojemnościowa |
| Rezystor | R + L szeregowo, równolegle C | Rezystory wysokoomowe „pojemnościowe”, niskoomowe „indukcyjne” |
| Ścieżka, przelotka | ok. 0,5–1 nH na mm ścieżki (zależnie od geometrii), przelotka ok. 0,5–1 nH | Masa przez przelotkę nie jest „idealną masą” |

ESL zależy głównie od **obudowy i ułożenia** (długości pętli prądowej), nie od pojemności: 0402 — ok. 0,3–0,5 nH, 0603 — ok. 0,5–0,9 nH, 1206 — ok. 1 nH i więcej (wartości orientacyjne; dokładne podają modele producentów).

### Dobroć

$$Q = \frac{X}{R} = \frac{\text{energia zmagazynowana}}{\text{energia tracona na okres}}\cdot 2\pi$$

Dobroć cewek SMD na 1 GHz: od ok. 20 (cewki wielowarstwowe) do 50–100 (cewki nawijane drutem, ceramiczne). Dobroć elementów ogranicza tłumienie w paśmie filtrów, sprawność dopasowań i szum fazowy oscylatorów. Kondensatory w.cz. z dielektrykiem C0G/NP0 mają bardzo małe straty i stałą pojemność — **w torze w.cz. nie stosuje się dielektryków X7R/Y5V** (zmienność z napięciem i temperaturą, straty).

### Obwody rezonansowe

Szeregowy: impedancja minimalna w rezonansie, równoległy: maksymalna. Pasmo −3 dB: $B = f_0/Q_L$, gdzie $Q_L$ — dobroć obciążona (uwzględnia źródło i obciążenie). Przekształcenie szeregowe ↔ równoległe przy dużym $Q$: $R_p \approx Q^2R_s$, $X_p \approx X_s$.

### Odsprzęganie zasilania w.cz.

Kondensator jest skuteczny w okolicy swojego SRF. Dla szerokiego pasma: kilka wartości równolegle (np. 100 nF + 100 pF), ale uwaga na **rezonans równoległy między nimi** (antyrezonans) — maksimum impedancji między SRF obu. Dławiki i koraliki ferrytowe w zasilaniu stopni w.cz.; koralik ma charakter rezystancyjny w swoim zakresie pracy.

## Przykład rozwiązany

1. **Kondensator 100 nF, ESL 1 nH:** SRF ≈ 15,9 MHz. Przy 1 GHz jego reaktancja to praktycznie $\omega\cdot ESL \approx 6{,}3\ \Omega$ (indukcyjna). Do odsprzęgania przy 1 GHz lepszy jest 10 pF w 0402 z ESL ok. 0,5 nH: SRF ≈ 2,25 GHz.
2. **Cewka 10 nH, $C_p$ = 0,1 pF:** SRF ≈ 5 GHz; użyteczna do ok. 1/3–1/2 SRF (dalej indukcyjność efektywna szybko rośnie).
3. **Dobroć cewki:** 10 nH przy 1 GHz to $X_L = 62{,}8\ \Omega$; przy $R = 1{,}5\ \Omega$ (z naskórkowością) $Q \approx 42$.

## Typowe pułapki

- **Dobór kondensatora sprzęgającego „jak w audio”** (duża pojemność) — przy GHz duży kondensator w dużej obudowie jest cewką.
- **Indukcyjność cewki z karty katalogowej odczytana przy niskiej częstotliwości** — w pobliżu SRF efektywna indukcyjność jest większa.
- **Długie ścieżki do masy** od kondensatora odsprzęgającego lub elementu filtru.
- **Kondensatory X7R w filtrach w.cz.**
- **Symulacja elementami idealnymi** — używaj modeli producentów (pliki S2P lub modele SPICE z ESL i ESR).

## Ćwiczenie komputerowe

Impedancja rzeczywistego kondensatora i cewki w funkcji częstotliwości:

```python
import numpy as np
import matplotlib.pyplot as plt

f = np.logspace(5, 10, 2000); w = 2*np.pi*f
def cap(C, ESL, ESR): return ESR + 1j*w*ESL + 1/(1j*w*C)
def ind(L, R, Cp): return 1/(1/(R + 1j*w*L) + 1j*w*Cp)

for C, ESL, lab in [(100e-9, 1e-9, '100 nF, 1 nH'), (10e-12, 0.5e-9, '10 pF, 0,5 nH')]:
    Z = cap(C, ESL, 0.05); plt.loglog(f, abs(Z), label=lab)
    print(f"{lab}: SRF = {1/(2*np.pi*np.sqrt(C*ESL))/1e6:.1f} MHz")
Zp = 1/(1/cap(100e-9, 1e-9, 0.05) + 1/cap(10e-12, 0.5e-9, 0.05))
plt.loglog(f, abs(Zp), 'k--', label='równolegle (antyrezonans)')
i = np.argmax(abs(Zp)*(f > 2e7)*(f < 2e9)); print(f"antyrezonans przy {f[i]/1e6:.0f} MHz, |Z| = {abs(Zp[i]):.1f} Ohm")
ZL = ind(10e-9, 1.5, 0.1e-12)
print(f"cewka 10 nH: SRF = {1/(2*np.pi*np.sqrt(10e-9*0.1e-12))/1e9:.2f} GHz, "
      f"L_eff(2 GHz) = {(ZL[np.argmin(abs(f - 2e9))].imag)/(2*np.pi*2e9)*1e9:.1f} nH")
plt.xlabel('f [Hz]'); plt.ylabel('|Z| [Ω]'); plt.legend(); plt.grid(which='both'); plt.show()
```

## Zadania

1. SRF kondensatora 1 nF w obudowie 0603 (ESL 0,7 nH).
2. Cewka 22 nH ma SRF 2,5 GHz. Jaka jest jej pojemność pasożytnicza? Do jakiej częstotliwości użyjesz jej w filtrze?
3. Obwód rezonansowy 100 MHz z cewką o $Q = 50$ obciążony tak, że $Q_L = 20$. Jakie pasmo −3 dB?
4. Rezystancja szeregowa 2 Ω przy $X = 100\ \Omega$. Jaka jest równoważna rezystancja równoległa?
5. Dlaczego kondensator odsprzęgający przy wzmacniaczu 2,4 GHz umieszcza się jak najbliżej pinu, z przelotką do masy przy samej padzie?

<details>
<summary>Odpowiedzi</summary>

1. ≈ 190 MHz
2. $C_p = 1/((2\pi f)^2L) \approx 0{,}18$ pF; z zapasem do ok. 0,8–1,2 GHz
3. 5 MHz
4. $Q = 50$, $R_p \approx Q^2R_s = 5$ kΩ
5. Każdy milimetr ścieżki i przelotki dodaje indukcyjność (ok. 1 nH to już ok. 15 Ω przy 2,4 GHz), która obniża SRF i zwiększa impedancję odsprzęgania
</details>

## Źródła

- [Fundamentals of Microwave and RF Design — M. Steer](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-microwave-and-rf-design) — elementy skupione na w.cz.
- [Lessons in Electric Circuits / All About Circuits Textbook](https://www.allaboutcircuits.com/textbook/) — rezonans, dobroć, elementy pasożytnicze
- [Analog Devices — Electronics I and II](https://wiki.analog.com/university/courses/electronics/text/electronics-toc) — elementy bierne i ich modele
- Modele producentów elementów (pliki S2P, modele SPICE kondensatorów i cewek) — do symulacji
