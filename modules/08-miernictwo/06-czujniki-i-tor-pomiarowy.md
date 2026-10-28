# 08.06 — Czujniki i tor pomiarowy

## Po co to jest

Większość systemów elektronicznych mierzy coś ze świata fizycznego: temperaturę, siłę, światło, prąd, położenie. Czujnik zamienia wielkość fizyczną na elektryczną, a tor kondycjonowania przygotowuje sygnał do przetwornika A/C. Jakość całego toru decyduje o jakości pomiaru, a nie sam przetwornik.

## Teoria w pigułce

### Tor pomiarowy

Czujnik → kondycjonowanie (zasilanie czujnika, wzmocnienie, przesunięcie poziomu, filtr antyaliasingowy) → przetwornik A/C → przetwarzanie (linearyzacja, kalibracja, filtracja) → wynik.

Budżet błędów obejmuje każdy element: czujnik (nieliniowość, histereza, dryft), elementy bierne (tolerancje, TCR), wzmacniacz (offset, szum), przetwornik (ENOB, napięcie odniesienia).

### Czujniki temperatury

| Czujnik | Zasada | Zakres / cechy | Kondycjonowanie |
|---|---|---|---|
| **RTD (Pt100, Pt1000)** | $R(T) \approx R_0(1 + \alpha T)$, $\alpha = 0{,}00385$ 1/K | Dokładny, liniowy, −200…+600 °C | Źródło prądowe, pomiar 3- lub 4-przewodowy |
| **Termistor NTC** | $R = R_0e^{B(1/T - 1/T_0)}$ | Bardzo czuły, nieliniowy, tani | Dzielnik + linearyzacja programowa |
| **Termopara** | Napięcie Seebecka (typ K ≈ 41 µV/K) | Szeroki zakres, mały sygnał | Kompensacja zimnych końców, wzmocnienie ×100–1000 |
| Złącze półprzewodnikowe / scalone | −2 mV/K lub wyjście cyfrowe | Proste, ±0,5–2 °C | Bezpośrednio do A/C lub magistrali |

**Samopodgrzewanie:** prąd pomiarowy grzeje czujnik ($P = I^2R$) — dobiera się go tak, by błąd był pomijalny (dla Pt100 typowo ≤ 1 mA).

### Inne czujniki

| Wielkość | Czujnik | Uwagi |
|---|---|---|
| Siła, masa, ciśnienie | Tensometry w mostku | Sygnał mV, wzmacniacz pomiarowy, wspólne zasilanie mostka i odniesienia A/C (pomiar ratiometryczny) |
| Prąd | Bocznik + wzmacniacz, czujnik Halla, przekładnik | Bocznik: precyzja, brak izolacji; Hall: izolacja, offset |
| Światło | Fotodioda + TIA | [03.03](../03-przyrzady-polprzewodnikowe/03-diody-specjalne.md), [04.07](../04-uklady-analogowe/07-wzmacniacz-operacyjny-idealny.md) |
| Położenie, obrót | Potencjometr, enkoder, czujnik Halla, LVDT | Enkodery w kodzie Graya |
| Przyspieszenie, obrót | MEMS (akcelerometr, żyroskop) | Wyjście cyfrowe I²C/SPI |

### Pomiar ratiometryczny

Gdy czujnik (mostek, potencjometr) i przetwornik A/C korzystają z tego samego napięcia odniesienia, wynik nie zależy od zmian tego napięcia — błędy się znoszą.

### Kalibracja

Dwupunktowa (offset + wzmocnienie), wielopunktowa (tablica, wielomian), zapis współczynników w pamięci nieulotnej. Kalibruje się cały tor, nie tylko czujnik.

## Przykład rozwiązany

**NTC 10 kΩ, B = 3950 K w dzielniku z rezystorem 10 kΩ, zasilanie 3,3 V (ratiometrycznie z A/C 12-bitowym).**

1. W 50 °C: $R = 10\ \text{k}\cdot e^{3950(1/323{,}15 - 1/298{,}15)} \approx 3{,}59$ kΩ.
2. Napięcie (NTC do masy): $3{,}3\cdot\dfrac{3{,}59}{13{,}59} \approx 0{,}87$ V → kod ok. 1081.
3. W 25 °C: 1,65 V → kod 2048. Odwrotne przeliczenie kodu na temperaturę: wyznacz $R$ z dzielnika, potem $T = \left[\dfrac{1}{T_0} + \dfrac{1}{B}\ln\dfrac{R}{R_0}\right]^{-1}$.
4. Czułość przy 25 °C ok. 45 kodów/K — rozdzielczość ok. 0,02 K, dokładność ograniczona przez tolerancję NTC (np. ±1%) i parametr B.

**Termopara K:** różnica 100 K daje ok. 4,1 mV. Przy przetworniku 12-bitowym z zakresem 3,3 V (LSB 0,8 mV) to tylko ok. 5 kodów — potrzebne wzmocnienie ok. 100–500 lub specjalizowany układ z kompensacją zimnych końców.

## Typowe pułapki

- **Termopara bez kompensacji zimnych końców** — mierzy różnicę temperatur, nie temperaturę.
- **Pt100 mierzony dwuprzewodowo** — 1 Ω rezystancji przewodów to błąd ok. 2,6 K.
- **Duży prąd pomiarowy czujnika rezystancyjnego** — samopodgrzewanie.
- **Linearyzacja NTC przybliżeniem liniowym** w szerokim zakresie.
- **Zasilanie mostka z innego źródła niż odniesienie A/C** — dryft zasilania przenosi się na wynik.

## Ćwiczenie komputerowe

```python
import numpy as np
R0, B, T0, Rs, Vref, bits = 10e3, 3950, 298.15, 10e3, 3.3, 12
def code_from_T(Tc):
    R = R0*np.exp(B*(1/(Tc + 273.15) - 1/T0))
    return np.round(Vref*R/(R + Rs)/Vref*(2**bits - 1))
def T_from_code(code):
    v = code/(2**bits - 1); R = Rs*v/(1 - v)
    return 1/(1/T0 + np.log(R/R0)/B) - 273.15
for Tc in [0, 25, 50, 85]:
    c = code_from_T(Tc); print(Tc, "°C → kod", int(c), "→", round(T_from_code(c), 2), "°C")
```

## Zadania

1. Rezystancja NTC 10 kΩ (B = 3950 K) w 50 °C?
2. Pt100 w 100 °C ($\alpha = 0{,}00385$). Jaki błąd temperatury wprowadzi 1 Ω rezystancji przewodów przy pomiarze dwuprzewodowym?
3. Termopara K, 100 K różnicy. Jakie napięcie? Ile kodów da przetwornik 12-bitowy 3,3 V bez wzmocnienia?
4. Pt100 zasilany prądem 1 mA, rezystancja cieplna czujnika do otoczenia 0,2 K/mW. Jaki błąd samopodgrzewania?
5. Wyjaśnij, dlaczego pomiar mostka tensometrycznego zasilanego z tego samego napięcia co odniesienie przetwornika A/C jest odporny na zmiany tego napięcia.

<details>
<summary>Odpowiedzi</summary>

1. ≈ 3,59 kΩ
2. $1/(100\cdot 0{,}00385) \approx 2{,}6$ K
3. ≈ 4,1 mV; ok. 5 kodów
4. $P = 10^{-6}\cdot 100 = 0{,}1$ mW (przy ok. 100 Ω) → 0,02 K
5. Napięcie mostka jest proporcjonalne do napięcia zasilania, a wynik przetwornika to stosunek napięcia wejściowego do odniesienia — zmiana zasilania zmienia obie wielkości w tej samej proporcji i znosi się w ilorazie
</details>

## Źródła

- [Modular Electronics Learning (ModEL) Project](https://ibiblio.org/kuphaldt/socratic/model/) — moduły o czujnikach i kondycjonowaniu sygnałów
- [Analog Devices — Electronics I and II](https://wiki.analog.com/university/courses/electronics/text/electronics-toc) — przetworniki i tor sygnałowy
- [Operational Amplifiers & Linear ICs — J. M. Fiore](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html) — wzmacniacze pomiarowe
