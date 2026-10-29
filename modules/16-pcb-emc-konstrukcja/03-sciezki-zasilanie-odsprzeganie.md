# 16.03 — Ścieżki, zasilanie i odsprzęganie

## Po co to jest

Ścieżka za wąska dla prądu się grzeje i powoduje spadki napięcia; sieć zasilania o zbyt dużej impedancji „faluje” przy każdym przełączeniu procesora. Zasilanie na płytce to system: ścieżki i płaszczyzny, kondensatory różnych wartości, przelotki i obudowy — projektuje się je tak, by impedancja widziana przez układy była mała w całym potrzebnym paśmie.

## Teoria w pigułce

### Szerokość ścieżki a prąd

Wzór empiryczny z IPC-2221 (stara norma, zachowawczy; nowsza IPC-2152 daje dokładniejsze wykresy):

$$I = k\cdot\Delta T^{0\text{,}44}\cdot A^{0\text{,}725}$$

$I$ [A], $\Delta T$ [K], $A$ — przekrój w mil² (1 mil = 25,4 µm), $k$ = 0,048 dla warstw zewnętrznych, 0,024 dla wewnętrznych (gorzej chłodzone).

| Prąd | Szerokość (35 µm, zewnętrzna, ΔT = 10 K) | Wewnętrzna |
|---|---|---|
| 0,5 A | ok. 0,12 mm | ok. 0,30 mm |
| 1 A | ok. 0,30 mm | ok. 0,78 mm |
| 2 A | ok. 0,78 mm | ok. 2,0 mm |
| 3 A | ok. 1,37 mm | ok. 3,6 mm |

Oprócz grzania liczy się **spadek napięcia**: $R = \rho l/(wt)$; miedź 35 µm ma ok. 0,5 mΩ na „kwadrat” — ścieżka 0,5 mm × 100 mm to ok. 98 mΩ (100 mV przy 1 A). Przy dużych prądach: polygony, kilka warstw równolegle, grubsza miedź (70 µm), wiele przelotek (jedna przelotka 0,3 mm przenosi typowo ok. 1 A — zależnie od długości i powlekania).

### Sieć zasilania (PDN)

**Impedancja docelowa:**

$$Z_{target} = \frac{\Delta U_{dop}}{\Delta I}$$

(np. 3,3 V ± 3% przy skoku 1 A → 0,1 Ω). Impedancja PDN musi być poniżej $Z_{target}$ od DC (stabilizator i jego pętla — [15.06](../15-energoelektronika-zasilanie/06-sterowanie-i-kompensacja.md)) przez kondensatory objętościowe (kHz–MHz) i ceramiczne (MHz–setki MHz) po pojemność międzypłaszczyznową i obudowy układów (setki MHz–GHz).

### Odsprzęganie

- Kondensator działa w pobliżu swojego rezonansu własnego ([12.01](../12-technika-wcz-rf/01-elementy-bierne-wcz.md)); **o skuteczności decyduje indukcyjność montażu** (pady, ścieżki, przelotki), nie wartość pojemności.
- Kondensator przy każdym pinie (lub parze pinów) zasilania, od strony układu; przelotki do masy i zasilania przy padach (najlepiej po bokach kondensatora, krótko).
- Kilka takich samych wartości (np. 100 nF i 1 µF w małej obudowie) zamiast „100 nF + 10 nF + 1 nF” — mniejsze ryzyko antyrezonansów; nowoczesne MLCC w małych obudowach mają niskie ESL.
- Kondensator objętościowy przy wejściu zasilania płytki i przy układach o dużym poborze impulsowym.
- Filtr (koralik ferrytowy + kondensator) dla zasilania analogowego i PLL — uwaga na rezonans LC filtra.

## Przykład rozwiązany

**Ścieżka zasilania 2 A** z przetwornicy do modułu (warstwa zewnętrzna, 35 µm, ΔT ≤ 10 K): ok. 0,8 mm; przy długości 40 mm opór $1\text{,}72\cdot 10^{-8}\cdot 0\text{,}04/(0\text{,}8\cdot 10^{-3}\cdot 35\cdot 10^{-6}) \approx 25$ mΩ → spadek 50 mV. Wniosek: dla 3,3 V ± 3% (± 100 mV) spadek jest znaczący — szersza ścieżka/polygon albo sprzężenie zwrotne przetwornicy z punktu odbioru (remote sense).

**Impedancja docelowa** mikrokontrolera: 3,3 V ± 3%, skok prądu 100 mA → $Z_{target} = 0\text{,}1/0\text{,}1 = 1\ \Omega$ — łatwe; procesora 1,0 V ± 3% przy skoku 10 A → 3 mΩ — wymaga dziesiątek kondensatorów i płaszczyzn.

## Typowe pułapki

- **Ścieżka zasilania doprowadzona do kondensatora, a od niego do pinu „przez pół płytki”.**
- **Jedna przelotka na prąd kilku amperów.**
- **Szerokość dobrana na prąd średni**, a prąd szczytowy lub zwarciowy wielokrotnie większy (bezpiecznik, ograniczenie prądu).
- **Koralik ferrytowy w zasilaniu bez analizy** — z kondensatorem tworzy rezonans, a przy prądzie stałym traci impedancję (nasycenie).
- **Pominięcie spadku na ścieżce masy** — masa też ma rezystancję.

## Ćwiczenie komputerowe

Kalkulator szerokości ścieżki (IPC-2221) i impedancja PDN z kilku kondensatorów:

```python
import numpy as np
import matplotlib.pyplot as plt

def trace_width_mm(I, dT=10, oz=1.0, external=True):
    k = 0.048 if external else 0.024
    A_mil2 = (I/(k*dT**0.44))**(1/0.725)
    return A_mil2/(1.378*oz)*0.0254
for I in [0.5, 1, 2, 3, 5]:
    print(f"{I:3.1f} A: zewn. {trace_width_mm(I):5.2f} mm, wewn. {trace_width_mm(I, external=False):5.2f} mm, "
          f"zewn. 70 µm {trace_width_mm(I, oz=2):5.2f} mm")
R = 1.72e-8*0.04/(0.8e-3*35e-6); print(f"ścieżka 0,8 mm x 40 mm: R = {R*1e3:.0f} mOhm")

f = np.logspace(4, 9, 2000); w = 2*np.pi*f
def Zc(C, ESL, ESR, n=1): return (ESR + 1j*w*ESL + 1/(1j*w*C))/n
Zvrm = 0.005 + 1j*w*50e-9                                   # stabilizator ~ mała R + indukcyjność pętli
Ytot = 1/Zvrm + 1/Zc(22e-6, 1.5e-9, 5e-3) + 1/Zc(1e-6, 0.5e-9, 10e-3, 4) + 1/Zc(100e-9, 0.4e-9, 20e-3, 8)
m = (f > 1e4) & (f < 2e8)
Zb = abs(1/(Ytot + 1/Zc(100e-6, 5e-9, 0.03)))                # + kondensator objętościowy 100 µF, ESR 30 mΩ
print(f"z kondensatorem objętościowym: maks. |Z| = {Zb[m].max()*1e3:.1f} mOhm")
Z = abs(1/Ytot)
print(f"maks. |Z| PDN w zakresie 10 kHz–200 MHz: {Z[(f > 1e4) & (f < 2e8)].max()*1e3:.1f} mOhm przy "
      f"{f[(f > 1e4) & (f < 2e8)][np.argmax(Z[(f > 1e4) & (f < 2e8)])]/1e6:.1f} MHz")
plt.loglog(f, Z); plt.axhline(0.1, color='r', ls='--', label='Z_target = 0,1 Ω')
plt.xlabel('f [Hz]'); plt.ylabel('|Z| [Ω]'); plt.legend(); plt.grid(which='both'); plt.show()
```

Bez kondensatora objętościowego impedancja ma szczyt ok. 0,22 Ω przy ok. 140 kHz — to antyrezonans indukcyjności pętli stabilizatora z kondensatorami ceramicznymi, ponad dwukrotnie powyżej $Z_{target}$. Kondensator objętościowy o umiarkowanym ESR (który tłumi rezonans) obniża maksimum do ok. 43 mΩ. Ten typ problemu łatwo przeoczyć, patrząc tylko na „ile kondensatorów 100 nF jest przy pinach”.

## Zadania

1. Jaka szerokość ścieżki zewnętrznej dla 3 A przy ΔT = 20 K (35 µm)? A przy miedzi 70 µm?
2. Ścieżka masy 0,3 mm × 50 mm przewodzi impulsy 0,5 A. Jaki spadek napięcia? Jak to wpływa na pomiar analogowy odniesiony do tej masy?
3. Impedancja docelowa dla szyny 1,8 V ± 2% przy skoku prądu 0,5 A?
4. Dlaczego dwa kondensatory 100 nF w obudowie 0402 mogą być lepsze niż jeden 100 nF + jeden 10 nF?
5. Ile przelotek (po ok. 1 A) zastosujesz do przeniesienia 4 A między warstwami? Dlaczego z zapasem?

<details>
<summary>Odpowiedzi</summary>

1. Ok. 0,9 mm; przy 70 µm ok. 0,45 mm
2. $R = 1\text{,}72\cdot 10^{-8}\cdot 0\text{,}05/(0\text{,}3\cdot 10^{-3}\cdot 35\cdot 10^{-6}) \approx 82$ mΩ → 41 mV impulsowo — przy przetworniku 12-bitowym 3,3 V to ok. 50 LSB błędu, jeśli masa analogowa dzieli tę ścieżkę
3. $0\text{,}036/0\text{,}5 = 72$ mΩ
4. Para różnych wartości tworzy antyrezonans (szczyt impedancji między ich częstotliwościami rezonansu); dwa jednakowe kondensatory obniżają impedancję (i ESL) o połowę bez antyrezonansu; w małej obudowie ESL obu jest podobne
5. Co najmniej 4–6 (np. 6): zapas na nierówny podział prądu, grzanie, niezawodność i niższą indukcyjność
</details>

## Źródła

- [Analog Devices MT-101 — Decoupling Techniques](https://www.analog.com/media/en/training-seminars/tutorials/MT-101.pdf) — odsprzęganie, elementy pasożytnicze, rozmieszczenie
- [LearnEMC](https://learnemc.com/) — odsprzęganie płytek i sieci zasilania
- [KiCad — dokumentacja](https://docs.kicad.org/) — kalkulator szerokości ścieżek (PCB Calculator)
- Normy IPC-2221 i IPC-2152 (płatne) — prąd w ścieżkach
