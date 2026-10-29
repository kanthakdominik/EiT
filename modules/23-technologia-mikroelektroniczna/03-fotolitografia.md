# 23.03 — Fotolitografia

## Po co to jest

Litografia przenosi wzór z maski na płytkę i wyznacza najmniejszy wymiar, jaki da się wykonać — a więc gęstość tranzystorów i w dużej mierze koszt nowoczesnej fabryki (skaner EUV kosztuje setki milionów dolarów). Proces CMOS potrzebuje od kilkunastu do ponad 60 kroków litografii. Zrozumienie wzoru Rayleigha wyjaśnia, dlaczego przemysł przeszedł od światła widzialnego przez głęboki ultrafiolet do EUV i dlaczego „węzeł 3 nm” nie oznacza żadnego wymiaru równego 3 nm.

## Teoria w pigułce

### Proces

1. Nałożenie **fotorezystu** (wirowanie), wstępne wygrzewanie.
2. **Naświetlanie** przez maskę (obraz pomniejszony 4× w skanerze krokowym) — zmiana rozpuszczalności rezystu: pozytywowy (naświetlony się rozpuszcza) lub negatywowy.
3. Wygrzewanie po naświetleniu, **wywoływanie**.
4. Kontrola wymiarów (CD) i **nałożenia** (overlay) względem poprzednich warstw.
5. Operacja przez maskę rezystu (trawienie, implantacja), usunięcie rezystu.

### Rozdzielczość i głębia ostrości

$$CD = k_1\frac{\lambda}{\mathrm{NA}}, \qquad DOF = k_2\frac{\lambda}{\mathrm{NA}^2}$$

- $\lambda$ — długość fali, $\mathrm{NA} = n\sin\theta$ — apertura numeryczna obiektywu, $k_1$ — współczynnik procesu (teoretyczne minimum 0,25 dla pojedynczego naświetlenia; produkcyjnie 0,28–0,4).
- Większa NA poprawia rozdzielczość, ale głębia ostrości maleje z kwadratem NA — płytka musi być bardzo płaska (stąd CMP).

| Źródło | λ | NA | Typowe $CD$ |
|---|---|---|---|
| Lampa rtęciowa (linia i) | 365 nm | 0,6 | ~350 nm |
| KrF | 248 nm | 0,8 | ~130 nm |
| ArF (sucha) | 193 nm | 0,93 | ~65 nm |
| **ArF immersyjna** (woda, n = 1,44) | 193 nm | 1,35 | ~40 nm (pojedyncze naświetlenie) |
| **EUV** | 13,5 nm | 0,33 (High-NA: 0,55) | ~16 nm (High-NA ok. 10 nm) |

### Techniki poprawy rozdzielczości

- **OPC** (korekcja efektów bliskości) — maska celowo zniekształcona (narożniki, paski pomocnicze), by obraz na płytce był bliski projektowi.
- **Maski z przesunięciem fazy**, oświetlenie pozaosiowe.
- **Wielokrotne naświetlanie** (LELE, SADP/SAQP — samowyrównujące podwajanie wzoru): podział gęstego wzoru na kilka mniej gęstych; pozwala uzyskać rozstaw poniżej granicy pojedynczego naświetlenia kosztem liczby kroków.
- **EUV** — odbiciowa optyka (lustra wielowarstwowe Mo/Si), próżnia, źródło plazmowe (krople cyny); mniej kroków wielokrotnego naświetlania.
- Inne: litografia elektronowa (maski, badania; bardzo wolna), nanoimprint.

### Węzeł technologiczny

Nazwa węzła („7 nm”, „3 nm”) jest dziś nazwą handlową generacji; rzeczywiste wymiary to np. rozstaw bramek ok. 45–50 nm i rozstaw metalu 1. poziomu ok. 20–30 nm.

## Przykład rozwiązany

**Rozdzielczość immersji ArF i EUV:**

- ArF immersyjna: $CD = 0\text{,}28\cdot 193/1\text{,}35 = 40$ nm. Rozstaw (pitch) linii ok. $2\cdot CD = 80$ nm.
- Wzór o rozstawie 40 nm wymaga więc podwojenia (SADP), a 20 nm — poczwórnego (SAQP) przy ArF.
- EUV, $\mathrm{NA} = 0\text{,}33$, $k_1 = 0\text{,}4$: $CD = 0\text{,}4\cdot 13\text{,}5/0\text{,}33 = 16$ nm — w jednym naświetleniu.
- Głębia ostrości ($k_2 = 1$): ArF immersyjna $193/1\text{,}35^2 \approx 106$ nm, EUV $13\text{,}5/0\text{,}33^2 \approx 124$ nm — porównywalne; dla EUV High-NA (0,55) już ok. 45 nm.

## Typowe pułapki

- **Utożsamianie nazwy węzła z wymiarem** tranzystora.
- **Pomijanie nałożenia** (overlay) — przy wymiarach rzędu 20 nm błąd ustawienia warstw o kilka nm psuje kontakty.
- **Zapominanie o głębi ostrości** — topografia płytki większa niż DOF daje rozmyty obraz.
- **Proste przeskalowanie maski** bez OPC — narożniki się zaokrąglają, krótkie linie skracają.
- **Efekty statystyczne w EUV** — mało fotonów na nm² powoduje losowe defekty (stochastyka, chropowatość krawędzi).

## Ćwiczenie komputerowe

Rozdzielczość i głębia ostrości różnych generacji oraz obraz siatki linii (model z dwiema harmonicznymi — dlaczego wzór poniżej granicy znika):

```python
import numpy as np

gens = [("i-line", 365, 0.6, 0.6), ("KrF", 248, 0.8, 0.4), ("ArF", 193, 0.93, 0.35),
        ("ArF immersja", 193, 1.35, 0.28), ("EUV", 13.5, 0.33, 0.4), ("EUV High-NA", 13.5, 0.55, 0.4)]
for name, lam, NA, k1 in gens:
    print(f"{name:13s}: CD = {k1*lam/NA:6.1f} nm, DOF ≈ {lam/NA**2:6.1f} nm")

# obraz siatki linii o rozstawie p w oświetleniu koherentnym: przechodzą tylko rzędy dyfrakcji |m|·λ/p ≤ NA
def contrast(pitch_nm, lam, NA):
    x = np.linspace(0, 2*pitch_nm, 2001)
    field = 0.5*np.ones_like(x)                            # rząd 0
    m = 1
    while m*lam/pitch_nm <= NA:
        field += 2*np.sin(np.pi*m/2)/(np.pi*m)*np.cos(2*np.pi*m*x/pitch_nm)
        m += 1
    I = field**2
    return (I.max() - I.min())/(I.max() + I.min())

for pitch in (300, 160, 143, 140, 100):
    print(f"rozstaw {pitch} nm (ArF immersja, koherentnie): kontrast obrazu = {contrast(pitch, 193, 1.35):.2f}")
```

W oświetleniu koherentnym obraz istnieje, dopóki pierwszy rząd dyfrakcji mieści się w aperturze: $p \geq \lambda/\mathrm{NA} = 143$ nm. Oświetlenie pozaosiowe zmniejsza tę granicę do $\lambda/(2\mathrm{NA}) \approx 71$ nm — stąd $k_1$ bliskie 0,25.

## Zadania

1. Ile wynosi CD dla KrF (248 nm, NA = 0,8, $k_1 = 0\text{,}4$)?
2. Dlaczego immersja wodna zwiększa NA ponad 1?
3. Ile razy zmniejsza się głębia ostrości przy przejściu z NA = 0,33 do 0,55 (EUV)?
4. Co to jest SADP i jaki ma koszt?
5. Dlaczego litografia EUV wymaga próżni i luster zamiast soczewek?

<details>
<summary>Odpowiedzi</summary>

1. $0\text{,}4\cdot 248/0\text{,}8 = 124$ nm
2. $\mathrm{NA} = n\sin\theta$; między soczewką a płytką jest woda ($n = 1\text{,}44$) zamiast powietrza, więc przy tym samym kącie NA rośnie 1,44 raza (praktycznie do 1,35)
3. $(0\text{,}55/0\text{,}33)^2 \approx 2\text{,}8$ raza
4. Self-Aligned Double Patterning: na liniach pomocniczych osadza się warstwę dystansową (spacer), usuwa linie, a dystanse stają się maską o dwukrotnie gęstszym wzorze. Koszt: dodatkowe osadzanie i trawienie, ograniczenia projektowe (tylko regularne wzory), dodatkowe maski do cięcia linii
5. Promieniowanie 13,5 nm jest silnie pochłaniane przez wszystkie materiały, w tym powietrze i szkło — używa się luster wielowarstwowych (Mo/Si, odbicie ok. 70% na lustro) w próżni
</details>

## Źródła

- [ASML — Lithography principles: Rayleigh criterion](https://www.asml.com/technology/lithography-principles/rayleigh-criterion)
- [MIT 6.152J Micro/Nano Processing Technology](https://ocw.mit.edu/courses/6-152j-micro-nano-processing-technology-fall-2005/) — litografia
- [Purdue — Semiconductor Fabrication 101](https://engineering.purdue.edu/online/semiconductors/semiconductor-fabrication-101)
