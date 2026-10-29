# 24.01 — Podstawy akustyki

## Po co to jest

Karta mikrofonu podaje czułość w mV/Pa przy 94 dB SPL, głośnika — poziom w dB przy 1 W i 1 m, norma hałasu — dopuszczalne dB(A). Żeby połączyć te liczby z napięciami w torze elektronicznym, trzeba rozumieć, czym jest fala dźwiękowa, jak definiuje się poziomy w decybelach ([00.07](../00-matematyka/07-decybele.md)) i jak dźwięk słabnie z odległością.

## Teoria w pigułce

### Fala dźwiękowa

- Fala podłużna — drgania cząsteczek wzdłuż kierunku rozchodzenia; zmiany ciśnienia $p$ wokół ciśnienia atmosferycznego (ok. 101 kPa) są bardzo małe: od $20$ µPa (próg słyszenia) do ok. 20–200 Pa (próg bólu, wybuchy).
- Prędkość dźwięku w powietrzu: $c \approx 331\text{,}3 + 0\text{,}606\,\vartheta$ [m/s, °C] — 343 m/s w 20 °C; w wodzie ok. 1480 m/s.
- Długość fali $\lambda = c/f$: 20 Hz — 17 m, 1 kHz — 34 cm, 20 kHz — 17 mm. Porównanie $\lambda$ z wymiarami (głośnika, obudowy, głowy, pomieszczenia) wyjaśnia większość zjawisk kierunkowości i rezonansów.
- **Impedancja akustyczna** ośrodka $Z_0 = \rho c \approx 413$ Pa·s/m (powietrze, 20 °C); natężenie fali płaskiej $I = p_{RMS}^2/(\rho c)$.

### Poziomy w decybelach

| Wielkość | Definicja | Odniesienie |
|---|---|---|
| Poziom ciśnienia **SPL** | $L_p = 20\log_{10}(p/p_0)$ | $p_0 = 20$ µPa |
| Poziom natężenia | $L_I = 10\log_{10}(I/I_0)$ | $I_0 = 10^{-12}$ W/m² |
| Poziom mocy akustycznej | $L_W = 10\log_{10}(P/P_0)$ | $P_0 = 10^{-12}$ W |

- 1 Pa ↔ 94 dB SPL (stąd kalibratory mikrofonów 94 dB / 1 kHz); 0,1 Pa ↔ 74 dB.
- Rozmowa ok. 60 dB, ruch uliczny 80 dB, koncert 100–110 dB, próg bólu ok. 130 dB.
- **Sumowanie źródeł nieskorelowanych** — dodają się moce (natężenia): $L = 10\log_{10}\sum 10^{L_i/10}$; dwa jednakowe: +3 dB. **Spójnych w fazie** (np. dwa głośniki z tym samym sygnałem na niskich częstotliwościach) — dodają się ciśnienia: do +6 dB, a w przeciwfazie wygaszanie.

### Rozchodzenie się

- **Źródło punktowe** (pole swobodne): $L_p(r) = L_W - 20\log_{10}r - 11$ dB; **−6 dB na podwojenie odległości**.
- **Źródło liniowe** (np. długa droga, szyk liniowy głośników): −3 dB na podwojenie.
- **Pole bliskie** — w odległości porównywalnej z rozmiarem źródła lub $\lambda$ prawo odwrotnych kwadratów nie obowiązuje (efekt zbliżeniowy mikrofonów kierunkowych).
- Ograniczona przestrzeń: źródło przy ścianie promieniuje w półprzestrzeń (+3 dB), w narożniku (+9 dB) — dotyczy niskich częstotliwości.
- Tłumienie w powietrzu rośnie z częstotliwością (kilka–kilkadziesiąt dB/km przy kilku kHz).

## Przykład rozwiązany

**Poziom koncertu w różnych odległościach.** Zestaw daje 105 dB SPL w 1 m (na osi, pole swobodne).

- W 3 m: $105 - 20\log_{10}3 = 95\text{,}5$ dB; w 10 m: 85 dB; w 30 m: 75,5 dB.
- Ciśnienie w 1 m: $p = 20\cdot 10^{-6}\cdot 10^{105/20} = 3\text{,}56$ Pa RMS; natężenie $3\text{,}56^2/413 = 31$ mW/m².
- Dwa takie zestawy (różne sygnały — nieskorelowane): +3 dB → 108 dB w 1 m od obu; ten sam sygnał przy niskich częstotliwościach (w fazie): do +6 dB.

## Typowe pułapki

- **Dodawanie decybeli arytmetycznie** — 80 dB + 80 dB to 83 dB, nie 160 dB.
- **20 log czy 10 log** — dla ciśnienia i napięcia 20 log, dla mocy i natężenia 10 log.
- **Prawo −6 dB w pomieszczeniu** — obowiązuje tylko blisko źródła; dalej dominuje pole pogłosowe (temat 08).
- **Pomiar w polu bliskim** traktowany jak w polu dalekim.
- **Mylenie dB SPL z dB(A)** — dB(A) to poziom ważony charakterystyką A (temat 02).

## Ćwiczenie komputerowe

```python
import numpy as np

p0, rho_c = 20e-6, 413.0
spl = lambda p: 20*np.log10(p/p0)
pressure = lambda L: p0*10**(L/20)
print(f"1 Pa = {spl(1):.1f} dB SPL; 105 dB SPL = {pressure(105):.2f} Pa, natężenie {pressure(105)**2/rho_c*1e3:.1f} mW/m²")

for f in (20, 100, 1000, 10_000, 20_000):
    print(f"f = {f:6d} Hz: λ = {343/f:.3f} m")

def add_levels(*L, coherent=False):
    if coherent:
        return 20*np.log10(np.sum([10**(l/20) for l in L]))
    return 10*np.log10(np.sum([10**(l/10) for l in L]))
print(f"80 + 80 dB: nieskorelowane {add_levels(80, 80):.1f} dB, w fazie {add_levels(80, 80, coherent=True):.1f} dB; 80 + 70 dB: {add_levels(80, 70):.1f} dB")

# dwa głośniki w odległości 1,7 m od siebie, słuchacz na osi jednego: interferencja w funkcji częstotliwości
d1, d2 = 3.0, np.hypot(3.0, 1.7)
for f in (50, 100, 200, 500, 1000):
    k = 2*np.pi*f/343
    p = 1/d1*np.exp(-1j*k*d1) + 1/d2*np.exp(-1j*k*d2)
    print(f"{f:5d} Hz: poziom względem jednego głośnika {20*np.log10(abs(p)*d1):+5.1f} dB")
```

Interferencja dwóch spójnych źródeł daje wzmocnienia i wygaszenia zależne od częstotliwości i miejsca słuchacza — to podstawa zjawisk w zwrotnicach (temat 05) i pomieszczeniach (temat 08).

## Zadania

1. Ile wynosi ciśnienie przy 74 dB SPL i przy 120 dB SPL?
2. Maszyna daje 85 dB w 2 m. Jaki poziom w 16 m (pole swobodne)?
3. Trzy nieskorelowane źródła: 70, 73 i 76 dB. Poziom sumaryczny?
4. Jaka jest długość fali 50 Hz w temperaturze 0 °C?
5. Dlaczego subwoofer w narożniku pokoju gra głośniej niż na środku?

<details>
<summary>Odpowiedzi</summary>

1. 0,1 Pa i 20 Pa
2. Trzy podwojenia odległości: $85 - 18 = 67$ dB
3. $10\log_{10}(10^7 + 10^{7\text{,}3} + 10^{7\text{,}6}) \approx 78\text{,}5$ dB
4. $c = 331\text{,}3$ m/s; $\lambda = 6\text{,}6$ m
5. Ściany i podłoga ograniczają przestrzeń promieniowania (odbicia w fazie przy długich falach): w narożniku trójściennym promieniuje w 1/8 przestrzeni — do +9 dB względem pola swobodnego; dodatkowo pobudza wszystkie mody pomieszczenia
</details>

## Źródła

- [UCF Physics — Physics of Hearing](https://pressbooks.online.ucf.edu/phy2053bc/chapter/hearing/) — fala dźwiękowa, poziomy
- [sengpielaudio — kalkulatory SPL, ciśnienia i natężenia](https://sengpielaudio.com/Calculations03.htm)
- [Stanford CCRMA — książki online J. O. Smitha](https://ccrma.stanford.edu/~jos/EE201/Related_Online_Books_CCRMA.html) — akustyka fizyczna
- [02.04 Drgania i fale](../02-fizyka-i-materialy/04-drgania-i-fale.md)
