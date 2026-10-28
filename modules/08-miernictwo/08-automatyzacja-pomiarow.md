# 08.08 — Automatyzacja pomiarów

## Po co to jest

Pomiar 50 punktów charakterystyki ręcznie zajmuje godzinę i jest podatny na pomyłki; skrypt zrobi to w minutę, powtarzalnie, z zapisem wszystkich ustawień. Automatyzacja to też podstawa testów produkcyjnych i charakteryzacji układów w funkcji temperatury czy napięcia zasilania.

## Teoria w pigułce

### Warstwy komunikacji z przyrządami

| Warstwa | Przykłady |
|---|---|
| Interfejs fizyczny | USB (USBTMC), LAN (VXI-11, HiSLIP, gniazdo TCP), GPIB, RS-232 |
| Biblioteka VISA | NI-VISA, Keysight VISA lub czysto pythonowa pyvisa-py |
| **Język poleceń SCPI** | Tekstowy, hierarchiczny: `MEAS:VOLT:DC?`, `SOUR:FREQ 1000` |
| Biblioteka w Pythonie | **PyVISA**, sterowniki producentów, PyMeasure |

**SCPI:** polecenia kończące się „?” to zapytania (zwracają odpowiedź). Wspólne polecenia IEEE 488.2: `*IDN?` (identyfikacja), `*RST` (reset), `*OPC?` (czekaj na zakończenie operacji), `*CLS` (kasowanie błędów), `SYST:ERR?` (odczyt kolejki błędów).

### Dobre praktyki

- Zawsze zaczynaj od `*IDN?` i `*RST`, ustaw wszystkie parametry jawnie (nie polegaj na stanie przyrządu).
- Synchronizuj: `*OPC?` lub odczyt po zakończeniu pomiaru, czas ustalania układu po zmianie pobudzenia.
- Sprawdzaj `SYST:ERR?` po sekwencji poleceń.
- **Zapisuj metadane:** model i numer seryjny przyrządów, ustawienia, datę, temperaturę, wersję skryptu.
- Zapisuj surowe dane (CSV, HDF5), przetwarzaj osobno.
- Ustaw limity zabezpieczające (prąd zasilacza, maksymalne napięcie) przed włączeniem wyjścia.

### Gdy nie ma przyrządów laboratoryjnych

Karta dźwiękowa (pasmo audio, 16–24 bity), przetwornik mikrokontrolera przesyłający dane przez UART/USB, tanie przyrządy USB (np. moduły z biblioteką w Pythonie). Zasady są te same: pobudzenie, akwizycja, zapis, analiza.

## Przykład rozwiązany

Pomiar charakterystyki filtra: generator i oscyloskop sterowane z Pythona. Poniższy kod ilustruje strukturę — polecenia SCPI dobiera się z dokumentacji konkretnego przyrządu (składnia się różni między producentami).

```python
# wymaga: pip install pyvisa pyvisa-py  oraz podłączonych przyrządów
import time, csv, numpy as np
import pyvisa

rm = pyvisa.ResourceManager()
gen = rm.open_resource("USB0::...::INSTR")      # adresy z rm.list_resources()
osc = rm.open_resource("USB0::...::INSTR")
print(gen.query("*IDN?"), osc.query("*IDN?"))

gen.write("*RST"); osc.write("*RST")
gen.write("SOUR1:FUNC SIN"); gen.write("SOUR1:VOLT 1"); gen.write("OUTP1 ON")

with open("bode.csv", "w", newline="") as fh:
    w = csv.writer(fh); w.writerow(["f_Hz", "Vin_Vpp", "Vout_Vpp", "phase_deg"])
    for f in np.logspace(1, 5, 50):
        gen.write(f"SOUR1:FREQ {f:.3f}")
        osc.write(f"TIM:SCAL {2/f/10:.3e}")          # ok. 2 okresy na ekranie
        time.sleep(0.3)                              # ustalenie układu i przyrządu
        vin  = float(osc.query("MEAS:VPP? CHAN1"))   # składnia zależna od producenta
        vout = float(osc.query("MEAS:VPP? CHAN2"))
        ph   = float(osc.query("MEAS:PHAS? CHAN2,CHAN1"))
        w.writerow([f, vin, vout, ph])
print(osc.query("SYST:ERR?"))
```

Analiza zapisanych danych (działa bez przyrządów — na danych z pliku lub z symulacji):

```python
import numpy as np
f = np.logspace(1, 5, 50)
H = 1/(1 + 1j*f/1e3)                                     # tu wczytaj dane z pliku bode.csv
gain_db = 20*np.log10(np.abs(H)); phase = np.degrees(np.angle(H))
fc = f[np.argmin(np.abs(gain_db + 3))]
print(f"f(-3 dB) ≈ {fc:.0f} Hz, faza tam ≈ {phase[np.argmin(np.abs(gain_db + 3))]:.1f}°")
```

## Typowe pułapki

- **Brak czasu na ustalenie** po zmianie częstotliwości lub zakresu — pierwsze odczyty są błędne.
- **Pomiar automatyczny oscyloskopu przy niewłaściwej podstawie czasu lub czułości** — wynik „9.9E37” (wartość nieprawidłowa) zamiast liczby; skrypt musi dopasowywać skalę i sprawdzać wyniki.
- **Brak zapisu ustawień** — za miesiąc nie wiadomo, w jakich warunkach zmierzono dane.
- **Włączenie wyjścia zasilacza przed ustawieniem ograniczenia prądu.**

## Ćwiczenie praktyczne

- [ ] Z dowolnym przyrządem z interfejsem USB/LAN: odczytaj `*IDN?`, wykonaj pojedynczy pomiar i odczytaj kolejkę błędów.
- [ ] Zautomatyzuj pomiar charakterystyki filtra (projekt modułowy).
- [ ] Bez przyrządów: zrealizuj ten sam pomiar kartą dźwiękową (biblioteka `sounddevice`) — generuj sinusy, nagrywaj wyjście filtra, licz amplitudę i fazę metodą korelacji z sygnałem odniesienia.

## Zadania

1. Do czego służą polecenia `*IDN?`, `*RST`, `*OPC?` i `SYST:ERR?`?
2. Ile czasu zajmie pomiar 50 punktów przy 0,3 s na ustalenie i 0,2 s na komunikację? Jak to skrócić?
3. Jakie metadane zapiszesz razem z charakterystyką filtra?
4. Dlaczego do pomiaru fazy przy 10 Hz potrzeba długiego czasu akwizycji i jak to uwzględnić w skrypcie?
5. Zaproponuj sposób sprawdzenia, że skrypt działa poprawnie, zanim zmierzysz nim nieznany układ.

<details>
<summary>Odpowiedzi</summary>

1. Identyfikacja przyrządu; przywrócenie ustawień domyślnych; oczekiwanie na zakończenie operacji (zwraca 1); odczyt błędów wykonania poleceń
2. 25 s; krótszy czas ustalania dla wysokich częstotliwości (zależny od okresu i stałej czasowej układu), pomiary wsadowe, równoległe przemiatanie
3. Przyrządy (model, numer seryjny, wersja oprogramowania), ustawienia (amplituda, impedancja, sondy, uśrednianie), układ badany, data, temperatura, wersja skryptu
4. Do wiarygodnego pomiaru potrzeba kilku okresów (setek ms) i dłuższego czasu ustalania układu; skrypt dopasowuje podstawę czasu i czas oczekiwania do częstotliwości
5. Zmierzyć znany układ referencyjny — np. bezpośrednie połączenie (wzmocnienie 0 dB, faza 0°) i prosty filtr RC z elementów o znanych wartościach
</details>

## Źródła

- [PyVISA](https://pyvisa.readthedocs.io/) — dokumentacja biblioteki
- [Hackaday — How to control your instruments from a computer](https://hackaday.com/2016/11/16/how-to-control-your-instruments-from-a-computer-its-easier-than-you-think) — praktyczne wprowadzenie do SCPI i VISA
- Podręczniki programowania (programming guide) konkretnych przyrządów — źródło składni poleceń SCPI
