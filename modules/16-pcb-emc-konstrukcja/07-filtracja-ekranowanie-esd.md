# 16.07 — Filtracja, ekranowanie i ochrona ESD

## Po co to jest

Nawet dobrze zaprojektowana płytka potrzebuje „straży granicznej”: filtrów na wejściach i wyjściach, ochrony przed wyładowaniami elektrostatycznymi i przepięciami, a czasem ekranu. Złącza to miejsca, przez które zakłócenia wychodzą na zewnątrz i wchodzą do środka — i przez które człowiek dotyka urządzenia naładowaną ręką.

## Teoria w pigułce

### Filtry EMI

| Element | Działanie | Uwagi |
|---|---|---|
| **Kondensator do masy/obudowy** | Zwiera zakłócenia w.cz. | Skuteczny tylko z małą indukcyjnością połączenia (krótko do masy przy złączu) |
| **Koralik ferrytowy** | Impedancja rezystancyjna w zakresie ok. 10 MHz – 1 GHz | Traci skuteczność przy prądzie DC (nasycenie); dobór po charakterystyce Z(f) |
| **Dławik wspólny (common-mode)** | Duża impedancja dla prądu wspólnego, mała dla różnicowego | Na kablach USB, Ethernet, zasilaniu, CAN; kluczowy dla emisji CM |
| Filtr LC / π | Większe tłumienie | Uwaga na rezonans i zachowanie przy impedancjach źródła/obciążenia |
| Filtr sieciowy | X (między przewodami) i Y (do PE) kondensatory + dławik wspólny | Kondensatory klasy X/Y (bezpieczeństwo), prąd upływu |

**Tłumienie wtrąceniowe** filtra zależy od impedancji po obu stronach — katalogowe dane w układzie 50 Ω/50 Ω mogą się bardzo różnić od rzeczywistości.

### Ekranowanie

Skuteczność ekranu = tłumienie absorpcyjne (grubość w głębokościach wnikania — [11.02](../11-pole-em-linie-anteny/02-fale-plaskie.md)) + odbiciowe. W praktyce ogranicza ją **najdłuższa szczelina**: szczelina o długości $l$ zaczyna przepuszczać, gdy $l$ zbliża się do $\lambda/2$ (przy 1 GHz to 15 cm; dla tłumienia ok. 20 dB szczeliny ≤ ok. λ/20). Otwory wentylacyjne jako falowody poniżej odcięcia ([11.06](../11-pole-em-linie-anteny/06-linie-praktyczne-i-falowody.md)). Ekrany na płytce (puszki nad blokami RF) z gęstym rzędem przelotek do masy (odstęp ≤ λ/20). **Kabel przechodzący przez ekran bez filtracji niweczy ekran.** Pole magnetyczne niskiej częstotliwości wymaga materiałów magnetycznych (stal, mu-metal).

### Ochrona ESD i przepięciowa

Wyładowanie ESD: kilka kV, prąd szczytowy rzędu dziesiątek A (IEC 61000-4-2 przy 8 kV ok. 30 A), czas narastania ok. 1 ns — energia mała, ale prąd i $dI/dt$ ogromne.

| Element | Zastosowanie |
|---|---|
| **Diody TVS / tablice ESD** | Linie sygnałowe na złączach (USB, przyciski, czujniki); mała pojemność dla szybkich interfejsów |
| Rezystor szeregowy | Ogranicza prąd do wewnętrznych diod układu |
| Kondensator przy złączu | Dzieli ładunek, spowalnia zbocze |
| Warystor, odgromnik gazowy | Przepięcia na zasilaniu i liniach długich (udary) |
| Bezpiecznik, bezpiecznik polimerowy (PTC) | Zwarcia i przeciążenia |
| Dioda / MOSFET przeciw odwrotnej polaryzacji | Wejście zasilania |

Zasady układu: **element ochronny jak najbliżej złącza**, z krótką i szeroką drogą do masy/obudowy; ścieżka chroniona przechodzi **przez** pad TVS (bez odgałęzienia); prąd wyładowania nie powinien płynąć przez płaszczyznę masy pod mikrokontrolerem.

## Przykład rozwiązany

**Złącze USB urządzenia:** tablica ESD o pojemności < 1 pF na D+/D− (żeby nie psuć sygnału 480 Mbit/s), TVS na VBUS, dławik wspólny na D+/D− (jeśli emisja CM jest problemem), ferryt + kondensatory na VBUS, ekran złącza połączony z masą obudowy (lub przez RC do 0 V w urządzeniu bez obudowy metalowej).

**Szczelina w obudowie:** szczelina 10 cm zaczyna przepuszczać przy częstotliwościach, dla których $\lambda/2 \approx 10$ cm — ok. 1,5 GHz; dla dobrego ekranowania do 1 GHz szczeliny powinny mieć ≤ ok. 1,5 cm (λ/20 przy 1 GHz) — stąd gęste wkręty, uszczelki przewodzące, zachodzące krawędzie.

## Typowe pułapki

- **Kondensator filtrujący z długą ścieżką do masy** — działa jak cewka, nie filtruje.
- **TVS daleko od złącza** — wyładowanie dociera najpierw do układu.
- **Ferryt w linii o dużym prądzie DC** — nasycony, bezużyteczny.
- **Ekran z jedną szczeliną na całej długości** lub z niefiltrowanym kablem.
- **TVS o zbyt dużej pojemności na szybkiej linii** (np. USB HS, HDMI) — degradacja sygnału.

## Ćwiczenie komputerowe

Tłumienie filtra LC w zależności od impedancji źródła i obciążenia, oraz skuteczność ekranowania ograniczona szczeliną (przybliżenie $20\log(\lambda/2l)$):

```python
import numpy as np

f = np.array([1e6, 10e6, 100e6, 1e9]); w = 2*np.pi*f
L, C, ESL = 1e-6, 100e-9, 1e-9
def il_db(Zs, Zl):
    Zc = 1j*w*ESL + 1/(1j*w*C); Zp = 1/(1/Zc + 1/Zl)
    v_with = Zp/(Zs + 1j*w*L + Zp); v_without = Zl/(Zs + Zl)
    return 20*np.log10(abs(v_without/v_with))
for Zs, Zl in [(50, 50), (1, 50), (50, 1e3), (0.1, 5)]:
    print(f"Zs = {Zs:5} Ω, Zl = {Zl:6} Ω: tłumienie wtrąceniowe " +
          ", ".join(f"{fi/1e6:g} MHz: {v:5.1f} dB" for fi, v in zip(f, il_db(Zs, Zl))))
for l_cm in [1.5, 5, 10, 30]:
    for fr in [100e6, 1e9]:
        lam = 3e8/fr; se = 20*np.log10(lam/(2*l_cm/100)) if 2*l_cm/100 < lam else 0
        print(f"szczelina {l_cm:4.1f} cm, {fr/1e6:5.0f} MHz: skuteczność ≈ {se:5.1f} dB")
```

## Zadania

1. Jaka maksymalna długość szczelin, jeśli ekran ma tłumić co najmniej 20 dB do 2,4 GHz?
2. Dlaczego ten sam filtr LC może tłumić w pomiarze 50 Ω wyraźnie więcej niż w rzeczywistym układzie (porównaj wyniki skryptu dla 1 MHz)?
3. Zaprojektuj ochronę wejścia przycisku wyprowadzonego na przewodzie 1 m do mikrokontrolera.
4. Ile wynosi prąd szczytowy wyładowania kontaktowego 4 kV według IEC 61000-4-2 (ok. 3,75 A/kV)?
5. Dlaczego dławik wspólny nie wpływa na sygnał różnicowy USB?

<details>
<summary>Odpowiedzi</summary>

1. λ przy 2,4 GHz = 12,5 cm; 20 dB → $\lambda/(2l) = 10$ → $l \leq 6\text{,}25$ mm
2. Tłumienie zależy od impedancji źródła i obciążenia; przy źródle o bardzo małej impedancji (wyjście przetwornicy) i obciążeniu o małej impedancji kondensator filtra „nie ma czego bocznikować”, a cewka ma za małą impedancję względem obciążenia — konieczne dopasowanie topologii (L od strony niskiej impedancji, C od strony wysokiej)
3. Przy złączu: TVS do masy, rezystor szeregowy (np. 1–10 kΩ), kondensator (np. 10–100 nF) przy wejściu mikrokontrolera, podciąganie; programowe eliminowanie drgań ([09.02](../09-mikrokontrolery-embedded/02-gpio-i-przerwania.md))
4. Ok. 15 A
5. Prądy różnicowe w obu przewodach mają przeciwne kierunki — ich strumienie w rdzeniu znoszą się, więc dławik ma dla nich małą impedancję; prąd wspólny (ten sam kierunek) wytwarza strumień i widzi dużą impedancję
</details>

## Źródła

- [LearnEMC](https://learnemc.com/) — filtry, ekranowanie, ochrona ESD
- [Electromagnetics, Vol. 2 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-2) — ekranowanie i falowody poniżej odcięcia
- [Analog Devices MT-101 — Decoupling Techniques](https://www.analog.com/media/en/training-seminars/tutorials/MT-101.pdf) — filtry zasilania z ferrytami
- Noty producentów elementów ochronnych (TVS, tablice ESD) i ferrytów (charakterystyki Z(f) i zależność od prądu DC)
