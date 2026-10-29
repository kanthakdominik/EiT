# 22.03 — Lasery półprzewodnikowe

## Po co to jest

Dioda laserowa jest nadajnikiem w łączach światłowodowych ([14.02](../14-sieci-telekomunikacyjne/02-warstwa-fizyczna-i-swiatlowody.md)), źródłem w dalmierzach i lidarach, czytnikach kodów, drukarkach, myszach optycznych i czujnikach. Elektronicznie wygląda jak dioda LED, ale ma ostry próg, silną zależność od temperatury i jest łatwa do uszkodzenia krótkim impulsem nadprądowym. Sterownik lasera to więc zawsze precyzyjne, zabezpieczone źródło prądowe, często z pętlą stabilizacji mocy.

## Teoria w pigułce

### Zasada działania

- **Emisja wymuszona** w ośrodku z inwersją obsadzeń (złącze p-n silnie spolaryzowane) i **rezonator optyczny** (zwierciadła — łupane krawędzie kryształu, siatki Bragga, zwierciadła DBR).
- Poniżej **prądu progowego** $I_{th}$ dioda świeci słabo jak LED (emisja spontaniczna); powyżej moc rośnie liniowo: $P = \eta_s(I - I_{th})$, $\eta_s$ — **sprawność różniczkowa** [W/A].
- Różniczkowa sprawność kwantowa: $\eta_d = \eta_s\cdot\dfrac{q}{E_{foton}}$ — ile fotonów na każdy dodatkowy elektron.
- **Zależność od temperatury:** $I_{th}(T) = I_{th0}\,e^{(T - T_0)/T_c}$, $T_c$ — temperatura charakterystyczna (40–150 K); spada też $\eta_s$, a długość fali przesuwa się o ok. 0,3 nm/K.

### Rodzaje

| Typ | Cechy | Zastosowania |
|---|---|---|
| **Fabry–Pérot (krawędziowy)** | Kilka modów podłużnych, szerokie widmo (1–3 nm) | Wskaźniki, łącza krótkie, odtwarzacze |
| **DFB** (rozłożone sprzężenie zwrotne) | Jeden mod, wąskie widmo (< 1 MHz – kilka MHz) | Telekomunikacja dalekosiężna, DWDM |
| **VCSEL** (emisja z powierzchni) | Niski próg, okrągła wiązka, tani w produkcji, łatwe szyki | Łącza wielomodowe 850 nm, czujniki ToF, rozpoznawanie twarzy |
| Laser dużej mocy (szeroki pasek, belki) | Waty–kilowaty | Pompowanie, obróbka materiałów |

### Sterowanie

- **Źródło prądowe** z miękkim startem, ograniczeniem prądu maksymalnego i zabezpieczeniem przed stanami nieustalonymi (włączenie zasilania, ESD).
- **Automatyczna kontrola mocy (APC):** fotodioda monitorująca w obudowie lasera (tylne zwierciadło) + pętla regulacji prądu — kompensuje temperaturę i starzenie.
- **Stabilizacja temperatury (TEC)** — element Peltiera + termistor + regulator PID ([10.05](../10-automatyka/05-regulatory-pid.md)), gdy liczy się długość fali (DWDM, spektroskopia).
- **Modulacja bezpośrednia:** prąd polaryzacji nieco powyżej progu + modulacja; praca poniżej progu w stanie „0” powoduje opóźnienie włączenia i *chirp*.

### Bezpieczeństwo

Klasy laserów (IEC 60825-1): 1 — bezpieczny w normalnych warunkach, 2 — widzialny do 1 mW (chroni odruch mrugania), 3R, 3B, 4 — niebezpieczne dla oka (3B: do 500 mW, 4 — także dla skóry i pożarowo). Podczerwień jest szczególnie groźna — nie wywołuje odruchu mrugania.

## Przykład rozwiązany

**Laser 650 nm:** $I_{th} = 10$ mA przy 25 °C, $\eta_s = 0\text{,}5$ W/A, $T_c = 60$ K, prąd pracy 30 mA.

1. Moc przy 25 °C: $P = 0\text{,}5\cdot(30 - 10) = 10$ mW.
2. Różniczkowa sprawność kwantowa: $\eta_d = 0\text{,}5/1\text{,}91 = 0\text{,}26$ — co czwarty dodatkowy elektron daje foton wyjściowy.
3. Przy 65 °C: $I_{th} = 10\,e^{40/60} = 19\text{,}5$ mA; przy stałym prądzie 30 mA moc spada do $0\text{,}5\cdot 10\text{,}5 = 5\text{,}3$ mW (zaniedbując spadek $\eta_s$) — **prawie połowa**.
4. Wniosek: bez APC moc zmienia się dwukrotnie w zakresie temperatur; z APC prąd wzrośnie do ok. 39,5 mA (a uwzględniając spadek $\eta_s$ o 0,4%/K — do ok. 43 mA), utrzymując 10 mW — trzeba sprawdzić, czy mieści się w maksymalnym prądzie diody.

## Typowe pułapki

- **Zasilanie lasera jak LED z rezystora** — mała zmiana napięcia lub temperatury daje duże zmiany mocy, łatwo przekroczyć moc maksymalną.
- **Szpilki prądu przy włączaniu** i ESD — laser ginie w nanosekundy; miękki start, dioda zabezpieczająca, zwarcie wyprowadzeń przy montażu.
- **APC z błędnym znakiem pętli lub za szybką pętlą** — oscylacje mocy.
- **Odbicia wsteczne do lasera** (złącza, soczewki) — szum i niestabilność widma; w telekomunikacji izolatory optyczne, złącza APC (szlifowane pod kątem).
- **Lekceważenie klasy bezpieczeństwa** — nawet kilka mW podczerwieni w zogniskowanej wiązce uszkadza siatkówkę.

## Ćwiczenie komputerowe

Charakterystyka P–I w funkcji temperatury i prosta pętla APC (regulator całkujący):

```python
import numpy as np

eta0, Ith0, Tc = 0.5, 10e-3, 60.0
def power(I, T):
    Ith = Ith0*np.exp((T - 25)/Tc)
    eta = eta0*(1 - 0.004*(T - 25))          # spadek sprawności 0,4%/K
    return np.maximum(eta*(I - Ith), 0)

for T in (0, 25, 45, 65):
    print(f"T = {T:3d} °C: I_th = {Ith0*np.exp((T-25)/Tc)*1e3:5.1f} mA, P(30 mA) = {power(30e-3, T)*1e3:5.2f} mW")

# APC: fotodioda monitorująca (0,1 A/W względem mocy wyjściowej), regulator I
P_set, k_mon, Ki = 10e-3, 0.1, 2000.0     # Ki [1/s]: wzmocnienie regulatora całkującego
I, dt = 25e-3, 1e-3
T_profile = np.concatenate([np.full(500, 25.0), np.linspace(25, 65, 2000), np.full(500, 65.0)])
for k, T in enumerate(T_profile):
    err = k_mon*P_set - k_mon*power(I, T)       # uchyb prądu fotodiody monitorującej
    I = min(I + Ki*err*dt, 60e-3)                # ograniczenie prądu maksymalnego 60 mA
    if k in (499, 1499, 2499, 2999):
        print(f"t = {(k+1)*dt:.1f} s, T = {T:4.1f} °C: I = {I*1e3:5.2f} mA, P = {power(I, T)*1e3:5.2f} mW")
```

## Zadania

1. Laser 1310 nm: $I_{th} = 8$ mA, $\eta_s = 0\text{,}3$ W/A. Jaki prąd daje 2 mW? Ile wynosi $\eta_d$?
2. Dlaczego w modulacji bezpośredniej prąd w stanie „0” utrzymuje się nieco powyżej progu?
3. Laser ma $T_c = 50$ K. O ile procent rośnie prąd progowy przy wzroście temperatury o 10 K?
4. Jaka jest różnica między laserem DFB a Fabry–Pérot z punktu widzenia łącza 1550 nm na 80 km?
5. Wskaźnik laserowy 5 mW, 532 nm — jaka to klasa i dlaczego jest niebezpieczny mimo „małej” mocy?

<details>
<summary>Odpowiedzi</summary>

1. $I = 8 + 2/0\text{,}3 = 14\text{,}7$ mA; $E = 0\text{,}95$ eV, $\eta_d = 0\text{,}3/0\text{,}95 \approx 0\text{,}32$
2. Poniżej progu nośniki muszą najpierw zbudować inwersję — pojawia się opóźnienie włączenia (setki ps) i oscylacje relaksacyjne; praca tuż nad progiem skraca czas narastania i zmniejsza zniekształcenia, kosztem współczynnika ekstynkcji
3. $e^{10/50} = 1\text{,}22$ → o 22%
4. Fabry–Pérot ma widmo szerokości kilku nm; przy dyspersji ok. 17 ps/(nm·km) poszerzenie impulsu na 80 km to kilka ns — uniemożliwia przepływności Gb/s. DFB ma widmo bardzo wąskie i ogranicza go głównie modulacja (chirp)
5. Klasa 3R (powyżej 1 mW, do 5 mW dla widzialnego); wiązka skupiona przez soczewkę oka na siatkówce daje gęstość mocy tysiące razy większą niż na źrenicy
</details>

## Źródła

- [RP Photonics Encyclopedia](https://www.rp-photonics.com/encyclopedia.html) — hasła: laser diodes, VCSEL, DFB lasers, threshold
- [MIT 6.161 Modern Optics Project Laboratory](https://ocw.mit.edu/courses/6-161-modern-optics-project-laboratory-fall-2005/) — lasery
- [The FOA Reference Guide to Fiber Optics](https://www.thefoa.org/tech/ref/contents.html) — nadajniki światłowodowe
