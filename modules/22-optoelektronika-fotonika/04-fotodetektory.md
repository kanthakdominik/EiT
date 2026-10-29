# 22.04 — Fotodetektory

## Po co to jest

Fotodetektor zamienia moc optyczną na prąd. Od jego doboru zależy, czy odbiornik światłowodowy osiągnie 10 Gb/s, czy czujnik pulsu wykryje zmiany o 0,1%, czy dalmierz zobaczy słabe echo z 100 m. Trzeba znać cztery liczby: **responsywność** (ile prądu na wat), **prąd ciemny** (ile prądu bez światła), **pojemność** (jak szybko) i **szum** (ile światła najmniej).

## Teoria w pigułce

### Fotodioda

- Foton o energii $E \geq E_g$ generuje parę elektron–dziura; pole złącza rozdziela nośniki → **fotoprąd** płynący w kierunku zaporowym: $I_{ph} = \mathcal R\,P$.
- **Responsywność:** $\mathcal R = \eta\dfrac{q\lambda}{hc} = \eta\,\dfrac{\lambda[\mu\text{m}]}{1\text{,}24}$ [A/W], $\eta$ — sprawność kwantowa. Krzem przy 850 nm: idealnie 0,69 A/W, typowo 0,5–0,6 A/W; maksimum ok. 900–950 nm, spadek do zera przy 1100 nm.
- **Model:** źródło prądowe $I_{ph}$ równolegle z diodą, pojemnością złącza $C_j$ (zależną od napięcia wstecznego), rezystancją bocznikującą $R_{sh}$ (GΩ) i szeregową $R_s$.
- **Prąd ciemny** $I_d$ — prąd wsteczny bez światła; podwaja się co ok. 8–10 K.

### Tryby pracy

| Tryb | Polaryzacja | Zalety | Wady |
|---|---|---|---|
| **Fotowoltaiczny** (zerowe napięcie, wzmacniacz TIA) | 0 V | Brak prądu ciemnego (prawie), najmniejszy szum, liniowość | Większa pojemność, wolniej |
| **Fotoprzewodzący** (polaryzacja zaporowa) | −5…−100 V | Mniejsza $C_j$ → szybciej, szerszy zakres liniowości | Prąd ciemny i jego szum |
| **Ogniwo** (obciążenie rezystancyjne, bez polaryzacji) | — | Pozyskiwanie energii | Nieliniowe, wolne |

### Rodzaje detektorów

| Detektor | Cechy | Zastosowanie |
|---|---|---|
| Fotodioda p-n | Prosta, tania | Czujniki światła |
| **Fotodioda PIN** | Gruba warstwa intrinsic: mała $C_j$, szybka, dobra sprawność | Łącza optyczne, pomiary |
| **APD** (lawinowa) | Wzmocnienie wewnętrzne $M$ = 10–100, wymaga 50–200 V, nadmiarowy szum | Słabe sygnały, lidary, łącza dalekiego zasięgu |
| **SPAD / SiPM** | Zliczanie pojedynczych fotonów | Lidar ToF, PET, fizyka |
| **Fototranzystor** | Wzmocnienie $\beta$, wolny (µs) | Czujniki szczelinowe, transoptory |
| InGaAs, Ge | Czułe 900–1700 nm | Telekomunikacja 1310/1550 nm |

### Pasmo i szum

- Ograniczenie RC: $f_{-3\,\text{dB}} = \dfrac{1}{2\pi R_LC_j}$; dodatkowo czas przelotu nośników i dyfuzja (wolny „ogon” przy świetle wnikającym głęboko).
- **Szum śrutowy** fotoprądu i prądu ciemnego: $i_n = \sqrt{2q(I_{ph} + I_d)}$ [A/√Hz] ([21.06](../21-procesy-losowe-szum/06-szum-w-ukladach-elektronicznych.md)); szum termiczny obciążenia $\sqrt{4kT/R_L}$.
- **NEP** (moc równoważna szumowi) — moc optyczna, dla której SNR = 1 w paśmie 1 Hz: $\mathrm{NEP} = i_n/\mathcal R$ [W/√Hz].
- **Granica kwantowa:** przy braku innych szumów SNR = $\sqrt{N_{fot}\eta}$ — nie da się zmierzyć mocy dokładniej niż pozwala statystyka Poissona fotonów ([21.08](../21-procesy-losowe-szum/08-szum-waskopasmowy-i-procesy-punktowe.md)).

## Przykład rozwiązany

**Fotodioda krzemowa PIN przy 850 nm:** $\eta = 0\text{,}8$, $C_j = 10$ pF, $I_d = 1$ nA.

1. Responsywność: $\mathcal R = 0\text{,}8\cdot 0\text{,}85/1\text{,}24 = 0\text{,}55$ A/W; 1 µW → 0,55 µA.
2. Pasmo z obciążeniem 50 Ω: 318 MHz; z rezystorem 10 kΩ (większy sygnał napięciowy): 1,6 MHz — rezystor obciążenia zamienia czułość na pasmo. Wzmacniacz transimpedancyjny (temat 05) łagodzi ten kompromis.
3. NEP ograniczony prądem ciemnym: $\sqrt{2q\cdot 10^{-9}}/0\text{,}55 = 17\text{,}9\ \text{fA}/\sqrt{\text{Hz}}/0\text{,}55 = 33$ fW/√Hz. W paśmie 1 MHz: najmniejsza wykrywalna moc ok. 33 pW — w praktyce szum wzmacniacza jest zwykle znacznie większy.

## Typowe pułapki

- **Responsywność z innej długości fali** — dla 650 nm krzem ma ok. 0,35–0,45 A/W, nie 0,55.
- **Duża fotodioda „bo czulsza”** — większa powierzchnia to większa pojemność i prąd ciemny; dobieraj powierzchnię do plamki światła.
- **Światło otoczenia** — prąd od lampy lub słońca (DC i 100 Hz) potrafi przekroczyć sygnał tysiące razy i nasycić wzmacniacz; filtr optyczny, modulacja źródła i detekcja synchroniczna.
- **Prąd ciemny w wysokiej temperaturze** — podwaja się co ok. 10 K.
- **Fototranzystor w szybkim torze** — czasy rzędu µs (efekt Millera pojemności kolektor–baza).

## Ćwiczenie komputerowe

```python
import numpy as np

h, c, q, k = 6.62607015e-34, 2.99792458e8, 1.602176634e-19, 1.380649e-23

def responsivity(lam_nm, eta):
    return eta*q*lam_nm*1e-9/(h*c)

for lam, eta in ((650, 0.7), (850, 0.8), (950, 0.6)):
    print(f"{lam} nm, η = {eta}: R = {responsivity(lam, eta):.3f} A/W (idealnie {responsivity(lam, 1):.3f})")

R = responsivity(850, 0.8); Cj, Id, T = 10e-12, 1e-9, 300
for RL in (50, 1e3, 10e3, 1e6):
    bw = 1/(2*np.pi*RL*Cj)
    i_shot = np.sqrt(2*q*Id); i_th = np.sqrt(4*k*T/RL)
    nep = np.sqrt(i_shot**2 + i_th**2)/R
    print(f"R_L = {RL:9.0f} Ω: pasmo {bw/1e6:9.3f} MHz, NEP = {nep*1e15:8.1f} fW/√Hz, "
          f"min. moc w paśmie = {nep*np.sqrt(bw)*1e9:8.3f} nW")
```

Wynik pokazuje kompromis: duży rezystor obciążenia zmniejsza szum termiczny (mniejszy NEP), ale zawęża pasmo.

## Zadania

1. Fotodioda InGaAs ma $\eta = 0\text{,}85$ przy 1550 nm. Jaka jest responsywność? Jaki fotoprąd da moc −20 dBm?
2. Fotodioda $C_j = 50$ pF przy 0 V i 12 pF przy −10 V. Jakie pasmo z obciążeniem 1 kΩ w obu przypadkach?
3. Dlaczego w pomiarze słabego światła (np. fluorescencja) wybiera się tryb fotowoltaiczny?
4. APD o wzmocnieniu $M = 50$ daje 50 razy większy sygnał. Czy SNR rośnie 50 razy? Od czego to zależy?
5. Policz NEP fotodiody, której prąd ciemny wynosi 10 pA, a responsywność 0,5 A/W (pomiń inne szumy).

<details>
<summary>Odpowiedzi</summary>

1. $\mathcal R = 0\text{,}85\cdot 1\text{,}55/1\text{,}24 = 1\text{,}06$ A/W; −20 dBm = 10 µW → 10,6 µA
2. 3,2 MHz i 13,3 MHz
3. Przy zerowym napięciu prąd ciemny (i jego szum śrutowy) praktycznie znika, a rezystancja bocznikująca jest bardzo duża — najmniejszy szum i dryf; szybkość nie jest wtedy priorytetem
4. Nie — APD wzmacnia też szum śrutowy, z dodatkowym czynnikiem nadmiarowym $F(M)$. SNR rośnie, dopóki dominuje szum wzmacniacza (który nie jest mnożony); gdy dominuje szum śrutowy wzmocniony, dalsze zwiększanie $M$ pogarsza SNR — istnieje optymalne $M$
5. $\sqrt{2q\cdot 10^{-11}} = 1\text{,}79$ fA/√Hz; NEP = 3,6 fW/√Hz
</details>

## Źródła

- [Hamamatsu — Si photodiodes: technical information (PDF)](https://www.hamamatsu.com/resources/pdf/ssd/si_pd_kspd0001e.pdf) — parametry, układy pracy, szum
- [RP Photonics Encyclopedia](https://www.rp-photonics.com/encyclopedia.html) — hasła: photodiodes, avalanche photodiodes, responsivity, noise-equivalent power
- [21.06 Szum w układach elektronicznych](../21-procesy-losowe-szum/06-szum-w-ukladach-elektronicznych.md)
