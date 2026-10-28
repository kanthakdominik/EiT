# 03.07 — MOSFET: model małosygnałowy i praca jako klucz

## Po co to jest

MOSFET pracuje w dwóch zupełnie różnych rolach: jako **wzmacniacz** (w zakresie nasycenia, opis modelem małosygnałowym) i jako **klucz** (odcięcie ↔ zakres liniowy, opis rezystancją $R_{DS(on)}$ i ładunkiem bramki). W przetwornicach i sterownikach liczą się głównie straty przełączania.

## Teoria w pigułce

### Model małosygnałowy (zakres nasycenia)

| Parametr | Wzór |
|---|---|
| Transkonduktancja | $g_m = kU_{ov} = \sqrt{2kI_D} = \dfrac{2I_D}{U_{ov}}$ |
| Rezystancja wyjściowa | $r_o = \dfrac{1}{\lambda I_D}$ |
| Rezystancja wejściowa | nieskończona (bramka izolowana) |

Porównanie z BJT przy tym samym prądzie: $g_{m,MOS} = \dfrac{2I_D}{U_{ov}}$, $g_{m,BJT} = \dfrac{I_C}{U_T}$. Ponieważ typowo $U_{ov} \approx 0{,}2$–1 V $\gg 2U_T$, **BJT ma większe $g_m$ przy tym samym prądzie**. MOSFET wygrywa nieskończoną rezystancją wejściową.

Pojemności: $C_{gs}$, $C_{gd}$ (efekt Millera — [04.03](../04-uklady-analogowe/03-wzmacniacze-jednotranzystorowe.md)).

### MOSFET jako klucz

**Straty przewodzenia:** $P_{cond} = I_D^2R_{DS(on)}$ (z uwzględnieniem wzrostu $R_{DS(on)}$ z temperaturą — typowo +50–80% przy 100 °C).

**Ładunek bramki** $Q_g$ (z dokumentacji): czas przełączenia przy prądzie sterownika $I_G$: $t \approx Q_g/I_G$. Na charakterystyce ładowania bramki widać **plateau Millera** — w tym czasie zmienia się napięcie drenu i powstają straty.

**Straty przełączania** (przybliżenie dla obciążenia indukcyjnego/rezystancyjnego):

$$P_{sw} \approx \tfrac12 U_{DS}I_D(t_r + t_f)f_{sw}$$

**Moc sterowania bramką:** $P_G = Q_gU_{GS}f_{sw}$ (pobierana z zasilania drivera).

### Konfiguracje kluczy

- **Low-side (nMOS po stronie masy)** — najprostszy: bramka sterowana względem masy.
- **High-side** — pMOS (prosty, ale gorsze parametry) albo nMOS z driverem z pompą ładunku / bootstrapem (bramka musi być powyżej napięcia zasilania).
- **Rezystor bramkowy** (kilka–kilkadziesiąt Ω) tłumi oscylacje i ogranicza szybkość zboczy; **rezystor bramka–źródło** (10–100 kΩ) trzyma tranzystor wyłączony, gdy sterowanie nie działa.

## Przykład rozwiązany

Klucz low-side w przetwornicy: 12 V, 5 A, $f_{sw} = 100$ kHz, $R_{DS(on)} = 20$ mΩ, $Q_g = 30$ nC, $t_r + t_f = 100$ ns, $U_{GS} = 10$ V, wypełnienie 50%.

1. Przewodzenie: $5^2\cdot 0{,}02\cdot 0{,}5 = 0{,}25$ W (przy 50% czasu włączenia).
2. Przełączanie: $\tfrac12\cdot 12\cdot 5\cdot 100\cdot 10^{-9}\cdot 10^5 = 0{,}3$ W.
3. Sterowanie bramką: $30\cdot 10^{-9}\cdot 10\cdot 10^5 = 30$ mW.
4. Driver o prądzie 1 A przełączy bramkę w ok. 30 ns; wyjście mikrokontrolera (10 mA) — w ok. 3 µs, co zwiększyłoby straty przełączania kilkudziesięciokrotnie.

## Typowe pułapki

- **Sterowanie dużego MOSFET-a bezpośrednio z pinu mikrokontrolera przy wysokiej częstotliwości** — zbyt wolne zbocza, duże straty, przegrzanie.
- **$R_{DS(on)}$ z temperatury 25 °C** użyte do obliczeń cieplnych.
- **Brak rezystora bramka–źródło** — tranzystor włącza się przy odłączonym sterowaniu.
- **Indukcyjność obciążenia bez ścieżki dla prądu** przy wyłączeniu — przepięcie przekracza $U_{DS,max}$ (dioda gasząca, snubber lub tranzystor z oceną lawinową).

## Symulacja

```spice
* 03.07 klucz MOSFET z obciazeniem indukcyjnym i dioda gaszaca
V1 vcc 0 12
VG g0 0 PULSE(0 10 0 20n 20n 4.98u 10u)
RG g0 g 10
L1 vcc d 100u
R1 d 0 1meg
D1 d vcc DS
M1 d g 0 0 PWRNMOS
.model DS D(Is=1u Rs=0.01 Cjo=100p)
.model PWRNMOS VDMOS(Rg=3 Vto=4 Rd=20m Rs=5m Rb=10m Kp=25 Cgdmax=2n Cgdmin=50p Cgs=1.8n Cjo=900p Is=40p)
.tran 0 100u
.end
```

Obejrzyj `V(g)` — znajdź plateau Millera. Oblicz moc chwilową tranzystora (Alt + klik na M1) i jej wartość średnią. Usuń diodę D1 i zobacz, co dzieje się z napięciem drenu.

## Zadania

1. $k = 2$ mA/V², $I_D = 1$ mA. Wyznacz $g_m$ i $U_{ov}$. Porównaj z $g_m$ tranzystora bipolarnego przy 1 mA.
2. $\lambda = 0{,}02$ V⁻¹, $I_D = 1$ mA. Ile wynosi $r_o$ i wzmocnienie wewnętrzne $g_mr_o$?
3. Tranzystor przewodzi stale 5 A, $R_{DS(on)} = 20$ mΩ w 25 °C, w temperaturze pracy o 60% więcej. Jakie są straty?
4. MOSFET z $Q_g = 30$ nC ma być przełączany w 50 ns. Jaki prąd musi dać driver? Jaka moc sterowania przy 10 V i 200 kHz?
5. Oszacuj straty przełączania: 48 V, 10 A, $t_r + t_f = 60$ ns, $f_{sw} = 250$ kHz.

<details>
<summary>Odpowiedzi</summary>

1. $g_m = \sqrt{2\cdot 2\cdot 10^{-3}\cdot 10^{-3}} = 2$ mS, $U_{ov} = 1$ V; BJT: 38,7 mS — ok. 19 razy więcej
2. $r_o = 50$ kΩ, $g_mr_o = 100$
3. $25\cdot 0{,}032 = 0{,}8$ W
4. $I_G \approx 30\ \text{nC}/50\ \text{ns} = 0{,}6$ A; $P_G = 30\ \text{nC}\cdot 10\ \text{V}\cdot 200\ \text{kHz} = 60$ mW
5. $\tfrac12\cdot 48\cdot 10\cdot 60\cdot 10^{-9}\cdot 2{,}5\cdot 10^5 = 3{,}6$ W
</details>

## Źródła

- [MIT 6.012 Microelectronic Devices and Circuits](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-spring-2009/) — model małosygnałowy MOSFET
- [MIT 6.002 Circuits and Electronics](https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/) — MOSFET jako klucz, energia i straty w układach CMOS
- [Analog Devices — Electronics I and II](https://wiki.analog.com/university/courses/electronics/text/electronics-toc) — rozdział o układach zarządzania zasilaniem
- [LTspice](https://www.analog.com/en/resources/design-tools-and-calculators/ltspice-simulator.html) — biblioteka modeli tranzystorów mocy (VDMOS)
