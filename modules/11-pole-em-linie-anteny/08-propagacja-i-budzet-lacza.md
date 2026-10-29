# 11.08 — Propagacja fal radiowych i budżet łącza

## Po co to jest

„Jaki będzie zasięg?” — to pytanie zadaje każdy, kto projektuje urządzenie radiowe. Odpowiedź daje budżet łącza: bilans mocy nadajnika, zysków anten, strat propagacji i czułości odbiornika, z marginesem na zaniki. Do tego trzeba wiedzieć, jak fale rozchodzą się w rzeczywistym środowisku: nad ziemią, przez ściany, odbijając się od jonosfery.

## Teoria w pigułce

### Równanie Friisa

$$P_r = P_t G_t G_r\left(\frac{\lambda}{4\pi d}\right)^2,\qquad \text{w dB:}\quad P_r = P_t + G_t + G_r - L_{FS}$$

**Tłumienie wolnej przestrzeni** (FSPL):

$$L_{FS} = 20\log_{10}\frac{4\pi d}{\lambda} = 20\log_{10}d_{[\text{km}]} + 20\log_{10}f_{[\text{MHz}]} + 32\text{,}44\ \text{dB}$$

+6 dB przy podwojeniu odległości lub częstotliwości. Wzrost z częstotliwością wynika z mniejszej powierzchni skutecznej anten o stałym zysku — sama fala w próżni nie „słabnie bardziej” na wyższych częstotliwościach.

### Budżet łącza

$$\text{Margines} = P_t + G_t + G_r - L_{kabli} - L_{prop} - P_{czułość}$$

**Czułość odbiornika:** $P_{min} = -174\ \text{dBm/Hz} + 10\log B + NF + SNR_{min}$ ($-174$ dBm/Hz = $kT$ przy 290 K; szumy — [12.04](../12-technika-wcz-rf/04-szumy.md); wymagany SNR zależy od modulacji — [13](../13-telekomunikacja/)). Margines na zaniki: typowo 10–20 dB, w środowisku wielodrogowym więcej.

### Mechanizmy propagacji

| Mechanizm | Pasma | Uwagi |
|---|---|---|
| **Fala przyziemna (powierzchniowa)** | LF, MF (do ok. 3 MHz) | Ugina się wzdłuż powierzchni ziemi, zasięgi setek km; radiofonia AM |
| **Fala jonosferyczna** | HF (3–30 MHz) | Odbicie od jonosfery, zasięgi globalne, zależne od pory dnia i aktywności Słońca |
| **Fala bezpośrednia (LOS)** | VHF i wyżej | Ograniczona horyzontem radiowym: $d \approx 4\text{,}12(\sqrt{h_1} + \sqrt{h_2})$ km (h w m, dla współczynnika krzywizny 4/3) |
| Odbicie od ziemi (model dwupromieniowy) | VHF/UHF | Dla dużych odległości tłumienie rośnie jak $d^4$ (40 dB/dekadę) |
| Dyfrakcja | wszystkie | Ugięcie na krawędziach (budynki, wzgórza) |
| Rozpraszanie | wszystkie | Na obiektach mniejszych od λ, deszcz (powyżej ok. 10 GHz) |

### Strefa Fresnela

Elipsoida wokół linii bezpośredniej widoczności. Promień pierwszej strefy w punkcie odległym o $d_1$ i $d_2$ od końców:

$$r_1 = 17\text{,}32\sqrt{\frac{d_1d_2}{f\,d}}\ \text{m}\quad (d\ \text{w km},\ f\ \text{w GHz})$$

Wolne powinno być co najmniej ok. 60% pierwszej strefy — inaczej pojawia się dodatkowe tłumienie, nawet gdy anteny „się widzą”.

### Środowisko rzeczywiste

- **Modele empiryczne** (log-distance): $L(d) = L(d_0) + 10n\log(d/d_0)$; wykładnik $n = 2$ w wolnej przestrzeni, 2,7–3,5 w mieście, 4–6 wewnątrz budynków z przeszkodami.
- **Tłumienie ścian:** od kilku dB (drewno, płyta g-k) do 10–20 dB (żelbet) i więcej (szyby metalizowane) — rośnie z częstotliwością.
- **Wielodrogowość:** fale odbite sumują się z różnymi fazami → **zaniki szybkie** (zmiany o 20–30 dB na odległości λ/2); model Rayleigha (brak LOS), Rice'a (z LOS). Przeciwdziałanie: dywersyfikacja anten, korekcja kanału, OFDM ([13](../13-telekomunikacja/)).
- **Zaniki wolne (cień)** — przeszkody; rozkład log-normalny.

## Przykład rozwiązany

**Łącze Wi-Fi 2,4 GHz, 100 m, widoczność bezpośrednia:**

| Pozycja | Wartość |
|---|---|
| Moc nadajnika | +20 dBm |
| Zysk anten | +2 dBi + 2 dBi |
| FSPL (100 m, 2,4 GHz) | −80,0 dB |
| **Moc odbierana** | **−56 dBm** |
| Czułość dla szybkiej modulacji (przykład) | −70 dBm |
| Margines | 14 dB |

**Łącze LoRa 868 MHz, 3 km:** FSPL = 100,8 dB. Nadajnik 14 dBm, anteny 0 dBi, czułość odbiornika −137 dBm (wolne ustawienie modulacji) → margines ok. 50 dB w wolnej przestrzeni — w praktyce zjada go teren, budynki i wysokość anten. Promień pierwszej strefy Fresnela w połowie trasy: $17\text{,}32\sqrt{1\text{,}5\cdot 1\text{,}5/(0\text{,}868\cdot 3)} \approx 16$ m — anteny na wysokości 1,5 m nad ziemią są daleko od warunku wolnej strefy, stąd duże dodatkowe tłumienie.

## Typowe pułapki

- **FSPL zastosowane do łącza wewnątrz budynku** — rzeczywiste tłumienie o dziesiątki dB większe.
- **Pominięcie strat kabli i złączy** — przy 2,4 GHz kilka metrów cienkiego kabla to kilka dB.
- **Mylenie EIRP z mocą nadajnika** przy sprawdzaniu limitów regulacyjnych.
- **Brak marginesu na zaniki** — łącze działa przy testach, a „gubi pakiety” w eksploatacji.
- **Anteny nisko nad ziemią** — strefa Fresnela przesłonięta przez ziemię.

## Ćwiczenie komputerowe

Kalkulator budżetu łącza i zasięgu dla różnych wykładników tłumienia:

```python
import numpy as np

def fspl(d_m, f_hz):
    return 20*np.log10(4*np.pi*d_m*f_hz/299792458)

def sensitivity(B_hz, NF_db, snr_db):
    return -174 + 10*np.log10(B_hz) + NF_db + snr_db

def max_range(Pt, Gt, Gr, Lc, Psens, f, n=2.0, margin=10, d0=1.0):
    budget = Pt + Gt + Gr - Lc - Psens - margin          # dopuszczalne tłumienie trasy
    return d0*10**((budget - fspl(d0, f))/(10*n))

print(f"FSPL 2.4 GHz, 100 m: {fspl(100, 2.4e9):.1f} dB; 868 MHz, 3 km: {fspl(3e3, 868e6):.1f} dB")
Ps = sensitivity(125e3, 6, -20)                           # LoRa: SNR graniczny ok. -20 dB przy wolnym ustawieniu
print(f"czułość (125 kHz, NF 6 dB, SNR -20 dB): {Ps:.1f} dBm")
for n in [2.0, 2.7, 3.5]:
    print(f"n = {n}: zasięg ≈ {max_range(14, 0, 0, 1, Ps, 868e6, n)/1e3:8.2f} km")
r1 = 17.32*np.sqrt(1.5*1.5/(0.868*3))
print(f"promień 1. strefy Fresnela w połowie 3 km przy 868 MHz: {r1:.1f} m")
```

## Zadania

1. FSPL dla 433 MHz na 1 km i 5,8 GHz na 1 km.
2. Ile wynosi moc odbierana na 2,4 GHz w odległości 50 m przy $P_t = 0$ dBm i antenach 0 dBi?
3. Czułość odbiornika: pasmo 1 MHz, NF = 7 dB, wymagany SNR 10 dB.
4. Horyzont radiowy dla anten na 30 m i 2 m.
5. Zasięg łącza wewnątrz budynku z $n = 3\text{,}5$ jest X razy mniejszy niż w wolnej przestrzeni przy tym samym budżecie 100 dB (punkt odniesienia 1 m, 2,4 GHz). Oszacuj X.

<details>
<summary>Odpowiedzi</summary>

1. 85,2 dB i 107,7 dB
2. $L_{FS} = 74\text{,}0$ dB → −74 dBm
3. $-174 + 60 + 7 + 10 = -97$ dBm
4. $4\text{,}12(5\text{,}48 + 1\text{,}41) \approx 28$ km
5. Tłumienie na 1 m: 40 dB, pozostaje 60 dB: wolna przestrzeń $10^{60/20} = 1000$ m, $n = 3\text{,}5$: $10^{60/35} \approx 52$ m → ok. 19 razy mniej
</details>

## Źródła

- [Electromagnetics, Vol. 2 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-2) — równanie Friisa, propagacja, łącza radiowe
- [PySDR — rozdział Link Budgets](https://pysdr.org/content/link_budgets) — budżet łącza w praktyce, z przykładami
- [Fundamentals of Microwave and RF Design — M. Steer](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-microwave-and-rf-design) oraz [Microwave and RF Design: Radio Systems](https://open.umn.edu/opentextbooks/textbooks/microwave-and-rf-design-radio-systems) — systemy radiowe i propagacja
