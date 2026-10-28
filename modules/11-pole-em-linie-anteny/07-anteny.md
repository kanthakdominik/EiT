# 11.07 — Anteny

## Po co to jest

Antena zamienia falę prowadzoną w linii na falę w przestrzeni i odwrotnie. Od jej parametrów — zysku, charakterystyki, impedancji, polaryzacji i pasma — zależy zasięg łącza tak samo jak od mocy nadajnika i czułości odbiornika. Antena źle dopasowana albo umieszczona przy metalu potrafi „zjeść” 10–20 dB budżetu.

## Teoria w pigułce

### Strefy pola

| Strefa | Odległość | Charakter |
|---|---|---|
| Bliska reaktywna | $r \lesssim \lambda/(2\pi)$ | Energia głównie magazynowana (jak w L i C), E/H ≠ 377 Ω |
| Bliska promieniowania (Fresnela) | pośrednia | Charakterystyka zależy od odległości |
| **Daleka (Fraunhofera)** | $r > 2D^2/\lambda$ (i $r \gg \lambda$) | Fala lokalnie płaska, pole maleje jak $1/r$, charakterystyka stała |

### Parametry anteny

| Parametr | Definicja |
|---|---|
| **Charakterystyka promieniowania** | Rozkład kątowy promieniowanej mocy; płaszczyzny E i H; szerokość wiązki (−3 dB), listki boczne, stosunek przód/tył |
| **Kierunkowość $D$** | Stosunek gęstości mocy w kierunku maksimum do średniej (antena izotropowa = 1) |
| **Zysk $G$** | $G = \eta_{rad}D$ — uwzględnia straty; w dBi (względem izotropowej) lub dBd (względem dipola, 0 dBd = 2,15 dBi) |
| **Impedancja wejściowa** | $Z_A = R_{rad} + R_{strat} + jX_A$; w rezonansie $X_A = 0$ |
| **Sprawność** | $\eta_{rad} = R_{rad}/(R_{rad} + R_{strat})$ |
| Pasmo | Zakres, w którym np. WFS < 2 (S11 < −10 dB) |
| Polaryzacja | Liniowa, kołowa — [11.02](02-fale-plaskie.md) |
| **Powierzchnia skuteczna** | $A_e = \dfrac{G\lambda^2}{4\pi}$ — ile mocy „zbiera” antena odbiorcza: $P_r = S\cdot A_e$ |

**Zasada wzajemności:** charakterystyka, zysk i impedancja są takie same dla nadawania i odbioru.

**EIRP** (efektywna moc promieniowana izotropowo) = $P_t\cdot G_t$ (w dBm: $P_t + G_t$) — w niej wyraża się limity regulacyjne.

### Typowe anteny

| Antena | Zysk | Impedancja | Uwagi |
|---|---|---|---|
| Dipol krótki ($l \ll \lambda$) | 1,76 dBi | $R_{rad} = 80\pi^2(l/\lambda)^2$ — bardzo małe | Trudny do dopasowania, mała sprawność |
| **Dipol półfalowy** | 2,15 dBi | ≈ 73 Ω | Charakterystyka „pączek”, zero wzdłuż osi; długość fizyczna ok. 0,95·λ/2 |
| **Monopol λ/4** nad płaszczyzną masy | 5,15 dBi (nad idealną nieskończoną masą) | ≈ 36,5 Ω | Wymaga przeciwwagi (masy) o wymiarach ≥ λ/4; połowa dipola + obraz |
| Antena pętlowa mała | jak dipol krótki | Bardzo mała R, indukcyjna | Odbiorniki, RFID HF/NFC (pole bliskie) |
| **Antena łatkowa (patch)** | 6–9 dBi | Zależy od punktu zasilania | Na PCB, płaska, wąskie pasmo; GPS, Wi-Fi |
| Antena PCB (inverted-F, meander) | 0–3 dBi | Dopasowana elementami LC | Moduły IoT; bardzo wrażliwa na otoczenie |
| Yagi–Uda | 7–15 dBi | ok. 20–50 Ω (z dopasowaniem) | Kierunkowa, TV, łącza punkt–punkt |
| Antena paraboliczna | $\eta_{ap}(\pi D/\lambda)^2$, 20–50 dBi | — | Łącza satelitarne i radiolinie |
| Tuba | 10–25 dBi | — | Mikrofale, wzorce pomiarowe |

### Szyki antenowe

$N$ elementów o regulowanej fazie i amplitudzie: **czynnik szyku** mnoży charakterystykę elementu. Zmiana faz steruje wiązką bez ruchu mechanicznego (szyki fazowane — 5G, radary, łącza satelitarne). Rozstaw elementów ≤ λ/2, aby uniknąć listków siatkowych (grating lobes). Zysk rośnie ok. $10\log N$.

## Przykład rozwiązany

**Dipol półfalowy na 868 MHz.**

1. $\lambda = c/f = 0{,}345$ m; $\lambda/2 = 17{,}3$ cm; skrócenie ok. 5% → ok. **16,4 cm** (dokładnie — po pomiarze S11).
2. Impedancja ok. 73 Ω w wolnej przestrzeni → WFS ok. 1,5 w torze 50 Ω; do tego dipol jest symetryczny, a kabel niesymetryczny — potrzebny symetryzator (balun), inaczej prąd płynie po oplocie i zniekształca charakterystykę.
3. Powierzchnia skuteczna: $A_e = 1{,}64\cdot 0{,}345^2/(4\pi) \approx 155$ cm².

**Szyk 4 elementów** rozstawionych co λ/2, wiązka odchylona o 30° od normalnej: przesunięcie fazy między elementami $\Delta\varphi = kd\sin\theta = \pi\sin 30° = 90°$.

## Typowe pułapki

- **Antena PCB bez strefy wolnej od miedzi** zalecanej przez producenta — przesunięcie rezonansu, spadek zysku o 5–10 dB.
- **Monopol bez płaszczyzny masy** — „antena” staje się też oplot kabla i obudowa.
- **Dipol zasilany wprost kablem koncentrycznym bez balunu.**
- **Zysk anteny pomylony z jej „wzmocnieniem”** — antena nie dodaje mocy, tylko ją skupia w kierunku (więcej w jednym kierunku = mniej w innych).
- **Pomiar S11 w złym otoczeniu** (ręka, stół metalowy) — antenę stroi się w docelowej obudowie.
- **dBi pomylone z dBd** — różnica 2,15 dB.

## Ćwiczenie komputerowe

Charakterystyka dipola półfalowego i szyku liniowego ze sterowaniem wiązką:

```python
import numpy as np
import matplotlib.pyplot as plt

th = np.linspace(1e-3, np.pi - 1e-3, 2000)
F_dip = (np.cos(np.pi/2*np.cos(th))/np.sin(th))**2            # dipol λ/2, kąt od osi dipola
D_dip = 2/np.sum(F_dip*np.sin(th)*(th[1] - th[0]))
print(f"kierunkowość dipola λ/2: {D_dip:.3f} = {10*np.log10(D_dip):.2f} dBi")

phi = np.linspace(-np.pi/2, np.pi/2, 2001)                     # kąt od normalnej szyku
N, d = 4, 0.5                                                  # elementy, rozstaw w λ
for steer in [0, 30]:
    dphi = 2*np.pi*d*np.sin(np.radians(steer))
    psi = 2*np.pi*d*np.sin(phi) - dphi
    AF = np.abs(np.sum([np.exp(1j*n*psi) for n in range(N)], axis=0))/N
    plt.plot(np.degrees(phi), 20*np.log10(AF + 1e-6), label=f'odchylenie {steer}°, Δφ={np.degrees(dphi):.0f}°')
plt.ylim(-30, 1); plt.xlabel('kąt [°]'); plt.ylabel('czynnik szyku [dB]'); plt.legend(); plt.grid(); plt.show()
```

## Zadania

1. Długość fizyczna dipola półfalowego na 433 MHz i monopola λ/4 na 2,44 GHz (skrócenie 5%).
2. Antena ma kierunkowość 8 dBi i sprawność 70%. Jaki jest zysk w dBi i dBd?
3. Powierzchnia skuteczna anteny 2,15 dBi przy 2,4 GHz i przy 433 MHz. Wniosek?
4. Nadajnik 14 dBm, kabel z tłumieniem 2 dB, antena 6 dBi. Jakie EIRP?
5. Szyk 8 elementów co λ/2. O ile stopni trzeba przesunąć fazę między sąsiednimi elementami, aby odchylić wiązkę o 20°?

<details>
<summary>Odpowiedzi</summary>

1. 433 MHz: $\lambda/2 = 34{,}6$ cm → ok. 32,9 cm; 2,44 GHz: $\lambda/4 = 30{,}7$ mm → ok. 29,2 mm
2. $10\log(0{,}7\cdot 6{,}31) = 6{,}45$ dBi = 4,3 dBd
3. 2,4 GHz: $1{,}64\cdot 0{,}125^2/(4\pi) \approx 20$ cm²; 433 MHz: ≈ 625 cm². Przy tym samym zysku antena na niższą częstotliwość zbiera więcej mocy — stąd mniejsze tłumienie „wolnej przestrzeni” na niższych częstotliwościach dla anten o stałym zysku ([11.08](08-propagacja-i-budzet-lacza.md))
4. $14 - 2 + 6 = 18$ dBm (≈ 63 mW)
5. $180°\cdot\sin 20° \approx 61{,}6°$
</details>

## Źródła

- [Electromagnetics, Vol. 2 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-2) — rozdziały o antenach (dipol, parametry, szyki)
- [antenna-theory.com](https://antenna-theory.com/) — parametry anten i przegląd typów z rysunkami
- [MIT 6.013 Electromagnetics and Applications](https://ocw.mit.edu/courses/6-013-electromagnetics-and-applications-fall-2005/) — promieniowanie i anteny
- Noty aplikacyjne producentów układów radiowych dotyczące projektowania anten PCB (strefy wolne od miedzi, dopasowanie)
