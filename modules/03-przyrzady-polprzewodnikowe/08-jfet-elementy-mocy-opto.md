# 03.08 — JFET, elementy mocy i optoelektronika

## Po co to jest

JFET wciąż pojawia się w niskoszumowych wejściach wzmacniaczy i źródłach prądowych. Tyrystory, triaki i IGBT przełączają duże moce w napędach i sieci. Transoptory izolują galwanicznie obwody sterowania od obwodów mocy i sieci — to kwestia bezpieczeństwa.

## Teoria w pigułce

### JFET

Kanał (np. typu n) zwężany warstwą zaporową złącza bramka–kanał. **Normalnie włączony**: przy $U_{GS} = 0$ płynie maksymalny prąd $I_{DSS}$; przy $U_{GS} = U_P$ (napięcie odcięcia, ujemne dla kanału n) kanał się zamyka.

$$I_D = I_{DSS}\left(1 - \frac{U_{GS}}{U_P}\right)^2, \qquad g_m = \frac{2I_{DSS}}{\lvert U_P\rvert}\left(1 - \frac{U_{GS}}{U_P}\right)$$

Bramka musi być spolaryzowana zaporowo (prąd bramki rzędu pA). Zastosowania: wzmacniacze o dużej impedancji wejściowej i małym szumie, proste źródło prądowe (JFET z bramką zwartą ze źródłem).

### Przyrządy mocy

| Przyrząd | Sterowanie | Wyłączanie | Typowe zastosowanie |
|---|---|---|---|
| **Tyrystor (SCR)** | Impuls prądu bramki | Tylko spadek prądu poniżej prądu podtrzymania | Prostowniki sterowane, softstarty |
| **Triak** | Impuls bramki, oba kierunki | Przejście prądu przez zero | Ściemniacze, sterowanie grzałkami 230 V |
| **MOSFET mocy** | Napięcie bramki | Pełne sterowanie | Przetwornice do ok. 200 V (Si) |
| **IGBT** | Napięcie bramki (jak MOSFET) | Pełne, ale wolniejsze („ogon” prądu) | Falowniki, napędy, 600–1700 V |
| **SiC MOSFET** | Napięcie bramki (zwykle wyższe) | Pełne, szybkie | Wysokie napięcia, wysoka sprawność |
| **GaN HEMT** | Napięcie bramki (wąski zakres!) | Bardzo szybkie | Zasilacze o dużej gęstości mocy |

IGBT łączy wejście MOS z wyjściem bipolarnym: spadek napięcia w stanie włączenia ma postać $U_{CE(sat)} \approx 1{,}5$–2 V (niezależnie od prądu bardziej niż $R_{DS(on)}$), co przy dużych prądach i napięciach daje mniejsze straty niż MOSFET krzemowy.

### Optoelektronika i izolacja

**Transoptor** — dioda LED i fototranzystor w jednej obudowie, rozdzielone izolacją (typowo kilka kV). Kluczowy parametr — **CTR** (current transfer ratio): $I_C = \text{CTR}\cdot I_F$. CTR ma duży rozrzut, maleje z czasem i temperaturą. Fototranzystor jest wolny (µs); szybsze są transoptory z wyjściem logicznym. Alternatywy: izolatory pojemnościowe i magnetyczne.

## Przykład rozwiązany

**JFET:** $I_{DSS} = 10$ mA, $U_P = -4$ V, $U_{GS} = -2$ V.

$I_D = 10(1 - 0{,}5)^2 = 2{,}5$ mA; $g_m = \dfrac{2\cdot 10}{4}(1 - 0{,}5) = 2{,}5$ mS.

**Transoptor jako izolowane wejście cyfrowe.** Dioda sterowana prądem 5 mA, CTR minimalny 50% → fototranzystor pewnie przewodzi do 2,5 mA. Wyjście z rezystorem podciągającym do 5 V: aby fototranzystor był nasycony przy najgorszym CTR, $R \geq \dfrac{5\ \text{V}}{2{,}5\ \text{mA}} = 2$ kΩ → np. 4,7 kΩ (kosztem wolniejszego zbocza narastającego).

## Typowe pułapki

- **JFET z bramką spolaryzowaną w kierunku przewodzenia** — płynie prąd bramki, tracona jest główna zaleta.
- **Projekt transoptora z typowym CTR** — po kilku latach pracy CTR spada i układ przestaje działać.
- **Triak do obciążeń indukcyjnych bez snubbera** — samoczynne włączanie przy szybkim wzroście napięcia.
- **GaN sterowany jak MOSFET krzemowy** — przekroczenie dopuszczalnego $U_{GS}$ (często tylko kilka V) niszczy tranzystor.

## Symulacja

W LTspice zbuduj transoptor jako LED + źródło prądowe sterowane prądem diody (`F1 c e V_sense 0.5` — CTR 50%) z rezystorem podciągającym. Sprawdź, przy jakim minimalnym prądzie diody wyjście osiąga poziom niski poniżej 0,4 V dla rezystorów 1 kΩ, 4,7 kΩ i 10 kΩ.

## Zadania

1. JFET: $I_{DSS} = 10$ mA, $U_P = -4$ V. Wyznacz $I_D$ i $g_m$ przy $U_{GS} = -2$ V oraz $g_m$ przy $U_{GS} = 0$.
2. Jakie $U_{GS}$ daje prąd 6,4 mA?
3. Transoptor: $I_F = 10$ mA, CTR 100–300%, zasilanie wyjścia 3,3 V. Dobierz rezystor podciągający, który zapewni nasycenie przy każdym egzemplarzu.
4. Dlaczego do falownika 400 V AC (napięcie DC ok. 600 V) częściej stosuje się IGBT lub SiC niż MOSFET krzemowy?
5. Dlaczego tyrystora nie można wyłączyć impulsem bramki?

<details>
<summary>Odpowiedzi</summary>

1. $I_D = 2{,}5$ mA, $g_m = 2{,}5$ mS; przy $U_{GS} = 0$: $g_{m0} = 5$ mS
2. $\sqrt{0{,}64} = 0{,}8 = 1 - U_{GS}/U_P$ → $U_{GS} = -0{,}8$ V
3. Minimalny prąd wyjściowy 10 mA; $R \geq 3{,}3\ \text{V}/10\ \text{mA} = 330\ \Omega$ — z zapasem np. 1 kΩ
4. Krzemowe MOSFET-y wysokonapięciowe mają bardzo dużą $R_{DS(on)}$; IGBT ma mniejsze straty przewodzenia przy wysokich napięciach i dużych prądach, a SiC łączy niskie straty z szybkim przełączaniem
5. Po włączeniu struktura czterowarstwowa podtrzymuje przewodzenie dzięki wewnętrznemu dodatniemu sprzężeniu zwrotnemu dwóch tranzystorów; bramka traci kontrolę, dopóki prąd nie spadnie poniżej prądu podtrzymania
</details>

## Źródła

- [Semiconductor Devices — J. M. Fiore, rozdziały o JFET](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html)
- [All About Circuits — tom Semiconductors, rozdziały o JFET, tyrystorach i optoelektronice](https://www.allaboutcircuits.com/textbook/)
- [Analog Devices — Electronics I and II](https://wiki.analog.com/university/courses/electronics/text/electronics-toc)
