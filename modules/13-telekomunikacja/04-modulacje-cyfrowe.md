# 13.04 — Modulacje cyfrowe: PSK, QAM, FSK

## Po co to jest

Modulacja cyfrowa zamienia bity na zmiany amplitudy, fazy lub częstotliwości nośnej. Wybór modulacji to kompromis między przepływnością w danym paśmie, odpornością na szum i wymaganiami na liniowość nadajnika. Od BPSK w łączach kosmicznych po 4096-QAM w Wi-Fi 7 — wszystkie opisuje ten sam język konstelacji i sygnałów I/Q.

## Teoria w pigułce

### Reprezentacja I/Q

Każdy sygnał wąskopasmowy wokół nośnej:

$$s(t) = I(t)\cos\omega_ct - Q(t)\sin\omega_ct = \text{Re}\left\{[I(t) + jQ(t)]e^{j\omega_ct}\right\}$$

Symbol to punkt na płaszczyźnie I/Q (**konstelacja**). Modulator I/Q (dwa mieszacze z nośną przesuniętą o 90° — [12.07](../12-technika-wcz-rf/07-mieszacze-i-oscylatory.md)) realizuje dowolną konstelację; całe przetwarzanie odbywa się na zespolonym sygnale w paśmie podstawowym.

### Przegląd modulacji

| Modulacja | Bity/symbol | Konstelacja | Cechy |
|---|---|---|---|
| OOK/ASK | 1 | 0 i A | Najprostsza (piloty, RFID), słaba odporność |
| **BPSK** | 1 | ±1 | Najodporniejsza, mała efektywność |
| **QPSK** | 2 | 4 punkty na okręgu | Ten sam BER na bit co BPSK przy dwa razy większej efektywności |
| 8-PSK | 3 | 8 na okręgu | Stała obwiednia; łącza satelitarne |
| **16/64/256-QAM** | 4/6/8 | Siatka kwadratowa | Duża efektywność; wymaga dużego SNR i liniowego PA |
| APSK | 4–5 | Okręgi | Łącza satelitarne (DVB-S2) — mniejszy PAPR niż QAM |
| **FSK / GFSK** | 1 (2-FSK) | — (różne częstotliwości) | Stała obwiednia, prosty odbiornik; Bluetooth, IoT |
| MSK / GMSK | 1 | — | FSK o ciągłej fazie i minimalnym odstępie; GSM |
| CSS (chirp) | SF bitów | — | LoRa — bardzo duża czułość kosztem przepływności |

**Kodowanie Graya:** sąsiednie punkty konstelacji różnią się jednym bitem — najczęstszy błąd (pomylenie z sąsiadem) daje błąd jednego bitu.

**Efektywność widmowa:** $\eta = \dfrac{\log_2M}{1 + \alpha}$ bit/s/Hz (z filtrem podniesionego kosinusa). Większe $M$ — większa efektywność, ale punkty bliżej siebie: każde podwojenie liczby punktów QAM wymaga ok. 3 dB więcej SNR (przy wysokich rzędach). Modulacja adaptacyjna (Wi-Fi, LTE, 5G) dobiera $M$ i sprawność kodu do bieżącego SNR.

### Miary jakości sygnału

- **EVM** (błąd wektora modulacji): rms odległość odebranych punktów od idealnych, względem rms konstelacji; SNR ≈ $-20\log(EVM)$ dB.
- **PAPR** — stosunek mocy szczytowej do średniej; rośnie z rzędem QAM i z filtrem kształtującym (wymagania na PA — [12.06](../12-technika-wcz-rf/06-wzmacniacze-wcz.md)).
- Zniekształcenia widoczne na konstelacji: obrót (błąd fazy), wirowanie (błąd częstotliwości), spłaszczenie zewnętrznych punktów (kompresja PA), elipsa (niezrównoważenie I/Q), rozmycie (szum, szum fazowy — rozmycie łukowe).

## Przykład rozwiązany

Kanał 20 MHz, $\alpha = 0\text{,}25$ → $R_s = 16$ Msym/s.

| Modulacja | Przepływność (bez kodowania) |
|---|---|
| QPSK | 32 Mbit/s |
| 16-QAM | 64 Mbit/s |
| 64-QAM | 96 Mbit/s |
| 256-QAM | 128 Mbit/s |

Z kodem o sprawności 3/4 przepływność użyteczna: 24, 48, 72, 96 Mbit/s. Przejście z 64- na 256-QAM daje +33% przepływności, ale wymaga ok. 6 dB więcej SNR (por. [13.05](05-detekcja-i-ber.md)) — w praktyce działa tylko blisko punktu dostępowego.

## Typowe pułapki

- **Mapowanie bez kodu Graya** — BER rośnie przy tym samym SER.
- **Porównywanie modulacji przy tym samym SNR zamiast $E_b/N_0$** lub odwrotnie — zależnie od tego, co jest ustalone (moc czy przepływność).
- **QAM wysokiego rzędu przez nieliniowy wzmacniacz** — zniekształcenia zewnętrznych punktów, wzrost EVM.
- **Ignorowanie PAPR przy projektowaniu nadajnika.**
- **Mylenie liczby punktów z bitami** — 64-QAM to 6 bitów, nie 64.

## Ćwiczenie komputerowe

Konstelacje z kodowaniem Graya, efekty zniekształceń i EVM:

```python
import numpy as np
import matplotlib.pyplot as plt

def gray(n): return n ^ (n >> 1)
def qam_map(M):
    m = int(np.sqrt(M)); lv = np.arange(-(m - 1), m, 2)
    pts = {}
    for i in range(m):
        for q in range(m):
            bits = (gray(i) << int(np.log2(m))) | gray(q)
            pts[bits] = lv[i] + 1j*lv[q]
    c = np.array([pts[k] for k in range(M)])
    return c/np.sqrt(np.mean(abs(c)**2))

rng = np.random.default_rng(0)
c = qam_map(16); s = c[rng.integers(0, 16, 3000)]
effects = {
    'szum (SNR 25 dB)': s + 10**(-25/20)/np.sqrt(2)*(rng.standard_normal(s.size) + 1j*rng.standard_normal(s.size)),
    'błąd fazy 10°': s*np.exp(1j*np.radians(10)),
    'niezrównoważenie I/Q': s.real*1.1 + 1j*s.imag*0.9,
    'kompresja PA': np.tanh(abs(s))*np.exp(1j*np.angle(s))*np.mean(abs(s))/np.mean(np.tanh(abs(s))),
}
fig, axs = plt.subplots(1, 4, figsize=(14, 3.6))
for ax, (name, r) in zip(axs, effects.items()):
    evm = np.sqrt(np.mean(abs(r - s)**2)/np.mean(abs(s)**2))
    ax.plot(r.real, r.imag, '.', ms=2); ax.plot(c.real, c.imag, 'r+'); ax.set_aspect('equal')
    ax.set_title(f"{name}\nEVM = {100*evm:.1f}% ({20*np.log10(evm):.1f} dB)", fontsize=9)
    print(f"{name:22s} EVM = {100*evm:5.1f}%")
for M in [4, 16, 64, 256]:
    print(f"{M:>3}-QAM: {int(np.log2(M))} bit/symbol, eta(alpha=0.25) = {np.log2(M)/1.25:.2f} bit/s/Hz")
plt.show()
```

## Zadania

1. Ile wynosi przepływność 64-QAM przy 5 Msym/s? Jakie pasmo przy $\alpha = 0\text{,}2$?
2. Zapisz konstelację QPSK z kodem Graya.
3. Dlaczego QPSK ma taki sam BER na bit jak BPSK, a dwa razy większą efektywność?
4. Zmierzone EVM wynosi 3%. Jakiemu SNR odpowiada? Czy wystarczy dla 256-QAM (wymagane EVM ok. 2–3%)?
5. Dlaczego Bluetooth i większość tanich układów IoT używa GFSK, a nie QAM?

<details>
<summary>Odpowiedzi</summary>

1. 30 Mbit/s; 6 MHz
2. Np. 00 → (+1+j), 01 → (−1+j), 11 → (−1−j), 10 → (+1−j) (sąsiedzi różnią się jednym bitem)
3. QPSK to dwa niezależne BPSK na nośnych I i Q (ortogonalnych); każda składowa niesie 1 bit z tą samą energią na bit i tym samym szumem
4. ≈ 30,5 dB; na granicy — 256-QAM zwykle wymaga EVM ok. 2–3% (SNR ok. 30–34 dB), więc działa tylko z dobrym marginesem
5. Stała obwiednia pozwala na tani, sprawny, nieliniowy wzmacniacz; prosty odbiornik (dyskryminator) i odporność na błędy amplitudy; przy małych przepływnościach efektywność widmowa nie jest kluczowa
</details>

## Źródła

- [PySDR — rozdziały IQ Sampling i Digital Modulation](https://pysdr.org) — I/Q, konstelacje, modulacje cyfrowe w Pythonie
- [MIT 6.02 Digital Communication Systems](https://ocw.mit.edu/courses/6-02-introduction-to-eecs-ii-digital-communication-systems-fall-2012/) — modulacja i demodulacja
- [MIT 6.450 Principles of Digital Communications I](https://ocw.mit.edu/courses/6-450-principles-of-digital-communications-i-fall-2006/) — modulacja PAM i QAM
- [Analog Devices MT-080](https://www.analog.com/media/en/training-seminars/tutorials/MT-080.pdf) — modulatory I/Q od strony sprzętu
