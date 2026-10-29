# 02.05 — Pasma energetyczne i półprzewodniki

## Po co to jest

Wszystkie przyrządy półprzewodnikowe — diody, tranzystory, LED-y, fotodiody, ogniwa słoneczne — działają dzięki temu, że w półprzewodniku można sterować liczbą i rodzajem nośników ładunku przez domieszkowanie, temperaturę, światło i pole elektryczne.

## Teoria w pigułce

### Model pasmowy

W krysztale dozwolone poziomy energii elektronów tworzą pasma:

- **pasmo walencyjne** — elektrony związane z atomami,
- **pasmo przewodnictwa** — elektrony swobodne,
- **przerwa energetyczna** $E_g$ — energii z tego zakresu elektron mieć nie może.

| Materiał | $E_g$ [eV] w 300 K | Zastosowanie |
|---|---|---|
| Przewodnik | brak przerwy (pasma się nakładają) | — |
| Ge | 0,66 | Dawne tranzystory, detektory podczerwieni |
| Si | 1,12 | Większość elektroniki |
| GaAs | 1,42 | Układy w.cz., LED podczerwone |
| SiC | ok. 3,3 | Elektronika mocy wysokiego napięcia |
| GaN | 3,4 | Tranzystory mocy, niebieskie LED |
| Izolator (SiO₂) | ok. 9 | Dielektryk bramki MOSFET |

### Półprzewodnik samoistny

Energia cieplna przenosi część elektronów do pasma przewodnictwa. Każdy taki elektron zostawia w paśmie walencyjnym **dziurę** — brak elektronu, który zachowuje się jak dodatni nośnik. W półprzewodniku samoistnym $n = p = n_i$. Dla krzemu w 300 K $n_i \approx 10^{10}$ cm⁻³ (atomów jest ok. $5\cdot 10^{22}$ cm⁻³). $n_i$ rośnie bardzo szybko z temperaturą (w przybliżeniu jak $e^{-E_g/2kT}$).

### Domieszkowanie

- **Typ n** — domieszka donorowa (grupa V: P, As), oddaje elektron. Nośniki większościowe: elektrony.
- **Typ p** — domieszka akceptorowa (grupa III: B), przyjmuje elektron, tworząc dziurę. Nośniki większościowe: dziury.

**Prawo działania mas** (w równowadze termicznej):

$$np = n_i^2$$

Dla typu n przy $N_D \gg n_i$: $n \approx N_D$, $p \approx n_i^2/N_D$.

**Poziom Fermiego** $E_F$ — poziom energii, którego prawdopodobieństwo obsadzenia wynosi 1/2. W typie n leży bliżej pasma przewodnictwa, w typie p — bliżej walencyjnego. W złączu p-n poziomy Fermiego wyrównują się, co tworzy barierę potencjału ([03.01](../03-przyrzady-polprzewodnikowe/01-zlacze-pn.md)).

**Napięcie termiczne:** $U_T = \dfrac{kT}{q} \approx 25\text{,}85$ mV w 300 K. Pojawia się w każdym wzorze dla diody i tranzystora bipolarnego.

### Półprzewodniki a światło

Foton o energii $h\nu > E_g$ może wygenerować parę elektron–dziura (fotodioda, ogniwo słoneczne). Rekombinacja w półprzewodniku z prostą przerwą (GaAs, GaN) emituje foton o energii ≈ $E_g$ (LED). Długość fali: $\lambda[\mu\text{m}] \approx 1\text{,}24/E_g[\text{eV}]$.

## Przykład rozwiązany

Krzem typu n, $N_D = 10^{16}$ cm⁻³, 300 K, $n_i = 10^{10}$ cm⁻³.

1. $n \approx N_D = 10^{16}$ cm⁻³.
2. $p = n_i^2/n = 10^{20}/10^{16} = 10^4$ cm⁻³ — dwanaście rzędów wielkości mniej.
3. Rezystywność (ruchliwość elektronów ≈ 1350 cm²/V·s): $\rho = \dfrac{1}{qn\mu_n} \approx \dfrac{1}{1\text{,}6\cdot 10^{-19}\cdot 10^{16}\cdot 1350} \approx 0\text{,}46$ Ω·cm.

## Typowe pułapki

- **Dziura jako „cząstka dodatnia” poruszająca się niezależnie od elektronów** — to wygodny model ruchu brakującego elektronu w paśmie walencyjnym.
- **Półprzewodnik domieszkowany jako naładowany.** Jest elektrycznie obojętny — jony domieszek kompensują ładunek nośników.
- **Pomylenie jednostek** cm⁻³ i m⁻³ (czynnik $10^6$).

## Ćwiczenie komputerowe

```python
import numpy as np
k, q = 1.380649e-23, 1.602e-19
for T in [250, 300, 350, 400]:
    print(T, "K: U_T =", round(k*T/q*1e3, 2), "mV")
# λ emisji LED z przerwy energetycznej
for name, Eg in [("GaAs", 1.42), ("GaN", 3.4)]:
    print(name, round(1.24/Eg*1e3), "nm")
```

## Zadania

1. Krzem typu n z $N_D = 10^{16}$ cm⁻³. Wyznacz koncentrację dziur w 300 K.
2. Krzem typu p z $N_A = 10^{17}$ cm⁻³. Wyznacz $p$ i $n$.
3. Ile wynosi $U_T$ w temperaturze 85 °C?
4. Jaką długość fali emituje LED z GaN ($E_g = 3\text{,}4$ eV)? Jaki jest maksymalny zakres długości fal, które wykryje fotodioda krzemowa?
5. Dlaczego elementy krzemowe pracują do ok. 150–175 °C, a elementy z SiC i GaN mogą pracować w wyższej temperaturze?

<details>
<summary>Odpowiedzi</summary>

1. $p = 10^4$ cm⁻³
2. $p \approx 10^{17}$ cm⁻³, $n = 10^{20}/10^{17} = 10^3$ cm⁻³
3. $U_T = kT/q$ przy 358 K ≈ 30,9 mV
4. ≈ 365 nm (ultrafiolet; białe LED-y to niebieskie/UV z luminoforem); krzem wykrywa do $1\text{,}24/1\text{,}12 \approx 1\text{,}1\ \mu$m
5. W wysokiej temperaturze $n_i$ rośnie tak bardzo, że przestaje być pomijalne wobec koncentracji domieszek i przyrząd traci właściwości. Szersza przerwa energetyczna SiC i GaN daje wielokrotnie mniejsze $n_i$ w tej samej temperaturze.
</details>

## Źródła

- [MIT 6.012 Microelectronic Devices and Circuits](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-spring-2009/) — wykłady o półprzewodnikach w równowadze
- [Semiconductor Devices — J. M. Fiore, rozdział 1](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html) — przystępne wprowadzenie do fizyki półprzewodników
- [LibreTexts — Intrinsic Carrier Concentration](https://eng.libretexts.org/Bookshelves/Materials_Science/Supplemental_Modules_%28Materials_Science%29/Solar_Basics/C._Semiconductors_and_Solar_Interactions/II._Conduction_in_Semiconductors/1._Intrinsic_Carrier_Concentration)
- [All About Circuits — tom Semiconductors, rozdział o teorii przyrządów półprzewodnikowych](https://www.allaboutcircuits.com/textbook/)
