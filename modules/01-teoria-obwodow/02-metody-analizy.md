# 01.02 — Metody analizy: węzłowa i oczkowa

## Po co to jest

Prawa Kirchhoffa wystarczą do rozwiązania każdego obwodu, ale bez systemu łatwo się pogubić. Metody węzłowa i oczkowa dają **minimalną liczbę równań** i przepis, jak je napisać. Metoda węzłowa jest podstawą działania symulatorów SPICE.

## Teoria w pigułce

### Liczba równań

Dla obwodu o $b$ gałęziach i $n$ węzłach:

- metoda węzłowa: $n - 1$ równań,
- metoda oczkowa: $b - n + 1$ równań (dla obwodów planarnych — tyle, ile „okienek” na schemacie).

Wybierz metodę, która daje mniej równań. Źródła prądowe sprzyjają metodzie węzłowej, źródła napięciowe — oczkowej.

### Metoda węzłowa (potencjałów węzłowych)

1. Wybierz węzeł odniesienia (masa) — najlepiej ten, do którego dochodzi najwięcej gałęzi.
2. Dla pozostałych węzłów napisz PPK, wyrażając prądy przez potencjały: prąd z węzła $k$ do $m$ przez $R$ wynosi $\dfrac{V_k - V_m}{R}$.
3. Rozwiąż układ $\mathbf{G}\mathbf{V} = \mathbf{J}$.

**Zapis „z oka”:** na przekątnej $G_{kk}$ — suma konduktancji przyłączonych do węzła $k$; poza przekątną $G_{km}$ — minus konduktancja między węzłami $k$ i $m$; po prawej stronie — suma prądów źródłowych wpływających do węzła (źródło napięciowe $E$ z szeregowym $R$ daje prąd $E/R$).

**Superwęzeł:** gdy idealne źródło napięcia łączy dwa węzły bez masy, obejmij oba węzły jednym PPK i dopisz równanie $V_k - V_m = E$.

### Metoda oczkowa (prądów oczkowych)

1. W każdym oczku niezależnym przyjmij prąd oczkowy (zwykle zgodnie z ruchem wskazówek zegara).
2. Dla każdego oczka napisz NPK. Prąd w gałęzi wspólnej dwóch oczek to różnica ich prądów oczkowych.
3. Rozwiąż $\mathbf{R}\mathbf{I} = \mathbf{E}$.

**Zapis „z oka”:** na przekątnej — suma rezystancji oczka; poza przekątną — minus rezystancja wspólna (gdy oba prądy mają zwrot zegarowy); po prawej — suma SEM w oczku, ze znakiem „+” gdy źródło wymusza prąd zgodnie z kierunkiem obiegu.

**Superoczko:** gdy źródło prądowe leży na gałęzi wspólnej dwóch oczek.

### Źródła sterowane

Źródło sterowane (np. prąd $g_m u_x$) traktuje się jak zwykłe źródło przy pisaniu równań, a następnie wyraża wielkość sterującą $u_x$ przez niewiadome. Macierz przestaje być symetryczna. Źródła sterowane to modele tranzystorów i wzmacniaczy — wracają w module 04.

## Przykład rozwiązany — obie metody

Węzeł A na górze, masa na dole. Trzy gałęzie między A i masą:

- lewa: źródło $E_1 = 12$ V („+” do góry) szeregowo z $R_1 = 2\ \Omega$,
- środkowa: $R_3 = 4\ \Omega$,
- prawa: $R_2 = 2\ \Omega$ szeregowo ze źródłem $E_2 = 6$ V („+” do góry).

**Metoda węzłowa** (jedno równanie):

$$\frac{V_A - 12}{2} + \frac{V_A}{4} + \frac{V_A - 6}{2} = 0 \;\Rightarrow\; 5V_A = 36 \;\Rightarrow\; V_A = 7\text{,}2\ \text{V}$$

Prądy: przez $R_1$ do węzła $(12 - 7\text{,}2)/2 = 2\text{,}4$ A; przez $R_3$ w dół $7\text{,}2/4 = 1\text{,}8$ A; przez $R_2$ w dół $(7\text{,}2 - 6)/2 = 0\text{,}6$ A. PPK: $2\text{,}4 = 1\text{,}8 + 0\text{,}6$ ✓.

**Metoda oczkowa** (dwa równania, prądy $I_a$ — lewe oczko, $I_b$ — prawe, oba zgodnie z ruchem wskazówek zegara):

$$\begin{cases} (2 + 4)I_a - 4I_b = 12 \\ -4I_a + (4 + 2)I_b = -6 \end{cases} \;\Rightarrow\; I_a = 2\text{,}4\ \text{A},\; I_b = 0\text{,}6\ \text{A}$$

W prawym oczku źródło $E_2$ działa przeciwnie do kierunku obiegu, stąd $-6$. Prąd $R_3$ = $I_a - I_b = 1\text{,}8$ A ✓ — obie metody dają ten sam wynik.

## Typowe pułapki

- **Znak źródła w metodzie oczkowej.** Sprawdź, czy obiegając oczko przechodzisz przez źródło od „−” do „+” (wymusza zgodnie) czy odwrotnie.
- **Pominięcie gałęzi wspólnej** — prąd w niej to różnica prądów oczkowych, nie jeden z nich.
- **Idealne źródło napięcia między dwoma węzłami w metodzie węzłowej** — nie da się zapisać jego prądu przez potencjały. Użyj superwęzła.
- **Za dużo równań.** Jeśli wychodzi więcej niż $n - 1$ (lub $b - n + 1$), któreś jest zależne.

## Symulacja

```spice
* 01.02 przyklad - trzy galezie
V1 1 0 12
R1 1 A 2
R3 A 0 4
R2 A 2 2
V2 2 0 6
.op
.end
```

Ćwiczenie: zapisz macierz $\mathbf{G}$ dowolnego obwodu z zadań i rozwiąż w NumPy (`np.linalg.solve`). Porównaj z wynikiem `.op`.

## Zadania

1. $E_1 = 10$ V przez $R_1 = 2$ kΩ i $E_2 = 5$ V przez $R_2 = 1$ kΩ dochodzą do wspólnego węzła; z niego $R_3 = 2$ kΩ do masy. Policz napięcie węzła i prądy (metodą węzłową).
2. Źródło prądowe 2 mA wpływa do węzła 1. Węzeł 1 — masa: $R_1 = 1$ kΩ. Węzeł 1 — węzeł 2: $R_2 = 2$ kΩ. Węzeł 2 — masa: $R_3 = 2$ kΩ. Wyznacz $V_1$ i $V_2$.
3. Rozwiąż przykład rozwiązany metodą oczkową przy $E_2 = 0$ (prawa gałąź to sam rezystor). Sprawdź metodą węzłową.
4. Idealne źródło 5 V łączy węzeł 1 („+”) z węzłem 2. Węzeł 1 — masa: 1 kΩ. Węzeł 2 — masa: 1 kΩ. Do węzła 1 wpływa prąd 10 mA ze źródła prądowego. Wyznacz $V_1$ i $V_2$ (superwęzeł).
5. Do węzła wpływa prąd 1 mA ze źródła prądowego. Z węzła do masy: rezystor 1 kΩ oraz źródło prądowe sterowane napięciem pobierające prąd $g_m V$, $g_m = 1$ mS. Wyznacz $V$ i rezystancję, jaką „widzi” źródło.
6. Obwód ma 6 gałęzi i 4 węzły. Ile równań daje metoda węzłowa, a ile oczkowa?

<details>
<summary>Odpowiedzi</summary>

1. $V = \dfrac{5 + 5}{0\text{,}5 + 1 + 0\text{,}5} = 5$ V; $I_1 = 2\text{,}5$ mA do węzła, $I_2 = 0$, $I_3 = 2\text{,}5$ mA
2. $1\text{,}5V_1 - 0\text{,}5V_2 = 2$; $-0\text{,}5V_1 + V_2 = 0$ (w kΩ i mA) → $V_1 = 1\text{,}6$ V, $V_2 = 0\text{,}8$ V
3. $I_a = 3\text{,}6$ A, $I_b = 2\text{,}4$ A, prąd $R_3$ = 1,2 A; węzłowo $V_A = 4\text{,}8$ V ✓
4. $V_1/1\text{k} + V_2/1\text{k} = 10$ mA i $V_1 - V_2 = 5$ → $V_1 = 7\text{,}5$ V, $V_2 = 2\text{,}5$ V
5. $1\ \text{mA} = V/1\text{k} + 1\ \text{mS}\cdot V$ → $V = 0\text{,}5$ V; widziana rezystancja 500 Ω (źródło sterowane zachowuje się jak rezystor $1/g_m$)
6. Węzłowa: 3, oczkowa: $6 - 4 + 1 = 3$
</details>

## Źródła

- [DC Electrical Circuit Analysis — J. M. Fiore](https://eng.libretexts.org/Bookshelves/Electrical_Engineering/Electronics/DC_Electrical_Circuit_Analysis_-_A_Practical_Approach_%28Fiore%29) — rozdziały o metodach oczkowej i węzłowej oraz źródłach sterowanych
- [Khan Academy — Node voltage method, Mesh current method](https://www.khanacademy.org/science/electrical-engineering)
- [MIT 6.002 Circuits and Electronics](https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/) — wykład o metodach analizy, zadania domowe
- [Neso Academy — Network Theory](https://www.classcentral.com/classroom/youtube-network-theory-48208) — seria o analizie węzłowej i oczkowej, superwęźle i superoczku
