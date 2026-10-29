# 22.07 — Transoptory i izolacja galwaniczna

## Po co to jest

Sprzężenie zwrotne w zasilaczu sieciowym ([15.05](../15-energoelektronika-zasilanie/05-przetwornice-izolowane.md)), wejścia sterownika przemysłowego 24 V, sterowanie tranzystora górnego mostka, interfejs RS-485 w hali z falownikami, pomiar w torze sieciowym — wszędzie tam obwody muszą być **galwanicznie odizolowane**: ze względu na bezpieczeństwo (napięcie sieci), różnicę potencjałów mas i zakłócenia. Transoptor (dioda LED + fotodetektor w jednej obudowie) jest najstarszym i nadal najpopularniejszym sposobem.

## Teoria w pigułce

### Budowa i parametry

| Parametr | Znaczenie | Typowo |
|---|---|---|
| **CTR** (Current Transfer Ratio) | $I_C/I_F$ — stosunek prądu wyjściowego do prądu diody | 20–600% (klasy, np. 100–200%) |
| Napięcie izolacji | Próba napięciowa wejście–wyjście | 3,75–5 kV RMS przez 1 min |
| Odstępy izolacyjne (creepage, clearance) | Droga po powierzchni i w powietrzu | 5–8 mm dla izolacji wzmocnionej |
| CMTI | Odporność na szybkie zmiany napięcia między stronami | 10–100 kV/µs |
| Czasy $t_{on}$, $t_{off}$ | Zależne od $R_L$ i $I_F$ | 2–20 µs (fototranzystor) |

- CTR **zależy od prądu diody** (maksimum przy kilku mA), **od temperatury** i **maleje z czasem** (degradacja LED, szybciej przy dużym prądzie i temperaturze) — projektuje się z minimalnym CTR i zapasem 50% na starzenie.
- Rodzaje wyjść: fototranzystor (wolny, tani), fototranzystor Darlingtona (duży CTR, bardzo wolny), wyjście logiczne z wbudowanym wzmacniaczem (6N137: 10 Mb/s), fototriak (sterowanie obciążeniem sieciowym), fotowoltaiczny (sterowanie bramką MOSFET bez zasilania strony wtórnej).

### Projekt wyjścia cyfrowego (fototranzystor + rezystor podciągający)

- Stan niski wymaga nasycenia: $I_C \geq \dfrac{U_{CC} - U_{CE(sat)}}{R_L}$, a dostępny prąd to $I_F\cdot\mathrm{CTR}_{min}\cdot(1 - \text{zapas na starzenie})$.
- Szybkość: czas wyłączania rośnie z $R_L$ (pojemność kolektor–baza fototranzystora); mniejsze $R_L$ — szybciej, ale potrzebne większe $I_F$.

### Alternatywy

| Technologia | Zasada | Cechy |
|---|---|---|
| **Izolatory pojemnościowe** (cyfrowe) | Sygnał modulowany przez barierę z SiO₂ | Do 100+ Mb/s, brak degradacji, małe zużycie energii, wysoka CMTI |
| **Izolatory magnetyczne** (transformatorowe) | Mikrotransformatory w obudowie | Szybkie, mogą przenosić także zasilanie (izolowane DC/DC) |
| Transformator sygnałowy | Klasyczny transformator impulsowy | Sterowanie bramek, Ethernet |
| Światłowód | Pełna separacja, dowolne napięcie | Wysokie napięcia, silne zakłócenia, duże odległości |

## Przykład rozwiązany

**Wejście cyfrowe izolowane:** strona wejściowa 24 V, wyjście do mikrokontrolera 3,3 V. Transoptor z fototranzystorem, CTR 50–600% przy $I_F = 5$ mA (klasa szeroka), $U_{CE(sat)} = 0\text{,}4$ V.

1. Rezystor diody od 24 V: $R = (24 - 1\text{,}2)/0\text{,}005 = 4\text{,}56$ kΩ → 4,7 kΩ ($I_F = 4\text{,}85$ mA; moc 110 mW — rezystor 0,25 W).
2. Prąd wyjściowy w najgorszym przypadku: $4\text{,}85\ \text{mA}\cdot 0\text{,}5\cdot 0\text{,}5$ (CTR min., 50% na starzenie) $\approx 1\text{,}2$ mA.
3. Minimalny rezystor podciągający: $R_L \geq (3\text{,}3 - 0\text{,}4)/1\text{,}2\ \text{mA} = 2\text{,}4$ kΩ → wybieramy **4,7 kΩ** (potrzebne tylko 0,62 mA — duży zapas, ale czas wyłączania rzędu kilkudziesięciu µs; wystarcza dla wejść przekaźnikowych i sygnałów do kilku kHz).
4. Dla szybszych sygnałów: transoptor z wyjściem logicznym lub izolator cyfrowy.

## Typowe pułapki

- **Projekt na typowy CTR** — egzemplarz z CTR na dolnej granicy po kilku latach przestanie nasycać tranzystor.
- **Zbyt mały $R_L$** przy małym CTR — brak nasycenia, stan niski niezdefiniowany.
- **Płytka „zjadająca” izolację** — ścieżki, przelotki, wylewki masy pod transoptorem zmniejszają odstępy izolacyjne; potrzebna wolna strefa, czasem frezowana szczelina ([16.06](../16-pcb-emc-konstrukcja/06-emc-mechanizmy-i-normy.md)).
- **Pojemność sprzęgająca** przez barierę (ok. 1 pF) — szybkie zmiany potencjału (falowniki, $dU/dt$ = 50 kV/µs) wstrzykują prąd i dają fałszywe impulsy; wybieraj elementy o wysokiej CMTI.
- **Wolna odpowiedź przy sygnałach PWM** — transoptor z fototranzystorem zniekształca współczynnik wypełnienia.

## Ćwiczenie komputerowe

Dobór rezystorów transoptora z uwzględnieniem rozrzutu CTR, temperatury i starzenia (sprawdzenie nasycenia w najgorszym przypadku):

```python
import numpy as np

Vin_range = (19.2, 30.0)              # wejście 24 V ±20%/+25%
Vf, Vce_sat, Vcc = 1.2, 0.4, 3.3
R_in = 4.7e3
ctr_min, aging, temp_factor = 0.5, 0.5, 0.8      # CTR min., spadek po latach, spadek w wysokiej temperaturze

for Vin in Vin_range:
    IF = (Vin - Vf)/R_in
    Ic_avail = IF*ctr_min*aging*temp_factor
    RL_min = (Vcc - Vce_sat)/Ic_avail
    print(f"U_we = {Vin:4.1f} V: I_F = {IF*1e3:.2f} mA, dostępny I_C (najgorszy) = {Ic_avail*1e3:.2f} mA, "
          f"R_L ≥ {RL_min/1e3:.2f} kΩ, moc R_we = {(Vin - Vf)**2/R_in*1e3:.0f} mW")

# czas wyłączania ~ proporcjonalny do R_L (model: t_off ≈ k·R_L, k z karty katalogowej, np. 4 µs przy 1 kΩ)
for RL in (1e3, 4.7e3, 10e3):
    t_off = 4e-6*RL/1e3
    print(f"R_L = {RL/1e3:4.1f} kΩ: t_off ≈ {t_off*1e6:4.0f} µs → maks. ok. {1/(10*t_off)/1e3:.1f} kHz (zbocza < 10% okresu)")
```

Model czasu wyłączania jest liniowym przybliżeniem; dokładne wartości dają wykresy $t_{off}(R_L)$ w karcie katalogowej.

## Zadania

1. CTR = 100% przy $I_F = 10$ mA, wymagany prąd wyjściowy 2 mA. Jaki minimalny $I_F$ z zapasem 50% na starzenie?
2. Dlaczego w zasilaczu sieciowym transoptor w pętli sprzężenia zwrotnego wpływa na stabilność regulacji?
3. Jakie wymagania izolacyjne ma transoptor oddzielający obwód sieci 230 V od części dostępnej dla użytkownika?
4. Porównaj transoptor z fototranzystorem i izolator pojemnościowy dla łącza SPI 10 MHz.
5. Wejście 24 V z transoptorem reaguje na zakłócenia z długiego kabla. Jak zwiększyć odporność bez zmiany transoptora?

<details>
<summary>Odpowiedzi</summary>

1. Potrzebny CTR·I_F ≥ 2 mA przy CTR = 50% (po starzeniu) → $I_F \geq 4$ mA (uwaga: CTR zależy od $I_F$, sprawdzić wykres)
2. Transoptor wnosi biegun (pojemność kolektor–baza z rezystorem obciążenia, kilka–kilkadziesiąt kHz) i wzmocnienie zależne od CTR (rozrzut i starzenie) — oba wpływają na częstotliwość przecięcia i zapas fazy pętli ([15.06](../15-energoelektronika-zasilanie/06-sterowanie-i-kompensacja.md))
3. Izolacja wzmocniona: napięcie próby zwykle ≥ 3–4 kV RMS (zależnie od normy, np. IEC 62368-1), odstępy izolacyjne rzędu 6–8 mm, odpowiedni materiał obudowy (CTI), certyfikat (np. VDE, UL)
4. Fototranzystor — za wolny (µs); potrzebny izolator cyfrowy ≥ 25–50 Mb/s z małym opóźnieniem i dopasowanymi czasami kanałów (opóźnienie wpływa na odczyt MISO w SPI)
5. Zwiększyć prąd progowy (rezystor równoległy do diody LED, np. tak, by poniżej 1 mA dioda nie świeciła), filtr RC na wejściu, dioda TVS, filtr cyfrowy (eliminacja drgań) po stronie mikrokontrolera, dioda Zenera w szereg dla progu napięciowego
</details>

## Źródła

- [Vishay — AN04: Impact of Current Transfer Ratio on Optocouplers (PDF)](https://www.vishay.com/docs/80579/an04_impactcurrenttransferratiooptocouplers.pdf)
- [15.05 Przetwornice izolowane](../15-energoelektronika-zasilanie/05-przetwornice-izolowane.md) — transoptor w pętli regulacji
- [16.06 EMC: mechanizmy i normy](../16-pcb-emc-konstrukcja/06-emc-mechanizmy-i-normy.md) — bezpieczeństwo i odstępy izolacyjne
