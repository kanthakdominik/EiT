# 22.08 — Czujniki optyczne i obrazowe

## Po co to jest

Czujniki optyczne mierzą bez kontaktu: odległość (dalmierze, lidary, ToF w telefonach), obecność i położenie (bariery, enkodery), skład i stężenie (pulsoksymetr, czujniki gazów NDIR, spektrometry), a matryce obrazowe — wszystko naraz. Każdy z nich składa się z elementów z poprzednich tematów: źródła, toru optycznego, detektora i wzmacniacza — plus przetwarzania sygnału, które wyciąga słaby sygnał z szumu i światła otoczenia.

## Teoria w pigułce

### Detekcja synchroniczna (lock-in)

Źródło modulowane z częstotliwością $f_m$; odbiornik mnoży sygnał przez sygnał odniesienia i uśrednia. Światło otoczenia (DC, 100 Hz) i szum poza wąskim pasmem wokół $f_m$ są odrzucane — pasmo szumowe zawęża się do $\approx 1/(2T_{uśr})$. Stosowane w pulsoksymetrach, czujnikach zbliżeniowych, pomiarach słabej fluorescencji.

### Pomiar odległości

| Metoda | Zasada | Rozdzielczość / zasięg |
|---|---|---|
| **Triangulacja** | Przesunięcie plamki na detektorze pozycyjnym | mm–µm, do kilku m |
| **ToF impulsowy** (lidar) | $d = c\,\Delta t/2$ | 1 ns → 15 cm; zasięg 1–300 m |
| **ToF fazowy** (AM-CW) | Przesunięcie fazy modulacji: $d = \dfrac{c\,\Delta\varphi}{4\pi f_m}$ | Zasięg jednoznaczności $c/(2f_m)$ |
| **Interferometria** | Prążki interferencyjne | Ułamki długości fali |

### Czujniki obrazu

- Piksel = fotodioda + kondensator całkujący ładunek; **CCD** (przesuwanie ładunku) i **CMOS** (wzmacniacz w każdym pikselu — dominujący dziś).
- **Pojemność studni** (full well) $N_{max}$ [e⁻], **szum odczytu** $\sigma_r$ [e⁻], **sprawność kwantowa** QE, prąd ciemny [e⁻/s].
- **Zakres dynamiki:** $DR = 20\log_{10}(N_{max}/\sigma_r)$ dB.
- **SNR piksela** przy $N$ elektronach sygnału: $\mathrm{SNR} = \dfrac{N}{\sqrt{N + N_d + \sigma_r^2}}$ — przy dużym oświetleniu ograniczony szumem fotonowym ($\sqrt N$), przy słabym — szumem odczytu.
- Kolor: filtr Bayera (RGGB) i interpolacja; przesłona migawki: rolling vs global shutter (zniekształcenia ruchu).

### Inne czujniki

- **Enkodery optyczne** — tarcza z prążkami + fotodetektory w kwadraturze (kierunek ruchu, [09.03](../09-mikrokontrolery-embedded/03-timery-i-pwm.md)).
- **Pulsoksymetria** — stosunek modulacji tętniczej przy dwóch długościach fali (660 i 940 nm), detekcja synchroniczna, kalibracja empiryczna.
- **Czujniki NDIR** (CO₂) — pochłanianie podczerwieni przy 4,26 µm, termostos lub fotodioda + filtr.

## Przykład rozwiązany

**Matryca CMOS:** pojemność studni 10 000 e⁻, szum odczytu 3 e⁻, prąd ciemny pomijalny.

- Zakres dynamiki: $20\log_{10}(10\,000/3) = 70\text{,}5$ dB (ok. 11,7 bita — przetwornik 12-bitowy wystarcza).
- Maksymalny SNR (pełna studnia): $\sqrt{10\,000} = 100$ → **40 dB**; nawet idealny czujnik nie da więcej przy jednym naświetleniu.
- Przy 100 e⁻ (słabe światło): $\mathrm{SNR} = 100/\sqrt{100 + 9} = 9\text{,}6$ (19,6 dB) — szum fotonowy nadal dominuje; przy 10 e⁻: $10/\sqrt{19} = 2\text{,}3$ — tu dominuje szum odczytu.

**Lidar ToF:** obiekt w 100 m → czas przelotu w obie strony $2\cdot 100/c = 667$ ns; rozdzielczość odległości 15 cm wymaga pomiaru czasu z dokładnością 1 ns (przetworniki czasowo-cyfrowe, TDC).

## Typowe pułapki

- **Światło otoczenia** traktowane jak „mała poprawka” — słońce daje ok. 1000 W/m², wielokrotnie więcej niż sygnał czujnika; potrzebne filtry optyczne, modulacja, różnicowanie.
- **Odbicia i przesłuchy** w obudowie między nadajnikiem a odbiornikiem (czujnik zbliżeniowy pod szybką).
- **Wiara w liczbę megapikseli** — mniejszy piksel ma mniejszą studnię i gorszy SNR przy słabym świetle.
- **Nieuwzględnienie ruchu** przy rolling shutter.
- **Bezpieczeństwo oczu** dla lidarów z laserami impulsowymi dużej mocy szczytowej.

## Ćwiczenie komputerowe

SNR piksela w funkcji oświetlenia i detekcja synchroniczna słabego sygnału w świetle otoczenia:

```python
import numpy as np

# SNR piksela
full_well, read_noise = 10_000, 3.0
print(f"zakres dynamiki = {20*np.log10(full_well/read_noise):.1f} dB")
for N in (10, 100, 1000, 10_000):
    snr = N/np.sqrt(N + read_noise**2)
    print(f"N = {N:6d} e⁻: SNR = {snr:7.1f} ({20*np.log10(snr):5.1f} dB)")

# detekcja synchroniczna: sygnał 1 nA modulowany 1 kHz, światło otoczenia 1 µA (DC + 100 Hz), szum biały
rng = np.random.default_rng(0)
fs, N = 100_000, 100_000                                        # 1 s
t = np.arange(N)/fs
on = (np.arange(N) % 100) < 50                                  # LED włączana i wyłączana z 1 kHz (50 próbek na pół okresu)
sig = 1e-9*on
ambient = 1e-6*(1 + 0.3*np.sin(2*np.pi*100*t))
noise = rng.normal(0, 5e-9, N)                                  # szum 5 nA RMS w paśmie 50 kHz
x = sig + ambient + noise
ref = np.where(on, 1.0, -1.0)                                   # odniesienie ±1 zsynchronizowane z LED
est = 2*np.mean(x*ref)                                          # amplituda międzyszczytowa sygnału (prostokąt 0..A)
print(f"sygnał 1 nA w tle 1 µA i szumie 5 nA RMS: wynik detekcji synchronicznej = {est*1e9:.3f} nA")
```

Mimo że światło otoczenia jest 1000 razy silniejsze, a szum 5 razy większy od sygnału, detekcja synchroniczna z uśrednianiem przez 1 s odtwarza sygnał z błędem rzędu kilku procent (odchylenie standardowe wyniku: $2\cdot 5\ \text{nA}/\sqrt{10^5} \approx 0\text{,}03$ nA).

## Zadania

1. Matryca ma studnię 30 000 e⁻ i szum odczytu 1,5 e⁻. Jaki zakres dynamiki i maksymalny SNR?
2. ToF fazowy z modulacją 20 MHz. Jaki jest zasięg jednoznaczności? Jakiemu przesunięciu fazy odpowiada 1 cm?
3. Lidar ma mierzyć z rozdzielczością 3 cm. Z jaką rozdzielczością czasową trzeba mierzyć?
4. Dlaczego pulsoksymetr mierzy przy dwóch długościach fali, a nie przy jednej?
5. Jak zmieni się SNR detekcji synchronicznej, gdy czas uśredniania wydłużymy 4-krotnie?

<details>
<summary>Odpowiedzi</summary>

1. $20\log_{10}(30\,000/1\text{,}5) = 86$ dB; $\sqrt{30\,000} = 173$ (44,8 dB)
2. $c/(2f_m) = 7\text{,}5$ m; $\Delta\varphi = 4\pi f_m d/c = 4\pi\cdot 2\cdot 10^7\cdot 0\text{,}01/3\cdot 10^8 = 8\text{,}4$ mrad (0,48°)
3. $\Delta t = 2d/c = 200$ ps
4. Absorpcja hemoglobiny utlenowanej i odtlenowanej różnie zależy od długości fali (przy 660 nm różnica jest duża, przy 940 nm — odwrotna); stosunek modulacji przy dwóch długościach fali eliminuje nieznane czynniki (grubość tkanki, sprzężenie optyczne, jasność LED) i daje saturację
5. Pasmo szumowe maleje 4 razy → szum ($\propto\sqrt{B}$) maleje 2 razy → SNR rośnie 2 razy (6 dB)
</details>

## Źródła

- [RP Photonics Encyclopedia](https://www.rp-photonics.com/encyclopedia.html) — hasła: image sensors, lidar, time-of-flight, lock-in amplifiers
- [Hamamatsu — Si photodiodes: technical information (PDF)](https://www.hamamatsu.com/resources/pdf/ssd/si_pd_kspd0001e.pdf) — detektory pozycyjne, matryce
- [21.08 Szum wąskopasmowy i procesy punktowe](../21-procesy-losowe-szum/08-szum-waskopasmowy-i-procesy-punktowe.md) — statystyka fotonów
