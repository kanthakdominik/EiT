# 17.06 — Domeny zegarowe i reset

## Po co to jest

Prawdziwe systemy mają wiele zegarów (interfejs przetwornika, USB, Ethernet, zegar główny) i sygnały całkowicie asynchroniczne (przyciski, linie UART, przerwania z innych układów). Błędne przeniesienie sygnału między domenami zegarowymi (CDC) daje usterki rzadkie, zależne od temperatury i egzemplarza — najtrudniejsze do znalezienia. Kilka standardowych struktur rozwiązuje ten problem niezawodnie.

## Teoria w pigułce

### Metastabilność

Gdy dane zmieniają się w oknie setup/hold, przerzutnik może na pewien czas utknąć w stanie pośrednim i rozstrzygnąć się losowo. Prawdopodobieństwo nierozstrzygnięcia maleje wykładniczo z czasem. Średni czas między błędami:

$$MTBF = \frac{e^{t_r/\tau}}{T_0\cdot f_{clk}\cdot f_{dane}}$$

$t_r$ — czas dany na rozstrzygnięcie (zwykle ok. jeden okres zegara minus $t_{co}$ i $t_{su}$), $\tau$, $T_0$ — parametry technologii (τ rzędu dziesiątek ps). Dodanie przerzutnika zwiększa $t_r$ o cały okres — MTBF rośnie o wiele rzędów wielkości.

### Struktury CDC

| Sytuacja | Rozwiązanie |
|---|---|
| **Pojedynczy bit, wolnozmienny** (poziom: przycisk, flaga konfiguracji) | **Synchronizator 2-FF** (dwa przerzutniki w domenie docelowej, bez logiki między nimi) — jak `rx_s0/rx_s1` w [uart_rx.v](hdl/uart_rx.v) i `s0/s1` w [debounce.v](hdl/debounce.v) |
| **Impuls jednego taktu** do wolniejszej domeny | Synchronizator przełączający (toggle): impuls zmienia stan przerzutnika, w domenie docelowej synchronizator + detekcja zmiany |
| **Słowo wielobitowe**, rzadko zmieniane | Uzgadnianie (handshake): dane stabilne, synchronizowany jest tylko sygnał „ważne”/potwierdzenie |
| **Strumień danych** | **Asynchroniczna FIFO**: pamięć dwuportowa, wskaźniki w kodzie Graya synchronizowane do drugiej domeny |
| Licznik (np. czas) | Kod Graya (zmienia się jeden bit naraz) + synchronizator |

**Nigdy** nie synchronizuje się wielu bitów osobnymi synchronizatorami (bity mogą zostać „przechwycone” w różnych taktach — niespójne słowo) ani sygnału z logiki kombinacyjnej (szpilki — synchronizuje się wyjście przerzutnika).

### FIFO synchroniczna i asynchroniczna

[hdl/fifo_sync.v](hdl/fifo_sync.v) — jedna domena; wskaźniki mają dodatkowy bit odróżniający „pełna” od „pusta”. W wersji asynchronicznej wskaźnik zapisu (w kodzie Graya) przechodzi przez synchronizator do domeny odczytu (do obliczenia `empty`), a wskaźnik odczytu — do domeny zapisu (`full`); flagi są „pesymistyczne” (opóźnione), więc bezpieczne.

### Reset

- **Asynchroniczne załączenie, synchroniczne zwolnienie:** zewnętrzny reset natychmiast zeruje układ, ale jego zwolnienie przechodzi przez synchronizator w każdej domenie zegarowej — wszystkie przerzutniki wychodzą z resetu w tym samym takcie.
- Reset po skonfigurowaniu FPGA: wartości początkowe rejestrów (inicjalizacja w deklaracji) są ładowane z pliku konfiguracyjnego — w wielu projektach wystarczają, a globalny reset ogranicza się do logiki sterującej.
- Reset z PLL: logika czeka na sygnał `locked`.

## Przykład rozwiązany

**MTBF synchronizatora** (parametry przykładowe: τ = 0,1 ns, $T_0$ = 1 ns, zegar 100 MHz, dane zmieniają się 10⁶ razy/s):

1. Jeden przerzutnik, za nim od razu logika zajmująca 8 ns okresu → $t_r \approx 2$ ns: $MTBF = e^{20}/(10^{-9}\cdot 10^8\cdot 10^6) \approx 4\text{,}9\cdot 10^3$ s — **błąd co ok. 1,3 godziny**.
2. Dwa przerzutniki (drugi bez logiki przed sobą): $t_r \approx 9\text{,}5$ ns → $MTBF \approx e^{95}/10^5$ s — rzędu $10^{28}$ lat. Taki zysk daje jeden dodatkowy przerzutnik.

**Przycisk do automatu:** sygnał z przycisku → synchronizator 2-FF → eliminacja drgań → wykrywanie zbocza (porównanie z poprzednią wartością) → impuls jednego taktu do automatu ([hdl/debounce.v](hdl/debounce.v) realizuje dwa pierwsze kroki).

## Typowe pułapki

- **Sygnał asynchroniczny użyty bezpośrednio** w warunku `if` lub automacie.
- **Logika między przerzutnikami synchronizatora.**
- **Szyna danych przez osobne synchronizatory** dla każdego bitu.
- **Impuls krótszy niż okres zegara docelowego** — znika (potrzebny synchronizator toggle/handshake).
- **Brak ograniczeń dla ścieżek CDC** albo przeciwnie — `false_path` na wszystkim między domenami, także na ścieżkach bez synchronizatora.
- **Zwolnienie resetu bez synchronizacji** — część przerzutników startuje takt później.

## Ćwiczenie komputerowe

MTBF jednego i dwóch przerzutników w funkcji częstotliwości zegara (parametry przykładowe) i model synchronizatora toggle dla impulsów:

```python
import numpy as np

tau, T0, f_data, year = 0.1e-9, 1e-9, 1e6, 3.156e7
for fclk in [50e6, 100e6, 200e6, 400e6]:
    T = 1/fclk
    for n_ff, tr in [(1, max(T - 8e-9, 0.2e-9)), (2, T - 0.5e-9)]:
        mtbf = np.exp(tr/tau)/(T0*fclk*f_data)
        print(f"{fclk/1e6:5.0f} MHz, {n_ff} FF (t_r = {tr*1e9:4.1f} ns): MTBF ≈ {mtbf/year:.2e} lat")

# synchronizator toggle: impulsy jednego taktu w szybkiej domenie (100 MHz) przenoszone do wolnej (30 MHz)
fast, slow = 100e6, 30e6
pulse_cycles = [12, 40, 41, 300, 777]                 # takty szybkiej domeny z impulsem
pulse_times = [c/fast for c in pulse_cycles]
sync, detected = [0, 0, 0], 0
for i in range(int(1000/fast*slow) + 1):              # zbocza wolnego zegara przez 10 µs
    t = i/slow
    toggle = sum(tp < t for tp in pulse_times) % 2    # przerzutnik toggle: zmienia stan przy każdym impulsie
    sync = [toggle, sync[0], sync[1]]                  # 2 FF synchronizatora + rejestr do wykrycia zmiany
    detected += sync[1] != sync[2]
print(f"impulsów: {len(pulse_cycles)}, wykrytych w wolnej domenie: {detected} "
      "(impulsy w taktach 40 i 41 trafiają między te same zbocza wolnego zegara i znoszą się)")
```

Wynik pokazuje dwie rzeczy. Jeden przerzutnik, za którym od razu jest logika, zawodzi już przy 100 MHz. Przy 400 MHz nawet dwa przerzutniki dają MTBF rzędu minut (przy tych przykładowych parametrach) — dlatego przy wysokich częstotliwościach stosuje się synchronizatory trzyprzerzutnikowe, a do obliczeń bierze parametry τ i $T_0$ z dokumentacji danej technologii.

## Zadania

1. Dlaczego synchronizator ma dwa (lub trzy) przerzutniki, a nie jeden?
2. Szyna 8-bitowa ze stanem licznika przechodzi do innej domeny. Jak to zrobić poprawnie?
3. Impuls jednego taktu przy 200 MHz ma trafić do domeny 20 MHz. Co się stanie przy zwykłym synchronizatorze 2-FF i jak to rozwiązać?
4. Dlaczego wskaźniki asynchronicznej FIFO koduje się w kodzie Graya?
5. Opisz schemat resetu „asynchroniczne załączenie, synchroniczne zwolnienie”.

<details>
<summary>Odpowiedzi</summary>

1. Pierwszy przerzutnik może wejść w stan metastabilny; drugi daje mu pełny okres na rozstrzygnięcie, zanim wartość zostanie użyta — MTBF rośnie wykładniczo; przy wysokich częstotliwościach lub wymaganiach — trzeci
2. Kod Graya (jeden bit zmienia się naraz) + synchronizator każdego bitu — albo handshake/FIFO dla dowolnych danych; nie synchronizować zwykłego kodu binarnego bit po bicie
3. Impuls 5 ns zwykle nie zostanie zauważony przez zegar 50 ns; rozwiązanie: synchronizator toggle (impuls zmienia stan przerzutnika, w wolnej domenie wykrywana zmiana) lub rozciągnięcie impulsu z potwierdzeniem (handshake)
4. Wskaźnik zmienia się o 1 → w kodzie Graya zmienia się jeden bit; przechwycony w trakcie zmiany daje albo starą, albo nową wartość — nigdy przypadkową
5. Zewnętrzny reset asynchronicznie zeruje dwa przerzutniki synchronizatora resetu (i przez nie cały układ); po zwolnieniu do synchronizatora wpisywana jest jedynka, która po dwóch taktach zwalnia reset układu synchronicznie z zegarem — osobny synchronizator w każdej domenie
</details>

## Źródła

- [ZipCPU](https://zipcpu.com/) — CDC, synchronizatory, asynchroniczne FIFO, weryfikacja formalna
- [nandland](https://nandland.com/) — metastabilność i przekraczanie domen zegarowych
- [MIT 6.111](https://ocw.mit.edu/courses/6-111-introductory-digital-systems-laboratory-spring-2006/) — synchronizacja sygnałów asynchronicznych
- [05.06 Parametry czasowe](../05-technika-cyfrowa/06-parametry-czasowe.md) — metastabilność od podstaw
