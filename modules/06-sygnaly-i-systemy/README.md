# 06 — Sygnały i systemy

> **Status:** ✅ pełny

## Cel modułu

Opisywać sygnały i układy liniowe w dziedzinie czasu i częstotliwości, w czasie ciągłym i dyskretnym. To wspólny język cyfrowego przetwarzania sygnałów, telekomunikacji i automatyki. Po tym module swobodnie przechodzisz między odpowiedzią impulsową, transmitancją i widmem.

## Wymagania wstępne

- [00 Matematyka](../00-matematyka/): liczby zespolone, całki, równania różniczkowe, [szeregi Fouriera i transformata Laplace'a](../00-matematyka/05-szeregi-i-transformaty.md), [prawdopodobieństwo](../00-matematyka/06-prawdopodobienstwo-i-statystyka.md) (temat 08).
- [01 Teoria obwodów](../01-teoria-obwodow/): analiza AC, charakterystyki częstotliwościowe, [metoda operatorowa](../01-teoria-obwodow/08-laplace-w-obwodach.md).

## Tematy

| # | Temat | Czas (od zera / odświeżenie) |
|---|---|---|
| 01 | [Sygnały: klasyfikacja i operacje](01-sygnaly.md) | 6 h / 1 h |
| 02 | [Układy LTI, odpowiedź impulsowa i splot](02-uklady-lti-i-splot.md) | 10 h / 3 h |
| 03 | [Szereg Fouriera](03-szereg-fouriera.md) | 8 h / 2 h |
| 04 | [Przekształcenie Fouriera](04-przeksztalcenie-fouriera.md) | 10 h / 3 h |
| 05 | [Transmitancja, bieguny i zera, stabilność](05-transmitancja-i-bieguny.md) | 8 h / 3 h |
| 06 | [Próbkowanie i rekonstrukcja](06-probkowanie.md) | 8 h / 3 h |
| 07 | [Układy dyskretne i transformata Z](07-czas-dyskretny-i-transformata-z.md) | 12 h / 4 h |
| 08 | [Sygnały losowe i szum](08-sygnaly-losowe.md) | 8 h / 3 h |

## Test wejściowy (diagnoza)

Około 60 minut, bez notatek.

1. Czy układ $y(t) = 2x(t) + 3$ jest liniowy? Czy $y(t) = x(t - 2)$ jest stacjonarny?
2. Oblicz splot dyskretny $[1, 2, 3] * [1, 1]$.
3. Jaka część mocy fali prostokątnej ±1 przypada na składową podstawową?
4. Impuls prostokątny ma czas trwania 1 µs. Przy jakiej częstotliwości jego widmo ma pierwsze zero?
5. Gdzie leżą bieguny układu $H(s) = \dfrac{1}{s^2 + s - 2}$? Czy jest stabilny?
6. Sygnał 30 kHz spróbkowano z częstotliwością 44,1 kHz. Jaka częstotliwość pojawi się po rekonstrukcji?
7. Układ dyskretny $y[n] = 0{,}5y[n-1] + x[n]$. Wyznacz transmitancję $H(z)$, odpowiedź impulsową i wzmocnienie dla składowej stałej.

<details>
<summary>Odpowiedzi</summary>

1. Nie (nie spełnia jednorodności: $x = 0$ daje $y = 3$); tak
2. $[1, 3, 5, 3]$
3. $\dfrac{(4/\pi)^2/2}{1} \approx 81\%$
4. 1 MHz
5. $s = 1$ i $s = -2$; niestabilny (biegun w prawej półpłaszczyźnie)
6. 14,1 kHz (aliasing)
7. $H(z) = \dfrac{1}{1 - 0{,}5z^{-1}}$, $h[n] = 0{,}5^n u[n]$, $H(1) = 2$

**Ocena:** zadania 1–2 — tematy 01–02; 3–4 — tematy 03–04; 5 — temat 05; 6 — temat 06; 7 — temat 07.
</details>

## Projekt modułowy: od obwodu do widma i z powrotem

Notatnik Jupyter, w którym dla filtra RC i szeregowego RLC:

- [ ] wyznaczasz analitycznie transmitancję $H(s)$, bieguny, odpowiedź impulsową i skokową,
- [ ] rysujesz wykres Bodego (`scipy.signal.bode`) i porównujesz z LTspice (`.ac`),
- [ ] liczysz odpowiedź na falę prostokątną trzema sposobami: splotem numerycznym, sumą odpowiedzi na harmoniczne szeregu Fouriera, `scipy.signal.lsim` — i porównujesz z LTspice (`.tran`),
- [ ] dyskretyzujesz filtr (`scipy.signal.cont2discrete`, metoda biliniowa) i porównujesz charakterystyki dla kilku częstotliwości próbkowania,
- [ ] próbkujesz sinusoidę bliską $f_s/2$ i powyżej — pokazujesz aliasing w czasie i w widmie.

## Sprawdzian końcowy modułu

- [ ] Sprawdzam liniowość, stacjonarność, przyczynowość i stabilność układu z jego opisu.
- [ ] Liczę splot ciągły i dyskretny ręcznie (metodą graficzną) i w NumPy.
- [ ] Wyznaczam współczynniki szeregu Fouriera i wiem, które harmoniczne przejdą przez dany filtr.
- [ ] Korzystam z własności przekształcenia Fouriera (przesunięcie, modulacja, skalowanie, splot).
- [ ] Odczytuję charakter odpowiedzi z położenia biegunów w $s$ i w $z$.
- [ ] Dobieram częstotliwość próbkowania i filtr antyaliasingowy.
- [ ] Szacuję szum na wyjściu filtra przy znanej gęstości widmowej na wejściu.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [MIT 6.003 Signals and Systems (2011)](https://ocw.mit.edu/courses/6-003-signals-and-systems-fall-2011/) | Cały moduł: wideo, notatki, zadania z rozwiązaniami |
| [MIT RES.6-007 Signals and Systems (Oppenheim)](https://ocw.mit.edu/courses/res-6-007-signals-and-systems-spring-2011/) | Klasyczne wykłady wideo: splot, Fourier, próbkowanie, modulacja, transformata Z, sprzężenie zwrotne |
| [Fundamentals of Electrical Engineering I — D. Johnson](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-electrical-engineering-1) | Darmowy podręcznik: sygnały, analiza częstotliwościowa, próbkowanie |
| [The Scientist and Engineer's Guide to DSP — S. W. Smith](http://www.dspguide.com/) | Splot, Fourier i statystyka sygnałów z małą ilością matematyki |
| [Think DSP — A. Downey](https://greenteapress.com/wp/think-dsp/) | Darmowa książka z kodem w Pythonie — sygnały, widma, splot, filtry |
