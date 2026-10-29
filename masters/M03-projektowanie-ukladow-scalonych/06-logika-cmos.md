# M03.06 — Logika CMOS: opóźnienie, wysiłek logiczny, moc

## Po co to jest

Cyfrowa część układu scalonego to miliony bramek z biblioteki komórek standardowych — projektant zwykle nie rysuje ich ręcznie, ale musi rozumieć, od czego zależy ich szybkość i pobór mocy: żeby dobrać napięcie zasilania i częstotliwość, ocenić raport analizy czasowej, zaprojektować bufory zegara i dużych obciążeń, zrozumieć, dlaczego układ grzeje się w trybie czuwania, i świadomie stosować techniki oszczędzania energii. Temat łączy [05 Technikę cyfrową](../../modules/05-technika-cyfrowa/) z fizyką tranzystora.

## Teoria w pigułce

### Inwerter CMOS

- Charakterystyka przejściowa: próg przełączania $U_M$ zależy od stosunku $\beta_p/\beta_n$ (zwykle PMOS 1,5–3 razy szerszy); marginesy zakłóceń.
- **Opóźnienie:** $t_p \approx 0\text{,}69R_{eff}C_L$; $R_{eff} \propto 1/(W(U_{DD} - U_T)^\alpha)$ — szybciej przy większym napięciu i szerszych tranzystorach.
- **Wpływ napięcia:** obniżanie $U_{DD}$ zmniejsza moc kwadratowo, ale opóźnienie rośnie (szczególnie blisko $U_T$).

### Wysiłek logiczny (logical effort)

Opóźnienie bramki w jednostkach $\tau$ (opóźnienie idealnego inwertera bez pasożytów): $d = gh + p$.

- $g$ — wysiłek logiczny (inwerter 1, NAND2 4/3, NOR2 5/3), $h = C_{wy}/C_{we}$ — wysiłek elektryczny, $p$ — opóźnienie pasożytnicze (inwerter ≈ 1).
- Ścieżka: $F = G\cdot B\cdot H$; minimalne opóźnienie, gdy każdy stopień ma ten sam wysiłek $f = F^{1/N}$: $D = NF^{1/N} + \sum p$.
- **Optymalny wysiłek stopnia ≈ 4** (3,6 przy $p = 1$) → liczba stopni $N \approx \log_4F$.
- Zastosowanie: bufory sterujące dużymi obciążeniami (zegar, szyny, pola wyjściowe), dobór wielkości bramek na ścieżce krytycznej.

### Moc

| Składnik | Wzór | Uwagi |
|---|---|---|
| **Dynamiczna** (przełączanie) | $P = \alpha C U_{DD}^2 f$ | Dominująca w stanie aktywnym |
| Zwarciowa | Prąd przez oba tranzystory w czasie zbocza | 5–10% przy dobrych zboczach |
| **Statyczna (upływ)** | $I_{leak}U_{DD}$ | Upływ podprogowy rośnie wykładniczo przy niższym $U_T$ i wyższej temperaturze; tunelowanie przez bramkę, upływ złącz |

Techniki: bramkowanie zegara (clock gating — zmniejsza $\alpha$), wiele napięć progowych (szybkie komórki LVT tylko na ścieżkach krytycznych, HVT gdzie indziej), wyłączanie zasilania bloków (power gating), dynamiczne skalowanie napięcia i częstotliwości (DVFS), praca przy napięciu bliskim progowemu (near-threshold) dla urządzeń ultra-niskiej mocy.

### Elementy sekwencyjne

Przerzutnik D (master–slave), parametry: $t_{clk\to Q}$, czas ustalenia $t_{setup}$, czas trzymania $t_{hold}$ — wejście do analizy czasowej (temat 07). Metastabilność przy naruszeniu okna — synchronizatory ([17.06](../../modules/17-fpga-hdl/06-domeny-zegarowe-cdc.md)).

## Przykład rozwiązany

**Bufor dla obciążenia 1 pF z wejścia 2 fF** ($\tau = 5$ ps, $p = 1$): $F = 512$.

| Liczba stopni | Wysiłek stopnia | Opóźnienie |
|---|---|---|
| 1 | 512 | 2565 ps |
| 3 | 8,0 | 135 ps |
| 4 | 4,8 | 115 ps |
| 5 | 3,5 | 112 ps |
| 6 | 2,8 | 115 ps |

Optimum przy 4–5 stopniach ($\log_4 512 = 4\text{,}5$), a różnica między 4 a 6 jest niewielka — minimum jest płaskie. Jeden duży inwerter byłby 20 razy wolniejszy.

**Moc:** $10^6$ bramek, $C = 1$ fF, $\alpha = 0\text{,}1$, 1 GHz, 0,8 V: $P_{dyn} = 64$ mW; przy 0,6 V — 36 mW (−44%), przy 1,0 V — 100 mW. Upływ 1 nA na bramkę daje 0,8 mW — w trybie czuwania to jedyny składnik i decyduje o czasie pracy na baterii.

## Typowe pułapki

- **Jedna wielka bramka do dużego obciążenia** zamiast łańcucha buforów.
- **Obniżenie napięcia bez sprawdzenia opóźnień** — w narożniku SS układ przestaje spełniać wymagania czasowe.
- **Ignorowanie upływu** w układach zasilanych z baterii — w wysokiej temperaturze rośnie kilkadziesiąt razy.
- **Bramkowanie zegara bramką AND bez zatrzasku** — szpilki zegara; używaj komórek ICG z biblioteki.
- **Mylenie częstotliwości zegara z aktywnością** — moc zależy od tego, ile węzłów faktycznie się przełącza.

## Ćwiczenie komputerowe

Optymalna liczba stopni bufora (wysiłek logiczny) i bilans mocy dynamicznej i statycznej:

```python
import numpy as np

# łańcuch inwerterów sterujący dużym obciążeniem: wysiłek logiczny
C_in, C_load, p, tau = 2e-15, 1.024e-12, 1.0, 5e-12      # wejście 2 fF, obciążenie ok. 1 pF, opóźnienie pasożytnicze p, τ = 5 ps
F = C_load/C_in
for N in range(1, 8):
    f = F**(1/N)
    D = N*(f + p)*tau
    print(f"N = {N}: wysiłek stopnia f = {f:7.2f}, opóźnienie ścieżki {D*1e12:7.1f} ps")
N_opt = np.log(F)/np.log(4)
print(f"F = {F:.0f}; optymalna liczba stopni ≈ log4(F) = {N_opt:.1f}")

# moc dynamiczna i statyczna
Ngates, C, alpha, f, V = 1e6, 1e-15, 0.1, 1e9, 0.8
P_dyn = alpha*Ngates*C*V**2*f
I_leak = 1e-9                                        # upływ na bramkę (przykładowo 1 nA)
print(f"moc dynamiczna α·N·C·V²·f = {P_dyn*1e3:.0f} mW, moc upływu N·I·V = {Ngates*I_leak*V*1e3:.1f} mW")
for V2 in (1.0, 0.8, 0.6):
    print(f"V = {V2} V: moc dynamiczna {alpha*Ngates*C*V2**2*f*1e3:.0f} mW ({(V2/0.8)**2*100:.0f}% wartości przy 0,8 V)")
```

Ćwiczenie z PDK: zasymuluj w ngspice łańcuch inwerterów z biblioteki komórek (np. `sky130_fd_sc_hd__inv_*`) obciążony 1 pF i porównaj opóźnienia z przewidywaniem metody wysiłku logicznego.

## Zadania

1. Ścieżka: NAND2 → NOR2 → inwerter, wysiłek elektryczny całkowity $H = 20$. Ile wynosi wysiłek ścieżki $F$ i optymalny wysiłek stopnia?
2. Ile stopni buforów potrzeba dla $F = 4000$?
3. Układ zużywa 200 mW przy 1,0 V i 500 MHz. Ile zużyje przy 0,8 V i 400 MHz (tylko moc dynamiczna)?
4. Dlaczego upływ podprogowy rośnie wykładniczo przy obniżaniu napięcia progowego?
5. Gdzie w układzie warto użyć komórek o wysokim napięciu progowym?

<details>
<summary>Odpowiedzi</summary>

1. $G = 4/3\cdot 5/3\cdot 1 = 2\text{,}22$; $F = GH = 44\text{,}4$; $f = 44\text{,}4^{1/3} \approx 3\text{,}54$
2. $\log_4 4000 \approx 6$
3. $200\cdot 0\text{,}8^2\cdot 0\text{,}8 = 102$ mW
4. Prąd podprogowy $\propto e^{(U_{GS} - U_T)/(nU_T)}$ — przy $U_{GS} = 0$ obniżenie $U_T$ o ok. 85–100 mV (nachylenie podprogowe) zwiększa upływ 10 razy
5. Na ścieżkach niekrytycznych czasowo (większość logiki) — mniejszy upływ przy nieznacznie większym opóźnieniu; komórki LVT tylko tam, gdzie brakuje zapasu czasu
</details>

## Źródła

- [MIT 6.374 Analysis and Design of Digital Integrated Circuits](https://ocw.mit.edu/courses/6-374-analysis-and-design-of-digital-integrated-circuits-fall-2003/) — inwerter, opóźnienia, moc, wysiłek logiczny
- [SkyWater SKY130 PDK (GitHub)](https://github.com/google/skywater-pdk) — biblioteki komórek standardowych
- N. Weste, D. Harris — *CMOS VLSI Design* (płatna)
