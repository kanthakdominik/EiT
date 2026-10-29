# 24.02 — Słuch i psychoakustyka

## Po co to jest

Odbiorcą toru audio jest ludzkie ucho — przyrząd o zakresie dynamiki ok. 120 dB, czułości zależnej od częstotliwości i poziomu oraz o własnościach, które pozwalają „wyrzucić” z sygnału 90% danych bez słyszalnej straty (kodeki MP3, AAC, Opus). Stąd ważenie A w miernikach hałasu, specyfikacje szumu „A-weighted”, wymagania na zniekształcenia i opóźnienia oraz dopuszczalne dawki hałasu w BHP.

## Teoria w pigułce

### Zakres słyszenia

- Częstotliwości: ok. 20 Hz – 20 kHz (górna granica maleje z wiekiem: 15 kHz u wielu dorosłych).
- Największa czułość: 2–5 kHz (rezonans kanału słuchowego).
- **Krzywe równej głośności** (ISO 226): poziom tonu o różnej częstotliwości, który brzmi tak samo głośno jak ton 1 kHz; jednostka głośności — **fon** (równy dB SPL tonu 1 kHz). Przy cichym odsłuchu niskie tony są słyszane znacznie słabiej (stąd funkcja „loudness”).
- **Son** — skala głośności liniowa dla percepcji: +10 fonów ≈ dwa razy głośniej.

### Ważenie częstotliwościowe

| Charakterystyka | Zastosowanie | Wartość przy 100 Hz / 1 kHz / 10 kHz |
|---|---|---|
| **A** | Hałas, szum urządzeń (przybliża krzywą 40 fonów) | −19,1 / 0 / −2,5 dB |
| C | Wysokie poziomy, szczytowe | −0,3 / 0 / −4,4 dB |
| Z | Bez ważenia | 0 |

Specyfikacja „SNR 100 dB(A)” wygląda lepiej niż nieważona, bo ważenie A tłumi szum niskoczęstotliwościowy i bardzo wysokie częstotliwości (ok. 2 dB dla szumu białego w paśmie 20 Hz–20 kHz, więcej dla szumu z przewagą niskich częstotliwości).

### Maskowanie i rozdzielczość

- **Maskowanie równoczesne:** głośny ton czyni niesłyszalnymi słabsze dźwięki w sąsiedztwie (szczególnie wyższych częstotliwości) — próg maskowania w **pasmach krytycznych** (skala Bark, ok. 24 pasma; szerokość ok. 100 Hz poniżej 500 Hz, ok. 20% częstotliwości wyżej).
- **Maskowanie czasowe:** przed i po głośnym dźwięku (kilka do ok. 100–200 ms).
- Kodeki stratne obliczają próg maskowania i kwantują składowe tak, by szum kwantyzacji leżał poniżej progu.
- Najmniejsza wyczuwalna zmiana poziomu ok. 1 dB, częstotliwości ok. 0,2–0,5% (przy średnich częstotliwościach).
- **Lokalizacja:** różnice czasu (ITD, do ok. 0,7 ms — niskie częstotliwości) i poziomu (ILD — wysokie częstotliwości) między uszami, filtrowanie przez małżowinę (HRTF).

### Hałas i słuch

Dopuszczalna ekspozycja zawodowa (UE): 85 dB(A) przez 8 h (wartość progowa działania), z zasadą wymiany 3 dB: każde +3 dB skraca dopuszczalny czas o połowę. Uszkodzenie słuchu przez hałas jest nieodwracalne.

## Przykład rozwiązany

**Ważenie A szumu wzmacniacza.** Szum wyjściowy ma płaską gęstość w paśmie 20 Hz–20 kHz i wartość skuteczną 100 µV. Ile wyniesie po ważeniu A?

Moc ważona: $\dfrac{1}{B}\displaystyle\int_{20}^{20\,000}\lvert A(f)\rvert^2\,df \approx 0\text{,}62$ (obliczenie numeryczne niżej) → $100\ \mu\text{V}\cdot\sqrt{0\text{,}62} \approx 79$ µV — poprawa o ok. 2 dB. Dla szumu z przewagą niskich częstotliwości (np. przydźwięk 50/100 Hz) różnica jest dużo większa.

**Dawka hałasu:** 94 dB(A) to o 9 dB więcej niż 85 dB(A) → dopuszczalny czas $8\ \text{h}/2^3 = 1$ h.

## Typowe pułapki

- **Porównywanie SNR podanego w dB(A) z nieważonym.**
- **Ocena brzmienia przy różnych poziomach głośności** — głośniejsza wersja zawsze wydaje się „lepsza”; porównania A/B wymagają wyrównania poziomu do ±0,1–0,2 dB.
- **Myślenie, że ucho nie słyszy zniekształceń poniżej 1%** — słyszalność zależy od rzędu harmonicznych (wysokie rzędy i zniekształcenia skrośne są słyszalne przy znacznie mniejszych wartościach) i od maskowania.
- **Pomijanie opóźnienia** w systemach monitorowych i wideo — opóźnienie dźwięku względem obrazu > ok. 40–100 ms jest zauważalne.

## Ćwiczenie komputerowe

Charakterystyka ważenia A (wzór z IEC 61672) i wpływ na szum biały:

```python
import numpy as np

def a_weight_db(f):
    f2 = np.asarray(f, dtype=float)**2
    ra = 12194**2*f2**2/((f2 + 20.6**2)*np.sqrt((f2 + 107.7**2)*(f2 + 737.9**2))*(f2 + 12194**2))
    return 20*np.log10(ra) + 2.0

for f in (31.5, 100, 1000, 4000, 10_000, 16_000):
    print(f"A({f:6} Hz) = {a_weight_db(f):+6.1f} dB")

f = np.linspace(20, 20_000, 200_000)
gain_power = np.trapezoid(10**(a_weight_db(f)/10), f)/(20_000 - 20)
print(f"szum biały 20 Hz–20 kHz: po ważeniu A moc × {gain_power:.3f} → {10*np.log10(gain_power):+.1f} dB")

# szum różowy (gęstość ∝ 1/f) — więcej mocy w niskich częstotliwościach
w = 1/f
gain_pink = np.trapezoid(w*10**(a_weight_db(f)/10), f)/np.trapezoid(w, f)
print(f"szum różowy 20 Hz–20 kHz: po ważeniu A {10*np.log10(gain_pink):+.1f} dB")

# dawka hałasu z zasadą wymiany 3 dB
for L in (85, 88, 94, 100):
    print(f"{L} dB(A): dopuszczalnie {8/2**((L - 85)/3):.2f} h")
```

## Zadania

1. Ile wynosi ważenie A przy 50 Hz i 2 kHz (użyj kodu)?
2. Dlaczego przydźwięk 50 Hz słychać słabiej, niż wynikałoby z jego poziomu w dB SPL?
3. Pracownik spędza 2 h w hałasie 91 dB(A). Czy przekracza dawkę równoważną 85 dB(A) przez 8 h?
4. Na czym polega wykorzystanie maskowania w kodeku MP3?
5. Jak różnica czasu dotarcia dźwięku do uszu pozwala określić kierunek? Jaka jest maksymalna różnica przy odległości uszu 18 cm?

<details>
<summary>Odpowiedzi</summary>

1. Ok. −30,2 dB i +1,2 dB
2. Czułość słuchu przy 50 Hz jest znacznie mniejsza niż przy 1–4 kHz (krzywe równej głośności); ważenie A przy 50 Hz to ok. −30 dB. W praktyce słychać raczej harmoniczne przydźwięku (150, 250 Hz…)
3. Dopuszczalny czas dla 91 dB(A) to $8/2^2 = 2$ h — dokładnie na granicy dawki
4. Sygnał dzieli się na pasma (banki filtrów/MDCT), model psychoakustyczny wyznacza próg maskowania w każdym paśmie, a bity przydziela się tak, by szum kwantyzacji w każdym paśmie był poniżej progu — składowe maskowane koduje się zgrubnie lub pomija
5. Mózg porównuje fazy/chwile dotarcia sygnału do obu uszu; maksymalna różnica (dźwięk z boku) ok. $0\text{,}18/343 \approx 0\text{,}5$ ms (z uwzględnieniem drogi wokół głowy ok. 0,6–0,7 ms)
</details>

## Źródła

- [UCF Physics — Physics of Hearing](https://pressbooks.online.ucf.edu/phy2053bc/chapter/hearing/)
- [sengpielaudio — tabele dB](https://sengpielaudio.com/dB-chart.htm)
- [MIT 21M.380 Music and Technology: Sound Design](https://ocw.mit.edu/courses/21m-380-music-and-technology-sound-design-spring-2016/)
