# 13.03 — Transmisja w paśmie podstawowym: ISI, kryterium Nyquista, oko

## Po co to jest

Zanim symbole trafią na nośną, trzeba je zamienić na impulsy o ograniczonym paśmie. Zbyt wąskie pasmo rozmywa impulsy i nakłada je na siebie — powstaje interferencja międzysymbolowa (ISI). Kryterium Nyquista i filtr podniesionego kosinusa mówią, jak przesłać jak najwięcej symboli w danym paśmie bez ISI; wykres oka pozwala to zobaczyć na oscyloskopie.

## Teoria w pigułce

### Kodowanie liniowe

| Kod | Zasada | Cechy |
|---|---|---|
| NRZ | 1 = poziom wysoki, 0 = niski | Proste; składowa stała, brak przejść przy długich ciągach |
| RZ | Impuls przez pół bitu | Więcej przejść, dwa razy szersze pasmo |
| **Manchester** | Przejście w środku bitu (kierunek = wartość) | Zegar w sygnale, brak DC; dwa razy szersze pasmo (Ethernet 10BASE-T) |
| AMI, HDB3 | Jedynki naprzemiennie +/− | Brak DC (linie telekomunikacyjne E1) |
| 4B5B, 8b/10b, 64b/66b | Bloki z gwarancją przejść i równowagą DC | Szybkie łącza szeregowe (Ethernet, PCIe, USB) |
| PAM-4 | 4 poziomy = 2 bity/symbol | Połowa szybkości symbolowej przy tej samej przepływności (Ethernet 400G, PCIe 6) |

### Interferencja międzysymbolowa

Kanał o ograniczonym paśmie (kabel, filtr, kanał radiowy) wydłuża odpowiedź na pojedynczy impuls. Próbka w chwili decyzji zawiera wtedy „ogony” poprzednich i następnych symboli.

**Kryterium Nyquista (brak ISI):** całkowita odpowiedź impulsowa toru $p(t)$ (nadajnik · kanał · odbiornik) musi spełniać $p(kT_s) = 0$ dla $k \ne 0$. Minimalne pasmo dla szybkości $R_s$ symboli/s: $B_{min} = R_s/2$ (impuls sinc) — za to bardzo wrażliwy na błąd chwili próbkowania.

### Filtr podniesionego kosinusa

Widmo płaskie do $(1 - \alpha)R_s/2$, potem kosinusowe zbocze do $(1 + \alpha)R_s/2$. **Współczynnik nadmiarowości** $\alpha \in [0, 1]$:

$$B_{pp} = \frac{R_s}{2}(1 + \alpha)\ \ \text{(pasmo podstawowe)},\qquad B_{RF} = R_s(1 + \alpha)\ \ \text{(po przemianie na nośną)}$$

Większe $\alpha$ — szersze pasmo, ale szybciej zanikające ogony (mniejsza wrażliwość na błąd zegara i mniejsze szczyty sygnału). Typowo $\alpha$ = 0,2–0,35. W praktyce filtr dzieli się na dwa **filtry pierwiastkowe (RRC)** w nadajniku i odbiorniku — razem dają podniesiony kosinus (brak ISI), a odbiorczy jest jednocześnie filtrem dopasowanym ([13.05](05-detekcja-i-ber.md)).

### Wykres oka

Nałożone fragmenty sygnału o długości 2 symboli, wyzwalane zegarem symboli. **Otwarcie pionowe** — margines na szum i ISI; **otwarcie poziome** — margines na jitter; nachylenie — wrażliwość na błąd chwili próbkowania. Oko zamknięte = błędy niezależnie od SNR.

### Korekcja (wyrównywanie) kanału

Gdy kanał wprowadza ISI: korektor liniowy (filtr FIR odwrotny do kanału — zero-forcing lub MMSE), adaptacyjny (LMS — [07.08](../07-cps-dsp/08-zastosowania.md)), z decyzyjnym sprzężeniem zwrotnym (DFE), w szybkich łączach szeregowych — preemfaza w nadajniku i CTLE w odbiorniku. W systemach radiowych z dużym rozmyciem — OFDM ([13.07](07-ofdm-i-wielodostep.md)).

## Przykład rozwiązany

Łącze 1 Msym/s, filtr podniesionego kosinusa $\alpha = 0{,}35$:
- pasmo podstawowe 675 kHz, po przemianie na nośną **1,35 MHz**;
- z 16-QAM (4 bity/symbol): 4 Mbit/s w 1,35 MHz → efektywność 2,96 bit/s/Hz;
- przy $\alpha = 0$ byłoby 1 MHz (4 bit/s/Hz), ale filtr nierealizowalny i bardzo wrażliwy na zegar.

## Typowe pułapki

- **Mylenie szybkości bitowej z symbolową** — pasmo zależy od symbolowej.
- **Mylenie pasma podstawowego z pasmem na nośnej** (czynnik 2).
- **Dwa pełne filtry podniesionego kosinusa** (w nadajniku i odbiorniku) — razem dają ISI; prawidłowo: dwa filtry pierwiastkowe.
- **Długie ciągi zer lub jedynek w NRZ** — utrata synchronizacji zegara; stąd skramblery i kody blokowe.
- **Ocena łącza tylko po SNR** bez obejrzenia oka — ISI daje błędy także przy dużym SNR.

## Ćwiczenie komputerowe

Filtr pierwiastkowy podniesionego kosinusa, wykres oka i wpływ ograniczenia pasma kanału:

```python
import numpy as np
from scipy import signal
import matplotlib.pyplot as plt

def rrc(beta, sps, span):
    t = np.arange(-span*sps, span*sps + 1)/sps
    h = np.zeros_like(t)
    for i, ti in enumerate(t):
        if ti == 0: h[i] = 1 - beta + 4*beta/np.pi
        elif abs(abs(4*beta*ti) - 1) < 1e-9:
            h[i] = beta/np.sqrt(2)*((1 + 2/np.pi)*np.sin(np.pi/(4*beta)) + (1 - 2/np.pi)*np.cos(np.pi/(4*beta)))
        else:
            h[i] = (np.sin(np.pi*ti*(1 - beta)) + 4*beta*ti*np.cos(np.pi*ti*(1 + beta)))/(np.pi*ti*(1 - (4*beta*ti)**2))
    return h/np.sqrt(np.sum(h**2))

sps, beta = 8, 0.35
rng = np.random.default_rng(0)
sym = rng.choice([-3, -1, 1, 3], 2000)                    # PAM-4
x = np.zeros(len(sym)*sps); x[::sps] = sym
h = rrc(beta, sps, 8)
tx = np.convolve(x, h)
cases = {'bez ograniczenia kanału': tx,
         'kanał dolnoprzepustowy 0,3·Rs': signal.lfilter(*signal.butter(3, 0.3*2/sps), tx)}
fig, axs = plt.subplots(1, 2, figsize=(10, 4))
for ax, (name, sig) in zip(axs, cases.items()):
    rx = np.convolve(sig, h)                              # filtr dopasowany
    lag = np.argmax(np.correlate(rx[:4000], x[:4000], 'full')) - 3999
    for k in range(100, 400):
        seg = rx[lag + k*sps - sps: lag + k*sps + sps + 1]
        ax.plot(np.arange(-sps, sps + 1)/sps, seg, 'b', alpha=0.1)
    s = rx[lag::sps][:len(sym)]
    err = np.mean(np.abs(s[50:-50] - sym[50:-50]))
    ax.set_title(f"{name}\nśredni błąd próbki = {err:.3f}"); ax.grid()
    print(f"{name}: średni |błąd| w chwili próbkowania = {err:.3f}")
print(f"pasmo na nośnej dla 1 Msym/s: {1e6*(1 + beta)/1e6:.2f} MHz")
plt.show()
```

## Zadania

1. Przepływność 10 Mbit/s, QPSK, $\alpha = 0{,}25$. Jakie pasmo na nośnej?
2. Ile wynosi minimalne pasmo podstawowe dla 2 Msym/s bez ISI (teoretycznie)?
3. Dlaczego Manchester podwaja pasmo w porównaniu z NRZ i dlaczego mimo to bywa stosowany?
4. Łącze PAM-4 ma tę samą przepływność co NRZ. Jakie są jego zalety i wady?
5. Co oznacza na wykresie oka małe otwarcie poziome przy dużym otwarciu pionowym?

<details>
<summary>Odpowiedzi</summary>

1. $R_s = 5$ Msym/s → $5\cdot 1{,}25 = 6{,}25$ MHz
2. 1 MHz
3. Co najmniej jedno przejście na bit (dwa razy więcej zmian niż NRZ przy naprzemiennych bitach); zaleta: zegar w sygnale i brak składowej stałej — prosty odbiór, sprzężenie transformatorowe
4. Zaleta: połowa szybkości symbolowej (połowa pasma, mniejsze straty kanału na Nyquiście); wada: trzy razy mniejsze odstępy między poziomami (ok. 9,5 dB gorszy SNR przy tej samej amplitudzie), wrażliwość na nieliniowość
5. Duży jitter lub ISI w czasie przejść — mały margines na błąd chwili próbkowania; szum amplitudowy nie jest problemem
</details>

## Źródła

- [PySDR — rozdział Pulse Shaping](https://pysdr.org) — filtry kształtujące, podniesiony kosinus, ISI
- [MIT 6.02 Digital Communication Systems](https://ocw.mit.edu/courses/6-02-introduction-to-eecs-ii-digital-communication-systems-fall-2012/) — ISI, wykres oka, kanał jako układ LTI
- [MIT 6.450 Principles of Digital Communications I](https://ocw.mit.edu/courses/6-450-principles-of-digital-communications-i-fall-2006/) — kryterium Nyquista
