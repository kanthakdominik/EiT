# 08.03 — Oscyloskop i sondy

## Po co to jest

Oscyloskop pokazuje, co naprawdę dzieje się w układzie w czasie: zbocza, dzwonienia, zakłócenia, przebiegi na magistralach. Ale to, co widać na ekranie, jest zawsze filtrowane przez pasmo przyrządu, próbkowanie i sondę. Źle dobrana sonda lub długi przewód masy potrafią „dodać” dzwonienie, którego w układzie nie ma.

## Teoria w pigułce

### Parametry oscyloskopu cyfrowego

| Parametr | Znaczenie | Reguła |
|---|---|---|
| **Pasmo (BW)** | Częstotliwość −3 dB toru wejściowego | 3–5 × najwyższa istotna częstotliwość sygnału |
| **Czas narastania** | $t_r \approx 0\text{,}35/\text{BW}$ (dla odpowiedzi gaussowskiej) | Mierzony $t_{zm} \approx \sqrt{t_{sygn}^2 + t_{osc}^2 + t_{sondy}^2}$ |
| **Częstotliwość próbkowania** | Próbki na sekundę | ≥ 2,5–5 × pasmo (z interpolacją sinx/x) |
| **Długość rekordu (pamięć)** | Liczba próbek | Czas rejestracji = długość / częstotliwość próbkowania |
| Rozdzielczość pionowa | Zwykle 8 bitów (nowsze 10–12) | Tryb wysokiej rozdzielczości (uśrednianie) zwiększa ją kosztem pasma |

Dla sygnałów cyfrowych pasmo dobiera się do zbocza, a nie do zegara: $f_{knee} \approx 0\text{,}5/t_r$.

**Przy dłuższej podstawie czasu oscyloskop obniża częstotliwość próbkowania** (pamięć się kończy) — może pojawić się aliasing. Tryb detekcji szczytów (peak detect) wychwytuje krótkie impulsy.

### Wyzwalanie

Zboczem (poziom, kierunek), szerokością impulsu, oknem, magistralą (I²C, SPI, UART, CAN) — dekodery protokołów to jedna z najużyteczniejszych funkcji przy uruchamianiu systemów wbudowanych. Tryby: auto, normal, single.

### Sondy

| Sonda | Cechy | Zastosowanie |
|---|---|---|
| Bierna 1:1 | Duża pojemność (ok. 50–100 pF), pasmo kilka MHz | Małe sygnały, wolne |
| **Bierna 10:1** | 10 MΩ ∥ ok. 10–15 pF, pasmo do kilkuset MHz | Standard |
| Aktywna | Mała pojemność (< 1 pF), duże pasmo, ograniczony zakres | Szybkie sygnały cyfrowe i RF |
| Różnicowa | Mierzy różnicę dwóch punktów, wysoki CMRR | Pomiary bez masy, układy mocy |
| Prądowa | Hall (AC+DC) lub transformator (AC) | Prąd bez przerywania obwodu |

**Kompensacja sondy 10:1:** regulowany kondensator ustawia się na sygnale kalibracyjnym (prostokąt), aż narożniki będą płaskie. Źle skompensowana sonda zniekształca amplitudę i kształt.

**Przewód masy:** typowo 15 cm = ok. 150 nH; z pojemnością wejściową sondy tworzy obwód rezonansowy rzędu 100–200 MHz → dzwonienie na zboczach. Przy szybkich sygnałach — krótka sprężynka masy przy grocie.

**Masa oscyloskopu jest połączona z uziemieniem sieci.** Podłączenie przewodu masy do punktu o innym potencjale (np. w układzie zasilanym z sieci bez separacji) to zwarcie.

## Przykład rozwiązany

Zbocze sygnału cyfrowego ma 5 ns, oscyloskop 100 MHz, sonda pasywna 10:1 o paśmie 500 MHz.

1. $t_{osc} = 3\text{,}5$ ns, $t_{sondy} = 0\text{,}7$ ns.
2. $t_{zm} = \sqrt{25 + 12\text{,}25 + 0\text{,}49} \approx 6\text{,}1$ ns — błąd ok. 23%.
3. Pomiar z błędem ok. 2% wymaga oscyloskopu o czasie narastania ok. 1 ns, czyli pasma ok. 350–500 MHz.

**Pamięć:** 1 GS/s i 10 ms rejestracji → potrzeba 10 Mpkt. Przy pamięci 1 Mpkt oscyloskop obniży próbkowanie do 100 MS/s.

## Typowe pułapki

- **Długi przewód masy** przy pomiarze szybkich zboczy.
- **Sonda 1:1 na sygnale kilkadziesiąt MHz** — pojemność obciąża układ i ogranicza pasmo.
- **Pomiar między dwoma punktami bez masy** dwoma kanałami bez sondy różnicowej, a nawet przewodem masy w niewłaściwym miejscu.
- **Aliasing na długiej podstawie czasu** — na ekranie pojawia się „wolny” sygnał, którego nie ma.
- **Niewłaściwy współczynnik sondy** w ustawieniach kanału (wynik 10 razy za duży lub za mały).

## Ćwiczenie praktyczne

- [ ] Skompensuj sondę na sygnale kalibracyjnym; zrób zrzuty ekranu dla sondy niedokompensowanej i przekompensowanej.
- [ ] Zmierz zbocze szybkiego układu logicznego (np. 74HC) z długim przewodem masy i ze sprężynką — porównaj dzwonienie.
- [ ] Ustaw dekoder UART lub I²C i zmierz czas jednej transakcji.
- [ ] Bez sprzętu: w LTspice zamodeluj sondę jako 10 MΩ ∥ 12 pF z szeregową indukcyjnością masy 150 nH i obejrzyj odpowiedź na zbocze 1 ns.

## Zadania

1. Oscyloskop 100 MHz. Jaki ma czas narastania? Jaki czas zmierzysz dla sygnału o $t_r = 5$ ns?
2. Jakie pasmo jest potrzebne do pomiaru zbocza 2 ns z błędem ok. 3%?
3. Oscyloskop ma pamięć 10 Mpkt. Jaka będzie maksymalna częstotliwość próbkowania przy rejestracji 100 ms?
4. Przewód masy ma 150 nH, pojemność wejściowa sondy 12 pF. Przy jakiej częstotliwości pojawi się rezonans?
5. Dlaczego do pomiaru napięcia na tranzystorze górnym w mostku H zasilanym z 400 V nie można użyć zwykłej sondy z przewodem masy?

<details>
<summary>Odpowiedzi</summary>

1. 3,5 ns; ≈ 6,1 ns
2. Oscyloskop powinien mieć $t_r \approx 0\text{,}5$ ns ($\sqrt{2^2 + 0\text{,}5^2} \approx 2\text{,}06$) → pasmo ok. 700 MHz
3. $10^7/0\text{,}1 = 100$ MS/s
4. $\dfrac{1}{2\pi\sqrt{150\cdot 10^{-9}\cdot 12\cdot 10^{-12}}} \approx 119$ MHz — dlatego dzwonienie widać już przy zboczach rzędu kilku ns
5. Emiter/źródło tranzystora górnego „pływa” względem masy sieci (przełącza się między 0 a 400 V); przewód masy sondy połączony z uziemieniem oscyloskopu zwarłby ten węzeł do ziemi. Potrzebna sonda różnicowa wysokonapięciowa (lub izolowany oscyloskop)
</details>

## Źródła

- [Tektronix — XYZs of Oscilloscopes (primer)](https://www.electronicdesign.com/resources/white-papers/whitepaper/21807643/xyzs-of-oscilloscopes-primer) — działanie, parametry, sondy, techniki pomiarowe
- [Modular Electronics Learning (ModEL) Project](https://ibiblio.org/kuphaldt/socratic/model/) — moduły o oscyloskopach
- [All About Circuits — tom Experiments, rozdział o przyrządach](https://www.allaboutcircuits.com/textbook/)
