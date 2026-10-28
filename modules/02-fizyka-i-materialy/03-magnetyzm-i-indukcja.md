# 02.03 — Magnetyzm i indukcja elektromagnetyczna

## Po co to jest

Z pola magnetycznego wynikają cewki, transformatory, przekaźniki, silniki, czujniki Halla i prądowe. Prawo Faradaya tłumaczy przepięcia przy wyłączaniu obciążeń indukcyjnych i to, dlaczego pętle prądowe na PCB zbierają zakłócenia.

## Teoria w pigułce

**Siła Lorentza:** $\mathbf{F} = q(\mathbf{E} + \mathbf{v}\times\mathbf{B})$. Na przewód z prądem w polu: $\mathbf{F} = I\,\mathbf{l}\times\mathbf{B}$ (zasada silnika).

**Źródła pola magnetycznego** — prądy:

| Układ | Indukcja $B$ |
|---|---|
| Długi prosty przewód, odległość $r$ | $B = \dfrac{\mu_0 I}{2\pi r}$ |
| Środek pętli o promieniu $R$ | $B = \dfrac{\mu_0 I}{2R}$ |
| Wnętrze długiej cewki ($N$ zwojów, długość $l$) | $B = \mu_0\mu_r\dfrac{NI}{l}$ |

$\mu_0 = 4\pi\cdot 10^{-7}$ H/m. Kierunek — reguła prawej dłoni.

**Prawo Ampère'a:** $\oint\mathbf{H}\cdot d\mathbf{l} = I_{obj}$, $\mathbf{B} = \mu_0\mu_r\mathbf{H}$.

**Strumień magnetyczny:** $\Phi = \int\mathbf{B}\cdot d\mathbf{S}$ [Wb].

**Prawo Faradaya (z regułą Lenza):**

$$e = -N\frac{d\Phi}{dt}$$

Indukowane napięcie przeciwdziała zmianie strumienia, która je wywołała.

**Indukcyjność:** $L = \dfrac{N\Phi}{I}$. Dla cewki cylindrycznej (długiej): $L = \mu_0\mu_r\dfrac{N^2 A}{l}$. Dla rdzenia toroidalnego producent podaje współczynnik $A_L$: $L = A_L N^2$.

**Energia pola magnetycznego:** $W = \tfrac12 LI^2$.

**Materiały magnetyczne:**
- diamagnetyki i paramagnetyki — $\mu_r \approx 1$,
- ferromagnetyki (żelazo, ferryty) — $\mu_r$ od setek do dziesiątek tysięcy, **nieliniowość, histereza i nasycenie**: powyżej indukcji nasycenia $B_{sat}$ przenikalność gwałtownie spada i indukcyjność „znika”.

## Przykład rozwiązany

Cewka powietrzna: 100 zwojów na długości 2 cm, przekrój 1 cm², prąd 0,5 A.

1. $L = 4\pi\cdot 10^{-7}\cdot\dfrac{100^2\cdot 10^{-4}}{0{,}02} \approx 62{,}8\ \mu$H.
2. $B = 4\pi\cdot 10^{-7}\cdot\dfrac{100\cdot 0{,}5}{0{,}02} \approx 3{,}1$ mT.
3. Energia: $W = \tfrac12\cdot 62{,}8\cdot 10^{-6}\cdot 0{,}25 \approx 7{,}9\ \mu$J.

Z rdzeniem ferrytowym o $\mu_r = 1000$ (bez szczeliny) indukcyjność wzrosłaby do ok. 63 mH — ale przy znacznie mniejszym prądzie rdzeń by się nasycił.

## Typowe pułapki

- **Indukcyjność cewki z rdzeniem traktowana jako stała** — zależy od prądu (nasycenie). W przetwornicach kluczowy parametr dławika to prąd nasycenia.
- **Wzór na długą cewkę dla krótkiej cewki** — daje zawyżony wynik.
- **Pole wokół przewodu** maleje jak $1/r$, a pole pary przewodów z prądem w przeciwnych kierunkach — dużo szybciej. Dlatego przewody zasilania prowadzi się parami, blisko siebie.

## Ćwiczenie komputerowe

Zmierz (lub zasymuluj w [Falstad](https://www.falstad.com/mathphysics.html)) napięcie indukowane w pętli przez zmienny prąd w sąsiednim przewodzie. Oszacuj z prawa Faradaya napięcie zakłócenia indukowane w pętli o powierzchni 10 cm² przez pole 1 µT o częstotliwości 1 MHz.

```python
import numpy as np
A, B0, f = 10e-4, 1e-6, 1e6
print("amplituda SEM:", 2*np.pi*f*B0*A*1e3, "mV")   # ≈ 6.3 mV
```

## Zadania

1. Jakie jest pole $B$ w odległości 1 cm od przewodu z prądem 10 A? Porównaj z polem Ziemi (ok. 50 µT).
2. Policz indukcyjność cewki powietrznej: 100 zwojów, długość 2 cm, przekrój 1 cm².
3. Rdzeń toroidalny ma $A_L = 250$ nH/zw². Ile zwojów trzeba nawinąć, aby uzyskać 100 µH?
4. Strumień w uzwojeniu 50-zwojowym zmienia się liniowo o 2 mWb w ciągu 1 ms. Jakie napięcie się indukuje?
5. Przez cewkę 10 mH płynie 1 A. Prąd zostaje przerwany w ciągu 1 µs. Jakie napięcie (średnio) pojawi się na cewce?
6. Dlaczego rdzenie transformatorów sieciowych wykonuje się z cienkich, izolowanych blach, a rdzenie przetwornic — z ferrytów?

<details>
<summary>Odpowiedzi</summary>

1. 200 µT — czterokrotnie więcej niż pole Ziemi
2. ≈ 62,8 µH
3. $N = \sqrt{100\ \mu\text{H}/250\ \text{nH}} = 20$ zwojów
4. $e = 50\cdot\dfrac{2\cdot 10^{-3}}{10^{-3}} = 100$ V
5. $u = L\,\Delta i/\Delta t = 10^{-2}\cdot 10^6 = 10$ kV — stąd konieczność diody gaszącej lub tłumika
6. Zmienny strumień indukuje w rdzeniu prądy wirowe; podział na izolowane blachy ogranicza ich drogę i straty. Ferryty mają bardzo dużą rezystywność, więc prądy wirowe są pomijalne także przy częstotliwościach rzędu setek kHz.
</details>

## Źródła

- [MIT 8.02 Physics II: Electricity and Magnetism](https://ocw.mit.edu/courses/8-02-physics-ii-electricity-and-magnetism-spring-2007/) — pole magnetyczne, prawo Ampère'a, Faradaya, indukcyjność, materiały magnetyczne
- [Electromagnetics, Vol. 1 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-1) — magnetostatyka, indukcyjność, energia pola
- [All About Circuits — tom DC, rozdziały *Magnetism and Electromagnetism* i *Inductors*](https://www.allaboutcircuits.com/textbook/)
