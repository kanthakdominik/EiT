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
| **Icarus Verilog** | Symulator Verilog do testbenchy z modułu 17 (`bash modules/17-fpga-hdl/hdl/run_tests.sh`) | [steveicarus.github.io/iverilog](https://steveicarus.github.io/iverilog/) |
| **EDA Playground** | Symulatory HDL w przeglądarce, bez instalacji | [edaplayground.com](https://edaplayground.com) |
| **OSS CAD Suite** | Otwarty zestaw FPGA: Yosys (synteza), nextpnr (implementacja), symulatory, GTKWave | [github.com/YosysHQ/oss-cad-suite-build](https://github.com/YosysHQ/oss-cad-suite-build) |

## Projektowanie PCB

| Narzędzie | Do czego | Link |
|---|---|---|
| **KiCad** | Schematy, PCB, symulacja przez ngspice | [kicad.org](https://www.kicad.org/) |
| **Dokumentacja KiCad** | Edytor schematów i PCB, kalkulator ścieżek, eksport produkcyjny | [docs.kicad.org](https://docs.kicad.org/) |

## Radio i pomiary w.cz. (moduły 11–13)

| Narzędzie | Do czego | Link |
|---|---|---|
| **scikit-rf** | Parametry S, pliki Touchstone, wykres Smitha w Pythonie | [scikit-rf.readthedocs.io](https://scikit-rf.readthedocs.io) |
| **PySDR** (podręcznik z kodem) | Przetwarzanie próbek I/Q z odbiorników SDR w Pythonie | [pysdr.org](https://pysdr.org) |
| **PyVISA** | Sterowanie przyrządami pomiarowymi (moduł 08) | [pyvisa.readthedocs.io](https://pyvisa.readthedocs.io/) |

## Programowanie (moduł 19)

| Narzędzie | Do czego | Gdzie |
|---|---|---|
| **GCC / Clang** | Kompilacja C na komputerze, sanitizery (`-fsanitize=address,undefined`) | W systemie (Linux, macOS), na Windows przez WSL lub [MSYS2](https://www.msys2.org/) |
| **GNU make** | Budowanie projektów | [gnu.org/software/make](https://www.gnu.org/software/make/) |
| **GDB** | Debuger (także dla mikrokontrolerów przez OpenOCD) | [sourceware.org/gdb](https://sourceware.org/gdb/) |
| **Git** | Kontrola wersji | [git-scm.com](https://git-scm.com/) |
| **Visual Studio Code** | Edytor z obsługą C, Pythona, git i debugera | [code.visualstudio.com](https://code.visualstudio.com/) |
| **pytest** | Testy jednostkowe w Pythonie | [docs.pytest.org](https://docs.pytest.org/en/stable/) |

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

Dalej, zależnie od modułów: płytka z mikrokontrolerem i debuger (09), analizator stanów logicznych (09, 17), tani odbiornik SDR i analizator obwodów typu NanoVNA (11–13), płytka FPGA (17), stacja lutownicza na gorące powietrze (16).
