# 15.04 — Dobór elementów, straty i sprawność

## Po co to jest

Wzory na wypełnienie i tętnienia mówią, jaka przetwornica ma być, ale dopiero dobór konkretnych elementów decyduje, czy będzie działać sprawnie i niezawodnie. Dławik w nasyceniu, kondensator, który się przegrzewa, tranzystor o zbyt wolnych zboczach — to najczęstsze przyczyny problemów. Bilans strat pozwala przewidzieć sprawność i temperaturę jeszcze przed zbudowaniem prototypu.

## Teoria w pigułce

### Dławik

| Parametr | Na co uważać |
|---|---|
| Indukcyjność | Spada z prądem stałym i temperaturą (krzywa w nocie) |
| **Prąd nasycenia** $I_{sat}$ | Musi przewyższać prąd szczytowy w najgorszym przypadku (rozruch, przeciążenie, ograniczenie prądowe układu) |
| Prąd znamionowy (cieplny) $I_{rms}$ | Przyrost temperatury (np. 40 K) przy danym prądzie skutecznym |
| **DCR** | Straty $I_{rms}^2\cdot DCR$ |
| Straty w rdzeniu | Zależne od tętnień $\Delta I$ i częstotliwości (ferryt — małe przy wysokich częstotliwościach; proszkowe — miękkie nasycenie, większe straty) |
| Ekranowanie | Dławiki ekranowane — mniejsze pole rozproszone (EMI) |

Energia zmagazynowana $\tfrac12LI^2$ wyznacza rozmiar rdzenia.

### Kondensatory

| Typ | Cechy | Zastosowanie |
|---|---|---|
| Ceramiczne X5R/X7R (MLCC) | Bardzo małe ESR i ESL, duży prąd tętnień; **pojemność spada z napięciem DC** (nawet o 50–80%) i temperaturą | Wejście i wyjście przetwornic |
| Polimerowe (Al, tantalowe) | Średnie ESR, stabilna pojemność, duże wartości | Wyjście przy dużych skokach obciążenia |
| Elektrolityczne aluminiowe | Duże pojemności tanio; duże ESR, ograniczona trwałość (podwaja się przy każdym spadku temperatury o 10 K) | Wejście zasilaczy sieciowych, magazyn energii |

Dobór: pojemność **efektywna** przy napięciu pracy, prąd tętnień (rms), ESR (tętnienia i stabilność), napięcie znamionowe z zapasem.

### Tranzystor MOSFET

**Straty przewodzenia:** $P_{cond} = I_{rms}^2R_{DS(on)}$ (dla buck: klucz górny $\approx I_{wy}^2R_{DS(on)}D$); $R_{DS(on)}$ rośnie z temperaturą (ok. 1,5× przy 100 °C).

**Straty przełączania** (przybliżenie liniowe):

$$P_{sw} \approx \tfrac12 U_{we}I(t_r + t_f)f_{sw} + \tfrac12 C_{oss}U_{we}^2f_{sw}$$

Czasy przełączania zależą od ładunku bramki $Q_g$ (szczególnie $Q_{gd}$ — „plateau Millera”) i prądu sterownika. **Straty sterowania bramki:** $P_g = Q_gU_{GS}f_{sw}$ (w sterowniku).

Kompromis: mniejsze $R_{DS(on)}$ = większy tranzystor = większe $Q_g$ i $C_{oss}$. Wskaźnik jakości: $R_{DS(on)}\cdot Q_g$. Klucz górny przy NMOS wymaga napięcia bramki powyżej wejścia — **bootstrap** (dioda + kondensator ładowany w czasie przewodzenia klucza dolnego).

### Dioda i prostowanie synchroniczne

Dioda Schottky'ego: $P = U_FI_{wy}(1 - D)$ — przy niskim napięciu wyjściowym dominująca strata (0,4 V przy 3,3 V to 12%). **Prostowanie synchroniczne** (tranzystor zamiast diody): $P = I^2R_{DS(on)}(1 - D)$ + straty w czasie martwym (przewodzi dioda podłożowa) i odzyskiwania ładunku. Szerokoprzerwowe tranzystory **GaN** i **SiC** — mniejsze ładunki i brak odzyskiwania (GaN) → wyższe częstotliwości i sprawności przy wysokich napięciach.

### Sprawność

$$\eta = \frac{P_{wy}}{P_{wy} + \sum P_{strat}}$$

Krzywa sprawności w funkcji prądu: przy małych prądach dominują straty stałe (sterowanie, przełączanie, prąd spoczynkowy), przy dużych — przewodzenia ($I^2R$). Maksimum zwykle przy 30–70% prądu znamionowego.

## Przykład rozwiązany

Buck 12 V → 3,3 V / 1 A, 500 kHz (z [15.02](02-przetwornica-buck.md)), klucz $R_{DS(on)} = 50$ mΩ, $t_r + t_f = 40$ ns, dioda Schottky 0,4 V, dławik DCR 50 mΩ.

| Strata | Obliczenie | Moc |
|---|---|---|
| Przewodzenie klucza | $1^2\cdot 0\text{,}05\cdot 0\text{,}275$ | 14 mW |
| Przełączanie klucza | $0\text{,}5\cdot 12\cdot 1\cdot 40\cdot 10^{-9}\cdot 5\cdot 10^5$ | 120 mW |
| Dioda | $0\text{,}4\cdot 1\cdot 0\text{,}725$ | 290 mW |
| Dławik (DCR) | $1^2\cdot 0\text{,}05$ | 50 mW |
| **Razem** | | **≈ 0,47 W** → $\eta \approx 87\text{,}5\%$ |

**Wersja synchroniczna** (klucz dolny 30 mΩ): dioda → $1^2\cdot 0\text{,}03\cdot 0\text{,}725 \approx 22$ mW; razem ok. 0,21 W → **η ≈ 94%**. Wniosek: przy niskich napięciach wyjściowych prostowanie synchroniczne jest kluczowe.

## Typowe pułapki

- **Ceramika 10 µF/6,3 V na 5 V** — efektywnie może mieć 3–4 µF.
- **Dławik dobrany na prąd średni** zamiast szczytowy.
- **Straty przełączania liczone z czasami z noty przy innym prądzie bramki** — realne czasy zależą od sterownika i indukcyjności pętli.
- **Pominięcie strat sterowania bramki i czasu martwego** przy wysokich częstotliwościach.
- **Sprawność „z noty” przy innym napięciu wejściowym i dławiku** niż w projekcie.

## Ćwiczenie komputerowe

Bilans strat i krzywa sprawności w funkcji prądu dla wersji z diodą i synchronicznej:

```python
import numpy as np
import matplotlib.pyplot as plt

Vin, Vout, fsw = 12.0, 3.3, 500e3
D = Vout/Vin; Rhs, Rls, tsw, Vf, DCR, Qg, Vg, Iq = 0.05, 0.03, 40e-9, 0.4, 0.05, 10e-9, 5.0, 2e-3

def losses(I, sync):
    p = I**2*Rhs*D + 0.5*Vin*I*tsw*fsw + I**2*DCR + Qg*Vg*fsw + Vin*Iq
    p += (I**2*Rls*(1 - D) + Qg*Vg*fsw) if sync else Vf*I*(1 - D)
    return p
I = np.linspace(0.02, 2, 200)
for sync, lab in [(False, 'dioda Schottky'), (True, 'synchroniczna')]:
    eta = Vout*I/(Vout*I + losses(I, sync))
    plt.plot(I, eta*100, label=lab)
    print(f"{lab:15s}: η(1 A) = {100*Vout/(Vout + losses(1.0, sync)):.1f}%, η(0,05 A) = "
          f"{100*Vout*0.05/(Vout*0.05 + losses(0.05, sync)):.1f}%, maksimum przy {I[np.argmax(eta)]:.2f} A")
plt.xlabel('I_wy [A]'); plt.ylabel('η [%]'); plt.legend(); plt.grid(); plt.show()
```

Skrypt uwzględnia dodatkowo sterowanie bramek ($Q_gU_{GS}f_{sw}$) i prąd spoczynkowy układu, dlatego sprawności wychodzą o 1–2 punkty procentowe niższe niż w tabeli z przykładu — i dlatego przy małych prądach sprawność spada.

## Zadania

1. Dławik 10 µH, prąd średni 3 A, tętnienia 0,9 A. Jaki minimalny prąd nasycenia z zapasem 20%?
2. MOSFET: $Q_g$ = 20 nC, napięcie bramki 10 V, 300 kHz. Jaka moc sterowania bramki?
3. Kondensator 22 µF/10 V X5R ma przy 5 V efektywnie 40% pojemności. Ile wynosi i jak to zmienia tętnienia?
4. Przetwornica buck 5 V → 1,2 V / 3 A z diodą 0,35 V. Jaki procent mocy wyjściowej tracony jest w samej diodzie?
5. Dlaczego sprawność przetwornicy spada przy bardzo małym obciążeniu i jak się temu przeciwdziała?

<details>
<summary>Odpowiedzi</summary>

1. $I_{pk} = 3\text{,}45$ A → $I_{sat} \geq 4\text{,}1$ A
2. $20\cdot 10^{-9}\cdot 10\cdot 3\cdot 10^5 = 60$ mW
3. ok. 8,8 µF — tętnienia od pojemności rosną ok. 2,5 raza, zmienia się też położenie bieguna filtra LC (stabilność)
4. $D \approx 0\text{,}24$: $0\text{,}35\cdot 3\cdot 0\text{,}76 \approx 0\text{,}8$ W wobec 3,6 W → ok. 22%
5. Straty stałe (przełączanie, sterowanie, prąd spoczynkowy) nie maleją z obciążeniem; przeciwdziałanie: tryby PFM/pomijanie impulsów/burst, obniżanie częstotliwości, wyłączanie faz w przetwornicach wielofazowych
</details>

## Źródła

- [TI SLVA477 — Basic Calculation of a Buck Converter's Power Stage](https://www.ti.com/lit/pdf/SLVA477) — dobór dławika i kondensatorów
- [MIT 6.622 Power Electronics](https://ocw.mit.edu/courses/6-622-power-electronics-spring-2023/) — elementy magnetyczne, straty w przyrządach
- [Introduction to Power Electronics — R. Erickson (Coursera)](https://www.coursera.org/learn/power-electronics) — modelowanie strat i sprawności
- Noty producentów kondensatorów ceramicznych (charakterystyka DC bias) i dławików (krzywe nasycenia)
