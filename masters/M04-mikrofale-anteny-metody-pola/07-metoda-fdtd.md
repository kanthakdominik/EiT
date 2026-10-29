# M04.07 — Metoda FDTD

## Po co to jest

Gdy geometria jest zbyt złożona dla wzorów — antena w obudowie telefonu, przelotki i złącza na płytce, struktura EBG, wnęka urządzenia, dawka pola w tkance — rozwiązuje się równania Maxwella numerycznie. Metoda różnic skończonych w dziedzinie czasu (FDTD, Yee 1966) jest najprostsza do zrozumienia i zaimplementowania: pola E i H na przesuniętej siatce aktualizowane naprzemiennie w czasie. Jednym przebiegiem z impulsem daje odpowiedź w szerokim paśmie (FFT). Na niej opierają się openEMS, MEEP i wiele narzędzi komercyjnych.

## Teoria w pigułce

### Siatka Yee i równania aktualizacji (1D)

Fala płaska $E_z$, $H_y$ biegnąca w osi $z$: z równań $\partial H_y/\partial t = \frac1\mu\,\partial E_z/\partial x$ itd. różnice centralne w przestrzeni i czasie, z polami przesuniętymi o pół komórki i pół kroku:

$$H_y^{n+1/2}(i + \tfrac12) = H_y^{n-1/2}(i + \tfrac12) + \frac{\Delta t}{\mu\Delta z}\left[E_z^n(i + 1) - E_z^n(i)\right]$$
$$E_z^{n+1}(i) = E_z^n(i) + \frac{\Delta t}{\varepsilon\Delta z}\left[H_y^{n+1/2}(i + \tfrac12) - H_y^{n+1/2}(i - \tfrac12)\right]$$

W 3D — sześć składowych pól na przesuniętej siatce (komórka Yee), która automatycznie spełnia prawa Gaussa.

### Stabilność i dokładność

- **Warunek Couranta:** $S = \dfrac{c\Delta t}{\Delta z} \leq 1$ (1D), $\leq 1/\sqrt2$ (2D), $\leq 1/\sqrt3$ (3D) — przekroczenie daje wykładniczy wzrost pól.
- **Dyspersja numeryczna:** fala na siatce biegnie z prędkością zależną od częstotliwości i kierunku; potrzeba ≥ 10–20 komórek na najkrótszą długość fali (w najgęstszym dielektryku). W 1D przy $S = 1$ dyspersja znika („magiczny krok”).
- **Schodkowanie** zakrzywionych powierzchni — siatki niejednorodne, metody podkomórkowe.

### Brzegi i źródła

- **Warunki pochłaniające:** proste (Mur), **PML** (warstwa idealnie dopasowana — materiał pochłaniający bez odbić dla każdego kąta i częstotliwości) — standard.
- Ściany PEC/PMC — symetrie i ekrany.
- **Źródła:** twarde (wymuszona wartość — odbija falę), miękkie (dodawane), TF/SF (rozdział pola całkowitego i rozproszonego — fala płaska); impuls gaussowski z modulacją dla szerokiego pasma.
- **Wyniki:** parametry S z FFT napięć na portach, pole dalekie z transformacji pole bliskie → dalekie (charakterystyka anteny).

## Przykład rozwiązany

**Odbicie od dielektryka:** impuls gaussowski w próżni pada na półprzestrzeń o $\varepsilon_r = 4$. Teoria: $\Gamma = \dfrac{1 - \sqrt{\varepsilon_r}}{1 + \sqrt{\varepsilon_r}} = -\dfrac13$, $T = \dfrac{2}{1 + \sqrt{\varepsilon_r}} = \dfrac23$.

Symulacja 1D (2000 komórek po 1 mm, $S = 1$): zmierzone $\Gamma = -0\text{,}334$, $T = 0\text{,}667$ — zgodnie z teorią. Przy $S = 1\text{,}02$ pola rosną bez ograniczeń po kilkuset krokach — warunek Couranta jest twardą granicą.

Rozmiar problemu 3D: antena 2,4 GHz w obudowie 10 × 10 × 5 cm z rozdzielczością λ/20 w dielektryku $\varepsilon_r = 4$ (λ = 6,2 mm → komórka 0,3 mm) z marginesem na PML to rzędu $10^8$ komórek — dlatego siatki niejednorodne i obliczenia na GPU.

## Typowe pułapki

- **Za rzadka siatka** w obszarze dielektryka lub przy cienkich strukturach — błędne częstotliwości rezonansowe.
- **Odbicia od brzegów** (brak PML lub PML za blisko struktury) — fałszywe rezonanse.
- **Zbyt krótki czas symulacji** dla struktur o dużej dobroci — odpowiedź nie wygasła, FFT daje błędne parametry S (zjawisko obcięcia, jak przeciek widma).
- **Krok czasowy powyżej granicy Couranta** w siatce niejednorodnej (decyduje najmniejsza komórka).
- **Źródło twarde** w miejscu, przez które przechodzi fala odbita — dodatkowe odbicie.

## Ćwiczenie komputerowe

FDTD 1D: odbicie i transmisja na granicy próżnia–dielektryk oraz warunek Couranta:

```python
import numpy as np

# 1D FDTD (siatka Yee): impuls gaussowski pada z próżni na dielektryk εr = 4
c0 = 2.99792458e8
nz, dz = 2000, 1e-3                                  # 2 m, krok 1 mm
eps_r = np.ones(nz); eps_r[1000:] = 4.0
def run(S, steps=2300):
    dt = S*dz/c0                                     # liczba Couranta S = c·dt/dz
    Ez = np.zeros(nz); Hy = np.zeros(nz - 1)
    ce = S/eps_r; ch = S                             # pola w jednostkach znormalizowanych (E i η0·H)
    rec_inc, rec_ref, rec_tr = [], [], []
    src, t0, spread = 200, 120, 30
    for n in range(steps):
        Hy += ch*(Ez[1:] - Ez[:-1])
        Ez[1:-1] += ce[1:-1]*(Hy[1:] - Hy[:-1])
        Ez[src] += np.exp(-((n - t0)/spread)**2)     # źródło miękkie (addytywne)
        # proste warunki brzegowe pochłaniające (dokładne dla S = 1 w próżni): pola przesunięte o komórkę
        Ez[0] = Ez[1] if S == 1 else Ez[0]
        rec_ref.append(Ez[500]); rec_tr.append(Ez[1500])
        if not np.all(np.isfinite(Ez)) or np.max(np.abs(Ez)) > 1e6:
            return None
    return np.array(rec_ref), np.array(rec_tr)

out = run(1.0)
ref, tr = out
inc_peak = ref[:700].max()                           # impuls padający mija punkt 500 przed odbiciem
ref_peak = ref[700:].min()                           # odbicie (ujemne)
# w dielektryku εr = 4 punkt 1500 (0,5 m za granicą); amplituda fali przechodzącej
tr_peak = tr.max()
print(f"Γ zmierzone = {ref_peak/inc_peak:+.3f} (teoria (1 − √4)/(1 + √4) = {(1 - 2)/(1 + 2):+.3f})")
print(f"T zmierzone = {tr_peak/inc_peak:.3f} (teoria 2/(1 + √4) = {2/3:.3f})")
for S in (0.5, 1.0, 1.02):
    print(f"liczba Couranta S = {S}: {'stabilne' if run(S, 1000) is not None else 'NIESTABILNE — pola rosną bez ograniczeń'}")
```

Rozszerzenie: dodaj warstwę dielektryka o grubości λ/4 (przy wybranej częstotliwości) o $\varepsilon_r = 2$ przed półprzestrzenią $\varepsilon_r = 4$ — warstwę przeciwodblaskową — i sprawdź z FFT impulsu, przy jakiej częstotliwości odbicie znika. Następnie wykonaj ten sam eksperyment w openEMS.

## Zadania

1. Jaki maksymalny krok czasowy ma siatka 3D o komórce 0,5 mm?
2. Ile komórek na długość fali potrzeba w dielektryku $\varepsilon_r = 9$ przy 10 GHz (λ/20)? Jaka to komórka?
3. Dlaczego FDTD daje odpowiedź szerokopasmową z jednej symulacji, a metoda w dziedzinie częstotliwości (FEM, MoM) wymaga rozwiązania dla każdej częstotliwości?
4. Struktura ma rezonans o dobroci 500 przy 5 GHz. Jak długo (w nanosekundach) trzeba symulować, by energia spadła o 40 dB?
5. Co to jest PML i dlaczego jest lepsza od prostego warunku Mura?

<details>
<summary>Odpowiedzi</summary>

1. $\Delta t \leq \Delta/(c\sqrt3) = 0\text{,}5\cdot 10^{-3}/(3\cdot 10^8\cdot 1\text{,}732) \approx 0\text{,}96$ ps
2. $\lambda = 30\ \text{mm}/3 = 10$ mm → komórka 0,5 mm (20 komórek na λ)
3. Impuls zawiera szerokie widmo; odpowiedź czasowa po FFT daje transmitancję we wszystkich częstotliwościach naraz. Metody częstotliwościowe rozwiązują układ równań dla każdej częstotliwości (choć techniki przemiatania interpolacyjnego to łagodzą)
4. Energia zanika jak $e^{-\omega t/Q}$: $40\ \text{dB} = \ln(10^4) = 9\text{,}2$ → $t = 9\text{,}2Q/\omega = 9\text{,}2\cdot 500/(2\pi\cdot 5\cdot 10^9) \approx 146$ ns
5. PML to warstwa materiału z przewodnością elektryczną i magnetyczną (lub rozciągnięciem współrzędnych) dobraną tak, by impedancja była równa impedancji ośrodka — fala wchodzi bez odbicia dla każdej częstotliwości i kąta, a potem zanika; warunek Mura jest dokładny tylko dla padania prostopadłego i jednej prędkości
</details>

## Źródła

- [openEMS](https://openems.de) ([dokumentacja](https://docs.openems.de/intro.html)) — otwarty symulator FDTD 3D
- [S. J. Orfanidis — Electromagnetic Waves and Antennas](https://www.ece.rutgers.edu/~orfanidi/ewa) — metody numeryczne
- [MIT 6.635 Advanced Electromagnetism](https://ocw.mit.edu/courses/6-635-advanced-electromagnetism-spring-2003/)
- A. Taflove, S. Hagness — *Computational Electrodynamics: The FDTD Method* (płatna)
