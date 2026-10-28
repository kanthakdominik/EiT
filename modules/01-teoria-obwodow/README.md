# 01 — Teoria obwodów

> **Status:** ✅ pełny

## Cel modułu

Analizować dowolny liniowy obwód elektryczny prądu stałego i zmiennego — w stanie ustalonym i nieustalonym — i umieć sprawdzić wynik drugą metodą oraz symulacją. To najważniejszy moduł całego kierunku: każdy kolejny przedmiot zakłada, że teoria obwodów jest opanowana.

## Wymagania wstępne

- [00 Matematyka](../00-matematyka/): tematy 01–04 obowiązkowo, 05 przed tematem [08](08-laplace-w-obwodach.md).

## Tematy

| # | Temat | Odpowiednik na studiach | Czas (od zera / odświeżenie) |
|---|---|---|---|
| 01 | [Podstawowe pojęcia i prawa](01-pojecia-i-prawa.md) | Podstawy elektrotechniki | 8 h / 2 h |
| 02 | [Metody analizy: węzłowa i oczkowa](02-metody-analizy.md) | Teoria obwodów I | 12 h / 4 h |
| 03 | [Twierdzenia o obwodach](03-twierdzenia.md) | Teoria obwodów I | 10 h / 3 h |
| 04 | [Stany nieustalone 1. rzędu (RC, RL)](04-stany-nieustalone-1-rzedu.md) | Teoria obwodów I–II | 12 h / 4 h |
| 05 | [Obwody 2. rzędu (RLC)](05-obwody-2-rzedu.md) | Teoria obwodów II | 10 h / 3 h |
| 06 | [Analiza AC: fazory, impedancja, moc](06-analiza-ac-fazory.md) | Teoria obwodów I | 14 h / 4 h |
| 07 | [Rezonans i charakterystyki częstotliwościowe](07-rezonans-i-charakterystyki.md) | Teoria obwodów II | 12 h / 4 h |
| 08 | [Metoda operatorowa (Laplace)](08-laplace-w-obwodach.md) | Teoria obwodów II | 12 h / 4 h |
| 09 | [Czwórniki](09-czworniki.md) | Teoria obwodów II | 8 h / 2 h |
| 10 | [Obwody sprzężone magnetycznie i transformator](10-sprzezenia-magnetyczne.md) | Teoria obwodów II | 6 h / 2 h |
| 11 | [Obwody trójfazowe](11-obwody-trojfazowe.md) | Podstawy elektrotechniki | 4 h / 1 h |

## Test wejściowy (diagnoza)

Rozwiąż bez notatek, około 2 godzin. Przy każdym zadaniu zaznacz: **umiem / z trudem / nie umiem**.

1. **Dzielnik z obciążeniem.** Źródło 12 V, $R_1 = R_2 = 10$ kΩ, równolegle do $R_2$ obciążenie $R_L = 10$ kΩ. Policz napięcie na $R_L$. Następnie wyznacz obwód zastępczy Thévenina widziany z zacisków $R_2$ i sprawdź nim wynik.
2. **Analiza węzłowa.** $E_1 = 10$ V przez $R_1 = 2$ kΩ i $E_2 = 5$ V przez $R_2 = 1$ kΩ dochodzą do wspólnego węzła, z którego $R_3 = 2$ kΩ idzie do masy. Policz napięcie węzła i prądy gałęzi.
3. **Dopasowanie mocy.** Źródło 5 V o rezystancji wewnętrznej 50 Ω. Przy jakim $R_L$ moc w obciążeniu jest maksymalna i ile wynosi? Jaka jest wtedy sprawność?
4. **Stan nieustalony RC.** $C = 10\ \mu$F naładowany do 2 V w chwili $t = 0$ zostaje dołączony przez $R = 10$ kΩ do źródła 12 V. Wyznacz $u_C(t)$. Po jakim czasie $u_C = 9$ V?
5. **To samo przez Laplace'a.** Wyprowadź $u_C(t)$ z zadania 4 metodą operatorową.
6. **Filtr RC.** Dolnoprzepustowy RC: $R = 1{,}6$ kΩ, $C = 100$ nF. Policz częstotliwość graniczną oraz $\lvert H\rvert$ (dB) i fazę przy 1 kHz i 10 kHz.
7. **Rezonans szeregowy.** $R = 100\ \Omega$, $L = 10$ mH, $C = 100$ nF, wymuszenie 1 V. Policz $f_0$, $Q$, pasmo 3 dB i napięcie na kondensatorze w rezonansie.

<details>
<summary>Odpowiedzi</summary>

1. $R_2 \parallel R_L = 5$ kΩ, $U = 12\cdot\dfrac{5}{15} = 4$ V. Thévenin: $E_{th} = 6$ V, $R_{th} = 5$ kΩ; $6\cdot\dfrac{10}{15} = 4$ V ✓
2. $V = \dfrac{10/2 + 5/1}{1/2 + 1 + 1/2} = 5$ V; $I_1 = 2{,}5$ mA (do węzła), $I_2 = 0$, $I_3 = 2{,}5$ mA
3. $R_L = 50\ \Omega$, $P = \dfrac{2{,}5^2}{50} = 0{,}125$ W, sprawność 50%
4. $u_C(t) = 12 - 10e^{-t/0{,}1\,\text{s}}$ V; $t = 0{,}1\ln\dfrac{10}{3} \approx 0{,}120$ s
5. $U_C(s) = \dfrac{2}{s} + \dfrac{10}{s(1 + 0{,}1s)}$ → ten sam wynik
6. $f_c \approx 995$ Hz; przy 1 kHz: −3,03 dB, −45,2°; przy 10 kHz: −20,1 dB, −84,3°
7. $f_0 \approx 5033$ Hz, $Q \approx 3{,}16$, $B \approx 1592$ Hz, $U_C = Q\cdot 1\ \text{V} \approx 3{,}16$ V

**Ocena:** wszystkie „umiem” — przejrzyj tylko pułapki i zadania. Zadania 1–3 sprawiają trudność — zacznij od tematów 01–03. Zadania 4–5 — tematy 04 i 08. Zadania 6–7 — tematy 06–07.
</details>

## Projekt modułowy: analizator obwodów RC/RLC

Połączenie rachunków, symulacji i programowania — dowód, że rozumiesz, a nie tylko pamiętasz wzory.

- [ ] Wybierz trzy obwody: dzielnik RC, szeregowy RLC, równoległy RLC.
- [ ] Policz ręcznie: transmitancję, częstotliwości charakterystyczne, odpowiedź skokową.
- [ ] Napisz skrypt w Pythonie, który dla zadanych wartości elementów rysuje wykres Bodego i odpowiedź skokową (NumPy + SciPy `signal.lti`).
- [ ] Zasymuluj te same obwody w LTspice (`.ac` i `.tran`) i wyeksportuj dane (File → Export data as text).
- [ ] Nałóż na jeden wykres wynik analityczny, skrypt i LTspice. Wyjaśnij każdą rozbieżność.
- [ ] Jeśli masz sprzęt: zbuduj jeden obwód i zmierz odpowiedź skokową oscyloskopem.

## Sprawdzian końcowy modułu

- [ ] Rozwiązuję obwód z 3–4 węzłami metodą węzłową i oczkową, a wyniki się zgadzają.
- [ ] Zastępuję fragment obwodu źródłem Thévenina i wyznaczam je pomiarowo (napięcie jałowe + jeden pomiar z obciążeniem).
- [ ] Rozwiązuję stany nieustalone 1. rzędu „metodą trzech wielkości” bez pisania równania różniczkowego.
- [ ] Rozpoznaję charakter odpowiedzi układu RLC z samych wartości elementów.
- [ ] Liczę moc czynną, bierną i pozorną oraz kompensuję moc bierną.
- [ ] Rysuję asymptotyczny wykres Bodego transmitancji z kilkoma biegunami i zerami.
- [ ] Rozwiązuję stan nieustalony z niezerowymi warunkami początkowymi metodą operatorową.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [DC Electrical Circuit Analysis — J. M. Fiore](https://eng.libretexts.org/Bookshelves/Electrical_Engineering/Electronics/DC_Electrical_Circuit_Analysis_-_A_Practical_Approach_%28Fiore%29) | Tematy 01–04, dużo zadań z odpowiedziami |
| [AC Electrical Circuit Analysis — J. M. Fiore](https://eng.libretexts.org/Bookshelves/Electrical_Engineering/Electronics/AC_Electrical_Circuit_Analysis%3A_A_Practical_Approach_%28Fiore%29) | Tematy 06–07 |
| [MIT 6.002 Circuits and Electronics](https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/) | Ujęcie akademickie, wykłady wideo, zadania i egzaminy |
| [Khan Academy — Electrical Engineering](https://www.khanacademy.org/science/electrical-engineering) | Krótkie filmy do każdego zagadnienia (DC i AC) |
| [Neso Academy — Network Theory](https://www.classcentral.com/classroom/youtube-network-theory-48208) | Bardzo dużo rozwiązanych zadań na wideo |
| [All About Circuits — tomy DC i AC](https://www.allaboutcircuits.com/textbook/) | Intuicyjne wyjaśnienia, mało matematyki |
| [Ultimate Electronics](https://ultimateelectronicsbook.com/) | Interaktywne symulacje w przeglądarce |
| [Analog Devices — Engineering University Program](https://wiki.analog.com/university) | Ćwiczenia laboratoryjne do obwodów |
| [Falstad Circuit Simulator](https://www.falstad.com/circuit/) | Budowanie intuicji — widać przepływ prądu |
