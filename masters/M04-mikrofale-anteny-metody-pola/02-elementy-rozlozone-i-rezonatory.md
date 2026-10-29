# M04.02 — Elementy rozłożone i rezonatory

## Po co to jest

Powyżej kilku GHz cewki i kondensatory dyskretne mają rezonanse własne i duże straty, a ich wartości są porównywalne z pasożytami ścieżek ([12.01](../../modules/12-technika-wcz-rf/01-elementy-bierne-wcz.md)). Zamiast nich używa się odcinków linii: zwarty krótki odcinek zachowuje się jak cewka, rozwarty — jak kondensator, a odcinek λ/4 lub λ/2 — jak rezonator. Transformacja Richardsa i tożsamości Kurody pozwalają zamienić dowolny prototyp LC na strukturę z linii, a dobroć rezonatora wyznacza straty i selektywność filtrów i oscylatorów.

## Teoria w pigułce

### Odcinki linii jako reaktancje

- Zwarty odcinek: $Z_{we} = jZ_c\tan\beta l$ — dla $\beta l < \pi/2$ indukcyjny; rozwarty: $Z_{we} = -jZ_c\cot\beta l$ — pojemnościowy.
- **Transformacja Richardsa:** zmienna $\Omega = \tan\beta l$; cewka $L$ → zwarty odcinek o $Z_c = L$ (w znormalizowanych jednostkach), kondensator $C$ → rozwarty o $Y_c = C$, przy długości λ/8 dla częstotliwości granicznej. Odpowiedź jest **okresowa** w częstotliwości (pasma pasożytnicze co $4f_c$ dla λ/8).
- **Tożsamości Kurody** — zamiana szeregowych odcinków na równoległe (szeregowe są trudne do wykonania w mikropasku) z dodatkowymi odcinkami jednostkowymi.
- Odcinki wysoko- i niskoimpedancyjne (krótkie, $\beta l < \pi/4$) jako przybliżone cewki i kondensatory szeregowe/równoległe (temat 03).

### Rezonatory

| Rezonator | Zachowanie w rezonansie | Uwagi |
|---|---|---|
| Zwarty λ/4 | Rezonans równoległy (duża impedancja) | Jak obwód LC równoległy |
| Rozwarty λ/4 | Rezonans szeregowy (mała impedancja) | Odcinek tłumiący (notch) |
| λ/2 | Zależnie od zakończenia | Mikropaskowy rezonator sprzężony szczelinami |
| Wnęka (falowód) | Mody rezonansowe | Bardzo duża dobroć (tysiące–dziesiątki tysięcy) |
| Dielektryczny | Mod w bloku ceramicznym o dużym $\varepsilon_r$ | Filtry stacji bazowych, oscylatory |

- **Dobroć własna** linii z tłumieniem $\alpha$: $Q_0 = \dfrac{\beta}{2\alpha}$; obejmuje straty przewodnika, dielektryka ($Q_d = 1/\tan\delta$) i promieniowania: $1/Q_0 = 1/Q_c + 1/Q_d + 1/Q_r$.
- **Dobroć obciążona** $1/Q_L = 1/Q_0 + 1/Q_{ext}$ — sprzężenie z obwodem zewnętrznym; sprzężenie krytyczne $Q_{ext} = Q_0$ (dopasowanie w rezonansie).
- Pomiar: szerokość pasma −3 dB, $Q = f_0/\Delta f$; dokładniej z okręgu na wykresie Smitha.

## Przykład rozwiązany

**Zwarty odcinek λ/8 jako cewka:** przy $f_0 = 2$ GHz odcinek 50 Ω ma reaktancję $50\tan 45° = 50$ Ω — jak cewka 3,98 nH. Przy 1 GHz: 20,7 Ω (cewka: 25 Ω), przy 3 GHz: 121 Ω (cewka: 75 Ω), przy 3,8 GHz: 635 Ω (cewka: 95 Ω) — zgodność tylko w okolicy częstotliwości projektowej, a przy 4 GHz odcinek ma długość λ/4 i jego reaktancja dąży do nieskończoności.

**Rezonator λ/4 na podłożu ceramicznym** ($\varepsilon_{eff} = 6\text{,}7$, tłumienie 2 dB/m, 2 GHz): długość 14,5 mm, $Q_0 = \beta/2\alpha \approx 236$ — symulacja impedancji wejściowej daje tę samą wartość z szerokości pasma −3 dB. Filtr Butterwortha 3. rzędu z takich rezonatorów o paśmie względnym 2% miałby straty wtrącenia ok. $4\text{,}34\sum g_k/(\mathrm{FBW}\,Q_0) = 4\text{,}34\cdot 4/(0\text{,}02\cdot 236) \approx 3\text{,}7$ dB — wąskie filtry wymagają rezonatorów o dużej dobroci (wnękowych, dielektrycznych).

## Typowe pułapki

- **Zapominanie o okresowości** odpowiedzi elementów rozłożonych — pasmo pasożytnicze w paśmie innego systemu.
- **Pomijanie efektów końcowych** (rozproszone pole rozwartego końca mikropasku — efektywne wydłużenie), przelotek do masy (indukcyjność zwarcia).
- **Q z samych strat przewodnika** — przy FR4 dominują straty dielektryka ($\tan\delta \approx 0\text{,}02$ → $Q_d \approx 50$).
- **Dyspersja mikropasku** — $\varepsilon_{eff}$ rośnie z częstotliwością.
- **Rezonator zbyt mocno sprzężony** — Q obciążona dużo mniejsza od własnej, słaba selektywność.

## Ćwiczenie komputerowe

Odcinek zwarty jako cewka i dobroć rezonatora λ/4 z linii stratnej:

```python
import numpy as np

Z0, f0 = 50.0, 2.0e9
# odcinki linii jako elementy reaktancyjne (transformacja Richardsa): zwarty odcinek λ/8 = cewka, rozwarty = kondensator
for f in (1.0e9, 2.0e9, 3.0e9, 3.8e9):
    bl = np.pi/4*f/f0
    print(f"f = {f/1e9:.0f} GHz: zwarty λ/8 (Z0 = 50 Ω): X = {Z0*np.tan(bl):8.1f} Ω, cewka 3,98 nH: X = {2*np.pi*f*3.979e-9:6.1f} Ω")

# rezonator: zwarty odcinek λ/4 z tłumieniem — impedancja wejściowa w okolicy f0 (równoległy RLC)
alpha_dB_per_m, eps_eff = 2.0, 6.7                     # tłumienie linii i ε_eff (np. mikropasek na podłożu ceramicznym)
c = 2.99792458e8
lam_g = c/(f0*np.sqrt(eps_eff)); l = lam_g/4
alpha = alpha_dB_per_m/8.686
beta = 2*np.pi/lam_g
Q_theory = beta/(2*alpha)
f = np.linspace(1.9e9, 2.1e9, 200_001)
gam = alpha + 1j*2*np.pi*f*np.sqrt(eps_eff)/c
Zin = Z0*np.tanh(gam*l)
R = np.abs(Zin)
fpk = f[np.argmax(R)]; half = f[R >= R.max()/np.sqrt(2)]
Q_meas = fpk/(half[-1] - half[0])
print(f"rezonator λ/4: długość {l*1e3:.2f} mm, R w rezonansie {R.max()/1e3:.1f} kΩ, Q = {Q_meas:.0f} (teoria β/2α = {Q_theory:.0f})")
```

## Zadania

1. Jaka jest długość rozwartego odcinka mikropaskowego ($\varepsilon_{eff} = 3\text{,}3$), który przy 5 GHz ma reaktancję −50 Ω przy $Z_c = 50$ Ω?
2. Podłoże ma $\tan\delta = 0\text{,}002$, a straty przewodnika dają $Q_c = 300$. Ile wynosi $Q_0$ rezonatora (pomijając promieniowanie)?
3. Rezonator ma $Q_0 = 400$ i jest sprzężony tak, że $Q_L = 200$. Jakie jest $Q_{ext}$? Czy to sprzężenie krytyczne?
4. Dlaczego filtry z elementami λ/8 mają pasmo pasożytnicze przy $4f_c$?
5. Do czego służą tożsamości Kurody?

<details>
<summary>Odpowiedzi</summary>

1. $-50\cot\beta l = -50$ → $\beta l = 45°$ → $l = \lambda_g/8$, $\lambda_g = 0\text{,}06/\sqrt{3\text{,}3} = 33$ mm → $l \approx 4\text{,}1$ mm
2. $1/Q_0 = 1/300 + 0\text{,}002$ → $Q_0 = 187$
3. $1/Q_{ext} = 1/200 - 1/400$ → $Q_{ext} = 400 = Q_0$ — tak, sprzężenie krytyczne
4. Odpowiedź zależy od $\tan\beta l$, okresowej z okresem $\beta l = \pi$; przy $f = 4f_c$ długość λ/8 staje się λ/2 i odcinki zachowują się jak przy $f = 0$ — filtr znowu przepuszcza
5. Do przekształcania struktur z odcinkami szeregowymi (trudnymi do wykonania w liniach planarnych) w równoważne struktury z odcinkami równoległymi i liniami jednostkowymi oraz do rozdzielenia odcinków fizycznie
</details>

## Źródła

- [S. J. Orfanidis — Electromagnetic Waves and Antennas](https://www.ece.rutgers.edu/~orfanidi/ewa) — linie i rezonatory
- [MIT 6.632 Electromagnetic Wave Theory](https://ocw.mit.edu/courses/6-632-electromagnetic-wave-theory-spring-2003/) — falowody i rezonatory wnękowe
- D. M. Pozar — *Microwave Engineering* (płatna) — rozdziały 6 i 8
