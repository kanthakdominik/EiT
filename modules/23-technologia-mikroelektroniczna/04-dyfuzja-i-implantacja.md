# 23.04 — Domieszkowanie: dyfuzja i implantacja

## Po co to jest

Złącza p-n, studnie, kanały i obszary źródła i drenu powstają przez wprowadzenie domieszek w ściśle określone miejsca i w ściśle określonej ilości. Od profilu domieszki zależą napięcie progowe tranzystora, rezystancja szeregowa, napięcie przebicia i pojemności. Dwie metody — **dyfuzja** z powierzchni i **implantacja jonów** — opisują proste wzory, które pozwalają policzyć głębokość złącza i dawkę.

## Teoria w pigułce

### Dyfuzja

Prawa Ficka: strumień $J = -D\,\dfrac{\partial N}{\partial x}$, równanie $\dfrac{\partial N}{\partial t} = D\dfrac{\partial^2N}{\partial x^2}$ ([02.06](../02-fizyka-i-materialy/06-transport-nosnikow.md)).

- **Współczynnik dyfuzji** rośnie wykładniczo z temperaturą: $D = D_0\,e^{-E_a/kT}$ (dla boru $D_0 \approx 0\text{,}76$ cm²/s, $E_a \approx 3\text{,}46$ eV). Zmiana temperatury o 100 K zmienia $D$ ok. 10–20 razy.
- **Długość dyfuzji** $\sqrt{Dt}$ — skala głębokości profilu.
- **Źródło stałe** (stała koncentracja powierzchniowa $N_s$, np. z fazy gazowej): $N(x, t) = N_s\,\mathrm{erfc}\!\left(\dfrac{x}{2\sqrt{Dt}}\right)$; dawka rośnie jak $Q = \dfrac{2N_s\sqrt{Dt}}{\sqrt\pi}$.
- **Źródło ograniczone** (stała dawka $Q$, np. po implantacji — wygrzewanie, *drive-in*): profil gaussowski $N(x, t) = \dfrac{Q}{\sqrt{\pi Dt}}\,e^{-x^2/4Dt}$.
- **Głębokość złącza** $x_j$ — gdzie $N(x_j) = N_B$ (domieszkowanie podłoża): dla źródła stałego $x_j = 2\sqrt{Dt}\,\mathrm{erfc}^{-1}(N_B/N_s)$.
- **Budżet termiczny:** wszystkie kolejne procesy wysokotemperaturowe poszerzają wcześniejsze profile — liczy się suma $\sum D_it_i$.

### Implantacja jonów

Jony domieszki przyspieszone napięciem 1–1000 kV wbijane w płytkę; maską jest fotorezyst lub tlenek.

- **Dawka** $Q$ [atomów/cm²] z ładunku: $Q = \dfrac{I_{wiązki}\,t}{q\,A}$ — precyzyjna kontrola (±1%).
- **Profil** w przybliżeniu gaussowski: zasięg rzutowany $R_p$ i rozrzut $\Delta R_p$ zależą od energii i masy jonu; $N_{max} = \dfrac{Q}{\sqrt{2\pi}\,\Delta R_p}$.
- **Uszkodzenia sieci** — konieczne **wygrzewanie** (RTA, szybkie wygrzewanie lampowe lub laserowe, ms–s), które aktywuje domieszki elektrycznie przy minimalnej dyfuzji.
- **Kanałowanie** — jony wnikają głębiej wzdłuż osi kryształu; płytkę pochyla się o ok. 7°.
- Zalety względem dyfuzji: dokładna dawka, niska temperatura, płytkie i dobrze określone profile, maskowanie rezystem. Implantacja jest dziś podstawową metodą.

### Pomiar

Rezystancja powierzchniowa metodą czteroostrzową ($R_\square = \rho/x_j$ dla warstwy), profil SIMS (spektrometria jonów wtórnych), profil nośników (SRP, ECV).

## Przykład rozwiązany

**Dyfuzja boru ze źródła stałego** w 1100 °C przez 1 h, $N_s = 10^{19}$ cm⁻³, podłoże n o $N_B = 10^{16}$ cm⁻³.

1. $kT = 8\text{,}617\cdot 10^{-5}\cdot 1373 = 0\text{,}1183$ eV; $D = 0\text{,}76\,e^{-3\text{,}46/0\text{,}1183} = 1\text{,}5\cdot 10^{-13}$ cm²/s.
2. $\sqrt{Dt} = \sqrt{1\text{,}5\cdot 10^{-13}\cdot 3600} = 2\text{,}34\cdot 10^{-5}$ cm $= 0\text{,}23$ µm.
3. $\mathrm{erfc}^{-1}(10^{-3}) = 2\text{,}33$ → $x_j = 2\cdot 0\text{,}23\cdot 2\text{,}33 \approx 1\text{,}09$ µm.

**Implantacja:** dawka $10^{15}$ cm⁻², $\Delta R_p = 30$ nm → $N_{max} = 10^{15}/(\sqrt{2\pi}\cdot 3\cdot 10^{-6}) = 1\text{,}33\cdot 10^{20}$ cm⁻³. Na płytce 300 mm (707 cm²) to ładunek $10^{15}\cdot 707\cdot 1\text{,}6\cdot 10^{-19} = 0\text{,}113$ C — przy prądzie wiązki 1 mA ok. 2 minuty.

## Typowe pułapki

- **Pomijanie budżetu termicznego** — złącze wykonane na początku procesu „rozpływa się” w każdym kolejnym kroku wysokotemperaturowym.
- **Liniowe skalowanie głębokości z czasem** — głębokość rośnie jak $\sqrt t$.
- **Zależność $D$ od koncentracji** — przy dużych koncentracjach (> koncentracji samoistnej w temperaturze procesu) dyfuzja przyspiesza; proste wzory erfc/Gauss przestają obowiązywać.
- **Brak wygrzewania po implantacji** — domieszka nieaktywna, sieć uszkodzona, duże upływy.
- **Przekroczenie rozpuszczalności granicznej** — nadmiar domieszki tworzy wytrącenia i nie jest aktywny.

## Ćwiczenie komputerowe

Profile erfc i gaussowski, głębokość złącza i wpływ budżetu termicznego:

```python
import numpy as np
from scipy.special import erfc, erfcinv

k = 8.617333e-5
D_boron = lambda T_C: 0.76*np.exp(-3.46/(k*(T_C + 273.15)))       # cm²/s

Ns, NB = 1e19, 1e16
for T_C, t_h in ((1000, 1), (1100, 1), (1100, 4)):
    D = D_boron(T_C); L = np.sqrt(D*t_h*3600)
    xj = 2*L*erfcinv(NB/Ns)
    Q = 2*Ns*L/np.sqrt(np.pi)
    print(f"{T_C} °C, {t_h} h: D = {D:.2e} cm²/s, sqrt(Dt) = {L*1e4:.3f} µm, x_j = {xj*1e4:.2f} µm, dawka {Q:.2e} cm⁻²")

# wygrzewanie po implantacji: profil gaussowski (dawka 1e13 cm⁻², start z płytkiego profilu) i złącze z podłożem 1e15
Q, NB2 = 1e13, 1e15
for T_C, t_h in ((1000, 0.5), (1100, 2)):
    Dt = D_boron(T_C)*t_h*3600
    xj = np.sqrt(4*Dt*np.log(Q/(NB2*np.sqrt(np.pi*Dt))))
    print(f"wygrzewanie {T_C} °C, {t_h} h: N(0) = {Q/np.sqrt(np.pi*Dt):.2e} cm⁻³, x_j = {xj*1e4:.2f} µm")

# implantacja: maksimum i ładunek
dose, dRp = 1e15, 30e-7
print(f"implantacja 1e15 cm⁻², ΔRp = 30 nm: N_max = {dose/(np.sqrt(2*np.pi)*dRp):.2e} cm⁻³, "
      f"czas dla płytki 300 mm przy 1 mA: {dose*np.pi*15**2*1.602e-19/1e-3:.0f} s")
```

## Zadania

1. Ile razy dłużej trzeba dyfundować, by podwoić głębokość złącza (przy tym samym $N_s/N_B$)?
2. Dawka implantacji $5\cdot 10^{12}$ cm⁻² na płytce 200 mm przy prądzie wiązki 10 µA. Ile trwa implantacja?
3. Dlaczego implantację prowadzi się z pochyleniem płytki?
4. Napięcie progowe MOSFET-a koryguje się implantacją kanału. Dlaczego implantacja nadaje się do tego lepiej niż dyfuzja?
5. Wartość $\sqrt{Dt}$ dla boru w 1100 °C przez 1 h to 0,23 µm. Ile wyniesie przy 1000 °C (współczynnik $D$ mniejszy ok. 10 razy)?

<details>
<summary>Odpowiedzi</summary>

1. 4 razy ($x_j \propto \sqrt t$)
2. Powierzchnia 314 cm²; ładunek $5\cdot 10^{12}\cdot 314\cdot 1\text{,}6\cdot 10^{-19} = 2\text{,}5\cdot 10^{-4}$ C; $t = 25$ s
3. Aby uniknąć kanałowania jonów wzdłuż osi krystalograficznych (głębsze, niekontrolowane wnikanie)
4. Dawka jest kontrolowana z dokładnością ok. 1% przez pomiar ładunku, profil jest płytki i zlokalizowany pod bramką, proces jest niskotemperaturowy (nie zmienia innych profili), maskowanie rezystem
5. $0\text{,}23/\sqrt{10} \approx 0\text{,}073$ µm
</details>

## Źródła

- [MIT 6.152J Micro/Nano Processing Technology](https://ocw.mit.edu/courses/6-152j-micro-nano-processing-technology-fall-2005/) — dyfuzja i implantacja
- [MIT 6.774 Physics of Microfabrication: Front End Processing](https://ocw.mit.edu/courses/6-774-physics-of-microfabrication-front-end-processing-fall-2004/) — dyfuzja zależna od koncentracji, wygrzewanie
- [02.06 Transport nośników](../02-fizyka-i-materialy/06-transport-nosnikow.md)
