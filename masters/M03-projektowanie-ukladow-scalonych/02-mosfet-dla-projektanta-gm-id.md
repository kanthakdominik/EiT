# M03.02 — Tranzystor MOS dla projektanta: metoda gm/ID

## Po co to jest

Model kwadratowy z podręczników ($I_D \propto (U_{GS} - U_T)^2$) w nowoczesnych procesach myli się o dziesiątki procent: kanały są krótkie, prędkość nośników się nasyca, a energooszczędne układy pracują w słabej i umiarkowanej inwersji, gdzie model kwadratowy w ogóle nie obowiązuje. Metoda **$g_m/I_D$** omija ten problem: projektuje się w kategoriach wielkości, które zależą od punktu pracy, ale słabo od wymiarów — stosunku transkonduktancji do prądu, częstotliwości granicznej $f_T$ i wzmocnienia własnego $g_mr_o$ — a liczby bierze się z tablic wygenerowanych symulacją modeli PDK. To dziś standard projektowania analogowego.

## Teoria w pigułce

### Zakresy pracy

| Zakres | $g_m/I_D$ | Cechy |
|---|---|---|
| Słaba inwersja (podprogowa) | Blisko maksimum $1/(nU_T) \approx 25$–30 S/A | Najlepsza sprawność prądowa, duże tranzystory, wolno |
| Umiarkowana inwersja | 10–20 S/A | Częsty kompromis w układach niskiej mocy |
| Silna inwersja | 3–10 S/A | Szybko, mało powierzchni, większy prąd |

- **Współczynnik inwersji** $IC = I_D/I_{spec}$, $I_{spec} = 2n\mu C_{ox}U_T^2\,W/L$: $IC < 0\text{,}1$ — słaba, $0\text{,}1$–10 — umiarkowana, $> 10$ — silna.
- Przybliżenie (EKV): $\dfrac{g_m}{I_D} = \dfrac{2}{nU_T\left(1 + \sqrt{1 + 4IC}\right)}$ — ciągłe od słabej do silnej inwersji.
- W silnej inwersji w modelu kwadratowym: $g_m/I_D = 2/U_{ov}$ ($U_{ov} = U_{GS} - U_T$).

### Wielkości projektowe

- $g_m/I_D$ — „sprawność” zamiany prądu na transkonduktancję.
- **$f_T \approx \dfrac{g_m}{2\pi C_{gg}}$** — szybkość; maleje z rosnącym $g_m/I_D$ i rosnącym $L$.
- **Wzmocnienie własne** $g_mr_o$ — rośnie z $L$ i z $g_m/I_D$.
- **Gęstość prądu** $I_D/W$ — z niej szerokość: $W = I_D/(I_D/W)$.
- Tablice (lookup tables) $I_D/W$, $f_T$, $g_mr_o$ w funkcji $g_m/I_D$ dla kilku długości $L$ generuje się symulacją DC w ngspice z modelami PDK (np. narzędzie pygmid); wynik nie zależy od $W$ (dla $W$ znacznie większego od minimalnego).

### Procedura

1. Ze specyfikacji wyznacz potrzebne $g_m$ (np. $GBW = g_m/(2\pi C_L)$, szum $\propto 1/g_m$).
2. Wybierz $g_m/I_D$ (kompromis prąd–szybkość) i $L$ (kompromis wzmocnienie–szybkość–powierzchnia).
3. $I_D = g_m/(g_m/I_D)$; $W = I_D/(I_D/W)$ z tablicy.
4. Sprawdź $f_T$ (biegun pasożytniczy znacznie powyżej $GBW$), wzmocnienie, zakres napięć (napięcie nasycenia $U_{DS,sat} \approx 2/(g_m/I_D)$ w silnej inwersji, ok. 4–5 $U_T$ w słabej).

### Efekty krótkiego kanału (dlaczego model kwadratowy zawodzi)

Nasycenie prędkości (prąd bliższy liniowemu w $U_{ov}$), DIBL (napięcie progowe maleje z $U_{DS}$), modulacja długości kanału (mała $r_o$ przy minimalnym $L$), degradacja ruchliwości w silnym polu, efekty bliskości studni i naprężeń (zależność od położenia w layoucie).

## Przykład rozwiązany

**Potrzebne $g_m = 1$ mS** (np. dla GBW 160 MHz przy 1 pF), przykładowy NMOS z $\mu C_{ox} = 270$ µA/V², $n = 1\text{,}3$ ($I_{spec}$ = 0,47 µA dla $W/L = 1$):

| $g_m/I_D$ | $I_D$ | $IC$ | $W/L$ |
|---|---|---|---|
| 25 S/A | 40 µA | 0,23 | 377 |
| 15 S/A | 67 µA | 1,95 | 73 |
| 8 S/A | 125 µA | 10,1 | 26 |

Przy $g_m/I_D = 25$ (słaba inwersja) prąd jest najmniejszy, ale tranzystor 14 razy większy niż przy 8 S/A — jego pojemności obniżają $f_T$ i mogą ograniczyć pasmo. Wybór 12–16 S/A to częsty kompromis dla stopni wejściowych wzmacniaczy.

## Typowe pułapki

- **Model kwadratowy w procesie 130 nm i poniżej** — błędy prądu i $g_m$ o kilkadziesiąt procent; używaj tablic z PDK.
- **Minimalna długość kanału w obwodach analogowych** — małe wzmocnienie, duży rozrzut; typowo $L$ = 2–5 × minimum.
- **Ignorowanie efektu ciała** (napięcie źródło–podłoże) — przesuwa $U_T$; w SKY130 tranzystory w osobnej studni pozwalają go uniknąć dla PMOS.
- **Projektowanie bez zapasu napięć** — tranzystor w zakresie triodowym przy skrajnych sygnałach lub narożniku SS.
- **Tablice $g_m/I_D$ z innego narożnika lub temperatury** niż sprawdzane w końcowej weryfikacji.

## Ćwiczenie komputerowe

$g_m/I_D$ w funkcji współczynnika inwersji (przybliżenie EKV) i dobór $I_D$ oraz $W/L$ dla zadanego $g_m$:

```python
import numpy as np

n, UT = 1.3, 0.02585
muCox = 270e-6                                         # A/V² (przykładowy NMOS; odczytaj z PDK)
I_spec_sq = 2*n*muCox*UT**2                            # prąd specyficzny na „kwadrat” W/L = 1

def gm_id(IC):
    return 2/(n*UT*(1 + np.sqrt(1 + 4*IC)))            # przybliżenie EKV, ważne od słabej do silnej inwersji

for IC in (0.01, 0.1, 1, 10, 100):
    print(f"IC = {IC:6.2f}: gm/ID = {gm_id(IC):5.1f} S/A")
print(f"granica słabej inwersji 1/(n·UT) = {1/(n*UT):.1f} S/A; I_spec(W/L = 1) = {I_spec_sq*1e6:.3f} µA")

# projekt: potrzebne gm = 1 mS przy gm/ID = 15 S/A
gm_req, target = 1e-3, 15.0
ID = gm_req/target
x = 2/(target*n*UT)                                    # = 1 + sqrt(1 + 4 IC)
IC = ((x - 1)**2 - 1)/4
WL = ID/(IC*I_spec_sq)
print(f"gm/ID = {target}: ID = {ID*1e6:.1f} µA, IC = {IC:.2f}, W/L = {WL:.0f}")
# kompromis: duże gm/ID = mały prąd, ale duży tranzystor (pojemności, wolniej); małe gm/ID = szybciej, więcej prądu
for t in (25, 15, 8):
    x = 2/(t*n*UT); IC_ = ((x - 1)**2 - 1)/4
    print(f"gm/ID = {t:2d} S/A: ID = {gm_req/t*1e6:6.1f} µA, IC = {IC_:6.2f}, W/L = {gm_req/t/(IC_*I_spec_sq):7.1f}")
```

Ćwiczenie z PDK: w kontenerze IIC-OSIC-TOOLS wygeneruj tablice $g_m/I_D$ (np. pygmid z dokumentacji IHP) dla NMOS i PMOS przy kilku $L$ i powtórz dobór — porównaj z przybliżeniem EKV.

## Zadania

1. Ile wynosi $g_m/I_D$ w modelu kwadratowym przy $U_{ov} = 0\text{,}2$ V? Jaki to zakres pracy?
2. Wzmacniacz potrzebuje $g_m = 500$ µS przy prądzie nie większym niż 30 µA. Czy to możliwe? W jakim zakresie pracy?
3. Dlaczego zwiększenie $L$ przy stałym $g_m/I_D$ zwiększa wzmocnienie, ale zmniejsza $f_T$?
4. Ile wynosi przybliżone napięcie nasycenia $U_{DS,sat}$ tranzystora w słabej inwersji?
5. Dla $IC = 1$ i $n = 1\text{,}3$ policz $g_m/I_D$.

<details>
<summary>Odpowiedzi</summary>

1. $2/0\text{,}2 = 10$ S/A — granica umiarkowanej i silnej inwersji (model kwadratowy jest tu już niedokładny)
2. Potrzebne $g_m/I_D \geq 500/30 = 16\text{,}7$ S/A — możliwe w umiarkowanej inwersji (maksimum ok. 29 S/A), kosztem dużego tranzystora
3. Dłuższy kanał: mniejsza modulacja długości kanału (większe $r_o$, $g_mr_o$), ale przy tym samym $g_m/I_D$ większa powierzchnia bramki ($C_{gg} \propto WL$, a $W$ rośnie proporcjonalnie do $L$) — $f_T \propto 1/L^2$ (silna inwersja) lub $\propto 1/L$ przy nasyceniu prędkości
4. Ok. 4–5 $U_T$ ≈ 0,1–0,13 V
5. $2/(1\text{,}3\cdot 0\text{,}02585\cdot(1 + \sqrt5)) = 18\text{,}4$ S/A
</details>

## Źródła

- [IHP Open PDK — projektowanie z pygmid](https://ihp-open-pdk-docs.readthedocs.io/en/main/analog/pygmid.html)
- [MIT 6.012 Microelectronic Devices and Circuits](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-spring-2009/) — MOSFET, model małosygnałowy
- P. Jespers, B. Murmann — *Systematic Design of Analog CMOS Circuits* (płatna)
- [03.07 Model MOSFET](../../modules/03-przyrzady-polprzewodnikowe/07-mosfet-model-i-klucz.md)
