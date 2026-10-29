# 11.05 — Stany nieustalone na liniach i integralność sygnałów

## Po co to jest

Sygnały cyfrowe o szybkich zboczach (zegary, magistrale pamięci, USB, Ethernet, a nawet szybki GPIO) zachowują się na ścieżkach jak fale na liniach. Niedopasowanie daje odbicia, „schodki”, przerzuty i dzwonienie, które powodują błędne przełączenia, przekroczenie dopuszczalnych napięć i promieniowanie zakłóceń. Wykres odbić pozwala to przewidzieć, a reflektometr (TDR) — zmierzyć.

## Teoria w pigułce

### Skok napięcia na linii

Źródło $V_S$ z rezystancją $R_S$ dołączone do linii $Z_0$ o czasie propagacji $t_d$, obciążonej $R_L$:

1. W chwili 0 linia „wygląda” jak rezystor $Z_0$: w linię wchodzi fala $V_1 = V_S\dfrac{Z_0}{R_S + Z_0}$.
2. Po czasie $t_d$ fala dociera do obciążenia i odbija się z $\Gamma_L = \dfrac{R_L - Z_0}{R_L + Z_0}$.
3. Fala odbita wraca do źródła i odbija się z $\Gamma_S = \dfrac{R_S - Z_0}{R_S + Z_0}$.
4. Napięcie w każdym punkcie to suma wszystkich fal, które do niego dotarły. Stan ustalony: dzielnik $V_SR_L/(R_S + R_L)$.

**Wykres odbić (bounce/lattice diagram):** oś pozioma — położenie, pionowa — czas, linie ukośne — kolejne fale z ich amplitudami.

### Kiedy linia jest „długa”

Gdy czas propagacji jest porównywalny z czasem narastania zbocza $t_r$. Reguła praktyczna: efekty linii trzeba uwzględnić, gdy $t_d > t_r/6$ (ostrożnie) do $t_r/4$ — źródła podają różne progi. **Liczy się czas narastania, nie częstotliwość zegara:** wolny zegar 1 MHz z buforem o zboczu 1 ns ma te same problemy z odbiciami co zegar 100 MHz. Prędkość na FR-4: ok. 15–17 cm/ns (mikropasek), ok. 14–15 cm/ns (linia paskowa wewnątrz płytki). Pasmo sygnału cyfrowego: $f_{knee} \approx 0\text{,}35/t_r$ – $0\text{,}5/t_r$.

### Terminacja

| Rodzaj | Układ | Zalety | Wady |
|---|---|---|---|
| **Szeregowa** | $R_S + R_{wy} = Z_0$ przy nadajniku | Brak poboru mocy DC, jeden rezystor | Na linii przez $2t_d$ połowa napięcia — tylko dla odbiornika na końcu (topologia punkt–punkt) |
| **Równoległa** | $R = Z_0$ do masy na końcu | Czysty sygnał wzdłuż linii | Duży prąd DC |
| Thévenina | Dwa rezystory do zasilania i masy | Ustala poziom spoczynkowy | Prąd DC |
| **AC (RC)** | $R = Z_0$ szeregowo z C na końcu | Brak prądu DC | Dobór C; opóźnienie |
| Różnicowa | $R = Z_{diff}$ między liniami | Standard dla LVDS, USB, Ethernet, CAN | — |

### Reflektometria (TDR)

Skok napięcia wysłany w linię i obserwacja napięcia na jej wejściu: poziom po odbiciu mówi o impedancji ($Z = Z_0\dfrac{1 + \rho}{1 - \rho}$, $\rho$ — zmierzony współczynnik odbicia), czas — o miejscu nieciągłości ($x = v\,t/2$). Tak lokalizuje się uszkodzenia kabli i ocenia ścieżki na płytkach.

## Przykład rozwiązany

$V_S = 1$ V (skok), $R_S = 25\ \Omega$, $Z_0 = 50\ \Omega$, $t_d = 1$ ns, koniec rozwarty ($R_L = \infty$).

1. $V_1 = 1\cdot 50/75 = 0\text{,}667$ V, $\Gamma_L = 1$, $\Gamma_S = -1/3$.
2. Napięcie na końcu linii:

| Czas | Nowe fale | $V_{koniec}$ |
|---|---|---|
| 0–1 ns | — | 0 |
| 1 ns | $0\text{,}667 + 0\text{,}667$ | **1,333 V** (przerzut 33%) |
| 3 ns | $-0\text{,}222 - 0\text{,}222$ | 0,889 V |
| 5 ns | $+0\text{,}074 + 0\text{,}074$ | 1,037 V |
| 7 ns | $-0\text{,}025 - 0\text{,}025$ | 0,988 V |
| → | | 1 V |

3. Dzwonienie z okresem $4t_d$, zanikające jak $|\Gamma_S|^n$. Gdyby odbiornik miał próg 1,2 V dla „przekroczenia maksimum” lub zabezpieczenia diodowe, przerzut 1,33 V wymaga uwagi.
4. Poprawka: rezystor szeregowy 25 Ω przy nadajniku ($R_S$ = 50 Ω): $V_1 = 0\text{,}5$ V, na końcu od razu 1 V, $\Gamma_S = 0$ — koniec dzwonienia.

## Typowe pułapki

- **Ocena „linia/nie linia” po częstotliwości zegara** zamiast po czasie narastania.
- **Terminacja szeregowa przy wielu odbiornikach wzdłuż linii** — odbiorniki pośrodku widzą schodek o połowie napięcia.
- **Długie odgałęzienia (stub) do odbiorników** — dodatkowe odbicia.
- **Przelotki, złącza i zmiany szerokości ścieżki** — każda zmiana impedancji to nieciągłość.
- **Pomiar sondą z długim przewodem masy** — dzwonienie pochodzące od sondy ([08.03](../08-miernictwo/03-oscyloskop.md)).

## Symulacja

Wykres odbić z przykładu w LTspice:

```spice
* Odbicia na linii: Rs=25, Z0=50, Td=1n, koniec rozwarty
V1 src 0 PULSE(0 1 0 50p 50p 20n 40n)
Rs src in 25
T1 in 0 out 0 Td=1n Z0=50
RL out 0 1G
.tran 0 12n 0 5p
* Obserwuj V(in) i V(out). Zmien Rs na 50 (terminacja szeregowa)
* albo RL na 50 (terminacja rownolegla) i porownaj.
.end
```

## Ćwiczenie komputerowe

Wykres odbić liczony metodą sumowania fal (dowolne rezystancje źródła i obciążenia, skończony czas narastania):

```python
import numpy as np
import matplotlib.pyplot as plt

def bounce(Vs, Rs, Z0, RL, td, t, tr=0.1e-9, nmax=40):
    GS, GL = (Rs - Z0)/(Rs + Z0), (RL - Z0)/(RL + Z0)
    step = lambda t: np.clip(t/tr, 0, 1)            # zbocze liniowe o czasie tr
    V1 = Vs*Z0/(Rs + Z0)
    vin, vout = V1*step(t), np.zeros_like(t)
    a = V1
    for n in range(nmax):
        vout += a*(1 + GL)*step(t - (2*n + 1)*td)   # fala dociera do końca
        a *= GL
        vin += a*(1 + GS)*step(t - (2*n + 2)*td)    # fala odbita wraca do źródła
        a *= GS
    return vin, vout

t = np.linspace(0, 12e-9, 3000)
for Rs, RL in [(25, 1e12), (50, 1e12), (10, 1e12), (25, 50)]:
    vin, vout = bounce(1, Rs, 50, RL, 1e-9, t)
    plt.plot(t*1e9, vout, label=f'Rs={Rs}, RL={"∞" if RL > 1e9 else RL}')
    print(f"Rs={Rs:>3}, RL={RL:.0e}: max V_out = {vout.max():.3f} V")
plt.xlabel('t [ns]'); plt.ylabel('V_out [V]'); plt.legend(); plt.grid(); plt.show()
```

## Zadania

1. Narysuj wykres odbić dla $R_S = 10\ \Omega$, $Z_0 = 50\ \Omega$, koniec rozwarty, $V_S = 3\text{,}3$ V. Jakie jest maksymalne napięcie na końcu?
2. Ścieżka mikropaskowa ma 20 cm, prędkość 16 cm/ns. Bufor ma czas narastania 1 ns. Czy potrzebna jest terminacja?
3. Wyjście bufora ma rezystancję 15 Ω, linia 50 Ω. Dobierz rezystor terminacji szeregowej.
4. TDR pokazuje po 4 ns od wysłania skoku spadek poziomu z 0,5 V do 0,3 V (generator 1 V, 50 Ω, kabel 50 Ω, $v = 0\text{,}66c$). Gdzie jest nieciągłość i jaką ma impedancję?
5. Dlaczego terminacja szeregowa nie nadaje się do magistrali z kilkoma odbiornikami rozłożonymi wzdłuż ścieżki?

<details>
<summary>Odpowiedzi</summary>

1. $V_1 = 3\text{,}3\cdot 50/60 = 2\text{,}75$ V, $\Gamma_S = -2/3$; na końcu: 5,5 V po $t_d$, potem $5\text{,}5 - 2\cdot 1\text{,}833 = 1\text{,}83$ V, potem $1\text{,}83 + 2\cdot 1\text{,}22 = 4\text{,}28$ V… — maksimum 5,5 V (przerzut 67%), dzwonienie wolno zanika
2. $t_d = 1\text{,}25$ ns > $t_r/6$ — tak, to linia długa
3. $50 - 15 = 35\ \Omega$ (najbliższa wartość z szeregu, np. 33 Ω)
4. $x = v\,t/2 = 0\text{,}66\cdot 3\cdot 10^8\cdot 4\cdot 10^{-9}/2 \approx 0\text{,}40$ m; $\rho = (0\text{,}3 - 0\text{,}5)/0\text{,}5 = -0\text{,}4$ → $Z = 50\cdot 0\text{,}6/1\text{,}4 \approx 21\ \Omega$
5. Fala biegnąca ma połowę amplitudy; pełne napięcie pojawia się w danym punkcie dopiero po powrocie odbicia od końca — odbiorniki pośrodku przez pewien czas widzą poziom ok. 50%, w obszarze niezdefiniowanym logicznie
</details>

## Źródła

- [Electromagnetics, Vol. 1 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-1) — stany nieustalone na liniach (rozdział o liniach transmisyjnych)
- [Falstad — symulator obwodów (przykłady linii transmisyjnych)](https://falstad.com/circuit/e-index.html) — animowane odbicia
- [Lessons in Electric Circuits, tom II — Transmission Lines](https://www.allaboutcircuits.com/textbook/) — fale stojące i odbicia
- H. Johnson, M. Graham — *High-Speed Digital Design* (książka płatna, klasyka integralności sygnałów)
