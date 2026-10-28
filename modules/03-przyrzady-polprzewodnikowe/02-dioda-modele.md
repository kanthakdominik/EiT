# 03.02 — Dioda: charakterystyka, modele, punkt pracy

## Po co to jest

Dioda jest najprostszym elementem nieliniowym, więc na niej uczy się metod, które potem stosuje się do tranzystorów: wyznaczania punktu pracy, linearyzacji i modelu małosygnałowego.

## Teoria w pigułce

### Równanie Shockleya

$$I = I_S\left(e^{U/(nU_T)} - 1\right)$$

$I_S$ — prąd nasycenia (rzędu fA–nA), $n$ — współczynnik emisji (1–2), $U_T \approx 25{,}85$ mV.

Przydatne konsekwencje (dla $n = 1$):
- dziesięciokrotny wzrost prądu → wzrost napięcia o $U_T\ln 10 \approx 60$ mV,
- dwukrotny → o ok. 18 mV,
- przy stałym prądzie napięcie maleje o ok. **2 mV/K** (termometr diodowy).

### Modele diody

| Model | Opis | Kiedy wystarcza |
|---|---|---|
| Idealny | Zwarcie przy przewodzeniu, przerwa przy zaporowej | Napięcia w obwodzie ≫ 0,7 V, analiza logiczna |
| Stały spadek | Źródło 0,7 V (Si) przy przewodzeniu | Większość obliczeń „na kartce” |
| Odcinkowo-liniowy | 0,6 V + rezystancja szeregowa | Duże prądy, prostowniki |
| Wykładniczy | Równanie Shockleya | Dokładne obliczenia, małe prądy |
| Małosygnałowy | Rezystancja $r_d = nU_T/I_D$ (+ pojemność) | Małe zmiany wokół punktu pracy |

### Punkt pracy

Dioda w szeregu z rezystorem $R$ i źródłem $E$:

- **graficznie** — przecięcie charakterystyki diody z prostą obciążenia $I = (E - U)/R$,
- **iteracyjnie** — zgadnij $U$, policz $I = (E - U)/R$, policz nowe $U = nU_T\ln(I/I_S)$, powtarzaj (zbieżność bardzo szybka),
- **modelem uproszczonym** — $U = 0{,}7$ V.

### Właściwości dynamiczne

Przy przełączeniu z przewodzenia w zaporowy dioda przez czas **$t_{rr}$** (reverse recovery) przewodzi wstecz, aż usunie zgromadzony ładunek. Diody prostownicze: µs, szybkie: dziesiątki ns, Schottky'ego: praktycznie brak (brak nośników mniejszościowych).

## Przykład rozwiązany

$E = 5$ V, $R = 1$ kΩ, dioda $I_S = 10^{-14}$ A, $n = 1$.

1. Model 0,7 V: $I = 4{,}3$ mA.
2. Iteracja: $U = 0{,}02585\ln(4{,}3\cdot 10^{-3}/10^{-14}) \approx 0{,}6925$ V → $I = 4{,}3075$ mA → $U$ się nie zmienia. Wynik: 0,692 V, 4,31 mA.
3. Model uproszczony myli się o 0,2% — dla tego obwodu w zupełności wystarcza.
4. Rezystancja dynamiczna w tym punkcie: $r_d = 25{,}85\ \text{mV}/4{,}31\ \text{mA} \approx 6\ \Omega$. Jeśli $E$ zmienia się o ±100 mV, napięcie diody zmienia się tylko o $\pm 100\cdot\dfrac{6}{1006} \approx \pm 0{,}6$ mV.

## Typowe pułapki

- **0,7 V jako stała natury.** Przy 1 µA napięcie wynosi ok. 0,4 V, przy 1 A — ponad 0,9 V; diody Schottky'ego i LED-y mają zupełnie inne wartości.
- **Diody łączone równolegle bez rezystorów wyrównawczych** — niewielka różnica napięć i ujemny współczynnik temperaturowy powodują, że jedna przejmuje cały prąd.
- **Model małosygnałowy dla dużych sygnałów** — linearyzacja obowiązuje tylko dla zmian napięcia znacznie mniejszych od $U_T$.

## Symulacja

```spice
* 03.02 charakterystyka diody i punkt pracy
V1 a 0 5
R1 a k 1k
D1 k 0 D1N4148
.model D1N4148 D(Is=2.52n Rs=0.568 N=1.752 Cjo=4p M=0.4 tt=20n)
.dc V1 0 5 0.01
.op
.end
```

Wyświetl `I(D1)` w funkcji `V(k)` (zmień zmienną osi X) i przełącz oś prądu na logarytmiczną. Odczytaj nachylenie w mV na dekadę i porównaj z $n\cdot 60$ mV.

## Zadania

1. $I_S = 10^{-14}$ A, $n = 1$. Wyznacz napięcie diody przy 1 mA i 10 mA.
2. $E = 5$ V, $R = 1$ kΩ. Wyznacz punkt pracy diody z zadania 1 modelem 0,7 V i iteracyjnie.
3. Ile wynosi rezystancja dynamiczna diody przy 2 mA ($n = 1$)?
4. Dioda przewodzi 1 mA przy napięciu 0,655 V w 25 °C. Oszacuj napięcie w 75 °C przy tym samym prądzie.
5. Źródło 1,5 V przez 100 Ω zasila diodę krzemową. Dlaczego model idealny daje tu duży błąd? Ile wynosi prąd w przybliżeniu?
6. Dwie jednakowe diody połączone szeregowo przewodzą 1 mA. Jaka jest ich łączna rezystancja dynamiczna?

<details>
<summary>Odpowiedzi</summary>

1. ≈ 0,655 V i ≈ 0,714 V
2. 4,3 mA (model); 0,692 V i 4,31 mA (iteracja)
3. ≈ 12,9 Ω
4. $0{,}655 - 50\cdot 0{,}002 \approx 0{,}555$ V
5. Napięcie źródła jest porównywalne ze spadkiem na diodzie; $I \approx (1{,}5 - 0{,}7)/100 = 8$ mA, a nie 15 mA
6. $2\cdot 25{,}85\ \Omega \approx 52\ \Omega$
</details>

## Źródła

- [Semiconductor Devices — J. M. Fiore, rozdział o diodach](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html)
- [MIT 6.012 Microelectronic Devices and Circuits](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-spring-2009/)
- [MIT 6.002 Circuits and Electronics](https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/) — wykład o układach nieliniowych i diodach
- [Khan Academy — Electrical Engineering, dział o półprzewodnikach](https://www.khanacademy.org/science/electrical-engineering)
