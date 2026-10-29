# M03.05 — Niedopasowanie, szum i layout analogowy

## Po co to jest

Dwa „identyczne” tranzystory obok siebie różnią się napięciem progowym o kilka miliwoltów — to offset wzmacniacza, błąd luster, nieliniowość przetwornika. Szum termiczny i $1/f$ tranzystorów wyznacza najmniejszy sygnał, który układ przetworzy. Oba efekty zależą od **powierzchni** tranzystorów, a więc od kosztu i szybkości, i oba silnie zależą od **layoutu**. W układzie scalonym dokładność bierze się nie z precyzyjnych elementów, ale z dopasowania — i to dopasowanie projektuje się geometrią.

## Teoria w pigułce

### Niedopasowanie (prawo Pelgroma)

$$\sigma(\Delta U_T) = \frac{A_{VT}}{\sqrt{WL}}, \qquad \frac{\sigma(\Delta\beta)}{\beta} = \frac{A_\beta}{\sqrt{WL}}$$

- $A_{VT}$ — kilka mV·µm (rośnie z grubością tlenku; podany w dokumentacji PDK), $A_\beta$ ok. 1%·µm.
- Offset pary różnicowej: $\sigma_{U_{os}}^2 \approx \sigma^2(\Delta U_T) + \left(\dfrac{\sigma(\Delta\beta)/\beta}{g_m/I_D}\right)^2$ plus wkład lustra obciążenia (pomnożony przez $g_{m3}/g_{m1}$).
- **Czterokrotna powierzchnia = dwukrotnie mniejszy offset** — kosztem pojemności i prądu.
- Dla luster prądowych względny błąd prądu: $\dfrac{\sigma(\Delta I)}{I} \approx \left(\dfrac{g_m}{I_D}\right)\sigma(\Delta U_T)$ — lepiej w silnej inwersji.
- Gradienty (temperatura, naprężenia, grubość tlenku na płytce) dają niedopasowanie systematyczne, zależne od odległości — usuwa je geometria (centroid).

### Szum

- **Termiczny w kanale:** $\overline{i_n^2} = 4kT\gamma g_m$ ($\gamma \approx 2/3$ w silnej inwersji, ok. 1/2·n w słabej; więcej dla krótkich kanałów); na wejściu $\overline{e_n^2} = 4kT\gamma/g_m$ — **mniejszy szum wymaga większego $g_m$**, czyli prądu.
- **$1/f$:** $\overline{e_n^2}(f) = \dfrac{K_F}{C_{ox}WLf}$ — zależy od **powierzchni bramki**; PMOS zwykle ma mniejszy $K_F$ niż NMOS.
- Szum układu przeliczony na wejście: stopień wejściowy dominuje (jak współczynnik szumów Friisa — [12.04](../../modules/12-technika-wcz-rf/04-szumy.md)); obciążenia aktywne dokładają szum proporcjonalny do $g_{m,obc}/g_{m,we}$.
- **$kT/C$** w układach próbkujących ([21.04](../../modules/21-procesy-losowe-szum/04-procesy-w-ukladach-liniowych.md)).
- Techniki: chopper i autozerowanie (szum $1/f$ i offset), korelowane podwójne próbkowanie.

### Layout analogowy

| Technika | Cel |
|---|---|
| **Wspólny centroid** (ABBA, krzyżowe czwórki) | Usunięcie gradientów liniowych z niedopasowania par |
| **Przeplatanie** (interdigitation) palców tranzystorów | Jak wyżej, dla luster o wielu wyjściach |
| **Elementy fikcyjne** (dummy) na brzegach | Jednakowe otoczenie trawienia i naprężeń |
| Ta sama orientacja tranzystorów dopasowanych | Anizotropia (implantacja pod kątem, naprężenia) |
| Odległość od krawędzi studni (WPE) i izolacji (LOD) | Uniknięcie zmian $U_T$ |
| **Pierścienie ochronne** (guard rings), kontakty do podłoża | Izolacja szumu z części cyfrowej, latch-up |
| Symetryczne trasowanie sygnałów różnicowych | Równe pasożyty, odporność na zakłócenia wspólne |
| Oddzielne zasilania i masy analogowe/cyfrowe | Mniej sprzężeń przez podłoże i szyny |

## Przykład rozwiązany

**Offset pary wejściowej** ($A_{VT} = 5$ mV·µm, $A_\beta = 1\%$·µm, $g_m/I_D = 15$ S/A):

| Wymiary W/L | WL | σ(ΔU_T) | 3σ offsetu |
|---|---|---|---|
| 2/0,5 µm | 1 µm² | 5,0 mV | 15 mV |
| 10/1 µm | 10 µm² | 1,6 mV | 4,8 mV |
| 40/2 µm | 80 µm² | 0,56 mV | 1,7 mV |

Wkład niedopasowania $\beta$ jest tu ok. 7 razy mniejszy od wkładu $U_T$. Dla offsetu 3σ < 2 mV potrzeba ok. 60 µm² na tranzystor — i to bez lustra obciążenia, które dokłada swój udział.

**Szum termiczny:** para z $g_m = 1$ mS (dwa tranzystory wejściowe) — ok. 4,7 nV/√Hz; przy 100 µS — 15 nV/√Hz. Szum $1/f$ przy 1 Hz dla $K_F = 10^{-25}$ V²F: 1,1 µV/√Hz dla 10 µm², 112 nV/√Hz dla 1000 µm².

## Typowe pułapki

- **Minimalne tranzystory w parze wejściowej** — offset dziesiątek mV.
- **Dopasowane tranzystory daleko od siebie lub w różnych orientacjach.**
- **Monte Carlo tylko z niedopasowaniem lokalnym** albo tylko z globalnym — trzeba obu (rozrzut procesu i niedopasowanie).
- **Szum liczony tylko dla pary wejściowej** — lustro obciążenia i źródło prądu ogona też szumią.
- **Trasowanie linii zegara cyfrowego nad lub obok wejść analogowych.**

## Ćwiczenie komputerowe

Prawo Pelgroma (wzór i Monte Carlo), szum termiczny i $1/f$ tranzystorów wejściowych:

```python
import numpy as np

rng = np.random.default_rng(0)
A_VT, A_beta = 5e-3, 0.01                 # Pelgrom: 5 mV·µm, 1 %·µm (przykładowe; z dokumentacji PDK)
gm_id = 15.0                               # S/A — wpływ niedopasowania β na offset: Δβ/β / (gm/ID)
for W, L in ((2, 0.5), (10, 1), (40, 2)):
    area = W*L
    s_vt = A_VT/np.sqrt(area); s_b = A_beta/np.sqrt(area)
    s_off = np.sqrt(s_vt**2 + (s_b/gm_id)**2)        # offset pary różnicowej (σ różnicy dwóch tranzystorów)
    # Monte Carlo pary: każdy tranzystor ma VT ~ N(0, A_VT/√(2WL))
    vt = rng.normal(0, A_VT/np.sqrt(2*area), (200_000, 2))
    print(f"W/L = {W}/{L} µm (WL = {area:4.0f} µm²): σ(ΔVT) = {s_vt*1e3:.2f} mV (MC {np.std(vt[:, 0] - vt[:, 1])*1e3:.2f} mV), "
          f"σ offsetu z β = {s_b/gm_id*1e3:.2f} mV, łącznie {s_off*1e3:.2f} mV; 3σ = {3*s_off*1e3:.1f} mV")

# szum termiczny pary różnicowej i wymagana transkonduktancja
k, T, gamma = 1.380649e-23, 300, 2/3
for gm in (100e-6, 1e-3):
    en = np.sqrt(2*4*k*T*gamma/gm)         # dwa tranzystory wejściowe (pomijając lustro)
    print(f"gm = {gm*1e3:.1f} mS: szum wejściowy pary ≈ {en*1e9:.1f} nV/√Hz")
# 1/f: KF/(Cox·W·L·f)
Cox, KF = 8e-3, 1e-25                       # F/m², V²·F (przykładowe)
for area_um2 in (10, 100, 1000):
    e1f = np.sqrt(KF/(Cox*area_um2*1e-12*1.0))
    print(f"WL = {area_um2:5d} µm²: szum 1/f przy 1 Hz ≈ {e1f*1e9:.0f} nV/√Hz")
```

Ćwiczenie z PDK: narysuj w Magic lub KLayout parę różnicową w układzie wspólnego centroidu (ABBA) z elementami fikcyjnymi i pierścieniem ochronnym; porównaj symulację po ekstrakcji z wersją bez centroidu przy dodanym gradiencie $U_T$.

## Zadania

1. Wymagany offset 3σ ≤ 3 mV przy $A_{VT} = 4$ mV·µm. Jaka minimalna powierzchnia każdego tranzystora pary?
2. Lustro prądowe pracuje przy $g_m/I_D = 20$ S/A, $\sigma(\Delta U_T) = 2$ mV. Ile wynosi względny rozrzut prądu? A przy 8 S/A?
3. Dlaczego układ wspólnego centroidu usuwa wpływ liniowego gradientu?
4. Szum 1/f wzmacniacza jest za duży. Jakie dwie zmiany w projekcie pomogą?
5. Dlaczego zwiększenie $g_m$ zmniejsza szum termiczny, a nie zmniejsza szumu 1/f?

<details>
<summary>Odpowiedzi</summary>

1. $\sigma \leq 1$ mV → $\sqrt{WL} \geq 4$ → $WL \geq 16$ µm²
2. $20\cdot 2\ \text{mV} = 4\%$; przy 8 S/A — 1,6%
3. Przy liniowej zmianie parametru w przestrzeni tranzystory rozmieszczone symetrycznie względem wspólnego środka (np. A-B-B-A) mają ten sam średni parametr — gradient wpływa na oba jednakowo
4. Zwiększyć powierzchnię bramki tranzystorów wejściowych (szum $\propto 1/\sqrt{WL}$), użyć PMOS na wejściu (zwykle mniejszy $K_F$), ograniczyć wkład lustra (mniejsze $g_{m3}/g_{m1}$, długie tranzystory lustra), ewentualnie chopper
5. Szum termiczny przeliczony na bramkę to $4kT\gamma/g_m$ — maleje z $g_m$; szum $1/f$ napięciowy na bramce zależy od pułapek w tlenku i powierzchni bramki, nie od prądu
</details>

## Źródła

- [IIC-OSIC-TOOLS (GitHub)](https://github.com/iic-jku/IIC-OSIC-TOOLS) — narzędzia do layoutu i Monte Carlo
- [IHP Open PDK (GitHub)](https://github.com/IHP-GmbH/IHP-Open-PDK) — parametry niedopasowania w dokumentacji procesu
- B. Razavi — *Design of Analog CMOS Integrated Circuits* (płatna) — rozdziały o szumie i layoucie
- [21.06 Szum w układach elektronicznych](../../modules/21-procesy-losowe-szum/06-szum-w-ukladach-elektronicznych.md)
