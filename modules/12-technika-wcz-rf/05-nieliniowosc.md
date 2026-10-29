# 12.05 — Nieliniowość i zakres dynamiki

## Po co to jest

Szum ogranicza najsłabszy sygnał, który odbiornik usłyszy; nieliniowość — najsilniejszy, który zniesie, zanim zacznie tworzyć fałszywe sygnały. Silny nadajnik w sąsiednim kanale potrafi „zagłuszyć” odbiornik nie dlatego, że jest w paśmie, ale przez intermodulację w LNA lub mieszaczu. W nadajnikach nieliniowość wzmacniacza mocy rozszerza widmo na sąsiednie kanały.

## Teoria w pigułce

### Model wielomianowy

$$y = a_1x + a_2x^2 + a_3x^3 + \dots$$

Dla dwóch tonów $f_1$, $f_2$ powstają: harmoniczne ($2f_1$, $3f_1$), produkty drugiego rzędu ($f_1 \pm f_2$) i **produkty intermodulacji trzeciego rzędu $2f_1 - f_2$, $2f_2 - f_1$** — leżą tuż obok sygnałów, w paśmie, i nie da się ich odfiltrować.

### Miary nieliniowości

| Miara | Definicja |
|---|---|
| **P1dB** | Moc (wejściowa IP1dB lub wyjściowa OP1dB), przy której wzmocnienie spada o 1 dB |
| **IP3** (IIP3, OIP3) | Punkt przecięcia ekstrapolowanych prostych: podstawowej (nachylenie 1 dB/dB) i IM3 (nachylenie **3 dB/dB**) |
| IP2 | Analogicznie dla produktów drugiego rzędu (ważne w odbiornikach z bezpośrednią przemianą) |
| Kompresja AM/AM, AM/PM | Zmiana amplitudy i fazy wyjścia z mocą — wzmacniacze mocy |

Związki:
- $P_{IM3,wy} = 3P_{wy} - 2\cdot OIP3$ (dBm), czyli tłumienie produktów $\Delta = 2(OIP3 - P_{wy})$;
- $OIP3 = IIP3 + G$;
- dla nieliniowości trzeciego rzędu IP1dB ≈ IIP3 − 9,6 dB (reguła ok. 10 dB);
- **pomiar IP3:** $IIP3 = P_{we} + \Delta/2$.

### IP3 kaskady

$$\frac{1}{IIP3_{cał}} = \frac{1}{IIP3_1} + \frac{G_1}{IIP3_2} + \frac{G_1G_2}{IIP3_3} + \dots$$

(moce liniowe, np. mW). Tu **ostatnie stopnie decydują** — odwrotnie niż dla szumów. Duże wzmocnienie przed mieszaczem poprawia NF, ale pogarsza IIP3 całości.

### Zakres dynamiki

- **SFDR** (zakres dynamiki wolny od zniekształceń): od progu szumów do mocy, przy której produkty IM3 zrównują się z szumem:

$$SFDR = \frac23\left(IIP3 - P_{szum}\right),\qquad P_{szum} = -174 + 10\log B + NF$$

- Blokowanie (desensytyzacja): silny sygnał poza kanałem kompresuje odbiornik i obniża jego czułość.
- W przetwornikach A/C i odbiornikach SDR dochodzi zakres przetwornika ([07.01](../07-cps-dsp/01-przetwarzanie-ac.md)).

### Nadajniki

ACPR/ACLR (moc w sąsiednim kanale), maska widmowa, EVM (błąd wektora modulacji — [13](../13-telekomunikacja/)). Modulacje o dużym stosunku mocy szczytowej do średniej (PAPR — OFDM, QAM) wymagają **cofnięcia (back-off)** od P1dB lub linearyzacji (predystorsja cyfrowa).

## Przykład rozwiązany

Wzmacniacz: $G = 20$ dB, $OIP3 = +30$ dBm. Dwa tony po −20 dBm na wejściu.

1. $P_{wy} = 0$ dBm na ton.
2. $P_{IM3} = 3\cdot 0 - 2\cdot 30 = -60$ dBm — 60 dB poniżej tonów.
3. $IIP3 = 10$ dBm, $IP1dB \approx 0$ dBm.
4. Przy $NF = 5$ dB i $B = 1$ MHz: $P_{szum} = -109$ dBm → $SFDR = \tfrac23(10 + 109) \approx 79$ dB.
5. Gdy tony wzrosną o 10 dB (−10 dBm na wejściu), IM3 wzrośnie o 30 dB, do −30 dBm.

## Typowe pułapki

- **Pomiar IM3 w zakresie kompresji** — nachylenie przestaje być 3:1, ekstrapolacja IP3 daje fałszywy wynik.
- **Mylenie IIP3 z OIP3** (różnią się o wzmocnienie).
- **Projekt toru tylko pod NF** — maksymalne wzmocnienie na początku toru i słaby mieszacz dają odbiornik „głuchy” przy silnych sąsiadach.
- **Analizator widma wytwarza własne produkty IM3** — sprawdź, czy zmieniają się przy zmianie tłumika wejściowego analizatora.
- **Produkty drugiego rzędu w odbiorniku z bezpośrednią przemianą** — dudnienie z silnych sygnałów trafia na DC i do pasma podstawowego.

## Ćwiczenie komputerowe

Test dwutonowy na modelu wielomianowym — sprawdzenie nachylenia 3:1 i wyznaczenie IIP3:

```python
import numpy as np
import matplotlib.pyplot as plt

fs, N = 1e6, 2**16
t = np.arange(N)/fs
f1, f2 = 100e3, 110e3
f1 = round(f1*N/fs)*fs/N; f2 = round(f2*N/fs)*fs/N             # tony w środkach prążków FFT
a1, a3 = 10.0, -1.0                                            # y = a1 x + a3 x^3
fr = np.fft.rfftfreq(N, 1/fs)
amp_db = lambda Y, f: 20*np.log10(Y[np.argmin(abs(fr - f))])

Pin, Pf, Pim = [], [], []
for A in np.logspace(-2.5, -0.5, 9):
    x = A*(np.cos(2*np.pi*f1*t) + np.cos(2*np.pi*f2*t))
    Y = np.abs(np.fft.rfft(a1*x + a3*x**3))/N*2
    Pin.append(20*np.log10(A)); Pf.append(amp_db(Y, f1)); Pim.append(amp_db(Y, 2*f1 - f2))
Pin, Pf, Pim = map(np.array, (Pin, Pf, Pim))
s_f = np.polyfit(Pin[:4], Pf[:4], 1); s_im = np.polyfit(Pin[:4], Pim[:4], 1)
iip3 = (s_im[1] - s_f[1])/(s_f[0] - s_im[0])
print(f"nachylenia: podstawowa {s_f[0]:.2f}, IM3 {s_im[0]:.2f} dB/dB")
print(f"IIP3 (amplituda) = {10**(iip3/20):.3f}, teoria sqrt(4/3 |a1/a3|) = {np.sqrt(4/3*abs(a1/a3)):.3f}")
plt.plot(Pin, Pf, 'o-', label='podstawowa'); plt.plot(Pin, Pim, 's-', label='IM3')
plt.xlabel('wejście [dB]'); plt.ylabel('wyjście [dB]'); plt.legend(); plt.grid(); plt.show()
```

## Zadania

1. Wzmacniacz $G = 15$ dB, $OIP3 = +25$ dBm, dwa tony po −30 dBm. Poziom IM3 na wyjściu?
2. Pomiar: tony na wejściu −15 dBm, różnica między tonem a IM3 na wyjściu 50 dB. Ile wynosi IIP3?
3. IIP3 kaskady: LNA ($G = 15$ dB, IIP3 = −5 dBm), mieszacz ($G = -7$ dB, IIP3 = +10 dBm).
4. SFDR odbiornika: IIP3 = −10 dBm, NF = 3 dB, B = 200 kHz.
5. Dlaczego w odbiorniku z bezpośrednią przemianą ważny jest IP2, a w superheterodynie mniej?

<details>
<summary>Odpowiedzi</summary>

1. $P_{wy} = -15$ dBm, $IM3 = -45 - 50 = -95$ dBm
2. $-15 + 50/2 = +10$ dBm
3. $1/IIP3 = 1/0\text{,}316 + 31\text{,}6/10 = 3\text{,}16 + 3\text{,}16 = 6\text{,}32$ mW⁻¹ → $IIP3 \approx 0\text{,}158$ mW ≈ −8 dBm
4. $P_{szum} = -174 + 53 + 3 = -118$ dBm; $SFDR = \tfrac23(108) = 72$ dB
5. Produkty drugiego rzędu $f_1 - f_2$ (i prostowanie silnych sygnałów AM) trafiają w okolice zera — dokładnie w pasmo sygnału po przemianie bezpośredniej; w superheterodynie trafiają na niską częstotliwość, daleko od p.cz., i są odfiltrowane
</details>

## Źródła

- [Microwave and RF Design: Radio Systems — M. Steer](https://open.umn.edu/opentextbooks/textbooks/microwave-and-rf-design-radio-systems) — nieliniowość, intermodulacja, zakres dynamiki
- [Analog Devices MT-080 — Mixers and Modulators](https://www.analog.com/media/en/training-seminars/tutorials/MT-080.pdf) — parametry mieszaczy, IP3, kompresja
- [PySDR](https://pysdr.org) — zakres dynamiki odbiorników SDR
