# 03 — Przyrządy półprzewodnikowe

> **Status:** ✅ pełny

## Cel modułu

Znać budowę, zasadę działania, charakterystyki i modele elementów półprzewodnikowych na poziomie pozwalającym projektować z nimi układy (moduł [04](../04-uklady-analogowe/)) i dobierać je na podstawie dokumentacji.

## Wymagania wstępne

- [01 Teoria obwodów](../01-teoria-obwodow/) — zwłaszcza Thévenin i czwórniki.
- [02 Fizyka i materiały](../02-fizyka-i-materialy/) — tematy 05–06 (półprzewodniki, transport nośników).

## Tematy

| # | Temat | Czas (od zera / odświeżenie) |
|---|---|---|
| 01 | [Złącze p-n](01-zlacze-pn.md) | 8 h / 2 h |
| 02 | [Dioda: charakterystyka, modele, punkt pracy](02-dioda-modele.md) | 8 h / 3 h |
| 03 | [Diody specjalne: Zenera, Schottky'ego, LED, fotodioda, waraktor](03-diody-specjalne.md) | 6 h / 2 h |
| 04 | [Tranzystor bipolarny (BJT)](04-bjt.md) | 10 h / 3 h |
| 05 | [Model małosygnałowy BJT](05-bjt-model-malosygnalowy.md) | 6 h / 2 h |
| 06 | [Tranzystor MOSFET](06-mosfet.md) | 10 h / 3 h |
| 07 | [MOSFET: model małosygnałowy i praca jako klucz](07-mosfet-model-i-klucz.md) | 8 h / 3 h |
| 08 | [JFET, elementy mocy i optoelektronika](08-jfet-elementy-mocy-opto.md) | 6 h / 2 h |
| 09 | [Czytanie dokumentacji i obliczenia cieplne](09-datasheety-i-termika.md) | 6 h / 2 h |

## Test wejściowy (diagnoza)

Około 60 minut, bez notatek. $U_T = 25{,}85$ mV.

1. Dioda ma $I_S = 10^{-14}$ A. Jakie napięcie odkłada się na niej przy prądzie 1 mA? O ile wzrośnie przy 10 mA?
2. Źródło 5 V przez rezystor 1 kΩ zasila diodę z zadania 1. Wyznacz punkt pracy.
3. Jaka jest rezystancja dynamiczna diody przy prądzie 2 mA?
4. Tranzystor npn: $\beta = 100$, baza zasilana z 5 V przez 43 kΩ, kolektor przez 1 kΩ z 5 V. W jakim stanie pracuje? Jaki płynie prąd kolektora?
5. Wyznacz $g_m$ i $r_\pi$ tranzystora bipolarnego przy $I_C = 1$ mA, $\beta = 100$.
6. MOSFET z kanałem n: $k = 2$ mA/V², $V_t = 1$ V, $U_{GS} = 2$ V, $U_{DS} = 5$ V. W jakim zakresie pracuje i jaki płynie prąd drenu?
7. Tranzystor rozprasza 10 W, $R_{\theta JC} = 1{,}5$ K/W, $R_{\theta CS} = 0{,}5$ K/W, temperatura otoczenia 40 °C, $T_{j,max} = 150$ °C. Jaki radiator jest potrzebny?

<details>
<summary>Odpowiedzi</summary>

1. ≈ 0,655 V; o ok. 59,5 mV (do ≈ 0,714 V)
2. ≈ 0,692 V, ≈ 4,31 mA
3. $r_d = U_T/I_D \approx 12{,}9\ \Omega$
4. Z założenia aktywnego: $I_B = 0{,}1$ mA, $I_C = 10$ mA → $U_{CE} = -5$ V, co jest niemożliwe. Tranzystor jest nasycony: $I_C \approx (5 - 0{,}2)/1\ \text{k} = 4{,}8$ mA
5. $g_m \approx 38{,}7$ mS, $r_\pi \approx 2{,}59$ kΩ
6. Nasycenie (zakres pentodowy), bo $U_{DS} > U_{GS} - V_t$; $I_D = \tfrac{k}{2}(U_{GS} - V_t)^2 = 1$ mA
7. $R_{\theta SA} \leq \dfrac{150 - 40}{10} - 2 = 9$ K/W

**Ocena:** zadania 1–3 — tematy 01–03; 4–5 — tematy 04–05; 6 — tematy 06–07; 7 — temat 09.
</details>

## Projekt modułowy: charakterystyki i parametry modeli

- [ ] W LTspice wykreśl charakterystykę I–U diody 1N4148 i Schottky'ego (np. BAT54): `.dc` źródła napięciowego z rezystorem, skala logarytmiczna prądu.
- [ ] Wyeksportuj dane i dopasuj w Pythonie parametry $I_S$ i $n$ z prostoliniowego odcinka $\ln I(U)$ (`np.polyfit`).
- [ ] Wykreśl rodzinę charakterystyk wyjściowych tranzystora 2N3904 (`.dc` z dwoma źródłami — $U_{CE}$ i prąd bazy). Wyznacz $\beta$ i napięcie Early'ego.
- [ ] Wykreśl $I_D(U_{GS})$ i $I_D(U_{DS})$ MOSFET-a (np. 2N7002). Wyznacz $V_t$ i $k$ z wykresu $\sqrt{I_D}(U_{GS})$.
- [ ] Jeśli masz sprzęt: zmierz te same charakterystyki na płytce stykowej (źródło regulowane + multimetry) i porównaj z modelem.

## Sprawdzian końcowy modułu

- [ ] Wyjaśniam działanie złącza p-n na modelu pasmowym i z punktu widzenia nośników.
- [ ] Wyznaczam punkt pracy diody metodą graficzną, iteracyjną i modelem uproszczonym — i wiem, kiedy który wystarcza.
- [ ] Rozpoznaję stan pracy BJT i MOSFET-a z napięć na zaciskach.
- [ ] Liczę parametry małosygnałowe tranzystora w danym punkcie pracy.
- [ ] Dobieram MOSFET do kluczowania i szacuję straty przewodzenia i przełączania.
- [ ] Odczytuję z dokumentacji parametry graniczne i warunki pomiaru, liczę temperaturę złącza.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [Semiconductor Devices: Theory and Application — J. M. Fiore](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html) | Cały moduł, poziom praktyczny, z instrukcją laboratoryjną |
| [MIT 6.012 Microelectronic Devices and Circuits](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-spring-2009/) | Ujęcie akademickie: fizyka złącza, BJT, MOSFET i ich modele |
| [Analog Devices — Electronics I and II](https://wiki.analog.com/university/courses/electronics/text/electronics-toc) | Podręcznik i ćwiczenia laboratoryjne |
| [MIT 6.002 Circuits and Electronics](https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/) | MOSFET jako klucz i jako wzmacniacz, model małosygnałowy |
| [All About Circuits — tom Semiconductors](https://www.allaboutcircuits.com/textbook/) | Intuicyjne wyjaśnienia diod, tranzystorów, tyrystorów |
| [Khan Academy — Electrical Engineering](https://www.khanacademy.org/science/electrical-engineering) | Filmy o półprzewodnikach i diodach |
| [Falstad — demonstracje](https://falstad.com/circuit/e-index.html) | Diody, MOSFET-y, tranzystory bipolarne w animowanych symulacjach |
