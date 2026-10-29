# M04.03 — Filtry mikrofalowe

## Po co to jest

Każdy nadajnik i odbiornik radiowy ma filtry: przed wzmacniaczem niskoszumnym (ochrona przed silnymi sygnałami spoza pasma), po wzmacniaczu mocy (tłumienie harmonicznych wymagane przez przepisy), w torze pośredniej częstotliwości, w dupleksach. Przy częstotliwościach mikrofalowych filtr to wzór ścieżek na płytce albo wnęki i rezonatory. Projekt zaczyna się zawsze od tego samego prototypu dolnoprzepustowego LC ([12.08](../../modules/12-technika-wcz-rf/08-filtry-i-architektury.md)), który przekształca się w elementy rozłożone.

## Teoria w pigułce

### Od prototypu do filtru

1. **Prototyp dolnoprzepustowy** — współczynniki $g_k$ (Butterworth, Czebyszew, eliptyczny) z tablic lub wzorów; rząd z wymaganego tłumienia.
2. **Skalowanie** impedancji i częstotliwości; **transformacje**: dolno → górno-, pasmowo-, zaporowoprzepustowy.
3. **Realizacja:**

| Struktura | Typ | Cechy |
|---|---|---|
| **Odcinki o skokowej impedancji** (stepped impedance) | Dolnoprzepustowy | Prosty, przybliżony (odcinki $\beta l < \pi/4$), słabe tłumienie daleko od pasma |
| Odcinki rozwarte (Richards + Kuroda) | Dolnoprzepustowy | Dokładniejszy, większy |
| **Linie sprzężone równolegle** (edge-coupled) | Pasmowoprzepustowy | Pasmo względne 5–20%, popularny w mikropasku |
| Rezonatory spinkowe (hairpin), grzebieniowe (interdigital, combline) | Pasmowoprzepustowy | Zwarte konstrukcje |
| Wnękowe, dielektryczne, SAW/BAW | Pasmowoprzepustowe | Duża dobroć — wąskie pasma, małe straty (stacje bazowe, telefony) |

- **Falowniki impedancji** ($J$, $K$) — odcinki λ/4 lub sprzężenia, które pozwalają zbudować filtr pasmowy z jednakowych rezonatorów.
- **Straty wtrącenia** przy skończonej dobroci rezonatorów: $IL \approx 4\text{,}34\dfrac{\sum g_k}{\mathrm{FBW}\cdot Q_0}$ dB — wąskie pasmo wymaga dużego $Q_0$.

### Odcinki o skokowej impedancji

Cewka szeregowa → odcinek o dużej impedancji $Z_h$: $\beta l = g_kZ_0/Z_h$; kondensator równoległy → odcinek o małej impedancji $Z_l$: $\beta l = g_kZ_l/Z_0$. Im większy stosunek $Z_h/Z_l$, tym lepsze przybliżenie (ograniczenie: technologia — wąskie linie dla $Z_h$, szerokie dla $Z_l$).

## Przykład rozwiązany

**Filtr dolnoprzepustowy 2,5 GHz,** Butterworth rzędu 6, $Z_0 = 50$ Ω, $Z_h = 120$ Ω, $Z_l = 20$ Ω (klasyczny przykład z podręcznika Pozara).

Prototyp: $g = 0\text{,}517;\ 1\text{,}414;\ 1\text{,}932;\ 1\text{,}932;\ 1\text{,}414;\ 0\text{,}517$. Długości elektryczne przy 2,5 GHz: 11,8° (20 Ω), 33,8° (120 Ω), 44,3°, 46,1°, 32,4°, 12,3°.

| Częstotliwość | Linie | Prototyp LC |
|---|---|---|
| 2,0 GHz | −0,5 dB | −0,3 dB |
| 2,5 GHz | −3,8 dB | −3,0 dB |
| 4,0 GHz | −21 dB | −24,5 dB |
| 6,0 GHz | −30 dB | −46 dB |
| 9,0 GHz | −15 dB | −67 dB |

W paśmie i w okolicy częstotliwości granicznej wersja z linii jest bliska prototypowi; wyżej tłumienie jest słabsze, a przy ok. 9 GHz pojawia się pasmo pasożytnicze (odcinki zbliżają się do λ/2). Jeśli w tym zakresie pracuje inny system — potrzebny dodatkowy filtr lub inna struktura.

## Typowe pułapki

- **Brak analizy pasm pasożytniczych** filtrów z elementów rozłożonych.
- **Nieuwzględnienie nieciągłości** (skoki szerokości, zagięcia, końce rozwarte) — przesunięcie częstotliwości o kilka procent; symulacja EM (openEMS) i strojenie długości.
- **Filtr bardzo wąski na FR4** — straty dielektryka dają kilka dB strat wtrącenia.
- **Tolerancja wykonania** — dla filtrów pasmowych o paśmie kilku % rozrzut $\varepsilon_r$ i szerokości ścieżek przesuwa pasmo.
- **Obudowa** — ekran nad filtrem tworzy wnękę o rezonansach w paśmie lub blisko niego.

## Ćwiczenie komputerowe

Filtr o skokowej impedancji: długości odcinków i charakterystyka z kaskady macierzy ABCD w porównaniu z prototypem LC:

```python
import numpy as np

Z0, Zh, Zl, fc = 50.0, 120.0, 20.0, 2.5e9
g = [0.517, 1.414, 1.932, 1.932, 1.414, 0.517]          # prototyp Butterwortha N = 6 (zaczyna się od C równoległego)
sections = []
for k, gk in enumerate(g):
    if k % 2 == 0:  sections.append((Zl, gk*Zl/Z0))     # kondensator → odcinek niskoimpedancyjny, βl = g·Zl/Z0
    else:           sections.append((Zh, gk*Z0/Zh))     # cewka → odcinek wysokoimpedancyjny, βl = g·Z0/Zh
for Zc, bl in sections:
    print(f"Z = {Zc:5.0f} Ω, βl(fc) = {np.degrees(bl):5.1f}°")

def line(Zc, bl):
    return np.array([[np.cos(bl), 1j*Zc*np.sin(bl)], [1j*np.sin(bl)/Zc, np.cos(bl)]])
def s21(M):
    A, B, C, D = M.ravel()
    return 2/(A + B/Z0 + C*Z0 + D)
def lumped(f):                                          # ten sam prototyp z elementami skupionymi
    M = np.eye(2, dtype=complex); w = 2*np.pi*f; wc = 2*np.pi*fc
    for k, gk in enumerate(g):
        if k % 2 == 0: M = M @ np.array([[1, 0], [1j*w*gk/(Z0*wc), 1]])
        else:          M = M @ np.array([[1, 1j*w*gk*Z0/wc], [0, 1]])
    return M

for f in (1.0e9, 2.0e9, 2.5e9, 3.0e9, 4.0e9, 6.0e9, 9.0e9):
    M = np.eye(2, dtype=complex)
    for Zc, bl in sections:
        M = M @ line(Zc, bl*f/fc)
    print(f"f = {f/1e9:3.1f} GHz: |S21| linie {20*np.log10(abs(s21(M))):7.2f} dB, elementy skupione {20*np.log10(abs(s21(lumped(f)))):7.2f} dB")
```

Rozszerzenie: zaprojektuj filtr Czebyszewa 0,5 dB rzędu 5 o tej samej częstotliwości granicznej, porównaj stromość zbocza i sprawdź wpływ zmiany $Z_h$ na 100 Ω.

## Zadania

1. Ile wynosi $\beta l$ odcinka 100 Ω realizującego cewkę $g = 1\text{,}5$ w systemie 50 Ω?
2. Dlaczego stosunek $Z_h/Z_l$ powinien być jak największy?
3. Filtr pasmowy 5% z trzema rezonatorami o $Q_0 = 200$, Butterworth ($\sum g = 4$). Szacunkowe straty wtrącenia?
4. Przy jakiej częstotliwości pojawi się pierwsze pasmo pasożytnicze filtru z odcinków λ/8 zaprojektowanego na 3 GHz?
5. Jaki typ filtru wybrać na dupleksor 2 GHz o odstępie pasm 1%?

<details>
<summary>Odpowiedzi</summary>

1. $g\,Z_0/Z_h = 1\text{,}5\cdot 50/100 = 0\text{,}75$ rad ≈ 43°
2. Przybliżenie odcinka jako czystej cewki (lub kondensatora) jest dobre, gdy odcinek jest krótki; przy dużym $Z_h$ cewka o tej samej indukcyjności wymaga krótszego odcinka, a odcinek o małym $Z_l$ ma mniejszą „pasożytniczą” indukcyjność — mniej błędów i dalsze pasmo pasożytnicze
3. $4\text{,}34\cdot 4/(0\text{,}05\cdot 200) \approx 1\text{,}7$ dB
4. Przy $4f_c = 12$ GHz (odcinki stają się λ/2)
5. Rezonatory o dużej dobroci: wnękowe lub dielektryczne (w terminalach — filtry akustyczne BAW/SAW); planarne na laminacie mają za mało dobroci przy tak wąskim paśmie
</details>

## Źródła

- [S. J. Orfanidis — Electromagnetic Waves and Antennas](https://www.ece.rutgers.edu/~orfanidi/ewa)
- [openEMS](https://openems.de) — symulacja EM filtrów mikropaskowych
- D. M. Pozar — *Microwave Engineering* (płatna) — rozdział 8 (przykład filtru o skokowej impedancji)
