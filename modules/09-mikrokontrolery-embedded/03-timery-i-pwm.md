# 09.03 — Timery i PWM

## Po co to jest

Timery odmierzają czas, generują przebiegi PWM (sterowanie silnikami, jasnością LED, przetwornicami), mierzą częstotliwość i szerokość impulsów, wyzwalają przetworniki A/C. Sprzętowy timer jest dokładniejszy i nie obciąża procesora tak jak pętla programowa.

## Teoria w pigułce

### Licznik z preskalerem

Licznik zwiększa się z częstotliwością $f_{tim}/(PSC + 1)$ i przepełnia po osiągnięciu wartości okresu $ARR$:

$$f_{przep} = \frac{f_{tim}}{(PSC + 1)(ARR + 1)}$$

(Konwencja „+1” jest typowa, np. w STM32 — sprawdź w dokumentacji swojej rodziny.)

### Tryby pracy

| Tryb | Zastosowanie |
|---|---|
| Przerwanie od przepełnienia | Podstawa czasu systemu (tick), cykliczne zadania |
| **PWM** (porównanie) | Wyjście wysokie, gdy licznik < CCR; wypełnienie $D = CCR/(ARR + 1)$ |
| **Przechwytywanie (input capture)** | Zapis stanu licznika przy zboczu wejścia — pomiar okresu i szerokości impulsu |
| Tryb jednorazowy | Pojedynczy impuls o zadanej długości |
| Enkoder | Zliczanie impulsów kwadraturowych enkodera |
| Wyzwalanie peryferiów | Start konwersji A/C, transfer DMA |

### PWM

- **Rozdzielczość:** $\log_2(ARR + 1)$ bitów — rośnie z $f_{tim}$, maleje z częstotliwością PWM.
- PWM wyrównane do krawędzi lub centrowane (mniej harmonicznych, sterowanie silników).
- Wyjścia komplementarne z **czasem martwym** — sterowanie mostkami tranzystorowymi bez przewodzenia skrośnego.
- PWM + filtr RC = prosty przetwornik C/A ([07.01](../07-cps-dsp/01-przetwarzanie-ac.md)): kompromis między tętnieniami a szybkością odpowiedzi.

### Pomiar czasu

Przechwytywanie dwóch kolejnych zboczy: okres $T = (n_2 - n_1)/f_{licz}$. Przy przepełnieniu licznika między zboczami — odejmowanie modulo $2^N$ (dla liczb bez znaku działa automatycznie). Rozdzielczość: $1/f_{licz}$.

## Przykład rozwiązany

**PWM 20 kHz dla silnika** przy $f_{tim} = 72$ MHz:

1. $PSC = 0$, $ARR + 1 = 72\cdot 10^6/20\cdot 10^3 = 3600$ → $ARR = 3599$.
2. Rozdzielczość: $\log_2 3600 \approx 11\text{,}8$ bitu.
3. Wypełnienie 25%: $CCR = 900$.

**Serwo modelarskie (50 Hz, impuls 1–2 ms):**

1. $PSC = 71$ → licznik 1 MHz (1 µs na krok).
2. $ARR = 19\,999$ → okres 20 ms.
3. Impuls 1,5 ms: $CCR = 1500$. Zakres 1000–2000 daje 1000 kroków na pełny obrót serwa.

## Typowe pułapki

- **Konwencja ARR/ARR+1 pomylona** — błąd częstotliwości rzędu 1/ARR (przy małych ARR istotny).
- **Częstotliwość zegara timera przyjęta z zegara systemowego** — może być inna (dzielniki magistral, mnożnik ×2).
- **Zmiana CCR w środku okresu bez buforowania** (preload) — pojedynczy zniekształcony impuls.
- **Mostek H bez czasu martwego** — zwarcie zasilania przez tranzystory.
- **PWM o częstotliwości słyszalnej** dla silnika lub cewki — piszczenie (stąd ≥ 20 kHz).

## Ćwiczenie komputerowe

```python
def timer_settings(f_tim, f_target, max_arr=65535):
    best = None
    for psc in range(0, 65536):
        arr = round(f_tim/((psc + 1)*f_target)) - 1
        if 0 < arr <= max_arr:
            f = f_tim/((psc + 1)*(arr + 1))
            err = abs(f - f_target)/f_target
            if best is None or err < best[3] or (err == best[3] and arr > best[1]):
                best = (psc, arr, f, err)
            if err == 0: break
    return best

for f in [20e3, 50, 1e3, 38e3]:
    psc, arr, fr, err = timer_settings(72e6, f)
    print(f"{f:>8.0f} Hz: PSC={psc}, ARR={arr}, f={fr:.3f} Hz, błąd={err*1e6:.1f} ppm")
```

## Zadania

1. $f_{tim} = 72$ MHz, PWM 20 kHz. PSC, ARR, rozdzielczość, CCR dla 25%?
2. Ustawienia timera dla serwa (50 Hz, rozdzielczość 1 µs).
3. Przechwytywanie przy liczniku 1 MHz zarejestrowało 61 234 i 3 018 (16-bitowy licznik przepełnił się raz). Jaki okres i częstotliwość?
4. PWM 1 kHz z filtrem RC (τ = 10 ms) jako przetwornik C/A, 3,3 V. Oszacuj tętnienia przy wypełnieniu 50%.
5. Jaka jest maksymalna częstotliwość PWM o rozdzielczości 10 bitów przy $f_{tim} = 72$ MHz?

<details>
<summary>Odpowiedzi</summary>

1. PSC = 0, ARR = 3599, ≈ 11,8 bitu, CCR = 900
2. PSC = 71, ARR = 19 999
3. $(3018 - 61234) \bmod 65536 = 7320$ µs → ok. 136,6 Hz
4. Przy $T \ll \tau$: $\Delta U \approx \dfrac{U\cdot D(1 - D)\cdot T}{\tau} = \dfrac{3\text{,}3\cdot 0\text{,}25\cdot 1\ \text{ms}}{10\ \text{ms}} \approx 83$ mV
5. $72\cdot 10^6/1024 \approx 70\text{,}3$ kHz
</details>

## Źródła

- [Embedded Systems — Shape the World (J. Valvano)](https://users.ece.utexas.edu/~valvano/Volume1/E-Book/) — timery, PWM, pomiar czasu
- [Embedded Controllers Using C and Arduino — J. M. Fiore](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html) — PWM i pomiar czasu na Arduino
- Reference manual wybranego mikrokontrolera — rozdział o timerach (często największy w dokumentacji)
