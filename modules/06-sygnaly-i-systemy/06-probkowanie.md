# 06.06 — Próbkowanie i rekonstrukcja

## Po co to jest

Każdy przetwornik A/C próbkuje sygnał. Jeśli zrobi się to źle, w danych pojawią się częstotliwości, których w sygnale nie było — i żadne przetwarzanie cyfrowe ich już nie usunie. Twierdzenie o próbkowaniu i filtr antyaliasingowy to most między elektroniką analogową a cyfrową.

## Teoria w pigułce

### Próbkowanie jako mnożenie przez ciąg delt

$x_s(t) = x(t)\sum_n\delta(t - nT_s)$. Mnożenie w czasie to splot w częstotliwości, a transformata ciągu delt to ciąg delt co $f_s$ — **widmo sygnału spróbkowanego to widmo oryginału powielone co $f_s$**.

### Twierdzenie o próbkowaniu (Nyquista–Shannona)

Sygnał o paśmie ograniczonym do $f_{max}$ można dokładnie odtworzyć z próbek, jeśli

$$f_s > 2f_{max}$$

$f_s/2$ — częstotliwość Nyquista.

### Aliasing

Składowa o częstotliwości $f > f_s/2$ po spróbkowaniu jest nieodróżnialna od składowej:

$$f_{alias} = \lvert f - kf_s\rvert, \quad k \text{ takie, by } f_{alias} \in [0, f_s/2]$$

Raz powstałego aliasingu nie da się usunąć — trzeba mu zapobiec **analogowym filtrem antyaliasingowym przed przetwornikiem**.

### Dobór filtra antyaliasingowego

Filtr musi przepuścić pasmo użyteczne ($f_{max}$) i stłumić wszystko, co po spróbkowaniu wpadłoby w to pasmo — najgorszy przypadek to częstotliwość $f_s - f_{max}$. Wymagane tłumienie wynika z rozdzielczości przetwornika (np. ok. 72 dB dla 12 bitów, [07.01](../07-cps-dsp/01-przetwarzanie-ac.md)).

Kompromis: wyższe $f_s$ (nadpróbkowanie) → prostszy filtr analogowy, więcej danych do przetworzenia (potem decymacja cyfrowa — [07.07](../07-cps-dsp/07-zmiana-czestotliwosci-probkowania.md)).

### Rekonstrukcja

- Idealna: filtr dolnoprzepustowy o granicy $f_s/2$ (interpolacja funkcją sinc).
- Praktyczna: przetwornik C/A trzyma wartość przez okres próbkowania (**zero-order hold**) — to filtr o charakterystyce $\text{sinc}(f/f_s)$, tłumiący ok. 3,9 dB przy $f_s/2$, plus obrazy widma przy wielokrotnościach $f_s$, które usuwa analogowy filtr rekonstruujący.

### Próbkowanie pasmowe (podpróbkowanie)

Sygnał pasmowy (np. 70 MHz ± 5 MHz) można próbkować z $f_s$ mniejszą niż dwukrotność najwyższej częstotliwości, jeśli pasmo mieści się w jednej strefie Nyquista — wymagane $f_s > 2B$ (szerokość pasma), plus wąski filtr pasmowy. Stosuje się to w odbiornikach radiowych.

## Przykład rozwiązany

**Aliasing:** $f_s = 44{,}1$ kHz, w sygnale jest składowa 30 kHz → $f_{alias} = 44{,}1 - 30 = 14{,}1$ kHz — słyszalny ton, którego nie było.

**Dobór $f_s$:** pasmo użyteczne do $f_{max}$, filtr Butterwortha 4. rzędu z granicą $f_{max}$, wymagane tłumienie 60 dB przy $f_s - f_{max}$.

1. $10\log[1 + x^8] = 60$ → $x = 10^{6/8} \approx 5{,}62$.
2. $f_s - f_{max} \geq 5{,}62f_{max}$ → $f_s \geq 6{,}62f_{max}$.
3. Dla $f_{max} = 1$ kHz: $f_s \approx 6{,}7$ kHz, a nie 2 kHz z twierdzenia — prawie 3,5-krotne nadpróbkowanie wynika z realnego filtra.

## Typowe pułapki

- **$f_s = 2f_{max}$ dokładnie** — sinus o częstotliwości $f_s/2$ może zostać spróbkowany w przejściach przez zero i zniknąć.
- **Filtr antyaliasingowy cyfrowy** — za późno, alias już powstał.
- **Szum szerokopasmowy** bez filtra — cały szum powyżej $f_s/2$ „składa się” do pasma i podnosi poziom szumu.
- **Częstotliwość próbkowania z niestabilnego zegara** (jitter) — przy szybkich sygnałach jitter zamienia się w szum.

## Ćwiczenie komputerowe

```python
import numpy as np, matplotlib.pyplot as plt
fs = 1000; t = np.linspace(0, 0.02, 2000); n = np.arange(0, 0.02, 1/fs)
for f in [200, 800, 1200]:
    plt.plot(t*1e3, np.cos(2*np.pi*f*t), alpha=0.4)
    plt.plot(n*1e3, np.cos(2*np.pi*f*n), "o", label=f"{f} Hz")
plt.legend(); plt.xlabel("t [ms]"); plt.show()   # próbki 200, 800 i 1200 Hz pokrywają się
```

## Zadania

1. Sygnał audio do 20 kHz. Jaka minimalna częstotliwość próbkowania? Dlaczego w praktyce stosuje się 44,1 lub 48 kHz?
2. $f_s = 44{,}1$ kHz, składowa 30 kHz. Jaka częstotliwość pojawi się w próbkach?
3. $f_s = 1$ kHz. Jakie częstotliwości pozorne dadzą sygnały 1,2 kHz, 600 Hz i 2,05 kHz?
4. Filtr Butterwortha 4. rzędu z granicą $f_{max}$; wymagane tłumienie 60 dB przy $f_s - f_{max}$. Jakie $f_s$ dla $f_{max} = 1$ kHz?
5. Przetwornik C/A typu zero-order hold pracuje z $f_s = 48$ kHz. O ile dB stłumi składową 20 kHz?
6. Sygnał w paśmie 70 ± 5 MHz. Czy można go spróbkować z $f_s = 40$ MHz? W jakiej strefie Nyquista leży i gdzie pojawi się po spróbkowaniu?

<details>
<summary>Odpowiedzi</summary>

1. 40 kHz; zapas na realny filtr antyaliasingowy (pasmo przejściowe 20–22,05 kHz lub 20–24 kHz)
2. 14,1 kHz
3. 200 Hz, 400 Hz, 50 Hz
4. $f_s \approx 6{,}7$ kHz
5. $\text{sinc}(20/48) = \dfrac{\sin(0{,}4167\pi)}{0{,}4167\pi} \approx 0{,}738$ → ok. −2,6 dB
6. Tak: pasmo 65–75 MHz leży w całości w strefie 60–80 MHz (czwarta strefa, $3f_s/2$–$2f_s$); po spróbkowaniu pojawi się w paśmie 5–15 MHz, odwrócone w częstotliwości ($80 - f$)
</details>

## Źródła

- [MIT 6.003 Signals and Systems](https://ocw.mit.edu/courses/6-003-signals-and-systems-fall-2011/) — próbkowanie, aliasing, rekonstrukcja
- [MIT RES.6-007 Signals and Systems](https://ocw.mit.edu/courses/res-6-007-signals-and-systems-spring-2011/) — wykłady 16–19: próbkowanie, interpolacja, próbkowanie w czasie dyskretnym
- [The Scientist and Engineer's Guide to DSP — rozdział 3 *ADC and DAC*](http://www.dspguide.com/)
- [Think DSP — rozdział o aliasingu](https://greenteapress.com/wp/think-dsp/)
