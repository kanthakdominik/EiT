# 04.03 — Wzmacniacze jednotranzystorowe i ich pasmo

## Po co to jest

Trzy podstawowe konfiguracje (wspólny emiter/źródło, wspólny kolektor/dren, wspólna baza/bramka) to „klocki”, z których zbudowane są wszystkie wzmacniacze, także wnętrza wzmacniaczy operacyjnych. Każda ma inne wzmocnienie i impedancje — wybór zależy od tego, co jest przed i za stopniem.

## Teoria w pigułce

### Procedura analizy

1. Analiza DC → punkt pracy ([04.02](02-polaryzacja-tranzystorow.md)).
2. Parametry małosygnałowe: $g_m$, $r_\pi$, $r_e$, $r_o$ ([03.05](../03-przyrzady-polprzewodnikowe/05-bjt-model-malosygnalowy.md)).
3. Schemat AC: źródła stałe → masa, duże kondensatory → zwarcie.
4. Wzmocnienie, $R_{we}$, $R_{wy}$.

### Porównanie konfiguracji (BJT; $r_o$ pominięte, $R_L'$ — obciążenie z $R_C$ lub $R_E$)

| Konfiguracja | Wzmocnienie napięciowe | $R_{we}$ (bez dzielnika) | $R_{wy}$ | Faza | Zastosowanie |
|---|---|---|---|---|---|
| **WE** (wspólny emiter) | $-g_mR_C'$ | $r_\pi$ | $R_C$ | odwraca | Główne wzmocnienie |
| WE z $R_E$ | $\approx -\dfrac{R_C'}{r_e + R_E}$ | $r_\pi + (\beta + 1)R_E$ | $R_C$ | odwraca | Stabilne, liniowe wzmocnienie |
| **WC** (wtórnik emiterowy) | $\approx\dfrac{R_E'}{r_e + R_E'} \approx 1$ | $r_\pi + (\beta + 1)R_E'$ | $r_e + \dfrac{R_s}{\beta + 1}$ | nie odwraca | Bufor, mała $R_{wy}$ |
| **WB** (wspólna baza) | $+g_mR_C'$ | $\approx r_e$ | $R_C$ | nie odwraca | Wysokie częstotliwości, kaskoda |

Dla MOSFET-a: WS — $-g_mR_D'$; WD (wtórnik źródłowy) — $\dfrac{g_mR_S'}{1 + g_mR_S'}$, $R_{wy} \approx 1/g_m$; WG — $+g_mR_D'$, $R_{we} \approx 1/g_m$. Rezystancja wejściowa od strony bramki jest nieskończona.

### Pasmo — dolna częstotliwość graniczna

Kondensatory sprzęgające i blokujące tworzą filtry górnoprzepustowe. Dla każdego: $f = \dfrac{1}{2\pi R_{zast}C}$, gdzie $R_{zast}$ to rezystancja widziana z zacisków kondensatora. Kondensator blokujący emiter „widzi” bardzo małą rezystancję ($\approx r_e$), więc zwykle on decyduje o dolnej granicy pasma.

### Pasmo — górna częstotliwość graniczna i efekt Millera

Pojemność $C_\mu$ między wejściem a wyjściem stopnia odwracającego o wzmocnieniu $-K$ widziana od strony wejścia jest powiększona:

$$C_M = C_\mu(1 + K)$$

Ta pojemność z rezystancją źródła sygnału tworzy biegun, który zwykle ogranicza pasmo stopnia WE. Wtórnik i stopień WB nie mają efektu Millera — dlatego **kaskoda** (WE + WB) ma szerokie pasmo.

## Przykład rozwiązany

Wzmacniacz WE z [04.02](02-polaryzacja-tranzystorow.md): $I_C = 1\text{,}29$ mA, $\beta = 100$, $R_C = 4\text{,}7$ kΩ, $R_E$ zablokowany 100 µF, kondensator wejściowy 10 µF, źródło sygnału $R_s = 1$ kΩ, $C_\pi = 20$ pF, $C_\mu = 2$ pF.

1. $g_m \approx 49\text{,}8$ mS, $r_\pi \approx 2\text{,}01$ kΩ, $r_e \approx 19\text{,}9\ \Omega$.
2. $K_u = -g_mR_C \approx -234$.
3. $R_{we} = R_{th}\parallel r_\pi = 8\text{,}25\ \text{k}\parallel 2\text{,}01\ \text{k} \approx 1\text{,}62$ kΩ; $R_{wy} = 4\text{,}7$ kΩ.
4. Kondensator wejściowy: $f_1 = \dfrac{1}{2\pi(1\ \text{k} + 1\text{,}62\ \text{k})\cdot 10\ \mu\text{F}} \approx 6$ Hz.
5. Kondensator emiterowy „widzi” $R_E\parallel\left(r_e + \dfrac{R_s\parallel R_{th}}{\beta + 1}\right) \approx 27\text{,}9\ \Omega$ → $f_2 \approx 57$ Hz. **To on wyznacza dolną granicę pasma.**
6. Górna granica: $C_M = 2\ \text{pF}\cdot 235 \approx 470$ pF; z $C_\pi$ razem ok. 490 pF; rezystancja widziana $R_s\parallel R_{we} \approx 618\ \Omega$ → $f_H \approx 526$ kHz.

Bez zablokowania $R_E$: $K_u \approx -\dfrac{4\text{,}7\ \text{k}}{19\text{,}9 + 1000} \approx -4\text{,}6$ — wzmocnienie 50 razy mniejsze, ale niezależne od $\beta$ i temperatury, mniejsze zniekształcenia, a efekt Millera prawie znika.

## Typowe pułapki

- **Wzmocnienie WE bez uwzględnienia obciążenia** — następny stopień jest równoległy do $R_C$.
- **Wzmocnienie liczone od źródła, a nie od bazy** — trzeba uwzględnić dzielnik $R_s$ i $R_{we}$.
- **Pominięcie kondensatora emiterowego** przy szacowaniu dolnej granicy pasma.
- **Duża amplituda wejściowa** — wzmacniacz WE bez $R_E$ jest liniowy tylko dla $u_{be} \ll U_T$ (kilka mV).

## Symulacja

```spice
* 04.03 wzmacniacz WE - wzmocnienie i pasmo
VCC vcc 0 12
VS s 0 SINE(0 5m 1k) AC 1
RS s x 1k
C1 x b 10u
R1 vcc b 47k
R2 b 0 10k
RC vcc c 4.7k
RE e 0 1k
CE e 0 100u
Q1 c b e QN
.model QN NPN(Bf=100 Is=1e-14 Vaf=100 Cje=20p Cjc=2p)
.ac dec 50 1 100Meg
.end
```

Odczytaj wzmocnienie w paśmie i obie częstotliwości graniczne. Zmień `.ac` na `.tran 0 5m` i zwiększaj amplitudę źródła (5 mV, 20 mV, 50 mV) — przy której wyjście jest wyraźnie zniekształcone? Usuń `CE` i powtórz.

## Zadania

1. Wyznacz wzmocnienie, $R_{we}$ i $R_{wy}$ wzmacniacza z przykładu (z zablokowanym $R_E$).
2. Ten sam układ bez kondensatora $C_E$: wzmocnienie i $R_{we}$.
3. Ten sam tranzystor i polaryzacja jako wtórnik emiterowy (wyjście z emitera, $R_C = 0$, $R_s = 1$ kΩ). Wyznacz wzmocnienie, $R_{we}$ i $R_{wy}$.
4. Wzmacniacz WS: $g_m = 2$ mS, $R_D = 5$ kΩ, $R_S = 1$ kΩ. Wzmocnienie z zablokowanym i niezablokowanym $R_S$.
5. Stopień WE ma wzmocnienie −100 i $C_\mu = 3$ pF. Jaka jest pojemność Millera? Jaka będzie górna częstotliwość graniczna przy rezystancji źródła 10 kΩ (pomiń inne pojemności)?
6. Dlaczego kaskoda ma szersze pasmo niż sam stopień WE?

<details>
<summary>Odpowiedzi</summary>

1. ≈ −234; ≈ 1,62 kΩ; 4,7 kΩ
2. ≈ −4,6; $R_{th}\parallel(r_\pi + 101\ \text{k}) \approx 7\text{,}6$ kΩ
3. $K_u \approx 1000/(19\text{,}9 + 1000) \approx 0\text{,}98$; $R_{we} \approx 7\text{,}6$ kΩ; $R_{wy} \approx 19\text{,}9 + 892/101 \approx 29\ \Omega$ (równolegle z $R_E$: ≈ 28 Ω)
4. −10 i $-\dfrac{10}{1 + 2} \approx -3\text{,}3$
5. $C_M = 3\cdot 101 = 303$ pF; $f_H = \dfrac{1}{2\pi\cdot 10^4\cdot 303\cdot 10^{-12}} \approx 52$ kHz
6. W kaskodzie stopień WE jest obciążony małą rezystancją wejściową stopnia WB ($\approx r_e$), więc jego wzmocnienie napięciowe wynosi ok. −1 i efekt Millera praktycznie znika, a całe wzmocnienie daje stopień WB, który nie ma sprzężenia pojemnościowego wyjście–wejście
</details>

## Źródła

- [Semiconductor Devices — J. M. Fiore, rozdziały o wzmacniaczach BJT i FET](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html)
- [MIT 6.012 Microelectronic Devices and Circuits](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-spring-2009/) — wzmacniacze jednotranzystorowe, odpowiedź częstotliwościowa, efekt Millera
- [MIT 6.002 Circuits and Electronics](https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/) — wzmacniacze, model małosygnałowy
- [Analog Devices — Electronics I and II](https://wiki.analog.com/university/courses/electronics/text/electronics-toc)
