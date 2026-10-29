# 09.04 — Przetwornik A/C, C/A i DMA

## Po co to jest

Wbudowany przetwornik A/C łączy mikrokontroler z czujnikami. Żeby pomiary były dokładne i równomiernie próbkowane, trzeba właściwie dobrać czas próbkowania, wyzwalać konwersje sprzętowo i przesyłać dane przez DMA — nie programowo w pętli.

## Teoria w pigułce

### Przetwornik SAR w mikrokontrolerze

Typowo 10–16 bitów, do kilku MS/s, wiele kanałów przez multiplekser. Teoria kwantyzacji i ENOB — [07.01](../07-cps-dsp/01-przetwarzanie-ac.md).

**Czas próbkowania (akwizycji).** Wejście to kondensator próbkujący $C_S$ (kilka pF) ładowany przez rezystancję źródła $R_{źr}$ i wewnętrzną rezystancję przełącznika $R_{ADC}$. Aby błąd był mniejszy niż ¼ LSB:

$$t_s \geq (R_{źr} + R_{ADC})\cdot C_S\cdot\ln\left(2^{N+2}\right)$$

Przy źródle wysokoomowym: dłuższy czas próbkowania, bufor (wtórnik na wzmacniaczu operacyjnym) albo kondensator przy wejściu (rzędu 1–10 nF), który dostarcza ładunek do $C_S$.

### Napięcie odniesienia

Często jest nim zasilanie (VDDA) — szumy i spadki zasilania wprost wpływają na wynik. Dla precyzji: zewnętrzne źródło odniesienia lub pomiar ratiometryczny ([08.06](../08-miernictwo/06-czujniki-i-tor-pomiarowy.md)). Kanał wewnętrznego źródła odniesienia pozwala zmierzyć rzeczywiste VDDA.

### Wyzwalanie i tryby

- Programowe (start z kodu) — nieregularne próbkowanie, jitter.
- **Sprzętowe z timera** — stała częstotliwość próbkowania, warunek poprawnej analizy widmowej i filtracji.
- Skanowanie wielu kanałów, tryb ciągły, oversampling sprzętowy, watchdog analogowy (przerwanie po przekroczeniu progu).

### DMA

Kontroler DMA przenosi dane z rejestru peryferium do bufora w RAM bez udziału procesora. **Podwójne buforowanie (ping-pong)** lub bufor kołowy z przerwaniami w połowie i na końcu: procesor przetwarza jedną połowę, gdy DMA wypełnia drugą.

**Spójność pamięci podręcznej:** na rdzeniach z pamięcią podręczną danych bufor DMA trzeba unieważnić (invalidate) przed odczytem albo umieścić w obszarze bez buforowania.

### Przetwornik C/A

Wbudowany przetwornik C/A (8–12 bitów) z buforem wyjściowym lub bez; wyzwalany timerem + DMA daje generator przebiegów. Alternatywa: PWM + filtr ([09.03](03-timery-i-pwm.md)).

## Przykład rozwiązany

Przetwornik 12-bitowy, $C_S = 8$ pF, $R_{ADC} = 1$ kΩ, źródło: dzielnik o rezystancji Thévenina 10 kΩ.

1. $\ln(2^{14}) \approx 9\text{,}7$.
2. $t_s \geq 11\ \text{k}\Omega\cdot 8\ \text{pF}\cdot 9\text{,}7 \approx 0\text{,}85\ \mu$s.
3. Przy zegarze A/C 12 MHz to ok. 10,2 cykla → ustaw najbliższą dłuższą wartość z dostępnych (np. 12,5 lub 13,5 cykla).
4. Dla dzielnika 100 kΩ potrzeba ok. 8 µs — albo kondensator 10 nF przy wejściu (wtedy pasmo sygnału ograniczy stała $R\cdot C$) albo bufor.

## Typowe pułapki

- **Domyślny, najkrótszy czas próbkowania** przy wysokoomowym źródle — wyniki zaniżone i zależne od poprzedniego kanału (przesłuch między kanałami).
- **Próbkowanie z pętli programu** — jitter i nierówne odstępy.
- **Brak filtra antyaliasingowego** przed przetwornikiem ([06.06](../06-sygnaly-i-systemy/06-probkowanie.md)).
- **Zakłócenia od cyfrowej części układu** w zasilaniu analogowym — osobne filtrowanie VDDA, kondensatory przy pinach, pomiary w czasie, gdy cyfrowa część jest cicha.
- **Przetwarzanie bufora DMA, który jest właśnie nadpisywany.**

## Ćwiczenie komputerowe

Model ładowania kondensatora próbkującego — błąd w LSB w funkcji czasu próbkowania:

```python
import numpy as np
N, Cs, Radc = 12, 8e-12, 1e3
for Rsrc in [1e3, 10e3, 100e3]:
    for ts in [0.1e-6, 1e-6, 10e-6]:
        err_lsb = 2**N*np.exp(-ts/((Rsrc + Radc)*Cs))
        print(f"R={Rsrc/1e3:>5.0f} k, ts={ts*1e6:>4.1f} us: błąd ≈ {err_lsb:8.3f} LSB")
```

## Zadania

1. Minimalny czas próbkowania dla 12 bitów, $C_S = 8$ pF, $R_{ADC} = 1$ kΩ, źródło 10 kΩ.
2. Jak zmieni się wynik dla źródła 100 kΩ? Zaproponuj dwa rozwiązania.
3. Przetwornik próbkuje 4 kanały z 10 kHz każdy, dane 16-bitowe do bufora podwójnego po 256 próbek na kanał. Ile RAM zajmuje bufor i co ile ms procesor dostaje przerwanie?
4. Wynik pomiaru napięcia 1,2 V przy założonym VDDA = 3,3 V wynosi 1489. Pomiar wewnętrznego źródła 1,212 V daje 1532. Jakie jest rzeczywiste VDDA i rzeczywiste napięcie mierzone?
5. Dlaczego bufor DMA na rdzeniu z pamięcią podręczną danych może zawierać stare dane?

<details>
<summary>Odpowiedzi</summary>

1. ≈ 0,85 µs
2. ≈ 7,8 µs; bufor (wtórnik) albo kondensator przy wejściu (np. 10 nF) + odpowiednio długi czas między próbkami
3. $4\cdot 256\cdot 2\ \text{B}\cdot 2 = 4096$ B; przerwanie po zapełnieniu połowy: 256 próbek na kanał przy 10 kHz → co 25,6 ms
4. $V_{DDA} = 1\text{,}212\cdot 4095/1532 \approx 3\text{,}24$ V; $U = 1489\cdot 3\text{,}24/4095 \approx 1\text{,}178$ V
5. Procesor czyta kopię w pamięci podręcznej, a DMA zapisało nowe dane bezpośrednio do RAM; bez unieważnienia linii pamięci podręcznej procesor widzi stare wartości
</details>

## Źródła

- [Embedded Systems — Shape the World (J. Valvano)](https://users.ece.utexas.edu/~valvano/Volume1/E-Book/) — przetworniki A/C i C/A, próbkowanie
- [The Scientist and Engineer's Guide to DSP — rozdział 3](http://www.dspguide.com/)
- [Analog Devices — Electronics I and II, rozdziały o przetwornikach](https://wiki.analog.com/university/courses/electronics/text/electronics-toc)
- Nota aplikacyjna producenta mikrokontrolera o dokładności przetwornika A/C (większość producentów ją publikuje)
