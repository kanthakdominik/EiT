# 13.08 — Kanał radiowy i przegląd systemów

## Po co to jest

Kanał radiowy to nie tylko szum: sygnał zanika, gdy odbite fale znoszą się wzajemnie, zmienia się, gdy odbiornik się porusza, i rozmywa w czasie, gdy odbicia przychodzą z różnymi opóźnieniami. Zrozumienie tych zjawisk tłumaczy, dlaczego systemy komórkowe i Wi-Fi wyglądają tak, jak wyglądają. Ten temat zamyka moduł mapą rzeczywistych systemów i ich parametrów.

## Teoria w pigułce

### Parametry kanału

| Zjawisko | Miara | Skutek | Kanał „płaski” / „wolny”, gdy |
|---|---|---|---|
| Rozmycie opóźnień (wielodrogowość) | $\tau_{rms}$; pasmo koherencji $B_c \approx 1/(5\tau_{rms})$ | Zaniki selektywne częstotliwościowo, ISI | $B_{sygnału} \ll B_c$ |
| Rozmycie Dopplera (ruch) | $f_D = vf_c/c$; czas koherencji $T_c \approx 0{,}423/f_D$ | Zmienność kanału w czasie | $T_{symbolu} \ll T_c$ |

Typowe $\tau_{rms}$: wewnątrz budynków 10–100 ns, w mieście 1–3 µs, w terenie górzystym do ok. 10 µs i więcej.

### Zaniki

- **Rayleigha** — brak widoczności bezpośredniej, suma wielu fal o losowych fazach: obwiednia ma rozkład Rayleigha, głębokie zaniki (−20…−30 dB) co ok. λ/2.
- **Rice'a** — jest składowa bezpośrednia (współczynnik K); zaniki płytsze.
- **Zaniki wolne (cień)** — rozkład log-normalny, odchylenie 6–10 dB ([11.08](../11-pole-em-linie-anteny/08-propagacja-i-budzet-lacza.md)).

W kanale Rayleigha BER maleje tylko **odwrotnie proporcjonalnie** do średniego SNR (zamiast wykładniczo): BPSK potrzebuje ok. 24 dB dla $10^{-3}$ zamiast 6,8 dB w AWGN.

### Dywersyfikacja

Kilka niezależnie zanikających kopii sygnału — małe prawdopodobieństwo, że wszystkie zanikną naraz.

| Rodzaj | Realizacja |
|---|---|
| Przestrzenna | Kilka anten odległych o ≥ λ/2; łączenie: wybór najlepszej, łączenie z maksymalnym stosunkiem (MRC) |
| Częstotliwościowa | OFDM z kodowaniem i przeplotem po podnośnych, skoki częstotliwości |
| Czasowa | Kodowanie + przeplot w czasie dłuższym niż $T_c$, retransmisje (HARQ) |
| Nadawcza | Kody czasowo-przestrzenne (Alamouti), formowanie wiązki |

Dwie anteny z MRC: BPSK dla $10^{-3}$ — ok. 11 dB zamiast 24 dB. **Rząd dywersyfikacji** $L$: BER maleje jak $SNR^{-L}$.

### Przegląd systemów

| System | Pasmo | Modulacja / dostęp | Przepływność (rząd wielkości) |
|---|---|---|---|
| Radiofonia FM | 87,5–108 MHz | FM | Analog (mono/stereo + RDS) |
| DAB+ | VHF pasmo III | OFDM, DQPSK | ok. 1 Mbit/s na multipleks |
| DVB-T2 | UHF | OFDM, do 256-QAM, LDPC | ok. 30–40 Mbit/s na multipleks |
| GSM (2G) | 900/1800 MHz | GMSK, TDMA/FDMA | kbit/s (mowa, SMS) |
| LTE (4G) | 0,7–3,8 GHz | OFDMA (DL), SC-FDMA (UL), do 256-QAM, MIMO | dziesiątki–setki Mbit/s |
| 5G NR | < 6 GHz i fale milimetrowe (24+ GHz) | OFDMA, elastyczne odstępy podnośnych, LDPC/polarne, masywne MIMO | do Gbit/s |
| Wi-Fi 6/7 | 2,4 / 5 / 6 GHz | OFDMA, do 1024/4096-QAM, MIMO | do Gbit/s |
| Bluetooth LE | 2,4 GHz | GFSK, skoki częstotliwości | 1–2 Mbit/s |
| LoRa | sub-GHz | CSS | 0,3–50 kbit/s, km zasięgu |
| GNSS (GPS, Galileo) | L1 ok. 1575 MHz | DSSS/BPSK, BOC | 50 bit/s danych nawigacyjnych |
| Łącza satelitarne (DVB-S2) | Ku, Ka | APSK, LDPC + BCH | dziesiątki–setki Mbit/s na transponder |

Szczegóły warstw sieciowych tych systemów — moduł [14](../14-sieci-telekomunikacyjne/).

## Przykład rozwiązany

**Telefon w samochodzie,** 100 km/h, 2 GHz: $f_D = 27{,}8\cdot 2\cdot 10^9/3\cdot 10^8 \approx 185$ Hz → $T_c \approx 2{,}3$ ms. Symbol LTE (ok. 71 µs) jest dużo krótszy — w obrębie symbolu kanał stały, ale między kolejnymi podramkami (1 ms) już nie: estymacja kanału na pilotach musi być częsta.

**Miasto,** $\tau_{rms} = 1$ µs → $B_c \approx 200$ kHz. Kanał 20 MHz jest silnie selektywny częstotliwościowo — pojedyncza nośna potrzebowałaby długiego korektora; podnośna 15 kHz widzi kanał płaski.

## Typowe pułapki

- **Budżet łącza bez marginesu na zaniki** w ruchomym kanale.
- **Anteny dywersyfikacyjne zbyt blisko siebie** (≪ λ/2) — zaniki skorelowane, zysku brak.
- **Przeplot krótszy niż czas koherencji** — zanik obejmuje cały blok kodowy.
- **Wyniki BER z AWGN** przenoszone do kanału z zanikami.

## Ćwiczenie komputerowe

BER BPSK w kanale Rayleigha: symulacja vs teoria, bez dywersyfikacji i z MRC dla dwóch anten:

```python
import numpy as np
from scipy.special import erfc
import matplotlib.pyplot as plt

rng = np.random.default_rng(0)
N = 400_000
eb = np.arange(0, 31, 3)
def sim(L, g):
    b = rng.integers(0, 2, N); s = 1 - 2.0*b
    h = (rng.standard_normal((L, N)) + 1j*rng.standard_normal((L, N)))/np.sqrt(2)
    n = (rng.standard_normal((L, N)) + 1j*rng.standard_normal((L, N)))/np.sqrt(2*g)
    r = h*s + n
    z = np.sum(np.conj(h)*r, axis=0).real                     # MRC (dla L=1 — koherentna detekcja)
    return np.mean((z < 0) != b)

res = {}
for L in [1, 2]:
    res[L] = [sim(L, 10**(e/10)) for e in eb]
g = 10**(eb/10); mu = np.sqrt(g/(1 + g))
th1 = 0.5*(1 - mu); th2 = ((1 - mu)/2)**2*(1 + 2*(1 + mu)/2)
awgn = 0.5*erfc(np.sqrt(g))
for i, e in enumerate(eb):
    print(f"Eb/N0={e:2d} dB: AWGN {awgn[i]:.1e} | Rayleigh sym {res[1][i]:.1e} teoria {th1[i]:.1e} | MRC2 sym {res[2][i]:.1e} teoria {th2[i]:.1e}")
plt.semilogy(eb, awgn, label='AWGN'); plt.semilogy(eb, th1, label='Rayleigh'); plt.semilogy(eb, th2, label='Rayleigh + MRC 2 anteny')
plt.semilogy(eb, res[1], 'o'); plt.semilogy(eb, res[2], 's')
fd = 100/3.6*2e9/3e8
print(f"f_D = {fd:.0f} Hz, T_c = {0.423/fd*1e3:.2f} ms; B_c (1 us) = {1/(5e-6)/1e3:.0f} kHz")
plt.ylim(1e-6, 0.5); plt.xlabel('średnie Eb/N0 [dB]'); plt.legend(); plt.grid(which='both'); plt.show()
```

## Zadania

1. Częstotliwość Dopplera i czas koherencji dla pieszego (5 km/h) przy 2,4 GHz.
2. Kanał ma $\tau_{rms} = 200$ ns. Jakie pasmo koherencji? Czy sygnał BLE (2 MHz) doświadcza zaników selektywnych?
3. O ile dB trzeba zwiększyć moc BPSK w kanale Rayleigha w porównaniu z AWGN dla BER $10^{-3}$? Ile daje MRC z dwiema antenami?
4. Dlaczego w kanale Rayleigha kodowanie z przeplotem daje dużo większy zysk niż w kanale AWGN?
5. Na jakiej zasadzie LTE i Wi-Fi zwiększają przepływność bez poszerzania pasma?

<details>
<summary>Odpowiedzi</summary>

1. $f_D = 1{,}39\cdot 2{,}4\cdot 10^9/3\cdot 10^8 \approx 11$ Hz, $T_c \approx 38$ ms
2. $B_c \approx 1$ MHz; tak, częściowo — pasmo sygnału jest porównywalne z $B_c$ (stąd skoki częstotliwości w BLE)
3. Ok. $24 - 6{,}8 \approx 17$ dB; MRC: ok. 11 dB zamiast 24 dB (zysk ok. 13 dB)
4. Kod z przeplotem zapewnia dywersyfikację czasową/częstotliwościową — błędy z zaników rozkładają się na wiele niezależnie zanikających bitów; w AWGN takiego zysku nie ma
5. Modulacja i kodowanie adaptacyjne (wyższe rzędy QAM przy dobrym SNR) oraz MIMO z multipleksacją przestrzenną (kilka strumieni w tym samym paśmie)
</details>

## Źródła

- [PySDR — rozdział Multipath Fading](https://pysdr.org) — modele zaników i ich symulacja
- [MIT 6.450 Principles of Digital Communications I](https://ocw.mit.edu/courses/6-450-principles-of-digital-communications-i-fall-2006/) — kanały bezprzewodowe, zaniki, dywersyfikacja
- [Microwave and RF Design: Radio Systems — M. Steer](https://open.umn.edu/opentextbooks/textbooks/microwave-and-rf-design-radio-systems) — systemy radiowe w praktyce
- [MIT 6.02 Digital Communication Systems](https://ocw.mit.edu/courses/6-02-introduction-to-eecs-ii-digital-communication-systems-fall-2012/)
