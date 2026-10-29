# 04.05 — Stopnie wyjściowe

## Po co to jest

Stopień wyjściowy dostarcza prąd i moc do obciążenia: głośnika, silnika, linii, następnego układu. Musi mieć małą rezystancję wyjściową, możliwie dużą sprawność i małe zniekształcenia. Te same zasady dotyczą wyjść wzmacniaczy operacyjnych i driverów.

## Teoria w pigułce

### Klasy pracy

| Klasa | Czas przewodzenia tranzystora | Sprawność maksymalna (sinus) | Zniekształcenia | Uwagi |
|---|---|---|---|---|
| **A** | 360° | 25% (obciążenie rezystancyjne), 50% (transformator / źródło prądowe) | Najmniejsze | Duży prąd spoczynkowy |
| **B** | 180° (para komplementarna) | $\pi/4 \approx 78\text{,}5\%$ | Zniekształcenia skrośne (crossover) | Brak prądu spoczynkowego |
| **AB** | trochę ponad 180° | prawie jak B | Małe | Standard we wzmacniaczach audio |
| **C** | < 180° | do ok. 90% | Duże (wymaga obwodu rezonansowego) | Nadajniki w.cz. |
| **D** | Klucze (PWM) | > 90% | Zależne od filtracji | Nowoczesne wzmacniacze audio, sterowniki silników |

### Przeciwsobny stopień klasy B/AB

Komplementarna para wtórników (npn u góry, pnp na dole). W klasie B, gdy $\lvert u\rvert < 0\text{,}6$ V, żaden tranzystor nie przewodzi — powstają **zniekształcenia skrośne**. W klasie AB polaryzuje się bazy napięciem ok. $2U_{BE}$ (dwie diody lub „powielacz $U_{BE}$”), aby oba tranzystory lekko przewodziły w spoczynku. Rezystory emiterowe (0,1–0,5 Ω) stabilizują prąd spoczynkowy termicznie.

### Bilans mocy (klasa B, sinus o amplitudzie $U_p$, zasilanie $\pm V_{CC}$)

$$P_{wy} = \frac{U_p^2}{2R_L}, \qquad P_{zas} = \frac{2V_{CC}U_p}{\pi R_L}, \qquad P_{strat} = P_{zas} - P_{wy}$$

Straty w tranzystorach są największe przy $U_p = 2V_{CC}/\pi$ (ok. 64% zakresu), a nie przy pełnej mocy.

## Przykład rozwiązany

Klasa B, $\pm 15$ V, $R_L = 8\ \Omega$, amplituda wyjściowa 12 V.

1. $P_{wy} = \dfrac{144}{16} = 9$ W.
2. Prąd szczytowy 1,5 A; $P_{zas} = \dfrac{2\cdot 15\cdot 1\text{,}5}{\pi} \approx 14\text{,}3$ W.
3. Sprawność ≈ 63%, straty ≈ 5,3 W (po ok. 2,7 W na tranzystor).
4. Maksymalne straty przy $U_p = 2\cdot 15/\pi \approx 9\text{,}5$ V: $P_{strat} = \dfrac{2V_{CC}^2}{\pi^2R_L} \approx 5\text{,}7$ W łącznie — do tej wartości dobiera się radiator.

## Typowe pułapki

- **Radiator dobrany dla pełnej mocy wyjściowej** — największe straty są przy ok. 2/3 amplitudy.
- **Brak rezystorów emiterowych** w klasie AB — ucieczka termiczna.
- **Sprawność 78,5% dla klasy B traktowana jako typowa** — dotyczy pełnej amplitudy sinusa; przy muzyce średnia sprawność jest znacznie niższa.
- **Wyjście bez zabezpieczenia przed zwarciem** — tranzystory wyjściowe giną w ułamku sekundy.

## Symulacja

```spice
* 04.05 stopien przeciwsobny klasy B i AB
VCC vcc 0 15
VEE vee 0 -15
VIN in 0 SINE(0 12 1k)
* klasa B: bazy polaczone razem
Q1 vcc in out QN
Q2 vee in out QP
RL out 0 8
.model QN NPN(Bf=100 Is=1e-13)
.model QP PNP(Bf=100 Is=1e-13)
.tran 0 3m
.four 1k V(out)
.end
```

Obejrzyj zniekształcenia skrośne. `.four` wypisuje THD w pliku log. Następnie dodaj polaryzację AB: dwie diody między bazami zasilane źródłami prądowymi 5 mA i rezystory 0,22 Ω w emitery — porównaj THD.

## Zadania

1. Klasa B, $\pm 15$ V, 8 Ω, amplituda 12 V. Wyznacz $P_{wy}$, $P_{zas}$, sprawność i straty.
2. Jaka jest maksymalna moc wyjściowa i sprawność, jeśli tranzystory dochodzą do 1 V od szyn zasilania?
3. Przy jakiej amplitudzie straty są największe i ile wynoszą?
4. Wzmacniacz klasy A (wtórnik z rezystorem emiterowym) daje 1 W na obciążenie. Ile co najmniej pobiera z zasilania przy maksymalnej sprawności teoretycznej?
5. Dlaczego wzmacniacze klasy D osiągają sprawność ponad 90%?

<details>
<summary>Odpowiedzi</summary>

1. 9 W; ≈ 14,3 W; ≈ 63%; ≈ 5,3 W
2. $U_p = 14$ V: $P_{wy} = 196/16 = 12\text{,}25$ W, $P_{zas} = 2\cdot 15\cdot 1\text{,}75/\pi \approx 16\text{,}7$ W, $\eta \approx 73\%$
3. $U_p \approx 9\text{,}5$ V, $P_{strat} \approx 5\text{,}7$ W
4. Przy 25%: co najmniej 4 W (przez cały czas, także bez sygnału)
5. Tranzystory pracują jako klucze — są albo wyłączone (brak prądu), albo w pełni włączone (małe napięcie); iloczyn napięcia i prądu jest mały w obu stanach, a straty pochodzą głównie z $R_{DS(on)}$ i krótkich chwil przełączania
</details>

## Źródła

- [Semiconductor Devices — J. M. Fiore, rozdział o wzmacniaczach mocy](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html)
- [MIT 6.012 Microelectronic Devices and Circuits](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-spring-2009/) — stopnie wyjściowe we wzmacniaczach wielostopniowych
- [All About Circuits — tom Semiconductors, rozdział o klasach wzmacniaczy](https://www.allaboutcircuits.com/textbook/)
