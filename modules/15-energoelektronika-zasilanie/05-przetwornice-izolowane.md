# 15.05 — Przetwornice izolowane: flyback i forward

## Po co to jest

Zasilacz sieciowy — ładowarka telefonu, zasilacz laptopa, zasilacz w urządzeniu przemysłowym — musi oddzielić galwanicznie niskie napięcie od sieci 230 V, ze względów bezpieczeństwa. Robią to przetwornice z transformatorem pracującym przy dziesiątkach–setkach kHz: mały, lekki i sprawny w porównaniu z transformatorem sieciowym 50 Hz. Najczęściej spotkasz flyback (do ok. 100–150 W) i forward, a przy większych mocach — układy mostkowe i rezonansowe.

## Teoria w pigułce

### Tor zasilacza sieciowego

Filtr EMI → prostownik i kondensator (ok. 325 V DC z 230 V AC) → (dla P > ok. 75 W — korektor współczynnika mocy PFC, zwykle boost do ok. 400 V) → przetwornica izolowana → prostownik wyjściowy i filtr → pętla sprzężenia zwrotnego przez **transoptor** (lub uzwojenie pomocnicze — regulacja po stronie pierwotnej).

### Flyback

Topologia buck-boost z transformatorem (właściwie z dwoma sprzężonymi dławikami): w czasie przewodzenia klucza energia gromadzi się w szczelinie rdzenia, po wyłączeniu przekazywana jest do wyjścia.

$$U_{wy} = U_{we}\frac{D}{1 - D}\cdot\frac{N_s}{N_p}\quad\text{(CCM)},\qquad U_{DS,max} = U_{we,max} + n(U_{wy} + U_F) + U_{szpilki}$$

($n = N_p/N_s$; $n(U_{wy} + U_F)$ — napięcie odbite).
- Proste, tanie, wiele wyjść z jednego transformatora; tryby DCM, CCM, quasi-rezonansowy (przełączanie w dolinie napięcia — mniejsze straty).
- **Indukcyjność rozproszenia** — po wyłączeniu klucza jej energia daje przepięcie: **snubber RCD** (lub clamp aktywny) ogranicza napięcie na tranzystorze, tracąc tę energię w rezystorze ($P \approx \tfrac12L_{lk}I_{pk}^2f_{sw}\cdot\dfrac{U_{cl}}{U_{cl} - nU_{wy}}$).
- Transformator ze szczeliną powietrzną (magazynuje energię) — duże tętnienia prądu, większe kondensatory wyjściowe.

### Forward

Topologia buck z transformatorem: energia przekazywana w czasie przewodzenia klucza, dławik wyjściowy jak w buck.

$$U_{wy} = U_{we}\cdot D\cdot\frac{N_s}{N_p}$$

Transformator nie magazynuje energii (bez szczeliny), ale **rdzeń trzeba rozmagnesować** w każdym okresie: uzwojenie rozmagnesowujące, clamp aktywny lub układ dwutranzystorowy → ograniczenie $D \leq 0\text{,}5$ (dla klasycznego). Lepszy od flyback powyżej ok. 100 W.

### Większe moce

Półmostek, pełny mostek, push-pull; **LLC** (rezonansowy) — przełączanie przy zerowym napięciu (ZVS), bardzo wysoka sprawność (zasilacze serwerowe, telewizory, ładowarki). Przetwornice z aktywnym mostkiem podwójnym (DAB) — dwukierunkowe (ładowarki pojazdów).

### Bezpieczeństwo i normy

Odstępy izolacyjne (creepage, clearance), izolacja wzmocniona transformatora i transoptora, kondensatory klasy Y między stroną pierwotną a wtórną (prąd upływu), bezpiecznik, warystor, termistor NTC ograniczający prąd rozruchowy. Normy bezpieczeństwa urządzeń (np. IEC 62368-1) i kompatybilności EM.

**Praca przy sieci 230 V wymaga odpowiedniej wiedzy i zabezpieczeń** — kondensator po prostowniku przechowuje ok. 325 V długo po odłączeniu. Do nauki: gotowe moduły, transformator separujący, ograniczony prąd, symulacja.

## Przykład rozwiązany

Flyback 325 V DC → 12 V / 1 A, przekładnia $n = N_p/N_s = 10$, dioda 0,5 V.

1. Napięcie odbite: $10\cdot(12 + 0\text{,}5) = 125$ V.
2. Wypełnienie (CCM, idealnie): $D = \dfrac{125}{325 + 125} \approx 0\text{,}28$.
3. Napięcie na tranzystorze: $325 + 125 = 450$ V + szpilka od rozproszenia (np. 100 V) → tranzystor 600–650 V.
4. Napięcie wsteczne diody wyjściowej: $12 + 325/10 = 44\text{,}5$ V → dioda ≥ 60 V.
5. Większe $n$ zmniejsza obciążenie diody, ale zwiększa napięcie na tranzystorze — dobór przekładni to kompromis.

**Forward** 48 V → 5 V przy $D_{max}$ = 0,45: $N_s/N_p \geq 5/(48\cdot 0\text{,}45) \approx 0\text{,}23$ (przy minimalnym napięciu wejściowym — ze spadkami więcej).

## Typowe pułapki

- **Snubber zbyt mały** — przepięcie przekracza napięcie przebicia tranzystora.
- **Transformator bez szczeliny w flyback** — nasycenie rdzenia.
- **Za małe odstępy izolacyjne na płytce** między stroną pierwotną a wtórną.
- **Pętla sprzężenia przez transoptor bez uwzględnienia jego bieguna i starzenia (CTR)**.
- **Pomiary oscyloskopem z masą sondy na stronie pierwotnej** — zwarcie przez uziemienie oscyloskopu; potrzebna sonda różnicowa lub transformator separujący ([08.03](../08-miernictwo/03-oscyloskop.md)).

## Ćwiczenie komputerowe

Dobór przekładni flyback: wypełnienie, napięcia na tranzystorze i diodzie w funkcji $n$ i napięcia wejściowego (zasilacz uniwersalny 85–265 V AC):

```python
import numpy as np

Vout, Vf, spike = 12.0, 0.5, 100.0
Vin_min, Vin_max = 85*np.sqrt(2)*0.9, 265*np.sqrt(2)          # z tętnieniami przy minimum
print(f"U_we DC: {Vin_min:.0f}–{Vin_max:.0f} V")
print(" n   Vrefl   D(min U)  D(max U)  U_DS,max   U_diody")
for n in [5, 8, 10, 12, 15]:
    Vr = n*(Vout + Vf)
    Dmin_in, Dmax_in = Vr/(Vin_min + Vr), Vr/(Vin_max + Vr)
    print(f"{n:2d}  {Vr:6.1f}   {Dmin_in:6.3f}    {Dmax_in:6.3f}   {Vin_max + Vr + spike:7.0f} V  {Vout + Vin_max/n:6.1f} V")
print("dla 325 V, n=10: D =", round(125/(325 + 125), 3))
```

## Zadania

1. Flyback 325 V → 5 V / 2 A, $n = 20$, dioda 0,5 V. Napięcie odbite, wypełnienie, napięcie na tranzystorze bez szpilki.
2. Dlaczego transformator flyback ma szczelinę, a forward nie?
3. Forward: 36–72 V → 12 V, $D_{max}$ = 0,45. Minimalna przekładnia $N_s/N_p$?
4. Indukcyjność rozproszenia 5 µH, prąd szczytowy 1 A, 100 kHz. Jaka energia na okres i moc do rozproszenia (bez współczynnika clampu)?
5. Jak transoptor przenosi informację o napięciu wyjściowym i co zapewnia?

<details>
<summary>Odpowiedzi</summary>

1. $20\cdot 5\text{,}5 = 110$ V; $D = 110/435 \approx 0\text{,}25$; $U_{DS} = 435$ V
2. Flyback magazynuje energię w polu magnetycznym rdzenia (w szczelinie, gdzie mieści się większość energii przy dopuszczalnym strumieniu); forward przenosi energię bezpośrednio, a transformator ma jak największą indukcyjność magnesowania (mały prąd magnesowania)
3. $12/(36\cdot 0\text{,}45) \approx 0\text{,}74$ (przy minimalnym napięciu wejściowym)
4. $\tfrac12\cdot 5\cdot 10^{-6}\cdot 1^2 = 2\text{,}5$ µJ; $\cdot 10^5 = 0\text{,}25$ W (rzeczywista moc w RCD większa o współczynnik clampu)
5. Wzmacniacz błędu po stronie wtórnej (np. TL431) steruje prądem diody LED transoptora; fototranzystor po stronie pierwotnej przekazuje sygnał do sterownika PWM — przy zachowaniu izolacji galwanicznej
</details>

## Źródła

- [MIT 6.622 Power Electronics](https://ocw.mit.edu/courses/6-622-power-electronics-spring-2023/) — przetwornice izolowane, transformatory, układy rezonansowe
- [Introduction to Power Electronics — R. Erickson (Coursera)](https://www.coursera.org/learn/power-electronics) — przetwornice z transformatorem
- [LTspice](https://www.analog.com/en/resources/design-tools-and-calculators/ltspice-simulator.html) — modele sterowników flyback z obwodami demonstracyjnymi
- Noty aplikacyjne producentów sterowników flyback (projekt transformatora, snubbera, pętli z transoptorem)
