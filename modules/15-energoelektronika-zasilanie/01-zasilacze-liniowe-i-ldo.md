# 15.01 — Zasilacze liniowe i stabilizatory LDO

## Po co to jest

Zasilacz liniowy jest prosty, cichy i nie zakłóca — dlatego wciąż zasila tory audio, precyzyjne przetworniki i małe układy. Jego wadą jest sprawność: nadmiar napięcia zamienia się w ciepło. Umiejętność policzenia tętnień, strat i radiatora oraz rozumienie stabilności LDO pozwala świadomie wybrać, kiedy liniowo, a kiedy impulsowo.

## Teoria w pigułce

### Tor zasilacza liniowego

Transformator sieciowy → prostownik → kondensator filtrujący → stabilizator → kondensatory wyjściowe.

| Element | Zależności |
|---|---|
| Transformator | $U_{szczyt} = \sqrt2 U_{sk}$; napięcie zależy od obciążenia i tolerancji sieci (230 V ± 10%) |
| Prostownik | Mostek: dwa spadki diodowe (ok. 2 × 0,7–1 V); dwupołówkowy → tętnienia 100 Hz |
| Kondensator | Tętnienia $\Delta U \approx \dfrac{I}{2fC}$ (dwupołówkowy, $f = 50$ Hz) — [04.01](../04-uklady-analogowe/01-uklady-z-diodami.md) |
| Prąd diod i kondensatora | Impulsowy, wiele razy większy od prądu średniego (ładowanie w krótkim czasie przy szczycie) — prąd tętnień kondensatora i współczynnik mocy |
| Stabilizator | Minimalne napięcie wejściowe = $U_{wy} + U_{drop}$ musi być zachowane **w dolinie tętnień przy minimalnym napięciu sieci** |

### Bilans mocy i sprawność

$$P_{strat} = (U_{we} - U_{wy})I_{wy} + U_{we}I_q,\qquad \eta \approx \frac{U_{wy}}{U_{we}}$$

Temperatura złącza: $T_j = T_a + P\cdot(R_{th,jc} + R_{th,cs} + R_{th,sa})$ ([03.09](../03-przyrzady-polprzewodnikowe/09-datasheety-i-termika.md)).

### Stabilizatory LDO

| Typ | Napięcie minimalne $U_{drop}$ | Element regulacyjny |
|---|---|---|
| Klasyczny (78xx, LM317) | ok. 1,5–2,5 V | Darlington npn |
| **LDO** | ok. 0,05–0,5 V | pnp lub **PMOS** (wtórnik źródłowy odwrócony) |

Mały spadek wymaga elementu regulacyjnego pracującego jako „wspólny emiter/źródło” — wyjście ma dużą impedancję, a biegun wyjściowy zależy od kondensatora obciążenia. Skutki:
- **stabilność zależy od kondensatora wyjściowego** — producent podaje zakres pojemności i **ESR**; starsze LDO wymagały ESR w pewnym przedziale (zero od ESR kompensuje fazę), nowoczesne są stabilne z ceramicznymi kondensatorami o małym ESR;
- **PSRR** maleje z częstotliwością — LDO nie tłumi dobrze tętnień przetwornicy powyżej ok. 100 kHz–1 MHz;
- szum wyjściowy (µV rms) — ważny dla przetworników i torów RF; wyjście „NR/bypass” do filtrowania źródła odniesienia.

### LDO czy przetwornica

| Kryterium | LDO | Przetwornica |
|---|---|---|
| Sprawność | $\approx U_{wy}/U_{we}$ | 80–95% prawie niezależnie od różnicy napięć |
| Szum i zakłócenia | Bardzo małe | Tętnienia i EMI przy częstotliwości przełączania |
| Złożoność, koszt, miejsce | Minimalne | Dławik, więcej kondensatorów, staranny układ płytki |
| Prąd spoczynkowy | od < 1 µA | często większy, w trybach oszczędnych mały |
| Zastosowanie | Mała różnica napięć lub mały prąd, tory analogowe, post-regulacja za przetwornicą | Duża różnica napięć i prąd, baterie |

## Przykład rozwiązany

Zasilacz 5 V / 1 A z transformatora 12 V AC, mostka i kondensatora 4700 µF, stabilizator 7805.

1. Szczyt: $12\sqrt2 - 1\text{,}6 \approx 15\text{,}4$ V; tętnienia $1/(100\cdot 0\text{,}0047) \approx 2\text{,}1$ V → dolina ok. 13,2 V (zapas dla 7805 ok. 2 V — sprawdź przy sieci −10%: szczyt ok. 13,7 V, dolina ok. 11,6 V — jeszcze wystarcza).
2. Średnie napięcie wejściowe ok. 14,3 V → strata $(14\text{,}3 - 5)\cdot 1 \approx 9\text{,}3$ W, sprawność stabilizatora ok. 35%.
3. Radiator: $T_{j,max} = 125$ °C, $T_a = 40$ °C → $R_{th,całk} \leq 85/9\text{,}3 \approx 9\text{,}1$ K/W; obudowa TO-220 $R_{th,jc} \approx 5$ K/W, podkładka 0,5 K/W → radiator ≤ **3,6 K/W** (spory!). Wniosek: przy takiej różnicy napięć — przetwornica albo transformator o niższym napięciu.

**LDO 5 V → 3,3 V / 0,5 A:** strata 0,85 W, sprawność 66%; w obudowie SOT-223 ($R_{th,ja} \approx 60$ K/W przy dobrym polu miedzi) przyrost ok. 51 K — na granicy przy 50 °C otoczenia.

## Typowe pułapki

- **Projekt na nominalne napięcie sieci** — przy −10% stabilizator „wypada” z regulacji w dolinie tętnień.
- **Pominięcie prądu tętnień kondensatora** — przegrzanie i skrócenie życia elektrolitu.
- **LDO z kondensatorem spoza zakresu ESR z noty** — oscylacje.
- **Oczekiwanie, że LDO usunie tętnienia przetwornicy 1 MHz** — PSRR przy tej częstotliwości bywa kilka–kilkanaście dB.
- **Odwrotna polaryzacja i rozładowanie wyjścia do wejścia** (np. przy kondensatorze wyjściowym większym niż wejściowy) — dioda zabezpieczająca.

## Ćwiczenie komputerowe

Symulacja prostownika z kondensatorem: tętnienia, prąd szczytowy diod, dolina przy napięciu sieci −10%:

```python
import numpy as np

def rectifier(Urms, C, I_load, Vd=0.8, f=50, Rs=0.5, cycles=20, dt=2e-6):
    t = np.arange(0, cycles/f, dt); v = 0.0; out = np.empty_like(t); idiode = np.empty_like(t)
    for k, tk in enumerate(t):
        vs = abs(np.sqrt(2)*Urms*np.sin(2*np.pi*f*tk)) - 2*Vd
        i_d = max((vs - v)/Rs, 0.0)                     # mostek przewodzi, gdy napięcie źródła > kondensatora
        v += dt*(i_d - I_load)/C
        out[k], idiode[k] = v, i_d
    last = t > (cycles - 2)/f
    return out[last].max(), out[last].min(), idiode[last].max()

for Urms in [12, 12*0.9]:
    vmax, vmin, ipk = rectifier(Urms, 4700e-6, 1.0)
    print(f"U_sk = {Urms:5.2f} V: szczyt {vmax:.2f} V, dolina {vmin:.2f} V, tętnienia {vmax - vmin:.2f} V, "
          f"prąd szczytowy diod {ipk:.1f} A")
print(f"wzór: dU = I/(2fC) = {1/(2*50*4700e-6):.2f} V (górne oszacowanie — zakłada rozładowanie przez cały półokres)")
P = (14.3 - 5)*1.0
print(f"7805: P = {P:.1f} W, wymagany radiator <= {(125 - 40)/P - 5 - 0.5:.1f} K/W")
```

Rezystancja uzwojeń i diod (tu 0,5 Ω) obniża napięcie szczytowe o ponad 1,5 V przy impulsach prądu ok. 4–5 A — dlatego zmierzone napięcie zasilacza pod obciążeniem jest niższe niż z prostego wzoru, a tętnienia nieco mniejsze.

## Zadania

1. Zasilacz 12 V / 0,5 A z LM7812 (spadek minimalny 2 V). Jakie minimalne napięcie skuteczne transformatora przy tętnieniach 1,5 V, mostku (2 × 0,8 V) i sieci −10%?
2. Jaka pojemność daje tętnienia 1 V przy 2 A (prostownik dwupołówkowy, 50 Hz)?
3. LDO 3,3 V z 3,7 V (bateria Li-ion) przy 200 mA: strata i sprawność? Co się dzieje przy baterii rozładowanej do 3,4 V, jeśli $U_{drop}$ = 150 mV?
4. Dlaczego niektóre LDO wymagają kondensatora o ESR w określonym przedziale?
5. Stabilizator traci 2 W, $R_{th,jc}$ = 3 K/W, $T_{j,max}$ = 125 °C, $T_a$ = 60 °C. Jaki radiator?

<details>
<summary>Odpowiedzi</summary>

1. Dolina ≥ 14 V → szczyt ≥ 15,5 V → $U_{szczyt,tr} \geq 17\text{,}1$ V przy sieci −10% → nominalnie ≥ 19 V szczytowo → $U_{sk} \geq 13\text{,}4$ V (np. transformator 15 V)
2. $C = I/(2f\Delta U) = 2/(100\cdot 1) = 20$ mF
3. 80 mW, ok. 89%; przy 3,4 V: $3\text{,}4 - 0\text{,}15 = 3\text{,}25$ V < 3,3 V — wyjście spada poniżej nominalnego (praca w dropoucie)
4. Zero transmitancji pętli od ESR kondensatora kompensuje fazę bieguna wyjściowego; za małe ESR — brak kompensacji i oscylacje, za duże — biegun/zero w złym miejscu i słaba odpowiedź na skok obciążenia
5. $65/2 = 32\text{,}5$ K/W łącznie → radiator ≤ ok. 29 K/W (minus podkładka) — wystarczy mały radiator
</details>

## Źródła

- [Analog Devices — Electronics I and II](https://wiki.analog.com/university/courses/electronics/text/electronics-toc) — prostowniki, stabilizatory, zarządzanie zasilaniem
- [Operational Amplifiers & Linear ICs — J. M. Fiore](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html) — rozdział o regulacji napięcia
- [MIT 6.622 Power Electronics](https://ocw.mit.edu/courses/6-622-power-electronics-spring-2023/) — prostowniki i obciążenia nieliniowe sieci
- Noty aplikacyjne producentów LDO dotyczące stabilności i kondensatorów wyjściowych
