# 08.02 — Multimetr i pomiary podstawowe

## Po co to jest

Multimetr to najczęściej używany przyrząd, a jednocześnie źródło wielu cichych błędów: woltomierz obciąża dzielnik wysokoomowy, amperomierz zmienia prąd w obwodzie, zwykły multimetr źle mierzy przebiegi odkształcone. Świadome pomiary podstawowe to warunek wiarygodnego uruchamiania układów.

## Teoria w pigułce

### Pomiar napięcia

Woltomierz ma skończoną rezystancję wejściową (typowo 10 MΩ, przyrządy precyzyjne na niskich zakresach > 10 GΩ). Mierząc punkt o rezystancji Thévenina $R_{th}$:

$$U_{zm} = U\frac{R_{we}}{R_{we} + R_{th}}, \qquad \delta \approx -\frac{R_{th}}{R_{we}}$$

### Pomiar prądu

Amperomierz to bocznik — wprowadza **spadek napięcia (burden voltage)**, który zmniejsza prąd w obwodzie o niskim napięciu. Pomiar prądu przez bocznik z osobnym woltomierzem lub sondą prądową (Halla, transformatorową) często jest lepszy.

### Pomiar rezystancji

- **Dwuprzewodowy:** wynik zawiera rezystancję przewodów i styków (dziesiątki–setki mΩ).
- **Czteroprzewodowy (Kelvina):** dwa przewody podają prąd, dwa mierzą napięcie bez prądu — eliminuje rezystancję doprowadzeń. Konieczny poniżej ok. 1 Ω.
- Siły termoelektryczne na złączach różnych metali (µV/K) — eliminuje się je pomiarem z odwróconym prądem (offset compensation).

### Pomiar napięć zmiennych

| Rodzaj przyrządu | Co mierzy | Kiedy poprawny |
|---|---|---|
| Średniej wartości wyprostowanej, skalowany w RMS | $1\text{,}11\cdot\overline{\lvert u\rvert}$ | Tylko dla sinusa |
| **True RMS** | $\sqrt{\overline{u^2}}$ | Dowolny przebieg w paśmie przyrządu i do określonego współczynnika szczytu |

Współczynnik szczytu (crest factor) $= U_{pk}/U_{RMS}$: sinus 1,41, prostokąt 1, impulsy o małym wypełnieniu — duży. Przyrząd podaje maksymalny dopuszczalny współczynnik szczytu i **pasmo** (często tylko kilka–kilkadziesiąt kHz!). Sprawdź też, czy przyrząd mierzy AC+DC czy tylko składową zmienną.

### Bezpieczeństwo

Kategorie pomiarowe CAT I–IV określają odporność na przepięcia zależnie od miejsca w instalacji. Zasada: przyrząd i przewody muszą mieć kategorię i napięcie co najmniej takie jak mierzony obwód. Pomiar prądu „na zakresie prądowym” przy przyłożonym napięciu = zwarcie.

## Przykład rozwiązany

**Obciążenie woltomierzem.** Dzielnik 1 MΩ/1 MΩ z 10 V, woltomierz 10 MΩ.

1. $R_{th} = 500$ kΩ, $U = 5$ V.
2. Wskazanie: $5\cdot\dfrac{10}{10\text{,}5} \approx 4\text{,}76$ V — błąd −4,8%, wielokrotnie większy niż specyfikacja przyrządu.
3. Korekcja: $U = U_{zm}\left(1 + \dfrac{R_{th}}{R_{we}}\right)$ — lub przyrząd o wyższej rezystancji wejściowej (tryb > 10 GΩ), lub bufor.

**Spadek napięcia amperomierza.** Zakres 200 mA z bocznikiem 1 Ω (plus przewody i bezpiecznik ok. 0,5 Ω), układ zasilany z 3,3 V pobiera 100 mA: spadek ok. 0,15 V — układ dostaje 3,15 V i może zachowywać się inaczej.

## Typowe pułapki

- **Pomiar wysokoomowych węzłów zwykłym multimetrem** (dzielniki, wyjścia czujników, bramki).
- **Pomiar przebiegu PWM** multimetrem bez true RMS lub o zbyt małym paśmie.
- **Przewody pomiarowe zostawione w gnieździe prądowym** — przy pomiarze napięcia zwarcie i przepalony bezpiecznik (albo gorzej).
- **Ignorowanie czasu ustalania** przy pomiarze rezystancji z dużą pojemnością równoległą.

## Ćwiczenie praktyczne

- [ ] Zmierz napięcie w środku dzielników 10 k/10 k, 1 M/1 M i 10 M/10 M zasilanych 10 V. Porównaj z obliczeniami uwzględniającymi rezystancję wejściową.
- [ ] Zmierz rezystancję przewodów pomiarowych zwartych ze sobą — to błąd każdego pomiaru dwuprzewodowego.
- [ ] Zmierz przebieg prostokątny 0/5 V o wypełnieniu 10% multimetrem true RMS i zwykłym; porównaj z wartościami teoretycznymi (średnia 0,5 V, RMS ≈ 1,58 V).

## Zadania

1. Dzielnik 1 MΩ / 1 MΩ, 10 V, woltomierz 10 MΩ. Co pokaże?
2. Jaka powinna być minimalna rezystancja wejściowa woltomierza, aby błąd z zadania 1 był mniejszy niż 0,1%?
3. Amperomierz o rezystancji 1,5 Ω mierzy prąd w obwodzie: źródło 3,3 V, obciążenie 33 Ω. Jaki prąd pokaże, a jaki płynie bez amperomierza?
4. Przebieg prostokątny 0/5 V, wypełnienie 10%. Ile wynosi wartość średnia, RMS (AC+DC) i współczynnik szczytu?
5. Multimetr średniej wartości wyprostowanej (skalowany dla sinusa) mierzy symetryczny prostokąt ±1 V. Co pokaże? Jaka jest prawdziwa wartość RMS?

<details>
<summary>Odpowiedzi</summary>

1. ≈ 4,76 V
2. $R_{we} > 1000\cdot R_{th} = 500$ MΩ
3. $3\text{,}3/34\text{,}5 \approx 95\text{,}7$ mA; bez amperomierza 100 mA
4. 0,5 V; $5\sqrt{0\text{,}1} \approx 1\text{,}58$ V; $5/1\text{,}58 \approx 3\text{,}16$
5. $1\text{,}11\cdot 1 = 1\text{,}11$ V; prawdziwa RMS = 1 V (błąd +11%)
</details>

## Źródła

- [All About Circuits — tom DC, rozdział *DC Metering Circuits*](https://www.allaboutcircuits.com/textbook/) — woltomierze, amperomierze, obciążenie przyrządem, pomiar Kelvina
- [Modular Electronics Learning (ModEL) Project](https://ibiblio.org/kuphaldt/socratic/model/) — moduły o multimetrach i pomiarach
- [DC Electrical Circuit Analysis — J. M. Fiore](https://eng.libretexts.org/Bookshelves/Electrical_Engineering/Electronics/DC_Electrical_Circuit_Analysis_-_A_Practical_Approach_%28Fiore%29) — przykłady wpływu przyrządu na obwód
