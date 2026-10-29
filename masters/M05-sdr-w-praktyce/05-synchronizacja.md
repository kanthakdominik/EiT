# M05.05 — Synchronizacja: częstotliwość, czas symbolu, faza

## Po co to jest

W symulacji z podręcznika nadajnik i odbiornik mają ten sam zegar i tę samą fazę nośnej. W prawdziwym radiu nie mają: oscylatory różnią się o kilka–kilkadziesiąt ppm (kilohertzy przesunięcia), zegary próbkowania dryfują, opóźnienie kanału jest nieznane. Bez synchronizacji konstelacja QPSK obraca się i rozmywa, a BER wynosi 50%. Synchronizacja to zwykle największa i najtrudniejsza część cyfrowego odbiornika — i element, który najczęściej zawodzi przy przejściu z symulacji do sprzętu.

## Teoria w pigułce

### Kolejność

1. **Zgrubna korekcja częstotliwości** (CFO) — by sygnał zmieścił się w filtrze dopasowanym, a pętle mogły się zatrzasnąć.
2. **Filtr dopasowany** (RRC, [13.03](../../modules/13-telekomunikacja/03-pasmo-podstawowe-i-isi.md)).
3. **Synchronizacja symbolowa** — wybór chwil próbkowania w środku „oka”.
4. **Synchronizacja nośnej** — śledzenie resztkowej częstotliwości i fazy.
5. Rozstrzygnięcie **niejednoznaczności fazy** (90° dla QPSK) — preambuła, słowo synchronizacyjne lub kodowanie różnicowe.

### Estymacja CFO

- **Potęgowanie:** dla M-PSK $x^M$ usuwa modulację ($e^{jM\pi k/2}$ → 1 dla QPSK, $M = 4$), zostaje prążek na $M\cdot f_{CFO}$ — jego położenie z FFT. Zakres jednoznaczności $\lvert f_{CFO}\rvert < f_s/(2M)$; dokładność zależy od długości FFT i SNR (strata na potęgowaniu przy niskim SNR).
- **Z preambuły** (data-aided): faza iloczynu odebranych i znanych symboli rośnie liniowo — nachylenie to CFO; lub korelacja dwóch identycznych fragmentów (Schmidl–Cox, [07](07-ofdm-w-sdr.md)).
- **FLL z filtrami brzegów pasma** (band-edge) — pętla częstotliwości przed synchronizacją symbolową (blok *FLL Band-Edge* w GNU Radio).

### Synchronizacja symbolowa

- **Detektor Gardnera** (2 próbki na symbol): $e_k = \mathrm{Re}\{(y_{k-1} - y_k)\,y_{k-1/2}^*\}$ — znak mówi, czy próbkujemy za wcześnie, czy za późno; niezależny od fazy nośnej, więc może działać przed pętlą fazy.
- **Mueller–Müller** (1 próbka na symbol, sterowany decyzjami): $e_k = \mathrm{Re}\{\hat a_{k-1}^*y_k - \hat a_k^*y_{k-1}\}$ — wymaga poprawnej fazy.
- **Interpolator** (liniowy, sześcienny, Farrow lub filtr wielofazowy) wylicza próbkę w ułamkowej chwili; **filtr pętli PI** sumuje błędy i koryguje chwilę oraz okres (różnicę zegarów).

### Synchronizacja nośnej

- **Pętla Costasa:** BPSK $e = I\cdot Q$; QPSK $e = \mathrm{sgn}(I)\,Q - \mathrm{sgn}(Q)\,I$; wyższe QAM — detektor sterowany decyzjami $e = \arg(y\hat a^*)$.
- **Pętla drugiego rzędu** (proporcjonalna + całkująca, [10.05](../../modules/10-automatyka/05-regulatory-pid.md)) śledzi i fazę, i częstotliwość bez uchybu ustalonego.
- **Pasmo pętli:** szerokie — szybkie zatrzaskiwanie, ale duży szum fazy; wąskie — mały szum, wolne zatrzaskiwanie i większe ryzyko **poślizgów cykli** (przeskok konstelacji o 90°) przy niskim SNR.

## Przykład rozwiązany

QPSK 100 kBd, 8 próbek na symbol, RRC $\beta = 0\text{,}35$; kanał: CFO 3 kHz, opóźnienie 3,4 próbki, faza 40°, $E_s/N_0 = 15$ dB.

1. Czwarta potęga + FFT ($2^{18}$ punktów): estymata CFO 3,000 kHz (błąd 0,1 Hz).
2. Gardner z interpolacją liniową, filtr PI: zbieżność w kilkuset symbolach.
3. Pętla Costasa drugiego rzędu: resztkowe CFO 0,0 Hz.
4. Po zbieżności: EVM 17,9% (teoretycznie dla samego szumu $1/\sqrt{E_s/N_0}$ = 17,8%), 0 błędów na 6000 bitów.

Strata implementacyjna synchronizacji jest więc pomijalna przy tym SNR; przy niskim SNR dominują poślizgi cykli i szum pętli ([06](06-odbiornik-cyfrowy-od-zera.md)).

## Typowe pułapki

- **Pętla Costasa przy dużym CFO** (rzędu pasma pętli) — nie zatrzaskuje się; najpierw zgrubna korekcja.
- **Detektor Mueller–Müller przed korekcją fazy** — błąd czasu zależy od obrotu konstelacji.
- **Za szerokie pasmo pętli** — EVM wyraźnie większe od teorii; za wąskie — długi stan przejściowy (gubione początki pakietów).
- **Niejednoznaczność 90°** nierozstrzygnięta — „idealna” konstelacja i 50% błędów lub zamienione bity I/Q.
- **Dryf zegara próbkowania** pominięty w długich ramkach — pętla symbolowa musi śledzić także okres, nie tylko fazę.

## Ćwiczenie komputerowe

Pełny łańcuch synchronizacji QPSK: CFO z czwartej potęgi, Gardner, pętla Costasa:

```python
import numpy as np

rng = np.random.default_rng(5)

def rrc(beta, sps, span):
    t = np.arange(-span * sps, span * sps + 1) / sps
    h = np.zeros_like(t)
    for i, ti in enumerate(t):
        if abs(ti) < 1e-12:
            h[i] = 1 + beta * (4 / np.pi - 1)
        elif abs(abs(4 * beta * ti) - 1) < 1e-12:
            h[i] = beta / np.sqrt(2) * ((1 + 2 / np.pi) * np.sin(np.pi / (4 * beta))
                                        + (1 - 2 / np.pi) * np.cos(np.pi / (4 * beta)))
        else:
            h[i] = (np.sin(np.pi * ti * (1 - beta)) + 4 * beta * ti * np.cos(np.pi * ti * (1 + beta))) \
                   / (np.pi * ti * (1 - (4 * beta * ti)**2))
    return h / np.sqrt(np.sum(h**2))

# Nadajnik QPSK: 100 kBd, 8 próbek na symbol, RRC beta = 0,35
Rs, sps, Nsym = 100e3, 8, 6000
fs = Rs * sps
bity = rng.integers(0, 2, 2 * Nsym)
sym = ((1 - 2 * bity[0::2]) + 1j * (1 - 2 * bity[1::2])) / np.sqrt(2)
h = rrc(0.35, sps, 6)
up = np.zeros(Nsym * sps, complex)
up[::sps] = sym
tx = np.convolve(up, h)

# Kanał: przesunięcie częstotliwości 3 kHz, opóźnienie 3,4 próbki, faza 40 st., szum (Es/N0 = 15 dB)
cfo, opoznienie = 3e3, 3.4
n = np.arange(tx.size)
rx = np.interp(n - opoznienie, n, tx.real) + 1j * np.interp(n - opoznienie, n, tx.imag)
rx = rx * np.exp(1j * (2 * np.pi * cfo * n / fs + np.deg2rad(40)))
EsN0 = 10**(15 / 10)
rx = rx + np.sqrt(1 / EsN0 / 2) * (rng.standard_normal(rx.size) + 1j * rng.standard_normal(rx.size))

# 1) Zgrubna estymacja CFO: czwarta potęga usuwa modulację QPSK
X4 = np.fft.fft(rx**4, 2**18)
f4 = np.fft.fftfreq(2**18, 1 / fs)
cfo_est = f4[np.argmax(np.abs(X4))] / 4
print(f"CFO: prawdziwe {cfo / 1e3:.3f} kHz, estymata z 4. potęgi {cfo_est / 1e3:.3f} kHz")
y = rx * np.exp(-2j * np.pi * cfo_est * n / fs)
y = np.convolve(y, h)                                  # filtr dopasowany

# 2) Synchronizacja symbolowa Gardnera (2 próbki na symbol z interpolacją liniową)
def interp(x, t):
    i = int(t); f = t - i
    return x[i] * (1 - f) + x[i + 1] * f

t, okres, out, poprz, e_int = 2.0 * sps * 6, float(sps), [], 0j, 0.0
Kp, Ki = 0.08, 0.002
while t + sps + 2 < y.size:
    teraz, polowa = interp(y, t), interp(y, t - okres / 2)
    if out:
        e = np.real((poprz - teraz) * np.conj(polowa))       # błąd Gardnera
        e_int += Ki * e
        t += Kp * e + e_int
    out.append(teraz); poprz = teraz
    t += okres
z = np.array(out)

# 3) Pętla Costasa dla QPSK (resztkowa faza i częstotliwość)
faza, czest, a1, a2 = 0.0, 0.0, 0.05, 0.002
zc = np.empty_like(z)
hist = np.empty(z.size)
for k, v in enumerate(z):
    w = v * np.exp(-1j * faza)
    zc[k] = w
    e = np.sign(w.real) * w.imag - np.sign(w.imag) * w.real
    czest += a2 * e
    faza += czest + a1 * e
    hist[k] = czest

# Ocena po zbieżności (rozstrzygnięcie niejednoznaczności 4 obrotów symbolami znanymi)
ost = zc[2000:5000]                                    # po zbieżności pętli
ost = ost / np.sqrt(np.mean(np.abs(ost)**2))
ref = None
for przes in range(-20, 21):
    kandydat = sym[2000 + przes:2000 + przes + ost.size]
    if kandydat.size < ost.size:
        continue
    for rot in range(4):
        d = np.mean(np.abs(ost * 1j**rot - kandydat)**2)
        if ref is None or d < ref[0]:
            ref = (d, rot, przes)
d, rot, przes = ref
dec = ost * 1j**rot
evm = np.sqrt(d) * 100
bledy = np.sum(np.sign(dec.real) != np.sign(sym[2000 + przes:2000 + przes + dec.size].real))
bledy += np.sum(np.sign(dec.imag) != np.sign(sym[2000 + przes:2000 + przes + dec.size].imag))
print(f"EVM po synchronizacji: {evm:.1f} % (teoria dla Es/N0 = 15 dB: {100 / np.sqrt(EsN0):.1f} %)")
print(f"błędy bitowe: {bledy} na {2 * dec.size}")
print(f"resztkowe CFO wg pętli Costasa (średnia po zbieżności): {hist[2000:].mean() * Rs / (2 * np.pi):.1f} Hz"
      f" (błąd estymaty zgrubnej: {cfo - cfo_est:.1f} Hz)")
```

Rozszerzenia: wykreśl przebieg błędu Gardnera i częstotliwości pętli Costasa w czasie (stan przejściowy); dodaj różnicę zegarów nadajnika i odbiornika (np. 50 ppm — przeskaluj oś czasu przy interpolacji) i sprawdź, czy pętla śledzi; porównaj z blokami *Symbol Sync* i *Costas Loop* w GNU Radio.

## Zadania

1. Jaki jest zakres jednoznacznej estymacji CFO metodą czwartej potęgi dla QPSK przy 8 próbkach na symbol i 100 kBd?
2. Dlaczego detektor Gardnera potrzebuje dwóch próbek na symbol?
3. Pętla Costasa pierwszego rzędu ma śledzić resztkowe CFO 50 Hz przy 100 kBd. Jaki będzie ustalony błąd fazy przy wzmocnieniu pętli 0,05 rad na rad?
4. Jak wykryć poślizg cyklu w odbiorniku?
5. Dlaczego zgrubną estymację CFO wykonuje się zwykle przed filtrem dopasowanym lub z filtrem szerszym od dopasowanego?

<details>
<summary>Odpowiedzi</summary>

1. $f_s/(2\cdot 4) = 800\ \text{kHz}/8 = \pm 100$ kHz (w praktyce mniej, bo prążek musi wyraźnie wystawać ponad szum)
2. Porównuje różnicę dwóch kolejnych symboli z próbką pośrodku między nimi; w środku przejścia między symbolami ta próbka jest zerowa przy poprawnym próbkowaniu, a jej znak względem kierunku zmiany mówi o kierunku błędu
3. Przyrost fazy na symbol $2\pi\cdot 50/10^5 = 3\text{,}1\cdot 10^{-3}$ rad; błąd ustalony $3\text{,}1\cdot 10^{-3}/0\text{,}05 \approx 0\text{,}063$ rad ≈ 3,6° (pętla drugiego rzędu usuwa ten uchyb)
4. Nagły obrót decyzji o 90° — błędy wzrastają lawinowo do końca ramki; wykrywa się go przez kontrolę znanych symboli (piloty, słowo synchronizacyjne), CRC lub kodowanie różnicowe, które ogranicza skutki do kilku symboli
5. Przy dużym CFO część widma sygnału wypada poza wąski filtr dopasowany — tracona energia i zniekształcenia; dopiero po korekcji filtr dopasowany działa optymalnie
</details>

## Źródła

- [PySDR: A Guide to SDR and DSP using Python](https://pysdr.org) — rozdział o synchronizacji (Mueller–Müller, Costas, korekcja częstotliwości)
- [T. Collins i in. — Software-Defined Radio for Engineers](https://www.analog.com/sdrforengineers) — rozdziały o synchronizacji czasu i nośnej
- [MIT 6.450 Principles of Digital Communication I (2006)](https://ocw.mit.edu/courses/6-450-principles-of-digital-communications-i-fall-2006/)
- M. Rice — *Digital Communications: A Discrete-Time Approach* (płatna) — synchronizacja w dziedzinie dyskretnej
