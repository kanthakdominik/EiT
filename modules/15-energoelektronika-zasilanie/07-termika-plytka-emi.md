# 15.07 — Termika, układ płytki i zakłócenia

## Po co to jest

Przetwornica, która na schemacie ma 92% sprawności, na źle zaprojektowanej płytce przegrzewa się, „dzwoni”, zakłóca radio i nie przechodzi badań EMC. W energoelektronice układ ścieżek jest częścią obwodu: indukcyjności pasożytnicze pętli prądowych i powierzchnie węzłów przełączających decydują o przepięciach i emisji. Do tego każdy wat strat trzeba odprowadzić z dopuszczalną temperaturą elementów.

## Teoria w pigułce

### Termika

Model cieplny jak obwód elektryczny ([03.09](../03-przyrzady-polprzewodnikowe/09-datasheety-i-termika.md)): $T_j = T_a + P\cdot\sum R_{th}$.

| Ścieżka ciepła | Typowe wartości |
|---|---|
| $R_{th,ja}$ SOT-23 | ok. 150–250 K/W (silnie zależne od miedzi na płytce) |
| $R_{th,ja}$ obudowa z padem termicznym (DPAK, QFN) | ok. 30–60 K/W z polem miedzi i przelotkami |
| $R_{th,jc}$ TO-220 | ok. 0,5–5 K/W |
| Radiator | od ok. 1 K/W (duży, żebrowany) do ok. 20–30 K/W (mały) |
| Przelotki termiczne | Siatka przelotek pod padem przenosi ciepło na warstwy wewnętrzne i spód |

**Rozkład strat** — ważniejsza jest temperatura najgorętszego elementu niż sprawność całości. Elektrolity i ceramika (pojemność!) mają własne ograniczenia temperaturowe; trwałość elektrolitu maleje o połowę co +10 K.

**Termowizja** lub termopara w czasie pracy przy maksymalnym obciążeniu i temperaturze otoczenia — obowiązkowy etap weryfikacji.

### Pętle prądu impulsowego

W buck prąd **wejściowy** jest impulsowy: pętla kondensator wejściowy → klucz górny → klucz dolny/dioda → masa kondensatora przenosi prąd przełączany z szybkością $dI/dt$ rzędu A/ns. Indukcyjność tej pętli (nawet kilka nH) daje przepięcia $L\,dI/dt$ i dzwonienie węzła przełączającego.

| Topologia | Pętla krytyczna („gorąca”) |
|---|---|
| Buck | Kondensator wejściowy – klucze |
| Boost | Klucze – kondensator **wyjściowy** |
| Flyback | Kondensator wejściowy – uzwojenie pierwotne – klucz; oraz uzwojenie wtórne – dioda – kondensator wyjściowy |

### Zasady układu płytki przetwornicy

1. **Najkrótsza pętla gorąca:** kondensator ceramiczny (mały, w.cz.) bezpośrednio przy pinach kluczy/układu, z masą przez kilka przelotek do ciągłej płaszczyzny masy.
2. **Węzeł przełączający (SW) mały** — jego powierzchnia to antena pola E (dV/dt rzędu V/ns); tylko tyle miedzi, ile wymaga prąd i chłodzenie.
3. **Ciągła płaszczyzna masy** pod przetwornicą (warstwa 2), bez przecięć pod pętlami prądowymi.
4. **Sprzężenie zwrotne** prowadzone z dala od węzła SW i dławika, mierzone w punkcie obciążenia (lub przy kondensatorze wyjściowym), masa sygnałowa dzielnika do masy cichej układu.
5. **Dławik ekranowany**, nie pod czułymi ścieżkami.
6. Pomiar prądu (bocznik) z połączeniem Kelvina.

### Zakłócenia (EMI)

- **Przewodzone** (do ok. 30 MHz): prąd impulsowy wraca do źródła przez przewody zasilające — **filtr wejściowy** (LC, dławik wspólny); uwaga: filtr wejściowy ma ujemną rezystancję wejściową przetwornicy po drugiej stronie — możliwa niestabilność (warunek Middlebrooka: impedancja wyjściowa filtra ≪ impedancji wejściowej przetwornicy).
- **Promieniowane:** pętle prądowe (pole H), węzły o dużym dV/dt (pole E), kable jako anteny.
- Techniki: spowolnienie zboczy (rezystor bramki — kosztem strat), snubber RC na węźle SW, **rozpraszanie widma** (modulacja częstotliwości przełączania), ekranowanie.

Szczegóły kompatybilności EM i projektowania płytek — moduł [16](../16-pcb-emc-konstrukcja/).

## Przykład rozwiązany

**Termika buck:** straty 0,47 W (z [15.04](04-elementy-straty-sprawnosc.md)): dioda 0,29 W, klucz 0,13 W, dławik 0,05 W.
- Dioda Schottky w obudowie SOD-123 ($R_{th,ja}$ ok. 200 K/W): $\Delta T \approx 58$ K — przy 50 °C otoczenia ok. 108 °C; dopuszczalne, ale bez zapasu (Schottky ma też prąd upływu rosnący z temperaturą). W obudowie SMA lub z większym polem miedzi (ok. 80 K/W): ok. 23 K.
- Wniosek: wersja synchroniczna lepsza także termicznie.

**Przepięcie na pętli:** pętla gorąca o indukcyjności 5 nH, prąd 1 A przełączany w 5 ns: $L\,dI/dt = 5\cdot 10^{-9}\cdot 2\cdot 10^8 = 1$ V; przy 10 A i 2 ns — 25 V przepięcia na kluczu 30 V.

## Typowe pułapki

- **Kondensator wejściowy „gdzieś na płytce”** zamiast przy kluczach.
- **Podziały płaszczyzny masy** pod przetwornicą („masa analogowa i cyfrowa” rozcięta w złym miejscu).
- **Ścieżka sprzężenia zwrotnego pod dławikiem** — sprzężenie pola magnetycznego, niestabilność.
- **Pole miedzi pod układem bez przelotek termicznych** — ciepło nie ma drogi.
- **Filtr wejściowy bez tłumienia** — rezonans z przetwornicą, oscylacje wejścia.

## Ćwiczenie komputerowe

Kalkulator temperatur elementów i przepięcia na pętli; widmo prostokąta węzła SW — dlaczego szybsze zbocza zwiększają emisję wysokich częstotliwości:

```python
import numpy as np

parts = {'dioda SOD-123': (0.29, 200), 'dioda SMA + miedź': (0.29, 80), 'MOSFET SOT-23': (0.13, 180),
         'dławik': (0.05, 60)}
Ta = 50
for n, (P, Rth) in parts.items():
    print(f"{n:20s}: P = {P:.2f} W, Tj ≈ {Ta + P*Rth:5.1f} °C")
for L, I, t in [(5e-9, 1, 5e-9), (5e-9, 10, 2e-9), (1e-9, 10, 2e-9)]:
    print(f"L = {L*1e9:.0f} nH, {I} A w {t*1e9:.0f} ns: przepięcie {L*I/t:.1f} V")

# obwiednia widma trapezu (12 V, 500 kHz, D = 0,275): spadek -20 dB/dek od 1/(pi*tau), -40 dB/dek od 1/(pi*tr)
V, f0, D = 12.0, 500e3, 0.275
tau = D/f0
for tr in [20e-9, 2e-9]:
    for f in [1e6, 30e6, 100e6, 300e6]:
        env = 2*V*D*min(1, 1/(np.pi*f*tau))*min(1, 1/(np.pi*f*tr))
        print(f"tr = {tr*1e9:4.0f} ns, {f/1e6:5.0f} MHz: obwiednia ≈ {20*np.log10(env/1e-6):6.1f} dBµV "
              f"(drugi punkt załamania 1/(π tr) = {1/(np.pi*tr)/1e6:.0f} MHz)")
```

## Zadania

1. Element traci 0,8 W, $R_{th,ja}$ = 45 K/W, $T_a$ = 60 °C. Jaka temperatura złącza? Czy to dopuszczalne dla $T_{j,max}$ = 125 °C?
2. Która pętla jest krytyczna w przetwornicy boost i dlaczego inna niż w buck?
3. Węzeł SW przełącza 24 V w 3 ns. Ile wynosi dV/dt? Ile prądu popłynie przez pojemność pasożytniczą 10 pF do pobliskiej ścieżki?
4. Wyjaśnij, dlaczego rozpraszanie widma (dithering częstotliwości) obniża zmierzone poziomy emisji, choć energia zakłóceń się nie zmienia.
5. Dlaczego filtr wejściowy LC przetwornicy może spowodować oscylacje?

<details>
<summary>Odpowiedzi</summary>

1. $60 + 0\text{,}8\cdot 45 = 96$ °C — dopuszczalne (zapas ok. 29 K)
2. W boost prąd impulsowy płynie po stronie wyjściowej (klucz → dioda/klucz → kondensator wyjściowy), a prąd wejściowy (przez dławik) jest ciągły; w buck odwrotnie
3. $8$ V/ns $= 8\cdot 10^9$ V/s; $i = C\,dV/dt = 10\cdot 10^{-12}\cdot 8\cdot 10^9 = 80$ mA impulsowo
4. Energia rozkłada się na szerszy zakres częstotliwości; odbiornik pomiarowy EMC mierzy w paśmie o ustalonej szerokości (np. 9 kHz lub 120 kHz) — w każdym paśmie trafia mniej mocy, więc szczytowy poziom w danym paśmie jest niższy
5. Przetwornica ze stabilizacją napięcia wyjściowego pobiera stałą moc: wzrost napięcia wejściowego zmniejsza prąd — ma ujemną rezystancję wejściową, która może odtłumić rezonans filtra LC
</details>

## Źródła

- [MIT 6.622 Power Electronics](https://ocw.mit.edu/courses/6-622-power-electronics-spring-2023/) — termika, elementy pasożytnicze, filtry wejściowe
- [TI SLVA477](https://www.ti.com/lit/pdf/SLVA477) i karty katalogowe układów przetwornic — zalecany układ płytki (layout guidelines)
- [Analog Devices — Electronics I and II](https://wiki.analog.com/university/courses/electronics/text/electronics-toc) — zarządzanie zasilaniem
- Powiązane: [16 PCB, EMC i konstrukcja](../16-pcb-emc-konstrukcja/), [08.07 Zakłócenia i ekranowanie](../08-miernictwo/07-zaklocenia-i-ekranowanie.md)
