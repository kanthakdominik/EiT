# 04.01 — Układy z diodami: prostowniki, ograniczniki, stabilizator Zenera

## Po co to jest

Każde urządzenie zasilane z sieci ma prostownik. Ograniczniki chronią wejścia przed przepięciami, układy przesuwające poziom (clamp) odtwarzają składową stałą sygnału, a diodę Zenera stosuje się w najprostszych źródłach napięcia.

## Teoria w pigułce

### Prostowniki

| Układ | Diody | Napięcie szczytowe na wyjściu | Częstotliwość tętnień | Napięcie wsteczne na diodzie |
|---|---|---|---|---|
| Jednopołówkowy | 1 | $U_m - U_F$ | $f$ | $\approx 2U_m$ (z kondensatorem) |
| Dwupołówkowy z odczepem | 2 | $U_m - U_F$ (z połowy uzwojenia) | $2f$ | $\approx 2U_m$ |
| Mostek Graetza | 4 | $U_m - 2U_F$ | $2f$ | $\approx U_m$ |

$U_m = \sqrt2\,U_{RMS}$ — amplituda napięcia transformatora.

### Filtr pojemnościowy

Kondensator ładuje się w szczytach i rozładowuje prądem obciążenia między nimi. Przy małych tętnieniach:

$$\Delta U \approx \frac{I_L}{f_t C}$$

$f_t$ — częstotliwość tętnień (50 Hz dla jednopołówkowego, 100 Hz dla dwupołówkowego przy sieci 50 Hz).

Konsekwencje: diody przewodzą tylko przez krótki czas w okolicy szczytu, więc **prąd szczytowy diod jest wielokrotnie większy niż prąd obciążenia**. Prąd ładowania przy włączeniu (inrush) może być bardzo duży.

### Ograniczniki (clipper) i układy przesuwające poziom (clamp)

- **Ogranicznik** — dioda (lub dioda + źródło odniesienia) „obcina” sygnał powyżej poziomu $U_{ref} + U_F$. Podwójny ogranicznik z dwiema diodami do zasilania chroni wejścia układów scalonych.
- **Układ przesuwający poziom** — kondensator szeregowy + dioda do masy: sygnał przesuwa się tak, by jego ekstremum leżało na poziomie ok. $-U_F$.
- **Powielacz napięcia** — połączenie układu przesuwającego poziom i prostownika szczytowego; podwaja napięcie szczytowe (przy małym obciążeniu).

### Stabilizator parametryczny z diodą Zenera

$$R \leq \frac{U_{we,min} - U_Z}{I_{L,max} + I_{Z,min}}$$

Moc diody sprawdza się w najgorszym przypadku: największe $U_{we}$, brak obciążenia.

## Przykład rozwiązany

**Zasilacz:** transformator 12 V RMS, mostek, kondensator 2200 µF, obciążenie 0,5 A, sieć 50 Hz.

1. $U_m = 12\sqrt2 \approx 16{,}97$ V; po mostku $U_{pk} \approx 16{,}97 - 1{,}4 \approx 15{,}6$ V.
2. Tętnienia: $\Delta U \approx \dfrac{0{,}5}{100\cdot 2{,}2\cdot 10^{-3}} \approx 2{,}27$ V. Napięcie minimalne ≈ 13,3 V.
3. Diody: napięcie wsteczne ≈ 17 V (+ zapas na wahania sieci ±10%) → diody 1 A / 50 V lub wyższe; prąd szczytowy wielokrotnie większy niż 0,5 A.
4. Kondensator: napięcie znamionowe co najmniej 25 V (sieć +10% daje ok. 17,3 V bez obciążenia), prąd tętnień z dokumentacji.

**Stabilizator Zenera:** $U_{we} = 12$ V, $U_Z = 5{,}1$ V, $I_{L,max} = 20$ mA, $I_{Z,min} = 5$ mA.

1. $R \leq \dfrac{12 - 5{,}1}{25\ \text{mA}} = 276\ \Omega$ → 270 Ω.
2. Bez obciążenia cały prąd $\dfrac{6{,}9}{270} \approx 25{,}6$ mA płynie przez diodę: $P_Z \approx 0{,}13$ W → dioda 0,5 W z zapasem.
3. Rezystor: $6{,}9\cdot 25{,}6\ \text{mA} \approx 0{,}18$ W → 0,25 W to już mało, lepiej 0,5 W.

## Typowe pułapki

- **Zapominanie o dwóch spadkach $U_F$ w mostku.**
- **Prąd diod równy prądowi obciążenia** — szczytowy jest kilka–kilkanaście razy większy.
- **Napięcie kondensatora liczone z nominalnego napięcia sieci** — sieć może mieć +10%, a transformator bez obciążenia daje więcej niż znamionowo.
- **Stabilizator Zenera do dużych prądów** — sprawność jest bardzo mała, a dioda grzeje się najmocniej bez obciążenia.

## Symulacja

```spice
* 04.01 prostownik mostkowy z filtrem pojemnosciowym
V1 a b SINE(0 16.97 50)
D1 a p D1N4007
D2 b p D1N4007
D3 n a D1N4007
D4 n b D1N4007
C1 p n 2200u
RL p n 31
.model D1N4007 D(Is=7.02767n Rs=0.0341512 N=1.80803 Cjo=10p M=0.3 Bv=1000 Ibv=5u)
.tran 0 200m 100m
.end
```

($R_L = 31\ \Omega$ ≈ 0,5 A przy ok. 15 V.) Zmierz tętnienia i prąd szczytowy diody. Zmień kondensator na 4700 µF — jak zmieniają się tętnienia i prąd szczytowy?

## Zadania

1. Transformator 12 V RMS, mostek, 2200 µF, 0,5 A, 50 Hz. Wyznacz $U_{pk}$, tętnienia i napięcie minimalne.
2. Ten sam zasilacz z prostownikiem jednopołówkowym. Ile wynoszą tętnienia?
3. Dobierz kondensator, aby tętnienia przy 1 A (mostek, 50 Hz) nie przekraczały 1 V.
4. Stabilizator Zenera: $U_{we} = 12$ V, $U_Z = 5{,}1$ V, $I_L$ = 0–20 mA, $I_{Z,min} = 5$ mA. Dobierz rezystor i moc diody.
5. Wejście układu zasilanego 3,3 V chronią dwie diody (do masy i do zasilania) z rezystorem 1 kΩ. Jaki prąd popłynie przez diodę przy sygnale wejściowym 12 V?
6. Sinusoida o amplitudzie 5 V przechodzi przez układ przesuwający poziom (kondensator + dioda do masy, dioda katodą do masy). W jakim zakresie zmienia się napięcie wyjściowe?

<details>
<summary>Odpowiedzi</summary>

1. ≈ 15,6 V; ≈ 2,27 V; ≈ 13,3 V
2. $\Delta U \approx 0{,}5/(50\cdot 2{,}2\cdot 10^{-3}) \approx 4{,}5$ V (dwa razy więcej)
3. $C \geq \dfrac{1}{100\cdot 1} = 10\,000\ \mu$F
4. 270 Ω; moc diody ≈ 0,13 W (dioda 0,5 W), rezystor 0,5 W
5. $\dfrac{12 - 3{,}3 - 0{,}7}{1\ \text{k}} = 8$ mA — płynie do szyny zasilania; jeśli układ pobiera mniej, napięcie zasilania może wzrosnąć (dlatego stosuje się też diody TVS lub ograniczenie prądu)
6. Przy diodzie katodą do masy dioda przewodzi przy dodatnich szczytach i kondensator ładuje się tak, że maksimum wyjścia ≈ +0,7 V; wyjście zmienia się od ok. −9,3 V do +0,7 V
</details>

## Źródła

- [Semiconductor Devices — J. M. Fiore, rozdziały o zastosowaniach diod](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html) — prostowniki, ograniczniki, układy przesuwające poziom, Zener
- [All About Circuits — tom Semiconductors, rozdział *Diodes and Rectifiers*](https://www.allaboutcircuits.com/textbook/)
- [Falstad — demonstracje diod](https://falstad.com/circuit/e-index.html) — prostowniki, powielacze, ograniczniki
