# M04.01 — Sieci mikrofalowe: macierze S, ABCD i de-embedding

## Po co to jest

Przy częstotliwościach mikrofalowych nie da się zmierzyć napięć i prądów na zaciskach — mierzy się fale padające i odbite, a układ opisuje macierzą rozproszenia **S** ([12.02](../../modules/12-technika-wcz-rf/02-parametry-s.md)). Do projektowania wygodniejsze są inne macierze: **ABCD** do łączenia kaskadowego, **Z** i **Y** do łączenia szeregowego i równoległego, **T** do kaskad w dziedzinie fal. Umiejętność przechodzenia między nimi pozwala składać filtry i dopasowania z odcinków, a **de-embedding** — wyodrębnić z pomiaru sam badany element, bez złączy i ścieżek dojściowych.

## Teoria w pigułce

### Macierze i ich zastosowania

| Macierz | Związek | Łączenie |
|---|---|---|
| **S** | $\mathbf b = \mathbf S\mathbf a$ (fale znormalizowane do $Z_0$) | Ogólna; pomiar VNA |
| **Z**, **Y** | $\mathbf V = \mathbf Z\mathbf I$, $\mathbf I = \mathbf Y\mathbf V$ | Szeregowe (Z dodają się), równoległe (Y dodają się) |
| **ABCD** | $\begin{bmatrix}V_1\\I_1\end{bmatrix} = \begin{bmatrix}A & B\\C & D\end{bmatrix}\begin{bmatrix}V_2\\I_2\end{bmatrix}$ | **Kaskada: mnożenie** |
| **T** | Fale na wejściu przez fale na wyjściu | Kaskada w dziedzinie fal |

Przekształcenie ABCD → S (wspólne $Z_0$):

$$S_{11} = \frac{A + B/Z_0 - CZ_0 - D}{\Delta}, \quad S_{21} = \frac{2}{\Delta}, \quad \Delta = A + B/Z_0 + CZ_0 + D$$

Elementy: impedancja szeregowa $\begin{bmatrix}1 & Z\\0 & 1\end{bmatrix}$, admitancja równoległa $\begin{bmatrix}1 & 0\\Y & 1\end{bmatrix}$, linia $\begin{bmatrix}\cos\beta l & jZ_c\sin\beta l\\ j\sin\beta l/Z_c & \cos\beta l\end{bmatrix}$.

### Własności fizyczne macierzy S

- **Wzajemność:** $\mathbf S = \mathbf S^T$ (układy bez materiałów magnetycznie nieodwracalnych i elementów aktywnych).
- **Bezstratność:** $\mathbf S^H\mathbf S = \mathbf I$ (macierz unitarna).
- **Przesunięcie płaszczyzny odniesienia** o linię dopasowaną o długości elektrycznej $\theta_n$: $S'_{mn} = S_{mn}e^{-j(\theta_m + \theta_n)}$.
- **Parametry S mieszane (różnicowe):** dla par różnicowych ($S_{dd}$, $S_{cc}$, $S_{dc}$) — sygnały szybkie, USB, PCIe ([16.04](../../modules/16-pcb-emc-konstrukcja/04-integralnosc-sygnalow.md)).

### De-embedding i kalibracja

- **Kalibracja VNA** (SOLT, TRL) przenosi płaszczyznę pomiaru na końce kabli/złączy.
- **De-embedding** usuwa znane elementy między płaszczyzną kalibracji a badanym elementem: $\mathbf M_{DUT} = \mathbf M_{fix,L}^{-1}\mathbf M_{pom}\mathbf M_{fix,R}^{-1}$ (w ABCD lub T). Modele przyrządów: z symulacji, z pomiaru struktur „thru”, „open”, „short” na tej samej płytce (2x-thru).

## Przykład rozwiązany

**Tłumik Π 3 dB dla 50 Ω:** $K = 10^{3/20} = 1\text{,}413$; $R_{równ} = Z_0\dfrac{K + 1}{K - 1} = 292\text{,}4$ Ω, $R_{szer} = Z_0\dfrac{K^2 - 1}{2K} = 17\text{,}61$ Ω. Macierz ABCD z trzech elementów → $\lvert S_{21}\rvert = -3\text{,}00$ dB, $S_{11} = 0$ ✓.

**De-embedding:** element szeregowy $25 + j10$ Ω zmierzono przez dwa odcinki linii 70 Ω o długości 30°. Zmierzone $S_{21}$ różni się fazą od $S_{21}$ samego elementu o ok. 58° (a modułem też), co przy wyznaczaniu impedancji z „surowego” pomiaru dałoby duży błąd. Po pomnożeniu przez odwrotności macierzy ABCD przyrządów odzyskujemy dokładnie $25 + j10$ Ω.

## Typowe pułapki

- **Mnożenie macierzy S zamiast ABCD/T** przy kaskadach.
- **Różne impedancje odniesienia** portów bez renormalizacji.
- **Model przyrządu niedokładny** — de-embedding przenosi jego błędy na wynik; struktury testowe na tej samej płytce, ten sam materiał.
- **Konwencje faz i numeracji portów** (S21 = z portu 1 do 2) różne w narzędziach — sprawdzaj na znanym elemencie.
- **Pliki Touchstone** w różnych formatach (MA, DB, RI; GHz vs Hz) — źródło cichych błędów.

## Ćwiczenie komputerowe

Przekształcenia ABCD ↔ S, tłumik Π i de-embedding przyrządów pomiarowych:

```python
import numpy as np

Z0 = 50.0
def abcd_series(Z):  return np.array([[1, Z], [0, 1]], dtype=complex)
def abcd_shunt(Y):   return np.array([[1, 0], [Y, 1]], dtype=complex)
def abcd_line(Zc, bl):
    return np.array([[np.cos(bl), 1j*Zc*np.sin(bl)], [1j*np.sin(bl)/Zc, np.cos(bl)]])

def abcd_to_s(M, Z0=50.0):
    A, B, C, D = M.ravel()
    den = A + B/Z0 + C*Z0 + D
    return np.array([[(A + B/Z0 - C*Z0 - D)/den, 2*(A*D - B*C)/den],
                     [2/den, (-A + B/Z0 - C*Z0 + D)/den]])

def s_to_abcd(S, Z0=50.0):
    S11, S12, S21, S22 = S.ravel()
    return np.array([[((1 + S11)*(1 - S22) + S12*S21)/(2*S21), Z0*((1 + S11)*(1 + S22) - S12*S21)/(2*S21)],
                     [((1 - S11)*(1 - S22) - S12*S21)/(2*S21*Z0), ((1 - S11)*(1 + S22) + S12*S21)/(2*S21)]])

# tłumik Π 3 dB dla 50 Ω
K = 10**(3/20)
R_sh = Z0*(K + 1)/(K - 1); R_se = Z0*(K**2 - 1)/(2*K)
att = abcd_shunt(1/R_sh) @ abcd_series(R_se) @ abcd_shunt(1/R_sh)
S = abcd_to_s(att)
print(f"tłumik Π: R_równ = {R_sh:.1f} Ω, R_szer = {R_se:.2f} Ω → |S21| = {20*np.log10(abs(S[1,0])):.2f} dB, |S11| = {abs(S[0,0]):.1e}")

# urządzenie (DUT) między dwoma przyrządami (fixture): linia 70 Ω o długości 30° po każdej stronie
fix = abcd_line(70.0, np.radians(30))
dut = abcd_series(25 + 10j)                              # nieznany element szeregowy
meas = fix @ dut @ fix
S_meas = abcd_to_s(meas)
dut_deemb = np.linalg.inv(fix) @ s_to_abcd(S_meas) @ np.linalg.inv(fix)
print(f"zmierzone S11 = {S_meas[0,0]:.3f}, S21 = {S_meas[1,0]:.3f}")
print(f"po usunięciu przyrządów (de-embedding): Z_szer = {dut_deemb[0,1]:.2f} Ω (prawdziwe 25+10j Ω)")
print(f"bez de-embeddingu S21 DUT samego = {abcd_to_s(dut)[1,0]:.3f} — różnica fazy {np.degrees(np.angle(S_meas[1,0]/abcd_to_s(dut)[1,0])):.1f}°")
```

W praktyce te same operacje wykonuje biblioteka scikit-rf (`Network`, `**` dla kaskady, `.inv` do de-embeddingu) na plikach Touchstone z analizatora.

## Zadania

1. Wyznacz macierz S idealnego odcinka linii 50 Ω o długości λ/8 (Z0 = 50 Ω).
2. Czy macierz $\mathbf S = \begin{bmatrix} 0 & 0\text{,}9 \\ 0\text{,}9 & 0\end{bmatrix}$ opisuje układ bezstratny?
3. Zaprojektuj tłumik T 6 dB dla 50 Ω (wzory: $R_{szer} = Z_0\frac{K-1}{K+1}$, $R_{równ} = Z_0\frac{2K}{K^2-1}$).
4. Płaszczyzna odniesienia portu 1 zostaje przesunięta o 45° w stronę urządzenia. Jak zmienia się $S_{11}$?
5. Dlaczego do de-embeddingu używa się macierzy T lub ABCD, a nie S?

<details>
<summary>Odpowiedzi</summary>

1. $S_{11} = S_{22} = 0$, $S_{21} = S_{12} = e^{-j\pi/4}$
2. Nie — $\lvert S_{11}\rvert^2 + \lvert S_{21}\rvert^2 = 0\text{,}81 < 1$: 19% mocy jest tracone (tłumik ok. 0,9 dB)
3. $K = 2$: $R_{szer} = 50\cdot 1/3 = 16\text{,}7$ Ω (dwa rezystory szeregowe), $R_{równ} = 50\cdot 4/3 = 66\text{,}7$ Ω
4. $S'_{11} = S_{11}e^{+j2\cdot 45°}$ — faza rośnie o 90° (krótsza droga do urządzenia), moduł bez zmian
5. Dla kaskady macierze ABCD i T mnożą się, więc odjęcie przyrządu to mnożenie przez odwrotność; dla macierzy S zależność kaskady jest nieliniowa (wzór z mianownikiem pętli odbić)
</details>

## Źródła

- [S. J. Orfanidis — Electromagnetic Waves and Antennas](https://www.ece.rutgers.edu/~orfanidi/ewa) — rozdziały o sieciach i parametrach S
- [scikit-rf](https://scikit-rf.readthedocs.io) — sieci, kalibracja, de-embedding
- D. M. Pozar — *Microwave Engineering* (płatna) — rozdział 4
