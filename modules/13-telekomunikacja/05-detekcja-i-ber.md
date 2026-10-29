# 13.05 — Detekcja w szumie, BER i synchronizacja

## Po co to jest

Odbiornik cyfrowy podejmuje decyzję: który symbol został nadany. Szum sprawia, że czasem się myli. Teoria detekcji mówi, jak zbudować odbiornik, który myli się najrzadziej (filtr dopasowany), i ile energii na bit potrzeba dla zadanej stopy błędów. To łącznik między budżetem łącza ([11.08](../11-pole-em-linie-anteny/08-propagacja-i-budzet-lacza.md)), czułością odbiornika ([12.04](../12-technika-wcz-rf/04-szumy.md)) a wyborem modulacji.

## Teoria w pigułce

### Filtr dopasowany

Dla sygnału $s(t)$ w białym szumie gaussowskim maksymalny SNR w chwili próbkowania daje filtr o odpowiedzi $h(t) = s(T - t)$ (odwrócony w czasie sygnał). Maksymalny SNR: $2E_s/N_0$ — zależy tylko od **energii** symbolu, nie od jego kształtu. Równoważnie: korelator (mnożenie przez wzorzec i całkowanie). W praktyce: filtr pierwiastkowy podniesionego kosinusa w odbiorniku ([13.03](03-pasmo-podstawowe-i-isi.md)).

### Stopa błędów w kanale AWGN

Funkcja $Q(x) = \dfrac{1}{\sqrt{2\pi}}\int_x^\infty e^{-u^2/2}du = \tfrac12\text{erfc}(x/\sqrt2)$.

| Modulacja | $P_b$ (Gray, przybliżenie dla QAM) | $E_b/N_0$ dla $10^{-3}$ | dla $10^{-5}$ |
|---|---|---|---|
| **BPSK, QPSK** | $Q\left(\sqrt{2E_b/N_0}\right)$ | 6,8 dB | **9,6 dB** |
| 2-FSK koherentna | $Q\left(\sqrt{E_b/N_0}\right)$ | 9,8 dB | 12,6 dB |
| 2-FSK niekoherentna | $\tfrac12 e^{-E_b/2N_0}$ | 10,9 dB | 13,4 dB |
| **16-QAM** | $\tfrac38\,\text{erfc}\sqrt{0{,}4E_b/N_0}$ | 10,5 dB | 13,4 dB |
| **64-QAM** | $\tfrac{7}{24}\,\text{erfc}\sqrt{E_b/(7N_0)}$ | 14,8 dB | 17,8 dB |

**$E_b/N_0$ a SNR:**

$$SNR = \frac{E_b}{N_0}\cdot\frac{R_b}{B}$$

Porównując modulacje przy tej samej przepływności, liczy się $E_b/N_0$; SNR w paśmie zależy od efektywności widmowej. Z kodowaniem $E_b$ to energia na bit **informacji** (bity kodowe mają mniej energii — $E_c = rE_b$).

Wnioski: każdy dodatkowy bit na symbol w QAM kosztuje ok. 2–3 dB $E_b/N_0$; BER spada z $E_b/N_0$ bardzo stromo (ok. dekada na 1 dB w okolicy $10^{-5}$) — dlatego margines kilku dB zmienia łącze „prawie niedziałające” w „bezbłędne”, a granica Shannona (−1,6 dB) pokazuje, ile mogą dać kody (ok. 10 dB względem BPSK bez kodowania przy $10^{-5}$).

### Synchronizacja

Odbiornik musi znać: **częstotliwość i fazę nośnej**, **chwilę próbkowania** (zegar symboli) i **początek ramki**.

| Zadanie | Metody |
|---|---|
| Wykrycie ramki, zgrubna synchronizacja czasu i częstotliwości | Preambuła o znanej sekwencji, korelacja |
| Odzyskiwanie zegara symboli | Detektor Gardnera, Muellera–Müllera, wczesny–późny; interpolator + pętla |
| Odzyskiwanie nośnej | Pętla Costasa (BPSK/QPSK), pętla PLL z decyzjami, podniesienie do potęgi M (usuwa modulację M-PSK); dokładna korekcja na pilotach |
| Niejednoznaczność fazy | Kodowanie różnicowe (DPSK) lub znane symbole |

Błąd fazy $\varphi$ obraca konstelację; niekorygowany błąd częstotliwości $\Delta f$ obraca ją o $2\pi\Delta f T_s$ na symbol. Szum fazowy LO daje losowe obroty ([12.07](../12-technika-wcz-rf/07-mieszacze-i-oscylatory.md)).

## Przykład rozwiązany

**Łącze QPSK** 1 Mbit/s, wymagany BER $10^{-5}$: $E_b/N_0 = 9{,}6$ dB. Pasmo z $\alpha = 0{,}35$: $R_s = 0{,}5$ Msym/s → 675 kHz; $SNR = 9{,}6 + 10\log(10^6/6{,}75\cdot 10^5) = 9{,}6 + 1{,}7 = 11{,}3$ dB.
Czułość przy NF = 5 dB: $-174 + 10\log(6{,}75\cdot 10^5) + 5 + 11{,}3 \approx -99{,}4$ dBm. Prościej, w kategoriach $E_b/N_0$: $P_{min} = -174 + 10\log R_b + NF + E_b/N_0 = -174 + 60 + 5 + 9{,}6 = -99{,}4$ dBm.

**Ten sam kanał z 64-QAM** (3 Mbit/s): $E_b/N_0$ = 17,8 dB → $P_{min} \approx -174 + 64{,}8 + 5 + 17{,}8 = -86{,}4$ dBm — 13 dB gorsza czułość za 3 razy większą przepływność.

## Typowe pułapki

- **Mieszanie $E_b/N_0$, $E_s/N_0$ i SNR** — różnią się o $10\log(\log_2M)$ i o stosunek $R_b/B$.
- **Symulacja BER z za małą liczbą bitów** — dla $10^{-5}$ potrzeba rzędu $10^7$ bitów (co najmniej ~100 błędów).
- **Szum dodany z błędną wariancją dla sygnału zespolonego** (po $N_0/2$ na składową I i Q).
- **Wzory dla AWGN stosowane w kanale z zanikami** — tam BER maleje dużo wolniej ([13.08](08-kanal-radiowy-i-systemy.md)).
- **Brak kodowania różnicowego przy odzyskiwaniu nośnej pętlą Costasa** — konstelacja może się „zatrzasnąć” obrócona o 90°/180°.

## Ćwiczenie komputerowe

Symulacja Monte Carlo BER dla BPSK, QPSK i 16-QAM w kanale AWGN, porównanie z teorią:

```python
import numpy as np
from scipy.special import erfc
import matplotlib.pyplot as plt

rng = np.random.default_rng(0)
Q = lambda x: 0.5*erfc(x/np.sqrt(2))
gray2 = {0: -3, 1: -1, 3: 1, 2: 3}                          # 2 bity -> poziom (Gray)
inv2 = {v: k for k, v in gray2.items()}

def sim(mod, ebn0_db, nbits=400_000):
    k = {'BPSK': 1, 'QPSK': 2, '16QAM': 4}[mod]
    b = rng.integers(0, 2, nbits - nbits % k)
    if mod == 'BPSK': s = 2*b - 1.0
    elif mod == 'QPSK': s = ((2*b[0::2] - 1) + 1j*(2*b[1::2] - 1))/np.sqrt(2)
    else:
        bb = b.reshape(-1, 4)
        I = np.vectorize(gray2.get)(2*bb[:, 0] + bb[:, 1]); Qd = np.vectorize(gray2.get)(2*bb[:, 2] + bb[:, 3])
        s = (I + 1j*Qd)/np.sqrt(10)
    Es = np.mean(abs(s)**2); N0 = Es/(k*10**(ebn0_db/10))
    n = np.sqrt(N0/2)*(rng.standard_normal(s.size) + (1j*rng.standard_normal(s.size) if mod != 'BPSK' else 0))
    r = s + n
    if mod == 'BPSK': bh = (r > 0).astype(int)
    elif mod == 'QPSK': bh = np.empty(b.size, int); bh[0::2] = r.real > 0; bh[1::2] = r.imag > 0
    else:
        q = lambda v: np.clip(2*np.round((v*np.sqrt(10) - 1)/2) + 1, -3, 3).astype(int)
        di, dq = np.vectorize(inv2.get)(q(r.real)), np.vectorize(inv2.get)(q(r.imag))
        bh = np.column_stack([di >> 1, di & 1, dq >> 1, dq & 1]).ravel()
    return np.mean(bh != b)

eb = np.arange(0, 13)
theory = {'BPSK': Q(np.sqrt(2*10**(eb/10))), 'QPSK': Q(np.sqrt(2*10**(eb/10))),
          '16QAM': 3/8*erfc(np.sqrt(0.4*10**(eb/10)))}
for mod in ['BPSK', 'QPSK', '16QAM']:
    ber = [sim(mod, e) for e in eb]
    plt.semilogy(eb, ber, 'o', label=f'{mod} symulacja'); plt.semilogy(eb, theory[mod], '-', label=f'{mod} teoria')
    print(mod, "Eb/N0=8 dB: sym", f"{ber[8]:.2e}", "teoria", f"{theory[mod][8]:.2e}")
plt.ylim(1e-5, 0.5); plt.xlabel('Eb/N0 [dB]'); plt.ylabel('BER'); plt.legend(); plt.grid(which='both'); plt.show()
```

## Zadania

1. Policz BER dla BPSK przy $E_b/N_0 = 8$ dB.
2. Łącze 64-QAM, 30 Mbit/s w paśmie 6 MHz. Przelicz wymagane $E_b/N_0$ dla $10^{-5}$ na SNR.
3. Czułość odbiornika BPSK 9,6 kbit/s, NF = 6 dB, BER $10^{-5}$.
4. O ile dB poprawi się czułość, jeśli przepływność spadnie 10 razy (ta sama modulacja)?
5. Błąd częstotliwości 1 kHz przy 100 ksym/s. O ile stopni obraca się konstelacja na symbol i po ilu symbolach QPSK zacznie dawać błędy (obrót 45°)?

<details>
<summary>Odpowiedzi</summary>

1. $Q(\sqrt{2\cdot 6{,}31}) = Q(3{,}55) \approx 1{,}9\cdot 10^{-4}$
2. $17{,}8 + 10\log(30/6) = 17{,}8 + 7 = 24{,}8$ dB
3. $-174 + 39{,}8 + 6 + 9{,}6 \approx -118{,}6$ dBm
4. O 10 dB
5. $360°\cdot 10^3/10^5 = 3{,}6°$ na symbol; po ok. 12–13 symbolach (bez szumu) — dlatego potrzebna jest pętla odzyskiwania nośnej
</details>

## Źródła

- [PySDR — rozdziały Noise and dB, Synchronization](https://pysdr.org) — szum, $E_b/N_0$, synchronizacja czasu i częstotliwości w Pythonie
- [MIT 6.02 Digital Communication Systems](https://ocw.mit.edu/courses/6-02-introduction-to-eecs-ii-digital-communication-systems-fall-2012/) — detekcja w szumie, BER
- [MIT 6.450 Principles of Digital Communications I](https://ocw.mit.edu/courses/6-450-principles-of-digital-communications-i-fall-2006/) — detekcja, filtr dopasowany
- [Fundamentals of Electrical Engineering I — D. Johnson](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-electrical-engineering-1) — komunikacja cyfrowa w szumie
