# M03.03 — Podstawowe bloki analogowe

## Po co to jest

Każdy analogowy układ scalony — wzmacniacz, komparator, przetwornik, regulator napięcia, pętla PLL — składa się z kilku powtarzających się bloków: luster prądowych (polaryzacja i obciążenia aktywne), stopni wzmacniających, kaskod (duże wzmocnienie i rezystancja wyjściowa), pary różnicowej i źródeł odniesienia. W układzie scalonym, inaczej niż na płytce, rezystory i kondensatory są drogie i niedokładne, a tranzystory tanie i dobrze dopasowane — stąd obwody oparte na tranzystorach i stosunkach wymiarów. Temat rozwija [04.03–04.04](../../modules/04-uklady-analogowe/04-wzmacniacz-roznicowy-i-lustra.md) o perspektywę projektanta układów scalonych.

## Teoria w pigułce

### Lustra prądowe

- **Proste:** $I_{wy}/I_{we} = \dfrac{(W/L)_2}{(W/L)_1}\cdot\dfrac{1 + \lambda U_{DS2}}{1 + \lambda U_{DS1}}$ — błąd przy różnych napięciach dren–źródło; $R_{wy} = r_o$.
- **Kaskodowe:** $R_{wy} \approx g_mr_o^2$, ale wymaga większego zapasu napięcia (dwa $U_{DS,sat}$ + $U_T$ w wersji prostej).
- **Szerokiej skali (wide-swing), regulowane (z pętlą sprzężenia)** — mniejszy zapas napięcia lub większa $R_{wy}$.
- Dokładność: niedopasowanie $U_T$ (temat 05) — dla luster prąd zależy od $\Delta U_T\cdot g_m/I_D$: mniejsze $g_m/I_D$ (silniejsza inwersja) daje lepsze dopasowanie prądów.

### Stopnie wzmacniające

| Stopień | Wzmocnienie | $R_{we}$ / $R_{wy}$ | Zastosowanie |
|---|---|---|---|
| Wspólne źródło (CS) z obciążeniem aktywnym | $-g_m(r_{o,n}\parallel r_{o,p})$ (20–40 dB) | ∞ / $r_o\parallel r_o$ | Wzmacnianie |
| Wspólny dren (wtórnik) | $\approx 1$ (mniej przez efekt ciała) | ∞ / $1/g_m$ | Bufor napięciowy |
| Wspólna bramka (CG) | $g_mR_L$ | $1/g_m$ / duża | Kaskoda, wejścia prądowe |
| **Kaskoda** (CS + CG) | $\approx -g_m(g_mr_o^2\parallel R_L)$ (60–80 dB) | ∞ / $g_mr_o^2$ | Wzmacniacze jednostopniowe o dużym wzmocnieniu |
| **Para różnicowa** | $g_m(r_o\parallel r_o)$ (z lustrem jako obciążeniem) | ∞ | Wejścia wzmacniaczy, komparatorów |

- Pasmo stopnia z obciążeniem pojemnościowym: biegun $1/(2\pi R_{wy}C_L)$, iloczyn wzmocnienia i pasma $\approx g_m/(2\pi C_L)$ — tę wielkość ustala się przez $g_m$, a wzmocnienie przez $r_o$.
- **Efekt Millera:** pojemność bramka–dren widziana na wejściu jako $C_{gd}(1 + \lvert A\rvert)$ — kaskoda go eliminuje.
- **Kaskoda składana (folded cascode)** — wzmacniacz jednostopniowy o dużym wzmocnieniu i szerokim zakresie wejściowym; częsty w przetwornikach (OTA).

### Źródła odniesienia

- **Polaryzacja niezależna od zasilania** (np. źródło ze stałym $g_m$, β-multiplier).
- **Źródło napięcia odniesienia bandgap:** suma napięcia $U_{BE}$ (współczynnik ok. −2 mV/K) i napięcia proporcjonalnego do temperatury bezwzględnej $\Delta U_{BE} = U_T\ln N$ (PTAT) daje ok. 1,2 V o małym współczynniku temperaturowym ([04.11](../../modules/04-uklady-analogowe/11-stabilizatory.md)); w CMOS z tranzystorów bipolarnych pasożytniczych (p+/studnia n/podłoże p).
- Przy niskich napięciach zasilania — bandgap prądowy lub odniesienia z tranzystorami w słabej inwersji.

## Przykład rozwiązany

**Porównanie stopni** ($g_m = 1$ mS, $r_o = 100$ kΩ, obciążenie 1 pF):

- CS z obciążeniem aktywnym: $A = -1\text{ mS}\cdot 50\text{ kΩ} = -50$ (34 dB), $f_{-3\,\text{dB}} = 1/(2\pi\cdot 50\text{ kΩ}\cdot 1\text{ pF}) = 3\text{,}2$ MHz, GBW = 159 MHz.
- Kaskoda NMOS z obciążeniem kaskodą PMOS: $R_{wy} \approx (g_mr_o^2)/2 = 5$ MΩ → $A \approx 5000$ (74 dB) przy tym samym GBW (159 MHz) — biegun dominujący przesuwa się do ok. 32 kHz.
- Lustro proste przy $\lambda = 0\text{,}1$ V⁻¹: gdy $U_{DS}$ tranzystora wyjściowego zmienia się od 0,3 do 1,5 V, prąd zmienia się od 0,97 do 1,09 względem wejściowego — ±6%; kaskoda zmniejsza tę zależność ok. $g_mr_o$ razy.

## Typowe pułapki

- **Lustro z minimalnym $L$** — duży błąd przez modulację długości kanału i niedopasowanie.
- **Kaskoda bez zapasu napięcia** — w narożniku SS i przy niskim zasilaniu tranzystory wychodzą z nasycenia, wzmocnienie spada o rzędy wielkości.
- **Zapomnienie o pojemności Millera** w stopniu CS o dużym wzmocnieniu.
- **Brak obwodu startowego** w źródłach samopolaryzujących (β-multiplier, bandgap) — stan stabilny z zerowym prądem.
- **Wtórnik źródłowy z efektem ciała** — wzmocnienie 0,8–0,9 zamiast 1 i przesunięcie poziomu.

## Ćwiczenie komputerowe

Wzmocnienia, rezystancje wyjściowe i pasmo podstawowych stopni (model małosygnałowy):

```python
import numpy as np

# stopień ze wspólnym źródłem, kaskoda i lustro prądowe — wzory małosygnałowe
gm, ro_n, ro_p = 1e-3, 100e3, 100e3
print(f"CS z obciążeniem aktywnym: A = −gm(ro_n‖ro_p) = {-gm*ro_n*ro_p/(ro_n + ro_p):.0f} ({20*np.log10(gm*ro_n*ro_p/(ro_n + ro_p)):.1f} dB)")
Rout_casc = gm*ro_n*ro_n                                 # kaskoda NMOS: ≈ gm·ro²
print(f"rezystancja wyjściowa kaskody ≈ gm·ro² = {Rout_casc/1e6:.0f} MΩ; wzmocnienie z obciążeniem kaskodą PMOS: "
      f"{gm*(Rout_casc/2):.0f} ({20*np.log10(gm*Rout_casc/2):.0f} dB)")

# lustro prądowe: błąd prądu przez efekt modulacji długości kanału (różne U_DS)
lam = 0.1                                               # 1/V (krótki kanał)
for Vds_out in (0.3, 0.9, 1.5):
    Vds_in = 0.6                                        # U_DS tranzystora wejściowego = U_GS
    ratio = (1 + lam*Vds_out)/(1 + lam*Vds_in)
    print(f"lustro proste: U_DS,wy = {Vds_out} V → I_wy/I_we = {ratio:.3f}")

# biegun i pasmo stopnia CS z obciążeniem pojemnościowym
CL = 1e-12
Rout = ro_n*ro_p/(ro_n + ro_p)
f3 = 1/(2*np.pi*Rout*CL)
print(f"CL = 1 pF: f_-3dB = {f3/1e6:.2f} MHz, GBW = gm/(2π CL) = {gm/(2*np.pi*CL)/1e6:.0f} MHz")
```

Ćwiczenie z PDK: w xschem narysuj lustro proste i kaskodowe (NMOS, $L$ = 1 µm) i zasymuluj $I_{wy}(U_{wy})$; porównaj rezystancję wyjściową i minimalne napięcie wyjściowe z obliczeniami.

## Zadania

1. Para różnicowa z obciążeniem lustrem: $g_m = 200$ µS, $r_{o,n} = r_{o,p} = 500$ kΩ. Wzmocnienie różnicowe?
2. Kaskoda: $g_m = 1$ mS, $r_o = 50$ kΩ. Rezystancja wyjściowa?
3. Lustro proste ma wejście przy $U_{DS} = 0\text{,}7$ V, wyjście pracuje przy 1,2 V, $\lambda = 0\text{,}05$ V⁻¹. Błąd prądu?
4. Dlaczego bandgap wytwarza ok. 1,2 V niezależnie od procesu?
5. Stopień CS ma wzmocnienie 40 i $C_{gd} = 10$ fF. Jaka pojemność Millera obciąża wejście?

<details>
<summary>Odpowiedzi</summary>

1. $200\ \mu\text{S}\cdot 250\ \text{kΩ} = 50$ (34 dB)
2. $g_mr_o^2 = 10^{-3}\cdot(5\cdot 10^4)^2 = 2\text{,}5$ MΩ
3. $(1 + 0\text{,}06)/(1 + 0\text{,}035) = 1\text{,}024$ → ok. +2,4%
4. Napięcie, przy którym współczynniki temperaturowe $U_{BE}$ i składnika PTAT się znoszą, jest bliskie przerwie energetycznej krzemu ekstrapolowanej do 0 K (ok. 1,2 V) — wielkość fizyczna, nie technologiczna
5. $C_{gd}(1 + 40) = 410$ fF
</details>

## Źródła

- [MIT 6.012 Microelectronic Devices and Circuits](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-spring-2009/) — stopnie wzmacniające i lustra
- [IIC-OSIC-TOOLS (GitHub)](https://github.com/iic-jku/IIC-OSIC-TOOLS) — środowisko do ćwiczeń z PDK
- B. Razavi — *Design of Analog CMOS Integrated Circuits* (płatna) — rozdziały 3–5, 11
