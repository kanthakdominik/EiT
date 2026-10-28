# 00.01 — Liczby zespolone

## Po co to jest

Liczby zespolone zamieniają równania różniczkowe obwodów prądu zmiennego w zwykłą algebrę. Impedancja, fazor, transmitancja, widmo sygnału i konstelacja modulacji QAM — wszystko to są liczby zespolone. W elektrotechnice jednostkę urojoną oznacza się literą $j$, bo $i$ jest zarezerwowane dla prądu.

## Teoria w pigułce

Liczba zespolona ma trzy równoważne postacie:

| Postać | Zapis | Kiedy wygodna |
|---|---|---|
| Algebraiczna | $z = a + jb$ | Dodawanie i odejmowanie |
| Trygonometryczna | $z = \lvert z\rvert(\cos\varphi + j\sin\varphi)$ | Przejście między postaciami |
| Wykładnicza (biegunowa) | $z = \lvert z\rvert e^{j\varphi} = \lvert z\rvert\angle\varphi$ | Mnożenie, dzielenie, potęgowanie |

Łączy je **wzór Eulera**:

$$e^{j\varphi} = \cos\varphi + j\sin\varphi$$

Z niego wynika, że $\cos\varphi = \dfrac{e^{j\varphi} + e^{-j\varphi}}{2}$ oraz $\sin\varphi = \dfrac{e^{j\varphi} - e^{-j\varphi}}{2j}$. Te dwa wzory są podstawą widma sygnałów: każda sinusoida to para wektorów wirujących w przeciwnych kierunkach.

**Interpretacja geometryczna:** mnożenie przez $e^{j\varphi}$ to obrót o kąt $\varphi$. Mnożenie przez $j$ to obrót o 90°. Dlatego napięcie na cewce ($Z_L = j\omega L$) wyprzedza prąd o 90°, a na kondensatorze ($Z_C = \dfrac{1}{j\omega C} = -\dfrac{j}{\omega C}$) się opóźnia.

## Wzory i założenia

| Działanie | Wzór |
|---|---|
| Moduł | $\lvert z\rvert = \sqrt{a^2 + b^2}$ |
| Argument | $\varphi = \operatorname{atan2}(b, a)$ — **uwaga na ćwiartkę!** |
| Postać algebraiczna z biegunowej | $a = \lvert z\rvert\cos\varphi$, $b = \lvert z\rvert\sin\varphi$ |
| Sprzężenie | $z^* = a - jb = \lvert z\rvert e^{-j\varphi}$, $z \cdot z^* = \lvert z\rvert^2$ |
| Mnożenie | $\lvert z_1 z_2\rvert = \lvert z_1\rvert\lvert z_2\rvert$, $\arg(z_1 z_2) = \varphi_1 + \varphi_2$ |
| Dzielenie | $\dfrac{z_1}{z_2} = \dfrac{z_1 z_2^*}{\lvert z_2\rvert^2}$ lub moduły dzielimy, argumenty odejmujemy |
| Potęga (de Moivre) | $z^n = \lvert z\rvert^n e^{jn\varphi}$ |
| Pierwiastki stopnia $n$ | $\sqrt[n]{\lvert z\rvert}\, e^{j(\varphi + 2k\pi)/n}$, $k = 0, \dots, n-1$ |

## Przykład rozwiązany

Oblicz $Z = \dfrac{(3 + j4)(1 - j)}{2 + j}$ i podaj wynik w obu postaciach.

1. Licznik: $(3 + j4)(1 - j) = 3 - 3j + 4j - 4j^2 = 3 + j + 4 = 7 + j$.
2. Dzielenie przez $2 + j$ — mnożymy przez sprzężenie mianownika:
   $\dfrac{(7 + j)(2 - j)}{(2 + j)(2 - j)} = \dfrac{14 - 7j + 2j - j^2}{5} = \dfrac{15 - 5j}{5} = 3 - j$.
3. Postać biegunowa: $\lvert Z\rvert = \sqrt{10} \approx 3{,}162$, $\varphi = \operatorname{atan2}(-1, 3) \approx -18{,}43^\circ$.

Wynik: $Z = 3 - j = 3{,}162\angle -18{,}43^\circ$.

## Typowe pułapki

- **Argument z samego $\arctan(b/a)$.** Dla $z = -1 - j$ daje 45°, a poprawny wynik to −135°. Zawsze sprawdź ćwiartkę albo używaj `atan2`.
- **Mieszanie stopni i radianów.** W wykładniku $e^{j\varphi}$ kąt jest w radianach. Kalkulator i Python (`np.angle`) zwracają radiany.
- **Dodawanie w postaci biegunowej.** $5\angle 0^\circ + 5\angle 90^\circ \neq 10\angle 45^\circ$. Poprawnie: $5 + j5 = 7{,}07\angle 45^\circ$.
- **Zapominanie, że $j^2 = -1$** przy wymnażaniu nawiasów.
- **$1/j = -j$**, a nie $j$.

## Symulacja / ćwiczenie komputerowe

```python
import numpy as np

z1 = 10 * np.exp(1j * np.radians(30))   # 10∠30°
z2 = 2 * np.exp(1j * np.radians(-60))   # 2∠-60°
w = z1 / z2
print(f"{abs(w):.3f} ∠ {np.degrees(np.angle(w)):.2f}°")   # 5.000 ∠ 90.00°
```

Ćwiczenie: narysuj w Matplotlib na płaszczyźnie zespolonej wektory $z_1$, $z_2$, $z_1 + z_2$ i $z_1 z_2$. Zobacz, że dodawanie to składanie wektorów, a mnożenie to obrót i skalowanie.

## Zadania

1. Zamień $5\angle 53{,}13^\circ$ na postać algebraiczną.
2. Oblicz $(1 + j)^8$.
3. Wyznacz wszystkie rozwiązania równania $z^3 = 8j$.
4. Oblicz impedancję $Z = R + j\left(\omega L - \dfrac{1}{\omega C}\right)$ dla $R = 10\ \Omega$, $L = 20$ mH, $C = 100\ \mu$F, $\omega = 1000$ rad/s. Podaj obie postacie.
5. Zapisz $10\cos(\omega t) + 10\sin(\omega t)$ jako jedną funkcję $A\cos(\omega t + \varphi)$, używając fazorów.
6. Wykaż, że $e^{j\theta} + e^{-j\theta} = 2\cos\theta$.

<details>
<summary>Odpowiedzi</summary>

1. $3 + j4$
2. $(\sqrt{2}e^{j\pi/4})^8 = 16e^{j2\pi} = 16$
3. $8j = 8e^{j\pi/2}$, więc $z_k = 2e^{j(\pi/6 + 2k\pi/3)}$: $2\angle 30^\circ = \sqrt{3} + j$, $2\angle 150^\circ = -\sqrt{3} + j$, $2\angle 270^\circ = -2j$
4. $\omega L = 20\ \Omega$, $\dfrac{1}{\omega C} = 10\ \Omega$, $Z = 10 + j10 = 14{,}14\angle 45^\circ\ \Omega$
5. Fazory: $10\angle 0^\circ + 10\angle -90^\circ = 10 - j10 = 14{,}14\angle -45^\circ$, czyli $14{,}14\cos(\omega t - 45^\circ)$
6. Ze wzoru Eulera: $(\cos\theta + j\sin\theta) + (\cos\theta - j\sin\theta) = 2\cos\theta$
</details>

## Źródła

- [Khan Academy — Electrical Engineering, AC circuit analysis](https://www.khanacademy.org/science/electrical-engineering) — seria o liczbach zespolonych, wzorze Eulera i obrocie przez $j$
- [All About Circuits — tom AC, rozdział *Complex Numbers*](https://www.allaboutcircuits.com/textbook/)
- [AC Electrical Circuit Analysis — J. M. Fiore](https://eng.libretexts.org/Bookshelves/Electrical_Engineering/Electronics/AC_Electrical_Circuit_Analysis%3A_A_Practical_Approach_%28Fiore%29) — rozdział wprowadzający o liczbach zespolonych w obwodach
- [3Blue1Brown](https://www.3blue1brown.com/) — wizualizacje wzoru Eulera i mnożenia jako obrotu
