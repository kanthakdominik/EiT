# M03.01 — Przepływ projektowy, PDK i otwarte narzędzia

## Po co to jest

Projekt układu scalonego to łańcuch narzędzi i sprawdzeń, w którym każdy błąd odkryty po produkcji kosztuje miesiące i dziesiątki tysięcy dolarów (lub więcej). Do niedawna narzędzia i dokumentacja procesów (PDK) były dostępne tylko dla firm i uczelni z umowami poufności. Od 2020 r. istnieją **otwarte PDK** (SkyWater SKY130, GlobalFoundries GF180MCU, IHP SG13G2) i kompletny zestaw otwartych narzędzi, a programy wielu projektów na jednej płytce (Tiny Tapeout) pozwalają wyprodukować własny układ za kilkaset dolarów lub mniej. Ten temat porządkuje przepływ i narzędzia, z którymi pracuje się w kolejnych tematach.

## Teoria w pigułce

### Co zawiera PDK

| Element | Do czego |
|---|---|
| Modele przyrządów (SPICE, BSIM4 itp.) z narożnikami procesu | Symulacja obwodów (TT, FF, SS, SF, FS; Monte Carlo) |
| Reguły projektowe (DRC) | Minimalne szerokości, odstępy, zakładki, gęstości warstw |
| Reguły LVS i ekstrakcji (PEX) | Rozpoznanie przyrządów w layoucie, ekstrakcja pasożytów |
| Biblioteki komórek standardowych | Bramki, przerzutniki (layout, modele czasowe Liberty, LEF) |
| Komórki wejścia/wyjścia, ESD | Pola kontaktowe, zabezpieczenia |
| Parametryczne komórki (PCells) | Tranzystory, rezystory, kondensatory MIM/MOM, cewki |
| Stos warstw | Liczba i grubości metali, dielektryki |

### Otwarte PDK

| PDK | Proces | Cechy |
|---|---|---|
| **SKY130** (SkyWater, Google) | 130 nm CMOS, 1,8 V rdzeń, 5 warstw metalu + lokalne połączenia | Najbardziej udokumentowany, wiele przykładów |
| **GF180MCU** (GlobalFoundries, Google) | 180 nm CMOS, 3,3/5 V | Układy mieszane, wyższe napięcia, produkcja przez wafer.space |
| **SG13G2** (IHP) | 130 nm BiCMOS z tranzystorami SiGe HBT (fT/fmax 350/450 GHz) | Układy w.cz. i mmWave, układy mieszane |

### Przepływy

**Analogowy (pełny projekt, full custom):** specyfikacja → schemat (xschem) → symulacja (ngspice, Xyce) w narożnikach i Monte Carlo → layout ręczny (Magic, KLayout) → DRC → LVS (Netgen) → ekstrakcja pasożytów → symulacja po ekstrakcji → integracja.

**Cyfrowy (komórki standardowe):** RTL (Verilog) → symulacja (Icarus, Verilator) → synteza (Yosys) → plan rozmieszczenia, sieć zasilania → rozmieszczenie → drzewo zegara (CTS) → trasowanie → STA (OpenSTA) → DRC/LVS → GDS. Zautomatyzowane w **LibreLane** (następca OpenLane, rozwijany przez FOSSi Foundation) i **OpenROAD-flow-scripts** (temat 07).

**Integracja i produkcja:** układ najwyższego poziomu z polami kontaktowymi, sprawdzenia końcowe (antenowe, gęstości, wypełnienie), GDS → producent. Programy MPW (wiele projektów na jednej płytce) dzielą koszt masek.

### Otwarte narzędzia — zestaw podstawowy

| Narzędzie | Rola |
|---|---|
| xschem | Schematy, symulacje, testbenche |
| ngspice, Xyce | Symulatory SPICE |
| Magic, KLayout | Layout, DRC, ekstrakcja; KLayout także podgląd GDS i DRC skryptowe |
| Netgen | LVS |
| Yosys, OpenROAD, OpenSTA | Synteza, implementacja, analiza czasowa |
| LibreLane | Zautomatyzowany przepływ RTL → GDS |
| cocotb, Verilator, Icarus | Weryfikacja cyfrowa |

Najprościej zacząć od kontenera **IIC-OSIC-TOOLS** (Uniwersytet Jana Keplera w Linzu) z kompletem narzędzi i PDK.

## Przykład rozwiązany

**Od schematu inwertera do zweryfikowanego layoutu** — co wykrywa każdy krok:

1. **Schemat i symulacja** (xschem + ngspice, narożniki TT/FF/SS, −40…125 °C): czy próg przełączania i czasy narastania spełniają wymagania — błąd projektu.
2. **Layout** (Magic): rozmieszczenie dyfuzji, bramki, kontaktów, metalu.
3. **DRC:** np. za mały odstęp metal–metal — layout niewykonalny lub zawodny.
4. **LVS** (ekstrakcja z Magic + Netgen): czy layout ma te same połączenia i wymiary tranzystorów co schemat — np. zapomniany kontakt do studni, zwarcie wejścia z wyjściem, zła szerokość.
5. **Ekstrakcja pasożytów** i ponowna symulacja: pojemności ścieżek zwiększają opóźnienie — czy specyfikacja nadal jest spełniona.

Każdy z tych etapów może przejść, a następny — nie; dopiero komplet daje pewność.

## Typowe pułapki

- **Symulacja tylko w narożniku typowym** — układ działa w symulacji, a w 30% egzemplarzy nie.
- **LVS „prawie czysty”** — każda rozbieżność musi być wyjaśniona; „nieistotne” różnice potrafią być zwarciem.
- **Pominięcie ekstrakcji pasożytów** w blokach szybkich i precyzyjnych.
- **Brak kontroli wersji i skryptów** — ręczne kroki niemożliwe do powtórzenia ([19.07](../../modules/19-programowanie/07-git.md)).
- **Mieszanie wersji PDK i narzędzi** — różne wyniki DRC/LVS; zamroź wersje (kontener).
- **Zapominanie o regułach antenowych i gęstości** — wykrywane dopiero przy końcowym sprawdzeniu przed produkcją.

## Ćwiczenie komputerowe

Szacunek powierzchni bloku cyfrowego z liczby bramek (parametry przykładowe — rzeczywiste odczytaj z biblioteki komórek PDK):

```python
import numpy as np

# szacunek powierzchni bloku cyfrowego z liczby bramek (parametry przykładowe — odczytaj z biblioteki komórek PDK)
cell_area_um2 = {"130 nm": 5.0, "180 nm": 9.0}        # średnia powierzchnia komórki (ok. NAND2) [µm²]
utilization = 0.6                                      # wypełnienie po rozmieszczeniu (reszta: trasowanie, bufory, odstępy)
for gates in (1_000, 20_000, 500_000):
    for node, a in cell_area_um2.items():
        area = gates*a/utilization
        side = np.sqrt(area)
        print(f"{gates:7d} bramek, {node}: rdzeń ≈ {area/1e6:7.3f} mm² (kwadrat {side:6.0f} µm)")

# czas symulacji: analogowa symulacja tranzystorowa a cyfrowa
print("Liczba tranzystorów ≈ 4 × liczba bramek; symulacja SPICE całego bloku 500 tys. bramek jest niepraktyczna — "
      "stąd hierarchia: SPICE dla bloków analogowych, symulacja zdarzeniowa (Verilog) i STA dla cyfrowych.")
```

Ćwiczenie praktyczne: zainstaluj kontener IIC-OSIC-TOOLS, otwórz przykład inwertera dla wybranego PDK, przeprowadź symulację, DRC i LVS, a następnie celowo wprowadź błąd w layoucie (usuń kontakt) i sprawdź, który krok go wykryje.

## Zadania

1. Wymień trzy rodzaje informacji, których nie da się uzyskać z samego schematu, a które daje layout po ekstrakcji.
2. Dlaczego bloki analogowe projektuje się ręcznie, a cyfrowe — automatycznie?
3. Do czego służą narożniki procesu SF i FS (w odróżnieniu od FF i SS)?
4. Który otwarty PDK wybierzesz do wzmacniacza niskoszumnego 24 GHz, a który do sterownika z wyjściem 5 V?
5. Co to jest MPW i dlaczego obniża koszt produkcji prototypów?

<details>
<summary>Odpowiedzi</summary>

1. Pojemności i rezystancje połączeń, sprzężenia między ścieżkami, rzeczywiste pojemności złącz źródła/drenu zależne od geometrii, efekty bliskości studni, naprężeń (LOD)
2. Układy analogowe są wrażliwe na każdy szczegół geometrii (dopasowanie, symetria, pasożyty, sprzężenia) i mają małą liczbę elementów; cyfrowe mają miliony elementów i są odporne na drobne różnice — automatyzacja z komórkami standardowymi i STA jest jedyną drogą
3. Narożniki mieszane (NMOS wolny/PMOS szybki i odwrotnie) — ważne dla układów, w których liczy się równowaga N/P: próg przełączania inwertera, przesunięcie wyjścia, czasy narastania i opadania w pamięciach i zatrzaskach
4. W.cz. 24 GHz: IHP SG13G2 (tranzystory SiGe HBT o fT 350 GHz); wyjście 5 V: GF180MCU (przyrządy 5 V)
5. Multi-Project Wafer — wiele projektów różnych klientów na jednym komplecie masek i płytek; koszt masek (setki tysięcy USD i więcej w zaawansowanych procesach) dzieli się na wszystkich uczestników, a każdy dostaje kilka–kilkadziesiąt egzemplarzy
</details>

## Źródła

- [IIC-OSIC-TOOLS (GitHub)](https://github.com/iic-jku/IIC-OSIC-TOOLS)
- [Tiny Tapeout](https://tinytapeout.com/) — samouczki i szablony projektów
- [Dokumentacja otwartych PDK](https://open-source-pdks.readthedocs.io) i [IHP Open PDK](https://github.com/IHP-GmbH/IHP-Open-PDK)
- [LibreLane (GitHub)](https://github.com/librelane/librelane)
