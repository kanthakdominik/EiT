# 03.05 — Model małosygnałowy tranzystora bipolarnego

## Po co to jest

Wzmacniacz pracuje z małymi zmianami sygnału wokół stałego punktu pracy. Model małosygnałowy zamienia nieliniowy tranzystor w liniowy obwód (źródło sterowane + rezystancje), który analizuje się metodami z modułu 01. Na nim opiera się cały moduł [04](../04-uklady-analogowe/).

## Teoria w pigułce

### Parametry w punkcie pracy

Linearyzacja $I_C = I_Se^{U_{BE}/U_T}$ w punkcie $I_C$:

| Parametr | Wzór | Przy $I_C = 1$ mA, $\beta = 100$, $V_A = 100$ V |
|---|---|---|
| Transkonduktancja | $g_m = \dfrac{I_C}{U_T}$ | 38,7 mS |
| Rezystancja wejściowa (baza–emiter) | $r_\pi = \dfrac{\beta}{g_m}$ | 2,59 kΩ |
| Rezystancja emitera | $r_e = \dfrac{\alpha}{g_m} \approx \dfrac{U_T}{I_E}$ | ≈ 25,6 Ω |
| Rezystancja wyjściowa | $r_o = \dfrac{V_A}{I_C}$ | 100 kΩ |
| Wzmocnienie wewnętrzne | $g_m r_o = \dfrac{V_A}{U_T}$ | ≈ 3870 |

**Najważniejsza obserwacja:** $g_m$ zależy tylko od prądu kolektora, nie od typu tranzystora. Wzmocnienie ustala się prądem polaryzacji.

### Model hybrydowy π

Między bazą a emiterem $r_\pi$, w obwodzie kolektora źródło prądowe $g_mu_{be}$ równolegle z $r_o$. Dla wysokich częstotliwości dochodzą pojemności $C_\pi$ (B–E) i $C_\mu$ (B–C) oraz rezystancja rozproszona bazy $r_b$.

### Model T

Rezystancja $r_e$ w emiterze i źródło prądowe $\alpha i_e$ w kolektorze. Równoważny modelowi π, ale wygodniejszy, gdy w emiterze jest rezystor ($R_E$).

### Związek z parametrami $h$

$h_{ie} \approx r_\pi$, $h_{fe} \approx \beta$, $h_{oe} \approx 1/r_o$, $h_{re} \approx 0$ ([01.09 Czwórniki](../01-teoria-obwodow/09-czworniki.md)).

### Częstotliwość graniczna

$$f_T \approx \frac{g_m}{2\pi(C_\pi + C_\mu)}$$

Przy $f_T$ wzmocnienie prądowe w układzie WE spada do 1. Wzmocnienie prądowe zaczyna spadać przy $f_\beta = f_T/\beta$.

## Przykład rozwiązany

$I_C = 1$ mA, $\beta = 100$, $C_\pi = 20$ pF, $C_\mu = 2$ pF.

1. $g_m = 1/25{,}85 \approx 38{,}7$ mS, $r_\pi \approx 2{,}59$ kΩ.
2. $f_T \approx \dfrac{0{,}0387}{2\pi\cdot 22\cdot 10^{-12}} \approx 280$ MHz, $f_\beta \approx 2{,}8$ MHz.
3. Prosty wzmacniacz WE z $R_C = 4{,}7$ kΩ (bez rezystora emiterowego, $r_o$ pominięte): $K_u = -g_mR_C \approx -182$.

## Typowe pułapki

- **Model małosygnałowy użyty do policzenia punktu pracy.** Najpierw analiza DC z modelem wielkosygnałowym, potem parametry, potem analiza AC.
- **Źródła stałe w analizie AC zostawione.** W schemacie małosygnałowym źródła napięcia stałego zwiera się do masy, a duże kondensatory sprzęgające zastępuje się zwarciem.
- **$r_\pi$ i $r_e$ pomylone** — różnią się $\beta + 1$ razy. $r_\pi$ „widać” od strony bazy, $r_e$ — od strony emitera.

## Symulacja

Wyznacz $g_m$ „pomiarowo”: w LTspice ustaw punkt pracy tranzystora na 1 mA, wykonaj `.dc` napięcia $U_{BE}$ w wąskim zakresie i policz pochodną `d(Ic(Q1))` w oknie przebiegów. Porównaj z $I_C/U_T$. Polecenie `.op` z włączonym logowaniem pokazuje też parametry małosygnałowe w pliku `.log` (View → SPICE Error Log).

## Zadania

1. Wyznacz $g_m$, $r_\pi$, $r_e$ przy $I_C = 2$ mA i $\beta = 150$.
2. Ile wynosi wzmocnienie wewnętrzne $g_mr_o$ przy $V_A = 100$ V? Czy zależy od prądu?
3. Tranzystor ma $f_T = 300$ MHz i $\beta = 150$. Przy jakiej częstotliwości wzmocnienie prądowe spada o 3 dB?
4. Narysuj schemat małosygnałowy wzmacniacza WE z rezystorem $R_E$ w emiterze (bez kondensatora). Wykaż, że $K_u \approx -\dfrac{R_C}{r_e + R_E}$.
5. Dlaczego dwukrotne zwiększenie prądu kolektora przy stałym $R_C$ podwaja wzmocnienie wzmacniacza WE, ale ogranicza zakres napięć wyjściowych?

<details>
<summary>Odpowiedzi</summary>

1. $g_m \approx 77{,}4$ mS, $r_\pi \approx 1{,}94$ kΩ, $r_e \approx 12{,}8\ \Omega$
2. ≈ 3870; nie zależy od prądu (oba parametry zależą od $I_C$ odwrotnie)
3. $f_\beta = 300/150 = 2$ MHz
4. $u_{we} = i_b r_\pi + (\beta + 1)i_b R_E$, $u_{wy} = -\beta i_b R_C$ → $K_u = -\dfrac{\beta R_C}{r_\pi + (\beta + 1)R_E} \approx -\dfrac{R_C}{r_e + R_E}$
5. $g_m$ rośnie proporcjonalnie do $I_C$, ale spadek napięcia na $R_C$ też się podwaja, więc $U_{CE}$ spada i zostaje mniej miejsca na wahania sygnału przed nasyceniem
</details>

## Źródła

- [MIT 6.012 Microelectronic Devices and Circuits](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-spring-2009/) — modele małosygnałowe i wysokoczęstotliwościowe
- [MIT 6.002 Circuits and Electronics](https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/) — wykłady o modelu małosygnałowym i wzmacniaczach
- [Semiconductor Devices — J. M. Fiore](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html) — modele AC tranzystora
