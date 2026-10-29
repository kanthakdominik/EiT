# 18.02 — Wymagania i architektura

## Po co to jest

„Rejestrator temperatury z Wi-Fi” to nie specyfikacja — to temat. Specyfikacja mówi: jaki zakres, z jaką niepewnością, jak często, ile czasu na baterii, w jakich warunkach, za ile. Dopiero z liczb da się wybrać architekturę i sprawdzić na końcu, czy projekt się udał. Architektura z kolei to decyzje, które najtrudniej zmienić później — warto je podejmować świadomie, porównując warianty.

## Teoria w pigułce

### Dobre wymaganie

| Cecha | Źle | Dobrze |
|---|---|---|
| Mierzalne | „dokładny pomiar” | „niepewność rozszerzona ≤ 0,5 °C (k = 2) w zakresie 0–50 °C” |
| Jednoznaczne | „długa praca na baterii” | „≥ 12 miesięcy z ogniwa 2000 mAh przy pomiarze co 10 min i wysyłce co 1 h” |
| Weryfikowalne | „odporny na zakłócenia” | „działa bez utraty danych podczas badania ESD ±4 kV kontaktowo na obudowie” |
| Realne | „pobór 1 µA z Wi-Fi” | Wymaganie zgodne z możliwościami technologii (sprawdzone budżetem) |
| Z priorytetem | — | „musi / powinno / może” (MoSCoW) |
| Ze sposobem weryfikacji | — | Pomiar / analiza / inspekcja / demonstracja |

Kategorie: funkcjonalne, parametryczne (dokładność, szybkość, pasmo), zasilanie i energia, środowisko (temperatura, wilgotność, IP), interfejsy, mechaniczne, normy i bezpieczeństwo, koszt i wielkość serii, ograniczenia (dostępne narzędzia, czas).

### Budżety

Wymagania systemowe rozdziela się na bloki: **budżet mocy** ([16.01](../16-pcb-emc-konstrukcja/01-proces-i-schemat.md)), **budżet energii** baterii ([09.01](../09-mikrokontrolery-embedded/01-architektura.md)), **budżet błędów** toru pomiarowego ([08.06](../08-miernictwo/06-czujniki-i-tor-pomiarowy.md)), **budżet szumów** i zakresu dynamiki ([12.04](../12-technika-wcz-rf/04-szumy.md)), **budżet łącza** radiowego ([11.08](../11-pole-em-linie-anteny/08-propagacja-i-budzet-lacza.md)), budżet opóźnień i czasu obliczeń, budżet kosztów (BOM).

### Wybór architektury

1. Wypisz 2–4 warianty (np. czujnik cyfrowy vs analogowy + przetwornik; BLE vs LoRa vs Wi-Fi; LDO vs przetwornica).
2. Kryteria z wagami wynikającymi z wymagań (energia, koszt, ryzyko, złożoność, dokładność).
3. **Macierz decyzyjna:** ocena każdego wariantu w każdym kryterium (np. 1–5), suma ważona.
4. Sprawdź wrażliwość: czy zmiana wag zmienia wynik? Jeśli tak — decyzja wymaga dodatkowych danych (prototyp).
5. Udokumentuj decyzję i odrzucone warianty z uzasadnieniem.

## Przykład rozwiązany

**Rejestrator temperatury i wilgotności w szklarni** (fragment specyfikacji):

| ID | Wymaganie | Priorytet | Weryfikacja |
|---|---|---|---|
| W1 | Temperatura −10…+50 °C, niepewność ≤ 0,5 °C (k = 2) | musi | Pomiar w komorze z termometrem wzorcowym |
| W2 | Wilgotność 20–90% RH, ±3% RH | powinno | Porównanie z higrometrem odniesienia |
| W3 | Pomiar co 10 min, wysyłka co 1 h, zasięg 500 m w terenie otwartym | musi | Test terenowy, budżet łącza |
| W4 | ≥ 12 miesięcy z ogniwa 2000 mAh | musi | Pomiar prądu w każdym trybie + obliczenie |
| W5 | Obudowa IP54, −20…+60 °C pracy | musi | Inspekcja, test w komorze |
| W6 | BOM ≤ 25 €/szt. przy serii 50 szt. | powinno | Analiza BOM |

**Łączność** — porównanie (wagi z W3, W4, W6):

| Kryterium (waga) | BLE (do bramy) | LoRa | Wi-Fi |
|---|---|---|---|
| Energia (0,4) | 4 | 5 | 1 |
| Zasięg 500 m (0,3) | 2 | 5 | 2 |
| Koszt i infrastruktura (0,2) | 4 | 3 | 5 |
| Złożoność (0,1) | 3 | 3 | 4 |
| **Suma ważona** | **3,3** | **4,4** | **2,4** |

LoRa wygrywa; budżet łącza z [11.08](../11-pole-em-linie-anteny/08-propagacja-i-budzet-lacza.md) potwierdza zasięg z dużym zapasem, budżet energii: średnio ok. 10–20 µA → wiele lat na ogniwie (W4 spełnione z zapasem).

## Typowe pułapki

- **Wymagania sformułowane po zrobieniu projektu** („pod to, co wyszło”).
- **Brak warunków pracy** (temperatura, zasilanie min/max) — działa na biurku, w terenie nie.
- **Wybór „ulubionego” układu** przed analizą wymagań.
- **Macierz decyzyjna z wagami dobranymi tak, by wygrał z góry wybrany wariant.**
- **Pominięcie budżetów** — błąd wychodzi dopiero przy weryfikacji.

## Ćwiczenie komputerowe

Macierz decyzyjna z analizą wrażliwości (losowe zaburzenie wag ±30%):

```python
import numpy as np

criteria = ['energia', 'zasięg', 'koszt', 'złożoność']
w = np.array([0.4, 0.3, 0.2, 0.1])
options = {'BLE': [4, 2, 4, 3], 'LoRa': [5, 5, 3, 3], 'Wi-Fi': [1, 2, 5, 4]}
S = np.array(list(options.values()), float)
for name, s in zip(options, S @ w):
    print(f"{name:6s}: {s:.2f}")
rng = np.random.default_rng(0); wins = dict.fromkeys(options, 0)
for _ in range(10000):
    wp = w*rng.uniform(0.7, 1.3, w.size); wp /= wp.sum()
    wins[list(options)[np.argmax(S @ wp)]] += 1
print("wygrane przy zaburzonych wagach:", {k: f"{v/100:.1f}%" for k, v in wins.items()})
```

## Zadania

1. Przepisz na mierzalne wymagania: „urządzenie ma być energooszczędne, dokładne i odporne na warunki zewnętrzne”.
2. Dla własnego tematu przygotuj specyfikację według [szablonu](szablony/specyfikacja-wymagan.md) (co najmniej 10 wymagań z priorytetami i metodą weryfikacji).
3. Zbuduj macierz decyzyjną dla wyboru zasilania (bateria pierwotna, akumulator Li-ion z ładowaniem USB, zasilanie z sieci) dla swojego projektu.
4. Jakie budżety przygotujesz dla odbiornika SDR z własnym torem w.cz.?
5. Kiedy zamiast macierzy decyzyjnej trzeba zbudować prototyp?

<details>
<summary>Odpowiedzi</summary>

1. Np. „średni pobór ≤ 50 µA przy 3,3 V w trybie pracy z pomiarem co 10 min”; „niepewność pomiaru temperatury ≤ 0,5 °C (k = 2) w zakresie −10…+50 °C”; „praca w zakresie −20…+60 °C, obudowa IP54, odporność ESD ±4 kV kontaktowo”
2. —
3. —
4. Budżet szumów (NF kaskady, czułość), zakres dynamiki (IIP3, SFDR, zakres przetwornika A/C), budżet wzmocnień, plan częstotliwości (lustra, produkty mieszania), budżet mocy i termiki, budżet przetwarzania (szybkość próbkowania, obciążenie procesora/FPGA)
5. Gdy wynik zależy od niepewnych danych (zasięg w rzeczywistym środowisku, zakłócenia, rzeczywisty pobór prądu, dokładność czujnika) albo gdy analiza wrażliwości pokazuje, że wybór zmienia się przy niewielkiej zmianie wag lub ocen
</details>

## Źródła

- [08.01 Metrologia i niepewność](../08-miernictwo/01-metrologia-i-niepewnosc.md) — jak zapisywać wymagania dokładności
- [JCGM 100:2008 (GUM)](https://www.bipm.org/en/doi/10.59161/jcgm100-2008e) — niepewność pomiaru
- H. Scott — *Designing Electronics That Work* (płatna) — specyfikacja i architektura
