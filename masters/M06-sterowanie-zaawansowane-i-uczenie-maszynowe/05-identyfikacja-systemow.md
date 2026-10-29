# M06.05 — Identyfikacja systemów

## Po co to jest

LQR, MPC i regulatory odporne potrzebują modelu. Modele z praw fizyki mają nieznane parametry (bezwładność, tarcie, stałe czasowe cieplne, parametry silnika), a czasem w ogóle ich nie ma. Identyfikacja buduje model z pomiarów wejścia i wyjścia: od doboru pobudzenia, przez estymację parametrów, po walidację. To most między estymacją ([M01.03](../M01-estymacja-detekcja-filtracja/03-ml-i-najmniejsze-kwadraty.md)) a sterowaniem — i zarazem najstarsza forma „uczenia maszynowego” w automatyce.

## Teoria w pigułce

### Procedura

1. **Eksperyment:** wejście pobudzające wszystkie istotne częstotliwości (PRBS — pseudolosowy sygnał binarny, multisinus, szum filtrowany), amplituda w zakresie liniowym, częstotliwość próbkowania ok. 10–20 × pasmo obiektu, dane w pętli otwartej lub zamkniętej.
2. **Struktura modelu:** rząd, opóźnienie, typ modelu szumu.
3. **Estymacja** parametrów.
4. **Walidacja** na **innych danych**: dopasowanie symulacyjne, analiza reszt (biel, brak korelacji z wejściem).

### Struktury modeli liniowych

| Model | Równanie | Estymacja |
|---|---|---|
| ARX | $A(q)y = B(q)u + e$ | Liniowa najmniejszych kwadratów — jedno rozwiązanie |
| ARMAX | $A(q)y = B(q)u + C(q)e$ | Nieliniowa (błąd predykcji) |
| OE (błąd wyjścia) | $y = \dfrac{B(q)}{F(q)}u + e$ | Nieliniowa; lub zmienne instrumentalne |
| Box–Jenkins | $y = \dfrac{B}{F}u + \dfrac{C}{D}e$ | Nieliniowa, najogólniejsza |
| Przestrzeń stanów | $x_{k+1} = Ax_k + Bu_k$, … | Metody podprzestrzeni (N4SID, MOESP) — także MIMO |

**Obciążenie ARX:** najmniejsze kwadraty są nieobciążone tylko wtedy, gdy szum wchodzi jako $e/A(q)$. Przy szumie białym na wyjściu (struktura OE) regresory $y_{k-i}$ są skorelowane z błędem równania i estymaty są **obciążone** niezależnie od liczby danych. Rozwiązania: **zmienne instrumentalne** (instrumenty nieskorelowane z szumem, np. wyjście modelu symulowanego z samego wejścia), metoda błędu predykcji, wyższy rząd ARX.

### Dobór rzędu i walidacja

Dopasowanie na danych uczących rośnie z rzędem zawsze; decyduje walidacja (lub kryteria AIC/BIC, które karzą liczbę parametrów). Dopasowanie symulacyjne (model z samego wejścia) jest surowszym testem niż predykcja jednokrokowa.

### Identyfikacja w pętli zamkniętej

Wejście jest skorelowane z szumem przez regulator — metody bezpośrednie (błąd predykcji z poprawnym modelem szumu), pośrednie (przez znany regulator) lub dwustopniowe; potrzebne dodatkowe pobudzenie na wartości zadanej.

## Przykład rozwiązany

Obiekt $y_k = 1\text{,}5y_{k-1} - 0\text{,}7y_{k-2} + u_{k-1} + 0\text{,}5u_{k-2}$ + szum, wejście PRBS, 2000 próbek (połowa do estymacji, połowa do walidacji).

**Szum równania (struktura ARX prawdziwa)** — dopasowanie walidacyjne: rząd 1 — 29,6%, rząd 2 — 87,0%, rzędy 3 i 4 — 86,9% (wyższy rząd nic nie daje). ARX(2,2): $a = [-1\text{,}494;\ 0\text{,}695]$, $b = [0\text{,}99;\ 0\text{,}53]$ — blisko prawdy.

**Szum biały na wyjściu (struktura OE):**

| Metoda | $a_1$, $a_2$ | $b_1$, $b_2$ | Moduł bieguna |
|---|---|---|---|
| prawda | −1,5; 0,7 | 1,0; 0,5 | 0,837 |
| ARX (LS) | −1,387; 0,600 | 0,954; 0,772 | 0,774 |
| zmienne instrumentalne | −1,494; 0,695 | 0,996; 0,526 | 0,833 |

ARX systematycznie zaniża bieguny (model „szybszy” i słabiej tłumiony niż obiekt) — regulator zaprojektowany na nim byłby źle nastawiony. Zmienne instrumentalne usuwają obciążenie.

## Typowe pułapki

- **Walidacja na danych uczących** — każdy model wygląda dobrze.
- **Pobudzenie zbyt wolne lub zbyt małe** — parametry nieidentyfikowalne (macierz regresji źle uwarunkowana), model zły w paśmie, które nas interesuje.
- **ARX przy szumie pomiarowym** — obciążenie, którego nie usuną dodatkowe dane.
- **Zbyt duża częstotliwość próbkowania** — bieguny skupione przy 1, złe uwarunkowanie; filtruje się i decymuje dane.
- **Nieliniowość (nasycenie, luz, strefa martwa)** zignorowana — model liniowy dopasowany do danych z wielu punktów pracy; sprawdza się liniowość testami z różnymi amplitudami.

## Ćwiczenie komputerowe

Identyfikacja ARX z doborem rzędu i walidacją; obciążenie przy szumie wyjściowym i jego usunięcie zmiennymi instrumentalnymi:

```python
import numpy as np
from scipy import signal

rng = np.random.default_rng(5)
a_true, b_true = [1, -1.5, 0.7], [0, 1.0, 0.5]   # y[k] = 1,5y[k-1] - 0,7y[k-2] + u[k-1] + 0,5u[k-2]
N = 2000

def prbs(n, okres=3):                              # sygnał binarny ±1 zmieniany losowo co 'okres' próbek
    return np.repeat(rng.choice([-1.0, 1.0], n // okres + 1), okres)[:n]

def regresory(y, u, na, nb):
    k0 = max(na, nb)
    Phi = np.column_stack([-y[k0 - i:len(y) - i] for i in range(1, na + 1)]
                          + [u[k0 - i:len(u) - i] for i in range(1, nb + 1)])
    return Phi, y[k0:]

def arx(y, u, na, nb):
    Phi, Y = regresory(y, u, na, nb)
    return np.linalg.lstsq(Phi, Y, rcond=None)[0]

def symulacja(th, u, na, nb):                       # odpowiedź modelu na samo wejście (bez szumu)
    return signal.lfilter(np.r_[0, th[na:]], np.r_[1, th[:na]], u)

def fit(y, yh):                                      # miara dopasowania jak w System Identification Toolbox
    return 100 * (1 - np.linalg.norm(y - yh) / np.linalg.norm(y - y.mean()))

u = prbs(N)
y0 = signal.lfilter(b_true, a_true, u)

# Przypadek 1: szum równania (model ARX jest prawdziwą strukturą)
y = signal.lfilter(b_true, a_true, u) + signal.lfilter([1], a_true, 0.3 * rng.standard_normal(N))
ue, ye, uw, yw = u[:N // 2], y[:N // 2], u[N // 2:], y[N // 2:]
print("dobór rzędu (estymacja na 1. połowie, walidacja symulacyjna na 2. połowie):")
for n in (1, 2, 3, 4):
    th = arx(ye, ue, n, n)
    print(f"  na = nb = {n}: dopasowanie walidacyjne {fit(yw, symulacja(th, uw, n, n)):5.1f} %")
th = arx(ye, ue, 2, 2)
print(f"ARX(2,2), szum równania: a = {np.round(th[:2], 3)}, b = {np.round(th[2:], 3)}"
      f"  (prawdziwe a = [-1.5, 0.7], b = [1.0, 0.5])")

# Przypadek 2: szum biały na wyjściu (struktura błędu wyjścia) — ARX daje estymaty obciążone
y = y0 + 0.5 * rng.standard_normal(N)
th_ls = arx(y, u, 2, 2)
# Zmienne instrumentalne: instrumenty = opóźnione wyjście modelu symulowanego z wejścia (nieskorelowane z szumem)
x_iv = symulacja(th_ls, u, 2, 2)
Phi, Y = regresory(y, u, 2, 2)
Z, _ = regresory(x_iv, u, 2, 2)
th_iv = np.linalg.solve(Z.T @ Phi, Z.T @ Y)
for _ in range(3):                                   # kilka iteracji poprawia instrumenty
    Z, _ = regresory(symulacja(th_iv, u, 2, 2), u, 2, 2)
    th_iv = np.linalg.solve(Z.T @ Phi, Z.T @ Y)
for nazwa, th in (("ARX (najmniejsze kwadraty)", th_ls), ("zmienne instrumentalne", th_iv)):
    bieg = np.roots(np.r_[1, th[:2]])
    print(f"szum wyjściowy, {nazwa:27s}: a = {np.round(th[:2], 3)}, b = {np.round(th[2:], 3)},"
          f" |biegun| = {np.abs(bieg[0]):.3f} (prawdziwy {np.sqrt(0.7):.3f})")
```

Rozszerzenia: oblicz widmo reszt i autokorelację (test bieli z [21](../../modules/21-procesy-losowe-szum/)); zidentyfikuj prawdziwy obiekt — np. silnik DC z modułu [10](../../modules/10-automatyka/) lub układ cieplny (rezystor + czujnik temperatury) z mikrokontrolerem: PRBS na PWM, pomiar, ARX i porównanie z modelem fizycznym; zaprojektuj na zidentyfikowanym modelu regulator LQR ([01](01-lqr-i-lqg.md)).

## Zadania

1. Dlaczego ARX daje się rozwiązać jednym układem równań, a OE wymaga optymalizacji nieliniowej?
2. Jakiej długości powinien być „takt” PRBS (czas stałej wartości), by pobudzić obiekt o stałej czasowej 2 s przy próbkowaniu 0,1 s?
3. Model ARX(4,4) ma lepsze dopasowanie uczące niż ARX(2,2), a gorsze walidacyjne. Co się dzieje?
4. Co powinno wyjść z analizy reszt dobrego modelu?
5. Dlaczego instrumenty w metodzie IV muszą być skorelowane z regresorami, ale nieskorelowane z szumem?

<details>
<summary>Odpowiedzi</summary>

1. W ARX błąd równania jest liniowy względem parametrów ($y_k - \varphi_k^T\theta$, regresory to zmierzone dane); w OE przewidywane wyjście zależy od parametrów rekurencyjnie (przez symulowane wyjście), więc błąd jest nieliniową funkcją parametrów
2. Widmo PRBS powinno sięgać pasma obiektu ($1/(2\pi\cdot 2\ \text{s}) \approx 0\text{,}08$ Hz) z zapasem kilku razy wyżej; takt rzędu 2–5 próbek (0,2–0,5 s) — dłuższy takt to więcej energii przy niskich częstotliwościach
3. Przeuczenie — dodatkowe parametry dopasowują się do szumu konkretnego zapisu
4. Reszty białe (autokorelacja w granicach przedziału ufności dla opóźnień ≠ 0) i nieskorelowane z przeszłymi wejściami
5. Estymata IV to $(Z^T\Phi)^{-1}Z^TY$; jeśli $Z$ nie jest skorelowane z szumem, błąd $Z^Te/N \to 0$ (brak obciążenia), a korelacja z regresorami zapewnia dobre uwarunkowanie $Z^T\Phi$ (mała wariancja)
</details>

## Źródła

- [MIT 2.160 Identification, Estimation, and Learning (2006)](https://ocw.mit.edu/courses/2-160-identification-estimation-and-learning-spring-2006/) — identyfikacja systemów, metody błędu predykcji, zmienne instrumentalne
- [MIT 6.241J Dynamic Systems and Control (2011)](https://ocw.mit.edu/courses/6-241j-dynamic-systems-and-control-spring-2011/)
- [M01.03 Największa wiarygodność i najmniejsze kwadraty](../M01-estymacja-detekcja-filtracja/03-ml-i-najmniejsze-kwadraty.md)
- L. Ljung — *System Identification: Theory for the User* (płatna)
