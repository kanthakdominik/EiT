# M04.04 — Dzielniki mocy i sprzęgacze

## Po co to jest

Szyk antenowy trzeba zasilić z jednego nadajnika — dzielnik rozdziela moc na wiele anten. Odbiornik kwadraturowy potrzebuje sygnałów przesuniętych o 90° — robi to sprzęgacz hybrydowy. Wzmacniacz zrównoważony, mieszacz zrównoważony, pomiar mocy odbitej (sprzęgacz kierunkowy), łączenie mocy kilku wzmacniaczy — wszędzie potrzebne są układy wielowrotowe z dobrą izolacją między portami. Najważniejsze z nich da się zbudować z kilku odcinków λ/4 i jednego rezystora.

## Teoria w pigułce

### Ograniczenia podstawowe

Trójwrotnik bezstratny, wzajemny i dopasowany na wszystkich portach **nie istnieje** — stąd: rozgałęzienie T (bezstratne, niedopasowane na wyjściach, brak izolacji) albo **dzielnik Wilkinsona** (z rezystorem: dopasowany i z izolacją, kosztem strat przy niezrównoważonym pobudzeniu wyjść).

### Dzielnik Wilkinsona (równy podział)

- Dwa odcinki λ/4 o impedancji $\sqrt2Z_0 = 70\text{,}7$ Ω z portu wejściowego do wyjść, rezystor $2Z_0 = 100$ Ω między wyjściami.
- Przy $f_0$: $S_{21} = S_{31} = -j/\sqrt2$ (−3 dB, w fazie), $S_{11} = S_{22} = S_{33} = 0$, $S_{23} = 0$ (izolacja).
- Analiza metodą pobudzenia parzystego i nieparzystego: przy pobudzeniu parzystym (równe sygnały na wyjściach) przez rezystor nie płynie prąd; przy nieparzystym rezystor jest dopasowanym obciążeniem.
- Pasmo: dla jednej sekcji ok. ±20% przy izolacji i dopasowaniu −20 dB; wiele sekcji — szersze.
- Wersje: nierówny podział, N-wyjściowy (gwiazda rezystorów).

### Sprzęgacze

| Sprzęgacz | Budowa | Wyjścia |
|---|---|---|
| **Gałęziowy (branch-line, hybryda 90°)** | Kwadrat z odcinków λ/4: dwa o $Z_0/\sqrt2$, dwa o $Z_0$ | −3 dB, przesunięcie 90°, izolowany port; wąskopasmowy (~10%) |
| **Pierścieniowy (rat-race, hybryda 180°)** | Pierścień 1,5λ, $\sqrt2Z_0$ | Wyjścia w fazie lub w przeciwfazie (Σ/Δ) |
| **Na liniach sprzężonych** | Dwa równoległe odcinki λ/4 | Sprzężenie słabe (10–30 dB) — sprzęgacze kierunkowe; mod parzysty i nieparzysty |
| Lange | Przeplatane linie sprzężone | Sprzężenie 3 dB, szerokie pasmo (MMIC) |

Parametry sprzęgacza kierunkowego: sprzężenie $C = -20\log\lvert S_{31}\rvert$, kierunkowość $D = 20\log\lvert S_{31}/S_{41}\rvert$, izolacja $I = C + D$. Kierunkowość decyduje o dokładności pomiaru współczynnika odbicia.

## Przykład rozwiązany

**Dzielnik Wilkinsona 2 GHz, 50 Ω** — analiza węzłowa (macierz Y trójwrotnika z odcinków linii i rezystora, potem $\mathbf S = (\mathbf I - Z_0\mathbf Y)(\mathbf I + Z_0\mathbf Y)^{-1}$):

| Częstotliwość | $S_{11}$ | $S_{21}$ | $S_{22}$ | Izolacja $S_{32}$ |
|---|---|---|---|---|
| 1,6 GHz | −19,3 dB | −3,06 dB | −38 dB | −19,1 dB |
| 1,8 GHz | −25,2 dB | −3,02 dB | −50 dB | −25,1 dB |
| 2,0 GHz | < −100 dB | −3,01 dB | < −100 dB | < −100 dB |

W $f_0$ układ jest idealny ($S_{21} = -j0\text{,}707$); przy ±20% dopasowanie wejścia i izolacja są ok. −19 dB — typowa szerokość pasma jednej sekcji.

## Typowe pułapki

- **Rezystor z dużą indukcyjnością** (zbyt duża obudowa, przelotki) — izolacja znacznie gorsza niż w symulacji; rezystory 0402/0201, cienkowarstwowe.
- **Niesymetryczny layout** — różne fazy i amplitudy na wyjściach (ważne dla szyków).
- **Moc rozpraszana w rezystorze** przy niedopasowanym obciążeniu jednego wyjścia — w dzielnikach wysokiej mocy rezystor musi to wytrzymać.
- **Sprzęgacz gałęziowy poza wąskim pasmem** — błędy fazy i amplitudy szybko rosną; wersje wielosekcyjne.
- **Ignorowanie różnicy prędkości modów** parzystego i nieparzystego w mikropasku — zmniejsza kierunkowość sprzęgaczy na liniach sprzężonych.

## Ćwiczenie komputerowe

Dzielnik Wilkinsona z macierzy admitancyjnej odcinków linii — parametry S w funkcji częstotliwości:

```python
import numpy as np

Z0, f0 = 50.0, 2.0e9
def line_Y(Zc, bl):
    """Macierz admitancyjna odcinka linii (dwuwrotnik)."""
    return np.array([[-1j/np.tan(bl), 1j/np.sin(bl)], [1j/np.sin(bl), -1j/np.tan(bl)]])/Zc

def wilkinson(f, R=100.0, Zc=50*np.sqrt(2)):
    bl = np.pi/2*f/f0
    Y = np.zeros((3, 3), complex)
    for p in (1, 2):                                   # dwie linie λ/4: port 0 ↔ port 1 i port 0 ↔ port 2
        Yl = line_Y(Zc, bl)
        idx = [0, p]
        for i in range(2):
            for j in range(2):
                Y[idx[i], idx[j]] += Yl[i, j]
    Y[1, 1] += 1/R; Y[2, 2] += 1/R; Y[1, 2] -= 1/R; Y[2, 1] -= 1/R   # rezystor między portami 2 i 3
    I = np.eye(3)
    return (I - Z0*Y) @ np.linalg.inv(I + Z0*Y)

for f in (1.6e9, 1.8e9, 2.0e9, 2.2e9, 2.4e9):
    S = wilkinson(f)
    db = lambda x: 20*np.log10(max(abs(x), 1e-6))          # podłoga −120 dB (zera numeryczne)
    print(f"f = {f/1e9:.1f} GHz: S11 {db(S[0,0]):6.1f} dB, S21 {db(S[1,0]):6.2f} dB, S22 {db(S[1,1]):6.1f} dB, izolacja S32 {db(S[2,1]):6.1f} dB")
S = wilkinson(f0)
print("S w f0 (zaokrąglone):\n", np.round(S, 3))
```

Rozszerzenie: zbuduj w ten sam sposób sprzęgacz gałęziowy (czterowrotnik z czterech odcinków λ/4) i sprawdź przesunięcie fazy między wyjściami oraz pasmo, w którym błąd fazy jest mniejszy niż 5°.

## Zadania

1. Jakie impedancje odcinków i jaki rezystor ma dzielnik Wilkinsona dla systemu 75 Ω?
2. Dlaczego przy pobudzeniu parzystym przez rezystor Wilkinsona nie płynie prąd?
3. Sprzęgacz ma sprzężenie 20 dB i kierunkowość 25 dB. Ile wynosi izolacja?
4. Do czego służy hybryda 180° w odbiorniku monoimpulsowym radaru?
5. Na wyjściu 2 dzielnika Wilkinsona obciążenie ma współczynnik odbicia 0,3. Co dzieje się z mocą odbitą?

<details>
<summary>Odpowiedzi</summary>

1. $\sqrt2\cdot 75 = 106$ Ω, rezystor 150 Ω
2. Napięcia na obu końcach rezystora są równe (symetria) — różnica potencjałów zero
3. $20 + 25 = 45$ dB
4. Tworzy sumę i różnicę sygnałów z dwóch połówek anteny: suma daje sygnał do wykrywania, różnica (zero na osi) — znak i wielkość odchylenia celu od osi, czyli precyzyjny kąt
5. Część odbitej mocy wraca do wejścia, część jest pochłaniana w rezystorze; do wyjścia 3 (izolowanego) w $f_0$ nie dociera nic — dzięki temu niedopasowanie jednej anteny w szyku nie zaburza pozostałych
</details>

## Źródła

- [S. J. Orfanidis — Electromagnetic Waves and Antennas](https://www.ece.rutgers.edu/~orfanidi/ewa) — sprzęgacze i linie sprzężone
- [scikit-rf](https://scikit-rf.readthedocs.io) — sieci wielowrotowe w Pythonie
- D. M. Pozar — *Microwave Engineering* (płatna) — rozdział 7
