# 02.06 — Transport nośników ładunku

## Po co to jest

Prąd w półprzewodniku płynie dzięki dwóm mechanizmom: **dryftowi** w polu elektrycznym i **dyfuzji** z obszaru o dużej koncentracji do małej. W złączu p-n i tranzystorze bipolarnym dominuje dyfuzja, w kanale MOSFET-a i rezystorze — dryft. Rekombinacja decyduje o szybkości przełączania diod.

## Teoria w pigułce

### Dryft

$$J_{dryf} = q(n\mu_n + p\mu_p)E$$

| Krzem, 300 K, słabe domieszkowanie | Wartość |
|---|---|
| Ruchliwość elektronów $\mu_n$ | ok. 1350 cm²/(V·s) |
| Ruchliwość dziur $\mu_p$ | ok. 480 cm²/(V·s) |

Elektrony są ok. 2,8 razy ruchliwsze od dziur — dlatego tranzystory nMOS i npn są szybsze i mają mniejszą rezystancję niż pMOS i pnp tej samej wielkości. Ruchliwość maleje ze wzrostem domieszkowania i temperatury. W silnym polu prędkość dryftu nasyca się (ok. $10^7$ cm/s w krzemie).

### Dyfuzja

$$J_{dyf,n} = qD_n\frac{dn}{dx}, \qquad J_{dyf,p} = -qD_p\frac{dp}{dx}$$

**Relacja Einsteina:** $\dfrac{D}{\mu} = U_T$, czyli $D_n = \mu_n U_T \approx 35$ cm²/s dla elektronów w krzemie.

### Generacja i rekombinacja

Nadmiarowe nośniki mniejszościowe znikają przez rekombinację z czasem życia $\tau$. Zanim zrekombinują, dyfundują średnio na odległość **drogi dyfuzji**:

$$L = \sqrt{D\tau}$$

Krótki czas życia = szybsza dioda (mniej ładunku do usunięcia przy wyłączaniu), ale też większe prądy upływu. Diody szybkie domieszkuje się celowo złotem lub platyną, żeby skrócić $\tau$.

### Równanie ciągłości

Bilans nośników w małej objętości: zmiana koncentracji = dopływ (dryft + dyfuzja) + generacja − rekombinacja. To równanie razem z prawem Gaussa jest podstawą symulatorów przyrządów półprzewodnikowych (TCAD).

## Przykład rozwiązany

Do krzemu typu p wstrzyknięto elektrony (nośniki mniejszościowe), $\tau_n = 1\ \mu$s.

1. $D_n = \mu_n U_T = 1350\cdot 0\text{,}02585 \approx 34\text{,}9$ cm²/s.
2. $L_n = \sqrt{34\text{,}9\cdot 10^{-6}} \approx 5\text{,}9\cdot 10^{-3}$ cm $\approx 59\ \mu$m.
3. Wniosek dla tranzystora bipolarnego: jeśli baza jest dużo cieńsza niż $L_n$ (typowo poniżej 1 µm), prawie wszystkie elektrony z emitera dotrą do kolektora bez rekombinacji — stąd duże $\beta$.

## Typowe pułapki

- **Dyfuzja wymaga pola elektrycznego.** Nie — wystarczy gradient koncentracji.
- **Znak prądu dyfuzji dziur** — dziury dyfundują w stronę mniejszej koncentracji i niosą ładunek dodatni, stąd minus we wzorze dla $J_p$.
- **Ruchliwość z tabeli dla czystego krzemu** stosowana do silnie domieszkowanych obszarów — tam jest kilka razy mniejsza.

## Ćwiczenie komputerowe

```python
import numpy as np, matplotlib.pyplot as plt
L = 59e-4  # cm
x = np.linspace(0, 5*L, 300)
plt.plot(x*1e4, np.exp(-x/L)); plt.xlabel("x [µm]"); plt.ylabel("Δn/Δn(0)")
plt.title("Zanik nadmiarowych nośników mniejszościowych"); plt.grid(); plt.show()
```

## Zadania

1. Wyznacz współczynnik dyfuzji dziur w krzemie ($\mu_p = 480$ cm²/V·s) w 300 K.
2. Czas życia dziur w krzemie typu n wynosi 10 µs. Jaka jest droga dyfuzji?
3. Próbka krzemu typu n ($N_D = 10^{16}$ cm⁻³) ma długość 1 mm i przekrój 1 mm². Jaka jest jej rezystancja?
4. Dlaczego tranzystor pMOS musi mieć ok. 2–3 razy szerszy kanał niż nMOS, aby przewodzić ten sam prąd?
5. Jaka jest prędkość dryftu elektronów w krzemie w polu 100 V/cm? A w polu $10^5$ V/cm?

<details>
<summary>Odpowiedzi</summary>

1. $D_p = 480\cdot 0\text{,}02585 \approx 12\text{,}4$ cm²/s
2. $L_p = \sqrt{12\text{,}4\cdot 10^{-5}} \approx 0\text{,}011$ cm ≈ 111 µm
3. $\rho \approx 0\text{,}46$ Ω·cm; $R = \rho l/A = 0\text{,}46\cdot 0\text{,}1/0\text{,}01 = 4\text{,}6\ \Omega$
4. Ruchliwość dziur jest ok. 2,8 razy mniejsza niż elektronów
5. $v = \mu E = 1\text{,}35\cdot 10^5$ cm/s; w polu $10^5$ V/cm prędkość jest nasycona, ok. $10^7$ cm/s (wzór liniowy dawałby fałszywie $1\text{,}35\cdot 10^8$ cm/s)
</details>

## Źródła

- [MIT 6.012 Microelectronic Devices and Circuits](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-spring-2009/) — dryft, dyfuzja, generacja i rekombinacja
- [Semiconductor Devices — J. M. Fiore](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html)
