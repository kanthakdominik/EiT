# M04.05 — Projekt wzmacniacza mikrofalowego

## Po co to jest

Wzmacniacz niskoszumny (LNA) decyduje o czułości odbiornika, wzmacniacz mocy — o zasięgu i poborze energii nadajnika. Przy częstotliwościach mikrofalowych tranzystor opisuje się parametrami S z karty katalogowej, a projekt polega na doborze impedancji źródła i obciążenia, które tranzystorowi „pokazują” sieci dopasowujące. Trzy wymagania często się wykluczają: maksymalne wzmocnienie, minimalny szum i stabilność (brak oscylacji przy dowolnym obciążeniu). Temat rozwija [12.06](../../modules/12-technika-wcz-rf/06-wzmacniacze-wcz.md) do pełnej procedury projektowej.

## Teoria w pigułce

### Wzmocnienia

- Współczynniki odbicia widziane na wejściu i wyjściu tranzystora: $\Gamma_{in} = S_{11} + \dfrac{S_{12}S_{21}\Gamma_L}{1 - S_{22}\Gamma_L}$, $\Gamma_{out} = S_{22} + \dfrac{S_{12}S_{21}\Gamma_S}{1 - S_{11}\Gamma_S}$.
- **Wzmocnienie przenoszenia:** $G_T = \dfrac{(1 - \lvert\Gamma_S\rvert^2)\lvert S_{21}\rvert^2(1 - \lvert\Gamma_L\rvert^2)}{\lvert 1 - \Gamma_S\Gamma_{in}\rvert^2\lvert 1 - S_{22}\Gamma_L\rvert^2}$.
- **Przybliżenie jednokierunkowe** ($S_{12} \approx 0$): $G_T = G_S\cdot\lvert S_{21}\rvert^2\cdot G_L$ — osobne „zyski dopasowania” wejścia i wyjścia; okręgi stałego wzmocnienia na wykresie Smitha.

### Stabilność

- **Bezwarunkowa stabilność** (żadne pasywne $\Gamma_S$, $\Gamma_L$ nie wywoła oscylacji): $K = \dfrac{1 - \lvert S_{11}\rvert^2 - \lvert S_{22}\rvert^2 + \lvert\Delta\rvert^2}{2\lvert S_{12}S_{21}\rvert} > 1$ i $\lvert\Delta\rvert < 1$, $\Delta = S_{11}S_{22} - S_{12}S_{21}$; albo jeden warunek $\mu > 1$.
- Tranzystor potencjalnie niestabilny: **okręgi stabilności** na wykresie Smitha — wybiera się $\Gamma_S$, $\Gamma_L$ z obszaru stabilnego albo stabilizuje (rezystor szeregowy/równoległy, sprzężenie zwrotne, indukcyjność w źródle).
- Stabilność sprawdza się **w całym paśmie, w którym tranzystor ma wzmocnienie** (także daleko poza pasmem pracy — tam oscylacje są najczęstsze).

### Maksymalne wzmocnienie i szum

- Przy $K > 1$: jednoczesne dopasowanie sprzężone $\Gamma_S = \Gamma_{in}^*$, $\Gamma_L = \Gamma_{out}^*$ daje $G_{T,max} = \dfrac{\lvert S_{21}\rvert}{\lvert S_{12}\rvert}\left(K - \sqrt{K^2 - 1}\right)$; dla $K \to 1$ — **MSG** $= \lvert S_{21}/S_{12}\rvert$.
- **Szum:** $F = F_{min} + \dfrac{4R_n}{Z_0}\dfrac{\lvert\Gamma_S - \Gamma_{opt}\rvert^2}{(1 - \lvert\Gamma_S\rvert^2)\lvert 1 + \Gamma_{opt}\rvert^2}$ — minimalny szum przy $\Gamma_S = \Gamma_{opt}$ (zwykle ≠ dopasowaniu dla wzmocnienia); okręgi stałego szumu; kompromis wzmocnienie–szum–dopasowanie wejścia.
- LNA często dopasowuje się szumowo na wejściu i dla wzmocnienia na wyjściu; indukcyjność w źródle zbliża $\Gamma_{opt}$ do $\Gamma_{in}^*$.

### Procedura

1. Parametry S i szumowe w punkcie pracy (karta katalogowa, plik Touchstone).
2. Stabilność w szerokim paśmie; ewentualna stabilizacja.
3. Wybór $\Gamma_S$, $\Gamma_L$ (wzmocnienie, szum, pasmo).
4. Sieci dopasowujące (L, odcinki linii — [11.04](../../modules/11-pole-em-linie-anteny/04-wykres-smitha-i-dopasowanie.md), [12.03](../../modules/12-technika-wcz-rf/03-dopasowanie-lc.md)), obwody polaryzacji (dławiki, odsprzęganie).
5. Symulacja z rzeczywistymi elementami, layout, symulacja EM, pomiar.

## Przykład rozwiązany

**Tranzystor przy 4 GHz:** $S_{11} = 0\text{,}72\angle{-116°}$, $S_{12} = 0\text{,}03\angle{57°}$, $S_{21} = 2\text{,}60\angle{76°}$, $S_{22} = 0\text{,}73\angle{-54°}$ (klasyczny przykład z podręcznika Pozara).

1. $\lvert\Delta\rvert = 0\text{,}488$, $K = 1\text{,}195$, $\mu = 1\text{,}04$ → bezwarunkowo stabilny (w tej częstotliwości).
2. Dopasowanie sprzężone: $\Gamma_S = 0\text{,}872\angle{123°}$, $\Gamma_L = 0\text{,}876\angle{61°}$ — duże moduły: wąskie pasmo i duża wrażliwość na tolerancje.
3. $G_{T,max} = 16\text{,}7$ dB wobec $\lvert S_{21}\rvert^2 = 8\text{,}3$ dB bez dopasowania; MSG = 19,4 dB.
4. Wymagane impedancje: źródła $4\text{,}4 + j26\text{,}8$ Ω, obciążenia $12\text{,}6 + j83\text{,}4$ Ω — do zrealizowania sieciami z odcinków linii lub elementów LC.

## Typowe pułapki

- **Stabilność sprawdzona tylko w paśmie pracy** — oscylacje przy kilkuset MHz lub kilkunastu GHz.
- **Parametry S dla innego punktu pracy** niż rzeczywisty (prąd, napięcie, temperatura).
- **Dopasowanie do $|\Gamma|$ bliskiego 1** — wąskopasmowe i wrażliwe; czasem lepiej oddać 1–2 dB wzmocnienia.
- **Obwód polaryzacji wpływający na dopasowanie** — dławik z rezonansem własnym w paśmie, brak odsprzęgania przy niskich częstotliwościach (tam wzmocnienie jest największe).
- **Indukcyjność przelotek do masy emitera/źródła** — zmienia parametry S i stabilność; uwzględniaj w modelu.

## Ćwiczenie komputerowe

Stabilność, jednoczesne dopasowanie sprzężone i maksymalne wzmocnienie z parametrów S:

```python
import numpy as np

# parametry S tranzystora przy 4 GHz (przykładowe, w konfiguracji ze wspólnym emiterem/źródłem, Z0 = 50 Ω)
pol = lambda m, a: m*np.exp(1j*np.radians(a))
S11, S12, S21, S22 = pol(0.72, -116), pol(0.03, 57), pol(2.60, 76), pol(0.73, -54)
D = S11*S22 - S12*S21
K = (1 - abs(S11)**2 - abs(S22)**2 + abs(D)**2)/(2*abs(S12*S21))
mu = (1 - abs(S11)**2)/(abs(S22 - D*np.conj(S11)) + abs(S12*S21))
print(f"|Δ| = {abs(D):.3f}, K = {K:.3f}, μ = {mu:.3f} → {'bezwarunkowo stabilny' if (K > 1 and abs(D) < 1) else 'potencjalnie niestabilny'}")

# jednoczesne dopasowanie sprzężone (dla K > 1)
B1 = 1 + abs(S11)**2 - abs(S22)**2 - abs(D)**2
B2 = 1 + abs(S22)**2 - abs(S11)**2 - abs(D)**2
C1 = S11 - D*np.conj(S22); C2 = S22 - D*np.conj(S11)
Gs = (B1 - np.sqrt(B1**2 - 4*abs(C1)**2))/(2*C1)
Gl = (B2 - np.sqrt(B2**2 - 4*abs(C2)**2))/(2*C2)
GT_max = abs(S21)/abs(S12)*(K - np.sqrt(K**2 - 1))
print(f"Γs = {abs(Gs):.3f}∠{np.degrees(np.angle(Gs)):.1f}°, ΓL = {abs(Gl):.3f}∠{np.degrees(np.angle(Gl)):.1f}°")
print(f"maksymalne wzmocnienie dostępne G_max = {10*np.log10(GT_max):.2f} dB; |S21|² = {20*np.log10(abs(S21)):.2f} dB")
print(f"MSG = |S21/S12| = {10*np.log10(abs(S21/S12)):.1f} dB (granica dla K → 1)")

# sprawdzenie: wzmocnienie przenoszenia przy Γs, ΓL
Gin = S11 + S12*S21*Gl/(1 - S22*Gl)
GT = (1 - abs(Gs)**2)*abs(S21)**2*(1 - abs(Gl)**2)/(abs(1 - Gs*Gin)**2*abs(1 - S22*Gl)**2)
print(f"G_T przy dopasowaniu = {10*np.log10(GT):.2f} dB, |Γin − Γs*| = {abs(Gin - np.conj(Gs)):.1e}")

# dopasowanie wejścia na wykresie Smitha: impedancja źródła, którą trzeba „pokazać” tranzystorowi
Zs = 50*(1 + Gs)/(1 - Gs); Zl = 50*(1 + Gl)/(1 - Gl)
print(f"wymagane Z_źr = {Zs:.1f} Ω, Z_obc = {Zl:.1f} Ω")
```

Rozszerzenie: wczytaj plik Touchstone wybranego tranzystora (scikit-rf), policz $K$ i $\mu$ w paśmie 0,1–20 GHz i znajdź zakres potencjalnej niestabilności; dodaj rezystor stabilizujący na wyjściu i powtórz.

## Zadania

1. Tranzystor ma $K = 0\text{,}8$. Czy można z niego zbudować stabilny wzmacniacz? Jak?
2. Ile wynosi MSG dla $\lvert S_{21}\rvert = 4$, $\lvert S_{12}\rvert = 0\text{,}05$?
3. Dlaczego LNA nie projektuje się na jednoczesne dopasowanie sprzężone wejścia?
4. Policz $\Gamma_{in}$ tranzystora z przykładu dla $\Gamma_L = 0$.
5. Jaka jest rola dławika w obwodzie polaryzacji i jakie wymagania musi spełniać?

<details>
<summary>Odpowiedzi</summary>

1. Tak — wybierając $\Gamma_S$ i $\Gamma_L$ z obszarów stabilnych (poza okręgami stabilności) lub stabilizując tranzystor rezystorem (szeregowym na wejściu, równoległym na wyjściu) albo sprzężeniem zwrotnym; wzmocnienie będzie niższe od MSG
2. $10\log_{10}(4/0\text{,}05) = 19$ dB
3. Minimalny szum wymaga $\Gamma_S = \Gamma_{opt}$, które zwykle różni się od $\Gamma_{in}^*$ — dopasowanie dla wzmocnienia zwiększyłoby współczynnik szumów; kompromis wybiera się z okręgów stałego szumu i wzmocnienia (lub stosuje topologię zbliżającą oba punkty)
4. $\Gamma_{in} = S_{11} = 0\text{,}72\angle{-116°}$ (dla $\Gamma_L = 0$ człon z $S_{12}S_{21}$ znika)
5. Doprowadza prąd stały do tranzystora, nie obciążając sygnału w.cz.: duża impedancja w całym paśmie pracy (rezonans własny powyżej pasma), mała rezystancja dla DC, odpowiedni prąd; często zastępowany odcinkiem λ/4 z kondensatorem odsprzęgającym na końcu
</details>

## Źródła

- [scikit-rf](https://scikit-rf.readthedocs.io) — analiza parametrów S tranzystorów
- [S. J. Orfanidis — Electromagnetic Waves and Antennas](https://www.ece.rutgers.edu/~orfanidi/ewa) — dopasowanie impedancji
- D. M. Pozar — *Microwave Engineering* (płatna) — rozdział 12 (przykład z tematu)
- [12.06 Wzmacniacze w.cz.](../../modules/12-technika-wcz-rf/06-wzmacniacze-wcz.md)
