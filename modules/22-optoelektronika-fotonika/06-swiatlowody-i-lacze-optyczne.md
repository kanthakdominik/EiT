# 22.06 — Światłowody i łącze optyczne

## Po co to jest

Światłowód przenosi praktycznie cały ruch internetowy: od sieci szkieletowych i podmorskich po FTTH i połączenia w centrach danych ([14.02](../14-sieci-telekomunikacyjne/02-warstwa-fizyczna-i-swiatlowody.md), [14.06](../14-sieci-telekomunikacyjne/06-sieci-dostepowe-i-szkieletowe.md)). Projekt łącza sprowadza się do dwóch pytań: czy dotrze **wystarczająco dużo mocy** (budżet tłumienia) i czy impulsy **nie rozmyją się** zanadto (dyspersja). W elektronice światłowody i transoptory światłowodowe służą też do izolacji przy wysokich napięciach i w silnych zakłóceniach.

## Teoria w pigułce

### Prowadzenie światła

- Rdzeń o współczynniku załamania $n_1$ w płaszczu $n_2 < n_1$ — całkowite wewnętrzne odbicie.
- **Apertura numeryczna:** $\mathrm{NA} = \sqrt{n_1^2 - n_2^2} = \sin\theta_{max}$ — kąt akceptacji wiązki.
- **Wielomodowy** (rdzeń 50 lub 62,5 µm, 850/1300 nm) — łatwe sprzęganie, tanie źródła (LED, VCSEL), zasięg setki metrów przy Gb/s.
- **Jednomodowy** (rdzeń ok. 9 µm, 1310/1550 nm) — zasięg dziesiątki–setki km, wymaga laserów.
- **Plastikowy (POF)** — rdzeń 1 mm, 650 nm, tłumienie ok. 0,15–0,2 dB/m; automatyka, audio, krótkie łącza.

### Tłumienie

| Światłowód / okno | Tłumienie typowe |
|---|---|
| Wielomodowy 850 nm | 2,5–3,5 dB/km |
| Jednomodowy 1310 nm | 0,3–0,4 dB/km |
| Jednomodowy 1550 nm | 0,18–0,25 dB/km |
| Złącze | 0,2–0,75 dB |
| Spaw | 0,05–0,1 dB |

### Dyspersja

- **Międzymodowa** (wielomodowy skokowy): różne drogi promieni; $\Delta t/L \approx \dfrac{n_1}{c}\left(\dfrac{n_1}{n_2} - 1\right)$. Światłowody gradientowe zmniejszają ją ok. 100 razy — producent podaje **pasmo modowe** [MHz·km].
- **Chromatyczna** (jednomodowy): $\Delta t = D\cdot\Delta\lambda\cdot L$, $D \approx 17$ ps/(nm·km) przy 1550 nm, ok. 0 przy 1310 nm.
- Kryterium: poszerzenie impulsu mniejsze niż ok. 1/4–1/2 czasu bitu.

### Budżet mocy

$$P_{odb} = P_{nad} - \alpha L - n_zL_z - n_sL_s - \text{(straty innych elementów)} \geq S_{odb} + M$$

$S_{odb}$ — czułość odbiornika (np. −20 dBm dla BER $10^{-12}$), $M$ — margines na starzenie, naprawy, temperaturę (3–6 dB). Za mocny sygnał też szkodzi — **przesterowanie** odbiornika przy krótkich łączach (tłumik).

## Przykład rozwiązany

**Łącze jednomodowe 1310 nm, 20 km:** nadajnik −3 dBm, tłumienie 0,35 dB/km, 2 złącza po 0,5 dB, 4 spawy po 0,1 dB, czułość odbiornika −20 dBm, margines 3 dB.

1. Straty: $20\cdot 0\text{,}35 + 2\cdot 0\text{,}5 + 4\cdot 0\text{,}1 = 7 + 1 + 0\text{,}4 = 8\text{,}4$ dB.
2. Moc odbierana: $-3 - 8\text{,}4 = -11\text{,}4$ dBm; zapas ponad czułość i margines: $-11\text{,}4 - (-20) - 3 = 5\text{,}6$ dB ✓.
3. Maksymalny zasięg przy tych samych złączach: $(-3 + 20 - 3 - 1 - 0\text{,}4)/0\text{,}35 = 36$ km.

**Dyspersja:** światłowód wielomodowy skokowy $n_1 = 1\text{,}48$, $n_2 = 1\text{,}46$: $\mathrm{NA} = 0\text{,}24$ (kąt akceptacji 14°), poszerzenie 68 ns/km → szybkość ok. $1/(2\Delta t) \approx 7$ Mb/s na 1 km. Jednomodowy przy 1550 nm z laserem o szerokości widma 0,1 nm na 50 km: $17\cdot 0\text{,}1\cdot 50 = 85$ ps — dopuszczalne dla ok. 2,5–5 Gb/s.

## Typowe pułapki

- **Brak marginesu** w budżecie — łącze działa w dniu instalacji, a po naprawie (dodatkowe spawy) już nie.
- **Brudne złącza** — najczęstsza przyczyna awarii; każde złącze trzeba czyścić i sprawdzać mikroskopem przed połączeniem.
- **Patrzenie w złącze aktywnego światłowodu** — promieniowanie 1310/1550 nm jest niewidoczne i może uszkodzić oko.
- **Promień gięcia** mniejszy niż dopuszczalny — duże straty (szczególnie przy 1550 nm).
- **Mieszanie typów** (50 i 62,5 µm, jednomodowy z wielomodowym) — straty kilku–kilkunastu dB.
- **Przesterowanie odbiornika** na krótkim łączu z nadajnikiem dalekiego zasięgu.

## Ćwiczenie komputerowe

Budżet łącza, maksymalny zasięg (ograniczenie mocą i dyspersją):

```python
import numpy as np

c = 2.99792458e8
def budget(P_tx, alpha, L_km, n_conn=2, L_conn=0.5, n_splice=4, L_splice=0.1, sens=-20, margin=3):
    loss = alpha*L_km + n_conn*L_conn + n_splice*L_splice
    P_rx = P_tx - loss
    return loss, P_rx, P_rx - sens - margin

loss, P_rx, spare = budget(-3, 0.35, 20)
print(f"1310 nm, 20 km: straty {loss:.1f} dB, P_odb = {P_rx:.1f} dBm, zapas {spare:.1f} dB")
L_max = (-3 - (-20) - 3 - 2*0.5 - 4*0.1)/0.35
print(f"zasięg ograniczony mocą: {L_max:.0f} km")

# dyspersja chromatyczna 1550 nm: zasięg dla różnych przepływności (kryterium: poszerzenie < 0,25 czasu bitu)
D, dlam = 17e-12/1e-9/1e3, 0.1e-9            # s/(m·m) i szerokość widma 0,1 nm
for Rb in (1e9, 2.5e9, 10e9):
    L = 0.25/Rb/(D*dlam)/1e3
    print(f"{Rb/1e9:4.1f} Gb/s: zasięg ograniczony dyspersją ≈ {L:.0f} km")

# apertura numeryczna i dyspersja międzymodowa
n1, n2 = 1.48, 1.46
NA = np.sqrt(n1**2 - n2**2)
dt = 1e3*n1/c*(n1/n2 - 1)
print(f"NA = {NA:.3f}, kąt akceptacji {np.degrees(np.arcsin(NA)):.1f}°, poszerzenie {dt*1e9:.0f} ns/km, B·L ≈ {1/(2*dt)/1e6:.1f} Mb/s·km")
```

Model dyspersji jest uproszczony — w rzeczywistości przy 10 Gb/s znaczenie ma też szerokość widma samego sygnału modulującego i chirp lasera.

## Zadania

1. Policz NA i kąt akceptacji dla $n_1 = 1\text{,}465$, $n_2 = 1\text{,}460$.
2. Łącze wielomodowe 850 nm, 300 m, tłumienie 3 dB/km, 4 złącza po 0,5 dB. Nadajnik VCSEL −5 dBm, czułość −15 dBm. Czy łącze działa z marginesem 3 dB?
3. Dlaczego łącza dalekiego zasięgu pracują przy 1550 nm, choć przy 1310 nm dyspersja jest bliska zera?
4. Laser DFB o szerokości widma 0,02 nm, 1550 nm, 100 km. Jakie poszerzenie impulsu?
5. Odbiornik ma czułość −28 dBm i przesterowanie powyżej −8 dBm. Nadajnik +2 dBm, łącze ma 5 dB strat. Co zrobić?

<details>
<summary>Odpowiedzi</summary>

1. $\mathrm{NA} = \sqrt{1\text{,}465^2 - 1\text{,}46^2} = 0\text{,}121$; $\theta = 6\text{,}9°$
2. Straty: $0\text{,}9 + 2 = 2\text{,}9$ dB; $P_{odb} = -7\text{,}9$ dBm; zapas ponad czułość 7,1 dB > 3 dB ✓
3. Tłumienie przy 1550 nm jest najmniejsze (ok. 0,2 dB/km) i działają tam wzmacniacze optyczne EDFA; dyspersję kompensuje się (światłowody kompensujące, przetwarzanie cyfrowe w odbiornikach koherentnych) lub używa światłowodów o przesuniętej dyspersji
4. $17\cdot 0\text{,}02\cdot 100 = 34$ ps
5. Moc odbierana −3 dBm > −8 dBm — przesterowanie; dodać tłumik optyczny ≥ 5 dB (np. 10 dB → −13 dBm, nadal 15 dB ponad czułością)
</details>

## Źródła

- [The FOA Reference Guide to Fiber Optics](https://www.thefoa.org/tech/ref/contents.html) — budżet łącza, złącza, pomiary, bezpieczeństwo
- [RP Photonics Encyclopedia](https://www.rp-photonics.com/encyclopedia.html) — hasła: optical fibers, chromatic dispersion, numerical aperture
- [14.02 Warstwa fizyczna i światłowody](../14-sieci-telekomunikacyjne/02-warstwa-fizyczna-i-swiatlowody.md)
- G. Keiser — *Optical Fiber Communications* (płatna)
