# M03.08 — Weryfikacja, układy mieszane i produkcja

## Po co to jest

Układ scalony produkuje się raz i nie da się go „poprawić lutownicą”. Weryfikacja przed produkcją — w narożnikach procesu, napięcia i temperatury, z rozrzutem Monte Carlo, z pasożytami, na poziomie całego układu z wejściami i wyjściami — jest dlatego najdłuższą częścią projektu. Układy mieszane, łączące bloki analogowe z cyfrowymi (przetworniki, PLL, czujniki), są szczególnie wymagające: zakłócenia cyfrowe przez podłoże i zasilanie, symulacja mieszana, kalibracja. Temat kończy się przetwornikiem SAR jako przykładem i listą kontrolną przed wysłaniem projektu do produkcji.

## Teoria w pigułce

### Weryfikacja analogowa

- **Narożniki PVT:** proces (TT, FF, SS, SF, FS), napięcie (±10%), temperatura (−40…125 °C); dla dokładności — **Monte Carlo** (rozrzut globalny + niedopasowanie lokalne), co najmniej kilkaset przebiegów, wynik jako średnia ± 3σ.
- **Symulacje po ekstrakcji pasożytów** (PEX) — szczególnie dla bloków szybkich i precyzyjnych.
- **Analizy:** DC (punkt pracy we wszystkich narożnikach — czy wszystkie tranzystory w nasyceniu), AC i stabilność (zapas fazy także dla pętli wewnętrznych), stany nieustalone (start zasilania, wybudzanie), szum, PSRR, zakresy wejściowe.
- **Uruchamianie zasilania** — obwody startowe, kolejność zasilań, stany nieokreślone.

### Układy mieszane

- **Symulacja mieszana:** bloki analogowe w SPICE, cyfrowe w Verilogu (ngspice z XSPICE/cosimulation) albo modele behawioralne (Verilog-A, modele w Pythonie) dla weryfikacji całego systemu.
- **Zakłócenia:** prądy przełączania logiki → spadki na zasilaniu i sprzężenia przez podłoże; osobne zasilania i masy, pierścienie ochronne, odległość, odsprzęganie na krzemie (kondensatory MOS), synchronizacja przetwarzania z próbkowaniem.
- **Przetwornik SAR** (przybliżeniowy): próbkowanie na macierzy kondensatorów ważonych binarnie, komparator, logika SAR wyznaczająca kolejne bity — prosty, energooszczędny, dobrze skaluje się z technologią. Rozdzielczość ogranicza dopasowanie kondensatorów (DNL/INL), szum $kT/C$ i komparatora, a szybkość — czas ustalania i komparator.
- **Wejścia i wyjścia:** pola kontaktowe z zabezpieczeniem ESD (diody do szyn, zaciski), stopnie wyjściowe, przesuwniki poziomu; specyfikacje HBM/CDM.

### Lista kontrolna przed produkcją

- [ ] DRC bez błędów (także reguły antenowe, gęstości, wypełnienie — *fill*).
- [ ] LVS czysty dla całego układu.
- [ ] STA we wszystkich narożnikach, z ekstrakcją; brak naruszeń setup/hold, poprawne ograniczenia.
- [ ] Symulacje analogowe w narożnikach i Monte Carlo po ekstrakcji; start zasilania.
- [ ] Symulacja całego układu (mieszana lub behawioralna) z podstawowymi scenariuszami użycia.
- [ ] Zabezpieczenia ESD na każdym wyprowadzeniu, sprawdzenie odstępów i szerokości szyn (elektromigracja).
- [ ] Struktury testowe: wyprowadzenia do pomiaru bloków osobno, tryby testowe, sygnały diagnostyczne.
- [ ] Plan pomiarów i płytka testowa przygotowane przed otrzymaniem krzemu.
- [ ] Wersja projektu oznaczona w repozytorium; wszystkie kroki odtwarzalne skryptami.

### Programy produkcji prototypów

**Tiny Tapeout** zbiera wiele małych projektów (cyfrowych i analogowych) na jednym układzie i wysyła je w kolejnych naborach na procesy SKY130, IHP SG13G2 i GF180 (przez wafer.space); daje szablony, automatyczne sprawdzenia i płytkę demonstracyjną. Po zamknięciu firmy Efabless w 2025 r. kontynuuje działalność z nowymi partnerami — terminy otwartych naborów sprawdzaj na stronie projektu.

## Przykład rozwiązany

**Przetwornik SAR 10 bitów, $U_{ref} = 1$ V:**

1. LSB $= 1/1024 = 0\text{,}977$ mV.
2. Szum $kT/C$ nie większy niż szum kwantyzacji ($\mathrm{LSB}/\sqrt{12}$): $C \geq kT/(\mathrm{LSB}/(2\sqrt3))^2 \approx 52$ fF (300 K) — całkowita pojemność macierzy co najmniej ok. 50 fF, czyli kondensator jednostkowy ok. 0,05 fF z punktu widzenia szumu.
3. Ale **dopasowanie** wymaga większych kondensatorów: symulacja pokazuje, że przy rozrzucie kondensatora jednostkowego 1% DNL/INL ok. 0,2/0,1 LSB, a przy 3% — ok. 1 LSB (brakujące kody). Orientacyjny wymóg: $\sigma(C_u)/C_u \lesssim 1/(2\sqrt{2^{N-1}}) = 2\text{,}2\%$.
4. Wniosek: w SAR o średniej rozdzielczości wymiar kondensatora jednostkowego wyznacza dopasowanie (zwykle kilka fF), a nie szum — kompromis z poborem energii i szybkością ustalania.

## Typowe pułapki

- **Weryfikacja bez pasożytów i bez Monte Carlo** — układ „działa” tylko w idealnym świecie.
- **Brak struktur testowych** — po produkcji nie da się ustalić, który blok zawodzi.
- **Zakłócenia cyfrowe w czasie próbkowania** przetwornika.
- **ESD i latch-up** sprawdzone dopiero po produkcji.
- **Przegapienie terminu naboru** — harmonogram projektu planuje się od daty zamknięcia naboru wstecz, z zapasem na sprawdzenia końcowe.
- **Brak płytki testowej i planu pomiarów** — układy czekają miesiącami na uruchomienie.

## Ćwiczenie komputerowe

Minimalna pojemność z $kT/C$ i wpływ niedopasowania kondensatorów na liniowość przetwornika SAR (model behawioralny):

```python
import numpy as np

rng = np.random.default_rng(1)
Nbits = 10
k, T = 1.380649e-23, 300
Vref = 1.0
LSB = Vref/2**Nbits
# minimalna pojemność próbkująca z kT/C: szum ≤ LSB/(2√3) (porównywalny z kwantyzacją)
C_min = k*T/(LSB/(2*np.sqrt(3)))**2
print(f"10 bit, Vref = 1 V: LSB = {LSB*1e3:.3f} mV, C_min (kT/C) = {C_min*1e15:.0f} fF")

def sar_adc(vin, caps):
    """Przetwornik SAR z ważoną binarnie macierzą kondensatorów (z błędami)."""
    Ctot = caps.sum() + caps[-1]                 # dodatkowy kondensator jednostkowy (końcowy)
    code = 0; v = 0.0
    for b in range(Nbits):
        trial = v + caps[b]/Ctot*Vref
        if vin >= trial:
            v = trial; code |= 1 << (Nbits - 1 - b)
    return code

def linearity(sigma_unit):
    Cu = 1.0
    nominal = Cu*2.0**np.arange(Nbits - 1, -1, -1)              # 512, 256, …, 1
    caps = nominal + rng.normal(0, sigma_unit*np.sqrt(nominal)) # każdy kondensator to suma jednostek
    v = np.linspace(0, Vref*(1 - 1e-9), 2**Nbits*32)
    codes = np.array([sar_adc(x, caps) for x in v])
    hist = np.bincount(codes, minlength=2**Nbits)[1:-1].astype(float)
    dnl = hist/hist.mean() - 1
    inl = np.cumsum(dnl)
    return np.max(np.abs(dnl)), np.max(np.abs(inl))

for s in (0.002, 0.01, 0.03):
    d, i = linearity(s)
    print(f"σ(Cu)/Cu = {s*100:.1f}%: max |DNL| = {d:.2f} LSB, max |INL| = {i:.2f} LSB")
print("wymóg orientacyjny dla 10 bitów: σ(Cu)/Cu ≲ 1/(2·√(2^(N−1))) ≈", f"{1/(2*np.sqrt(2**(Nbits-1)))*100:.1f}%")
```

Rozszerzenie: dodaj szum komparatora (gaussowski, σ = 0,3 LSB) i szum $kT/C$, policz ENOB z FFT sinusoidy ([07.01](../../modules/07-cps-dsp/01-przetwarzanie-ac.md)); zaprojektuj logikę SAR w Verilogu z testbenchem i przeprowadź ją przez przepływ z tematu 07.

## Zadania

1. Przetwornik 12-bitowy, $U_{ref} = 1\text{,}2$ V. Jaka minimalna pojemność próbkująca z warunku $kT/C$ (300 K)?
2. Dlaczego kondensatory MIM/MOM w macierzy SAR układa się w strukturze wspólnego centroidu?
3. Ile narożników (bez Monte Carlo) trzeba zasymulować dla 5 narożników procesu, 3 napięć i 3 temperatur?
4. Co to są reguły antenowe i dlaczego dotyczą tylko etapu produkcji?
5. Wymień trzy struktury testowe, które warto dodać do pierwszego układu z blokiem analogowym.

<details>
<summary>Odpowiedzi</summary>

1. LSB $= 1\text{,}2/4096 = 0\text{,}293$ mV; $C \geq kT\cdot 12/\mathrm{LSB}^2 = 4\text{,}14\cdot 10^{-21}\cdot 12/(2\text{,}93\cdot 10^{-4})^2 \approx 0\text{,}58$ pF
2. Stosunki pojemności (a nie wartości bezwzględne) decydują o liniowości; centroid usuwa wpływ gradientów grubości dielektryka i naprężeń, a elementy fikcyjne wyrównują otoczenie
3. $5\cdot 3\cdot 3 = 45$
4. W czasie trawienia plazmowego długie ścieżki metalu podłączone tylko do bramki zbierają ładunek i mogą przebić tlenek bramkowy, zanim zostaną dołączone do dyfuzji (która go odprowadzi); w gotowym układzie problem nie istnieje, ale uszkodzenie z produkcji zostaje — reguły ograniczają stosunek powierzchni anten do bramki (rozwiązania: diody antenowe, przeskok do wyższej warstwy)
5. Np. wyprowadzenie wyjścia wzmacniacza/odniesienia do pomiaru, osobne zasilanie bloku z możliwością pomiaru prądu, tryb obejścia (bypass) dla podawania sygnałów z zewnątrz, pojedyncze tranzystory i elementy bierne do pomiaru parametrów procesu, łańcuch skanujący dla logiki
</details>

## Źródła

- [Tiny Tapeout](https://tinytapeout.com/) — nabory, szablony, lista kontrolna
- [IIC-OSIC-TOOLS (GitHub)](https://github.com/iic-jku/IIC-OSIC-TOOLS) — narzędzia do weryfikacji
- [SkyWater SKY130 PDK](https://github.com/google/skywater-pdk), [IHP Open PDK](https://github.com/IHP-GmbH/IHP-Open-PDK) — modele narożników i Monte Carlo
- [23.08 Obudowy i niezawodność](../../modules/23-technologia-mikroelektroniczna/08-obudowy-i-niezawodnosc.md)
