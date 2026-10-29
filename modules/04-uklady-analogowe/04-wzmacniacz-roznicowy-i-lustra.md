# 04.04 — Wzmacniacz różnicowy i lustra prądowe

## Po co to jest

Wzmacniacz różnicowy wzmacnia różnicę dwóch sygnałów i tłumi to, co wspólne (zakłócenia, dryft). Jest wejściem każdego wzmacniacza operacyjnego, komparatora i wzmacniacza pomiarowego. Lustra prądowe zastępują rezystory w układach scalonych: polaryzują stopnie i dają duże wzmocnienie jako obciążenie aktywne.

## Teoria w pigułce

### Para różnicowa

Dwa jednakowe tranzystory ze złączonymi emiterami (źródłami) zasilane źródłem prądowym $I_{EE}$ (ogon). Bez sygnału każdy przewodzi $I_{EE}/2$.

- **Sygnał różnicowy** $u_d = u_1 - u_2$: prądy zmieniają się przeciwnie.
- **Sygnał wspólny** $u_{cm} = (u_1 + u_2)/2$: przy idealnym źródle ogona prądy się nie zmieniają.

| Wielkość | Wzór (BJT, obciążenie $R_C$ w każdym kolektorze) |
|---|---|
| $g_m$ jednego tranzystora | $\dfrac{I_{EE}/2}{U_T}$ |
| Wzmocnienie różnicowe, wyjście symetryczne | $A_d = g_mR_C$ |
| Wzmocnienie różnicowe, wyjście z jednego kolektora | $A_d = \dfrac{g_mR_C}{2}$ |
| Wzmocnienie sygnału wspólnego (wyjście z jednego kolektora) | $A_{cm} \approx -\dfrac{R_C}{2R_{EE}}$ |
| Współczynnik tłumienia sygnału wspólnego | $\text{CMRR} = \left\lvert\dfrac{A_d}{A_{cm}}\right\rvert$, zwykle w dB |

$R_{EE}$ — rezystancja wyjściowa źródła ogona. Im lepsze źródło prądowe, tym wyższy CMRR.

**Zakres liniowy** pary bipolarnej: $\lvert u_d\rvert \ll 2U_T$ (kilkadziesiąt mV). Przy większych sygnałach cały prąd przełącza się na jeden tranzystor — para działa jak przełącznik prądu (mnożniki, komparatory, logika ECL).

### Lustra prądowe

**Proste lustro:** tranzystor w połączeniu diodowym (baza zwarta z kolektorem) ustala $U_{BE}$, drugi tranzystor kopiuje prąd.

$$I_{ref} = \frac{V_{CC} - U_{BE}}{R}, \qquad I_{wy} = \frac{I_{ref}}{1 + 2/\beta}$$

Rezystancja wyjściowa: $r_o = V_A/I_{wy}$.

Ulepszenia: lustro z wtórnikiem (kompensacja prądu baz), lustro Wilsona i lustro kaskodowe (dużo większa rezystancja wyjściowa), lustro Widlara (małe prądy bez dużych rezystorów). Proporcje prądów ustala się stosunkiem powierzchni emiterów (W/L w MOSFET-ach).

### Obciążenie aktywne

Para różnicowa z lustrem prądowym w miejscu rezystorów kolektorowych: wyjście jednostronne, ale z pełnym wzmocnieniem $g_m(r_{o2}\parallel r_{o4})$ — rzędu kilkuset do kilku tysięcy z jednego stopnia.

## Przykład rozwiązany

Para bipolarna: $I_{EE} = 1$ mA, $R_C = 10$ kΩ, źródło ogona o rezystancji wyjściowej $R_{EE} = 100$ kΩ.

1. $g_m = 0\text{,}5\ \text{mA}/25\text{,}85\ \text{mV} \approx 19\text{,}3$ mS.
2. Wyjście symetryczne: $A_d \approx 193$; z jednego kolektora: $A_d \approx 96\text{,}7$.
3. $A_{cm} \approx -\dfrac{10\ \text{k}}{200\ \text{k}} = -0\text{,}05$.
4. $\text{CMRR} \approx 96\text{,}7/0\text{,}05 \approx 1934 \approx 65\text{,}7$ dB.

Zastąpienie ogona rezystorem 7,5 kΩ (przy zasilaniu −8 V) daje $A_{cm} \approx -0\text{,}67$ i CMRR tylko ok. 43 dB — dlatego w ogonie stosuje się lustro prądowe.

**Lustro:** $V_{CC} = 12$ V, $R = 11\text{,}3$ kΩ → $I_{ref} = 1$ mA; przy $\beta = 100$: $I_{wy} \approx 0\text{,}98$ mA.

## Typowe pułapki

- **Wzmocnienie dla wyjścia jednostronnego liczone jak dla symetrycznego** (różnica dwukrotna).
- **CMRR liczony przy idealnym źródle ogona** — wychodzi nieskończony; w rzeczywistości ogranicza go $R_{EE}$ i niedopasowanie elementów.
- **Lustro z tranzystorów w różnych temperaturach** — w układach dyskretnych tranzystory muszą być sprzężone termicznie (najlepiej podwójny tranzystor w jednej obudowie).
- **Napięcie wyjściowe lustra poza zakresem**, w którym tranzystor wyjściowy jest w stanie aktywnym.

## Symulacja

```spice
* 04.04 para roznicowa z lustrem pradowym w ogonie
VCC vcc 0 12
VEE vee 0 -12
VD in1 0 0 AC 0.5
VD2 in2 0 0 AC 0.5 180
RC1 vcc c1 10k
RC2 vcc c2 10k
Q1 c1 in1 e QN
Q2 c2 in2 e QN
Q3 e m vee QN
Q4 m m vee QN
RREF 0 m 11.3k
.model QN NPN(Bf=100 Is=1e-14 Vaf=100)
.ac dec 10 1k 10k
.end
```

Odczytaj wzmocnienie różnicowe z `V(c1,c2)`. Następnie ustaw oba źródła na `AC 1` w tej samej fazie i odczytaj wzmocnienie sygnału wspólnego z `V(c1)`. Policz CMRR.

## Zadania

1. Para różnicowa: $I_{EE} = 1$ mA, $R_C = 10$ kΩ. Wyznacz $A_d$ (oba rodzaje wyjścia).
2. Przy $R_{EE} = 100$ kΩ wyznacz $A_{cm}$ i CMRR w dB.
3. Jak zmieni się $A_d$ i zakres liniowy pary po dodaniu rezystorów 100 Ω w emitery obu tranzystorów (degeneracja)?
4. Lustro prądowe: $V_{CC} = 5$ V, potrzebny prąd 100 µA. Dobierz $R$. Jaki będzie prąd wyjściowy przy $\beta = 50$?
5. Lustro ma tranzystor wyjściowy o $V_A = 50$ V i prąd 100 µA. Jaka jest jego rezystancja wyjściowa? O ile zmieni się prąd przy zmianie napięcia wyjściowego o 5 V?

<details>
<summary>Odpowiedzi</summary>

1. 193 (symetryczne), ≈ 96,7 (jednostronne)
2. −0,05; ≈ 65,7 dB
3. $A_d \approx \dfrac{R_C}{r_e + R_E}$ na tranzystor: $r_e \approx 51\text{,}7\ \Omega$, jednostronnie ≈ $\dfrac{10\ \text{k}}{2(51\text{,}7 + 100)} \approx 33$ — wzmocnienie spada ok. 3 razy, ale zakres liniowy rośnie do ok. $\pm I_{EE}R_E/2$ ponad $\pm 2U_T$, czyli kilka razy
4. $R = (5 - 0\text{,}65)/100\ \mu\text{A} \approx 43\text{,}5$ kΩ (np. 43 kΩ); $I_{wy} = 100/(1 + 2/50) \approx 96$ µA
5. $r_o = 500$ kΩ; $\Delta I = 5/500\ \text{k} = 10\ \mu$A (10%)
</details>

## Źródła

- [MIT 6.012 Microelectronic Devices and Circuits](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-spring-2009/) — wzmacniacze różnicowe, lustra prądowe, obciążenie aktywne
- [Operational Amplifiers & Linear ICs — J. M. Fiore, rozdział 2 *Operational Amplifier Internals*](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html) — wzmacniacz różnicowy jako wejście wzmacniacza operacyjnego
- [Analog Devices — Electronics I and II](https://wiki.analog.com/university/courses/electronics/text/electronics-toc)
