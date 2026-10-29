# M03.04 — Dwustopniowy wzmacniacz operacyjny CMOS

## Po co to jest

Dwustopniowy wzmacniacz z kompensacją Millera to „hello world” projektowania analogowego i jednocześnie blok używany w regulatorach LDO, filtrach, buforach odniesienia, przetwornikach i obwodach pomiarowych. Projekt pokazuje cały warsztat: rozdział specyfikacji na bloki, dobór $g_m$ z pasma, rozsuwanie biegunów, wpływ zera w prawej półpłaszczyźnie, rezystor zerujący, zakres napięć, pobór prądu i weryfikację w narożnikach.

## Teoria w pigułce

### Struktura

1. **Stopień 1:** para różnicowa (M1, M2) z lustrem (M3, M4) i źródłem prądowym (M5) — duże wzmocnienie $A_1 = g_{m1}(r_{o2}\parallel r_{o4})$.
2. **Stopień 2:** CS (M6) z obciążeniem prądowym (M7) — $A_2 = g_{m6}(r_{o6}\parallel r_{o7})$, duży zakres wyjściowy.
3. **Kompensacja:** kondensator $C_c$ (zwykle z rezystorem $R_z$) między wyjściem 1. i 2. stopnia.

### Bieguny i zera

- Biegun dominujący (efekt Millera na $C_c$): $p_1 \approx \dfrac{1}{R_1\,g_{m6}R_2\,C_c}$.
- Iloczyn wzmocnienia i pasma: **$GBW \approx \dfrac{g_{m1}}{2\pi C_c}$**.
- Biegun niedominujący (rozsunięty): $p_2 \approx \dfrac{g_{m6}}{2\pi C_L}$ (dla $C_c \gg C_1$).
- **Zero w prawej półpłaszczyźnie** $z = \dfrac{g_{m6}}{2\pi C_c}$ — dodaje opóźnienia fazy jak biegun, a podnosi moduł; obniża zapas fazy.
- **Rezystor zerujący** szeregowo z $C_c$: $z = \dfrac{1}{2\pi C_c(1/g_{m6} - R_z)}$ — $R_z = 1/g_{m6}$ usuwa zero, $R_z > 1/g_{m6}$ przenosi je do lewej półpłaszczyzny (można nim zniwelować $p_2$, ale to wrażliwe na rozrzut).

### Procedura projektowa (klasyczna)

1. $C_c \geq 0\text{,}22\,C_L$ (dla zapasu fazy ok. 60° z zerem ≥ 10 GBW) — w praktyce często $C_c \approx 0\text{,}5\,C_L$.
2. $g_{m1} = 2\pi\,GBW\,C_c$.
3. $g_{m6} \geq 2\text{,}2\cdot 2\pi\,GBW\,C_L$ (biegun $p_2 \geq 2\text{,}2\,GBW$) i często $g_{m6} \geq 10g_{m1}$ (zero wysoko).
4. Prądy z $g_m/I_D$ (temat 02): $I_{D1} = g_{m1}/(g_m/I_D)_1$, $I_{D6} = g_{m6}/(g_m/I_D)_6$.
5. **Szybkość narastania** (slew rate) $SR = I_5/C_c$ — sprawdź, czy wystarcza dla dużych sygnałów.
6. Zakresy: wejściowy wspólny (od $U_{GS1} + U_{DS5,sat}$), wyjściowy (od $U_{DS6,sat}$ do $U_{DD} - U_{DS7,sat}$).
7. Weryfikacja: AC (wzmocnienie, GBW, zapas fazy), odpowiedź skokowa w konfiguracji wtórnika, CMRR, PSRR, szum, offset (Monte Carlo), narożniki.

## Przykład rozwiązany

**Specyfikacja:** GBW 10 MHz, $C_L = 2$ pF, zapas fazy ≥ 60°.

1. $C_c = 1$ pF ($0\text{,}5C_L$).
2. $g_{m1} = 2\pi\cdot 10^7\cdot 10^{-12} = 62\text{,}8$ µS → przy $g_m/I_D = 15$: $I_{D1} = 4\text{,}2$ µA (prąd ogona 8,4 µA).
3. $g_{m6} = 2\text{,}2\cdot 2\pi\cdot 10^7\cdot 2\cdot 10^{-12} = 276$ µS → przy $g_m/I_D = 10$: $I_{D6} = 28$ µA.
4. Wzmocnienie DC przy $g_mr = 50$ w każdym stopniu: 2500 (68 dB).
5. Zapas fazy (model małosygnałowy z kodu): bez $R_z$ — 56° (zero RHP przy 44 MHz psuje fazę), z $R_z = 1/g_{m6} = 3\text{,}6$ kΩ — 67°. Szybkość narastania $8\text{,}4\ \mu\text{A}/1\text{ pF} = 8\text{,}4$ V/µs.

## Typowe pułapki

- **Projekt bez $R_z$** przy dużym $C_L$ — zero RHP obniża zapas fazy, odpowiedź skokowa dzwoni.
- **$R_z$ z rezystora polikrzemowego** o rozrzucie ±20% i innym współczynniku temperaturowym niż $1/g_m$ — zamiast rezystora tranzystor w zakresie triodowym, śledzący $g_{m6}$.
- **Weryfikacja zapasu fazy tylko w narożniku typowym** — przy SS i 125 °C $g_m$ maleje, bieguny się przesuwają.
- **Zbyt mała szybkość narastania** — wzmacniacz w odpowiedzi na duży skok jest ograniczony prądem, a nie pasmem.
- **Zapomnienie o offsecie systematycznym** — niedopasowanie gęstości prądu M6 względem M3/M4 daje offset nawet przy idealnych tranzystorach.

## Ćwiczenie komputerowe

Zapas fazy wzmacniacza Millera z modelu małosygnałowego (analiza węzłowa dwóch węzłów) dla różnych $R_z$:

```python
import numpy as np

# dwustopniowy wzmacniacz Millera — model małosygnałowy (dwa węzły), analiza w dziedzinie częstotliwości
GBW, CL = 10e6, 2e-12
Cc = 1e-12
gm1 = 2*np.pi*GBW*Cc                                    # GBW ≈ gm1/(2π Cc)
gm6 = 2.2*2*np.pi*GBW*CL                                # biegun wyjściowy ≈ gm6/CL ≥ 2,2·GBW
R1, R2 = 1/(gm1*0.02), 1/(gm6*0.02)                     # rezystancje węzłów: gm·r = 50 w każdym stopniu (np. ro/2)
C1 = 0.1e-12                                            # pojemność pasożytnicza węzła pierwszego stopnia
print(f"gm1 = {gm1*1e6:.1f} µS, gm6 = {gm6*1e6:.1f} µS, wzmocnienie DC = {gm1*R1*gm6*R2:.0f} ({20*np.log10(gm1*R1*gm6*R2):.1f} dB)")

f = np.logspace(2, 10, 200_001); s = 2j*np.pi*f
def openloop(Rz):
    Yc = 1/(Rz + 1/(s*Cc))                              # Cc szeregowo z rezystorem zerującym Rz
    # równania węzłów: v1 (wyjście 1. stopnia), v2 (wyjście); wejście v_in = 1
    a11 = 1/R1 + s*C1 + Yc; a12 = -Yc
    a21 = gm6 - Yc;        a22 = 1/R2 + s*CL + Yc
    b1 = -gm1                                            # prąd gm1·vin wypływający z węzła 1
    det = a11*a22 - a12*a21
    v2 = (-a21*b1)/det
    return v2

for Rz, name in ((0, "bez Rz"), (1/gm6, "Rz = 1/gm6"), (1/gm6*(1 + CL/Cc), "Rz = (1 + CL/Cc)/gm6")):
    H = openloop(Rz)
    mag = np.abs(H)
    i = np.argmax(mag < 1)
    ph = np.unwrap(np.angle(H))
    pm = 180 + np.degrees(ph[i] - ph[0]) + 0.0     # faza względem DC (wzmacniacz odwracający w pętli) 
    print(f"{name:20s}: częstotliwość przecięcia {f[i]/1e6:5.2f} MHz, zapas fazy {pm:5.1f}°")
```

Wartość $R_z = (1 + C_L/C_c)/g_{m6}$ umieszcza zero w lewej półpłaszczyźnie na biegunie $p_2$ — w modelu idealnym zapas fazy rośnie do prawie 90°, ale w rzeczywistości kompensacja biegun–zero jest wrażliwa na rozrzut i obciążenie, więc w praktyce wybiera się wartości pośrednie.

Ćwiczenie z PDK: zaprojektuj ten wzmacniacz w SKY130 lub SG13G2 (tablice $g_m/I_D$ z tematu 02), zasymuluj AC i skok w konfiguracji wtórnika we wszystkich narożnikach, a potem narysuj layout (temat 05).

## Zadania

1. Wymagane GBW 50 MHz przy $C_c = 0\text{,}5$ pF. Ile wynosi $g_{m1}$?
2. $C_L = 5$ pF, GBW 20 MHz. Jakie minimalne $g_{m6}$?
3. Prąd ogona 20 µA, $C_c = 2$ pF. Szybkość narastania?
4. Dlaczego zero w prawej półpłaszczyźnie jest groźniejsze od bieguna na tej samej częstotliwości?
5. Jak zmieni się GBW, jeśli w narożniku SS $g_{m1}$ spadnie o 20%?

<details>
<summary>Odpowiedzi</summary>

1. $2\pi\cdot 5\cdot 10^7\cdot 5\cdot 10^{-13} = 157$ µS
2. $2\text{,}2\cdot 2\pi\cdot 2\cdot 10^7\cdot 5\cdot 10^{-12} = 1\text{,}38$ mS
3. $20\ \mu\text{A}/2\ \text{pF} = 10$ V/µs
4. Daje opóźnienie fazy jak biegun (−90° asymptotycznie), ale nie tłumi modułu (wręcz go podnosi o 20 dB/dek) — pętla dostaje mniej zapasu fazy bez spadku wzmocnienia, który przesunąłby częstotliwość przecięcia w dół
5. Spadnie o ok. 20% (GBW ∝ $g_{m1}/C_c$); zapas fazy wzrośnie (przecięcie dalej od $p_2$), ale zwolni odpowiedź
</details>

## Źródła

- [IHP Open PDK — projektowanie z pygmid](https://ihp-open-pdk-docs.readthedocs.io/en/main/analog/pygmid.html) — przykładowy projekt wzmacniacza metodą gm/ID
- [Tiny Tapeout](https://tinytapeout.com/) — samouczki projektów analogowych
- B. Razavi — *Design of Analog CMOS Integrated Circuits* (płatna) — rozdział o kompensacji
- [04.06 Sprzężenie zwrotne i stabilność](../../modules/04-uklady-analogowe/06-sprzezenie-zwrotne-i-stabilnosc.md)
