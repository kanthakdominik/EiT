# 03.01 — Złącze p-n

## Po co to jest

Złącze p-n to podstawowa „cegiełka”: jest diodą, dwa złącza tworzą tranzystor bipolarny, złącza oddzielają dren i źródło MOSFET-a od podłoża. Zrozumienie warstwy zaporowej wyjaśnia, skąd bierze się napięcie przewodzenia ok. 0,6–0,7 V, pojemność złączowa i przebicie.

## Teoria w pigułce

### Złącze w równowadze

Po zetknięciu obszarów p i n nośniki większościowe dyfundują na drugą stronę i rekombinują. Przy granicy zostają nieskompensowane jony domieszek — powstaje **warstwa zaporowa** (zubożona) z polem elektrycznym, które hamuje dalszą dyfuzję. W równowadze prąd dyfuzji i prąd dryftu się równoważą.

**Napięcie dyfuzyjne (bariera potencjału):**

$$\varphi_0 = U_T\ln\frac{N_AN_D}{n_i^2}$$

Dla krzemu typowo 0,6–0,9 V. Tego napięcia nie da się zmierzyć woltomierzem — na stykach metal–półprzewodnik powstają napięcia kontaktowe, które je kompensują.

**Szerokość warstwy zaporowej** (złącze skokowe):

$$W = \sqrt{\frac{2\varepsilon_s(\varphi_0 + U_R)}{q}\left(\frac{1}{N_A} + \frac{1}{N_D}\right)}$$

$U_R$ — napięcie wsteczne. Warstwa wnika głębiej w obszar **słabiej** domieszkowany.

### Polaryzacja

- **W kierunku przewodzenia** ($p$ na plusie): bariera maleje o $U$, prąd dyfuzji rośnie wykładniczo — $I = I_S(e^{U/U_T} - 1)$.
- **W kierunku zaporowym**: bariera rośnie, płynie tylko mały prąd nasycenia $I_S$ (nośniki mniejszościowe generowane termicznie) plus prąd upływu.

### Pojemności

- **Złączowa (barierowa)** — warstwa zaporowa to „kondensator” o okładkach na krawędziach: $C_j = \dfrac{C_{j0}}{(1 + U_R/\varphi_0)^m}$, $m \approx 0\text{,}5$ dla złącza skokowego, ≈ 0,33 dla liniowego. Dominuje przy polaryzacji zaporowej (warykap, [03.03](03-diody-specjalne.md)).
- **Dyfuzyjna** — ładunek nośników mniejszościowych zgromadzony przy przewodzeniu, proporcjonalny do prądu. Dominuje przy przewodzeniu i decyduje o czasie wyłączania diody.

### Przebicie

- **Zenerowskie (tunelowe)** — w silnie domieszkowanych złączach, napięcia poniżej ok. 5 V, ujemny współczynnik temperaturowy.
- **Lawinowe** — jonizacja zderzeniowa, napięcia powyżej ok. 6 V, dodatni współczynnik temperaturowy.

Przy ok. 5–6 V oba efekty się kompensują — diody Zenera 5,1–5,6 V mają najmniejszy dryft temperaturowy.

## Przykład rozwiązany

Krzemowe złącze skokowe: $N_A = 10^{17}$ cm⁻³, $N_D = 10^{16}$ cm⁻³, $n_i = 10^{10}$ cm⁻³, 300 K, $\varepsilon_s = 11\text{,}7\varepsilon_0$.

1. $\varphi_0 = 0\text{,}02585\cdot\ln\dfrac{10^{33}}{10^{20}} = 0\text{,}02585\cdot 29\text{,}93 \approx 0\text{,}774$ V.
2. Bez polaryzacji: $W \approx 0\text{,}33\ \mu$m, z tego ok. 91% po stronie n (słabiej domieszkowanej).
3. Przy $U_R = 5$ V: $W$ rośnie $\sqrt{5\text{,}774/0\text{,}774} \approx 2\text{,}7$ razy, do ≈ 0,91 µm.
4. Pojemność na jednostkę powierzchni $C = \varepsilon_s/W$: ≈ 312 pF/mm² bez polaryzacji i ≈ 114 pF/mm² przy 5 V.

## Typowe pułapki

- **Napięcie dyfuzyjne mylone z napięciem przewodzenia.** 0,7 V przy przewodzeniu to napięcie, przy którym prąd staje się „użyteczny”, a nie wysokość bariery.
- **Warstwa zaporowa równo po obu stronach.** Wnika głównie w obszar słabiej domieszkowany.
- **Prąd wsteczny jako stały $I_S$.** W rzeczywistych diodach dominuje prąd upływu i generacji, który rośnie z napięciem i silnie z temperaturą (ok. dwukrotnie co 10 K).

## Ćwiczenie komputerowe

```python
import numpy as np, matplotlib.pyplot as plt
q, eps = 1.602e-19, 11.7*8.854e-12
NA, ND, phi = 1e23, 1e22, 0.774        # m^-3, V
UR = np.linspace(0, 20, 200)
W = np.sqrt(2*eps*(phi + UR)/q*(1/NA + 1/ND))
plt.plot(UR, eps/W*1e-6*1e12); plt.xlabel("U_R [V]"); plt.ylabel("C [pF/mm²]"); plt.grid(); plt.show()
```

## Zadania

1. Wyznacz napięcie dyfuzyjne złącza $N_A = N_D = 10^{16}$ cm⁻³ w 300 K.
2. Złącze z przykładu: ile razy wzrośnie szerokość warstwy zaporowej przy $U_R = 20$ V w porównaniu ze stanem bez polaryzacji?
3. Dioda ma $C_{j0} = 10$ pF, $\varphi_0 = 0\text{,}7$ V, $m = 0\text{,}5$. Jaka jest pojemność przy napięciu wstecznym 5 V?
4. Prąd wsteczny diody wynosi 5 nA w 25 °C. Oszacuj go w 85 °C.
5. Dlaczego dioda Zenera 3,3 V ma inny znak współczynnika temperaturowego niż dioda 12 V?

<details>
<summary>Odpowiedzi</summary>

1. $0\text{,}02585\ln(10^{32}/10^{20}) = 0\text{,}02585\cdot 27\text{,}6 \approx 0\text{,}714$ V
2. $\sqrt{20\text{,}774/0\text{,}774} \approx 5\text{,}2$ razy
3. $10/\sqrt{1 + 5/0\text{,}7} \approx 3\text{,}5$ pF
4. 60 K to 6 podwojeń: $5\cdot 64 = 320$ nA (oszacowanie)
5. Przy 3,3 V dominuje przebicie Zenera (tunelowe) z ujemnym współczynnikiem, przy 12 V — lawinowe z dodatnim
</details>

## Źródła

- [MIT 6.012 Microelectronic Devices and Circuits](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-spring-2009/) — wykłady o złączu p-n w równowadze i pod polaryzacją
- [Semiconductor Devices — J. M. Fiore, rozdziały 1–2](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html)
- [All About Circuits — tom Semiconductors, rozdziały o teorii przyrządów i diodach](https://www.allaboutcircuits.com/textbook/)
