# 14.02 — Warstwa fizyczna i telekomunikacja światłowodowa

## Po co to jest

Prawie cały ruch internetowy na dłuższych odcinkach biegnie światłowodami — od kabli podmorskich po przyłącza FTTH. Światłowód ma pasmo i zasięg nieosiągalne dla miedzi, ale ma własne ograniczenia: tłumienie, dyspersję i nieliniowości. Inżynier telekomunikacji musi umieć policzyć budżet mocy łącza optycznego i ocenić, czy dyspersja pozwoli na zadaną przepływność.

## Teoria w pigułce

### Media transmisyjne

| Medium | Pasmo / przepływność | Zasięg | Uwagi |
|---|---|---|---|
| Skrętka (kat. 5e–8) | do 1–40 Gbit/s | 100 m (30 m dla 25/40G) | Pary różnicowe, Ethernet, PoE |
| Kabel koncentryczny | GHz | km (ze wzmacniaczami) | Sieci kablowe (DOCSIS) |
| Para telefoniczna | do ok. 100 Mbit/s–1 Gbit/s na krótkich odcinkach | km | xDSL, G.fast |
| **Światłowód jednomodowy** | Tbit/s (WDM) | dziesiątki km bez wzmacniaczy, tysiące ze wzmacniaczami | Sieci szkieletowe, dostępowe |
| Światłowód wielomodowy | do 100–400 Gbit/s na krótkich odcinkach | setki m | Centra danych |
| Radio | Mbit/s–Gbit/s | m–km | [13.08](../13-telekomunikacja/08-kanal-radiowy-i-systemy.md), [14.07](07-sieci-komorkowe-i-iot.md) |

### Światłowód

Rdzeń o współczynniku załamania nieco większym niż płaszcz — **całkowite wewnętrzne odbicie** ([11.02](../11-pole-em-linie-anteny/02-fale-plaskie.md)). Apertura numeryczna $NA = \sqrt{n_1^2 - n_2^2}$.
- **Jednomodowy (SMF)** — rdzeń ok. 9 µm, jeden rodzaj fali (jak falowód poniżej odcięcia wyższych rodzajów — [11.06](../11-pole-em-linie-anteny/06-linie-praktyczne-i-falowody.md)); brak dyspersji modowej.
- **Wielomodowy (MMF)** — rdzeń 50/62,5 µm, tańsze źródła (VCSEL), ograniczony dyspersją modową.

**Okna transmisyjne:** 850 nm (MMF), **1310 nm** (ok. 0,35 dB/km, zerowa dyspersja chromatyczna w zwykłym SMF), **1550 nm** (ok. 0,2 dB/km — minimum tłumienia, pasmo wzmacniaczy EDFA).

### Dyspersja

- **Modowa** (MMF): różne drogi promieni.
- **Chromatyczna:** prędkość zależy od długości fali; współczynnik $D$ w ps/(nm·km) — w zwykłym SMF przy 1550 nm ok. 17 ps/(nm·km). Poszerzenie impulsu $\Delta\tau = D\cdot L\cdot\Delta\lambda$.
- **Polaryzacyjna (PMD)** — znacząca przy 40G+.

Rozmycie impulsu porównywalne z czasem bitu daje ISI ([13.03](../13-telekomunikacja/03-pasmo-podstawowe-i-isi.md)). Przeciwdziałanie: lasery wąskopasmowe (DFB), praca przy 1310 nm, światłowody kompensujące, cyfrowa kompensacja w odbiornikach koherentnych.

### Nadajniki i odbiorniki

| Element | Rodzaje | Cechy |
|---|---|---|
| Źródło | LED, VCSEL, laser Fabry–Pérot, **DFB** | Szerokość widma, moc, szybkość modulacji |
| Modulacja | Bezpośrednia (prąd lasera), zewnętrzna (modulator Macha–Zehndera) | Do ok. 10–25 Gbaud bezpośrednio; dalej zewnętrzna |
| Detektor | Fotodioda **PIN**, **APD** (lawinowa — wewnętrzne wzmocnienie) | Czułość (dBm przy danym BER), pasmo |
| Formaty | NRZ, PAM-4, koherentne QPSK/16-QAM z polaryzacją podwójną | 100G–800G+ |

Moduły wymienne (SFP, SFP+, QSFP) zawierają nadajnik i odbiornik; parametry: moc nadawania, czułość, długość fali, zasięg.

### Multipleksacja falowa (WDM)

Wiele długości fali w jednym włóknie: **CWDM** (odstęp 20 nm, tanie, do 18 kanałów), **DWDM** (siatka 100/50 GHz, dziesiątki–ok. 100 kanałów w paśmie C). Wzmacniacz **EDFA** wzmacnia całe pasmo naraz bez przetwarzania elektrycznego.

### Budżet mocy

$$P_{nad} - P_{czułość} \geq \alpha L + n_zL_z + n_sL_s + M$$

($\alpha$ — tłumienie [dB/km], $L_z$ — złącze ok. 0,3–0,75 dB, $L_s$ — spaw ok. 0,1 dB, $M$ — margines 3 dB). Za dużo mocy też szkodzi — trzeba sprawdzić **maksymalną moc odbiornika** (przesterowanie; na krótkich odcinkach stosuje się tłumik).

## Przykład rozwiązany

Łącze 40 km, 1310 nm, moduł: nadajnik 0 dBm, czułość −28 dBm.

| Pozycja | Strata |
|---|---|
| Włókno $40\cdot 0\text{,}35$ | 14 dB |
| 4 złącza × 0,5 dB | 2 dB |
| 10 spawów × 0,1 dB | 1 dB |
| Margines | 3 dB |
| **Razem** | **20 dB** |

Dostępne 28 dB → zapas 8 dB. **Dyspersja** przy 1550 nm na 100 km z laserem o szerokości 0,1 nm: $17\cdot 100\cdot 0\text{,}1 = 170$ ps — więcej niż czas bitu przy 10 Gbit/s (100 ps): bez kompensacji łącze nie zadziała; przy 1 Gbit/s (1 ns) — bez problemu.

## Typowe pułapki

- **Patrzenie w światłowód lub złącze z aktywnym laserem** — trwałe uszkodzenie wzroku (promieniowanie niewidzialne przy 1310/1550 nm).
- **Brudne złącza** — najczęstsza przyczyna awarii; czyszczenie i inspekcja przed każdym połączeniem.
- **Mieszanie typów złączy (UPC/APC)** — duże straty i odbicia.
- **Budżet bez sprawdzenia mocy maksymalnej odbiornika.**
- **Moduł wielomodowy na włóknie jednomodowym** (i odwrotnie).

## Ćwiczenie komputerowe

Budżet mocy i limit dyspersyjny łącza:

```python
import numpy as np

def budget(L_km, alpha, n_conn, l_conn, n_spl, l_spl, margin):
    return L_km*alpha + n_conn*l_conn + n_spl*l_spl + margin

Ptx, Psens, Pmax = 0, -28, -3
loss = budget(40, 0.35, 4, 0.5, 10, 0.1, 3)
print(f"straty z marginesem: {loss:.1f} dB, zapas: {Ptx - Psens - loss:.1f} dB, moc odbierana: {Ptx - loss + 3:.1f} dBm")
L_max = (Ptx - Psens - 4*0.5 - 3)/(0.35 + 0.1/4)          # spaw co 4 km
print(f"maksymalny zasięg przy 1310 nm (tylko tłumienie): {L_max:.0f} km")

D = 17                                                        # ps/(nm km) przy 1550 nm
for R in [1e9, 10e9, 25e9]:
    for dl in [0.1, 1.0]:
        L_disp = 0.5/(R*D*1e-12*dl)                           # rozmycie <= połowa czasu bitu
        print(f"R = {R/1e9:4.0f} Gbit/s, szerokość źródła {dl} nm: limit dyspersyjny ≈ {L_disp:8.1f} km")
```

## Zadania

1. Policz zapas mocy łącza 60 km przy 1550 nm (0,22 dB/km), 2 złącza po 0,5 dB, spawy co 2 km po 0,05 dB, margines 3 dB, nadajnik +2 dBm, czułość −24 dBm.
2. Dlaczego sieci szkieletowe pracują przy 1550 nm, mimo że przy 1310 nm dyspersja chromatyczna jest bliska zeru?
3. Ile wynosi apertura numeryczna dla $n_1 = 1\text{,}468$, $n_2 = 1\text{,}462$?
4. Łącze 2 km ma nadajnik −1 dBm i odbiornik o mocy maksymalnej −8 dBm. Czego brakuje?
5. Ile kanałów DWDM o odstępie 50 GHz mieści pasmo C (ok. 1530–1565 nm, czyli ok. 4,4 THz)?

<details>
<summary>Odpowiedzi</summary>

1. Straty: $13\text{,}2 + 1 + 30\cdot 0\text{,}05 + 3 = 18\text{,}7$ dB; dostępne 26 dB → zapas ok. 7,3 dB
2. Najmniejsze tłumienie (dłuższe odcinki bez regeneracji) i pasmo wzmacniaczy EDFA umożliwiające WDM; dyspersję kompensuje się optycznie lub cyfrowo
3. $\sqrt{1\text{,}468^2 - 1\text{,}462^2} \approx 0\text{,}133$
4. Tłumika (ok. 5–10 dB) — przy krótkim łączu odbierana moc przekracza dopuszczalną
5. ok. 88 kanałów
</details>

## Źródła

- [The Fiber Optic Association — Guide to Fiber Optics](https://www.thefoa.org/tech/ref/) — włókna, złącza, budżet łącza, testowanie
- [Electromagnetics, Vol. 2 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-2) — światłowody jako falowody dielektryczne
- [Computer Networks: A Systems Approach — Peterson, Davie](https://github.com/SystemsApproach/book) — łącza fizyczne i kodowanie
