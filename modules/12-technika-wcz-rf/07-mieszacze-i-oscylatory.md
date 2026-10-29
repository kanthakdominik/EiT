# 12.07 — Mieszacze, oscylatory i syntezery

## Po co to jest

Prawie każdy odbiornik i nadajnik przesuwa sygnał w częstotliwości: z pasma radiowego na częstotliwość pośrednią lub do pasma podstawowego i z powrotem. Robi to mieszacz zasilany sygnałem generatora lokalnego, który z kolei pochodzi z syntezera PLL. Czystość tego generatora (szum fazowy, sygnały pasożytnicze) decyduje o selektywności odbiornika i o jakości modulacji nadajnika.

## Teoria w pigułce

### Mieszanie

Mnożenie dwóch sinusoid daje sumę i różnicę częstotliwości:

$$\cos(\omega_{RF}t)\cos(\omega_{LO}t) = \tfrac12\cos((\omega_{RF} - \omega_{LO})t) + \tfrac12\cos((\omega_{RF} + \omega_{LO})t)$$

**Częstotliwość lustrzana:** p.cz. $f_{IF} = |f_{RF} - f_{LO}|$ powstaje z dwóch częstotliwości wejściowych: $f_{LO} + f_{IF}$ i $f_{LO} - f_{IF}$. Druga z nich (lustrzana) musi być stłumiona **przed** mieszaczem filtrem albo mieszaczem z odrzucaniem lustra (Hartley, Weaver; kwadraturowy tor I/Q). Wybór wyższej p.cz. oddala lustro i ułatwia filtrację, niższej — ułatwia filtrację kanałową.

**Produkty pasożytnicze (spurs):** rzeczywisty mieszacz daje $mf_{RF} \pm nf_{LO}$; tablice produktów (spur charts) pozwalają dobrać częstotliwości tak, by niskie rzędy nie wpadały w p.cz.

### Rodzaje mieszaczy

| Mieszacz | Cechy |
|---|---|
| Diodowy podwójnie zrównoważony (pierścieniowy) | Bierny, strata przemiany ok. 6–7 dB, dobra liniowość, wymaga mocnego LO (+7…+17 dBm), szerokie pasmo |
| Komórka Gilberta | Aktywny, wzmocnienie przemiany, mały LO, łatwy w układach scalonych |
| Przełączający (pasywny CMOS) | Bardzo liniowy, w nowoczesnych układach scalonych radia |
| Modulator/demodulator I/Q | Dwa mieszacze z LO przesuniętym o 90° — bezpośrednia przemiana, odrzucanie lustra, modulacje cyfrowe |

Parametry: strata/wzmocnienie przemiany, NF, IIP3 i P1dB, izolacje LO–RF, LO–IF, RF–IF (przeciek LO przez antenę!).

### Oscylatory

Warunek Barkhausena: wzmocnienie pętli = 1, faza = 0° (n·360°) — [04.10](../04-uklady-analogowe/10-komparatory-i-generatory.md). Na w.cz. częściej opis **ujemnej rezystancji**: tranzystor z odpowiednim sprzężeniem daje $\text{Re}(Z) < 0$, które kompensuje straty rezonatora. Rezonatory: LC (Colpitts, Clapp), kwarc (dobroć 10⁴–10⁶), ceramiczne, linie, rezonatory dielektryczne, SAW. **VCO** — z waraktorem (pojemność zależna od napięcia) przestrajany napięciem; nachylenie $K_{VCO}$ w MHz/V.

### Szum fazowy

Widmo rzeczywistego oscylatora ma „spódnicę” wokół nośnej. $\mathcal L(\Delta f)$ — moc szumu w paśmie 1 Hz w odległości $\Delta f$ od nośnej, względem nośnej [dBc/Hz]. Model Leesona: szum rośnie, gdy dobroć rezonatora maleje, i spada z odległością od nośnej (−20 dB/dek w obszarze $1/f^2$).

Skutki:
- **mieszanie odwrotne (reciprocal mixing):** silny sygnał w sąsiednim kanale „miesza się” ze spódnicą LO i wpada w p.cz. jako szum;
- **błąd fazy w modulacjach cyfrowych** — rozmycie konstelacji, EVM ([13](../13-telekomunikacja/));
- **jitter** zegarów: $\sigma_t = \dfrac{\sqrt{2\int\mathcal L(f)\,df}}{2\pi f_0}$ (całka w liniowej skali) — ogranicza SNR przetworników A/C ([07.01](../07-cps-dsp/01-przetwarzanie-ac.md)).

### Syntezery PLL

Detektor fazy/częstotliwości porównuje $f_{ref}$ z $f_{VCO}/N$; filtr pętli steruje VCO ([10.08](../10-automatyka/08-zastosowania-w-elektronice.md)). Wyjście $f_{wy} = Nf_{ref}$.
- **Integer-N:** krok równy $f_{ref}$; mały krok wymaga małego $f_{ref}$, dużego $N$ i wąskiej pętli.
- **Fractional-N:** ułamkowy podział (modulator Σ-Δ), drobny krok przy dużym $f_{ref}$; dodatkowe produkty ułamkowe.
- **W paśmie pętli** szum referencji i detektora mnoży się przez $N$: **+20 log N dB**; poza pasmem dominuje szum VCO. Szerokość pasma pętli — kompromis: tłumienie szumu VCO i szybkość przestrajania vs. tłumienie szumu referencji i produktów odniesienia.
- Alternatywa: synteza cyfrowa DDS (akumulator fazy + tablica + przetwornik C/A) — bardzo drobny krok i szybkie przestrajanie, ograniczony zakres i produkty pasożytnicze przetwornika.

## Przykład rozwiązany

**Odbiornik FM:** RF 100 MHz, p.cz. 10,7 MHz, LO powyżej: $f_{LO} = 110\text{,}7$ MHz, lustro $f_{RF} + 2f_{IF} = 121\text{,}4$ MHz. Filtr wejściowy musi stłumić 121,4 MHz, a przestrajany — dla całego pasma 88–108 MHz (lustra 109,4–129,4 MHz; dlatego p.cz. 10,7 MHz, a nie np. 455 kHz).

**Syntezer 2,44 GHz** z $f_{ref} = 1$ MHz: $N = 2440$, w paśmie pętli szum referencji i detektora wzrasta o $20\log 2440 \approx 67\text{,}7$ dB. Detektor o szumie −150 dBc/Hz (odniesionym do $f_{ref}$) daje w paśmie ok. −82 dBc/Hz na wyjściu.

**Jitter:** oscylator 100 MHz o płaskim szumie −100 dBc/Hz od 10 kHz do 1 MHz: $\sqrt{2\cdot 10^{-10}\cdot 9\text{,}9\cdot 10^5} \approx 0\text{,}0141$ rad → $\sigma_t \approx 22$ ps.

## Typowe pułapki

- **Brak filtra lustra** albo filtr zbyt szeroki — odbiornik słyszy dwa pasma naraz.
- **Przeciek LO na antenę** — promieniowanie poza przydziałem, w odbiorniku z bezpośrednią przemianą: składowa stała (DC offset).
- **Za słaby LO dla mieszacza diodowego** — duża strata przemiany i słaba liniowość.
- **Pętla PLL zbyt szeroka** — produkty od częstotliwości odniesienia na wyjściu; zbyt wąska — powolne przestrajanie i niestłumiony szum VCO.
- **Zasilanie VCO z zaszumionego źródła** — szum zasilania moduluje częstotliwość (pushing).

## Ćwiczenie komputerowe

Mieszanie, lustro i produkty — symulacja w Pythonie z idealnym mieszaczem (mnożenie) i przełączającym (mnożenie przez prostokąt):

```python
import numpy as np

fs, N = 1e9, 2**18
t = np.arange(N)/fs
snap = lambda f: round(f*N/fs)*fs/N
f_lo, f_if = snap(110.7e6), snap(10.7e6)
f_rf, f_img = f_lo - f_if, f_lo + f_if                 # sygnał 100 MHz i lustro 121,4 MHz
lo_sin = np.cos(2*np.pi*f_lo*t)
lo_sq = np.sign(lo_sin)                                 # mieszacz przełączający
fr = np.fft.rfftfreq(N, 1/fs)
for name, rf in [("sygnał 100 MHz", f_rf), ("lustro 121,4 MHz", f_img)]:
    for lo_name, lo in [("sin", lo_sin), ("prostokąt", lo_sq)]:
        Y = np.abs(np.fft.rfft(np.cos(2*np.pi*rf*t)*lo))/N*2
        top = [i for i in np.argsort(Y)[::-1][:6] if Y[i] > 0.05]   # prążki powyżej -26 dB
        print(f"{name:18s} LO={lo_name:9s}: " + ", ".join(f"{fr[i]/1e6:6.1f} MHz ({20*np.log10(Y[i]):5.1f} dB)" for i in sorted(top)))

# jitter z płaskiego szumu fazowego
L, f1, f2, f0 = -100, 1e4, 1e6, 100e6
phi = np.sqrt(2*10**(L/10)*(f2 - f1))
print(f"jitter = {phi/(2*np.pi*f0)*1e12:.1f} ps rms; 20log(2440) = {20*np.log10(2440):.1f} dB")
```

Zauważ: sygnał i lustro dają **tę samą** p.cz. 10,7 MHz — mieszacz ich nie rozróżnia. Mieszacz przełączający daje dodatkowo produkty z nieparzystymi harmonicznymi LO.

## Zadania

1. RF 868 MHz, p.cz. 10,7 MHz, LO poniżej sygnału. Częstotliwość LO i lustrzana?
2. Dlaczego w odbiornikach radiofonii FM wybiera się p.cz. 10,7 MHz, a nie 455 kHz?
3. Syntezer integer-N ma dawać kanały co 25 kHz w paśmie 430–440 MHz. Jakie $f_{ref}$ i zakres $N$?
4. Oscylator 50 MHz ma −120 dBc/Hz płasko od 1 kHz do 10 MHz. Jaki jitter rms?
5. Silny sygnał −30 dBm odległy o 100 kHz od słabego sygnału, szum fazowy LO przy 100 kHz −110 dBc/Hz, pasmo kanału 10 kHz. Jaki poziom szumu wnosi mieszanie odwrotne do kanału?

<details>
<summary>Odpowiedzi</summary>

1. $f_{LO} = 857\text{,}3$ MHz, lustro $857\text{,}3 - 10\text{,}7 = 846\text{,}6$ MHz
2. Przy 455 kHz lustro leżałoby tylko 0,91 MHz od sygnału — wewnątrz pasma 88–108 MHz i nie do odfiltrowania przestrajanym filtrem wejściowym; przy 10,7 MHz lustro jest 21,4 MHz dalej, poza pasmem radiofonii
3. $f_{ref} = 25$ kHz, $N = 17\,200 \ldots 17\,600$
4. $\sqrt{2\cdot 10^{-12}\cdot 10^7} \approx 4\text{,}47$ mrad → $\sigma_t \approx 14$ ps
5. $-30 - 110 + 10\log(10^4) = -100$ dBm — szum ten zakryje słabe sygnały poniżej ok. −100 dBm, niezależnie od NF odbiornika
</details>

## Źródła

- [Analog Devices MT-080 — Mixers and Modulators](https://www.analog.com/media/en/training-seminars/tutorials/MT-080.pdf) — mieszacze, komórka Gilberta, modulatory I/Q
- [Microwave and RF Design: Radio Systems — M. Steer](https://open.umn.edu/opentextbooks/textbooks/microwave-and-rf-design-radio-systems) — mieszacze, oscylatory, szum fazowy w systemach
- [PySDR](https://pysdr.org) — sygnały I/Q, przemiana częstotliwości w SDR
- Noty aplikacyjne producentów syntezerów PLL — projekt filtra pętli, szum fazowy, fractional-N
