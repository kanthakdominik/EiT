# 24.08 — Akustyka pomieszczeń i pomiary

## Po co to jest

W pomieszczeniu słuchacz słyszy nie tylko głośnik, ale także tysiące odbić. Przy niskich częstotliwościach pomieszczenie zmienia charakterystykę o ±10–20 dB (mody), przy wysokich — dokłada pogłos. Dlatego zestaw dobrze zmierzony w komorze bezechowej może brzmieć źle w salonie, a sala konferencyjna z twardymi ścianami — być niezrozumiała. Ten temat liczy czas pogłosu i mody, a także opisuje, jak mierzy się charakterystykę systemu audio w warunkach domowych.

## Teoria w pigułce

### Pogłos

- **Wzór Sabine'a:** $T_{60} = \dfrac{0\text{,}161\,V}{A}$, $A = \sum S_i\alpha_i$ [m² — „sabiny”], $V$ — objętość [m³], $\alpha$ — współczynnik pochłaniania (beton 0,02, tynk 0,03–0,05, dywan 0,1–0,4, panel akustyczny 0,5–1, otwarte okno 1; silnie zależny od częstotliwości).
- **Wzór Eyringa** — dokładniejszy dla pomieszczeń silnie wytłumionych: $T_{60} = \dfrac{0\text{,}161\,V}{-S\ln(1 - \bar\alpha)}$.
- Zalecane: pokój odsłuchowy 0,3–0,5 s, sala wykładowa 0,6–1 s, sala koncertowa 1,8–2,2 s.
- **Odległość krytyczna** (pole bezpośrednie = pogłosowe): $r_c \approx 0\text{,}057\sqrt{\dfrac{QV}{T_{60}}}$ [m], $Q$ — kierunkowość źródła. Dalej od źródła poziom praktycznie nie maleje z odległością, a zrozumiałość mowy spada.

### Mody

Fale stojące między ścianami. Mod osiowy wzdłuż wymiaru $L$: $f_n = \dfrac{nc}{2L}$; ogólnie

$$f_{n_x n_y n_z} = \frac c2\sqrt{\left(\frac{n_x}{L_x}\right)^2 + \left(\frac{n_y}{L_y}\right)^2 + \left(\frac{n_z}{L_z}\right)^2}$$

- Poniżej **częstotliwości Schroedera** $f_S \approx 2000\sqrt{T_{60}/V}$ dominują pojedyncze mody (charakterystyka „górzysta”, zależna od miejsca); powyżej pole jest statystycznie rozproszone.
- Proporcje pomieszczenia (unikanie wymiarów będących wielokrotnościami), położenie głośników i słuchacza (nie w połowie i nie przy ścianach), pułapki basowe, korekcja DSP (tylko podbić; dołków nie da się „podnieść”) i kilka subwooferów.

### Pomiar charakterystyki

- **Sygnał przemiatany wykładniczo** (metoda Farina): sinus o częstotliwości rosnącej wykładniczo, odpowiedź splatana z odwrotnym filtrem → odpowiedź impulsowa; zniekształcenia harmoniczne oddzielają się w czasie (przed odpowiedzią liniową). Dobry stosunek sygnału do szumu, odporność na nieliniowość.
- Alternatywy: MLS (sekwencje pseudolosowe), szum różowy z analizatorem tercjowym (RTA).
- **Oknowanie czasowe** odpowiedzi impulsowej: obcięcie przed pierwszym odbiciem daje charakterystykę „quasi-bezechową” — ale tylko powyżej $1/T_{okna}$ (5 ms → 200 Hz).
- **Pomiar w polu bliskim** membrany (kilka mm) dla niskich częstotliwości, sklejany z pomiarem oknowanym.
- Mikrofon pomiarowy z indywidualnym plikiem kalibracji, interfejs audio z pętlą odniesienia (pomiar opóźnienia), program (np. REW — Room EQ Wizard).
- Pogłos z odpowiedzi impulsowej: całkowanie wsteczne Schroedera, odczyt T20/T30 (spadek o 20/30 dB ekstrapolowany do 60 dB).

## Przykład rozwiązany

**Pokój 5 × 4 × 2,7 m,** średni współczynnik pochłaniania 0,15.

1. $V = 54$ m³, $S = 2\cdot 20 + 2\cdot(5 + 4)\cdot 2\text{,}7 = 88\text{,}6$ m², $A = 13\text{,}3$ m².
2. $T_{60} = 0\text{,}161\cdot 54/13\text{,}3 = 0\text{,}65$ s — za długo dla pokoju odsłuchowego.
3. 10 m² paneli ($\alpha = 0\text{,}8$) zamiast ściany ($\alpha = 0\text{,}15$): $A = 13\text{,}3 + 10\cdot 0\text{,}65 = 19\text{,}8$ m² → $T_{60} = 0\text{,}44$ s.
4. Mody osiowe pierwszego rzędu: $343/10 = 34\text{,}3$ Hz, $343/8 = 42\text{,}9$ Hz, $343/5\text{,}4 = 63\text{,}5$ Hz; częstotliwość Schroedera $2000\sqrt{0\text{,}65/54} \approx 220$ Hz.
5. Odległość krytyczna (głośnik $Q = 2$): $0\text{,}057\sqrt{2\cdot 54/0\text{,}65} = 0\text{,}73$ m — słuchacz w 2–3 m słyszy głównie pole pogłosowe.

## Typowe pułapki

- **Korekcja DSP dołków modowych** — wymaga ogromnych podbić, przesterowuje wzmacniacz i głośnik, a w innym miejscu pokoju pogarsza wynik.
- **Panele piankowe „na bas”** — cienkie materiały pochłaniają tylko wysokie częstotliwości; bas wymaga grubych ustrojów lub rezonatorów.
- **Pomiar w jednym punkcie** — charakterystyka modowa zmienia się co kilkadziesiąt cm; uśrednia się kilka pozycji.
- **Okno czasowe dłuższe niż czas do pierwszego odbicia** przy pomiarze głośnika.
- **Brak kalibracji mikrofonu i toru** — błędy kilku dB na skrajach pasma.

## Ćwiczenie komputerowe

Czas pogłosu, mody pomieszczenia i pomiar odpowiedzi impulsowej sygnałem przemiatanym (symulowany „pokój”):

```python
import numpy as np
from scipy import signal

# Sabine i Eyring
Lx, Ly, Lz, alpha = 5.0, 4.0, 2.7, 0.15
V = Lx*Ly*Lz; S = 2*(Lx*Ly + Lx*Lz + Ly*Lz)
print(f"V = {V:.0f} m³, S = {S:.1f} m², Sabine T60 = {0.161*V/(S*alpha):.2f} s, Eyring T60 = {0.161*V/(-S*np.log(1 - alpha)):.2f} s")

# mody do 120 Hz
c = 343.0
modes = sorted((c/2*np.sqrt((i/Lx)**2 + (j/Ly)**2 + (k/Lz)**2), (i, j, k))
               for i in range(4) for j in range(4) for k in range(3) if (i, j, k) != (0, 0, 0))
print("mody < 120 Hz:", ", ".join(f"{f:.0f} Hz {m}" for f, m in modes if f < 120))

# pomiar: sweep wykładniczy 20 Hz–20 kHz, „pokój” = opóźnienie 3 ms + odbicie + zanik wykładniczy szumu
fs, T = 48_000, 3.0
t = np.arange(int(fs*T))/fs
f1, f2 = 20.0, 20_000.0
R = np.log(f2/f1)
sweep = np.sin(2*np.pi*f1*T/R*(np.exp(t*R/T) - 1))
inv = sweep[::-1]*np.exp(-t*R/T)                     # filtr odwrotny (kompensacja widma różowego)
rng = np.random.default_rng(0)
n_ir = int(0.6*fs)
room = np.zeros(n_ir); room[int(0.003*fs)] = 1.0; room[int(0.009*fs)] = 0.5
tail = rng.normal(0, 1, n_ir)*np.exp(-6.91*np.arange(n_ir)/fs/0.5)*0.05   # T60 = 0,5 s
room += tail
recorded = signal.fftconvolve(sweep, room)[:len(sweep) + n_ir]
ir = signal.fftconvolve(recorded, inv)
ir = ir[len(sweep) - 1:len(sweep) - 1 + n_ir]
ir /= np.max(np.abs(ir))
peak = np.argmax(np.abs(ir))
print(f"odtworzona odpowiedź impulsowa: główny impuls po {peak/fs*1e3:.2f} ms")

# całkowanie wsteczne Schroedera i odczyt T20 z ogona (po bezpośrednim dźwięku)
e = ir[peak + int(0.012*fs):]**2
edc = 10*np.log10(np.cumsum(e[::-1])[::-1]/np.sum(e))
i5, i25 = np.argmax(edc < -5), np.argmax(edc < -25)
print(f"T20 z ogona: {3*(i25 - i5)/fs:.2f} s (model: 0,50 s)")
```

## Zadania

1. Sala 20 × 12 × 6 m, $A = 300$ m². Ile wynosi $T_{60}$? Ile pochłaniania trzeba dodać, by uzyskać 1 s?
2. Pierwszy mod osiowy pokoju o długości 6 m?
3. Okno czasowe pomiaru głośnika wynosi 4 ms. Od jakiej częstotliwości charakterystyka jest wiarygodna?
4. Dlaczego sygnał przemiatany wykładniczo pozwala oddzielić zniekształcenia harmoniczne od odpowiedzi liniowej?
5. Dlaczego dwa subwoofery w różnych miejscach pokoju dają bardziej równomierny bas niż jeden?

<details>
<summary>Odpowiedzi</summary>

1. $V = 1440$ m³; $T_{60} = 0\text{,}161\cdot 1440/300 = 0\text{,}77$ s; na 1 s potrzeba $A = 232$ m² — trzeba **zmniejszyć** pochłanianie o ok. 68 m² (sala jest już „za sucha” względem celu 1 s)
2. $343/(2\cdot 6) = 28\text{,}6$ Hz
3. Ok. $1/4\ \text{ms} = 250$ Hz (rozdzielczość częstotliwościowa okna)
4. Harmoniczna rzędu $k$ sygnału przemiatanego wykładniczo pojawia się wcześniej o stały czas $\Delta t = T\ln k/\ln(f_2/f_1)$ — po splocie z filtrem odwrotnym produkty zniekształceń trafiają przed główną odpowiedź impulsową i można je wyciąć oknem
5. Każdy subwoofer pobudza mody inaczej (różne położenie względem węzłów i strzałek); suma ich pól wyrównuje maksima i minima w obszarze słuchania, a odpowiednie położenie (np. środki przeciwległych ścian) może wręcz wygasić niektóre mody
</details>

## Źródła

- [Stanford CCRMA — książki online J. O. Smitha](https://ccrma.stanford.edu/~jos/EE201/Related_Online_Books_CCRMA.html) — akustyka pomieszczeń, odpowiedź impulsowa
- [sengpielaudio — kalkulatory](https://sengpielaudio.com/Calculations03.htm)
- [MIT 21M.380 Music and Technology: Sound Design](https://ocw.mit.edu/courses/21m-380-music-and-technology-sound-design-spring-2016/)
- F. A. Everest, K. C. Pohlmann — *Master Handbook of Acoustics* (płatna)
