# 05.06 — Parametry czasowe, metastabilność, synchronizacja

## Po co to jest

Układ cyfrowy działa poprawnie tylko wtedy, gdy sygnały zdążą się ustalić przed zboczem zegara. Analiza czasowa mówi, jak szybko może pracować układ, a teoria metastabilności — jak bezpiecznie wprowadzić do niego sygnały z zewnątrz. Błędy z tego obszaru dają usterki rzadkie, trudne do odtworzenia i zależne od temperatury.

## Teoria w pigułce

### Parametry przerzutnika

| Parametr | Znaczenie |
|---|---|
| $t_{setup}$ | Dane muszą być stabilne co najmniej tyle **przed** zboczem zegara |
| $t_{hold}$ | Dane muszą być stabilne co najmniej tyle **po** zboczu |
| $t_{clk\to q}$ | Opóźnienie od zbocza zegara do zmiany wyjścia |

### Warunki czasowe ścieżki rejestr → logika → rejestr

**Setup (maksymalna częstotliwość):**

$$T_{clk} \geq t_{clk\to q,max} + t_{logic,max} + t_{setup} - t_{skew}$$

**Hold (niezależny od częstotliwości!):**

$$t_{clk\to q,min} + t_{logic,min} \geq t_{hold} + t_{skew}$$

$t_{skew}$ — przesunięcie zegara między przerzutnikiem docelowym a źródłowym. Naruszenia setup naprawia się wolniejszym zegarem lub krótszą logiką (potokowanie). Naruszenia hold — tylko zmianą układu (dodanie opóźnienia); obniżenie częstotliwości nie pomaga.

### Metastabilność

Gdy dane zmieniają się w oknie setup/hold, przerzutnik może na pewien czas utknąć w stanie pośrednim. Prawdopodobieństwo, że nie rozstrzygnie się w czasie $t_r$, maleje wykładniczo:

$$\text{MTBF} = \frac{e^{t_r/\tau}}{T_0 f_{clk}f_{dane}}$$

$\tau$ i $T_0$ to parametry technologii. Dodanie czasu na rozstrzygnięcie (kolejny przerzutnik) zwiększa MTBF o wiele rzędów wielkości.

### Synchronizacja i przekraczanie domen zegarowych

| Sytuacja | Rozwiązanie |
|---|---|
| Pojedynczy sygnał wolnozmienny (przycisk, flaga) | **Synchronizator dwuprzerzutnikowy** |
| Krótki impuls z szybszej domeny | Przełącznik (toggle) + synchronizator + detektor zbocza, albo handshake |
| Słowo wielobitowe | **FIFO asynchroniczne** (wskaźniki w kodzie Graya) albo handshake z sygnałem gotowości |
| Reset | Asynchroniczne ustawienie, **synchroniczne zwolnienie** |

Przyciski mechaniczne dodatkowo **drgają** (kilka–kilkadziesiąt ms) — po synchronizatorze potrzebny jest filtr (licznik stabilności) lub układ RC z przerzutnikiem Schmitta.

## Przykład rozwiązany

**Częstotliwość maksymalna:** $t_{clk\to q} = 0{,}5$ ns, logika 6 ns, $t_{setup} = 0{,}3$ ns, bez skew → $T_{min} = 6{,}8$ ns, $f_{max} \approx 147$ MHz. Podzielenie logiki na dwa etapy po 3 ns (potokowanie, dodatkowy rejestr) daje $T_{min} = 3{,}8$ ns, $f_{max} \approx 263$ MHz — kosztem jednego cyklu opóźnienia.

**Metastabilność:** $\tau = 0{,}1$ ns, $T_0 = 1$ ns, $f_{clk} = 100$ MHz, $f_{dane} = 1$ MHz.
- Jeden przerzutnik, ok. 1 ns zapasu do następnego przerzutnika: $\text{MTBF} = \dfrac{e^{10}}{10^{-9}\cdot 10^8\cdot 10^6} \approx 0{,}22$ s — błąd kilka razy na sekundę!
- Dwa przerzutniki, ok. 5 ns na rozstrzygnięcie: $\text{MTBF} \approx \dfrac{e^{50}}{10^5} \approx 5\cdot 10^{16}$ s — ponad miliard lat.

## Typowe pułapki

- **Ignorowanie warunku hold** w przekonaniu, że wolniejszy zegar wszystko naprawi.
- **Synchronizacja wielobitowej magistrali przez osobne synchronizatory** na każdym bicie — bity mogą zostać złapane w różnych cyklach (niespójne słowo).
- **Logika kombinacyjna między przerzutnikami synchronizatora.**
- **Generowanie zegara z logiki** (dzielnik na bramkach jako zegar dla innych przerzutników) — zamiast tego zegar wspólny i sygnał zezwolenia.

## Ćwiczenie w symulatorze

W Digital lub Logisim-evolution (z opóźnieniami bramek):
- [ ] zbuduj ścieżkę rejestr → sumator 4-bitowy → rejestr i zwiększaj częstotliwość zegara, aż wynik przestanie być poprawny,
- [ ] zbuduj synchronizator dwuprzerzutnikowy i licznik eliminujący drgania przycisku (stan zmienia się dopiero, gdy wejście jest stabilne przez N cykli).

## Zadania

1. $t_{clk\to q} = 0{,}5$ ns, logika 6 ns, $t_{setup} = 0{,}3$ ns. Wyznacz $f_{max}$.
2. Jak zmieni się $f_{max}$ z zadania 1, jeśli zegar przerzutnika docelowego dociera 0,4 ns **później** niż źródłowego? Jak to wpłynie na warunek hold?
3. $t_{clk\to q,min} = 0{,}3$ ns, najkrótsza ścieżka logiki 0,1 ns, $t_{hold} = 0{,}2$ ns, skew 0,3 ns. Czy warunek hold jest spełniony? Jak go naprawić?
4. Oblicz MTBF dla danych z przykładu, jeśli czas na rozstrzygnięcie wynosi 3 ns.
5. Dlaczego wskaźniki zapisu i odczytu w asynchronicznym FIFO przekazuje się między domenami w kodzie Graya?

<details>
<summary>Odpowiedzi</summary>

1. ≈ 147 MHz
2. Skew na korzyść setup: $T_{min} = 6{,}8 - 0{,}4 = 6{,}4$ ns, $f_{max} \approx 156$ MHz; warunek hold pogarsza się o 0,4 ns
3. $0{,}3 + 0{,}1 = 0{,}4 < 0{,}2 + 0{,}3 = 0{,}5$ — naruszony; dodać opóźnienie (bufory) w krótkiej ścieżce albo zmniejszyć skew
4. $e^{30}/10^5 \approx 1{,}07\cdot 10^8$ s ≈ 3,4 roku
5. W kodzie Graya kolejne wartości różnią się jednym bitem, więc nawet jeśli zostanie złapany „w trakcie zmiany”, odczytamy albo starą, albo nową wartość — nigdy przypadkowej
</details>

## Źródła

- [MIT 6.004 Computation Structures](https://ocw.mit.edu/courses/6-004-computation-structures-spring-2017/) — dyscyplina synchroniczna, ograniczenia czasowe, metastabilność
- [MIT 6.111 Introductory Digital Systems Laboratory](https://ocw.mit.edu/courses/6-111-introductory-digital-systems-laboratory-spring-2006/) — synchronizacja wejść, analiza czasowa
- [All About Circuits — tom Digital](https://www.allaboutcircuits.com/textbook/)
