# 15.03 — Boost, buck-boost i pompy ładunku

## Po co to jest

Nie zawsze trzeba obniżać napięcie: z jednego ogniwa Li-ion (3–4,2 V) trzeba zrobić 5 V dla USB, z 3,3 V — 12 V dla diod LED czy 24 V dla sterownika, a z baterii, której napięcie przechodzi przez wartość wyjściową, — stałe 3,3 V. Do tego służą przetwornice podwyższające (boost), odwracające i obniżająco-podwyższające, a przy małych prądach — pompy ładunku bez dławika.

## Teoria w pigułce

### Boost (podwyższająca)

Klucz zwiera dławik do masy przez $DT$ (prąd narasta), potem dławik oddaje energię przez diodę do wyjścia.

$$U_{wy} = \frac{U_{we}}{1 - D},\qquad I_{we} = \frac{I_{wy}}{1 - D},\qquad \Delta I_L = \frac{U_{we}D}{f_{sw}L},\qquad \Delta U_{wy} \approx \frac{I_{wy}D}{f_{sw}C}$$

- Prąd wyjściowy płynie impulsowo (tylko w czasie $(1 - D)T$) → **kondensator wyjściowy ma duży prąd tętnień**, wejściowy — mały.
- **Brak ochrony przed zwarciem wyjścia** — przez dławik i diodę płynie prąd bezpośrednio z wejścia; wyjście nie odłącza się, nawet gdy klucz jest wyłączony (potrzebny klucz odcinający lub topologia z odłączaniem).
- Praktyczne wzmocnienie ograniczone do ok. 5–10× (straty, wypełnienie bliskie 1).
- Prawe zero transmitancji (RHPZ) w sterowaniu — ogranicza pasmo pętli ([15.06](06-sterowanie-i-kompensacja.md)).

### Buck-boost

| Topologia | Napięcie wyjściowe | Cechy |
|---|---|---|
| **Odwracająca** (inverting buck-boost) | $U_{wy} = -U_{we}\dfrac{D}{1 - D}$ | Ujemne napięcie, jeden dławik |
| **Czterokluczowa** (4-switch buck-boost) | Dodatnie, wyżej lub niżej | Układy scalone do zasilania z baterii i USB-C PD; wysoka sprawność |
| **SEPIC** | Dodatnie, $U_{we}\dfrac{D}{1 - D}$ | Dwa dławiki (lub sprzężone) i kondensator sprzęgający; izolacja DC wejścia od wyjścia przy zwarciu |
| Ćuk | Ujemne | Ciągłe prądy wejścia i wyjścia |
| Flyback | Dowolne, izolowane | [15.05](05-przetwornice-izolowane.md) |

### Pompy ładunku

Kondensatory przełączane kluczami zamiast dławika: **podwajacz**, **inwerter** ($-U_{we}$), dzielnik przez 2. Mała liczba elementów, brak pola magnetycznego (mniej EMI), ale małe prądy (do kilkudziesięciu–kilkuset mA) i stały stosunek przetwarzania (stabilizacja przez dodatkowy LDO lub regulację). Zastosowania: zasilanie sterowników bramek (bootstrap — [15.04](04-elementy-straty-sprawnosc.md)), napięcia ujemne dla wzmacniaczy, sterowniki LED, interfejsy RS-232. Nowoczesne przetwornice z kondensatorami przełączanymi o dużej mocy (np. 48 → 12 V w centrach danych) osiągają sprawności > 98%.

## Przykład rozwiązany

**Boost 3,7 V → 5 V / 0,5 A, 1 MHz:**
1. $D = 1 - 3\text{,}7/5 = 0\text{,}26$.
2. $I_{we} = 0\text{,}5/0\text{,}74 \approx 0\text{,}68$ A (idealnie; przy sprawności 90% ok. 0,75 A).
3. Tętnienia prądu 30% prądu wejściowego (0,2 A): $L = \dfrac{3\text{,}7\cdot 0\text{,}26}{10^6\cdot 0\text{,}2} \approx 4\text{,}7$ µH.
4. Kondensator 10 µF: $\Delta U \approx \dfrac{0\text{,}5\cdot 0\text{,}26}{10^6\cdot 10^{-5}} = 13$ mV (+ ESR × prąd szczytowy diody ok. 0,78 A — przy ESR 10 mΩ dodatkowe 8 mV).
5. Najgorszy przypadek: bateria rozładowana do 3,0 V → $D = 0\text{,}4$, $I_{we} \approx 0\text{,}83$ A (idealnie) — dobór dławika i klucza na ten przypadek.

**Inwerter z 12 V na −5 V:** $D/(1 - D) = 5/12$ → $D \approx 0\text{,}294$.

## Typowe pułapki

- **Dobór boost dla nominalnego napięcia baterii** zamiast minimalnego — dławik nasyca się przy rozładowanej baterii.
- **Zwarcie wyjścia boost** — brak ograniczenia prądu (bezpiecznik, klucz odcinający).
- **Kondensator wyjściowy boost dobrany jak w buck** — za mały prąd tętnień, przegrzewanie.
- **Pompa ładunku obciążona większym prądem niż w nocie** — napięcie spada (rezystancja wyjściowa rzędu omów).
- **SEPIC z kondensatorem sprzęgającym o zbyt małym prądzie skutecznym.**

## Ćwiczenie komputerowe

Charakterystyki przetwarzania i symulacja przełączana boost:

```python
import numpy as np

D = np.array([0.1, 0.26, 0.4, 0.5, 0.7, 0.9])
print("D     buck   boost  inverting")
for d in D:
    print(f"{d:4.2f}  {d:5.2f}  {1/(1 - d):5.2f}  {-d/(1 - d):6.2f}  (× U_we)")

Vin, R, L, C, fsw = 3.7, 10.0, 4.7e-6, 10e-6, 1e6       # 5 V / 0,5 A
Dset = 1 - Vin/5.0; T = 1/fsw; dt = T/400
iL, vC = 0.68, 5.0; IL, VO = [], []
for k in range(int(3e-3/dt)):                       # 3 ms — stan ustalony
    on = (k*dt % T) < Dset*T
    vL = Vin if on else Vin - vC                         # dioda idealna (CCM)
    iL += dt*vL/L
    vC += dt*((0 if on else iL) - vC/R)/C
    if k*dt > 3e-3 - 4*T: IL.append(iL); VO.append(vC)
IL, VO = np.array(IL), np.array(VO)
print(f"boost: U_wy = {VO.mean():.3f} V, tętnienia {1e3*(VO.max() - VO.min()):.1f} mV (wzór {1e3*0.5*Dset/(fsw*C):.1f} mV), "
      f"średni i_L = {IL.mean():.3f} A (wzór {0.5/(1 - Dset):.3f} A), dI = {IL.max() - IL.min():.3f} A")
```

## Zadania

1. Boost 5 V → 12 V / 0,3 A, 500 kHz. Wypełnienie, prąd wejściowy, dławik dla tętnień 30%.
2. Tętnienia wyjściowe tego boost przy 22 µF (bez ESR).
3. Bateria 2 × AA (1,8–3,2 V) ma zasilać układ 3,3 V. Jaką topologię wybierzesz?
4. Pompa ładunku podwaja 5 V przy prądzie 20 mA i ma rezystancję wyjściową 15 Ω. Jakie napięcie wyjściowe?
5. Dlaczego w boost nie można ograniczyć prądu zwarcia samym wyłączeniem klucza?

<details>
<summary>Odpowiedzi</summary>

1. $D = 1 - 5/12 \approx 0\text{,}583$; $I_{we} = 0\text{,}3/0\text{,}417 \approx 0\text{,}72$ A; $\Delta I = 0\text{,}22$ A → $L = 5\cdot 0\text{,}583/(5\cdot 10^5\cdot 0\text{,}22) \approx 27$ µH
2. $0\text{,}3\cdot 0\text{,}583/(5\cdot 10^5\cdot 22\cdot 10^{-6}) \approx 16$ mV
3. Buck-boost (np. czterokluczowy) — napięcie baterii przechodzi przez 3,3 V
4. $10 - 0\text{,}02\cdot 15 = 9\text{,}7$ V
5. Ścieżka wejście → dławik → dioda → wyjście jest zawsze przewodząca w kierunku przewodzenia diody; wyłączony klucz nie przerywa tej drogi
</details>

## Źródła

- [TI SLVA372 — Basic Calculation of a Boost Converter's Power Stage](https://www.ti.com/document-viewer/lit/html/SLVA372) — wzory doboru elementów boost
- [MIT 6.622 Power Electronics](https://ocw.mit.edu/courses/6-622-power-electronics-spring-2023/) — topologie DC-DC, przetwornice z kondensatorami przełączanymi
- [Introduction to Power Electronics — R. Erickson (Coursera)](https://www.coursera.org/learn/power-electronics) — boost, buck-boost, SEPIC, Ćuk
