# 15.08 — Baterie, ładowanie i falowniki

## Po co to jest

Urządzenia przenośne i IoT żyją z baterii, a ich ładowanie i zabezpieczenie to sprawa bezpieczeństwa — ogniwo Li-ion potrafi się zapalić. Drugi biegun energoelektroniki to zamiana prądu stałego na przemienny: falowniki zasilają silniki (od wentylatorów po samochody elektryczne), oddają energię z paneli fotowoltaicznych do sieci i tworzą zasilacze awaryjne. Ten temat łączy elektronikę mocy z praktyką urządzeń.

## Teoria w pigułce

### Akumulatory

| Chemia | Napięcie nominalne / zakres | Gęstość energii | Cechy |
|---|---|---|---|
| **Li-ion (NMC, LCO)** | 3,6–3,7 V; 3,0–4,2 V | Duża | Wymaga ścisłej kontroli napięcia, temperatury i prądu; standard w elektronice |
| **LiFePO₄** | 3,2 V; 2,5–3,65 V | Średnia | Bezpieczniejsza, trwalsza (tysiące cykli), płaska krzywa rozładowania |
| NiMH | 1,2 V | Średnia | Tolerancyjna, samorozładowanie (mniejsze w odmianach LSD) |
| Kwasowo-ołowiowa | 2 V/ogniwo (12 V) | Mała | Tania, duże prądy rozruchowe, zasilacze awaryjne |
| Baterie pierwotne (Li-SOCl₂, alkaliczne) | 3,6 V; 1,5 V | Bardzo duża (Li) | Urządzenia na lata bez ładowania, mały prąd |

Pojemność [mAh], energia [Wh] = napięcie × pojemność; prąd w krotnościach pojemności (1C = pojemność/1 h). Pojemność użyteczna zależy od prądu, temperatury i wieku; **rezystancja wewnętrzna** rośnie z wiekiem i spada temperatura → spadki napięcia przy impulsach prądu (radio!).

### Ładowanie Li-ion: CC/CV

1. **Wstępne (pre-charge)** małym prądem, gdy ogniwo głęboko rozładowane (< ok. 3 V).
2. **Prąd stały (CC)** typowo 0,5–1C do napięcia 4,2 V (lub 4,1 V dla dłuższej żywotności).
3. **Napięcie stałe (CV)** 4,2 V ± 1% (lub lepiej), prąd maleje.
4. **Zakończenie**, gdy prąd spadnie do ok. 0,05–0,1C; bez ładowania podtrzymującego.
5. **Temperatura:** ładowanie tylko w zakresie ok. 0–45 °C (termistor NTC w pakiecie); poniżej 0 °C — ryzyko osadzania litu.

Ładowarki: liniowe (proste, straty $(U_{we} - U_{bat})I$ — przy 5 V, 3,6 V i 1 A ok. 1,4 W) lub impulsowe (sprawne, większe prądy, ścieżka zasilania systemu — power path).

### Zabezpieczenia i BMS

Układ zabezpieczający pakietu: przepięcie, zbyt głębokie rozładowanie, nadprąd i zwarcie (dwa tranzystory MOSFET w szeregu, przeciwsobnie), temperatura. Pakiety wieloogniwowe — **BMS**: pomiar każdego ogniwa, **wyrównywanie (balancing)** pasywne (rezystory) lub aktywne, szacowanie stanu naładowania (SOC — zliczanie ładunku + model napięcia) i zdrowia (SOH). Przechowywanie i transport — wymagania bezpieczeństwa.

### Falowniki

**Mostek H** (pełny mostek) z czterech kluczy wytwarza napięcie ±$U_{DC}$; **PWM sinusoidalne** (SPWM) — porównanie sinusoidy modulującej z nośną trójkątną — po odfiltrowaniu (lub przez indukcyjność obciążenia, np. silnika) daje przebieg sinusoidalny. Amplituda składowej podstawowej $\approx m\cdot U_{DC}$ (pełny mostek, $m \leq 1$ — współczynnik modulacji).

**Falownik trójfazowy** (6 kluczy): napięcie międzyfazowe skuteczne przy SPWM $\approx 0\text{,}612\,m\,U_{DC}$; modulacja wektorowa (SVPWM) lub dodanie trzeciej harmonicznej zwiększa je o ok. 15%. Obwody trójfazowe — [01.11](../01-teoria-obwodow/11-obwody-trojfazowe.md).

**Sterowanie silnikami:**
| Silnik | Sterowanie |
|---|---|
| DC szczotkowy | Mostek H + PWM; prąd ≈ moment |
| **BLDC / PMSM** | Komutacja 6-krokowa (czujniki Halla lub bezczujnikowo przez siłę elektromotoryczną) lub **sterowanie wektorowe (FOC)** — regulatory PI prądu w układzie wirującym ([10.08](../10-automatyka/08-zastosowania-w-elektronice.md)) |
| Indukcyjny | U/f (skalarne) lub FOC |
| Krokowy | Sterownik z regulacją prądu i mikrokrokiem |

Szczegóły praktyczne: czas martwy (przeciw przewodzeniu skrośnemu), sterowniki bramek z bootstrapem lub izolowane, pomiar prądu (boczniki, czujniki Halla), zabezpieczenia (desaturacja, nadprąd), hamowanie (energia wraca do szyny DC).

## Przykład rozwiązany

**Bateria IoT:** ogniwo 2000 mAh / 3,7 V → 7,4 Wh. Średni pobór 0,105 mA ([09.01](../09-mikrokontrolery-embedded/01-architektura.md)) → ok. 19 000 h. Impuls radia 120 mA przy rezystancji wewnętrznej 0,15 Ω (nowe) → spadek 18 mV; po starzeniu i w −10 °C (np. 1 Ω) → 120 mV — przy ogniwie rozładowanym do 3,3 V i LDO z $U_{drop}$ 0,2 V mikrokontroler może się zresetować.

**Ładowanie liniowe** 1 A z 5 V: przy ogniwie 3,6 V strata 1,4 W w układzie (w małej obudowie ok. 50 K/W → +70 K!) — ładowarka ograniczy prąd termicznie; ładowarka impulsowa (90%) traci ok. 0,4 W.

**Falownik trójfazowy** z szyny 325 V DC (wyprostowana sieć 230 V), SPWM, $m = 1$: napięcie międzyfazowe ok. $0\text{,}612\cdot 325 \approx 199$ V skutecznie — mniej niż 400 V sieci trójfazowej; z SVPWM ok. 230 V.

## Typowe pułapki

- **Ładowanie Li-ion bez kontroli temperatury** lub „przez rezystor”.
- **Ogniwa Li-ion równolegle o różnym stanie naładowania** — duże prądy wyrównawcze przy połączeniu.
- **Szacowanie SOC tylko z napięcia** dla LiFePO₄ (płaska krzywa).
- **Mostek H bez czasu martwego** — zwarcie szyny przez klucze.
- **Brak drogi dla energii hamowania silnika** — napięcie szyny DC rośnie i uszkadza kondensatory/klucze.

## Ćwiczenie komputerowe

Prosty model ogniwa (źródło zależne od stanu naładowania + rezystancja wewnętrzna) ładowanego CC/CV oraz widmo SPWM pełnego mostka:

```python
import numpy as np

Q, R_int, dt = 2.0*3600, 0.1, 1.0                       # 2 Ah, 0,1 Ohm
ocv = lambda soc: 3.45 + 0.75*soc - 0.45*(1 - soc)**4        # uproszczona krzywa OCV: 3,0 V (0%) … 4,2 V (100%)
soc, t, I_cc, V_cv, I_end = 0.1, 0, 1.0, 4.2, 0.1
phase_change = None
while True:
    I = I_cc if ocv(soc) + I_cc*R_int < V_cv else (V_cv - ocv(soc))/R_int   # CC lub CV
    if phase_change is None and I < I_cc: phase_change = t
    if I < I_end: break
    soc += I*dt/Q; t += dt
print(f"faza CC: {phase_change/3600:.2f} h, całkowity czas: {t/3600:.2f} h, SOC końcowy: {soc*100:.0f}%")

fs, f1, fc, m, Vdc = 2e6, 50, 10e3, 0.9, 325
tt = np.arange(0, 0.1, 1/fs)
ref = m*np.sin(2*np.pi*f1*tt); tri = 2*np.abs(2*((tt*fc) % 1) - 1) - 1
v = Vdc*np.where(ref > tri, 1, -1)                           # pełny mostek, PWM bipolarne
Y = np.abs(np.fft.rfft(v))/len(v)*2; fr = np.fft.rfftfreq(len(v), 1/fs)
print(f"składowa 50 Hz: {Y[np.argmin(abs(fr - 50))]:.1f} V (teoria m·Udc = {m*Vdc:.1f} V)")
print(f"największa harmoniczna w okolicy nośnej: {fr[np.argmax(Y*(fr > 5e3))]/1e3:.2f} kHz")
print(f"3 fazy SPWM, m=1: U_LL,rms ≈ {0.612*Vdc:.0f} V")
```

## Zadania

1. Pakiet 3S Li-ion (3 ogniwa szeregowo), 2500 mAh. Napięcie nominalne, zakres napięć i energia?
2. Ładowanie 2000 mAh prądem 0,5C. Ile trwa faza CC, jeśli kończy się przy ok. 70% naładowania?
3. Ładowarka liniowa z 5 V, ogniwo przy 3,0–4,2 V, prąd 0,5 A. Maksymalna strata?
4. Falownik jednofazowy (pełny mostek) z szyny 400 V, $m = 0\text{,}8$. Amplituda i wartość skuteczna składowej podstawowej?
5. Dlaczego sterowanie FOC daje płynniejszy moment niż komutacja 6-krokowa?

<details>
<summary>Odpowiedzi</summary>

1. 11,1 V; 9,0–12,6 V; ok. 27,8 Wh
2. 1 A; 1,4 Ah → ok. 1,4 h (+ faza CV, łącznie typowo 2–2,5 h)
3. Przy 3,0 V: $(5 - 3)\cdot 0\text{,}5 = 1$ W (przy pre-charge prąd mniejszy)
4. Amplituda $0\text{,}8\cdot 400 = 320$ V, skuteczna ok. 226 V
5. FOC steruje wektorem prądu w sposób ciągły (sinusoidalnie), utrzymując go prostopadle do strumienia wirnika; komutacja 6-krokowa przełącza prąd skokowo co 60° — tętnienia momentu przy każdej komutacji
</details>

## Źródła

- [Battery University](https://batteryuniversity.com/) — chemie akumulatorów, ładowanie Li-ion (artykuł BU-409), starzenie, bezpieczeństwo
- [MIT 6.622 Power Electronics](https://ocw.mit.edu/courses/6-622-power-electronics-spring-2023/) — falowniki, modulacja PWM
- [Introduction to Power Electronics — R. Erickson (Coursera)](https://www.coursera.org/learn/power-electronics) — podstawy przetwarzania energii
- Noty aplikacyjne producentów ładowarek Li-ion, układów BMS i sterowników silników (FOC)
