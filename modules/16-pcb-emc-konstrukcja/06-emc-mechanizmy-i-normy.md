# 16.06 — EMC: mechanizmy, normy i badania wstępne

## Po co to jest

Urządzenie elektroniczne wprowadzane na rynek musi spełniać wymagania kompatybilności elektromagnetycznej: nie zakłócać innych (emisja) i działać mimo zakłóceń (odporność). Nieudane badania w laboratorium akredytowanym to tygodnie opóźnienia i kolejne wersje płytki. Znajomość mechanizmów pozwala projektować „od razu dobrze”, a proste badania wstępne we własnym zakresie wyłapują większość problemów wcześnie.

## Teoria w pigułce

### Model źródło – sprzężenie – odbiornik

Każdy problem EMC ma źródło (szybkie zbocza, przetwornice, zegary), drogę sprzężenia i odbiornik. Rozwiązanie: osłabić źródło, przerwać drogę albo uodpornić odbiornik.

| Droga sprzężenia | Mechanizm | Przeciwdziałanie |
|---|---|---|
| **Przewodzona** | Przez wspólne zasilanie, masę, kable | Filtry, odsprzęganie, separacja mas ([16.05](05-masa-i-uklady-mieszane.md)) |
| **Pojemnościowa** (pole E) | Węzły o dużym $dV/dt$ blisko innych przewodników | Małe powierzchnie węzłów przełączających, odległość, ekran uziemiony |
| **Indukcyjna** (pole H) | Pętle o dużym $dI/dt$ | Małe pętle, skrętki, płaszczyzny |
| **Promieniowana** | Kable i szczeliny jako anteny | Filtry na kablach, ekranowanie, dławiki wspólne |

### Emisja różnicowa i wspólna

**Różnicowa (DM)** — pętla prądu sygnału i jego powrotu działa jak mała antena pętlowa (pole daleko, nad płaszczyzną odbijającą):

$$E_{DM} \approx 2\text{,}63\cdot 10^{-14}\,\frac{f^2AI}{r}\ \ [\text{V/m}]$$

**Wspólna (CM)** — prąd płynący w tę samą stronę po wszystkich przewodach kabla (kabel jako antena monopolowa, krótka względem λ):

$$E_{CM} \approx 1\text{,}26\cdot 10^{-6}\,\frac{fLI}{r}\ \ [\text{V/m}]$$

Wniosek z porównania: **kilka mikroamperów prądu wspólnego na kablu wystarcza do przekroczenia limitów**, podczas gdy emisja różnicowa wymaga miliamperów w dużych pętlach. Kable są zwykle głównym promiennikiem; prąd wspólny powstaje m.in. przez spadki napięcia na masie płytki między punktami podłączenia kabli.

### Normy (przegląd)

W UE — dyrektywa EMC i normy zharmonizowane; dla sprzętu multimedialnego i IT emisja według EN 55032 (CISPR 32), odporność EN 55035; dla środowiska przemysłowego normy ogólne EN 61000-6-x; osobne normy dla motoryzacji, medycyny, urządzeń radiowych (dyrektywa RED). Wartości orientacyjne (sprawdź aktualne wydania norm):

| Badanie | Zakres | Przykładowe wymagania |
|---|---|---|
| Emisja przewodzona (zasilanie AC) | 150 kHz – 30 MHz | klasa B: ok. 66–56 dBµV (quasi-peak, malejąco) do 0,5 MHz, 56 dBµV do 5 MHz, 60 dBµV do 30 MHz |
| Emisja promieniowana | 30 MHz – 1 GHz (wyżej dla szybkich urządzeń) | klasa B przy 10 m: ok. 30 dBµV/m (30–230 MHz), 37 dBµV/m (230 MHz–1 GHz); przy 3 m o ok. 10 dB więcej |
| ESD (IEC 61000-4-2) | — | typowo ±4 kV kontaktowo, ±8 kV w powietrzu (poziomy do ±8/±15 kV) |
| Odporność na pole w.cz. (61000-4-3) | 80 MHz – 6 GHz | 3 V/m (dom), 10 V/m (przemysł) |
| Szybkie stany przejściowe EFT (61000-4-4), udary (61000-4-5), zaburzenia przewodzone (61000-4-6), spadki napięcia | — | Zależnie od środowiska |

Klasa A — środowisko przemysłowe (luźniejsze limity emisji), klasa B — mieszkalne.

### Badania wstępne (pre-compliance)

- **Sondy pola bliskiego** (H — pętla, E — krótki pręt) + analizator widma lub SDR: lokalizacja źródeł na płytce.
- **Cęgi prądowe w.cz.** na kablu: pomiar prądu wspólnego → szacowanie emisji wzorem $E_{CM}$.
- **LISN** (sieć sztuczna) + analizator: emisja przewodzona.
- Prosty generator ESD (pistolet) i próby na złączach i obudowie.
- Porównanie „przed i po” każdej zmiany zamiast wartości bezwzględnych.

## Przykład rozwiązany

1. **Emisja DM:** pętla 1 cm², prąd 10 mA przy 100 MHz, 3 m: $E = 2\text{,}63\cdot 10^{-14}\cdot 10^{16}\cdot 10^{-4}\cdot 0\text{,}01/3 \approx 88$ µV/m = **39 dBµV/m** — prawie na limicie klasy B przy 3 m (ok. 40 dBµV/m). Mniejsza pętla (płaszczyzna masy) — proporcjonalnie mniej.
2. **Emisja CM:** kabel 1 m, prąd wspólny 5 µA przy 100 MHz, 3 m: $E = 1\text{,}26\cdot 10^{-6}\cdot 10^8\cdot 1\cdot 5\cdot 10^{-6}/3 \approx 210$ µV/m = **46 dBµV/m** — przekroczenie o ok. 6 dB. Limit odpowiada ok. **2,4 µA** prądu wspólnego.
3. Wniosek: dławik wspólny lub ferryt na kablu (+10–20 dB tłumienia prądu CM), filtr przy złączu, lepsza masa w miejscu wejścia kabla.

## Typowe pułapki

- **EMC „na końcu projektu”** — po zaprojektowaniu obudowy i płytki pole manewru jest małe.
- **Kable pominięte w analizie** — to one najczęściej promieniują.
- **Przetwornica o zmiennej częstotliwości** (tryb oszczędny) przesuwająca zakłócenia w pasma czułe (np. radio w urządzeniu).
- **Testy wstępne bez kabli docelowych** i w innej konfiguracji niż użytkowanie.
- **Złe łączenie ekranu** i brak filtracji na złączu — ekran wprowadza zakłócenia do środka.

## Ćwiczenie komputerowe

Szacowanie emisji DM i CM, porównanie z przykładowym limitem i dopuszczalny prąd wspólny w funkcji częstotliwości:

```python
import numpy as np

dbuv = lambda E: 20*np.log10(E/1e-6)
def E_dm(f, A, I, r=3): return 2.63e-14*f**2*A*I/r
def E_cm(f, L, I, r=3): return 1.26e-6*f*L*I/r
limit_3m = lambda f: 40 if f < 230e6 else 47                  # orientacyjny limit klasy B przy 3 m [dBµV/m]

for f in [30e6, 100e6, 300e6, 900e6]:
    dm = dbuv(E_dm(f, 1e-4, 0.01)); cm = dbuv(E_cm(f, 1.0, 5e-6))
    Imax = 10**(limit_3m(f)/20)*1e-6*3/(1.26e-6*f*1.0)
    print(f"{f/1e6:5.0f} MHz: DM(1 cm², 10 mA) = {dm:5.1f}, CM(1 m, 5 µA) = {cm:5.1f}, limit {limit_3m(f)} dBµV/m, "
          f"maks. prąd CM = {Imax*1e6:.2f} µA")
```

Uwaga: dla kabla dłuższego niż ok. λ/4 wzór dla krótkiej anteny przestaje obowiązywać (emisja przestaje rosnąć z częstotliwością) — dlatego przy 900 MHz wynik jest przeszacowany.

## Zadania

1. Policz emisję DM pętli 4 cm² z prądem 20 mA przy 200 MHz w odległości 3 m.
2. Jaki prąd wspólny na kablu 1,5 m przy 150 MHz daje 40 dBµV/m w 3 m?
3. Dlaczego zmniejszenie pola pętli dwukrotnie obniża emisję DM o 6 dB, a skrócenie zbocza dwukrotnie może ją podnieść znacznie bardziej w zakresie wysokich częstotliwości?
4. Wymień trzy badania odporności, które przejdzie typowe urządzenie przemysłowe.
5. Jak wykorzystasz sondę pola bliskiego i analizator widma do znalezienia źródła zakłócenia o częstotliwości 96 MHz?

<details>
<summary>Odpowiedzi</summary>

1. $2\text{,}63\cdot 10^{-14}\cdot 4\cdot 10^{16}\cdot 4\cdot 10^{-4}\cdot 0\text{,}02/3 \approx 2\text{,}8$ mV/m ≈ 69 dBµV/m — o ok. 29 dB za dużo
2. $I = 100\cdot 10^{-6}\cdot 3/(1\text{,}26\cdot 10^{-6}\cdot 1\text{,}5\cdot 10^8\cdot 1\text{,}5) \approx 1\text{,}06$ µA
3. Emisja jest proporcjonalna do pola pętli (−6 dB), ale widmo sygnału trapezowego powyżej $1/(\pi t_r)$ spada o 40 dB/dek; krótsze zbocze przesuwa ten punkt w górę i podnosi harmoniczne o wiele dB, a emisja pętli rośnie jak $f^2$
4. ESD (61000-4-2), odporność na pole w.cz. (61000-4-3), EFT/burst (61000-4-4), udary (61000-4-5), zaburzenia przewodzone (61000-4-6)
5. Zidentyfikuj, czego harmoniczną jest 96 MHz (np. 8 × 12 MHz kwarcu, 192 × 500 kHz przetwornicy); przesuwaj sondę H nad płytką, szukając maksimum sygnału przy tej częstotliwości; sprawdź kable cęgami; zmiana konfiguracji (wyłączenie bloku, zmiana częstotliwości) potwierdza źródło
</details>

## Źródła

- [LearnEMC](https://learnemc.com/) — mechanizmy emisji, zasady projektowania, kalkulatory
- [Electromagnetics, Vol. 2 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-2) — promieniowanie pętli i dipoli (podstawy wzorów)
- [08.07 Zakłócenia i ekranowanie](../08-miernictwo/07-zaklocenia-i-ekranowanie.md)
- H. Ott — *Electromagnetic Compatibility Engineering* (płatna) — źródło wzorów szacunkowych na emisję DM i CM
- Normy z serii EN 55032/55035 i IEC/EN 61000-4-x (płatne) — wymagania i metody badań
