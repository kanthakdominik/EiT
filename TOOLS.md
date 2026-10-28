# Narzędzia (wszystkie darmowe)

## Symulacja obwodów

| Narzędzie | Do czego | Link |
|---|---|---|
| **LTspice** | Główny symulator analogowy: punkt pracy, analiza AC, transient, szumy | [analog.com/ltspice](https://www.analog.com/en/resources/design-tools-and-calculators/ltspice-simulator.html) |
| **ngspice** | Otwartoźródłowy SPICE, sterowany netlistą; zintegrowany z KiCad | [ngspice.sourceforge.io](https://ngspice.sourceforge.io/) |
| **Falstad Circuit Simulator** | Animowany symulator w przeglądarce — świetny do budowania intuicji | [falstad.com/circuit](https://www.falstad.com/circuit/) · [gotowe przykłady](https://falstad.com/circuit/e-index.html) |
| **CircuitLab** | Symulator w przeglądarce (wersja darmowa ograniczona), powiązany z *Ultimate Electronics* | [circuitlab.com](https://www.circuitlab.com/) |

## Technika cyfrowa i HDL

| Narzędzie | Do czego | Link |
|---|---|---|
| **Logisim-evolution** | Projektowanie i symulacja układów logicznych, eksport do VHDL | [github.com/logisim-evolution](https://github.com/logisim-evolution/logisim-evolution) |
| **Digital** (H. Neemann) | Nowocześniejsza alternatywa dla Logisim, z eksportem do HDL | [github.com/hneemann/Digital](https://github.com/hneemann/Digital) |
| **nand2tetris Hardware Simulator** | Symulator HDL do kursu nand2tetris | [nand2tetris.org](https://www.nand2tetris.org/) |

## Projektowanie PCB

| Narzędzie | Do czego | Link |
|---|---|---|
| **KiCad** | Schematy, PCB, symulacja przez ngspice | [kicad.org](https://www.kicad.org/) |

## Obliczenia i analiza danych

| Narzędzie | Do czego |
|---|---|
| **Python + NumPy, SciPy, Matplotlib** | Rachunki zespolone, wykresy Bodego, FFT, filtry, porównanie wyników z symulacją |
| **SymPy** | Obliczenia symboliczne: rozwiązywanie układów równań obwodu, transformata Laplace'a |
| **Jupyter** | Notatniki łączące teorię, rachunki i wykresy |

Szybka instalacja:

```bash
pip install numpy scipy matplotlib sympy jupyter
```

## Laboratorium domowe (od modułu 03–04)

Na początek wystarczy:

- multimetr,
- płytka stykowa i przewody,
- zestaw rezystorów, kondensatorów, diod, tranzystorów (BJT i MOSFET), kilka wzmacniaczy operacyjnych,
- zasilacz laboratoryjny lub zasilanie niskonapięciowe,
- generator funkcyjny (może być tani moduł DDS),
- oscyloskop — nie jest niezbędny na starcie, ale bardzo przyspiesza naukę od modułu 04.
