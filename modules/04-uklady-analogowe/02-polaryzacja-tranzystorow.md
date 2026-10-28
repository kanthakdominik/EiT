# 04.02 — Polaryzacja tranzystorów i punkt pracy

## Po co to jest

Wzmacniacz działa tylko wtedy, gdy tranzystor ma właściwy punkt pracy: w zakresie aktywnym (BJT) lub nasycenia (MOSFET), z miejscem na wahania sygnału. Dobry układ polaryzacji utrzymuje ten punkt mimo rozrzutu $\beta$, $V_t$ i zmian temperatury.

## Teoria w pigułce

### Układy polaryzacji BJT

| Układ | Stabilność punktu pracy | Uwagi |
|---|---|---|
| Rezystor z zasilania do bazy | Bardzo zła — $I_C$ proporcjonalne do $\beta$ | Tylko dla kluczy |
| Rezystor z kolektora do bazy | Średnia — ujemne sprzężenie zwrotne | Prosty, zmniejsza wzmocnienie |
| **Dzielnik w bazie + rezystor emiterowy** | Dobra | Standard dla wzmacniaczy dyskretnych |
| Źródło prądowe w emiterze | Bardzo dobra | Układy scalone, wzmacniacze różnicowe |

### Analiza polaryzacji dzielnikiem

1. Zastąp dzielnik źródłem Thévenina: $E_{th} = V_{CC}\dfrac{R_2}{R_1 + R_2}$, $R_{th} = R_1\parallel R_2$.
2. Oczko baza–emiter: $E_{th} = I_BR_{th} + U_{BE} + (\beta + 1)I_BR_E$.
3. $I_C = \beta I_B$, $U_{CE} = V_{CC} - I_CR_C - I_ER_E$.

**Reguła projektowa:** gdy $(\beta + 1)R_E \gg R_{th}$ (np. 10 razy), to $I_E \approx \dfrac{E_{th} - 0{,}7}{R_E}$ — prąd prawie nie zależy od $\beta$. Typowo $U_E \approx 1$–2 V (10–20% zasilania), a punkt pracy w połowie zakresu dostępnego dla sygnału.

### Polaryzacja MOSFET-a

Dzielnik ustala napięcie bramki (bez prądu bramki — dzielnik może być wysokoomowy), rezystor źródła $R_S$ stabilizuje prąd:

$$U_{GS} = U_G - I_DR_S, \qquad I_D = \frac{k}{2}(U_{GS} - V_t)^2$$

Wynika z tego równanie kwadratowe — jedno rozwiązanie zwykle odpada, bo daje $U_{GS} < V_t$.

### Stabilność termiczna

$U_{BE}$ maleje o ok. 2 mV/K, a $\beta$ rośnie z temperaturą — prąd kolektora rośnie. Rezystor $R_E$ wprowadza ujemne sprzężenie zwrotne, które to kompensuje. W stopniach mocy bez takiego sprzężenia grozi **ucieczka termiczna**.

## Przykład rozwiązany

**BJT:** $V_{CC} = 12$ V, $R_1 = 47$ kΩ, $R_2 = 10$ kΩ, $R_C = 4{,}7$ kΩ, $R_E = 1$ kΩ, $\beta = 100$.

1. $E_{th} = 12\cdot\dfrac{10}{57} \approx 2{,}105$ V, $R_{th} \approx 8{,}25$ kΩ.
2. $I_B = \dfrac{2{,}105 - 0{,}7}{8{,}25\ \text{k} + 101\cdot 1\ \text{k}} \approx 12{,}9\ \mu$A.
3. $I_C \approx 1{,}29$ mA, $I_E \approx 1{,}30$ mA.
4. $U_C = 12 - 1{,}29\cdot 4{,}7 \approx 5{,}95$ V, $U_E \approx 1{,}30$ V, $U_{CE} \approx 4{,}66$ V — stan aktywny ✓.
5. Przybliżenie „$\beta \to \infty$”: $I_E \approx 1{,}405$ mA — błąd 8%, bo $(\beta + 1)R_E$ jest tylko ok. 12 razy większe od $R_{th}$. Przy $\beta = 300$ prąd wzrósłby tylko do ok. 1,37 mA.

**MOSFET:** $U_G = 3$ V, $R_S = 1$ kΩ, $k = 2$ mA/V², $V_t = 1$ V, $R_D = 5$ kΩ, $V_{DD} = 12$ V.

1. $I_D = (U_{GS} - 1)^2$ [mA], $U_{GS} = 3 - I_D$ → $I_D = (2 - I_D)^2$ → $I_D^2 - 5I_D + 4 = 0$.
2. $I_D = 1$ mA albo 4 mA. Dla 4 mA $U_{GS} = -1$ V $< V_t$ — odrzucamy. Wynik: $I_D = 1$ mA, $U_{GS} = 2$ V.
3. $U_{DS} = 12 - 1\cdot 5 - 1\cdot 1 = 6$ V $> U_{ov} = 1$ V — nasycenie ✓.

## Typowe pułapki

- **Pominięcie prądu bazy w dzielniku**, gdy dzielnik jest wysokoomowy.
- **Punkt pracy przy samym nasyceniu lub odcięciu** — sygnał zostanie obcięty z jednej strony.
- **Wybór złego pierwiastka** równania kwadratowego MOSFET-a.
- **Pominięcie spadku na $R_E$** przy liczeniu $U_{CE}$.

## Symulacja

```spice
* 04.02 polaryzacja dzielnikiem - wplyw beta
VCC vcc 0 12
R1 vcc b 47k
R2 b 0 10k
RC vcc c 4.7k
RE e 0 1k
Q1 c b e QN
.model QN NPN(Bf={B} Is=1e-14 Vaf=100)
.step param B list 50 100 200 400
.op
.end
```

Odczytaj $I_C$ dla kolejnych $\beta$ (View → SPICE Error Log). Zmniejsz $R_1$ i $R_2$ dziesięciokrotnie (przy tym samym stosunku) i powtórz — jak zmienia się wrażliwość na $\beta$ i pobór prądu z zasilania?

## Zadania

1. Wyznacz punkt pracy wzmacniacza z przykładu przy $\beta = 300$.
2. Zaprojektuj polaryzację: $V_{CC} = 9$ V, $I_C = 1$ mA, $U_E = 1$ V, $U_C = 5$ V, $\beta_{min} = 100$, prąd dzielnika ok. 10× prąd bazy. Podaj $R_E$, $R_C$, $R_1$, $R_2$.
3. MOSFET z przykładu: zmień $R_S$ na 2 kΩ. Wyznacz $I_D$ i $U_{GS}$.
4. Polaryzacja rezystorem z kolektora do bazy: $V_{CC} = 12$ V, $R_C = 4{,}7$ kΩ, $R_B = 470$ kΩ (kolektor–baza), $\beta = 100$. Wyznacz $I_C$ i $U_{CE}$.
5. Wyjaśnij mechanizm ucieczki termicznej w stopniu mocy bez rezystorów emiterowych.

<details>
<summary>Odpowiedzi</summary>

1. $I_B = \dfrac{1{,}405}{8{,}25\ \text{k} + 301\ \text{k}} \approx 4{,}54\ \mu$A, $I_C \approx 1{,}36$ mA, $U_{CE} \approx 12 - 1{,}36\cdot 4{,}7 - 1{,}37 \approx 4{,}24$ V
2. $R_E = 1$ kΩ, $R_C = 4$ kΩ (np. 3,9 kΩ), $U_B = 1{,}7$ V, $I_B = 10\ \mu$A, prąd dzielnika 100 µA: $R_2 = 17$ kΩ, $R_1 = (9 - 1{,}7)/110\ \mu\text{A} \approx 66$ kΩ (np. 68 kΩ i 16 kΩ z szeregu, z kontrolą wyniku)
3. $U_{GS} = 3 - 2I_D$, $I_D = (2 - 2I_D)^2$ → $4I_D^2 - 9I_D + 4 = 0$ → $I_D \approx 0{,}61$ mA (drugi pierwiastek 1,64 mA daje $U_{GS} < V_t$), $U_{GS} \approx 1{,}78$ V
4. $12 = (I_C + I_B)\cdot 4{,}7\ \text{k} + I_B\cdot 470\ \text{k} + 0{,}7$ → $I_B(101\cdot 4{,}7 + 470)\ \text{k} = 11{,}3$ → $I_B \approx 12{,}0\ \mu$A, $I_C \approx 1{,}2$ mA, $U_{CE} \approx 12 - 1{,}21\cdot 4{,}7 \approx 6{,}3$ V
5. Wzrost temperatury → spadek $U_{BE}$ przy stałym napięciu polaryzacji → wzrost prądu → większa moc strat → dalszy wzrost temperatury. Bez sprzężenia zwrotnego (np. rezystora emiterowego lub termicznego sprzężenia diod polaryzujących) proces może narastać aż do zniszczenia tranzystora.
</details>

## Źródła

- [Semiconductor Devices — J. M. Fiore, rozdziały o polaryzacji BJT i FET](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html)
- [MIT 6.002 Circuits and Electronics](https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/) — wzmacniacz MOSFET, analiza wielkosygnałowa
- [All About Circuits — tom Semiconductors, rozdział *Biasing Techniques*](https://www.allaboutcircuits.com/textbook/)
