# 24.05 — Zwrotnice głośnikowe

## Po co to jest

Żaden pojedynczy głośnik nie odtworzy dobrze całego pasma 20 Hz–20 kHz: duża membrana jest potrzebna do basu, mała do wysokich tonów (kierunkowość, masa). Zwrotnica dzieli sygnał między głośniki. To zastosowanie filtrów z [04.09](../04-uklady-analogowe/09-filtry-aktywne.md) i [07.04–07.05](../07-cps-dsp/05-filtry-iir.md) z jednym dodatkowym wymaganiem: **suma** sygnałów z głośników w punkcie słuchania ma być płaska — liczy się więc nie tylko moduł, ale i faza każdej gałęzi.

## Teoria w pigułce

### Rodzaje zwrotnic

| Rodzaj | Gdzie | Cechy |
|---|---|---|
| **Pasywna** | Między wzmacniaczem a głośnikami (L, C, R dużej mocy) | Jeden wzmacniacz; zależna od impedancji głośnika; straty, duże elementy |
| **Aktywna analogowa** | Przed wzmacniaczami (wzmacniacz operacyjny) | Osobny wzmacniacz na każdy głośnik; dokładna, łatwa korekcja |
| **Cyfrowa (DSP)** | Przed wzmacniaczami | Dowolne filtry (także FIR o liniowej fazie), opóźnienia, korekcja charakterystyki głośników |

### Typy filtrów i sumowanie

| Typ (rząd) | Nachylenie | Poziom każdej gałęzi przy $f_c$ | Suma |
|---|---|---|---|
| Butterworth 1. rzędu | 6 dB/okt. | −3 dB | Płaska (moduł i faza) — ale duże nakładanie się pasm |
| Butterworth 2. rzędu | 12 dB/okt. | −3 dB | Tweeter odwrócony: podbicie +3 dB przy $f_c$; nieodwrócony — głębokie wycięcie |
| **Linkwitz–Riley 2. rzędu** | 12 dB/okt. | −6 dB | Tweeter odwrócony: **płaska** |
| **Linkwitz–Riley 4. rzędu** | 24 dB/okt. | −6 dB | **Płaska**, obie gałęzie w fazie; suma jest filtrem wszechprzepustowym |

Filtr Linkwitza–Rileya rzędu $2n$ to dwa kaskadowo połączone filtry Butterwortha rzędu $n$.

### Elementy zwrotnicy pasywnej (obciążenie rezystancyjne $R$)

- 1. rząd: $C = \dfrac{1}{2\pi f_cR}$, $L = \dfrac{R}{2\pi f_c}$.
- Butterworth 2. rzędu: $C = \dfrac{1}{2\sqrt2\,\pi f_cR}$, $L = \dfrac{\sqrt2\,R}{2\pi f_c}$.
- Linkwitz–Riley 2. rzędu: $C = \dfrac{1}{4\pi f_cR}$, $L = \dfrac{R}{\pi f_c}$.
- W rzeczywistości impedancja głośnika nie jest stała — potrzebne korektory (Zobel na indukcyjność cewki, obwód RLC na rezonans tweetera) albo projekt na zmierzonej impedancji.

### Wybór częstotliwości podziału

- Tweeter: $f_c$ co najmniej 2× powyżej jego $f_s$ (przy 24 dB/okt. — 1,5–2×), ograniczenie mocy i wychylenia.
- Głośnik nisko-średniotonowy: poniżej częstotliwości, przy której zaczyna silnie „zawężać” promieniowanie (średnica membrany porównywalna z $\lambda$) i przed jego rezonansami membrany.
- Przesunięcie centrów akustycznych głośników (różne głębokości) — w DSP kompensuje się opóźnieniem, w pasywnych — przesunięciem lub filtrami asymetrycznymi.

## Przykład rozwiązany

**Zwrotnica 2. rzędu przy 2,5 kHz, głośniki 8 Ω (rezystancyjnie):**

| Typ | $C$ | $L$ |
|---|---|---|
| Butterworth 2. rzędu | $1/(2\sqrt2\,\pi\cdot 2500\cdot 8) = 5\text{,}63$ µF | $\sqrt2\cdot 8/(2\pi\cdot 2500) = 0\text{,}72$ mH |
| Linkwitz–Riley 2. rzędu | $1/(4\pi\cdot 2500\cdot 8) = 3\text{,}98$ µF | $8/(\pi\cdot 2500) = 1\text{,}02$ mH |

Sprawdzenie (Butterworth): $f = 1/(2\pi\sqrt{LC}) = 1/(2\pi\sqrt{0\text{,}72\cdot 10^{-3}\cdot 5\text{,}63\cdot 10^{-6}}) = 2500$ Hz ✓. W filtrze dolnoprzepustowym $L$ w szereg z głośnikiem niskotonowym i $C$ równolegle do niego; w górnoprzepustowym odwrotnie.

## Typowe pułapki

- **Projekt na rezystancję nominalną** — rzeczywista impedancja głośnika przy częstotliwości podziału może wynosić 10–20 Ω (indukcyjność cewki), co przesuwa $f_c$.
- **Zapomnienie o polaryzacji** — w zwrotnicy 2. rzędu tweeter musi być odwrócony; błąd daje dziurę w charakterystyce.
- **Ocena zwrotnicy po charakterystykach elektrycznych** — liczy się suma akustyczna (filtr × charakterystyka głośnika × położenie).
- **Cewki z rdzeniem bez sprawdzenia nasycenia** — zniekształcenia przy dużej mocy; cewki powietrzne mają z kolei rezystancję zmniejszającą tłumienie głośnika niskotonowego.
- **Zbyt niski podział dla tweetera** — przekroczenie wychylenia i mocy, zniekształcenia.

## Ćwiczenie komputerowe

Sumowanie gałęzi zwrotnic różnych typów (filtry analogowe, obliczenie zespolone):

```python
import numpy as np
from scipy import signal

fc = 2500.0
w = 2*np.pi*np.logspace(2, 4.5, 2000); wc = 2*np.pi*fc

def resp(b, a):
    return signal.freqs(b, a, worN=w)[1]

def butter(n, kind):
    b, a = signal.butter(n, wc, btype=kind, analog=True)
    return resp(b, a)

cases = {
    "Butterworth 2, tweeter w fazie":     (butter(2, "low"), butter(2, "high"), +1),
    "Butterworth 2, tweeter odwrócony":   (butter(2, "low"), butter(2, "high"), -1),
    "Linkwitz-Riley 2, tweeter odwrócony": (butter(1, "low")**2, butter(1, "high")**2, -1),
    "Linkwitz-Riley 4, w fazie":          (butter(2, "low")**2, butter(2, "high")**2, +1),
}
i_c = np.argmin(np.abs(w - wc))
for name, (lp, hp, sign) in cases.items():
    s = lp + sign*hp
    mag = 20*np.log10(np.abs(s))
    print(f"{name:36s}: suma przy f_c {mag[i_c]:+6.1f} dB, zakres {mag.min():+6.1f} … {mag.max():+5.1f} dB, "
          f"gałąź przy f_c {20*np.log10(abs(lp[i_c])):+5.1f} dB")

# elementy pasywne dla 8 Ω
R = 8.0
print(f"BW2: C = {1/(2*np.sqrt(2)*np.pi*fc*R)*1e6:.2f} µF, L = {np.sqrt(2)*R/(2*np.pi*fc)*1e3:.3f} mH; "
      f"LR2: C = {1/(4*np.pi*fc*R)*1e6:.2f} µF, L = {R/(np.pi*fc)*1e3:.3f} mH")
```

## Zadania

1. Zaprojektuj zwrotnicę 1. rzędu 3 kHz dla głośników 6 Ω (wartości L i C).
2. Dlaczego w zwrotnicy Butterwortha 2. rzędu suma ma +3 dB przy $f_c$?
3. Ile wynosi przesunięcie fazy między gałęziami zwrotnicy Linkwitz–Riley 4. rzędu przy $f_c$?
4. Jakie zalety ma zwrotnica cyfrowa FIR o liniowej fazie i jaki jest jej koszt?
5. Tweeter ma $f_s = 1200$ Hz. Jaka najniższa rozsądna częstotliwość podziału przy filtrze LR4?

<details>
<summary>Odpowiedzi</summary>

1. $C = 1/(2\pi\cdot 3000\cdot 6) = 8\text{,}84$ µF; $L = 6/(2\pi\cdot 3000) = 0\text{,}32$ mH
2. Każda gałąź ma −3 dB (moduł $1/\sqrt2$), a fazy różnią się o 180° — po odwróceniu tweetera sygnały są w fazie i dodają się napięciowo: $2/\sqrt2 = \sqrt2$ → +3 dB
3. 360° (gałęzie w fazie) — dlatego suma jest płaska bez odwracania polaryzacji
4. Suma jest identyczna z sygnałem wejściowym (opóźnionym) — brak zniekształceń fazowych, bardzo strome zbocza; kosztem dużego opóźnienia (kilka–kilkadziesiąt ms, problem w nagłośnieniu na żywo i z obrazem), mocy obliczeniowej i zjawiska „pre-ringing”
5. Ok. 2 kHz (1,5–2× $f_s$), zależnie od mocy i wymaganego poziomu
</details>

## Źródła

- [Linkwitz Lab — Crossovers](https://linkwitzlab.com/crossovers.htm)
- [Elliott Sound Products (spis artykułów)](https://sound-au.com/site-map.htm) — zwrotnice pasywne i aktywne, korekcja impedancji
- [04.09 Filtry aktywne](../04-uklady-analogowe/09-filtry-aktywne.md)
