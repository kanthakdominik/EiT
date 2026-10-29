# 16.05 — Masa i układy mieszane analogowo-cyfrowe

## Po co to jest

„Masa” to najczęściej źle rozumiane pojęcie w elektronice. Na schemacie to jeden symbol, na płytce — miedź o niezerowej impedancji, przez którą płyną prądy wielu obwodów. Gdy prądy cyfrowe lub impulsowe przepływają przez masę obwodu analogowego, pojawia się błąd pomiaru, szum albo zakłócenia. Dobre prowadzenie masy decyduje o tym, czy 16-bitowy przetwornik da 16 bitów, czy 10.

## Teoria w pigułce

### Masa nie jest ekwipotencjalna

Spadek napięcia na masie: $\Delta U = I\cdot R + L\,dI/dt$. Przy niskich częstotliwościach dominuje rezystancja, przy wysokich — indukcyjność pętli. Napięcie to dodaje się do każdego sygnału odniesionego do masy w innym punkcie (**sprzężenie przez wspólną impedancję**).

### Strategie

| Strategia | Opis | Kiedy |
|---|---|---|
| **Ciągła płaszczyzna masy** + przemyślane rozmieszczenie | Jedna masa, strefy elementów tak, że prądy cyfrowe nie płyną pod częścią analogową | **Domyślna dla większości płytek** z przetwornikami i mikrokontrolerami |
| Gwiazda (jednopunktowa) | Osobne ścieżki mas zbiegające się w jednym punkcie | Niskie częstotliwości, zasilacze, audio, układy z dużymi prądami |
| Wielopunktowa | Masa łączona z płaszczyzną w wielu punktach | Wysokie częstotliwości, w.cz. |
| Podzielona płaszczyzna (AGND/DGND) połączona w jednym punkcie | Szczelina między częścią analogową i cyfrową | Ostrożnie: **żaden sygnał nie może przechodzić nad szczeliną**; częściej szkodzi niż pomaga |

### Przetworniki A/C i C/A

Piny AGND i DGND przetwornika łączy się **z tą samą (analogową) płaszczyzną tuż pod układem** — wewnętrzne masy są połączone w układzie, a cyfrowe prądy wyjściowe są małe (wyjścia przetwornika powinny mieć małe obciążenie; bufor/rezystory szeregowe). Przetwornik umieszcza się na granicy stref, z częścią analogową po jednej stronie, a cyfrową po drugiej. Szczegóły — noty producentów przetworników („AGND i DGND”).

### Pętle masy w systemie

Połączenie dwóch urządzeń kablem sygnałowym i przewodem ochronnym (PE) tworzy pętlę: prąd indukowany polem sieci lub różnicą potencjałów ziemi płynie po ekranie kabla — przydźwięk 50 Hz, zakłócenia ([08.07](../08-miernictwo/07-zaklocenia-i-ekranowanie.md)). Rozwiązania: wejścia różnicowe, izolacja galwaniczna (transoptory, izolatory cyfrowe, przetwornice izolowane), łączenie ekranu z obudową w odpowiednim miejscu, dławiki wspólne.

### Masa a obudowa (chassis)

Masa sygnałowa (0 V) i masa obudowy/ochronna — różne funkcje. Złącza: ekran kabla łączony z obudową 360° przy wejściu do obudowy (zakłócenia „zostają na zewnątrz”), połączenie 0 V z obudową w kontrolowanym miejscu (często przez kondensator lub bezpośrednio przy złączach). Ochrona ESD odprowadza ładunek do obudowy/masy przy złączu, a nie przez całą płytkę ([16.07](07-filtracja-ekranowanie-esd.md)).

## Przykład rozwiązany

**Rejestrator z przetwornikiem 16-bitowym** (zakres 2,5 V → LSB ≈ 38 µV) i przetwornicą 1 A.

1. Gdyby prąd przetwornicy (impulsy 1 A) płynął przez wspólny odcinek masy o rezystancji 5 mΩ i indukcyjności 2 nH ze zboczem 10 ns: $\Delta U = 5$ mV + $2\cdot 10^{-9}\cdot 10^8 = 0\text{,}2$ V szpilki → setki–tysiące LSB.
2. Rozwiązanie: przetwornica w osobnym narożniku z własnymi kondensatorami i krótkimi pętlami; ciągła płaszczyzna masy; tor analogowy po przeciwnej stronie; przetwornik między strefami; filtr zasilania analogowego; próbkowanie zsynchronizowane z cichymi chwilami albo przetwornica w trybie o stałej częstotliwości poza pasmem pomiaru.

## Typowe pułapki

- **Szczelina AGND/DGND z sygnałami przechodzącymi nad nią.**
- **Masa przetwornika A/C podłączona do masy cyfrowej daleko od układu.**
- **Ekran kabla podłączony do 0 V płytki „pigtailem”** — długi przewód ekranu traci skuteczność przy w.cz.
- **Brak drogi dla prądu ESD** do obudowy — wyładowanie przechodzi przez mikrokontroler.
- **Pętla masy przez USB komputera i zasilacz laboratoryjny** w pomiarach — zakłócenia „znikają” na baterii.

## Ćwiczenie komputerowe

Wpływ wspólnej impedancji masy na pomiar: błąd w LSB w funkcji rezystancji/indukcyjności wspólnego odcinka i prądu zakłócającego:

```python
import numpy as np

lsb = 2.5/2**16
for R_mohm, L_nH, I, tr_ns in [(5, 2, 1.0, 10), (1, 0.5, 1.0, 10), (5, 2, 0.05, 10), (0.2, 0.2, 1.0, 10)]:
    dc = R_mohm*1e-3*I; spike = L_nH*1e-9*I/(tr_ns*1e-9)
    print(f"R = {R_mohm} mΩ, L = {L_nH} nH, I = {I} A: spadek DC {dc*1e3:.2f} mV ({dc/lsb:7.0f} LSB), "
          f"szpilka {spike*1e3:6.1f} mV ({spike/lsb:7.0f} LSB)")
print(f"LSB przetwornika 16-bit / 2,5 V = {lsb*1e6:.1f} µV")
```

## Zadania

1. Wspólny odcinek masy 20 mΩ, przez który płynie prąd 50 mA diody LED włączanej programowo. Ile LSB błędu da to przetwornikowi 12-bitowemu o zakresie 3,3 V?
2. Dlaczego zwykle zaleca się ciągłą płaszczyznę masy zamiast podziału na AGND i DGND?
3. Gdzie podłączysz piny AGND i DGND przetwornika A/C na płytce z jedną płaszczyzną masy?
4. Urządzenie pomiarowe podłączone do komputera przez USB „łapie” przydźwięk 50 Hz. Zaproponuj dwa rozwiązania.
5. Dlaczego ekran kabla łączy się z obudową na całym obwodzie złącza (360°), a nie przewodem?

<details>
<summary>Odpowiedzi</summary>

1. 1 mV; LSB = 0,81 mV → ok. 1,2 LSB (i zmiana zależna od stanu LED)
2. Prąd powrotny w.cz. płynie pod ścieżką; ciągła płaszczyzna utrzymuje pętle małe dla każdego sygnału; separację prądów zapewnia rozmieszczenie stref, a nie przecięcie — podział łatwo zepsuć sygnałem przechodzącym nad szczeliną
3. Oba do płaszczyzny masy bezpośrednio pod układem (krótko, przelotkami przy pinach), z przetwornikiem na granicy stref analogowej i cyfrowej
4. Izolacja galwaniczna USB (izolator USB lub izolowany interfejs), zasilanie bateryjne/izolowane, wejście różnicowe wzmacniacza, rozdzielenie pętli masy (np. bez połączenia PE w torze pomiarowym — z zachowaniem bezpieczeństwa)
5. Przewód (pigtail) ma indukcyjność kilku–kilkunastu nH — przy w.cz. jego impedancja jest duża i prąd zakłóceń z ekranu wchodzi do obudowy jak przez antenę; połączenie 360° ma minimalną indukcyjność
</details>

## Źródła

- [LearnEMC](https://learnemc.com/) — masa, płaszczyzny, prądy powrotne
- [Rick Hartley — wykłady o masie i ścieżkach powrotnych](https://www.youtube.com/results?search_query=Rick+Hartley+grounding+PCB) — dlaczego nie dzielić płaszczyzn
- [Analog Devices MT-101 — Decoupling Techniques](https://www.analog.com/media/en/training-seminars/tutorials/MT-101.pdf) — oraz pozostałe tutoriale serii MT o masie w układach z przetwornikami
- [08.07 Zakłócenia i ekranowanie](../08-miernictwo/07-zaklocenia-i-ekranowanie.md) — pętle masy w pomiarach
