# 04.11 — Stabilizatory liniowe

## Po co to jest

Prawie każdy układ potrzebuje stabilnego napięcia zasilania. Stabilizatory liniowe są proste, ciche (bez zakłóceń impulsowych) i tanie, ale tracą w postaci ciepła całą różnicę napięć. Przetwornice impulsowe omawia moduł [15](../15-energoelektronika-zasilanie/).

## Teoria w pigułce

### Zasada działania

Element regulacyjny (tranzystor) szeregowo z obciążeniem + wzmacniacz błędu porównujący część napięcia wyjściowego (z dzielnika) z napięciem odniesienia. To układ ze sprzężeniem zwrotnym ([04.06](06-sprzezenie-zwrotne-i-stabilnosc.md)) — może być niestabilny.

**Najprostszy:** dioda Zenera + wtórnik emiterowy: $U_{wy} \approx U_Z - 0\text{,}7$ V, prąd bazy $\beta$ razy mniejszy niż obciążenia.

### Typy stabilizatorów scalonych

| Typ | Minimalny spadek napięcia (dropout) | Uwagi |
|---|---|---|
| Klasyczny (np. seria 78xx) | ok. 2 V | Tranzystor npn w układzie Darlingtona |
| Regulowany (np. LM317) | ok. 1,5–3 V | $U_{wy} = 1\text{,}25\left(1 + \dfrac{R_2}{R_1}\right) + I_{ADJ}R_2$ |
| **LDO** | 0,05–0,5 V | Tranzystor pnp lub pMOS; **wymagania na ESR kondensatora wyjściowego** |

### Parametry

Dropout, prąd spoczynkowy, stabilizacja liniowa (line regulation) i obciążeniowa (load regulation), **PSRR** (tłumienie tętnień zasilania — spada z częstotliwością), szum wyjściowy, odpowiedź na skok obciążenia, zabezpieczenia (prądowe, termiczne).

### Bilans mocy i ciepło

$$P = (U_{we} - U_{wy})I_L + U_{we}I_Q, \qquad \eta \approx \frac{U_{wy}}{U_{we}}$$

Temperatura złącza — [03.09](../03-przyrzady-polprzewodnikowe/09-datasheety-i-termika.md).

## Przykład rozwiązany

Stabilizator 12 V → 5 V, 0,5 A, obudowa TO-220: $R_{\theta JA} = 50$ K/W, $R_{\theta JC} = 3$ K/W, podkładka 0,5 K/W, $T_a = 40$ °C, projekt na $T_j \leq 125$ °C.

1. $P = 7\cdot 0\text{,}5 = 3\text{,}5$ W, $\eta \approx 42\%$.
2. Bez radiatora: $T_j = 40 + 3\text{,}5\cdot 50 = 215$ °C — wyłączy się zabezpieczenie termiczne.
3. Łączna dopuszczalna rezystancja: $\dfrac{125 - 40}{3\text{,}5} \approx 24\text{,}3$ K/W; radiator: $\leq 24\text{,}3 - 3 - 0\text{,}5 \approx 20\text{,}8$ K/W.
4. Alternatywa: przetwornica impulsowa (sprawność ok. 90%) — straty ok. 0,3 W, bez radiatora.

**LM317 na 5 V:** $R_1 = 240\ \Omega$, $R_2 = 720\ \Omega$ → $1\text{,}25\cdot 4 = 5\text{,}0$ V (+ ok. 36 mV od prądu $I_{ADJ} \approx 50\ \mu$A).

## Typowe pułapki

- **Brak kondensatorów** na wejściu i wyjściu albo kondensator o niewłaściwym ESR (LDO bywają stabilne tylko w określonym zakresie ESR — sprawdź dokumentację; niektóre starsze LDO nie są stabilne z ceramiką).
- **Moc liczona z nominalnego napięcia wejściowego** — przy maksymalnym napięciu sieci i tętnieniach jest wyższa.
- **Wejście poniżej $U_{wy}$ + dropout** w dolinach tętnień — tętnienia „przechodzą” na wyjście.
- **LDO jako filtr zakłóceń przetwornicy** — PSRR przy setkach kHz jest zwykle mały.

## Symulacja

```spice
* 04.11 prosty stabilizator: Zener + wtornik, skok obciazenia
VIN in 0 PULSE(12 14 0 1u 1u 5m 10m)
R1 in z 1k
D1 0 z DZ
Q1 in z out QN
RL out 0 10
RL2 x 0 10
VCTL c 0 PULSE(0 1 2m 1u 1u 3m 10m)
S1 out x c 0 SWMOD
.model DZ D(Bv=5.6 Ibv=5m)
.model QN NPN(Bf=100 Is=1e-13)
.model SWMOD SW(Ron=0.01 Roff=1meg Vt=0.5)
.tran 0 10m
.end
```

Obserwuj, jak napięcie wyjściowe reaguje na zmianę napięcia wejściowego i dołączenie drugiego obciążenia. Następnie zastąp układ modelem scalonego LDO z biblioteki LTspice i porównaj stabilizację.

## Zadania

1. 12 V → 5 V, 0,5 A. Moc strat i sprawność?
2. Dobierz radiator dla zadania 1: $R_{\theta JC} = 3$ K/W, podkładka 0,5 K/W, $T_a = 40$ °C, $T_j \leq 125$ °C.
3. LM317, $R_1 = 240\ \Omega$. Dobierz $R_2$ dla 3,3 V i 12 V.
4. LDO 3,3 V ma dropout 0,3 V przy 500 mA. Czy można go zasilić z akumulatora Li-ion (4,2–3,0 V)? Do jakiego napięcia akumulatora będzie stabilizował?
5. Stabilizator Zener 5,6 V + wtórnik. Jakie napięcie wyjściowe i jaki prąd bazy przy obciążeniu 0,5 A ($\beta = 100$)?

<details>
<summary>Odpowiedzi</summary>

1. 3,5 W, ok. 42%
2. ≤ 20,8 K/W
3. $R_2 = R_1(U/1\text{,}25 - 1)$: 3,3 V → ≈ 394 Ω (np. 390 Ω); 12 V → ≈ 2064 Ω (np. 2 kΩ + regulacja lub 2,05 kΩ)
4. Tak, do ok. 3,6 V; poniżej napięcie wyjściowe będzie spadać razem z akumulatorem
5. ≈ 4,9 V; $I_B \approx 0\text{,}5/101 \approx 5$ mA — rezystor Zenera musi dostarczyć ten prąd plus minimalny prąd diody
</details>

## Źródła

- [Operational Amplifiers & Linear ICs — J. M. Fiore, rozdział 8 *Voltage Regulation*](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html) — stabilizatory liniowe i impulsowe
- [Analog Devices — Electronics I and II](https://wiki.analog.com/university/courses/electronics/text/electronics-toc) — rozdział o układach zarządzania zasilaniem
- [LTspice](https://www.analog.com/en/resources/design-tools-and-calculators/ltspice-simulator.html) — modele stabilizatorów i obwody demonstracyjne producenta
