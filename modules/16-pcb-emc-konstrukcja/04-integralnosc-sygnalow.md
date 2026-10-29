# 16.04 — Integralność sygnałów

## Po co to jest

Sygnał cyfrowy na płytce to fala na linii transmisyjnej, a nie „przewód z zerami i jedynkami”. Odbicia, przesłuchy i zakłócenia od nieciągłości ścieżki powrotnej powodują błędy, które pojawiają się dopiero w niektórych egzemplarzach, temperaturach czy przy dłuższych kablach. Integralność sygnałów (SI) to zastosowanie teorii linii ([11.03](../11-pole-em-linie-anteny/03-linie-transmisyjne.md), [11.05](../11-pole-em-linie-anteny/05-stany-nieustalone-na-liniach.md)) do projektowania płytek.

## Teoria w pigułce

### Kiedy ścieżka jest linią

Gdy czas propagacji jest porównywalny z czasem narastania: $t_d > t_r/6$ (do $t_r/4$) — [11.05](../11-pole-em-linie-anteny/05-stany-nieustalone-na-liniach.md). Pasmo sygnału: $f_{knee} \approx 0\text{,}35/t_r$ — **to czas narastania wyjścia, a nie częstotliwość zegara, decyduje o problemach**. Nowoczesne mikrokontrolery mają zbocza 1–5 ns już przy najwolniejszej konfiguracji pinu „high speed”.

### Ścieżka powrotna

Każdy prąd wraca do źródła. Przy niskich częstotliwościach — drogą najmniejszej rezystancji, **przy wysokich — drogą najmniejszej indukcyjności, czyli w płaszczyźnie odniesienia tuż pod ścieżką**. Skutki:
- **przerwa w płaszczyźnie** pod ścieżką (podział, rząd przelotek, wycięcie) zmusza prąd do objazdu: duża pętla → impedancja, przesłuchy, emisja;
- **zmiana warstwy** ścieżki zmienia płaszczyznę odniesienia — przy przelotce sygnałowej potrzebna **przelotka masy obok** (lub kondensator, jeśli płaszczyzny mają różne potencjały);
- ścieżka przy krawędzi płaszczyzny — gorsze odniesienie.

### Impedancja kontrolowana i terminacja

Szybkie sygnały (USB, Ethernet, HDMI, LVDS, DDR, w.cz.) wymagają ścieżek o zadanej impedancji (50 Ω pojedyncze, 90/100 Ω różnicowe), zamawianych z kontrolą impedancji u producenta. Terminacja — [11.05](../11-pole-em-linie-anteny/05-stany-nieustalone-na-liniach.md): szeregowa przy źródle dla linii punkt–punkt (często rezystor 22–33 Ω przy wyjściu zegara lub SPI), równoległa/różnicowa przy odbiorniku.

### Przesłuchy

Sprzężenie pojemnościowe i indukcyjne sąsiednich ścieżek. Na końcu bliskim (NEXT) i dalekim (FEXT). Przybliżenie dla ścieżek nad płaszczyzną (Johnson): $X \approx \dfrac{K}{1 + (D/H)^2}$ ($D$ — odstęp osi ścieżek, $H$ — wysokość nad płaszczyzną). Wniosek: **przesłuch spada szybko z odstępem i rośnie z wysokością nad masą** — dlatego cienki dielektryk do płaszczyzny pomaga. Reguła praktyczna „3W” (odstęp osi ≥ 3 szerokości ścieżki) dla sygnałów wrażliwych; zegary i sygnały szybkie z dala od wolnych linii wychodzących na złącza.

### Pary różnicowe

Dwie ścieżki o przeciwnych sygnałach, sprzężone ze sobą: impedancja różnicowa (np. 90 Ω USB, 100 Ω Ethernet), **równe długości** (różnica powoduje konwersję na tryb wspólny — emisja), stały odstęp, symetryczne prowadzenie, przelotki parami. Odporność na zakłócenia wspólne i mała emisja.

### Synchronizacja i długości

Magistrale równoległe (pamięci, RGB) wymagają wyrównania długości (opóźnienia) w grupie; w FR-4 ok. 6–7 ps/mm (mikropasek). Przy SPI czy I²C o umiarkowanej szybkości ważniejsze są ścieżki powrotne i zbocza niż długości.

## Przykład rozwiązany

**Zegar SPI 20 MHz, zbocze 2 ns, ścieżka 15 cm** do pamięci Flash:
1. $t_d \approx 15\ \text{cm}/16\ \text{cm/ns} \approx 0\text{,}94$ ns > $t_r/6 = 0\text{,}33$ ns → linia długa.
2. Wyjście pinu ma ok. 25 Ω, ścieżka 50 Ω → bez terminacji przerzut ok. 33% i dzwonienie ([11.05](../11-pole-em-linie-anteny/05-stany-nieustalone-na-liniach.md)); podwójne zbocza na wejściu zegarowym dają przekłamane bity.
3. Rozwiązanie: rezystor szeregowy ok. 22–27 Ω przy wyjściu, ścieżka nad ciągłą masą, wolniejsza konfiguracja szybkości pinu.

**Przesłuch:** dla $D/H = 1$ współczynnik ok. $K/2$, dla $D/H = 3$ — $K/10$ (dziesięciokrotnie mniej).

## Typowe pułapki

- **Ścieżka zegara nad podziałem płaszczyzny** (np. między strefą 3,3 V a 5 V na warstwie zasilania).
- **Przelotka sygnałowa bez przelotki masy obok** przy zmianie warstwy.
- **Długi zegar bez terminacji** do kilku odbiorników.
- **Pary różnicowe o różnych długościach** (np. z powodu objazdu przelotki).
- **Najszybsze ustawienie pinów GPIO „na wszelki wypadek”** — niepotrzebnie ostre zbocza.

## Ćwiczenie komputerowe

Ocena ścieżek: czy linia jest długa, oczekiwany przerzut bez terminacji i względny przesłuch w funkcji odstępu:

```python
import numpy as np

v = 16.0                                                    # cm/ns, mikropasek FR-4
def check(length_cm, tr_ns, Rs=25, Z0=50):
    td = length_cm/v
    overshoot = 2*Z0/(Rs + Z0) - 1                         # koniec rozwarty: napięcie 2·V1 względem 1 V
    long = td > tr_ns/6
    return td, long, overshoot*100 if long else 0.0
for L, tr in [(3, 2), (15, 2), (15, 10), (30, 1)]:
    td, long, os = check(L, tr)
    print(f"{L:3d} cm, tr = {tr:2d} ns: td = {td:.2f} ns -> {'linia długa' if long else 'krótka'}, "
          f"przerzut bez terminacji ≈ {os:.0f}%  (f_knee = {0.35/tr*1e3:.0f} MHz)")
for DH in [0.5, 1, 2, 3, 5]:
    print(f"D/H = {DH}: przesłuch względny 1/(1+(D/H)^2) = {1/(1 + DH**2):.3f}")
print(f"opóźnienie: {1e3/(v*10):.2f} ps/mm")
```

## Zadania

1. Zbocze 1 ns, ścieżka 5 cm na FR-4 — czy trzeba myśleć o terminacji?
2. Para USB 2.0 HS (90 Ω) ma ścieżki różniące się o 2 mm. Jaka różnica opóźnień i czy to problem (czas bitu 2,08 ns)?
3. Dlaczego zmiana warstwy szybkiego sygnału bez przelotki masy obok zwiększa emisję?
4. Jak zmieni się przesłuch, jeśli odstęp ścieżek pozostanie ten sam, a odległość od płaszczyzny masy zmaleje dwukrotnie (przy D/H = 1 początkowo)?
5. Mikrokontroler steruje wyświetlaczem kablem taśmowym 20 cm z zegarem 10 MHz. Co zrobisz, aby ograniczyć problemy SI i EMC?

<details>
<summary>Odpowiedzi</summary>

1. $t_d \approx 0\text{,}31$ ns > $t_r/6 \approx 0\text{,}17$ ns — tak, na granicy; rezystor szeregowy przy źródle jest tanim zabezpieczeniem
2. Ok. 13 ps — pomijalne wobec 2,08 ns (reguły USB dopuszczają rzędu kilku mm); ale równoważy się długości dla ograniczenia konwersji na tryb wspólny
3. Prąd powrotny nie może przejść między płaszczyznami w miejscu przelotki — płynie przez najbliższy kondensator lub pojemność płaszczyzn, tworząc dużą pętlę i wzbudzając płaszczyzny jak rezonator; promieniuje też szczelina między płaszczyznami
4. D/H z 1 na 2 → współczynnik z 0,5 na 0,2 (2,5 raza mniej)
5. Wolne zbocza pinów, rezystor szeregowy na zegarze, przewody masy przeplecione z sygnałami w taśmie (co drugi przewód masą), ferryt na kablu, filtr RC przy złączu, jeśli prędkość pozwala; obniżenie częstotliwości zegara
</details>

## Źródła

- [Electromagnetics, Vol. 1 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-1) — linie transmisyjne, odbicia
- [Rick Hartley — wykłady o masie i ścieżkach powrotnych](https://www.youtube.com/results?search_query=Rick+Hartley+grounding+PCB) — ścieżki powrotne prądu
- [LearnEMC](https://learnemc.com/) — integralność sygnałów a EMC
- H. Johnson, M. Graham — *High-Speed Digital Design* (płatna) — klasyka: przesłuchy, terminacje, płaszczyzny
