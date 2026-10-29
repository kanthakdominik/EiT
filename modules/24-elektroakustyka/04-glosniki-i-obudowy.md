# 24.04 — Głośniki i obudowy

## Po co to jest

Głośnik jest najsłabszym ogniwem toru audio: ma sprawność poniżej 1%, charakterystykę daleką od płaskiej, impedancję zmienną z częstotliwością i zniekształcenia o rzędy wielkości większe niż elektronika. Obudowa decyduje o tym, jak nisko zagra głośnik niskotonowy. Model Thiele'a–Smalla zamienia głośnik w obudowie w filtr górnoprzepustowy, który można policzyć jak każdy obwód RLC ([01 Teoria obwodów](../01-teoria-obwodow/)).

## Teoria w pigułce

### Głośnik elektrodynamiczny

Cewka w szczelinie magnesu, siła $F = Bl\,i$ ($Bl$ — współczynnik siły), membrana z zawieszeniem tworzy układ masa–sprężyna z rezonansem $f_s$. Schemat zastępczy: rezystancja cewki $R_e$, indukcyjność $L_e$, a strona mechaniczna i akustyczna przeniesiona na stronę elektryczną jako obwód równoległy RLC — stąd **szczyt impedancji przy $f_s$** (np. 8 Ω → 40 Ω).

### Parametry Thiele'a–Smalla (najważniejsze)

| Parametr | Znaczenie |
|---|---|
| $f_s$ | Częstotliwość rezonansowa w swobodnej przestrzeni |
| $Q_{es}$, $Q_{ms}$, $Q_{ts}$ | Dobroć elektryczna, mechaniczna, całkowita: $Q_{ts} = Q_{es}Q_{ms}/(Q_{es} + Q_{ms})$ |
| $V_{as}$ | Objętość powietrza o tej samej podatności co zawieszenie |
| $R_e$, $L_e$, $Bl$, $S_d$, $X_{max}$ | Rezystancja i indukcyjność cewki, współczynnik siły, powierzchnia membrany, maksymalne wychylenie |

### Czułość i moc

- **Czułość** w dB SPL przy 2,83 V (1 W na 8 Ω) w odległości 1 m: typowo 84–92 dB.
- Poziom przy mocy $P$: $L = L_{1W} + 10\log_{10}P$ — 50 W daje tylko +17 dB.
- **Sprawność:** $L_{1W,1m} \approx 112 + 10\log_{10}\eta$ dB (promieniowanie w półprzestrzeń) — 88 dB to $\eta \approx 0\text{,}4\%$. Reszta mocy zamienia się w ciepło w cewce (kompresja mocy przy wzroście jej rezystancji z temperaturą).

### Obudowa zamknięta

Powietrze w obudowie o objętości $V_b$ usztywnia zawieszenie: $\alpha = V_{as}/V_b$,

$$f_c = f_s\sqrt{1 + \alpha}, \qquad Q_{tc} = Q_{ts}\sqrt{1 + \alpha}$$

Charakterystyka: filtr górnoprzepustowy 2. rzędu o częstotliwości $f_c$ i dobroci $Q_{tc}$ (−12 dB/okt. poniżej $f_c$). $Q_{tc} = 0\text{,}707$ — Butterworth (płaska), 0,5 — krytycznie tłumiona, > 1 — podbicie i „dudnienie”.

### Inne obudowy

- **Bas-refleks:** otwór z tunelem (rezonator Helmholtza) — głębszy bas z tego samego głośnika, ale filtr 4. rzędu (−24 dB/okt.), gorsza odpowiedź impulsowa.
- **Obudowa otwarta, linia transmisyjna, tuba** — rzadsze; tuba zwiększa sprawność (nagłośnienie).
- **Dyfrakcja na krawędziach** obudowy i **przejście z promieniowania w półprzestrzeń do pełnej przestrzeni** (baffle step, ok. 6 dB) przy częstotliwości, dla której długość fali jest porównywalna z szerokością przedniej ścianki.

## Przykład rozwiązany

**Obudowa zamknięta dla głośnika:** $f_s = 40$ Hz, $Q_{ts} = 0\text{,}35$, $V_{as} = 50$ l; cel $Q_{tc} = 0\text{,}707$.

1. $\sqrt{1 + \alpha} = Q_{tc}/Q_{ts} = 2\text{,}02$ → $\alpha = 3\text{,}08$.
2. $V_b = V_{as}/\alpha = 16\text{,}2$ l (objętość netto — bez głośnika, wzmocnień i z korektą na materiał tłumiący).
3. $f_c = 40\cdot 2\text{,}02 = 80\text{,}8$ Hz — dla $Q_{tc} = 0\text{,}707$ to także częstotliwość −3 dB.
4. Większa obudowa (np. 48 l, $Q_{tc} = 0\text{,}5$) obniży $f_c$ do ok. 57 Hz, ale charakterystyka opada łagodniej i wcześniej — spadek −3 dB przy ok. 89 Hz (kod niżej).

**Poziom:** głośnik 88 dB/2,83 V/1 m, wzmacniacz 50 W na 8 Ω: $88 + 17 = 105$ dB w 1 m, ok. 95,5 dB w 3 m — w pomieszczeniu więcej (odbicia, temat 08).

## Typowe pułapki

- **Zbyt mała obudowa** „żeby zmieścić” — duże $Q_{tc}$, podbity, dudniący bas przy $f_c$.
- **Głośnik z dużym $Q_{ts}$ (> 0,6) w obudowie zamkniętej** — nadaje się raczej do obudowy otwartej lub dużej.
- **Moc wzmacniacza „na wyrost”** — 10 razy więcej mocy to tylko +10 dB, a granicą jest często $X_{max}$ (wychylenie przy niskich częstotliwościach), nie moc cieplna.
- **Pomijanie szczytu impedancji** przy zwrotnicy pasywnej i stabilności wzmacniacza.
- **Brak wytłumienia i usztywnienia** — rezonanse ścianek i fale stojące wewnątrz.

## Ćwiczenie komputerowe

Charakterystyka niskotonowa obudowy zamkniętej dla kilku objętości:

```python
import numpy as np

fs, Qts, Vas = 40.0, 0.35, 50.0
f = np.logspace(np.log10(10), np.log10(1000), 4000)

def closed_box(Vb):
    a = Vas/Vb
    fc, Qtc = fs*np.sqrt(1 + a), Qts*np.sqrt(1 + a)
    x = f/fc
    H = x**2/np.sqrt((1 - x**2)**2 + (x/Qtc)**2)          # moduł HP 2. rzędu
    return fc, Qtc, 20*np.log10(H)

for Vb in (8, 16.2, 48):
    fc, Qtc, H = closed_box(Vb)
    f3 = f[np.argmax(H > -3)]
    print(f"V_b = {Vb:5.1f} l: f_c = {fc:5.1f} Hz, Q_tc = {Qtc:.3f}, przewyższenie {H.max():+.1f} dB, f_-3dB = {f3:5.1f} Hz")

# sprawność z czułości
for L in (84, 88, 92, 100):
    print(f"czułość {L} dB/1W/1m → sprawność ≈ {10**((L - 112)/10)*100:.2f}%")
```

## Zadania

1. Głośnik ma $Q_{es} = 0\text{,}4$ i $Q_{ms} = 4$. Ile wynosi $Q_{ts}$?
2. Ile wynosi poziom w 2 m od głośnika 86 dB/1 W/1 m zasilanego mocą 20 W?
3. Głośnik $f_s = 30$ Hz, $Q_{ts} = 0\text{,}4$, $V_{as} = 80$ l. Jaka obudowa zamknięta daje $Q_{tc} = 0\text{,}707$ i jakie $f_c$?
4. Dlaczego przy niskich częstotliwościach ograniczeniem jest wychylenie membrany, a nie moc?
5. Co dzieje się z impedancją głośnika przy $f_s$ i dlaczego ma to znaczenie dla zwrotnicy pasywnej?

<details>
<summary>Odpowiedzi</summary>

1. $0\text{,}4\cdot 4/4\text{,}4 = 0\text{,}364$
2. $86 + 13 - 6 = 93$ dB
3. $\sqrt{1 + \alpha} = 1\text{,}77$ → $\alpha = 2\text{,}12$, $V_b = 37\text{,}7$ l; $f_c = 53$ Hz
4. Do wytworzenia tego samego ciśnienia przy częstotliwości 2 razy niższej potrzebne jest 4 razy większe wychylenie (objętość przesunięta ∝ $1/f^2$ dla stałego ciśnienia w polu dalekim); granica $X_{max}$ jest osiągana wcześniej niż granica cieplna
5. Rośnie kilkukrotnie (np. do 30–50 Ω) — zwrotnica pasywna zaprojektowana dla 8 Ω „widzi” inne obciążenie, charakterystyka filtru się zmienia; stosuje się układy korekcji impedancji (szeregowe RLC równolegle do głośnika)
</details>

## Źródła

- [Elliott Sound Products (spis artykułów)](https://sound-au.com/site-map.htm) — parametry Thiele'a–Smalla, obudowy
- [Linkwitz Lab — Crossovers](https://linkwitzlab.com/crossovers.htm) — dyfrakcja, baffle step, projektowanie zestawów
- V. Dickason — *The Loudspeaker Design Cookbook* (płatna)
