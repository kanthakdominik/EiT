# 22.02 — Diody LED i ich sterowanie

## Po co to jest

Dioda LED jest w prawie każdym urządzeniu: sygnalizacja stanu, podświetlenie, oświetlenie, nadajnik podczerwieni, źródło w czujniku optycznym i pulsoksymetrze. Jasność LED zależy od **prądu**, a napięcie przewodzenia ma duży rozrzut i zmienia się z temperaturą — dlatego dioda zasilana „napięciem” jest źle zaprojektowana. Ten temat uczy dobierać sterowanie od rezystora po źródło prądowe i przetwornicę.

## Teoria w pigułce

### Charakterystyka

- Zależność prąd–napięcie jak w diodzie ([03.02](../03-przyrzady-polprzewodnikowe/02-dioda-modele.md)), ale z większym $U_F$: IR 1,2–1,5 V, czerwona 1,8–2,2 V, zielona/niebieska/biała 2,8–3,4 V; plus rezystancja szeregowa (dla LED mocy ok. 1 Ω).
- **Rozrzut $U_F$** między egzemplarzami: ±0,1–0,3 V; współczynnik temperaturowy ok. −2 mV/K.
- Strumień jest prawie proporcjonalny do prądu (przy dużych prądach rośnie wolniej — *droop*); sprawność spada z temperaturą złącza.
- Długość fali przesuwa się z prądem i temperaturą (ważne w czujnikach).
- **Sprawność energetyczna** (wall-plug): $\eta = P_{opt}/(U_FI_F)$ — 30–60% dla dobrych LED.
- Napięcie wsteczne dopuszczalne zwykle tylko ok. 5 V.

### Metody sterowania

| Metoda | Prąd | Straty | Zastosowanie |
|---|---|---|---|
| **Rezystor szeregowy** $R = (U_{zas} - U_F)/I_F$ | Zależy od $U_{zas}$ i $U_F$ | $(U_{zas} - U_F)I_F$ | Sygnalizacja, małe prądy |
| **Źródło prądowe liniowe** (tranzystor + rezystor pomiarowy, wzmacniacz operacyjny + MOSFET) | Stały, $I = U_{ref}/R_S$ | $(U_{zas} - U_F)I_F$ | Czujniki, precyzja, nadajniki |
| **Przetwornica prądowa** (buck/boost z pomiarem prądu) | Stały | Małe (sprawność 85–95%) | Oświetlenie, LED mocy, łańcuchy LED |
| **PWM** (włączanie/wyłączanie przy stałym prądzie) | Średni = $D\cdot I$ | — | Ściemnianie bez zmiany barwy; częstotliwość > 200 Hz (bez migotania), dla kamer > kilka kHz |

- **Łączenie równoległe bez rezystorów** — prąd dzieli się nierówno (rozrzut $U_F$, ujemny współczynnik temperaturowy → ucieczka termiczna jednej diody). Łącz szeregowo albo każdą gałąź z własnym rezystorem lub źródłem.
- **Multipleksowanie** (wyświetlacze): diody zasilane po kolei impulsami większego prądu; średnia jasność ∝ prąd × współczynnik wypełnienia.

## Przykład rozwiązany

**Czerwona LED z GPIO 3,3 V,** $U_F = 2\text{,}0$ V (typowo, rozrzut 1,8–2,2 V), prąd 10 mA.

- $R = (3\text{,}3 - 2\text{,}0)/0\text{,}01 = 130$ Ω (jest w szeregu E24).
- Rozrzut prądu: $U_F = 1\text{,}8$ V → 11,5 mA; $U_F = 2\text{,}2$ V → 8,5 mA — ±15%, akceptowalne dla sygnalizacji.
- Gdyby zasilić z 2,5 V: $R = 50$ Ω, a rozrzut prądu (z uwzględnieniem charakterystyki diody) 13,6–6,5 mA (ok. ±35%) — rezystor sprawdza się tylko, gdy $U_{zas} \gg U_F$.

**LED mocy 350 mA, $U_F = 3\text{,}1$ V, zasilanie 12 V:**

- Liniowe źródło prądowe: straty $(12 - 3\text{,}1)\cdot 0\text{,}35 = 3\text{,}1$ W (więcej niż moc diody — 1,1 W).
- Trzy LED szeregowo + rezystor: $R = (12 - 9\text{,}3)/0\text{,}35 = 7\text{,}7$ Ω, straty 0,95 W — ale prąd zależy silnie od $U_F$ (zmiana sumy $U_F$ o 0,3 V zmienia prąd o 11%).
- Przetwornica buck z regulacją prądu (rezystor pomiarowy 0,29 Ω przy napięciu odniesienia 100 mV): straty ok. 0,3 W, prąd stały niezależnie od $U_F$ i zasilania.

## Typowe pułapki

- **LED bezpośrednio z pinu lub ze źródła napięciowego** bez ograniczenia prądu.
- **Ignorowanie rozrzutu $U_F$** przy małym zapasie napięcia.
- **Diody równoległe bez rezystorów.**
- **Napięcie wsteczne** (np. LED w układzie AC lub multipleksowanym) przekraczające ok. 5 V — dodaj diodę zabezpieczającą.
- **PWM o niskiej częstotliwości** — migotanie widoczne w ruchu i na kamerach; **analogowe ściemnianie** zmienia barwę białych LED.
- **Termika LED mocy** — temperatura złącza decyduje o trwałości; radiator i płytka z rdzeniem aluminiowym ([15.07](../15-energoelektronika-zasilanie/07-termika-plytka-emi.md)).

## Ćwiczenie komputerowe

Prąd LED przy rozrzucie $U_F$ — rezystor szeregowy kontra źródło prądowe (model diody z rezystancją szeregową, rozwiązany numerycznie):

```python
import numpy as np
from scipy.optimize import brentq

VT, n, Rs_led = 0.02585, 2.0, 1.0           # parametry modelu LED

def led_current(Vsup, R, Vf_nom, I_nom=10e-3):
    """Prąd LED z rezystorem R; Is dobrane tak, by U_F = Vf_nom przy I_nom."""
    Is = I_nom/np.exp((Vf_nom - I_nom*Rs_led)/(n*VT))
    f = lambda I: Vsup - I*R - (n*VT*np.log(I/Is + 1) + I*Rs_led)
    return brentq(f, 1e-9, Vsup/R)

for Vsup in (3.3, 2.5):
    R = round((Vsup - 2.0)/10e-3)
    currents = [led_current(Vsup, R, Vf)*1e3 for Vf in (1.8, 2.0, 2.2)]
    print(f"zasilanie {Vsup} V, R = {R} Ω: I = " + ", ".join(f"{i:.1f}" for i in currents) + " mA (U_F = 1,8 / 2,0 / 2,2 V)")

# łańcuch 3 LED mocy z 12 V: wpływ sumarycznego U_F
for Vf_sum in (9.0, 9.3, 9.6):
    print(f"suma U_F = {Vf_sum} V: I = {(12 - Vf_sum)/7.7*1e3:.0f} mA (rezystor 7,7 Ω)")

# straty: liniowe źródło prądowe kontra przetwornica 90%
P_led = 3.1*0.35
print(f"LED: {P_led:.2f} W; liniowo z 12 V: straty {(12 - 3.1)*0.35:.2f} W; przetwornica 90%: straty {P_led/0.9 - P_led:.2f} W")
```

## Zadania

1. Zielona LED ($U_F = 3\text{,}0$ V przy 5 mA) z zasilania 5 V. Rezystor (E24) i moc na nim?
2. Dlaczego nie można łączyć równolegle dwóch LED mocy z jednym wspólnym rezystorem?
3. Zaprojektuj źródło prądowe 20 mA ze wzmacniacza operacyjnego, MOSFET-a N i napięcia odniesienia 1,25 V. Jaki rezystor pomiarowy i jakie minimalne napięcie zasilania przy $U_F = 1\text{,}5$ V (IR)?
4. Wyświetlacz 8 cyfr multipleksowany: każda cyfra świeci 1/8 czasu. Jaki prąd impulsowy daje średnią 5 mA na segment? Na co uważać?
5. Dlaczego ściemnianie PWM nie zmienia barwy białej LED, a zmniejszanie prądu — zmienia?

<details>
<summary>Odpowiedzi</summary>

1. $(5 - 3)/0\text{,}005 = 400$ Ω → 390 Ω lub 430 Ω; moc $2\cdot 0\text{,}005 = 10$ mW
2. Dioda o mniejszym $U_F$ przejmuje większy prąd, nagrzewa się, jej $U_F$ maleje jeszcze bardziej (−2 mV/K) — dodatnie sprzężenie termiczne; prąd może się skupić w jednej diodzie
3. $R_S = 1\text{,}25/0\text{,}02 = 62\text{,}5$ Ω (62 Ω); $U_{zas} \geq U_F + U_{R_S} + U_{DS,min} \approx 1\text{,}5 + 1\text{,}25 + 0\text{,}2 \approx 3$ V (plus zapas na wyjście wzmacniacza sterującego bramką)
4. $8\cdot 5 = 40$ mA impulsowo; sprawdzić maksymalny prąd impulsowy LED i wydajność prądową driverów oraz to, że przy zawieszeniu multipleksowania (błąd programu) dioda dostanie 40 mA w sposób ciągły
5. Przy PWM dioda pracuje zawsze w tym samym punkcie (prąd, temperatura) — zmienia się tylko czas świecenia; przy zmniejszaniu prądu zmienia się widmo emisji niebieskiej diody i proporcja światła z luminoforu
</details>

## Źródła

- [RP Photonics Encyclopedia](https://www.rp-photonics.com/encyclopedia.html) — hasło: light-emitting diodes
- [03.03 Diody specjalne](../03-przyrzady-polprzewodnikowe/03-diody-specjalne.md) i [03.08 Elementy optoelektroniczne](../03-przyrzady-polprzewodnikowe/08-jfet-elementy-mocy-opto.md)
- [15.02 Przetwornica buck](../15-energoelektronika-zasilanie/02-przetwornica-buck.md) — sterowniki LED z przetwornicą
