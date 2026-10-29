# 22.05 — Wzmacniacz transimpedancyjny

## Po co to jest

Fotodioda daje prąd rzędu nA–µA, a przetwornik A/C i komparator potrzebują napięcia rzędu woltów. Wzmacniacz transimpedancyjny (TIA) zamienia prąd na napięcie, utrzymując fotodiodę przy stałym napięciu — dzięki temu jej pojemność „nie widzi” dużej rezystancji i pasmo jest wielokrotnie szersze niż z samym rezystorem obciążenia. To jednocześnie jeden z najbardziej podstępnych układów ze wzmacniaczem operacyjnym: duża pojemność na wejściu odwracającym łatwo wprowadza go w oscylacje.

## Teoria w pigułce

### Układ

Fotodioda między wejściem odwracającym a masą (lub napięciem polaryzacji), rezystor $R_f$ i kondensator $C_f$ w sprzężeniu zwrotnym. W paśmie: $U_{wy} = -I_{ph}R_f$ (transimpedancja $R_f$ [Ω = V/A]).

### Stabilność i pasmo

Pojemność wejściowa $C_t = C_j + C_{in}$ (fotodioda + wejście wzmacniacza + ścieżki) i $R_f$ tworzą biegun w pętli sprzężenia zwrotnego. **Wzmocnienie szumowe** (odwrotność współczynnika sprzężenia $\beta$):

$$\frac{1}{\beta} = 1 + \frac{Z_f}{Z_t} = 1 + \frac{R_f}{1 + sR_fC_f}\,sC_t$$

rośnie z częstotliwością od ok. $1/(2\pi R_fC_t)$ i przecina charakterystykę wzmocnienia wzmacniacza z nachyleniem 40 dB/dek — bez $C_f$ zapas fazy jest bliski zera ([04.06](../04-uklady-analogowe/06-sprzezenie-zwrotne-i-stabilnosc.md)).

- Pasmo bez $C_f$ (z dużym przewyższeniem): $f \approx \sqrt{\dfrac{GBW}{2\pi R_fC_t}}$.
- **Kompensacja** dla charakterystyki zbliżonej do Butterwortha (zapas fazy ok. 65°): $C_f \approx \sqrt{\dfrac{C_t}{2\pi R_f\,GBW}}$; pasmo wtedy $f_{-3\,\text{dB}} \approx \dfrac{1}{2\pi R_fC_f}$ (w praktyce nieco więcej).
- Większe $C_f$ — stabilniej, ale węższe pasmo: $f_{-3\,\text{dB}} = 1/(2\pi R_fC_f)$.
- Wymagany wzmacniacz: $GBW \geq \dfrac{C_t + C_f}{2\pi R_fC_f^2}$.

### Szum

| Źródło | Gęstość na wyjściu | Uwagi |
|---|---|---|
| Szum termiczny $R_f$ | $\sqrt{4kTR_f}$ | Względnie maleje z $R_f$: sygnał ∝ $R_f$, szum ∝ $\sqrt{R_f}$ |
| Szum prądowy wzmacniacza $i_n$ i śrutowy fotodiody | $i_n R_f$ | Wybierz wejście JFET/CMOS (fA/√Hz) |
| **Szum napięciowy $e_n$** × wzmocnienie szumowe | $e_n\,\lvert 1/\beta\rvert$ | Rośnie z częstotliwością jak $e_n\cdot 2\pi fR_fC_t$ — **dominuje w szerokim paśmie** |

Wniosek praktyczny: mała pojemność wejściowa (mała fotodioda, polaryzacja zaporowa, krótkie ścieżki, osłona) poprawia jednocześnie pasmo i szum.

### Dobór $R_f$

- Maksymalne napięcie wyjściowe / maksymalny fotoprąd (z zapasem na światło otoczenia).
- Jak największe dla szumu — w granicach pasma i zakresu.
- Duże $R_f$ (MΩ–GΩ): uwaga na pojemność pasożytniczą rezystora (0,1–0,2 pF dla obudowy 0603) — sama może być „kondensatorem $C_f$” ograniczającym pasmo; prądy upływu na płytce (pierścień ochronny).

## Przykład rozwiązany

**TIA:** $R_f = 100$ kΩ, fotodioda $C_j = 10$ pF, wejście wzmacniacza 3 pF ($C_t = 13$ pF), $GBW = 10$ MHz.

1. Bez kompensacji: $f \approx \sqrt{10^7/(2\pi\cdot 10^5\cdot 13\cdot 10^{-12})} = 1\text{,}1$ MHz, ale symulacja pokazuje przewyższenie ok. 19 dB — układ praktycznie na granicy oscylacji.
2. $C_f = \sqrt{13\cdot 10^{-12}/(2\pi\cdot 10^5\cdot 10^7)} = 1\text{,}44$ pF (najbliższe wartości 1,5 pF lub 1,2 pF + pojemność pasożytnicza rezystora).
3. Z $C_f = 1\text{,}44$ pF: przewyższenie ok. 1 dB, $f_{-3\,\text{dB}} \approx 1\text{,}3$ MHz.
4. Sygnał dla 1 µW przy 850 nm (0,55 A/W): 55 mV; szum na wyjściu ok. 78 µV RMS (przy $e_n = 5$ nV/√Hz) → SNR ok. 57 dB.
5. Gdyby potrzebne było pasmo 5 MHz: przy tym samym $R_f$ potrzebny wzmacniacz o $GBW$ ok. 200 MHz — albo mniejsze $R_f$ i drugi stopień wzmocnienia.

## Typowe pułapki

- **Brak $C_f$** „bo w symulacji idealnego wzmacniacza działało” — w rzeczywistości oscylacje.
- **Pominięcie pojemności wejściowej wzmacniacza i ścieżek** w obliczeniu $C_t$.
- **Wzmacniacz z wejściem bipolarnym** przy dużym $R_f$ — prąd polaryzacji i szum prądowy przewyższają fotoprąd.
- **Wzmacniacz niestabilny przy małym wzmocnieniu** (decompensated) bez analizy — wzmocnienie szumowe przy dużych częstotliwościach wynosi $1 + C_t/C_f$, nie $1$, co czasem pozwala użyć szybszych wzmacniaczy dekompensowanych.
- **Światło otoczenia** nasycające wyjście — sprzężenie AC po TIA nie pomaga, gdy TIA jest już nasycony; potrzebne odejmowanie prądu DC na wejściu (pętla serwo).

## Ćwiczenie komputerowe

Transimpedancja i szum wyjściowy TIA z modelem wzmacniacza jednobiegunowego dla kilku wartości $C_f$:

```python
import numpy as np

k, T = 1.380649e-23, 300
Rf, Cd, Cin, GBW = 100e3, 10e-12, 3e-12, 10e6     # rezystor, fotodioda, wejście wzmacniacza, iloczyn GBW
Ct = Cd + Cin
en, i_n = 5e-9, 5e-15                               # szum napięciowy i prądowy wzmacniacza (wejście FET)
f = np.logspace(2, 8, 60_001); s = 2j*np.pi*f

def tia(Cf):
    A = 2*np.pi*GBW/s                               # wzmacniacz jednobiegunowy (całkujący)
    Zf = Rf/(1 + s*Rf*Cf)
    Zi = 1/(s*Ct)
    beta = Zi/(Zi + Zf)                             # współczynnik sprzężenia zwrotnego
    Z = Zf*A*beta/(1 + A*beta)                      # transimpedancja (moduł)
    noise_gain = np.abs(1/beta)*np.abs(A*beta/(1 + A*beta))
    # gęstość szumu na wyjściu: e_n · wzmocnienie szumowe, prąd (i_n + szum Rf) · transimpedancja
    vout2 = (en*noise_gain)**2 + (i_n**2 + 4*k*T/Rf)*np.abs(Z)**2
    return np.abs(Z), np.sqrt(np.trapezoid(vout2, f))

print(f"f_-3dB (wzór) = {np.sqrt(GBW/(2*np.pi*Rf*Ct))/1e6:.2f} MHz, C_f (Butterworth) = {np.sqrt(Ct/(2*np.pi*Rf*GBW))*1e12:.2f} pF")
for Cf in (0, 0.5e-12, 1.44e-12, 3e-12):
    Z, vn = tia(Cf)
    m = Z/Rf
    f3 = f[np.argmax(m < 1/np.sqrt(2))]
    print(f"C_f = {Cf*1e12:4.2f} pF: przewyższenie {20*np.log10(m.max()):5.1f} dB, f_-3dB = {f3/1e6:5.2f} MHz, "
          f"szum wyjściowy (do 100 MHz) = {vn*1e6:6.1f} µV RMS")
print(f"sygnał dla 1 µW przy 0,55 A/W: {0.55e-6*Rf*1e3:.1f} mV")
```

Zauważ: kompensacja zmniejsza też szum — bez $C_f$ wzmocnienie szumowe ma ostre maksimum w pobliżu częstotliwości przecięcia i „zbiera” szum $e_n$.

Rozszerzenie: ten sam układ w LTspice (model wybranego wzmacniacza, np. JFET o GBW 10 MHz), analiza `.ac` z prądowym źródłem pobudzenia i `.noise`; porównaj z wynikami powyżej.

## Zadania

1. Maksymalny fotoprąd 20 µA, wyjście wzmacniacza do 4 V. Jaki największy $R_f$?
2. $R_f = 1$ MΩ, $C_t = 20$ pF, $GBW = 5$ MHz. Oblicz $C_f$ i pasmo.
3. Dlaczego polaryzacja zaporowa fotodiody (np. −5 V) zwiększa pasmo TIA?
4. Wzmocnienie szumowe przy wysokich częstotliwościach wynosi $1 + C_t/C_f$. Ile to dla przykładu z tekstu i co to oznacza dla szumu $e_n$?
5. Jak zmierzysz transimpedancję i pasmo TIA bez modulowanego źródła światła?

<details>
<summary>Odpowiedzi</summary>

1. $4/20\cdot 10^{-6} = 200$ kΩ (np. 180 kΩ z zapasem)
2. $C_f = \sqrt{20\cdot 10^{-12}/(2\pi\cdot 10^6\cdot 5\cdot 10^6)} = 0\text{,}80$ pF; $f \approx 1/(2\pi\cdot 10^6\cdot 0\text{,}8\cdot 10^{-12}) \approx 200$ kHz
3. Pojemność złącza maleje ze wzrostem napięcia wstecznego (szersza warstwa zubożona) — mniejsze $C_t$ daje większe pasmo i mniejszy szum $e_n$ w paśmie
4. $1 + 13/1\text{,}44 \approx 10$ — szum napięciowy wzmacniacza jest wzmacniany 10 razy w górnej części pasma (ok. 50 nV/√Hz na wyjściu przy $e_n = 5$ nV/√Hz), więcej niż szum termiczny $R_f$ (40 nV/√Hz)
5. Generator napięcia przez duży rezystor (np. 1 MΩ, małej pojemności) do wejścia — źródło prądowe $U/R$; uwaga na pojemność pasożytniczą tego rezystora. Alternatywnie dioda LED zasilana z generatora (pomiar względny pasma)
</details>

## Źródła

- [Texas Instruments — Transimpedance Considerations for High-Speed Amplifiers (SBOA122)](https://www.ti.com/lit/sboa122)
- [Texas Instruments — Precision Labs: Op Amps](https://www.ti.com/video/series/precision-labs/ti-precision-labs-op-amps.html) — stabilność i szum
- [Hamamatsu — Si photodiodes: technical information (PDF)](https://www.hamamatsu.com/resources/pdf/ssd/si_pd_kspd0001e.pdf) — układy z fotodiodami
- J. Graeme — *Photodiode Amplifiers: Op Amp Solutions* (płatna)
