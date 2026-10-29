# 12.04 — Szumy w torze w.cz.

## Po co to jest

Zasięg odbiornika jest ograniczony szumem: sygnał musi przewyższać szum o tyle, ile wymaga modulacja. Każdy element toru dodaje szum, ale najbardziej liczą się pierwsze stopnie. Współczynnik szumów i wzór Friisa pozwalają zaprojektować tor tak, by czułość była najlepsza przy rozsądnym koszcie.

## Teoria w pigułce

### Szum termiczny

Rezystor w temperaturze $T$ dostarcza do dopasowanego obciążenia moc szumu $P_n = kTB$ ($k = 1\text{,}38\cdot 10^{-23}$ J/K). Przy $T_0 = 290$ K: **−174 dBm/Hz** — przy paśmie 1 MHz −114 dBm, przy 20 MHz ok. −101 dBm. Szum termiczny jest biały i gaussowski ([06.08](../06-sygnaly-i-systemy/08-sygnaly-losowe.md)). Napięcie szumów rezystora (rozwarcie): $\sqrt{4kTRB}$ — [04.08](../04-uklady-analogowe/08-wzmacniacz-operacyjny-rzeczywisty.md).

### Współczynnik szumów

$$F = \frac{SNR_{we}}{SNR_{wy}}\ \ (\text{przy szumie źródła o } T_0 = 290\ \text{K}),\qquad NF = 10\log F$$

**Temperatura szumowa:** $T_e = T_0(F - 1)$. NF 1 dB ↔ 75 K, 3 dB ↔ 289 K. Temperatury wygodniejsze dla bardzo niskoszumowych torów (radioastronomia, satelity).

**Element stratny** (kabel, filtr, tłumik) w temperaturze $T_0$: $NF$ = tłumienie w dB. Kabel 2 dB przed LNA dodaje 2 dB do NF całego odbiornika.

### Wzór Friisa dla szumów

$$F_{cał} = F_1 + \frac{F_2 - 1}{G_1} + \frac{F_3 - 1}{G_1G_2} + \dots$$

(wartości liniowe). Wnioski:
- **pierwszy stopień decyduje** — powinien mieć małe NF i duże wzmocnienie;
- straty przed pierwszym wzmacniaczem (filtr, przełącznik, kabel) dodają się wprost do NF;
- duże wzmocnienie pierwszego stopnia ogranicza jednak zakres dynamiki (nieliniowość dalszych stopni — [12.05](05-nieliniowosc.md)) — kompromis.

### Czułość odbiornika

$$P_{min} = -174\ \text{dBm/Hz} + 10\log B + NF + SNR_{min}$$

$SNR_{min}$ (lub $E_b/N_0$) zależy od modulacji i kodowania ([13.05](../13-telekomunikacja/05-detekcja-i-ber.md)). Poziom szumu odniesiony do wejścia ($-174 + 10\log B + NF$) nazywa się progiem szumów (noise floor).

### Szum anteny

Antena „widzi” temperaturę otoczenia: ok. 290 K skierowana na ziemię, kilkadziesiąt K skierowana w niebo (powyżej ok. 1 GHz), dużo więcej na niskich częstotliwościach (szum atmosferyczny i przemysłowy na HF). Na pasmach HF szum zewnętrzny jest tak duży, że NF odbiornika rzędu 10 dB nie ma znaczenia; na mikrofalach liczy się każdy dziesiąty dB.

## Przykład rozwiązany

Tor: LNA ($G = 15$ dB, $NF = 1$ dB) → mieszacz ($G = -7$ dB, $NF = 7$ dB) → wzmacniacz p.cz. ($G = 20$ dB, $NF = 4$ dB).

1. Wartości liniowe: $F_1 = 1\text{,}259$, $G_1 = 31\text{,}6$; $F_2 = 5\text{,}01$, $G_2 = 0\text{,}2$; $F_3 = 2\text{,}51$.
2. $F = 1\text{,}259 + \dfrac{4\text{,}01}{31\text{,}6} + \dfrac{1\text{,}51}{31\text{,}6\cdot 0\text{,}2} = 1\text{,}259 + 0\text{,}127 + 0\text{,}239 = 1\text{,}625$ → **NF ≈ 2,1 dB**.
3. Z kablem 2 dB przed LNA: NF ≈ 4,1 dB. Bez LNA (mieszacz pierwszy): NF ≈ 8,2 dB.
4. Czułość dla $B = 1$ MHz i $SNR_{min} = 10$ dB: $-174 + 60 + 2\text{,}1 + 10 \approx -102$ dBm.

## Typowe pułapki

- **Sumowanie NF w dB** zamiast wartości liniowych we wzorze Friisa.
- **Filtr lub przełącznik przed LNA „bo tak wygodniej”** — każdy dB strat to dB czułości.
- **Pasmo szumowe pomylone z pasmem 3 dB** — dla filtrów niskiego rzędu pasmo szumowe jest większe ([06.08](../06-sygnaly-i-systemy/08-sygnaly-losowe.md)).
- **NF z karty katalogowej przy optymalnej impedancji źródła** — przy 50 Ω bez dopasowania może być wyraźnie gorzej.
- **Ignorowanie szumu fazowego generatora lokalnego** (mieszanie odwrotne — [12.07](07-mieszacze-i-oscylatory.md)), który może podnieść próg szumów bardziej niż NF.

## Ćwiczenie komputerowe

Kalkulator kaskady: NF, wzmocnienie i czułość, z analizą wpływu kolejności stopni:

```python
import numpy as np
lin = lambda db: 10**(db/10); db = lambda x: 10*np.log10(x)

def cascade_nf(stages):                          # stages: lista (nazwa, G_dB, NF_dB)
    F, G = 0.0, 1.0
    for i, (_, g, nf) in enumerate(stages):
        F += lin(nf) if i == 0 else (lin(nf) - 1)/G
        G *= lin(g)
    return db(F), db(G)

chain = [("LNA", 15, 1), ("mieszacz", -7, 7), ("p.cz.", 20, 4)]
for extra in [[], [("kabel", -2, 2)], [("filtr SAW", -2.5, 2.5)]]:
    nf, g = cascade_nf(extra + chain)
    print(f"{' + '.join(s[0] for s in extra + chain):40s} NF = {nf:5.2f} dB, G = {g:5.1f} dB")
for g_lna in [10, 15, 20, 25]:                          # wpływ wzmocnienia LNA na NF całości
    nf, _ = cascade_nf([("LNA", g_lna, 1)] + chain[1:])
    print(f"G_LNA = {g_lna} dB: NF = {nf:.2f} dB")
nf, _ = cascade_nf(chain)
for B, snr in [(10e3, 10), (1e6, 10), (20e6, 25)]:
    print(f"B = {B/1e6:6.2f} MHz, SNR = {snr} dB: czułość = {-174 + db(B) + nf + snr:7.1f} dBm")
print("temperatura szumowa NF=1 dB:", round(290*(lin(1) - 1), 1), "K")
```

## Zadania

1. Moc szumu termicznego w paśmie 200 kHz (w dBm).
2. Wzmacniacz o NF = 0,5 dB — jaka temperatura szumowa?
3. Policz NF kaskady: filtr (−1,5 dB), LNA (G = 18 dB, NF = 1,2 dB), mieszacz (G = −6 dB, NF = 8 dB), p.cz. (G = 25 dB, NF = 5 dB).
4. Odbiornik o NF = 6 dB, pasmo 125 kHz, wymagany SNR −20 dB (modulacja z rozpraszaniem widma). Jaka czułość?
5. Antena satelitarna ma temperaturę szumową 50 K, LNB ma NF = 0,3 dB. Jaka jest temperatura szumowa systemu? Co dałoby obniżenie NF do 0,2 dB?

<details>
<summary>Odpowiedzi</summary>

1. $-174 + 53 = -121$ dBm
2. $290(10^{0\text{,}05} - 1) \approx 35$ K
3. Licząc od filtra ($F_1 = 1\text{,}413$, $G_1 = 0\text{,}708$): $F = 1\text{,}413 + (1\text{,}318 - 1)/0\text{,}708 + (6\text{,}31 - 1)/(0\text{,}708\cdot 63\text{,}1) + (3\text{,}16 - 1)/(0\text{,}708\cdot 63\text{,}1\cdot 0\text{,}251) \approx 1\text{,}413 + 0\text{,}449 + 0\text{,}119 + 0\text{,}193 = 2\text{,}17$ → NF ≈ 3,4 dB
4. $-174 + 51 + 6 - 20 = -137$ dBm
5. $T_e = 290(10^{0\text{,}03} - 1) \approx 21$ K → $T_{sys} \approx 71$ K; przy 0,2 dB: $T_e \approx 14$ K, $T_{sys} \approx 64$ K — poprawa SNR o $10\log(71/64) \approx 0\text{,}45$ dB
</details>

## Źródła

- [Microwave and RF Design: Radio Systems — M. Steer](https://open.umn.edu/opentextbooks/textbooks/microwave-and-rf-design-radio-systems) — szumy, współczynnik szumów, kaskady
- [Fundamentals of Microwave and RF Design — M. Steer](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-microwave-and-rf-design)
- [PySDR — rozdział Link Budgets](https://pysdr.org/content/link_budgets) — szum i czułość w budżecie łącza
