# 07.07 — Zmiana częstotliwości próbkowania

## Po co to jest

Systemy cyfrowe rzadko pracują z jedną częstotliwością próbkowania: przetwornik sigma-delta próbkuje z MHz, a dane trafiają do aplikacji z kHz; audio 44,1 kHz trzeba zamienić na 48 kHz; odbiornik SDR przenosi pasmo z wysokiej częstotliwości do pasma podstawowego. Decymacja i interpolacja to podstawa wydajnego przetwarzania wielotaktowego (multirate).

## Teoria w pigułce

### Decymacja o czynnik $M$

1. Filtr dolnoprzepustowy (antyaliasingowy) z granicą $\leq f_s/(2M)$.
2. Odrzucenie $M - 1$ z każdych $M$ próbek.

Bez filtra składowe powyżej nowej częstotliwości Nyquista nałożą się na pasmo (aliasing — tym razem cyfrowy).

### Interpolacja o czynnik $L$

1. Wstawienie $L - 1$ zer między próbki (expander) — widmo zawiera $L - 1$ obrazów.
2. Filtr dolnoprzepustowy z granicą $f_s/2$ (oryginalnej) i wzmocnieniem $L$ — usuwa obrazy.

### Zmiana o ułamek $L/M$

Interpolacja o $L$ → wspólny filtr → decymacja o $M$. Np. 44,1 → 48 kHz: $L/M = 160/147$.

### Efektywna realizacja

- **Filtry polifazowe:** nie liczy się próbek, które zaraz zostaną odrzucone (decymacja), ani mnożeń przez wstawione zera (interpolacja) — koszt maleje $M$ lub $L$ razy.
- **Decymacja wieloetapowa:** zamiast jednego bardzo stromego filtra kilka etapów (np. ×4, ×4, ×2) z łagodniejszymi filtrami — wielokrotnie mniej obliczeń.
- **Filtry półpasmowe** — idealne do etapów ×2 (co drugi współczynnik zero).
- **CIC** jako pierwszy etap dużych decymacji, z korekcją charakterystyki w kolejnym etapie ([07.06](06-realizacja-filtrow.md)).

### Konwersja w dół w odbiorniku cyfrowym (DDC)

Mnożenie przez $e^{-j2\pi f_0n/f_s}$ (cyfrowy oscylator NCO) przesuwa interesujące pasmo do zera, potem decymacja do szerokości pasma sygnału. Tak działają odbiorniki SDR.

## Przykład rozwiązany

Sygnał próbkowany z 48 kHz, potrzebny 8 kHz (pasmo do 3,4 kHz — telefonia).

1. $M = 6$. Filtr: przepustowy do 3,4 kHz, zaporowy od 4 kHz (nowy Nyquist), tłumienie np. 60 dB.
2. Jeden etap przy 48 kHz: $\Delta f = 600$ Hz → $N \approx \dfrac{60}{22}\cdot\dfrac{48000}{600} \approx 218$ współczynników.
3. Polifazowo liczy się tylko co 6. próbkę wyjściową: ok. $218\cdot 8000 \approx 1{,}7$ mln mnożeń/s zamiast ok. 10,5 mln.
4. Dwa etapy (×2 półpasmowy, potem ×3) dałyby jeszcze mniej.

## Typowe pułapki

- **Decymacja przez „wyrzucanie próbek”** bez filtra.
- **Brak wzmocnienia $L$** w filtrze interpolacyjnym — sygnał $L$ razy cichszy.
- **Jeden etap dla dużego współczynnika** — ogromny filtr.
- **Ułamkowa zmiana bez wspólnego filtra** — filtr musi spełniać wymagania obu stron (minimum z dwóch częstotliwości Nyquista).

## Ćwiczenie komputerowe

```python
import numpy as np
from scipy import signal
fs = 48000; n = np.arange(fs)
x = np.sin(2*np.pi*1000*n/fs) + 0.5*np.sin(2*np.pi*5000*n/fs)   # 5 kHz > 4 kHz
y_bad  = x[::6]                                       # bez filtra: 5 kHz → alias 3 kHz
y_good = signal.resample_poly(x, 1, 6)                # z filtrem polifazowym
for y, lab in [(y_bad, "bez filtra"), (y_good, "resample_poly")]:
    f = np.fft.rfftfreq(len(y), 1/8000); Y = np.abs(np.fft.rfft(y))*2/len(y)
    print(lab, "— składowa 3 kHz:", round(Y[np.argmin(abs(f - 3000))], 3))
z = signal.resample_poly(x, 147, 160)                 # 48 kHz → 44,1 kHz
print(len(z))
```

## Zadania

1. Decymacja 48 → 8 kHz: jaki czynnik, jaka granica filtra?
2. Jakie $L$ i $M$ dla konwersji 44,1 → 48 kHz?
3. Sygnał 5 kHz przy decymacji 48 → 8 kHz bez filtra — jaka częstotliwość pojawi się w wyniku?
4. Oszacuj długość filtra jednoetapowej decymacji z przykładu i liczbę mnożeń na sekundę w realizacji polifazowej.
5. Interpolacja ×4 sygnału 8 kHz: ile obrazów widma trzeba usunąć i gdzie leżą (dla sygnału do 3,4 kHz)?

<details>
<summary>Odpowiedzi</summary>

1. $M = 6$; granica (zaporowa) ok. 4 kHz, przepustowa do pasma użytecznego
2. $L = 160$, $M = 147$
3. $8 - 5 = 3$ kHz
4. ≈ 218 współczynników; ≈ 1,7 mln mnożeń/s
5. 3 obrazy w okolicach 8, 16 i 24 kHz (pasma 4,6–11,4 kHz, 12,6–19,4 kHz, 20,6–27,4 kHz przy nowej $f_s = 32$ kHz, do 16 kHz widoczne bezpośrednio, reszta lustrzanie)
</details>

## Źródła

- [MIT RES.6-008 Digital Signal Processing](https://ocw.mit.edu/courses/res-6-008-digital-signal-processing-spring-2011/) — zmiana częstotliwości próbkowania
- [MIT RES.6-007 Signals and Systems](https://ocw.mit.edu/courses/res-6-007-signals-and-systems-spring-2011/) — wykład 19: próbkowanie w czasie dyskretnym, decymacja i interpolacja
- [SciPy — `resample_poly`, `decimate`, `upfirdn`](https://docs.scipy.org/doc/scipy/reference/signal.html)
