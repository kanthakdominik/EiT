# 01.01 — Podstawowe pojęcia i prawa

## Po co to jest

Prawo Ohma i prawa Kirchhoffa to cała teoria obwodów w pigułce — wszystkie metody analizy (węzłowa, oczkowa, twierdzenia) są tylko sposobami ich systematycznego stosowania. Błąd w konwencji strzałkowania tutaj mści się w każdym kolejnym temacie.

## Teoria w pigułce

### Wielkości

| Wielkość | Definicja | Jednostka |
|---|---|---|
| Prąd | $i = \dfrac{dq}{dt}$ | A |
| Napięcie | Praca na jednostkę ładunku między dwoma punktami | V |
| Moc | $p = u\cdot i$ | W |
| Energia | $w = \int p\,dt$ | J (lub Wh) |

### Elementy idealne

| Element | Równanie | Zachowanie w stanie ustalonym DC |
|---|---|---|
| Rezystor | $u = Ri$ | Rezystancja |
| Kondensator | $i = C\dfrac{du}{dt}$ | Przerwa |
| Cewka | $u = L\dfrac{di}{dt}$ | Zwarcie |
| Idealne źródło napięcia | $u = E$ niezależnie od prądu | — |
| Idealne źródło prądu | $i = J$ niezależnie od napięcia | — |

Źródło rzeczywiste napięcia = idealne źródło $E$ + szeregowa rezystancja wewnętrzna $R_w$.

### Konwencje strzałkowania

- **Odbiornikowa** (dla R, L, C): strzałka prądu i strzałka napięcia skierowane **przeciwnie** (prąd wpływa do zacisku „+”). Wtedy $p = ui > 0$ oznacza moc pobieraną.
- **Źródłowa** (dla źródeł): strzałki **zgodne**. $p = ui > 0$ oznacza moc oddawaną.

Kierunki strzałek wybiera się dowolnie. Ujemny wynik oznacza tylko, że rzeczywisty zwrot jest przeciwny.

### Prawa Kirchhoffa

- **Prądowe (PPK):** suma prądów wpływających do węzła równa się sumie prądów wypływających — $\sum i = 0$. Wynika z zasady zachowania ładunku.
- **Napięciowe (NPK):** suma napięć w zamkniętym oczku równa się zeru — $\sum u = 0$. Wynika z potencjalności pola elektrostatycznego.

### Łączenie elementów

| | Szeregowo | Równolegle |
|---|---|---|
| Rezystory | $R = R_1 + R_2$ | $R = \dfrac{R_1 R_2}{R_1 + R_2}$ |
| Kondensatory | $\dfrac{1}{C} = \dfrac{1}{C_1} + \dfrac{1}{C_2}$ | $C = C_1 + C_2$ |
| Cewki (niesprzężone) | $L = L_1 + L_2$ | $\dfrac{1}{L} = \dfrac{1}{L_1} + \dfrac{1}{L_2}$ |

**Dzielnik napięcia:** $U_2 = U\dfrac{R_2}{R_1 + R_2}$ — tylko bez obciążenia (lub gdy obciążenie wliczono do $R_2$).
**Dzielnik prądu:** $I_1 = I\dfrac{R_2}{R_1 + R_2}$ — prąd w gałęzi jest proporcjonalny do rezystancji **drugiej** gałęzi.

## Przykład rozwiązany

$E = 12$ V zasila $R_1 = 2$ kΩ połączony szeregowo z równoległym układem $R_2 = 6$ kΩ i $R_3 = 3$ kΩ. Wyznacz wszystkie prądy i sprawdź bilans mocy.

1. $R_{23} = \dfrac{6\cdot 3}{6 + 3} = 2$ kΩ, $R_z = 2 + 2 = 4$ kΩ.
2. $I = \dfrac{12}{4\ \text{k}\Omega} = 3$ mA.
3. $U_{23} = 3\ \text{mA}\cdot 2\ \text{k}\Omega = 6$ V.
4. $I_2 = \dfrac{6}{6\ \text{k}} = 1$ mA, $I_3 = \dfrac{6}{3\ \text{k}} = 2$ mA (PPK: $1 + 2 = 3$ ✓).
5. Bilans: $P_E = 12\cdot 3 = 36$ mW; $P_{R1} = 18$ mW, $P_{R2} = 6$ mW, $P_{R3} = 12$ mW; suma 36 mW ✓.

## Typowe pułapki

- **Dzielnik napięcia z pominiętym obciążeniem.** Obciążenie zmienia wynik — patrz zadanie 1.
- **Odwrócony dzielnik prądu** — prąd gałęzi liczony z jej własnej rezystancji zamiast z rezystancji drugiej gałęzi.
- **Zmiana konwencji w połowie zadania.** Ustal strzałki na schemacie na początku i trzymaj się ich.
- **„Równolegle” i „szeregowo” rozpoznawane z rysunku, a nie z węzłów.** Elementy są równoległe tylko wtedy, gdy łączą tę samą parę węzłów.
- **Bilans mocy pominięty.** To najszybszy test poprawności całego rozwiązania.

## Symulacja

Netlista dla LTspice lub ngspice (zapisz jako `przyklad.cir`, w LTspice: File → Open):

```spice
* 01.01 przyklad - dzielnik z rozgalezieniem
V1 1 0 12
R1 1 2 2k
R2 2 0 6k
R3 2 0 3k
.op
.end
```

Po uruchomieniu `.op` sprawdź napięcie węzła 2 i prądy rezystorów. W [Falstad](https://www.falstad.com/circuit/) zbuduj ten sam obwód — animacja pokazuje rozpływ prądu w węźle.

## Zadania

1. Dzielnik: 12 V, $R_1 = R_2 = 10$ kΩ, obciążenie $R_L = 10$ kΩ równolegle do $R_2$. Jakie jest napięcie na obciążeniu? Ile wynosiłoby bez obciążenia?
2. Prąd 6 mA rozpływa się na $R_1 = 1$ kΩ i $R_2 = 2$ kΩ połączone równolegle. Wyznacz prądy gałęzi.
3. Wyznacz rezystancję zastępczą: $R_1 = 4\ \Omega$ szeregowo z układem równoległym ($R_2 = 6\ \Omega$) ∥ ($R_3 = 2\ \Omega$ szeregowo z $R_4 = 10\ \Omega$).
4. Rezystor 1 kΩ ma moc dopuszczalną 0,25 W. Jakie jest maksymalne napięcie, które można na nim wydzielić?
5. Bateria 9 V o rezystancji wewnętrznej 1 Ω zasila obciążenie 8 Ω. Wyznacz prąd, napięcie na zaciskach, moc w obciążeniu i sprawność.
6. W oczku znajdują się: źródło 10 V, rezystor $R_1$ z napięciem 4 V i rezystor $R_2$. Jakie jest napięcie na $R_2$? Jak zmieni się odpowiedź, jeśli zwrot strzałki $U_{R2}$ narysujesz odwrotnie?
7. Akumulator 3,7 V, 2000 mAh zasila urządzenie pobierające 50 mA. Ile godzin będzie pracować i jaka energia jest zgromadzona?

<details>
<summary>Odpowiedzi</summary>

1. $R_2\parallel R_L = 5$ kΩ → 4 V; bez obciążenia 6 V
2. $I_1 = 6\cdot\dfrac{2}{3} = 4$ mA, $I_2 = 2$ mA
3. $(2 + 10) = 12\ \Omega$; $6\parallel 12 = 4\ \Omega$; $R_z = 4 + 4 = 8\ \Omega$
4. $U = \sqrt{PR} = \sqrt{250} \approx 15\text{,}8$ V
5. $I = 1$ A, $U = 8$ V, $P = 8$ W, $\eta = 8/9 \approx 89\%$
6. 6 V; przy odwróconej strzałce wynik −6 V — to ta sama fizyczna sytuacja
7. 40 h; $W = 3\text{,}7\ \text{V}\cdot 2\ \text{Ah} = 7\text{,}4$ Wh ≈ 26,6 kJ
</details>

## Źródła

- [DC Electrical Circuit Analysis — J. M. Fiore](https://eng.libretexts.org/Bookshelves/Electrical_Engineering/Electronics/DC_Electrical_Circuit_Analysis_-_A_Practical_Approach_%28Fiore%29) — rozdziały o połączeniach szeregowych, równoległych i mieszanych, prawach Kirchhoffa
- [Khan Academy — Circuit analysis](https://www.khanacademy.org/science/electrical-engineering) — filmy: elementy idealne, konwencja znaków, prawa Kirchhoffa, dzielnik napięcia
- [All About Circuits — tom DC](https://www.allaboutcircuits.com/textbook/)
- [Neso Academy — Network Theory](https://www.classcentral.com/classroom/youtube-network-theory-48208) — seria *Basics of Network Theory* z rozwiązanymi zadaniami
