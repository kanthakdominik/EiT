# 02.07 — Materiały elektroniczne w praktyce

## Po co to jest

Ten sam „kondensator 1 µF” może zachowywać się zupełnie inaczej w zależności od dielektryka: stracić 80% pojemności pod napięciem, zmieniać ją z temperaturą albo wysychać po kilku latach. Wiedza o materiałach pozwala świadomie dobierać elementy bierne i czytać ich dokumentację.

## Teoria w pigułce

### Rezystory

| Typ | Cechy | Zastosowanie |
|---|---|---|
| Węglowy | Tani, duży szum, słaba stabilność | Rzadko w nowych projektach |
| Metalizowany (warstwa metalowa) | Tolerancja 1% i lepsza, mały TCR, mały szum | Ogólne, precyzyjne |
| Grubowarstwowy SMD (thick film) | Tani, typowy dla SMD, większy szum i TCR | Większość elektroniki |
| Cienkowarstwowy SMD (thin film) | Precyzyjny, stabilny | Pomiary, przetworniki |
| Drutowy | Duża moc, indukcyjność | Obciążenia mocy, boczniki |
| Bocznik (shunt) z manganinu | Bardzo mały TCR, mała rezystancja | Pomiar prądu |

Parametry: tolerancja, moc, **TCR** (ppm/K), napięcie maksymalne, szum, indukcyjność pasożytnicza.

### Kondensatory — dielektryki

| Dielektryk | Pojemności | Stabilność | Uwagi |
|---|---|---|---|
| Ceramika klasy 1 (C0G/NP0) | pF–nF | Bardzo dobra (±30 ppm/K), brak efektu napięciowego | Filtry, generatory, w.cz. |
| Ceramika klasy 2 (X7R, X5R) | nF–dziesiątki µF | ±15% w zakresie temperatur, **duży spadek pojemności pod napięciem DC** | Odsprzęganie |
| Ceramika Y5V/Z5U | jak X7R | Zła (do −80%) | Unikać w nowych projektach |
| Foliowe (PP, PET) | nF–µF | Dobra, małe straty (PP) | Audio, filtry, impulsy, sieć |
| Elektrolityczne aluminiowe | µF–mF | Słaba, duże ESR, ograniczona trwałość (wysychanie) | Filtry zasilania |
| Polimerowe | µF–mF | Dobra, małe ESR | Zasilacze impulsowe |
| Tantalowe | µF | Dobra; ryzyko zapłonu przy przepięciu | Zasilanie, miejsce ograniczone |

Kondensatory elektrolityczne i tantalowe są **spolaryzowane**. Trwałość elektrolitów podaje się dla temperatury maksymalnej; reguła praktyczna: każde 10 °C mniej podwaja trwałość.

**Model rzeczywisty kondensatora:** $C$ + szeregowe ESR + szeregowe ESL. Powyżej częstotliwości rezonansu własnego $f = 1/(2\pi\sqrt{\text{ESL}\cdot C})$ kondensator zachowuje się jak cewka — dlatego do odsprzęgania stosuje się małe kondensatory ceramiczne blisko układu.

### Materiały magnetyczne

| Materiał | Częstotliwości | Zastosowanie |
|---|---|---|
| Blachy krzemowe | 50 Hz – kilka kHz | Transformatory sieciowe |
| Ferryty MnZn | do ok. 1 MHz | Transformatory i dławiki przetwornic |
| Ferryty NiZn | 1 MHz – setki MHz | Filtry EMI, koraliki ferrytowe |
| Proszkowe (żelazo, sendust) | kHz – MHz | Dławiki z dużym prądem DC (miękkie nasycenie) |

### Dielektryki płytek drukowanych

FR-4 ($\varepsilon_r \approx 4{,}3$, straty rosnące z częstotliwością) — standard do kilku GHz. Laminaty w.cz. (np. na bazie PTFE) — stabilne $\varepsilon_r$ i małe straty dla mikrofal.

## Przykład rozwiązany

Kondensator ceramiczny X5R 10 µF / 6,3 V w obudowie 0603, pracujący przy 5 V DC.

Producenci podają krzywe pojemności w funkcji napięcia DC. Dla małych obudów X5R spadek przy napięciu bliskim znamionowemu sięga często 60–80%. Rzeczywista pojemność może więc wynosić 2–4 µF zamiast 10 µF. Rozwiązania: wyższe napięcie znamionowe, większa obudowa, kilka kondensatorów równolegle — i zawsze sprawdzenie krzywej w dokumentacji.

## Typowe pułapki

- **Pojemność nominalna X7R/X5R** przyjmowana bez uwzględnienia napięcia DC i temperatury.
- **Elektrolit bez zapasu temperatury** obok gorącego elementu — szybkie wysychanie.
- **Ferryt do filtra EMI wybrany po indukcyjności** zamiast po impedancji w paśmie zakłóceń.
- **Rezystor dobrany tylko po mocy**, bez sprawdzenia napięcia maksymalnego (ważne przy wysokich napięciach i małych obudowach).

## Ćwiczenie komputerowe

W LTspice dodaj do kondensatora 100 nF szeregowe ESR = 20 mΩ i ESL = 1 nH. Wykonaj analizę `.ac` impedancji (źródło prądowe 1 A AC, obserwuj napięcie). Wyznacz rezonans własny i porównaj z kondensatorem 10 µF z ESL 2 nH. Połącz oba równolegle i zobacz wynik.

```spice
* 02.07 impedancja kondensatorow rzeczywistych
I1 0 a AC 1
C1 a b 100n
R1 b c 20m
L1 c 0 1n
.ac dec 100 1k 1G
.end
```

## Zadania

1. Kondensator 100 nF ma ESL = 1 nH. Jaka jest jego częstotliwość rezonansu własnego?
2. Do filtra aktywnego potrzebujesz kondensatora 10 nF o stabilnej pojemności. Jaki dielektryk wybierzesz i dlaczego?
3. Elektrolit o trwałości 2000 h w 105 °C pracuje w 65 °C. Oszacuj trwałość.
4. Rezystor grubowarstwowy ma TCR = 200 ppm/K. O ile zmieni się jego rezystancja przy wzroście temperatury o 50 K?
5. Dlaczego do bocznika pomiarowego prądu nie używa się zwykłego rezystora węglowego?

<details>
<summary>Odpowiedzi</summary>

1. $f = \dfrac{1}{2\pi\sqrt{10^{-9}\cdot 10^{-7}}} \approx 15{,}9$ MHz
2. C0G/NP0 — brak zależności od napięcia i bardzo mała od temperatury (ewentualnie folia PP przy większych pojemnościach)
3. 40 K mniej to 4 podwojenia: ok. $2000\cdot 16 = 32\,000$ h (oszacowanie zgrubne)
4. $200\cdot 10^{-6}\cdot 50 = 1\%$
5. Duży i niestabilny TCR, szum, mała dokładność i ograniczona obciążalność — bocznik musi mieć stałą, dokładną rezystancję niezależną od nagrzewania prądem mierzonym
</details>

## Źródła

- [All About Circuits Textbook](https://www.allaboutcircuits.com/textbook/) — tomy DC i Reference: przewodniki, izolatory, kondensatory, cewki
- [Analog Devices — Electronics I and II](https://wiki.analog.com/university/courses/electronics/text/electronics-toc) — elementy bierne i ich modele
- Dokumentacja producentów kondensatorów ceramicznych — krzywe zależności pojemności od napięcia DC (DC bias) i temperatury
