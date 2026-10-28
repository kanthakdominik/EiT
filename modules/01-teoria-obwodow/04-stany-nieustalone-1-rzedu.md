# 01.04 — Stany nieustalone w obwodach 1. rzędu (RC, RL)

## Po co to jest

Każde przełączenie w obwodzie z kondensatorem lub cewką wywołuje stan przejściowy: ładowanie kondensatora odsprzęgającego, czas narastania zbocza sygnału cyfrowego, przepięcie przy wyłączaniu przekaźnika, układy opóźniające i resetujące, generatory relaksacyjne. Większość z nich to układy 1. rzędu.

## Teoria w pigułce

### Prawa komutacji

- **Napięcie na kondensatorze nie może zmienić się skokowo:** $u_C(0^+) = u_C(0^-)$ (skok napięcia wymagałby nieskończonego prądu).
- **Prąd cewki nie może zmienić się skokowo:** $i_L(0^+) = i_L(0^-)$.

Wszystkie inne wielkości (prąd kondensatora, napięcie cewki, napięcia na rezystorach) **mogą** zmieniać się skokowo.

### Stała czasowa

- Obwód RC: $\tau = R_{th}C$
- Obwód RL: $\tau = \dfrac{L}{R_{th}}$

gdzie $R_{th}$ to rezystancja Thévenina widziana z zacisków kondensatora lub cewki (po wyłączeniu źródeł).

### Metoda trzech wielkości

Dowolna wielkość $x(t)$ w obwodzie 1. rzędu z wymuszeniem stałym:

$$x(t) = x(\infty) + \left[x(0^+) - x(\infty)\right]e^{-t/\tau}$$

Wystarczy:
1. **$x(0^+)$** — z obwodu tuż po przełączeniu (kondensator jako źródło napięcia $u_C(0)$, cewka jako źródło prądu $i_L(0)$).
2. **$x(\infty)$** — z obwodu w stanie ustalonym (kondensator = przerwa, cewka = zwarcie).
3. **$\tau$** — z rezystancji Thévenina.

### Odpowiedź na przebieg prostokątny

Filtr RC pobudzony prostokątem o półokresie $T/2$:
- $T/2 \gg \tau$ — kondensator zdąży się naładować, wyjście to „zaokrąglony” prostokąt,
- $T/2 \ll \tau$ — wyjście to mały trójkąt wokół wartości średniej (układ całkujący).

## Przykład rozwiązany

**RC z niezerowym warunkiem początkowym.** $C = 10\ \mu$F naładowany do 2 V w chwili $t = 0$ zostaje dołączony przez $R = 10$ kΩ do źródła 12 V.

1. $u_C(0^+) = 2$ V (prawo komutacji), $u_C(\infty) = 12$ V, $\tau = RC = 0{,}1$ s.
2. $u_C(t) = 12 + (2 - 12)e^{-t/0{,}1} = 12 - 10e^{-10t}$ V.
3. Prąd: $i(0^+) = \dfrac{12 - 2}{10\ \text{k}} = 1$ mA, potem maleje wykładniczo: $i(t) = 1\ \text{mA}\cdot e^{-10t}$.
4. Czas do 9 V: $10e^{-t/\tau} = 3 \Rightarrow t = \tau\ln\dfrac{10}{3} \approx 0{,}120$ s.

**RL — wyłączenie cewki.** Przez cewkę $L = 50$ mH płynie 100 mA. Wyłącznik otwiera się, a prąd może płynąć tylko przez równoległy rezystor 1 kΩ.

1. $i_L(0^+) = 100$ mA (prawo komutacji) — ten prąd musi płynąć przez rezystor.
2. Napięcie na cewce w chwili $0^+$: $u = 0{,}1\ \text{A}\cdot 1\ \text{k}\Omega = 100$ V — mimo że obwód mógł być zasilany kilkoma woltami!
3. $\tau = L/R = 50\ \mu$s.

Bez rezystora (lub diody gaszącej) napięcie rośnie aż do przebicia — tak niszczy się tranzystory sterujące przekaźnikami.

## Typowe pułapki

- **Ciągłość prądu kondensatora albo napięcia cewki** — przyjmowana błędnie. Ciągłe są tylko $u_C$ i $i_L$.
- **$\tau$ z rezystancji połączonej szeregowo z kondensatorem**, zamiast z rezystancji Thévenina widzianej z jego zacisków.
- **Stan ustalony z kondensatorem jako zwarciem** (to cewka jest zwarciem w DC).
- **Brak diody gaszącej** przy przełączaniu obciążeń indukcyjnych — w praktyce, nie tylko na kolokwium.

## Symulacja

```spice
* 01.04 RC z warunkiem poczatkowym
V1 1 0 12
R1 1 2 10k
C1 2 0 10u IC=2
.tran 0 0.6 0 1m UIC
.end
```

Ćwiczenie: zmierz kursorami czas, po którym $u_C = 9$ V. Następnie zastąp źródło przebiegiem prostokątnym (`PULSE(0 5 0 1n 1n 1m 2m)`) i obserwuj wyjście filtra RC o $\tau = 1$ ms przy różnych okresach.

## Zadania

1. Szeregowy obwód: źródło 10 V, $R = 1$ kΩ, $C = 100\ \mu$F (rozładowany). Wyznacz $i(0^+)$, $\tau$, $u_C(\tau)$. Jak zmieni się odpowiedź po czterokrotnym zwiększeniu $C$?
2. Kondensator 100 µF naładowany do 50 V rozładowuje się przez 10 kΩ. Po jakim czasie napięcie spadnie do 5 V? Jaka była energia początkowa?
3. Źródło 24 V, $R = 12\ \Omega$, $L = 0{,}6$ H, wyłącznik zamyka się w $t = 0$. Wyznacz $i_L(\infty)$, $\tau$ i $i_L(0{,}1\ \text{s})$.
4. Źródło 12 V, dzielnik $R_1 = 6$ kΩ, $R_2 = 3$ kΩ, kondensator $C = 1\ \mu$F równolegle do $R_2$ (rozładowany). Wyznacz $u_C(\infty)$ i $\tau$.
5. Cewka $L = 50$ mH z prądem 100 mA; po otwarciu wyłącznika prąd płynie przez 1 kΩ. Wyznacz napięcie na cewce w $t = 0^+$ i stałą czasową. Co zmieni dioda gasząca równolegle do cewki?
6. **(trudniejsze)** Filtr RC o $\tau = 1$ ms pobudzany prostokątem 0/5 V o półokresie równym $\tau$. Wyznacz napięcia maksymalne i minimalne na kondensatorze w stanie ustalonym.

<details>
<summary>Odpowiedzi</summary>

1. $i(0^+) = 10$ mA, $\tau = 0{,}1$ s, $u_C(\tau) = 6{,}32$ V; przy $4C$: $\tau = 0{,}4$ s, prąd początkowy bez zmian, przebieg 4 razy wolniejszy
2. $\tau = 1$ s, $t = \ln 10 \approx 2{,}30$ s; $W = \tfrac12\cdot 10^{-4}\cdot 50^2 = 0{,}125$ J
3. $i_L(\infty) = 2$ A, $\tau = 0{,}05$ s, $i_L(0{,}1) = 2(1 - e^{-2}) \approx 1{,}73$ A
4. $u_C(\infty) = 12\cdot\dfrac{3}{9} = 4$ V, $R_{th} = 6\parallel 3 = 2$ kΩ, $\tau = 2$ ms
5. 100 V, $\tau = 50\ \mu$s; z diodą napięcie ograniczy się do spadku na diodzie (ok. 0,7 V), a prąd zaniknie wolniej
6. Z warunku okresowości: $U_{max} = \dfrac{5}{1 + e^{-1}} \approx 3{,}66$ V, $U_{min} = U_{max}e^{-1} \approx 1{,}34$ V
</details>

## Źródła

- [DC Electrical Circuit Analysis — J. M. Fiore](https://eng.libretexts.org/Bookshelves/Electrical_Engineering/Electronics/DC_Electrical_Circuit_Analysis_-_A_Practical_Approach_%28Fiore%29) — rozdziały o kondensatorach, cewkach i stanach przejściowych
- [All About Circuits — tom DC, rozdział *RC and L/R Time Constants*](https://www.allaboutcircuits.com/textbook/)
- [MIT 6.002 Circuits and Electronics](https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/) — wykłady o dynamice układów 1. rzędu
- [Analog Devices — Engineering University Program](https://wiki.analog.com/university) — laboratorium pomiaru stałej czasowej i odpowiedzi skokowej
