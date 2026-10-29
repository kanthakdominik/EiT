# 24.06 — Wzmacniacze audio

## Po co to jest

Wzmacniacz mocy zamienia sygnał rzędu woltów na dziesiątki woltów i amperów w obciążeniu kilku omów. Projekt dotyczy w równym stopniu jakości (zniekształcenia, szum, stabilność z obciążeniem reaktancyjnym) i energii: ile mocy zamieni się w ciepło, jaki radiator i zasilacz są potrzebne. Wzmacniacz klasy D to w istocie przetwornica buck ([15.02](../15-energoelektronika-zasilanie/02-przetwornica-buck.md)) sterowana sygnałem audio — dlatego zdominował urządzenia przenośne i aktywne zestawy.

## Teoria w pigułce

### Moc i napięcia

- Moc sinusoidalna w obciążeniu $R$: $P = \dfrac{U_{pk}^2}{2R}$ → $U_{pk} = \sqrt{2PR}$, $I_{pk} = U_{pk}/R$.
- Zasilanie symetryczne: $U_{zas} \geq U_{pk} + U_{spadku}$ (2–5 V na tranzystorach wyjściowych i rezystorach emiterowych); w układzie mostkowym (BTL) napięcie na obciążeniu podwojone → 4× moc z tego samego zasilania.
- Muzyka ma współczynnik szczytu 10–20 dB — średnia moc to ułamek mocy szczytowej; od tego zależy dobór radiatora i zasilacza.

### Klasy wzmacniaczy

| Klasa | Zasada | Sprawność (sinus, pełna moc) | Uwagi |
|---|---|---|---|
| **A** | Tranzystor przewodzi cały okres, prąd spoczynkowy ≥ szczytowy | ≤ 25% (50% z transformatorem/dławikiem) | Brak zniekształceń skrośnych, ogromne straty |
| **B** | Para komplementarna, każdy tranzystor pół okresu | ≤ $\pi/4$ = 78,5% | Zniekształcenia skrośne przy przejściu przez zero |
| **AB** | Jak B z małym prądem spoczynkowym | ok. 50–70% | Standard wzmacniaczy liniowych |
| **D** | Modulacja PWM lub sigma-delta, tranzystory jako klucze, filtr LC | 85–95% | Małe straty, EMI, filtr wyjściowy, zależność od zasilania |
| G, H | Przełączane lub śledzące napięcie zasilania | 60–80% | Liniowe o lepszej sprawności |

- Straty w klasie B/AB są największe nie przy pełnej mocy, ale przy $U_{pk} = \tfrac{2}{\pi}U_{zas}$: $P_{strat,max} = \dfrac{2U_{zas}^2}{\pi^2R}$ (obie połówki razem).
- Zniekształcenia skrośne ([04.05](../04-uklady-analogowe/05-stopnie-wyjsciowe.md)) zmniejsza polaryzacja AB i głębokie sprzężenie zwrotne; termiczna stabilizacja prądu spoczynkowego (tranzystor $U_{BE}$ na radiatorze).

### Klasa D

- Modulator porównuje sygnał z piłą/trójkątem (250 kHz–1 MHz) lub stosuje modulację samooscylującą; stopień mostkowy MOSFET; **filtr LC 2. rzędu** odcina nośną.
- Dobór filtra Butterwortha dla obciążenia $R$: $L = \dfrac{\sqrt2\,R}{\omega_0}$, $C = \dfrac{1}{\sqrt2\,R\,\omega_0}$; $f_0$ ok. 30–60 kHz. Charakterystyka zależy od impedancji głośnika (zmienna!) — sprzężenie zwrotne za filtrem lub filtry „bezfiltrowe” (modulacja trójstanowa) dla małych mocy.
- Czas martwy w mostku → zniekształcenia; **PSRR** — w otwartej pętli tętnienia zasilania przenoszą się wprost na wyjście.
- **Pompowanie zasilania** (bus pumping) w półmostku: energia z obciążenia wraca do zasilacza i podnosi napięcie szyny przy niskich częstotliwościach.
- EMI — szybkie zbocza i długie przewody głośnikowe działają jak antena ([16.06](../16-pcb-emc-konstrukcja/06-emc-mechanizmy-i-normy.md)).

### Parametry jakościowe

THD+N (zwykle < 0,1% do < 0,001%), SNR (> 100 dB), pasmo, współczynnik tłumienia ($R_{obc}/R_{wy}$ — kontrola ruchu membrany przy rezonansie), stabilność z obciążeniem pojemnościowym (sieć Zobela, cewka wyjściowa), zabezpieczenia (zwarciowe, DC na wyjściu, termiczne, opóźnione załączanie głośnika).

## Przykład rozwiązany

**Wzmacniacz 50 W na 8 Ω:**

1. $U_{pk} = \sqrt{2\cdot 50\cdot 8} = 28\text{,}3$ V, $I_{pk} = 3\text{,}54$ A → zasilanie ±32 V (zapas na spadki).
2. Klasa AB: maksymalne straty $2\cdot 32^2/(\pi^2\cdot 8) = 25\text{,}9$ W (przy mocy wyjściowej ok. 26 W, czyli ok. połowie znamionowej) — radiator dobiera się na tę wartość, nie na straty przy pełnej mocy.
3. Klasa D o sprawności 90% przy pełnej mocy: straty $50/0\text{,}9 - 50 = 5\text{,}6$ W — kilka razy mniejszy radiator.
4. Filtr wyjściowy klasy D dla $f_0 = 30$ kHz i 8 Ω: $L = \sqrt2\cdot 8/(2\pi\cdot 30\,000) = 60$ µH, $C = 0\text{,}47$ µF.

## Typowe pułapki

- **Radiator liczony na straty przy pełnej mocy** w klasie AB — największe straty są przy części mocy.
- **Brak stabilności z kablem i głośnikiem** (obciążenie pojemnościowe) — oscylacje w.cz., przegrzanie.
- **Obciążenie 4 Ω na wzmacniaczu projektowanym na 8 Ω** — dwukrotny prąd szczytowy, większe straty i ryzyko zadziałania zabezpieczeń.
- **Pętla masy** między przedwzmacniaczem a wzmacniaczem — przydźwięk 50/100 Hz ([16.05](../16-pcb-emc-konstrukcja/05-masa-i-uklady-mieszane.md)).
- **Klasa D bez analizy EMI** i bez uwzględnienia zmian impedancji głośnika w filtrze.
- **Moc „PMPO”/„muzyczna”** w specyfikacjach — sensowne porównanie tylko dla mocy ciągłej przy określonym THD (np. 1%).

## Ćwiczenie komputerowe

Moc strat wzmacniacza klasy B w funkcji poziomu wyjścia, sprawność i porównanie z klasą D:

```python
import numpy as np

Vcc, R = 32.0, 8.0
Vpk = np.linspace(0.01, 30, 3000)
P_out = Vpk**2/(2*R)
P_supply = 2*Vcc*Vpk/(np.pi*R)                 # klasa B, obie szyny, sinus
P_loss = P_supply - P_out
i = np.argmax(P_loss)
print(f"klasa B: maks. straty {P_loss[i]:.1f} W przy U_pk = {Vpk[i]:.1f} V (2·Ucc/π = {2*Vcc/np.pi:.1f} V), "
      f"P_wy = {P_out[i]:.1f} W; wzór 2Ucc²/(π²R) = {2*Vcc**2/(np.pi**2*R):.1f} W")
for frac in (0.1, 0.5, 1.0):
    v = np.sqrt(2*frac*50*R)
    eta = (v**2/(2*R))/(2*Vcc*v/(np.pi*R))
    print(f"P_wy = {frac*50:4.0f} W: sprawność klasy B {eta*100:4.1f}%")

# muzyka: współczynnik szczytu 12 dB, szczyty na granicy obcinania → średnia moc wyjściowa
crest_db = 12
P_avg = 50/10**(crest_db/10)*2                 # sinus pełny ma współczynnik szczytu 3 dB
print(f"muzyka (szczyt 12 dB): średnia moc ok. {P_avg:.1f} W")

# filtr LC klasy D (Butterworth dla obciążenia R)
f0 = 30e3; w0 = 2*np.pi*f0
L, C = np.sqrt(2)*R/w0, 1/(np.sqrt(2)*R*w0)
for f in (1e3, 20e3, 400e3):
    s = 2j*np.pi*f
    H = 1/(1 + s*L/R + s**2*L*C)
    print(f"filtr L = {L*1e6:.0f} µH, C = {C*1e6:.2f} µF: |H({f/1e3:.0f} kHz)| = {20*np.log10(abs(H)):+.1f} dB")
```

## Zadania

1. Jakie napięcie szczytowe i prąd szczytowy są potrzebne do 100 W na 4 Ω?
2. Wzmacniacz BTL zasilany pojedynczym napięciem 12 V, obciążenie 4 Ω. Maksymalna moc (bez spadków)?
3. Ile wynoszą maksymalne straty klasy B przy zasilaniu ±40 V i obciążeniu 8 Ω?
4. Dlaczego wzmacniacz klasy D w otwartej pętli ma słabe PSRR?
5. Wzmacniacz o rezystancji wyjściowej 0,05 Ω pracuje z głośnikiem 8 Ω przez kabel 2 × 0,1 Ω. Jaki jest efektywny współczynnik tłumienia?

<details>
<summary>Odpowiedzi</summary>

1. $U_{pk} = \sqrt{2\cdot 100\cdot 4} = 28\text{,}3$ V, $I_{pk} = 7\text{,}1$ A
2. Napięcie szczytowe na obciążeniu 12 V → $P = 12^2/(2\cdot 4) = 18$ W
3. $2\cdot 40^2/(\pi^2\cdot 8) = 40\text{,}5$ W
4. Wyjście mostka to fala prostokątna o amplitudzie równej napięciu zasilania; amplituda sygnału po filtrze jest wprost proporcjonalna do napięcia zasilania — tętnienia zasilania modulują sygnał (PSRR ok. 0 dB bez sprzężenia zwrotnego)
5. $8/(0\text{,}05 + 0\text{,}2) = 32$ (kabel dominuje)
</details>

## Źródła

- [Texas Instruments — A comprehensive study of class D amplifier technology (PDF)](https://e2e.ti.com/cfs-file/__key/communityserver-discussions-components-files/6/A-comprehensive-study-of-class-D-amplifier-technology.pdf)
- [Elliott Sound Products (spis artykułów)](https://sound-au.com/site-map.htm) — wzmacniacze mocy, radiatory, zasilacze
- [04.05 Stopnie wyjściowe](../04-uklady-analogowe/05-stopnie-wyjsciowe.md)
- D. Self — *Audio Power Amplifier Design* (płatna)
