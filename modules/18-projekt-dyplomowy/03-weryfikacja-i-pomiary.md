# 18.03 — Weryfikacja i pomiary

## Po co to jest

Projekt jest skończony dopiero wtedy, gdy pomiarami wykazano, że spełnia wymagania — i wiadomo, z jaką pewnością. „Działa” to nie wynik inżynierski. Plan testów przygotowany razem z wymaganiami, macierz zgodności i pomiary z niepewnością ([08.01](../08-miernictwo/01-metrologia-i-niepewnosc.md)) zamieniają demonstrację w dowód.

## Teoria w pigułce

### Plan testów

Dla każdego wymagania: **metoda** (pomiar, analiza, inspekcja, demonstracja), **stanowisko** (przyrządy, ich niepewności, schemat połączeń), **procedura** (kroki, warunki, liczba powtórzeń), **kryterium zaliczenia** (z uwzględnieniem niepewności), **wynik** i data. Plan przygotowuje się w fazie wymagań — wymaganie, którego nie da się zweryfikować, trzeba przeformułować.

### Macierz zgodności (traceability)

Tabela: wymaganie → test → wynik → status (spełnione / niespełnione / częściowo / odstępstwo). Pokazuje na pierwszy rzut oka stan projektu i niczego nie gubi.

### Decyzja z uwzględnieniem niepewności

Wynik $y$ z niepewnością rozszerzoną $U$ względem granicy $L$ (np. wymaganie $y \leq L$):
- $y + U \leq L$ — **spełnione** z pewnością;
- $y - U > L$ — **niespełnione**;
- w przeciwnym razie — **niejednoznaczne**: potrzebny dokładniejszy pomiar albo reguła decyzyjna ustalona wcześniej (np. pasmo ochronne).

### Typowe pomiary w projektach elektronicznych

| Parametr | Metoda | Moduł |
|---|---|---|
| Pobór prądu w trybach, czas pracy na baterii | Bocznik + oscyloskop / przyrząd do profilowania prądu, całkowanie ładunku | [08.02](../08-miernictwo/02-multimetr-i-pomiary-podstawowe.md), [09.01](../09-mikrokontrolery-embedded/01-architektura.md) |
| Tętnienia i stany nieustalone zasilania | Oscyloskop z krótką masą, skok obciążenia | [08.03](../08-miernictwo/03-oscyloskop.md), [15.06](../15-energoelektronika-zasilanie/06-sterowanie-i-kompensacja.md) |
| Dokładność toru pomiarowego | Wzorzec, kilka punktów zakresu, temperatura | [08.06](../08-miernictwo/06-czujniki-i-tor-pomiarowy.md) |
| Szum, ENOB, widmo | FFT z oknem, SINAD | [07.03](../07-cps-dsp/03-okna-i-analiza-widmowa.md), [07.01](../07-cps-dsp/01-przetwarzanie-ac.md) |
| Charakterystyka filtra, pętli | Generator + oscyloskop/analizator, pomiar pętli | [08.04](../08-miernictwo/04-generatory-i-analizatory.md), [08.05](../08-miernictwo/05-impedancja-i-charakterystyki.md) |
| Dopasowanie anteny, łącze radiowe | VNA (S11), test zasięgu, RSSI/SNR | [12.02](../12-technika-wcz-rf/02-parametry-s.md), [11.08](../11-pole-em-linie-anteny/08-propagacja-i-budzet-lacza.md) |
| Temperatura elementów | Termopara, termowizja przy maksymalnym obciążeniu | [15.07](../15-energoelektronika-zasilanie/07-termika-plytka-emi.md) |
| Emisja (wstępnie) | Sonda pola bliskiego, cęgi prądowe | [16.06](../16-pcb-emc-konstrukcja/06-emc-mechanizmy-i-normy.md) |

**Automatyzacja** ([08.08](../08-miernictwo/08-automatyzacja-pomiarow.md)): skrypty sterujące przyrządami i urządzeniem dają powtarzalne pomiary i gotowe wykresy do raportu.

### Raportowanie wyników

Wynik + niepewność + warunki + przyrządy; porównanie z obliczeniami i symulacją; **wyjaśnienie różnic** (to najcenniejsza część — pokazuje zrozumienie). Surowe dane i skrypty w repozytorium.

## Przykład rozwiązany

**Wymaganie W4** (12 miesięcy z 2000 mAh). Pomiar profilu prądu: uśpienie 3,2 µA (niepewność ±0,3 µA), pomiar 2,1 mA przez 50 ms co 10 min, nadawanie LoRa 45 mA przez 1,3 s co 1 h.

1. Ładunek na godzinę: uśpienie $3\text{,}2\ \mu\text{A}\cdot 3600\ \text{s} = 11\text{,}5$ mC; pomiary $6\cdot 2\text{,}1\ \text{mA}\cdot 0\text{,}05\ \text{s} = 0\text{,}63$ mC; nadawanie $45\ \text{mA}\cdot 1\text{,}3\ \text{s} = 58\text{,}5$ mC → razem ok. 70,6 mC/h → średnio **19,6 µA**.
2. Czas pracy: $2\ \text{Ah}/19\text{,}6\ \mu\text{A} \approx 102\,000$ h ≈ 11,6 roku (bez samorozładowania; z rezerwą 50% na starzenie, temperaturę i samorozładowanie nadal ≫ 12 miesięcy) → **spełnione** z dużym zapasem.
3. Dominujący składnik: nadawanie (83%) — skrócenie czasu ramki (mniejszy SF przy dobrym zasięgu) to najskuteczniejsza optymalizacja.

## Typowe pułapki

- **Plan testów pisany po zakończeniu projektu.**
- **Brak niepewności i warunków pomiaru** w raporcie.
- **Jeden egzemplarz, jedna temperatura** — wynik nie mówi nic o rozrzucie.
- **Pomiar prądu uśpienia przyrządem o za małej rozdzielczości** lub z dużym spadkiem napięcia na zakresie.
- **Pomijanie wyników niekorzystnych** — wymaganie niespełnione też jest wynikiem, z wnioskiem do wersji 2.

## Ćwiczenie komputerowe

Bilans ładunku z profilu prądu i decyzja o zgodności z uwzględnieniem niepewności (propagacja metodą Monte Carlo):

```python
import numpy as np

rng = np.random.default_rng(0); n = 100_000
I_sleep = rng.normal(3.2e-6, 0.15e-6, n)                     # niepewność standardowa = U/2
I_meas, t_meas = rng.normal(2.1e-3, 0.05e-3, n), 0.05
I_tx, t_tx = rng.normal(45e-3, 1.5e-3, n), rng.normal(1.3, 0.02, n)
Q_h = I_sleep*3600 + 6*I_meas*t_meas + I_tx*t_tx              # ładunek na godzinę [C]
I_avg = Q_h/3600
life_years = 2.0*3600/Q_h/24/365*0.5                           # 50% rezerwy pojemności
print(f"prąd średni = {I_avg.mean()*1e6:.1f} µA ± {2*I_avg.std()*1e6:.1f} µA (k = 2)")
print(f"czas pracy z rezerwą 50%: {life_years.mean():.1f} lat, 2,5 percentyl {np.percentile(life_years, 2.5):.1f} lat")
L = 1.0
y, U = life_years.mean(), 2*life_years.std()
verdict = "spełnione" if y - U >= L else ("niespełnione" if y + U < L else "niejednoznaczne")
print(f"wymaganie ≥ {L} rok: {verdict}")
print(f"udział nadawania w ładunku: {np.mean(I_tx*t_tx/Q_h)*100:.0f}%")
```

## Zadania

1. Przygotuj plan testów dla trzech wymagań swojego projektu według [szablonu](szablony/plan-testow.md).
2. Wymaganie: tętnienia ≤ 20 mV p-p. Zmierzono 18 mV p-p z niepewnością rozszerzoną 3 mV. Jaka decyzja?
3. Jak zmierzysz prąd uśpienia rzędu 2 µA urządzenia, które co sekundę wybudza się na 1 ms z poborem 10 mA?
4. Dlaczego warto mierzyć kilka egzemplarzy i w kilku temperaturach?
5. Wynik pomiaru różni się od obliczeń o 30%. Co zrobisz, zanim zapiszesz go w raporcie?

<details>
<summary>Odpowiedzi</summary>

1. —
2. $18 + 3 = 21$ mV > 20 mV, a $18 - 3 = 15$ mV < 20 mV — wynik niejednoznaczny; dokładniejszy pomiar (pasmo, sonda, uśrednianie) lub reguła decyzyjna
3. Przyrząd o dużym zakresie dynamiki (profiler prądu, bocznik z przełączaniem zakresów) albo bocznik + wzmacniacz + oscyloskop z długim zapisem i całkowanie ładunku; multimetr na zakresie µA zawiedzie przy impulsach (spadek napięcia, reset) — można go zbocznikować na czas impulsów lub mierzyć tylko w uśpieniu z wyłączonym wybudzaniem
4. Rozrzut elementów i parametry zależne od temperatury (prądy upływu, dryft, sprawność, częstotliwość kwarcu) — jeden egzemplarz w pokoju może przypadkowo spełniać wymagania
5. Sprawdź stanowisko i przyrządy (zakresy, masy, kalibracja), powtórz pomiar, przejrzyj założenia obliczeń i modelu (pominięte zjawiska, parametry z noty przy innych warunkach), zmierz wielkości pośrednie; w raporcie opisz przyczynę lub hipotezy
</details>

## Źródła

- [JCGM 100:2008 (GUM)](https://www.bipm.org/en/doi/10.59161/jcgm100-2008e) — niepewność pomiaru
- [08 Miernictwo](../08-miernictwo/) — metody i przyrządy
- [PyVISA](https://pyvisa.readthedocs.io/) — automatyzacja pomiarów
