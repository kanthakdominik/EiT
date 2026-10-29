# 15.02 — Przetwornica obniżająca (buck)

## Po co to jest

Przetwornica buck jest najczęściej spotykaną przetwornicą impulsową: zasila procesory, układy FPGA, moduły radiowe, całe płytki z 12 V, 24 V czy z USB-C. Zamiast „spalać” nadmiar napięcia, przełącza je z dużą częstotliwością i uśrednia filtrem LC — przy sprawności 85–95%. Jej analiza jest wzorem dla wszystkich innych topologii.

## Teoria w pigułce

### Zasada działania

Klucz (MOSFET) łączy wejście z dławikiem na czas $DT$, potem prąd dławika płynie przez diodę (lub drugi tranzystor — **przetwornica synchroniczna**) przez $(1 - D)T$. Filtr LC uśrednia napięcie w węźle przełączającym.

**Bilans woltosekund dławika** (w stanie ustalonym średnie napięcie na dławiku = 0):

$$(U_{we} - U_{wy})DT = U_{wy}(1 - D)T\ \Rightarrow\ U_{wy} = D\cdot U_{we}$$

(w praktyce $D$ nieco większe — spadki na kluczach i dławiku).

### Prądy i tętnienia (CCM)

| Wielkość | Wzór |
|---|---|
| Tętnienia prądu dławika | $\Delta I_L = \dfrac{(U_{we} - U_{wy})D}{f_{sw}L} = \dfrac{U_{wy}(1 - D)}{f_{sw}L}$ |
| Prąd szczytowy | $I_{pk} = I_{wy} + \Delta I_L/2$ |
| Tętnienia napięcia wyjściowego | $\Delta U \approx \dfrac{\Delta I_L}{8f_{sw}C} + \Delta I_L\cdot ESR$ |
| Średni prąd wejściowy | $I_{we} \approx D\cdot I_{wy}/\eta$ (impulsowy — kondensator wejściowy przejmuje tętnienia) |
| Prąd skuteczny kondensatora wejściowego | $\approx I_{wy}\sqrt{D(1 - D)}$ — maksimum przy $D = 0\text{,}5$ |

Typowy wybór: $\Delta I_L \approx$ 20–40% $I_{wy}$ — kompromis: mniejsze tętnienia = większy, wolniejszy dławik.

### Tryby pracy

- **CCM** (ciągły prąd dławika) — wzory powyżej.
- **DCM** (nieciągły) — przy małym obciążeniu, gdy $I_{wy} < \Delta I_L/2$, prąd spada do zera (w przetwornicy z diodą); napięcie wyjściowe zależy wtedy od obciążenia, zmienia się dynamika.
- Przetwornice synchroniczne mogą pracować w wymuszonym CCM (prąd ujemny) albo w trybach oszczędnych przy małym obciążeniu (pomijanie impulsów, PFM, burst) — wysoka sprawność przy małym prądzie kosztem tętnień o niskiej częstotliwości.

### Wybór częstotliwości przełączania

Wyższa $f_{sw}$: mniejsze L i C, szybsza odpowiedź; ale większe straty przełączania i w rdzeniu, ograniczenie minimalnego czasu załączenia ($t_{on,min} = D/f_{sw}$ — problem przy dużym stosunku napięć, np. 48 → 1 V). Typowo 300 kHz – 3 MHz w układach scalonych.

## Przykład rozwiązany

Buck 12 V → 3,3 V / 1 A, $f_{sw}$ = 500 kHz, tętnienia prądu ok. 30%, tętnienia napięcia ≤ 10 mV.

1. $D = 3\text{,}3/12 = 0\text{,}275$.
2. $L = \dfrac{8\text{,}7\cdot 0\text{,}275}{5\cdot 10^5\cdot 0\text{,}3} \approx 16$ µH → wybieramy **15 µH**; rzeczywiste $\Delta I_L = 0\text{,}319$ A, $I_{pk} \approx 1\text{,}16$ A → dławik o prądzie nasycenia ≥ ok. 1,5 A (zapas na rozruch i przeciążenie).
3. $C \geq \dfrac{0\text{,}319}{8\cdot 5\cdot 10^5\cdot 0\text{,}01} \approx 8$ µF → np. **2 × 10 µF** ceramiczne (uwaga: pojemność X5R/X7R spada pod napięciem stałym — sprawdź charakterystykę DC bias); przy ESR 5 mΩ składnik ESR to 1,6 mV.
4. Kondensator wejściowy: prąd skuteczny $1\cdot\sqrt{0\text{,}275\cdot 0\text{,}725} \approx 0\text{,}45$ A.
5. Granica CCM/DCM: $I_{wy} = \Delta I_L/2 \approx 0\text{,}16$ A.

## Typowe pułapki

- **Dławik w nasyceniu** przy prądzie szczytowym (rozruch, zwarcie) — prąd gwałtownie rośnie, tranzystor się uszkadza.
- **Nominalna pojemność ceramiki zamiast efektywnej** przy danym napięciu — tętnienia i stabilność inne niż w projekcie.
- **Za mały kondensator wejściowy lub daleko od klucza** — dzwonienie, przepięcia, zakłócenia (pętla prądu impulsowego — [15.07](07-termika-plytka-emi.md)).
- **Pomiar tętnień sondą z długą masą** — widać szpilki z indukcyjności sondy, nie z zasilacza ([08.03](../08-miernictwo/03-oscyloskop.md)).
- **Zbyt duży stosunek napięć przy wysokiej częstotliwości** — $t_{on}$ poniżej minimum układu.

## Ćwiczenie komputerowe

Symulacja przełączanej przetwornicy buck (idealne klucze, synchroniczna) — sprawdzenie wzorów na tętnienia:

```python
import numpy as np
import matplotlib.pyplot as plt

Vin, Vout_set, R = 12.0, 3.3, 3.3                  # obciążenie 1 A
L, C, ESR, fsw = 15e-6, 20e-6, 0.005, 500e3
D = Vout_set/Vin; T = 1/fsw; dt = T/400
iL, vC = 1.0, 3.3; tt, IL, VO = [], [], []
for k in range(int(3e-3/dt)):                       # 3 ms — aż wygasną drgania filtra LC
    t = k*dt
    vsw = Vin if (t % T) < D*T else 0.0
    vo = vC + ESR*(iL - vC/R)
    iL += dt*(vsw - vo)/L
    vC += dt*(iL - vC/R)/C
    if t > 3e-3 - 4*T: tt.append(t); IL.append(iL); VO.append(vo)     # ostatnie 4 okresy
IL, VO = np.array(IL), np.array(VO)
dI = (Vin - Vout_set)*D/(fsw*L)
print(f"tętnienia prądu: symulacja {IL.max() - IL.min():.3f} A, wzór {dI:.3f} A")
print(f"tętnienia napięcia: symulacja {(VO.max() - VO.min())*1e3:.2f} mV, "
      f"wzór {(dI/(8*fsw*C) + dI*ESR)*1e3:.2f} mV (suma składników — górne oszacowanie)")
print(f"średnie U_wy = {VO.mean():.3f} V, f0 filtra = {1/(2*np.pi*np.sqrt(L*C))/1e3:.1f} kHz")
plt.subplot(2, 1, 1); plt.plot(np.array(tt)*1e6, IL); plt.ylabel('i_L [A]'); plt.grid()
plt.subplot(2, 1, 2); plt.plot(np.array(tt)*1e6, VO); plt.ylabel('u_wy [V]'); plt.xlabel('t [µs]'); plt.grid(); plt.show()
```

Rozszerzenie: dodaj skok obciążenia i zobacz oscylacje filtra LC bez sprzężenia zwrotnego — powód, dla którego potrzebna jest pętla regulacji ([15.06](06-sterowanie-i-kompensacja.md)).

## Zadania

1. Buck 24 V → 5 V / 2 A, 400 kHz, tętnienia prądu 30%. Dobierz L i prąd nasycenia dławika.
2. Ten sam układ: kondensator wyjściowy dla tętnień 20 mV (ESR pomijalne). Jaki prąd skuteczny kondensatora wejściowego?
3. Poniżej jakiego prądu obciążenia przetwornica z zadania 1 (z diodą) wejdzie w DCM?
4. Przetwornica 48 V → 1 V przy 1 MHz. Ile wynosi czas załączenia? Czy układ o $t_{on,min}$ = 80 ns sobie poradzi?
5. Dlaczego tętnienia prądu w kondensatorze wejściowym buck są większe niż w wyjściowym?

<details>
<summary>Odpowiedzi</summary>

1. $D = 0\text{,}208$; $\Delta I = 0\text{,}6$ A → $L = 19\cdot 0\text{,}208/(4\cdot 10^5\cdot 0\text{,}6) \approx 16\text{,}5$ µH → np. 15–22 µH; $I_{pk} \approx 2\text{,}3$ A, $I_{sat}$ ≥ ok. 3 A
2. $C \geq 0\text{,}6/(8\cdot 4\cdot 10^5\cdot 0\text{,}02) \approx 9\text{,}4$ µF; $I_{Cin,rms} \approx 2\sqrt{0\text{,}208\cdot 0\text{,}792} \approx 0\text{,}81$ A
3. $I < \Delta I/2 = 0\text{,}3$ A
4. $t_{on} = D/f = (1/48)/10^6 \approx 21$ ns < 80 ns — nie; trzeba obniżyć częstotliwość (np. do 200 kHz → 104 ns) albo zastosować dwa stopnie
5. Prąd wejściowy jest impulsowy (prostokąt o amplitudzie ok. $I_{wy}$ przez czas $DT$), a wyjściowy kondensator widzi tylko trójkątne tętnienia dławika $\Delta I_L$
</details>

## Źródła

- [TI SLVA477 — Basic Calculation of a Buck Converter's Power Stage](https://www.ti.com/lit/pdf/SLVA477) — wzory doboru elementów
- [MIT 6.622 Power Electronics](https://ocw.mit.edu/courses/6-622-power-electronics-spring-2023/) — analiza przetwornic DC-DC, CCM/DCM
- [Introduction to Power Electronics — R. Erickson (Coursera)](https://www.coursera.org/learn/power-electronics) — bilans woltosekund i ładunku, analiza stanu ustalonego
- [LTspice](https://www.analog.com/en/resources/design-tools-and-calculators/ltspice-simulator.html) — modele przetwornic buck producentów
