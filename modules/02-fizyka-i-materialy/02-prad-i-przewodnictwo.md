# 02.02 — Prąd i przewodnictwo

## Po co to jest

Model przewodnictwa łączy fizykę z teorią obwodów: z niego wynika prawo Ohma, rezystancja ścieżek na PCB, wpływ temperatury na rezystory i to, czym różni się przewodnictwo metali od półprzewodników.

## Teoria w pigułce

**Gęstość prądu:** $J = I/A$ [A/m²]. W przewodniku nośniki poruszają się chaotycznie z dużą prędkością termiczną, a pole elektryczne nadaje im niewielką **prędkość dryftu**:

$$v_d = \mu E$$

$\mu$ — ruchliwość [m²/(V·s)].

**Prawo Ohma w postaci mikroskopowej:** $J = \sigma E$, gdzie przewodność $\sigma = qn\mu$ ($n$ — koncentracja nośników). Rezystywność $\rho = 1/\sigma$.

**Rezystancja przewodnika:** $R = \rho\dfrac{l}{A}$.

| Materiał | $\rho$ w 20 °C [Ω·m] | Współczynnik temperaturowy $\alpha$ [1/K] |
|---|---|---|
| Srebro | $1\text{,}6\cdot 10^{-8}$ | 0,0038 |
| Miedź | $1\text{,}72\cdot 10^{-8}$ | 0,0039 |
| Aluminium | $2\text{,}8\cdot 10^{-8}$ | 0,0039 |
| Konstantan (stop rezystancyjny) | $4\text{,}9\cdot 10^{-7}$ | ok. 0,00001 |
| Krzem samoistny | ok. $2\cdot 10^{3}$ | ujemny |

**Zależność od temperatury (metale):** $R(T) \approx R_0\left[1 + \alpha(T - T_0)\right]$. Na tym opiera się czujnik Pt100.

**Gęstość mocy:** ciepło wydziela się w objętości przewodnika, $p = J^2\rho$. Ścieżki PCB i przewody dobiera się do prądu tak, by nagrzewanie było akceptowalne.

**Efekt naskórkowości:** przy wysokich częstotliwościach prąd płynie przy powierzchni przewodnika na głębokości $\delta = \sqrt{\dfrac{\rho}{\pi f\mu}}$ (dla miedzi przy 1 MHz ok. 66 µm). Rezystancja dla AC rośnie z częstotliwością — szczegóły w module [11](../11-pole-em-linie-anteny/).

## Przykład rozwiązany

Ścieżka PCB: miedź 35 µm (1 oz), szerokość 0,5 mm, długość 10 cm, prąd 1 A.

1. Przekrój: $A = 35\cdot 10^{-6}\cdot 0\text{,}5\cdot 10^{-3} = 1\text{,}75\cdot 10^{-8}$ m².
2. $R = 1\text{,}72\cdot 10^{-8}\cdot\dfrac{0\text{,}1}{1\text{,}75\cdot 10^{-8}} \approx 0\text{,}098\ \Omega$.
3. Spadek napięcia 98 mV, moc 98 mW — dla zasilania układu 3,3 V już zauważalne (3%).
4. W 70 °C rezystancja wzrośnie o ok. $0\text{,}0039\cdot 50 \approx 20\%$.

## Typowe pułapki

- **Prędkość dryftu mylona z prędkością sygnału.** Elektrony dryfują z prędkością rzędu mm/s, a sygnał (fala elektromagnetyczna) rozchodzi się z prędkością rzędu 0,5–1 $c$.
- **Rezystancja ścieżki pomijana** w obwodach zasilania i pomiarowych (pomiar Kelvina — moduł 08).
- **Liniowa zależność $R(T)$ stosowana do półprzewodników** — tam zależność jest silnie nieliniowa i zwykle o przeciwnym znaku.

## Ćwiczenie komputerowe

```python
rho, t = 1.72e-8, 35e-6
for w_mm in [0.2, 0.5, 1.0, 2.0]:
    R_per_cm = rho * 0.01 / (t * w_mm * 1e-3)
    print(f"{w_mm} mm: {R_per_cm*1e3:.1f} mΩ/cm")
```

## Zadania

1. Jaka jest rezystancja 10 m przewodu miedzianego o przekroju 1 mm²? A pętli (tam i z powrotem)?
2. Rezystor Pt100 ma 100 Ω w 0 °C, $\alpha = 0\text{,}00385$ 1/K. Ile ma w 100 °C?
3. Przewód miedziany 1 mm² przewodzi 10 A. Jaka jest gęstość prądu i prędkość dryftu elektronów ($n \approx 8\text{,}5\cdot 10^{28}$ m⁻³)?
4. Ścieżka 0,5 mm × 35 µm, długość 10 cm, prąd 1 A. Policz rezystancję i moc strat.
5. Zasilanie 5 V, 2 A dociera do urządzenia przewodem dwużyłowym o długości 2 m i przekroju 0,25 mm². Jakie napięcie dociera do urządzenia?

<details>
<summary>Odpowiedzi</summary>

1. $0\text{,}172\ \Omega$; pętla 20 m: $0\text{,}344\ \Omega$
2. $100(1 + 0\text{,}385) = 138\text{,}5\ \Omega$
3. $J = 10^7$ A/m²; $v_d = J/(qn) \approx \dfrac{10^7}{1\text{,}6\cdot 10^{-19}\cdot 8\text{,}5\cdot 10^{28}} \approx 0\text{,}74$ mm/s
4. $\approx 0\text{,}098\ \Omega$, $\approx 98$ mW
5. Długość pętli 4 m: $R = 1\text{,}72\cdot 10^{-8}\cdot 4/(0\text{,}25\cdot 10^{-6}) \approx 0\text{,}275\ \Omega$; spadek 0,55 V, do urządzenia dociera ok. 4,45 V
</details>

## Źródła

- [MIT 8.02 Physics II: Electricity and Magnetism](https://ocw.mit.edu/courses/8-02-physics-ii-electricity-and-magnetism-spring-2007/) — prąd, rezystywność, prawo Ohma
- [All About Circuits — tom DC, rozdział *Physics of Conductors and Insulators*](https://www.allaboutcircuits.com/textbook/)
- [DC Electrical Circuit Analysis — J. M. Fiore](https://eng.libretexts.org/Bookshelves/Electrical_Engineering/Electronics/DC_Electrical_Circuit_Analysis_-_A_Practical_Approach_%28Fiore%29) — rozdział o rezystancji i przewodnikach
