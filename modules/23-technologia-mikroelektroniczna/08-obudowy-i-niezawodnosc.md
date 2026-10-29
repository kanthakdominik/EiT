# 23.08 — Montaż, obudowy i niezawodność

## Po co to jest

Gotowa płytka krzemowa musi zostać pocięta, zmontowana w obudowie, przetestowana i zakwalifikowana: producent deklaruje, że układ przetrwa np. 10 lat w 105 °C. Obudowa decyduje o odprowadzaniu ciepła ([03.09](../03-przyrzady-polprzewodnikowe/09-datasheety-i-termika.md)), indukcyjności wyprowadzeń (w.cz., zasilanie — [16.03](../16-pcb-emc-konstrukcja/03-sciezki-zasilanie-odsprzeganie.md)) i sposobie lutowania ([16.08](../16-pcb-emc-konstrukcja/08-produkcja-montaz-uruchamianie.md)). Testy przyspieszone i model Arrheniusa pozwalają w kilka tygodni ocenić, co stanie się przez lata — i zrozumieć liczby FIT i MTBF w kartach katalogowych.

## Teoria w pigułce

### Od płytki do układu

1. **Test na płytce** (sondy ostrzowe) — odrzucenie złych struktur.
2. **Ścienianie** (do 50–200 µm), **cięcie** (piła diamentowa, laser).
3. **Montaż struktury** (die attach): klej przewodzący lub lut.
4. **Połączenia:** drut (Au, Cu, Al — wire bonding) lub **flip-chip** (struktura odwrócona, kulki lutownicze/słupki Cu bezpośrednio na podłożu — mniejsze indukcyjności, więcej wyprowadzeń).
5. **Hermetyzacja:** zalewanie tworzywem (EMC), obudowy ceramiczne (hermetyczne — wojsko, kosmos).
6. **Test końcowy**, sortowanie, wygrzewanie wstępne (burn-in) dla eliminacji wczesnych uszkodzeń.

### Rodzaje obudów

| Obudowa | Cechy | Zastosowanie |
|---|---|---|
| DIP, SOIC, TSSOP | Wyprowadzenia na bokach, łatwe lutowanie | Układy proste i średnie |
| **QFN/DFN** | Bez wyprowadzeń, pole termiczne pod spodem, małe indukcyjności | Zasilanie, w.cz., mikrokontrolery |
| **BGA** | Kulki pod spodem, setki–tysiące połączeń | Procesory, FPGA, pamięci |
| **WLCSP** | Obudowa wielkości struktury (kulki na krzemie) | Telefony, urządzenia noszone |
| **2,5D/3D, chiplety** | Interposer krzemowy, mostki, struktury w stosie (TSV), pamięci HBM | Wysokowydajne obliczenia |
| Moduły mocy | Podłoże ceramiczne DBC, duże przekroje połączeń | Falowniki |

### Mechanizmy uszkodzeń

| Mechanizm | Przyczyna | Przyspieszają |
|---|---|---|
| **Elektromigracja** | Przemieszczanie atomów metalu przez elektrony | Gęstość prądu, temperatura |
| **TDDB** (przebicie tlenku zależne od czasu) | Generacja defektów w dielektryku | Pole elektryczne, temperatura |
| **HCI** (gorące nośniki) | Wstrzykiwanie nośników do tlenku przy drenie | Napięcie dren–źródło, niska temperatura |
| **BTI** (niestabilność napięcia progowego) | Ładunki w tlenku pod napięciem bramki | Napięcie bramki, temperatura |
| Zmęczenie połączeń lutowanych | Różnica współczynników rozszerzalności | Cykle temperatury |
| Korozja, delaminacja, „popcorn” | Wilgoć w obudowie + szybkie nagrzanie przy lutowaniu | Wilgotność (klasy MSL — wygrzewanie przed lutowaniem) |
| ESD, przepięcia | Zdarzenia zewnętrzne | — |

**Równanie Blacka** (elektromigracja): $\mathrm{MTTF} = A\,J^{-n}\,e^{E_a/kT}$, $n \approx 1$–2, $E_a \approx 0\text{,}7$–0,9 eV.

### Niezawodność — liczby

- **Krzywa „wannowa”:** uszkodzenia wczesne (eliminuje burn-in), okres losowych (stała intensywność $\lambda$), zużycie.
- **FIT** = liczba uszkodzeń na $10^9$ urządzeniogodzin; **MTBF** = $1/\lambda$ (dla stałej intensywności). 10 FIT ↔ MTBF ok. 11 400 lat — nie znaczy, że układ żyje tyle; znaczy, że w populacji 100 000 sztuk przez rok uszkodzi się ok. 9.
- **Współczynnik przyspieszenia Arrheniusa:** $AF = \exp\!\left[\dfrac{E_a}{k}\left(\dfrac{1}{T_{użyt}} - \dfrac{1}{T_{test}}\right)\right]$.
- **Test HTOL** (praca w wysokiej temperaturze, zwykle 125 °C, 1000 h, ok. 77 sztuk z każdej z 3 partii — JESD47); przy braku uszkodzeń górna granica intensywności z rozkładu $\chi^2$: $\lambda \leq \dfrac{\chi^2_{CL}(2r + 2)}{2\cdot N\cdot t\cdot AF}$, $r$ — liczba uszkodzeń.

## Przykład rozwiązany

**Test HTOL:** 77 układów, 1000 h w 125 °C, 0 uszkodzeń; $E_a = 0\text{,}7$ eV, warunki użytkowania 55 °C, poziom ufności 60%.

1. $AF = \exp\left[\dfrac{0\text{,}7}{8\text{,}617\cdot 10^{-5}}\left(\dfrac{1}{328\text{,}15} - \dfrac{1}{398\text{,}15}\right)\right] = e^{4\text{,}35} \approx 78$ — 1000 h testu odpowiada ok. 78 000 h (8,9 roku) pracy w 55 °C.
2. Równoważne urządzeniogodziny: $77\cdot 1000\cdot 78 = 5\text{,}98\cdot 10^6$ h.
3. $\chi^2_{0\text{,}6}(2) = 1\text{,}83$ → $\lambda \leq 1\text{,}83/(2\cdot 5\text{,}98\cdot 10^6) = 1\text{,}53\cdot 10^{-7}$ /h = **153 FIT**.

**Elektromigracja:** wzrost temperatury ścieżki z 105 °C do 125 °C przy $E_a = 0\text{,}9$ eV skraca czas do uszkodzenia $e^{(0\text{,}9/k)(1/378 - 1/398)} = 4$ razy.

## Typowe pułapki

- **MTBF jako „czas życia”** — to odwrotność intensywności uszkodzeń w okresie losowym, nie przewidywany wiek egzemplarza.
- **Arrhenius dla każdego mechanizmu** z tą samą energią aktywacji — różne mechanizmy mają różne $E_a$, niektóre (HCI) przyspieszają w niskiej temperaturze, a zmęczenie lutów zależy od cykli, nie od temperatury średniej.
- **Lutowanie układów wrażliwych na wilgoć** bez wygrzania (MSL) — pęknięcia obudowy.
- **Duże struktury w małej obudowie bez pola termicznego** — temperatura złącza przekracza dopuszczalną.
- **Ignorowanie gęstości prądu** w szerokości ścieżek zasilania w układzie scalonym i na płytce.

## Ćwiczenie komputerowe

Współczynnik przyspieszenia, FIT z testu i liczba próbek potrzebna do wykazania celu:

```python
import numpy as np
from scipy.stats import chi2

k = 8.617333e-5
def AF(Ea, T_use_C, T_test_C):
    return np.exp(Ea/k*(1/(T_use_C + 273.15) - 1/(T_test_C + 273.15)))

def fit_upper(N, hours, af, failures=0, cl=0.6):
    return chi2.ppf(cl, 2*failures + 2)/(2*N*hours*af)*1e9

af = AF(0.7, 55, 125)
print(f"AF(0,7 eV, 55 → 125 °C) = {af:.1f}; 1000 h testu ≈ {af*1000/8766:.1f} roku pracy")
for fails in (0, 1, 2):
    print(f"77 szt. × 1000 h, {fails} uszk.: λ ≤ {fit_upper(77, 1000, af, fails):.0f} FIT (60%), "
          f"{fit_upper(77, 1000, af, fails, 0.9):.0f} FIT (90%)")

# ile sztuk trzeba, by wykazać 50 FIT przy 90% ufności, 0 uszkodzeń, 1000 h?
target = 50e-9
N = chi2.ppf(0.9, 2)/(2*1000*af*target)
print(f"wymagana liczba sztuk dla 50 FIT (90%, 0 uszk.): {np.ceil(N):.0f}")

# elektromigracja: równanie Blacka — wpływ temperatury i gęstości prądu
for T in (85, 105, 125):
    print(f"MTTF względem 105 °C przy T = {T} °C: {AF(0.9, T, 105):.2f}×; przy 2× większej gęstości prądu (n = 2): {AF(0.9, T, 105)/4:.2f}×")
```

## Zadania

1. Policz AF dla $E_a = 0\text{,}7$ eV między 40 °C a 150 °C.
2. Układ ma 20 FIT. Ile uszkodzeń w ciągu roku można się spodziewać w populacji 50 000 urządzeń pracujących ciągle?
3. Dlaczego obudowa QFN z polem termicznym ma znacznie mniejszą rezystancję termiczną niż SOIC tej samej wielkości?
4. Co oznacza oznaczenie MSL 3 na opakowaniu układu i jak z tym postępować przy montażu?
5. Dlaczego flip-chip zastąpił drut w szybkich układach o wielu wyprowadzeniach?

<details>
<summary>Odpowiedzi</summary>

1. $\exp\left[\tfrac{0\text{,}7}{8\text{,}617\cdot 10^{-5}}\left(\tfrac{1}{313\text{,}15} - \tfrac{1}{423\text{,}15}\right)\right] = e^{6\text{,}74} \approx 850$
2. $50\,000\cdot 8760\ \text{h}\cdot 20\cdot 10^{-9} \approx 8\text{,}8$ — ok. 9 uszkodzeń
3. Struktura leży na metalowym polu, które jest przylutowane bezpośrednio do miedzi płytki (z przelotkami termicznymi) — ciepło przechodzi krótką drogą przez metal, a nie przez tworzywo i cienkie wyprowadzenia
4. Poziom wrażliwości na wilgoć 3: po otwarciu szczelnego opakowania układy należy zlutować w ciągu 168 h (w warunkach ≤ 30 °C/60% RH); po przekroczeniu — wygrzać (np. 125 °C przez kilkanaście–kilkadziesiąt godzin wg normy J-STD-033)
5. Krótsze połączenia (mniejsza indukcyjność i rezystancja), wyprowadzenia rozmieszczone na całej powierzchni (więcej połączeń, lepsze rozprowadzenie zasilania), lepsze odprowadzanie ciepła przez tył struktury
</details>

## Źródła

- [MIT 6.152J Micro/Nano Processing Technology](https://ocw.mit.edu/courses/6-152j-micro-nano-processing-technology-fall-2005/) — montaż i niezawodność
- [Purdue — Semiconductor Fabrication 101](https://engineering.purdue.edu/online/semiconductors/semiconductor-fabrication-101) — od płytki do obudowy
- JEDEC JESD47 — *Stress-Test-Driven Qualification of Integrated Circuits* (norma)
- [03.09 Karty katalogowe i termika](../03-przyrzady-polprzewodnikowe/09-datasheety-i-termika.md)
