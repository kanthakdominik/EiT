# M05.06 — Cyfrowy odbiornik pakietowy QPSK od zera

## Po co to jest

Ten temat składa wszystko w całość: nadajnik, który buduje ramkę z preambułą, i odbiornik, który **bez żadnej wiedzy z góry** o chwili nadania, przesunięciu częstotliwości i fazie wykrywa ramkę, synchronizuje się i dekoduje bity — z jakością bliską teorii. To szkielet każdego łącza pakietowego (Wi-Fi, Bluetooth, LoRa, telemetria satelitarna, łącza IoT). Gotowy odbiornik można uruchomić na ADALM-Pluto w pętli kablowej (nadajnik → tłumik → odbiornik).

## Teoria w pigułce

### Struktura ramki

| Pole | Rola |
|---|---|
| (Opcjonalnie) sekwencja wstępna | Ustalenie ARW i zgrubna synchronizacja |
| **Preambuła** (znane symbole, np. 32–128) | Wykrycie ramki, synchronizacja czasu, estymacja CFO, fazy i kanału |
| Nagłówek | Długość, typ, modulacja i kod danych (chroniony silniej) |
| Dane | Ładunek, zwykle z kodowaniem kanałowym i przeplotem |
| CRC | Wykrycie błędów — decyzja o przyjęciu/retransmisji |

Preambuła powinna mieć **ostrą autokorelację** (sekwencje m, Barkera, Zadoffa–Chu, losowe QPSK), wystarczającą długość dla wymaganego prawdopodobieństwa wykrycia i fałszywego alarmu ([M01.01](../M01-estymacja-detekcja-filtracja/01-teoria-detekcji.md)) oraz odporność na nieznane CFO.

### Wykrywanie ramki przy nieznanym CFO

Korelacja koherentna z całą preambułą $\left\lvert\sum_k y_k p_k^*\right\rvert$ zawodzi, gdy faza obraca się podczas preambuły o więcej niż ok. π. Rozwiązanie: **korelacja segmentowa** — preambuła dzielona na $S$ segmentów, korelacje segmentów sumowane niekoherentnie: $\sum_s\left\lvert\sum_{k\in s}y_kp_k^*\right\rvert$. Kosztem ok. 1–2 dB czułości wykrywania zyskuje się odporność na CFO do ok. $R_s/(2\cdot\text{długość segmentu})$. Dodatkowo **fazy kolejnych segmentów** dają estymatę CFO: $\hat\omega = \arg\sum_s c_{s+1}c_s^*/L_{seg}$.

### Odbiornik

1. Filtr dopasowany RRC na pełnej szybkości (np. 8 próbek/symbol).
2. Korelacja segmentowa na każdej próbce → maksimum daje jednocześnie **początek ramki i chwilę próbkowania** (rozdzielczość 1/8 symbolu).
3. CFO z faz segmentów, faza z całej preambuły.
4. Decymacja do 1 próbki/symbol, **śledzenie fazy sterowane decyzjami** (pętla drugiego rzędu) przez dane.
5. Decyzje (lub LLR dla dekodera, [M02.06](../M02-mimo-i-kodowanie/06-kody-ldpc.md)), CRC.

## Przykład rozwiązany

Ramka: 64 symbole preambuły + 1000 symboli danych QPSK, 100 kBd, RRC $\beta = 0\text{,}35$; kanał: losowe opóźnienie, losowe CFO w zakresie ±5 kHz, losowa faza, AWGN. Po 60 ramek na punkt:

| $E_b/N_0$ | 2 dB | 4 dB | 6 dB | 8 dB | 10 dB |
|---|---|---|---|---|---|
| BER odbiornika | $1\text{,}1\cdot 10^{-1}$ | $1\text{,}45\cdot 10^{-2}$ | $2\text{,}8\cdot 10^{-3}$ | $4\text{,}3\cdot 10^{-4}$ | 0 (na 120 000 bitów) |
| teoria (koherentny QPSK) | $3\text{,}75\cdot 10^{-2}$ | $1\text{,}25\cdot 10^{-2}$ | $2\text{,}4\cdot 10^{-3}$ | $1\text{,}9\cdot 10^{-4}$ | $3\text{,}9\cdot 10^{-6}$ |

Od 4 dB odbiornik traci wobec teorii ok. 0,3–0,6 dB (szum estymat i pętli fazy, próbkowanie z rozdzielczością 1/8 symbolu). Przy 2 dB pętla sterowana decyzjami traci synchronizm (poślizgi cykli) i część ramek jest stracona — dlatego przy niskim SNR stosuje się piloty rozmieszczone w danych, kodowanie i dekodowanie z informacją zwrotną dla pętli.

## Typowe pułapki

- **Korelacja koherentna z długą preambułą** przy CFO kilku kHz — ramki niewykrywane.
- **Estymata CFO tylko z preambuły ekstrapolowana na długą ramkę** — błąd fazy rośnie liniowo; potrzebne śledzenie w danych lub piloty.
- **Normalizacja amplitudy pominięta** — decyzje QAM wyższego rzędu i progi wykrywania zależne od wzmocnienia.
- **Pomiar BER bez rozróżnienia ramek utraconych i błędnych** — myląca statystyka; raportuje się osobno prawdopodobieństwo wykrycia i BER/FER ramek wykrytych.
- **Test na sprzęcie bez tłumika** — przesterowany odbiornik (Pluto nadaje kilka dBm) i niedozwolona emisja.

## Ćwiczenie komputerowe

Kompletny łańcuch: nadajnik ramek, kanał z nieznanym opóźnieniem, CFO i fazą, odbiornik i krzywa BER:

```python
import numpy as np
from scipy.special import erfc

rng = np.random.default_rng(6)
sps, beta, span = 8, 0.35, 6
Rs = 100e3
fs = Rs * sps

def rrc(beta, sps, span):
    t = np.arange(-span * sps, span * sps + 1) / sps + 1e-9      # przesunięcie omija osobliwości
    h = (np.sin(np.pi * t * (1 - beta)) + 4 * beta * t * np.cos(np.pi * t * (1 + beta))) \
        / (np.pi * t * (1 - (4 * beta * t)**2))
    return h / np.sqrt(np.sum(h**2))

h = rrc(beta, sps, span)
qpsk = lambda b: ((1 - 2 * b[0::2]) + 1j * (1 - 2 * b[1::2])) / np.sqrt(2)
pre = qpsk(np.random.default_rng(99).integers(0, 2, 128))       # znana preambuła: 64 symbole
Ndata = 1000

def nadajnik(bity):
    sym = np.concatenate([pre, qpsk(bity)])
    up = np.zeros(sym.size * sps, complex)
    up[::sps] = sym
    return np.convolve(up, h)

def kanal(tx, EbN0_db):
    cisza = rng.integers(200, 2000)                              # nieznany początek ramki
    x = np.concatenate([np.zeros(cisza, complex), tx, np.zeros(500, complex)])
    n = np.arange(x.size)
    cfo = rng.uniform(-5e3, 5e3)                                  # nieznane przesunięcie częstotliwości
    x = x * np.exp(1j * (2 * np.pi * cfo * n / fs + rng.uniform(0, 2 * np.pi)))
    EsN0 = 2 * 10**(EbN0_db / 10)
    return x + np.sqrt(1 / EsN0 / 2) * (rng.standard_normal(x.size) + 1j * rng.standard_normal(x.size))

def odbiornik(rx):
    y = np.convolve(rx, h)                                          # filtr dopasowany
    # 1) synchronizacja ramki i chwili próbkowania: korelacja z preambułą przy pełnym nadpróbkowaniu,
    #    niekoherentnie w 8 segmentach po 8 symboli — odporna na nieznane CFO
    L, seg = pre.size, 8
    K = y.size - L * sps
    c = np.zeros(K)
    cj_all = []
    for j in range(L // seg):
        wzor = np.zeros(seg * sps, complex)
        wzor[::sps] = pre[j * seg:(j + 1) * seg]
        cj = np.correlate(y[j * seg * sps:], wzor, mode="valid")[:K]
        cj_all.append(cj)
        c += np.abs(cj)
    start = np.argmax(c)
    # 2) CFO z obrotu fazy między kolejnymi segmentami preambuły, faza z całej preambuły
    cs = np.array([cj[start] for cj in cj_all])
    w = np.angle(np.sum(cs[1:] * np.conj(cs[:-1]))) / (seg * sps)   # rad na próbkę
    n = np.arange(y.size - start)
    z = (y[start:] * np.exp(-1j * w * n))[::sps][:L + Ndata]
    z = z * np.exp(-1j * np.angle(np.sum(z[:L] * np.conj(pre))))
    # 4) śledzenie fazy na danych: pętla sterowana decyzjami
    d = z[pre.size:].copy()
    faza, czest = 0.0, 0.0
    for k in range(d.size):
        d[k] *= np.exp(-1j * faza)
        dec = (np.sign(d[k].real) + 1j * np.sign(d[k].imag)) / np.sqrt(2)
        e = np.angle(d[k] * np.conj(dec))
        czest += 0.0002 * e                                  # pętla drugiego rzędu: faza i częstotliwość
        faza += czest + 0.02 * e
    bity = np.empty(2 * Ndata, int)
    bity[0::2], bity[1::2] = d.real < 0, d.imag < 0
    return bity, w * fs / (2 * np.pi)

for EbN0 in (2, 4, 6, 8, 10):
    bledy = wszystkie = 0
    for _ in range(60):
        b = rng.integers(0, 2, 2 * Ndata)
        bh, cfo_est = odbiornik(kanal(nadajnik(b), EbN0))
        bledy += np.sum(b != bh); wszystkie += b.size
    teoria = 0.5 * erfc(np.sqrt(10**(EbN0 / 10)))
    print(f"Eb/N0 = {EbN0} dB: BER = {bledy / wszystkie:.2e} (teoria {teoria:.2e})")
```

Na sprzęcie (ADALM-Pluto, pętla kablowa przez tłumik ≥ 30 dB; nie podłączaj anteny) — blok nieuruchamiany automatycznie:

```python
import adi, numpy as np
sdr = adi.Pluto("ip:192.168.2.1")
sdr.sample_rate = int(800e3)
sdr.tx_lo = sdr.rx_lo = int(433.92e6)
sdr.tx_hardwaregain_chan0 = -40             # mała moc nadajnika
sdr.rx_buffer_size = 2**16
b = np.random.randint(0, 2, 2000)
tx = nadajnik(b)                            # funkcja z ćwiczenia powyżej
sdr.tx_cyclic_buffer = True
sdr.tx(np.concatenate([tx, np.zeros(2000)]) * 2**14)   # Pluto oczekuje skali ok. 2^14
rx = sdr.rx()
bh, cfo = odbiornik(rx)
print("BER:", np.mean(b != bh), "CFO [Hz]:", cfo)
```

Rozszerzenia: dodaj CRC-16 i nagłówek z długością; zastąp decyzje twarde wartościami LLR i dekoderem LDPC z [M02.06](../M02-mimo-i-kodowanie/06-kody-ldpc.md); dodaj piloty co 100 symboli i porównaj odporność na poślizgi przy 2 dB.

## Zadania

1. Jaki CFO obraca fazę o π w czasie segmentu 8 symboli przy 100 kBd?
2. Ile wynosi strata SNR spowodowana próbkowaniem z błędem 1/16 symbolu przy RRC $\beta = 0\text{,}35$ (oszacuj z kształtu impulsu podniesionego kosinusa)?
3. Dlaczego maksimum korelacji przy 8 próbkach na symbol wyznacza zarazem chwilę próbkowania?
4. Jak dobrać długość preambuły, by prawdopodobieństwo fałszywego alarmu na próbkę było $10^{-6}$ przy wymaganym prawdopodobieństwie wykrycia 0,99?
5. Po co odbiornikowi CRC, skoro BER jest mierzony bezpośrednio?

<details>
<summary>Odpowiedzi</summary>

1. $\pi = 2\pi f\cdot 8/10^5$ → $f = 6\text{,}25$ kHz (dlatego CFO do ±5 kHz jest jeszcze tolerowane)
2. Impuls podniesionego kosinusa w $t = T/16$: $\mathrm{sinc}(1/16)\cdot\cos(\pi\beta/16)/(1 - (2\beta/16)^2) \approx 0\text{,}994\cdot 1\text{,}000 \approx 0\text{,}993$ → ok. 0,06 dB straty mocy użytecznej, plus niewielka ISI — pomijalne
3. Korelacja z wzorcem próbkowanym co symbol jest maksymalna, gdy wszystkie próbki wzorca trafiają w szczyty impulsów po filtrze dopasowanym, czyli w optymalne chwile próbkowania
4. Z teorii detekcji: próg wynika z rozkładu statystyki dla samego szumu (dla korelacji niekoherentnej — rozkład Rayleigha/chi-kwadrat), a wymagana energia preambuły $E = L\cdot E_s$ z wymaganego $P_D$ przy tym progu — dłuższa preambuła przy niższym SNR ([M01.01](../M01-estymacja-detekcja-filtracja/01-teoria-detekcji.md))
5. W rzeczywistym systemie odbiornik nie zna nadanych bitów — CRC jest jedynym sposobem, by stwierdzić, czy ramka jest poprawna (i poprosić o retransmisję)
</details>

## Źródła

- [PySDR: A Guide to SDR and DSP using Python](https://pysdr.org) — rozdziały o filtrach dopasowanych, synchronizacji, wykrywaniu ramek i PlutoSDR (nadawanie i odbiór)
- [T. Collins i in. — Software-Defined Radio for Engineers](https://www.analog.com/sdrforengineers) — projekt odbiornika pakietowego na ADALM-Pluto
- [M01.01 Teoria detekcji](../M01-estymacja-detekcja-filtracja/01-teoria-detekcji.md)
