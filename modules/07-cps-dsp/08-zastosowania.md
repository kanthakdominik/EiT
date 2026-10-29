# 07.08 — Zastosowania: Goertzel, filtry adaptacyjne, praktyka

## Po co to jest

Ten temat łączy moduł w praktyczne narzędzia, które trafiają do prawdziwych urządzeń: wykrywanie tonów DTMF, pomiar amplitudy i fazy pojedynczej częstotliwości, usuwanie zakłóceń 50 Hz i echa, a także zasady implementacji DSP na mikrokontrolerze.

## Teoria w pigułce

### Algorytm Goertzela

Gdy potrzebny jest **jeden prążek** widma (albo kilka), Goertzel jest tańszy niż pełna FFT: rekurencyjny filtr 2. rzędu z jednym współczynnikiem rzeczywistym.

$$k = \text{round}\left(\frac{Nf}{f_s}\right), \qquad c = 2\cos\frac{2\pi k}{N}$$

$$s[n] = x[n] + c\,s[n - 1] - s[n - 2], \qquad \lvert X[k]\rvert^2 = s^2[N-1] + s^2[N-2] - c\,s[N-1]s[N-2]$$

Jedno mnożenie na próbkę na każdą wykrywaną częstotliwość. Standard w dekoderach DTMF (8 częstotliwości).

### Filtracja adaptacyjna (LMS)

Filtr FIR, którego współczynniki same się dostrajają, aby zminimalizować błąd $e[n] = d[n] - y[n]$:

$$\mathbf{w}[n + 1] = \mathbf{w}[n] + \mu\,e[n]\,\mathbf{x}[n]$$

Warunek stabilności (w przybliżeniu): $0 < \mu < \dfrac{2}{L\cdot P_x}$ ($L$ — długość filtra, $P_x$ — moc sygnału wejściowego). Wariant NLMS normalizuje krok mocą sygnału.

| Zastosowanie | Sygnał $x$ | Sygnał $d$ |
|---|---|---|
| Usuwanie zakłóceń (np. 50 Hz) | Referencja zakłócenia | Sygnał + zakłócenie |
| Kasowanie echa | Sygnał nadawany | Sygnał z mikrofonu |
| Korektor kanału | Odebrane symbole | Znane symbole treningowe |
| Identyfikacja układu | Pobudzenie | Wyjście nieznanego układu |

### Inne typowe algorytmy

- **Korelacja** — wykrywanie znanego wzorca w szumie (synchronizacja ramek, radar, GPS).
- **Detekcja obwiedni i fazy** — przetwarzanie kwadraturowe I/Q, transformata Hilberta.
- **Filtr medianowy** — usuwanie pojedynczych zakłóceń impulsowych (nieliniowy).
- **Filtr Kalmana** — estymacja stanu z modelem i szumem pomiaru (czujniki, nawigacja).

### DSP na mikrokontrolerze — zasady

- Próbkowanie z **timera sprzętowego** (nie z pętli programu), dane przez **DMA** do bufora.
- **Podwójne buforowanie** (ping-pong): przetwarzasz jeden bufor, gdy DMA wypełnia drugi.
- Budżet obliczeń: cykle na próbkę = $f_{CPU}/f_s$. Sprawdź, czy filtr się mieści.
- Biblioteki zoptymalizowane pod rdzeń (np. CMSIS-DSP dla ARM Cortex-M) zamiast własnych pętli.
- Testy: te same dane wejściowe w Pythonie i na mikrokontrolerze, porównanie wyników.

## Przykład rozwiązany

**Wykrywanie tonu DTMF 697 Hz**, $f_s = 8$ kHz, $N = 205$.

1. $k = \text{round}(205\cdot 697/8000) = \text{round}(17\text{,}86) = 18$.
2. $c = 2\cos(2\pi\cdot 18/205) \approx 1\text{,}703$.
3. Rozdzielczość $8000/205 \approx 39$ Hz — wystarcza do rozróżnienia częstotliwości DTMF (najbliższe różnią się o ok. 73 Hz).
4. Koszt dla 8 częstotliwości: ok. $8\cdot 205$ mnożeń na blok 25,6 ms — niewielki ułamek możliwości nawet prostego mikrokontrolera.

## Typowe pułapki

- **Goertzel z $N$ dobranym tak, że częstotliwość wypada między prążkami** — spadek czułości; dobiera się $N$ tak, aby $Nf/f_s$ było bliskie liczbie całkowitej dla wszystkich tonów.
- **Zbyt duże $\mu$ w LMS** — rozbieganie się współczynników; zbyt małe — bardzo wolna adaptacja.
- **Próbkowanie programowe w pętli** — jitter zamienia się w szum ([06.06](../06-sygnaly-i-systemy/06-probkowanie.md)).
- **Brak sprawdzenia budżetu czasu** — filtr nie nadąża i gubi próbki.

## Ćwiczenie komputerowe

```python
import numpy as np
def goertzel(x, k, N):
    c = 2*np.cos(2*np.pi*k/N); s1 = s2 = 0.0
    for v in x[:N]:
        s1, s2 = v + c*s1 - s2, s1
    return s1*s1 + s2*s2 - c*s1*s2
fs, N = 8000, 205
n = np.arange(N); x = np.sin(2*np.pi*697*n/fs) + np.sin(2*np.pi*1209*n/fs)
for f in [697, 770, 852, 941, 1209, 1336, 1477]:
    k = round(N*f/fs); print(f, "Hz:", round(goertzel(x, k, N)))
```

LMS — usuwanie zakłócenia 50 Hz z sygnału EKG-podobnego:

```python
import numpy as np
rng = np.random.default_rng(0); fs = 500; n = np.arange(5*fs)
s = np.sin(2*np.pi*1.2*n/fs)**63                       # „uderzenia serca”
d = s + 0.5*np.sin(2*np.pi*50*n/fs + 0.7)              # sygnał z zakłóceniem
ref = np.c_[np.sin(2*np.pi*50*n/fs), np.cos(2*np.pi*50*n/fs)]
w = np.zeros(2); mu = 0.02; e = np.zeros_like(d)
for i in range(len(d)):
    y = ref[i] @ w; e[i] = d[i] - y; w += mu*e[i]*ref[i]
print("resztkowe zakłócenie:", np.std(e[-fs:] - s[-fs:]))
```

## Zadania

1. Wyznacz $k$ i współczynnik $c$ algorytmu Goertzela dla 697 Hz, $f_s = 8$ kHz, $N = 205$.
2. Ile mnożeń na blok potrzeba do wykrycia 8 tonów DTMF Goertzelem, a ile przez FFT o długości 256?
3. Filtr LMS o długości 32, moc sygnału wejściowego 0,5. Jaki jest maksymalny krok $\mu$?
4. Mikrokontroler 72 MHz, $f_s = 48$ kHz. Ile cykli procesora przypada na próbkę? Czy zmieści się FIR o 128 współczynnikach (zakładając 1 cykl na MAC i 30% narzutu)?
5. Zaproponuj algorytm do usunięcia z sygnału pojedynczych, krótkich „szpilek” przy zachowaniu stromych zboczy sygnału użytecznego.

<details>
<summary>Odpowiedzi</summary>

1. $k = 18$, $c \approx 1\text{,}703$
2. Goertzel: ok. $8\cdot 205 = 1640$ mnożeń; FFT 256: ok. $128\cdot 8 = 1024$ mnożeń zespolonych (ok. 4000 rzeczywistych) — Goertzel jest tańszy przy kilku częstotliwościach i nie wymaga $N$ będącego potęgą 2
3. $\mu < \dfrac{2}{32\cdot 0\text{,}5} = 0\text{,}125$ (w praktyce wielokrotnie mniej)
4. 1500 cykli; FIR 128 współczynników to ok. $128\cdot 1\text{,}3 \approx 170$ cykli — mieści się z dużym zapasem
5. Filtr medianowy (np. 3- lub 5-punktowy) — usuwa wartości odstające, nie rozmywając zboczy jak filtr liniowy
</details>

## Źródła

- [The Scientist and Engineer's Guide to DSP](http://www.dspguide.com/) — rozdziały o zastosowaniach (audio, korelacja, filtry specjalne) i procesorach sygnałowych
- [Think DSP](https://greenteapress.com/wp/think-dsp/) — korelacja, sygnały dźwiękowe, praktyka w Pythonie
- [MIT RES.6-008 Digital Signal Processing](https://ocw.mit.edu/courses/res-6-008-digital-signal-processing-spring-2011/)
