# 02.01 — Elektrostatyka i pojemność

## Po co to jest

Pole elektryczne wyjaśnia, jak działa kondensator, skąd bierze się pojemność pasożytnicza między ścieżkami, dlaczego złącze p-n ma warstwę zaporową i jak tranzystor MOSFET steruje kanałem napięciem bramki.

## Teoria w pigułce

**Prawo Coulomba:** $F = \dfrac{1}{4\pi\varepsilon_0}\dfrac{q_1q_2}{r^2}$, $\dfrac{1}{4\pi\varepsilon_0} \approx 8\text{,}99\cdot 10^9$ N·m²/C².

**Natężenie pola** $\mathbf{E} = \mathbf{F}/q$ [V/m]. Pole kilku ładunków to suma wektorowa (superpozycja).

**Potencjał** $V$ i napięcie: $U_{AB} = V_A - V_B = \int_A^B \mathbf{E}\cdot d\mathbf{l}$; lokalnie $\mathbf{E} = -\nabla V$. Pole „spływa” od wyższego potencjału do niższego.

**Prawo Gaussa:** strumień pola elektrycznego przez zamkniętą powierzchnię jest proporcjonalny do ładunku wewnątrz:

$$\oint_S \mathbf{D}\cdot d\mathbf{S} = Q_{wewn}, \qquad \mathbf{D} = \varepsilon_0\varepsilon_r\mathbf{E}$$

**Przewodnik w polu elektrostatycznym:** wewnątrz $\mathbf{E} = 0$, cały ładunek na powierzchni, powierzchnia jest ekwipotencjalna. Stąd działanie ekranów (klatka Faradaya).

**Dielektryk:** pole polaryzuje cząsteczki, co osłabia pole wewnątrz $\varepsilon_r$ razy. Przy zbyt dużym polu następuje przebicie (wytrzymałość dielektryczna, np. powietrze ≈ 3 MV/m).

**Pojemność:** $C = Q/U$.

| Układ | Pojemność |
|---|---|
| Kondensator płaski | $C = \dfrac{\varepsilon_0\varepsilon_r A}{d}$ |
| Kondensator cylindryczny (kabel koncentryczny), długość $l$ | $C = \dfrac{2\pi\varepsilon_0\varepsilon_r l}{\ln(b/a)}$ |
| Kula o promieniu $R$ | $C = 4\pi\varepsilon_0 R$ |

$\varepsilon_0 \approx 8\text{,}854$ pF/m.

**Energia zgromadzona:** $W = \tfrac12 CU^2$, gęstość energii pola $w = \tfrac12\varepsilon E^2$.

## Przykład rozwiązany

Kondensator płaski: okładki 1 cm², odstęp 0,1 mm, dielektryk $\varepsilon_r = 4$ (laminat FR-4), napięcie 50 V.

1. $C = \dfrac{8\text{,}854\cdot 10^{-12}\cdot 4\cdot 10^{-4}}{10^{-4}} \approx 35\text{,}4$ pF.
2. Pole: $E = U/d = 50/10^{-4} = 0\text{,}5$ MV/m — dużo poniżej wytrzymałości FR-4 (rzędu 20 MV/m).
3. Energia: $W = \tfrac12\cdot 35\text{,}4\cdot 10^{-12}\cdot 50^2 \approx 44$ nJ.

To jednocześnie oszacowanie pojemności między polem miedzi na wierzchu płytki a płaszczyzną masy pod nią — pojemności pasożytnicze PCB są rzędu pF/cm².

## Typowe pułapki

- **Mylenie potencjału z napięciem.** Potencjał zależy od wyboru punktu odniesienia, napięcie (różnica potencjałów) — nie.
- **Wzór na kondensator płaski bez założeń.** Obowiązuje, gdy $d \ll$ wymiary okładek (pomija efekt brzegowy).
- **Kondensatory szeregowo traktowane jak rezystory szeregowo.** Pojemności łączone szeregowo dodaje się odwrotnościami.

## Ćwiczenie komputerowe

```python
import numpy as np
eps0 = 8.854e-12
# pojemność 1 m kabla koncentrycznego RG-58: a=0.45 mm, b=1.47 mm, PE eps_r=2.25
a, b, er = 0.45e-3, 1.47e-3, 2.25
print(2*np.pi*eps0*er/np.log(b/a)*1e12, "pF/m")   # ≈ 106 pF/m (katalogowo ok. 100 pF/m)
```

W [Falstad — symulacje elektrostatyki](https://www.falstad.com/mathphysics.html) obejrzyj linie pola dla układów ładunków i przewodników.

## Zadania

1. Dwa ładunki po 1 µC w odległości 10 cm. Jaka siła na siebie działa?
2. Kondensator płaski 35,4 pF ($A = 1$ cm², $d = 0\text{,}1$ mm, $\varepsilon_r = 4$). Jak zmieni się pojemność, jeśli zmniejszysz odstęp o połowę i usuniesz dielektryk?
3. Jaką pojemność ma 1 m kabla koncentrycznego o promieniach 0,45 mm i 1,47 mm z polietylenem ($\varepsilon_r = 2\text{,}25$)?
4. Kondensator 1000 µF naładowany do 400 V. Jaka energia jest zgromadzona i dlaczego jest groźny?
5. Dwa kondensatory 10 nF i 40 nF połączone szeregowo dołączono do 50 V. Wyznacz napięcie na każdym.
6. Wyjaśnij, dlaczego wewnątrz metalowej obudowy pole elektrostatyczne z zewnątrz jest zerowe.

<details>
<summary>Odpowiedzi</summary>

1. $F = 8\text{,}99\cdot 10^9\cdot\dfrac{10^{-12}}{0\text{,}01} \approx 0\text{,}9$ N
2. $C' = C\cdot\dfrac{2}{4} = 17\text{,}7$ pF (dwukrotnie mniejszy odstęp: ×2; brak dielektryka: ÷4)
3. $\approx 106$ pF
4. $W = \tfrac12\cdot 10^{-3}\cdot 400^2 = 80$ J — może dostarczyć bardzo duży prąd w krótkim czasie, napięcie groźne dla życia, utrzymuje się długo po odłączeniu zasilania
5. Ładunek jednakowy: $C_z = 8$ nF, $Q = 400$ nC; $U_1 = 40$ V na 10 nF, $U_2 = 10$ V na 40 nF (większe napięcie na mniejszej pojemności)
6. Ładunki swobodne w metalu przesuwają się tak, by skompensować pole wewnątrz przewodnika; wnęka otoczona przewodnikiem bez ładunków w środku ma stały potencjał, więc $\mathbf{E} = 0$
</details>

## Źródła

- [MIT 8.02 Physics II: Electricity and Magnetism](https://ocw.mit.edu/courses/8-02-physics-ii-electricity-and-magnetism-spring-2007/) — podręcznik kursu: pole elektryczne, prawo Gaussa, potencjał, pojemność i dielektryki
- [Electromagnetics, Vol. 1 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-1) — rozdział o elektrostatyce, pojemność linii koncentrycznej
- [Khan Academy — Electrical Engineering](https://www.khanacademy.org/science/electrical-engineering) — dział o elektrostatyce
