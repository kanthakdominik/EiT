# 23.02 — Utlenianie i osadzanie cienkich warstw

## Po co to jest

Układ scalony to stos kilkudziesięciu cienkich warstw: tlenek bramkowy o grubości kilku warstw atomowych, izolacja między tranzystorami, polikrzem lub metal bramki, dielektryki między warstwami połączeń, bariery, miedź. Łatwość wytwarzania doskonałego tlenku na krzemie (SiO₂) była jednym z powodów, dla których krzem wygrał z innymi półprzewodnikami. Ten temat opisuje utlenianie termiczne (model Deala–Grove'a) i metody osadzania.

## Teoria w pigułce

### Utlenianie termiczne

Si + O₂ → SiO₂ (suche) lub Si + 2H₂O → SiO₂ + 2H₂ (mokre) w 800–1200 °C. Tlenek rośnie **w głąb** krzemu: na każdy 1 nm tlenku zużywa się 0,44 nm krzemu.

**Model Deala–Grove'a:** utleniacz dyfunduje przez istniejący tlenek i reaguje na granicy Si/SiO₂:

$$x^2 + Ax = B(t + \tau)$$

- Cienkie warstwy ($x \ll A$): wzrost **liniowy**, $x \approx \dfrac{B}{A}t$ — ogranicza reakcja.
- Grube warstwy ($x \gg A$): wzrost **paraboliczny**, $x \approx \sqrt{Bt}$ — ogranicza dyfuzja.
- $B$ i $B/A$ rosną wykładniczo z temperaturą (energia aktywacji ok. 1,2–2 eV); mokre utlenianie jest kilkanaście razy szybsze.
- Przykładowe stałe w 1000 °C: suche $A = 0\text{,}165$ µm, $B = 0\text{,}0117$ µm²/h, $\tau = 0\text{,}37$ h (szybki wzrost pierwszych ok. 25 nm); mokre $A = 0\text{,}226$ µm, $B = 0\text{,}287$ µm²/h.
- Suche — tlenek bramkowy i cienkie warstwy wysokiej jakości; mokre — grube tlenki izolacyjne (setki nm).

### Osadzanie cienkich warstw

| Metoda | Zasada | Warstwy | Cechy |
|---|---|---|---|
| **CVD** (chemiczne z fazy gazowej): LPCVD, PECVD | Reakcja gazów na gorącej powierzchni; plazma obniża temperaturę | SiO₂, Si₃N₄, polikrzem, wolfram | Dobra konformalność (LPCVD); PECVD do 300–400 °C (po metalizacji) |
| **PVD** (fizyczne): rozpylanie (sputtering), naparowanie | Atomy wybijane z tarczy jonami argonu lub odparowane | Metale (Al, Ti, TiN, Cu — warstwa zarodkowa), bariery | Słaba konformalność, „cieniowanie” w głębokich otworach |
| **ALD** (osadzanie warstw atomowych) | Naprzemienne, samoograniczające się reakcje — jedna warstwa atomowa na cykl | Tlenki high-k (HfO₂), cienkie bariery | Doskonała konformalność i kontrola grubości (0,1 nm/cykl), wolne |
| **Epitaksja** | Wzrost monokrystaliczny (CVD) | Si, SiGe (naprężony kanał), GaN na Si | Kontrolowane domieszkowanie warstwy |
| **Galwanizacja** | Osadzanie elektrochemiczne | Miedź połączeń | Wypełnianie rowków (proces damasceński) |

### Pomiar grubości

Elipsometria i reflektometria (interferencja w warstwie — barwa tlenku zmienia się z grubością), profilometr, przekroje w mikroskopie elektronowym.

## Przykład rozwiązany

**Tlenek bramkowy 100 nm suchy w 1000 °C** (przykład dydaktyczny; dzisiejsze tlenki bramkowe mają ułamki tej grubości):

$$t = \frac{x^2 + Ax}{B} - \tau = \frac{0\text{,}01 + 0\text{,}0165}{0\text{,}0117} - 0\text{,}37 = 2\text{,}26 - 0\text{,}37 \approx 1\text{,}9\ \text{h}$$

**Tlenek polowy 500 nm mokry w 1000 °C:** $t = (0\text{,}25 + 0\text{,}113)/0\text{,}287 = 1\text{,}26$ h. Zużyty krzem: $0\text{,}44\cdot 500 = 220$ nm — powierzchnia tlenku wystaje ponad pierwotną powierzchnię krzemu o ok. 280 nm, co tworzy stopień (stąd w nowoczesnych procesach izolacja rowkowa STI z planaryzacją CMP — [23.06](06-proces-cmos.md)).

## Typowe pułapki

- **Ekstrapolacja wzrostu liniowego** na grube warstwy — przy dużych grubościach czas rośnie z kwadratem grubości.
- **Model Deala–Grove'a dla ultracienkich tlenków** (< 20–30 nm, suche) — niedoszacowuje szybkiego początkowego wzrostu; stąd parametr $\tau$ i modele empiryczne.
- **Pomijanie zużycia krzemu** — zmienia głębokości złącz i topografię.
- **Temperatura po metalizacji** — aluminium topi się w 660 °C, miedź dyfunduje; po wykonaniu połączeń tylko procesy niskotemperaturowe (PECVD, ≤ 400–450 °C).
- **Słaba konformalność PVD** w głębokich otworach — przerwy w barierze, puste przestrzenie.

## Ćwiczenie komputerowe

Grubość tlenku w funkcji czasu (model Deala–Grove'a) i czas potrzebny na zadaną grubość:

```python
import numpy as np

params = {  # A [µm], B [µm²/h], tau [h] — 1000 °C
    "suche 1000 °C": (0.165, 0.0117, 0.37),
    "mokre 1000 °C": (0.226, 0.287, 0.0),
}

def thickness(t, A, B, tau):
    return (-A + np.sqrt(A**2 + 4*B*(t + tau)))/2

def time_for(x, A, B, tau):
    return (x**2 + A*x)/B - tau

for name, (A, B, tau) in params.items():
    xs = [thickness(t, A, B, tau)*1e3 for t in (0.5, 1, 2, 4, 8)]
    print(f"{name}: grubość po 0,5/1/2/4/8 h = " + ", ".join(f"{x:.0f}" for x in xs) + " nm")
    for x_nm in (100, 500, 1000):
        print(f"   {x_nm:5d} nm: {time_for(x_nm/1e3, A, B, tau):6.2f} h, zużyty krzem {0.44*x_nm:.0f} nm")
```

Zwróć uwagę, jak czas rośnie z kwadratem grubości w zakresie parabolicznym (500 → 1000 nm mokrego tlenku).

## Zadania

1. Ile krzemu zużyje wyhodowanie 200 nm tlenku?
2. Ile czasu zajmie wyhodowanie 1 µm tlenku mokrego w 1000 °C? Ile razy dłużej niż 500 nm?
3. Dlaczego tlenek bramkowy hoduje się w atmosferze suchej, a izolacyjny — mokrej?
4. Dlaczego do tlenku bramkowego w nowoczesnych procesach stosuje się ALD (HfO₂), a nie utlenianie termiczne?
5. Którą metodą osadzisz dielektryk między warstwami metalu i dlaczego?

<details>
<summary>Odpowiedzi</summary>

1. $0\text{,}44\cdot 200 = 88$ nm
2. $(1 + 0\text{,}226)/0\text{,}287 = 4\text{,}27$ h — ok. 3,4 razy dłużej (zakres paraboliczny)
3. Suche utlenianie jest wolne (dokładna kontrola grubości) i daje tlenek o najlepszych własnościach elektrycznych (mała gęstość ładunków i pułapek); mokre jest szybkie — opłacalne dla grubych warstw, gdzie jakość granicy jest mniej krytyczna
4. SiO₂ o grubości ok. 1 nm przepuszcza duży prąd tunelowy; HfO₂ o przenikalności ok. 20–25 daje tę samą pojemność przy kilkakrotnie większej grubości fizycznej — ALD zapewnia kontrolę grubości na poziomie warstw atomowych i jednorodność
5. PECVD (lub inne metody niskotemperaturowe, także spin-on) — po wykonaniu metalizacji nie można przekroczyć ok. 400–450 °C
</details>

## Źródła

- [MIT 6.152J Micro/Nano Processing Technology](https://ocw.mit.edu/courses/6-152j-micro-nano-processing-technology-fall-2005/) — utlenianie, CVD, PVD
- [MIT 6.774 Physics of Microfabrication: Front End Processing](https://ocw.mit.edu/courses/6-774-physics-of-microfabrication-front-end-processing-fall-2004/) — kinetyka utleniania
- J. D. Plummer, M. D. Deal, P. B. Griffin — *Silicon VLSI Technology* (płatna) — rozdział o utlenianiu
