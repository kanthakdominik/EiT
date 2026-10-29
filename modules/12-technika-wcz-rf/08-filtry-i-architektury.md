# 12.08 — Filtry w.cz. i architektury odbiorników

## Po co to jest

Odbiornik musi wyłowić słaby sygnał spośród silnych sąsiadów, a nadajnik — nie śmiecić poza swoim kanałem. Robią to filtry w.cz. i dobrze dobrana architektura toru. Ten temat zbiera klocki z modułu w działający system: od klasycznej superheterodyny po radio programowalne (SDR), w którym większość pracy wykonuje cyfrowe przetwarzanie sygnałów.

## Teoria w pigułce

### Filtry w.cz.

| Technologia | Zakres | Cechy |
|---|---|---|
| **LC (elementy skupione)** | do ok. 1–3 GHz | Prosty projekt z tablic prototypów; straty zależne od Q cewek |
| Mikropaskowe, sprzężone linie | od ok. 1 GHz | Na płytce, powtarzalne; duże wymiary na niższych częstotliwościach |
| Ceramiczne (wnękowe, wielowarstwowe) | 0,4–6 GHz | Małe straty, małe wymiary |
| **SAW** (fala akustyczna powierzchniowa) | do ok. 2,5–3 GHz | Bardzo strome zbocza, wąskie pasmo, straty 1–3 dB, ograniczona moc |
| **BAW/FBAR** | 1,5–6+ GHz | Telefony komórkowe, duplekser |
| Kwarcowe | do ok. 100–200 MHz | Bardzo wąskie pasma (filtry p.cz.) |
| Wnękowe, falowodowe | mikrofale | Bardzo małe straty, duża moc (stacje bazowe) |

**Projekt filtra LC z prototypu:** współczynniki $g_k$ prototypu dolnoprzepustowego (Butterworth, Czebyszew) przeskalowane do impedancji $R_0$ i częstotliwości $f_c$:

$$C_k = \frac{g_k}{2\pi f_cR_0},\qquad L_k = \frac{g_kR_0}{2\pi f_c}$$

Butterworth 3. rzędu: $g = 1,\ 2,\ 1$. Przekształcenia: dolnoprzepustowy → górnoprzepustowy (L ↔ C), → pasmowoprzepustowy (każdy element w obwód rezonansowy na $f_0$). Teoria filtrów analogowych — [04.09](../04-uklady-analogowe/09-filtry-aktywne.md).

### Architektury odbiorników

| Architektura | Zasada | Zalety | Wady |
|---|---|---|---|
| **Superheterodyna** | RF → mieszacz → stała p.cz. → filtr kanałowy → demodulacja | Doskonała selektywność i czułość, sprawdzona | Lustro, filtry zewnętrzne (SAW, kwarc), złożoność |
| **Bezpośrednia przemiana (zero-IF)** | Mieszacz I/Q z LO = $f_{RF}$, filtry dolnoprzepustowe, A/C | Prosta, scalona, brak lustra | DC offset, przeciek LO, szum 1/f, IP2, niezrównoważenie I/Q |
| Niska p.cz. (low-IF) | p.cz. rzędu szerokości kanału, odrzucanie lustra w I/Q | Brak problemu DC | Lustro w sąsiednim kanale — wymaga dobrego zrównoważenia I/Q |
| **SDR** | Przetwornik A/C możliwie blisko anteny (po p.cz. lub bezpośrednio), reszta cyfrowo | Elastyczność, wiele standardów, aktualizacje programowe | Wymagania na A/C (szybkość, zakres dynamiki), pobór mocy |

Nadajniki: modulator I/Q z bezpośrednią przemianą w górę, superheterodyna nadawcza, modulacja polarna; wymagania widmowe (maska, harmoniczne — filtr dolnoprzepustowy za PA).

### Planowanie częstotliwości i budżet

Projekt toru: wybór p.cz. (lustro, produkty mieszania, dostępne filtry), rozkład wzmocnień i filtrów tak, aby uzyskać wymagany NF (wzmocnienie na początku, [12.04](04-szumy.md)) i IIP3 (ostrożnie ze wzmocnieniem przed mieszaczem, [12.05](05-nieliniowosc.md)), automatyczna regulacja wzmocnienia (AGC) dla zakresu dynamiki sygnałów wejściowych.

## Przykład rozwiązany

**Filtr dolnoprzepustowy Butterwortha 3. rzędu**, 50 Ω, $f_c = 100$ MHz, struktura π (C–L–C):

- $C_1 = C_3 = \dfrac{1}{2\pi\cdot 10^8\cdot 50} \approx 31\text{,}8$ pF,
- $L_2 = \dfrac{2\cdot 50}{2\pi\cdot 10^8} \approx 159$ nH.

Tłumienie przy 200 MHz (Butterworth 3. rzędu): $10\log(1 + 2^6) \approx 18\text{,}1$ dB. W praktyce: elementy z szeregu (33 pF, 160 nH lub 150 nH), dobroć cewki i jej SRF.

**Odbiornik SDR na 868 MHz:** RTL-SDR próbkuje I/Q z 2,4 MS/s po bezpośredniej przemianie (lub niskiej p.cz.) — w Pythonie: przesunięcie częstotliwości (mnożenie przez $e^{-j2\pi f t}$), filtr FIR i decymacja ([07.07](../07-cps-dsp/07-zmiana-czestotliwosci-probkowania.md)), demodulacja.

## Typowe pułapki

- **Filtr zaprojektowany na idealnych elementach** — SRF cewek i pojemności padów przesuwają charakterystykę.
- **Filtr SAW bez dopasowania** zalecanego przez producenta — tętnienia i duże straty.
- **Superheterodyna z p.cz., na której leżą silne sygnały z otoczenia** (np. nadajniki) — przeciek bezpośrednio na p.cz.
- **Odbiornik zero-IF bez kompensacji DC** — „szpilka” w środku widma (charakterystyczna dla tanich SDR).
- **Niezrównoważenie I/Q** — lustro widoczne w widmie SDR jako odbicie sygnału względem środka.

## Symulacja

Filtr Butterwortha z przykładu w LTspice:

```spice
* Butterworth 3. rzedu, 50 Ohm, fc = 100 MHz (C-L-C)
V1 src 0 AC 2
Rs src in 50
C1 in 0 31.8p
L2 in out 159n
C3 out 0 31.8p
RL out 0 50
.ac dec 200 1Meg 1G
* Zrodlo AC 2 V -> V(out) = 1 V (0 dB) w pasmie przepustowym; -3 dB przy 100 MHz.
* Dodaj Rser=1 do L2 (skonczona dobroc) i Cpar=0.2p - porownaj.
.end
```

## Ćwiczenie komputerowe

Filtr LC z prototypu (ABCD → S21) i przesunięcie częstotliwości z filtracją jak w SDR:

```python
import numpy as np
from scipy import signal

Z0 = 50
def s21(f, C1, L2, C3, RL=0.0):
    w = 2*np.pi*f
    M = lambda A, B, C, D: np.array([[A, B], [C, D]], dtype=complex)
    T = M(1, 0, 1j*w*C1, 1) @ M(1, 1j*w*L2 + RL, 0, 1) @ M(1, 0, 1j*w*C3, 1)
    A, B, C, D = T.ravel()
    return 2/(A + B/Z0 + C*Z0 + D)

fc = 100e6; g = [1, 2, 1]
C1 = g[0]/(2*np.pi*fc*Z0); L2 = g[1]*Z0/(2*np.pi*fc); C3 = g[2]/(2*np.pi*fc*Z0)
print(f"C1 = C3 = {C1*1e12:.1f} pF, L2 = {L2*1e9:.1f} nH")
for f in [50e6, 100e6, 200e6, 400e6]:
    print(f"{f/1e6:5.0f} MHz: |S21| = {20*np.log10(abs(s21(f, C1, L2, C3))):6.2f} dB"
          f" (z R cewki 2 Ω: {20*np.log10(abs(s21(f, C1, L2, C3, 2.0))):6.2f} dB)")

# SDR: sygnał I/Q 2,4 MS/s, nadajnik o +300 kHz od środka -> przesunięcie do 0, filtr, decymacja
fs = 2.4e6; t = np.arange(240000)/fs
rng = np.random.default_rng(1)
x = np.exp(2j*np.pi*300e3*t) + 3*np.exp(2j*np.pi*-500e3*t) + 0.1*(rng.standard_normal(t.size) + 1j*rng.standard_normal(t.size))
y = x*np.exp(-2j*np.pi*300e3*t)                       # przesunięcie częstotliwości
h = signal.firwin(101, 50e3, fs=fs)                   # filtr kanałowy
z = signal.lfilter(h, 1, y)[::10]                     # decymacja do 240 kS/s
print(f"moc w kanale po filtracji: {10*np.log10(np.mean(abs(z[20:])**2)):.2f} dB (sygnał użyteczny = 0 dB)")
```

## Zadania

1. Zaprojektuj filtr dolnoprzepustowy Butterwortha 3. rzędu 50 Ω na 30 MHz (C–L–C).
2. Ile wynosi tłumienie Butterwortha 5. rzędu przy $2f_c$?
3. Odbiornik ma odbierać kanał 25 kHz w paśmie 433 MHz przy silnych sygnałach w odległości 200 kHz. Którą architekturę wybierzesz i jakie filtry?
4. Dlaczego w tanich odbiornikach SDR widać szpilkę w środku widma i jak się jej pozbyć?
5. Filtr SAW na wejściu odbiornika ma stratę 2,5 dB. O ile pogorszy się NF? Dlaczego mimo to się go stosuje?

<details>
<summary>Odpowiedzi</summary>

1. $C_1 = C_3 = 106$ pF, $L_2 = 531$ nH
2. $10\log(1 + 2^{10}) \approx 30\text{,}1$ dB
3. Np. superheterodyna lub low-IF z dobrym filtrem kanałowym (kwarcowym/ceramicznym na p.cz. albo cyfrowym przy wystarczającym zakresie dynamiki A/C) i filtrem SAW na wejściu; kluczowy jest szum fazowy LO przy 200 kHz (mieszanie odwrotne) i IIP3
4. Składowa stała z przecieku LO i niezrównoważenia mieszacza w architekturze zero-IF; rozwiązania: przestrojenie odbioru tak, by sygnał był obok środka (offset tuning), cyfrowe usuwanie DC, kalibracja
5. NF rośnie o ok. 2,5 dB; filtr chroni LNA i mieszacz przed silnymi sygnałami spoza pasma (kompresja, intermodulacja, lustro) — bez niego czułość w rzeczywistym środowisku byłaby gorsza
</details>

## Źródła

- [Microwave and RF Design: Radio Systems — M. Steer](https://open.umn.edu/opentextbooks/textbooks/microwave-and-rf-design-radio-systems) — architektury nadajników i odbiorników, planowanie częstotliwości
- [Fundamentals of Microwave and RF Design — M. Steer](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-microwave-and-rf-design) — filtry w.cz.
- [PySDR](https://pysdr.org) — SDR, sygnały I/Q, odbiór i demodulacja w Pythonie
- [Analog Devices MT-080](https://www.analog.com/media/en/training-seminars/tutorials/MT-080.pdf) — modulatory i demodulatory I/Q
