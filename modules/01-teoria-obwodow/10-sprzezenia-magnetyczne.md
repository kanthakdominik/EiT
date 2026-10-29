# 01.10 — Obwody sprzężone magnetycznie i transformator

## Po co to jest

Transformatory występują w zasilaczach, przetwornicach izolowanych, układach dopasowania impedancji (audio, w.cz.), sondach prądowych i transmisji różnicowej (Ethernet). Sprzężenia pasożytnicze między ścieżkami i przewodami to źródło przesłuchów i zakłóceń.

## Teoria w pigułce

### Indukcyjność wzajemna

Dwie cewki o indukcyjnościach $L_1$, $L_2$ sprzężone indukcyjnością wzajemną $M$:

$$u_1 = L_1\frac{di_1}{dt} \pm M\frac{di_2}{dt}, \qquad u_2 = \pm M\frac{di_1}{dt} + L_2\frac{di_2}{dt}$$

Współczynnik sprzężenia: $k = \dfrac{M}{\sqrt{L_1L_2}}$, $0 \leq k \leq 1$.

**Konwencja kropkowa:** jeśli oba prądy wpływają do zacisków oznaczonych kropką, strumienie się wzmacniają i składnik z $M$ ma znak „+”.

W postaci fazorowej: $\underline{U}_1 = j\omega L_1\underline{I}_1 \pm j\omega M\underline{I}_2$.

### Cewki sprzężone połączone szeregowo

- zgodnie: $L = L_1 + L_2 + 2M$,
- przeciwnie: $L = L_1 + L_2 - 2M$.

Pomiar obu wartości pozwala wyznaczyć $M = \dfrac{L_{zg} - L_{przec}}{4}$.

### Transformator idealny

Przekładnia $n = \dfrac{N_1}{N_2}$ ($k = 1$, brak strat, nieskończona indukcyjność magnesowania):

$$\frac{U_1}{U_2} = n, \qquad \frac{I_1}{I_2} = \frac{1}{n}, \qquad Z_{we} = n^2 Z_L$$

Transformator **przenosi impedancję w kwadracie przekładni** — to podstawa dopasowania impedancji.

### Transformator rzeczywisty (model)

Indukcyjności rozproszenia (sprzężenie $k < 1$), indukcyjność magnesowania, rezystancje uzwojeń, straty w rdzeniu (histereza i prądy wirowe), pojemności międzyzwojowe. Transformator nie przenosi napięcia stałego — strumień w rdzeniu musi się zmieniać.

## Przykład rozwiązany

Transformator sieciowy 230 V / 12 V zasila obciążenie pobierające 2 A.

1. $n = 230/12 \approx 19\text{,}17$.
2. Rezystancja obciążenia $R_L = 12/2 = 6\ \Omega$; widziana od strony pierwotnej: $6\cdot 19\text{,}17^2 \approx 2204\ \Omega$.
3. Prąd pierwotny (transformator idealny): $I_1 = 2/19\text{,}17 \approx 104$ mA. Kontrola mocy: $230\cdot 0\text{,}104 \approx 24$ W $= 12\cdot 2$ ✓.

## Typowe pułapki

- **Znak składnika $M$** bez sprawdzenia kropek.
- **Przekładnia napięć stosowana do prądów** w tę samą stronę — prądy przekształcają się odwrotnie.
- **Impedancja przenoszona przez $n$** zamiast $n^2$.
- **Transformator zasilany napięciem stałym** — prąd ograniczony tylko rezystancją uzwojenia, nasycenie rdzenia, przegrzanie.

## Symulacja

W LTspice sprzężenie definiuje się dyrektywą `K`:

```spice
* 01.10 transformator 10:1 z obciazeniem 10 ohm
V1 p 0 SINE(0 325.27 50)
L1 p 0 10
L2 s 0 0.1
K1 L1 L2 0.999
RL s 0 10
.tran 0 100m 60m
.end
```

Przekładnia napięciowa $n = \sqrt{L_1/L_2} = 10$. Zmień $k$ na 0,9 i obserwuj spadek napięcia wtórnego pod obciążeniem (wpływ indukcyjności rozproszenia).

## Zadania

1. $L_1 = 4$ mH, $L_2 = 9$ mH, $k = 0\text{,}5$. Wyznacz $M$ oraz indukcyjność połączenia szeregowego zgodnego i przeciwnego.
2. Transformator idealny 10:1, napięcie pierwotne 230 V, obciążenie 10 Ω. Wyznacz $U_2$, $I_2$, $I_1$ i impedancję widzianą od strony pierwotnej.
3. Głośnik 8 Ω ma być dopasowany do wyjścia o rezystancji 800 Ω. Jaka przekładnia transformatora jest potrzebna?
4. Zmierzono indukcyjność dwóch cewek połączonych szeregowo zgodnie: 19 mH, przeciwnie: 7 mH. Wyznacz $M$.
5. Dlaczego transformator nie przenosi napięcia stałego? Co się stanie, jeśli do uzwojenia sieciowego przyłożyć 230 V DC?

<details>
<summary>Odpowiedzi</summary>

1. $M = 0\text{,}5\sqrt{36} = 3$ mH; zgodnie $4 + 9 + 6 = 19$ mH, przeciwnie $4 + 9 - 6 = 7$ mH
2. $U_2 = 23$ V, $I_2 = 2\text{,}3$ A, $I_1 = 0\text{,}23$ A, $Z_{we} = 100\cdot 10 = 1000\ \Omega$
3. $n = \sqrt{800/8} = 10$
4. $M = (19 - 7)/4 = 3$ mH
5. Napięcie indukowane jest proporcjonalne do zmian strumienia ($u = N\,d\Phi/dt$). Przy DC strumień się nie zmienia, więc w uzwojeniu wtórnym nie indukuje się napięcie, a prąd pierwotny ogranicza tylko mała rezystancja uzwojenia — rdzeń się nasyca, uzwojenie przegrzewa i ulega zniszczeniu.
</details>

## Źródła

- [All About Circuits — tom AC, rozdział o transformatorach](https://www.allaboutcircuits.com/textbook/)
- [AC Electrical Circuit Analysis — J. M. Fiore](https://eng.libretexts.org/Bookshelves/Electrical_Engineering/Electronics/AC_Electrical_Circuit_Analysis%3A_A_Practical_Approach_%28Fiore%29)
- [MIT 8.02 Physics II: Electricity and Magnetism](https://ocw.mit.edu/courses/8-02-physics-ii-electricity-and-magnetism-spring-2007/) — fizyka indukcji i indukcyjności wzajemnej
