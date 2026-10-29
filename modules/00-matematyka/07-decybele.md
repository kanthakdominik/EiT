# 00.07 — Decybele i skale logarytmiczne

## Po co to jest

Wzmocnienia, tłumienia i poziomy sygnałów w elektronice zmieniają się o wiele rzędów wielkości. Decybele zamieniają mnożenie na dodawanie: wzmocnienie kaskady stopni to suma ich wzmocnień w dB. Na tym opierają się wykresy Bodego i budżet łącza radiowego.

## Teoria w pigułce

**Stosunek mocy:**

$$K_P[\text{dB}] = 10\log_{10}\frac{P_2}{P_1}$$

**Stosunek napięć lub prądów** (przy tej samej impedancji, bo $P \sim U^2$):

$$K_U[\text{dB}] = 20\log_{10}\frac{U_2}{U_1}$$

| Stosunek mocy | Stosunek napięć | dB |
|---|---|---|
| 2 | 1,414 | +3 |
| 4 | 2 | +6 |
| 10 | 3,16 | +10 |
| 100 | 10 | +20 |
| 0,5 | 0,707 | −3 |
| 0,01 | 0,1 | −20 |

**Jednostki bezwzględne** (poziom odniesiony do wartości wzorcowej):

| Jednostka | Odniesienie | Zastosowanie |
|---|---|---|
| dBm | 1 mW | RF, telekomunikacja |
| dBW | 1 W | Moc nadajników |
| dBV | 1 V RMS | Audio, pomiary |
| dBµV | 1 µV | EMC, odbiorniki |
| dBc | moc nośnej | Harmoniczne, szum fazowy |
| dBi | antena izotropowa | Zysk anteny |

**Skala logarytmiczna częstotliwości:** dekada = 10×, oktawa = 2×. Spadek 20 dB/dekadę ≈ 6 dB/oktawę — to nachylenie charakterystyki filtra 1. rzędu.

## Przykład rozwiązany

Tor składa się z: wzmacniacza +20 dB, kabla −6 dB i drugiego wzmacniacza +10 dB. Na wejściu jest −40 dBm. Jaki jest poziom i wzmocnienie napięciowe całości?

1. Wzmocnienie całkowite: $20 - 6 + 10 = 24$ dB.
2. Poziom wyjściowy: $-40 + 24 = -16$ dBm.
3. Wzmocnienie napięciowe (przy stałej impedancji): $10^{24/20} \approx 15\text{,}85$ V/V.

## Typowe pułapki

- **10 log zamiast 20 log** (lub odwrotnie). 10 — dla mocy, 20 — dla wielkości, których kwadrat jest proporcjonalny do mocy.
- **Dodawanie dBm do dBm.** Można dodawać dB do dBm (zmiana poziomu), ale dwóch mocy w dBm nie sumuje się arytmetycznie — trzeba przeliczyć na mW, dodać i wrócić do dBm.
- **20 log stosowany przy różnych impedancjach.** Wtedy wzmocnienie napięciowe w dB nie jest równe wzmocnieniu mocy w dB.

## Symulacja / ćwiczenie komputerowe

```python
import numpy as np
dbm = lambda p_w: 10*np.log10(p_w/1e-3)
w_from_dbm = lambda d: 1e-3 * 10**(d/10)

print(dbm(1.0))                          # 30 dBm
p = w_from_dbm(-10) + w_from_dbm(-10)    # dwa sygnały po -10 dBm
print(dbm(p))                            # ≈ -6.99 dBm, a nie -20 ani 0
```

## Zadania

1. Ile dBm to 1 W? A 1 µW?
2. Wzmacniacz ma wzmocnienie napięciowe 100 V/V. Ile to dB?
3. Jaka jest wartość skuteczna napięcia sygnału 0 dBm na obciążeniu 50 Ω?
4. Moc spadła do połowy. O ile dB?
5. Kaskada: +20 dB, −6 dB, +10 dB. Jakie jest wzmocnienie napięciowe w V/V?
6. Filtr 2. rzędu opada z nachyleniem 40 dB/dekadę. O ile dB stłumi sygnał o częstotliwości 10 razy większej niż graniczna (w przybliżeniu asymptotycznym)?

<details>
<summary>Odpowiedzi</summary>

1. 30 dBm; −30 dBm
2. 40 dB
3. $P = 1$ mW, $U = \sqrt{PR} = \sqrt{0\text{,}05} \approx 0\text{,}224$ V RMS
4. −3,01 dB
5. 24 dB → ok. 15,85 V/V
6. Około 40 dB
</details>

## Źródła

- [Operational Amplifiers & Linear ICs — J. M. Fiore, rozdział 1](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html) — decybele i wykresy Bodego
- [All About Circuits Textbook](https://www.allaboutcircuits.com/textbook/) — rozdziały o decybelach w tomach o półprzewodnikach i RF
