# 12.06 — Wzmacniacze w.cz.: LNA i wzmacniacze mocy

## Po co to jest

Wzmacniacz małoszumowy (LNA) ustala czułość odbiornika, wzmacniacz mocy (PA) — zasięg i pobór energii nadajnika. Oba projektuje się z parametrów S tranzystora, ale z innymi celami: LNA — minimum szumów przy stabilności, PA — moc, sprawność i liniowość. Wzmacniacz w.cz., który nie jest stabilny przy każdym obciążeniu, prędzej czy później stanie się oscylatorem.

## Teoria w pigułce

### Definicje wzmocnienia

| Wzmocnienie | Opis |
|---|---|
| Przetwornikowe $G_T$ | Moc w obciążeniu / moc dostępna ze źródła — „rzeczywiste” w układzie |
| Dostępne $G_A$ | Moc dostępna z wyjścia / moc dostępna ze źródła — używane przy projektowaniu szumowym |
| Robocze $G_P$ | Moc w obciążeniu / moc wpływająca do wejścia — używane przy projektowaniu mocy |
| $|S_{21}|^2$ | Przetwornikowe przy zakończeniach 50 Ω |

### Stabilność

Wzmacniacz może oscylować, gdy $|\Gamma_{we}| > 1$ lub $|\Gamma_{wy}| > 1$ dla pewnych impedancji źródła/obciążenia (sprzężenie zwrotne przez $S_{12}$). **Bezwarunkowa stabilność** (stabilny przy każdym biernym źródle i obciążeniu) — kryterium Rolleta:

$$K = \frac{1 - |S_{11}|^2 - |S_{22}|^2 + |\Delta|^2}{2|S_{12}S_{21}|} > 1\quad \text{i}\quad |\Delta| < 1,\qquad \Delta = S_{11}S_{22} - S_{12}S_{21}$$

Równoważnie jeden parametr $\mu > 1$ (kryterium Edwardsa–Sinsky'ego). **Sprawdzaj w całym zakresie częstotliwości**, w którym tranzystor ma wzmocnienie — także daleko poza pasmem pracy (niskie częstotliwości, gdzie wzmocnienie tranzystora jest duże). Przy warunkowej stabilności: okręgi stabilności na wykresie Smitha, stabilizacja rezystorem (szeregowo w bramce, równolegle na wyjściu), sprzężenie zwrotne.

**Maksymalne dostępne wzmocnienie** (przy $K > 1$, z jednoczesnym dopasowaniem sprzężonym obu wrót):

$$MAG = \left|\frac{S_{21}}{S_{12}}\right|\left(K - \sqrt{K^2 - 1}\right)$$

### Wzmacniacz małoszumowy

Współczynnik szumów zależy od impedancji źródła: minimum $NF_{min}$ przy $\Gamma_{opt}$ (dane w karcie katalogowej). Okręgi stałego NF i stałego wzmocnienia na wykresie Smitha — projekt to kompromis między nimi i dopasowaniem wejścia. Techniki: degeneracja indukcyjna źródła (zbliża optimum szumowe do dopasowania mocy), sprzężenie zwrotne. Gotowe LNA w postaci układów scalonych (MMIC) są dopasowane do 50 Ω.

### Wzmacniacze mocy

| Klasa | Kąt przewodzenia | Sprawność maks. (teoretyczna) | Liniowość | Zastosowanie |
|---|---|---|---|---|
| A | 360° | 50% | Najlepsza | Stopnie sterujące, małe moce, liniowe |
| AB | 180–360° | 50–78,5% | Dobra | Modulacje liniowe (QAM, OFDM) |
| B | 180° | 78,5% | Zniekształcenia skrośne (w przeciwsobnym) | |
| C | < 180° | → 100% | Słaba | FM, modulacje o stałej obwiedni |
| D, E, F | Kluczowanie | 90%+ (praktycznie 70–90%) | Wymaga linearyzacji/technik obwiedni | Wysoka sprawność |

**PAE** (sprawność mocy dodanej) $= (P_{wy} - P_{we})/P_{DC}$. **Load-pull:** impedancja obciążenia dla maksymalnej mocy (nie jest sprzężeniem $S_{22}$!) — w pierwszym przybliżeniu $R_{opt} \approx (V_{DD} - V_{knee})^2/(2P_{wy})$. Linearyzacja: cofnięcie od nasycenia, predystorsja cyfrowa (DPD), architektury Doherty'ego, śledzenie obwiedni.

## Przykład rozwiązany

Tranzystor przy 4 GHz: $S_{11} = 0{,}61\angle 165°$, $S_{21} = 3{,}72\angle 59°$, $S_{12} = 0{,}05\angle 42°$, $S_{22} = 0{,}45\angle -48°$.

1. $|\Delta| \approx 0{,}109 < 1$.
2. $K = \dfrac{1 - 0{,}372 - 0{,}203 + 0{,}012}{2\cdot 0{,}05\cdot 3{,}72} \approx 1{,}18 > 1$ — **bezwarunkowo stabilny** (przy tej częstotliwości).
3. $|S_{21}|^2 = 11{,}4$ dB (przy 50 Ω); $MAG \approx 16{,}2$ dB — dopasowanie obu wrót daje prawie 5 dB więcej.

**PA:** $P_{wy} = 1$ W, $P_{we} = 10$ mW, $P_{DC} = 2{,}5$ W → PAE ≈ 39,6%; z zasilania 3,6 V w przybliżeniu $R_{opt} \approx (3{,}6 - 0{,}3)^2/2 \approx 5{,}4\ \Omega$ — potrzebna transformacja do 50 Ω z $Q \approx 2{,}9$.

## Typowe pułapki

- **Stabilność sprawdzona tylko w paśmie pracy** — oscylacje na kilkudziesięciu MHz lub na kilku GHz.
- **LNA dopasowany do maksimum wzmocnienia** — NF wyraźnie powyżej $NF_{min}$.
- **Obwód polaryzacji (dławik, kondensatory)** tworzący rezonanse poza pasmem.
- **PA dopasowany do $S_{22}^*$** zamiast do optymalnej impedancji obciążenia z load-pull.
- **Odłączenie anteny od pracującego PA** — pełne odbicie, przegrzanie lub przebicie tranzystora (stosuje się izolatory, zabezpieczenia WFS).

## Ćwiczenie komputerowe

Stabilność (K, Δ, μ) i MAG w funkcji częstotliwości z danych S (w praktyce — z pliku .s2p przez scikit-rf):

```python
import numpy as np

pol = lambda m, a: m*np.exp(1j*np.radians(a))
data = {   # f [GHz]: S11, S21, S12, S22 (przykładowy tranzystor)
    1.0: (pol(0.85, -60), pol(8.0, 130), pol(0.03, 60), pol(0.70, -30)),
    2.0: (pol(0.72, 120), pol(5.5, 90), pol(0.04, 50), pol(0.55, -40)),
    4.0: (pol(0.61, 165), pol(3.72, 59), pol(0.05, 42), pol(0.45, -48)),
}
for f, (S11, S21, S12, S22) in data.items():
    D = S11*S22 - S12*S21
    K = (1 - abs(S11)**2 - abs(S22)**2 + abs(D)**2)/(2*abs(S12*S21))
    mu = (1 - abs(S11)**2)/(abs(S22 - D*np.conj(S11)) + abs(S12*S21))
    msg = 10*np.log10(abs(S21/S12))
    mag = 10*np.log10(abs(S21/S12)*(K - np.sqrt(K**2 - 1))) if K > 1 else None
    state = "bezwarunkowo stabilny" if (K > 1 and abs(D) < 1) else "WARUNKOWO stabilny"
    print(f"{f} GHz: K={K:.3f}, |Δ|={abs(D):.3f}, μ={mu:.3f} -> {state}; "
          f"|S21|²={20*np.log10(abs(S21)):.1f} dB, " + (f"MAG={mag:.1f} dB" if mag else f"MSG={msg:.1f} dB"))
```

## Zadania

1. Policz K i |Δ| dla tranzystora z przykładu. Czy jest bezwarunkowo stabilny?
2. Dlaczego tranzystor bywa warunkowo stabilny na niskich częstotliwościach, a bezwarunkowo na wysokich?
3. PA: 2 W wyjścia, wzmocnienie 12 dB, pobór 6 W. Ile wynosi PAE i sprawność drenu?
4. Szacunkowa optymalna rezystancja obciążenia PA 5 W zasilanego z 28 V ($V_{knee}$ = 2 V).
5. Dlaczego do sygnału OFDM o PAPR 10 dB wzmacniacz musi pracować z dużym cofnięciem i jaki to ma wpływ na sprawność?

<details>
<summary>Odpowiedzi</summary>

1. $K \approx 1{,}18$, $|\Delta| \approx 0{,}11$ — tak (przy 4 GHz)
2. Na niskich częstotliwościach $|S_{21}|$ jest duże, a sprzężenie zwrotne przez $S_{12}$ i pojemności — wystarczające do niestabilności przy pewnych obciążeniach; na wysokich wzmocnienie spada, więc pętla sprzężenia ma za mały zysk
3. $P_{we} = 2/15{,}85 = 0{,}126$ W; PAE = $(2 - 0{,}126)/6 \approx 31\%$; sprawność drenu $2/6 \approx 33\%$
4. $(28 - 2)^2/(2\cdot 5) \approx 68\ \Omega$
5. Szczyty sygnału są 10 dB powyżej średniej i nie mogą wchodzić w kompresję (zniekształcenia, widmo w sąsiednich kanałach, EVM) — średnia moc jest dużo poniżej nasycenia, gdzie sprawność klasy AB jest mała (np. 10–20%); stąd DPD, Doherty i śledzenie obwiedni
</details>

## Źródła

- [Keysight AN 154 — S-Parameter Design](https://www.keysight.com/be/en/assets/7018-06743/application-notes/5952-1087.pdf) — stabilność, projektowanie wzmacniaczy z parametrów S
- [Fundamentals of Microwave and RF Design — M. Steer](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-microwave-and-rf-design) — wzmacniacze, stabilność
- [Microwave and RF Design: Radio Systems — M. Steer](https://open.umn.edu/opentextbooks/textbooks/microwave-and-rf-design-radio-systems) — wzmacniacze mocy i liniowość w systemach
- Karty katalogowe tranzystorów i MMIC w.cz. (parametry S, $NF_{min}$, $\Gamma_{opt}$, dane load-pull)
