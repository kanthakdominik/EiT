# 12.02 — Parametry S i analizator obwodów

## Po co to jest

Na wielkich częstotliwościach nie da się wygodnie mierzyć napięć i prądów ani robić zwarć i rozwarć (potrzebnych do parametrów Z, Y, h) — zwarty tranzystor w.cz. potrafi się wzbudzić. Zamiast tego mierzy się fale: padającą, odbitą i przechodzącą, przy zakończeniach 50 Ω. Parametry S to język kart katalogowych w.cz., analizatorów obwodów (VNA) i symulatorów.

## Teoria w pigułce

### Definicja

Dla wrót $i$: fala padająca $a_i$ i odbita $b_i$ (znormalizowane tak, że $|a|^2$ to moc). Dla czwórnika:

$$\begin{bmatrix}b_1\\ b_2\end{bmatrix} = \begin{bmatrix}S_{11} & S_{12}\\ S_{21} & S_{22}\end{bmatrix}\begin{bmatrix}a_1\\ a_2\end{bmatrix}$$

| Parametr | Sens (przy drugich wrotach zakończonych $Z_0$) |
|---|---|
| $S_{11}$ | Współczynnik odbicia na wejściu ($\Gamma_{we}$) |
| $S_{21}$ | Transmitancja w przód — wzmocnienie lub tłumienie |
| $S_{12}$ | Transmitancja wsteczna — izolacja |
| $S_{22}$ | Współczynnik odbicia na wyjściu |

W dB: $20\log|S_{ij}|$. Tłumienie odbiciowe (return loss) = $-|S_{11}|_{dB}$, tłumienie wtrąceniowe (insertion loss) = $-|S_{21}|_{dB}$.

### Własności

- **Obwód odwracalny** (bierny, bez ferrytów): $S_{12} = S_{21}$.
- **Bezstratny:** macierz S unitarna — $|S_{11}|^2 + |S_{21}|^2 = 1$.
- **Symetryczny:** $S_{11} = S_{22}$.
- Przesunięcie płaszczyzny odniesienia o linię o długości $l$ zmienia fazę $S_{11}$ o $-2\beta l$, $S_{21}$ o $-\beta l$.
- Z $S_{11}$: $Z_{we} = Z_0\dfrac{1 + S_{11}}{1 - S_{11}}$. Przejścia między S, Z, Y, ABCD — wzory w podręcznikach i bibliotekach (scikit-rf); **kaskadę liczy się w ABCD lub parametrach T**, nie mnożąc macierzy S.

### Analizator obwodów (VNA)

Źródło przemiatane w częstotliwości, sprzęgacze kierunkowe oddzielające fale padające i odbite, odbiorniki mierzące amplitudę i fazę. **Kalibracja** (np. SOLT: short, open, load, thru) usuwa błędy systematyczne kabli i złączy i ustala płaszczyznę odniesienia. Bez kalibracji wyniki fazy są bezwartościowe. Wynik zapisuje się w plikach **Touchstone** (.s1p, .s2p).

Pomiary: S11 anteny (rezonans, pasmo), S21 filtra (charakterystyka, tłumienie), parametry tranzystora, kable (TDR przez odwrotną FFT). Tanie analizatory amatorskie (np. NanoVNA) wystarczają do nauki i strojenia anten do ok. 1–3 GHz.

### Wzmocnienie

Przy dopasowanych zakończeniach $|S_{21}|^2$ to wzmocnienie mocy przetwornikowe. Przy niedopasowaniu definicji jest kilka (przetwornikowe, dostępne, robocze) — [12.06](06-wzmacniacze-wcz.md).

## Przykład rozwiązany

Wzmacniacz: $S_{11} = -12$ dB, $S_{21} = 15$ dB, $S_{12} = -25$ dB, $S_{22} = -10$ dB.

1. Wejście: $|\Gamma| = 10^{-12/20} = 0{,}251$ → WFS 1,67, odbija się 6,3% mocy.
2. Wzmocnienie mocy przy 50 Ω: ×31,6.
3. Izolacja wsteczna 25 dB — sygnał z wyjścia (np. przeciek generatora lokalnego z mieszacza) przenika na wejście tłumiony o 25 dB.
4. Wyjście: $|\Gamma| = 0{,}316$, WFS 1,92.

**Impedancja z S11:** $S_{11} = 0{,}2 + j0{,}4$ → $Z = 50\dfrac{1{,}2 + j0{,}4}{0{,}8 - j0{,}4} = 50 + j50\ \Omega$.

## Typowe pułapki

- **Pomiar bez kalibracji lub z kalibracją w innym miejscu** niż przyłączenie badanego obwodu.
- **Mylenie S21 w dB z wzmocnieniem napięciowym** w układzie o innych impedancjach niż 50 Ω.
- **Mnożenie macierzy S przy kaskadzie** — błędne; użyj ABCD/T.
- **Za duża moc z VNA na wejściu wzmacniacza** — pomiar w nasyceniu.
- **Płaszczyzna odniesienia na złączu, a nie na padach elementu** — trzeba odjąć (de-embedding) ścieżkę i złącze.

## Ćwiczenie komputerowe

Parametry S linii, kaskada przez ABCD i konwersja S11 → impedancja (bez dodatkowych bibliotek; to samo robi scikit-rf):

```python
import numpy as np

Z0 = 50
def abcd_line(Zc, bl):  return np.array([[np.cos(bl), 1j*Zc*np.sin(bl)], [1j*np.sin(bl)/Zc, np.cos(bl)]])
def abcd_series(Z):     return np.array([[1, Z], [0, 1]])
def abcd_shunt(Y):      return np.array([[1, 0], [Y, 1]])
def abcd2s(M):
    A, B, C, D = M.ravel(); den = A + B/Z0 + C*Z0 + D
    return np.array([[(A + B/Z0 - C*Z0 - D)/den, 2*(A*D - B*C)/den], [2/den, (-A + B/Z0 - C*Z0 + D)/den]])

# filtr: L szeregowo - C równolegle - L szeregowo przy 100 MHz
f = 100e6; w = 2*np.pi*f
M = abcd_series(1j*w*80e-9) @ abcd_shunt(1j*w*32e-12) @ abcd_series(1j*w*80e-9)
S = abcd2s(M)
print("|S| [dB]:\n", np.round(20*np.log10(abs(S)), 2))
print("bezstratność |S11|^2+|S21|^2 =", round(abs(S[0, 0])**2 + abs(S[1, 0])**2, 6))
S11 = 0.2 + 0.4j
print("Z z S11 = 0.2+j0.4:", Z0*(1 + S11)/(1 - S11))
for s11_db in [-6, -10, -12, -20]:
    g = 10**(s11_db/20); print(f"S11 = {s11_db} dB: |Γ| = {g:.3f}, WFS = {(1 + g)/(1 - g):.2f}, odbite {100*g*g:.1f}%")
```

## Zadania

1. Przelicz $S_{11} = -10$ dB na |Γ|, WFS i procent mocy odbitej.
2. Tłumik 6 dB dopasowany do 50 Ω — podaj jego macierz S (moduły).
3. $S_{11} = -0{,}5$ (rzeczywiste). Jaka impedancja wejściowa?
4. Filtr bezstratny ma przy pewnej częstotliwości $|S_{21}| = -1$ dB. Ile wynosi $|S_{11}|$ w dB?
5. Dlaczego do kaskady dwóch czwórników używa się macierzy ABCD, a nie S?

<details>
<summary>Odpowiedzi</summary>

1. 0,316; 1,92; 10%
2. $|S_{11}| = |S_{22}| = 0$, $|S_{21}| = |S_{12}| = 0{,}5$ (−6 dB)
3. $50\cdot 0{,}5/1{,}5 \approx 16{,}7\ \Omega$
4. $|S_{21}|^2 = 0{,}794$ → $|S_{11}|^2 = 0{,}206$ → $-6{,}9$ dB
5. Macierz ABCD wiąże wielkości na wejściu z wielkościami na wyjściu, więc kaskada to iloczyn macierzy; macierz S wiąże fale wychodzące z padającymi na obu wrotach jednocześnie — kaskadę trzeba liczyć z uwzględnieniem wielokrotnych odbić (lub przez macierze T)
</details>

## Źródła

- [Keysight AN 154 — S-Parameter Design](https://www.keysight.com/be/en/assets/7018-06743/application-notes/5952-1087.pdf) — parametry S od podstaw
- [Fundamentals of Microwave and RF Design — M. Steer](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-microwave-and-rf-design) — macierze S, ABCD i ich konwersje
- [scikit-rf](https://scikit-rf.readthedocs.io) — obsługa plików Touchstone, kaskady, kalibracja VNA w Pythonie
