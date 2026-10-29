# 22.01 — Światło: foton, wielkości radiometryczne i fotometryczne

## Po co to jest

Karta katalogowa diody LED podaje strumień w lumenach, fotodiody — responsywność w A/W, lasera — moc w mW, czujnika oświetlenia — natężenie w luksach. Żeby połączyć nadajnik z odbiornikiem w jednym rachunku, trzeba umieć przechodzić między falą a fotonem, między watami a lumenami i między mocą źródła a tym, co dociera do detektora z danej odległości.

## Teoria w pigułce

### Foton

- Energia fotonu: $E = h\nu = \dfrac{hc}{\lambda}$; w praktyce $E[\text{eV}] \approx \dfrac{1240}{\lambda[\text{nm}]}$.
- Liczba fotonów na sekundę w wiązce o mocy $P$: $\dot N = P/E$ (1 mW przy 650 nm to ok. $3\text{,}3\cdot 10^{15}$ fotonów/s).
- Półprzewodnik pochłania foton, gdy $E \geq E_g$: krzem ($E_g = 1\text{,}12$ eV) do ok. 1100 nm, german i InGaAs — do 1700 nm. Dioda emituje przy energii bliskiej $E_g$: GaAs 870 nm, InGaN — niebieski, AlGaInP — czerwony.

| λ [nm] | Zakres | $E$ [eV] | Zastosowanie |
|---|---|---|---|
| 450 | Niebieski | 2,76 | LED białe (z luminoforem) |
| 555 | Zielony | 2,23 | Maksimum czułości oka |
| 650 | Czerwony | 1,91 | Wskaźniki laserowe, POF |
| 850 | Podczerwień bliska | 1,46 | Łącza światłowodowe wielomodowe, czujniki, piloty (940 nm) |
| 1310 | Podczerwień | 0,95 | Światłowód jednomodowy (minimum dyspersji) |
| 1550 | Podczerwień | 0,80 | Światłowód jednomodowy (minimum tłumienia), wzmacniacze EDFA |

### Radiometria i fotometria

| Wielkość radiometryczna (fizyczna) | Jednostka | Fotometryczna (dla oka) | Jednostka |
|---|---|---|---|
| Strumień (moc) promieniowania $\Phi_e$ | W | Strumień świetlny $\Phi_v$ | lm |
| Natężenie promieniowania $I_e$ (na kąt bryłowy) | W/sr | Światłość $I_v$ | cd = lm/sr |
| Natężenie napromienienia $E_e$ (na powierzchnię) | W/m² | Natężenie oświetlenia $E_v$ | lx = lm/m² |
| Radiancja $L_e$ | W/(m²·sr) | Luminancja $L_v$ | cd/m² |

- Przeliczenie: $\Phi_v = 683\ \tfrac{\text{lm}}{\text{W}}\displaystyle\int V(\lambda)\,\Phi_e(\lambda)\,d\lambda$, gdzie $V(\lambda)$ — krzywa czułości oka (1 przy 555 nm, 0,1 przy 650 nm, praktycznie 0 w podczerwieni). Dioda IR ma moc, ale zero lumenów.
- **Skuteczność świetlna** źródła [lm/W elektrycznego]: LED białe 100–200 lm/W, żarówka ok. 15 lm/W.
- **Prawo odwrotnych kwadratów** (źródło punktowe): $E = \dfrac{I}{d^2}\cos\theta$.
- **Źródło lambertowskie** (powierzchnia matowa, LED bez soczewki): $I(\theta) = I_0\cos\theta$, strumień całkowity $\Phi = \pi I_0$.
- **Kąt bryłowy** stożka o półkącie $\alpha$: $\Omega = 2\pi(1 - \cos\alpha)$ [sr].

## Przykład rozwiązany

**Ile mocy dotrze do fotodiody?** Dioda IR 850 nm o natężeniu promieniowania $I_e = 20$ mW/sr na osi, fotodioda o powierzchni 7 mm² w odległości 1 m.

1. Natężenie napromienienia: $E_e = I_e/d^2 = 20$ mW/m².
2. Moc na fotodiodzie: $P = E_e\cdot A = 20\cdot 10^{-3}\cdot 7\cdot 10^{-6} = 140$ nW.
3. Liczba fotonów: $E_{foton} = 1\text{,}46$ eV → $\dot N = 140\cdot 10^{-9}/(1\text{,}46\cdot 1\text{,}602\cdot 10^{-19}) \approx 6\cdot 10^{11}$ /s.
4. Przy responsywności 0,55 A/W (temat 04): fotoprąd ok. 77 nA. Przy 10 m — 100 razy mniej (0,77 nA), porównywalnie z prądem ciemnym typowej fotodiody.

## Typowe pułapki

- **Mylenie mocy promieniowania z mocą elektryczną** — LED o mocy 1 W elektrycznie wypromieniowuje 0,3–0,5 W.
- **Lumeny dla źródeł niewidzialnych** (IR, UV) — nie mają sensu; używaj watów.
- **Prawo odwrotnych kwadratów blisko dużego źródła** — działa, gdy odległość jest ≥ 5× większa od rozmiaru źródła.
- **Kąt połówkowy z karty katalogowej** to kąt, przy którym natężenie spada do 50%, a nie granica wiązki.
- **Pomijanie widma** — czujnik krzemowy „widzi” podczerwień, której nie widzi oko; czujnik oświetlenia bez filtra zawyża luksy przy świetle żarowym.

## Ćwiczenie komputerowe

```python
import numpy as np

h, c, q = 6.62607015e-34, 2.99792458e8, 1.602176634e-19
for lam in (450, 555, 650, 850, 1310, 1550):
    E = h*c/(lam*1e-9)
    print(f"{lam:5d} nm: E = {E/q:.3f} eV, 1 mW = {1e-3/E:.2e} fotonów/s")

# przybliżona krzywa czułości oka V(λ) (dopasowanie gaussowskie do krzywej CIE w okolicy maksimum)
V = lambda lam: np.exp(-0.5*((lam - 555)/42)**2)
for lam in (555, 600, 650, 700):
    print(f"V({lam} nm) ≈ {V(lam):.3f} -> 1 W = {683*V(lam):.0f} lm")

# lambertowski LED: natężenie na osi a strumień całkowity
I0 = 20e-3                        # W/sr
theta = np.linspace(0, np.pi/2, 10_001)
P_tot = np.trapezoid(I0*np.cos(theta)*2*np.pi*np.sin(theta), theta)
print(f"strumień całkowity: {P_tot*1e3:.1f} mW (pi*I0 = {np.pi*I0*1e3:.1f} mW)")

# moc na fotodiodzie 7 mm² w funkcji odległości
for d in (0.1, 1, 10):
    P = I0/d**2*7e-6
    print(f"d = {d:4} m: P = {P*1e9:9.2f} nW, fotoprąd (0,55 A/W) = {0.55*P*1e9:8.2f} nA")
```

Przybliżenie gaussowskie $V(\lambda)$ jest dokładne tylko w pobliżu maksimum (przy 650 nm daje ok. 0,08 wobec 0,107 w tablicy CIE); do obliczeń używa się tablicy CIE.

## Zadania

1. Ile fotonów na sekundę emituje laser 5 mW, 532 nm?
2. Do jakiej długości fali czuła jest fotodioda z InGaAs ($E_g = 0\text{,}75$ eV)?
3. Lampa daje 800 lm. Jakie natężenie oświetlenia daje na biurku 2 m niżej, jeśli świeci równomiernie w półprzestrzeń?
4. LED lambertowska ma $I_0 = 0\text{,}5$ cd. Jaki jest jej całkowity strumień świetlny?
5. Dlaczego zielona dioda o tej samej mocy promieniowania wydaje się jaśniejsza niż czerwona?

<details>
<summary>Odpowiedzi</summary>

1. $E = 1240/532 = 2\text{,}33$ eV $= 3\text{,}73\cdot 10^{-19}$ J; $\dot N = 5\cdot 10^{-3}/3\text{,}73\cdot 10^{-19} \approx 1\text{,}34\cdot 10^{16}$ /s
2. $\lambda \leq 1240/0\text{,}75 \approx 1650$ nm
3. Półprzestrzeń: $2\pi$ sr, $I = 800/2\pi \approx 127$ cd; $E = 127/4 \approx 32$ lx (w rzeczywistości zależy od rozsyłu oprawy)
4. $\Phi = \pi I_0 \approx 1\text{,}57$ lm
5. Czułość oka przy ok. 530–555 nm jest bliska maksimum, przy 630–650 nm tylko 10–25% — ten sam strumień w watach daje kilka razy więcej lumenów
</details>

## Źródła

- [RP Photonics Encyclopedia](https://www.rp-photonics.com/encyclopedia.html) — hasła: photon energy, radiometry, photometry
- [MIT 6.161 Modern Optics Project Laboratory](https://ocw.mit.edu/courses/6-161-modern-optics-project-laboratory-fall-2005/)
- [02.05 Pasma i półprzewodniki](../02-fizyka-i-materialy/05-pasma-i-polprzewodniki.md)
