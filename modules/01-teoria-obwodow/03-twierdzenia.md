# 01.03 — Twierdzenia o obwodach

## Po co to jest

Twierdzenia upraszczają analizę. **Thévenin i Norton** są najważniejsze w praktyce: każde wyjście (czujnika, wzmacniacza, zasilacza) i każde wejście opisuje się źródłem z rezystancją wewnętrzną. Pojęcia rezystancji wejściowej i wyjściowej w układach elektronicznych to nic innego jak rezystancje Thévenina.

## Teoria w pigułce

### Superpozycja

W obwodzie **liniowym** odpowiedź na kilka źródeł niezależnych to suma odpowiedzi na każde źródło z osobna. Wyłączanie źródeł: **źródło napięciowe → zwarcie, źródło prądowe → przerwa.** Źródeł sterowanych się nie wyłącza.

Superpozycja **nie** dotyczy mocy (moc jest kwadratowa).

### Twierdzenie Thévenina

Dowolny liniowy dwójnik aktywny widziany z dwóch zacisków zastępuje się źródłem napięcia $E_{th}$ z szeregową rezystancją $R_{th}$:

- $E_{th}$ — napięcie na rozwartych zaciskach (napięcie jałowe),
- $R_{th}$ — rezystancja widziana z zacisków po wyłączeniu źródeł niezależnych, albo $R_{th} = \dfrac{U_{jał}}{I_{zw}}$ (gdy są źródła sterowane — zawsze tą drugą metodą lub przez przyłożenie źródła testowego).

### Twierdzenie Nortona

To samo, ale źródło prądowe $I_N = I_{zw}$ (prąd zwarcia) z równoległą $R_N = R_{th}$. Przejście: $E_{th} = I_N R_{th}$.

### Przekształcanie źródeł

Źródło napięcia $E$ z szeregowym $R$ ⇔ źródło prądu $E/R$ z równoległym $R$. Pozwala to łączyć gałęzie bez pisania równań.

### Twierdzenie Millmana

Napięcie węzła, do którego dochodzą gałęzie ($E_k$, $R_k$) i którego drugi koniec gałęzi jest wspólny:

$$V = \frac{\sum E_k/R_k}{\sum 1/R_k}$$

### Dopasowanie na maksimum mocy

Obciążenie pobiera maksymalną moc, gdy $R_L = R_{th}$. Wtedy $P_{max} = \dfrac{E_{th}^2}{4R_{th}}$, a sprawność wynosi tylko 50%. Dla prądu zmiennego: $Z_L = Z_{th}^*$ (sprzężenie).

W energetyce **nie** dopasowuje się mocy (liczy się sprawność, $R_L \gg R_{th}$). W technice w.cz. i telekomunikacji dopasowuje się zawsze.

### Przekształcenie gwiazda–trójkąt

Trójkąt → gwiazda: $R_a = \dfrac{R_{ab}R_{ca}}{R_{ab} + R_{bc} + R_{ca}}$ (iloczyn rezystancji przylegających do węzła przez sumę).

Gwiazda → trójkąt: $R_{ab} = \dfrac{R_aR_b + R_bR_c + R_cR_a}{R_c}$ (suma iloczynów przez rezystancję przeciwległą).

Dla elementów jednakowych: $R_Y = R_\Delta/3$.

## Przykład rozwiązany

**Superpozycja na obwodzie z tematu 02** ($E_1 = 12$ V/$R_1 = 2\ \Omega$, $R_3 = 4\ \Omega$, $R_2 = 2\ \Omega$/$E_2 = 6$ V):

1. Tylko $E_1$ ($E_2$ zwarte): $\dfrac{V - 12}{2} + \dfrac{V}{4} + \dfrac{V}{2} = 0 \Rightarrow V' = 4\text{,}8$ V.
2. Tylko $E_2$ ($E_1$ zwarte): $\dfrac{V}{2} + \dfrac{V}{4} + \dfrac{V - 6}{2} = 0 \Rightarrow V'' = 2\text{,}4$ V.
3. Razem: $V = 4\text{,}8 + 2\text{,}4 = 7\text{,}2$ V — tak samo jak metodą węzłową.

**Thévenin z pomiaru.** Wyjście czujnika ma napięcie jałowe 9 V, a po dołączeniu obciążenia 1 kΩ napięcie spada do 6 V. Z dzielnika: $6 = 9\cdot\dfrac{1\ \text{k}}{1\ \text{k} + R_{th}} \Rightarrow R_{th} = 500\ \Omega$. Dwa pomiary wystarczają, żeby poznać „wnętrze” dowolnego liniowego źródła.

## Typowe pułapki

- **Wyłączanie źródła prądowego przez zwarcie** (powinna być przerwa).
- **Superpozycja mocy.** Najpierw zsumuj prądy lub napięcia, potem licz moc.
- **$R_{th}$ z wyłączonymi źródłami, gdy w obwodzie są źródła sterowane** — da zły wynik. Użyj $U_{jał}/I_{zw}$ albo źródła testowego.
- **Dopasowanie mocy mylone z maksymalną sprawnością.**

## Symulacja

W LTspice wyznacz Thévenina „pomiarowo”: dołącz do zacisków źródło prądowe `I1` i wykonaj `.dc I1 0 1m 0.1m`. Napięcie na zaciskach jest prostą $U = E_{th} - R_{th}I$ — odczytaj punkt przecięcia z osią i nachylenie.

```spice
* 01.03 Thevenin pomiarowo
V1 1 0 10
R1 1 2 4k
R2 2 0 6k
R3 2 out 1.6k
I1 out 0 0
.dc I1 0 1m 0.1m
.end
```

## Zadania

1. $E = 10$ V, $R_1 = 4$ kΩ od źródła do węzła 2, $R_2 = 6$ kΩ z węzła 2 do masy, $R_3 = 1\text{,}6$ kΩ z węzła 2 do zacisku wyjściowego. Wyznacz zastępcze źródło Thévenina i Nortona widziane z zacisku wyjściowego i masy.
2. Jakie obciążenie pobierze z obwodu z zadania 1 maksymalną moc i ile ona wynosi?
3. Źródło 6 V przez $R_1 = 2$ kΩ i źródło prądowe 3 mA zasilają węzeł, z którego $R_2 = 1$ kΩ idzie do masy. Wyznacz napięcie węzła metodą superpozycji.
4. Przekształć trójkąt trzech rezystorów 30 Ω w gwiazdę. Przekształć gwiazdę 10 Ω, 20 Ω, 30 Ω w trójkąt.
5. Zamień źródło 12 V z szeregowym 4 Ω na równoważne źródło prądowe.
6. Trzy gałęzie zbiegają się w węźle: 10 V/10 Ω, 20 V/20 Ω oraz sam rezystor 20 Ω. Wyznacz napięcie węzła twierdzeniem Millmana.
7. Napięcie jałowe źródła wynosi 9 V, a z obciążeniem 1 kΩ — 6 V. Jaki prąd popłynie przy zwarciu zacisków?

<details>
<summary>Odpowiedzi</summary>

1. $E_{th} = 10\cdot\dfrac{6}{10} = 6$ V; $R_{th} = 4\parallel 6 + 1\text{,}6 = 2\text{,}4 + 1\text{,}6 = 4$ kΩ; Norton: $I_N = 1\text{,}5$ mA, $R_N = 4$ kΩ
2. $R_L = 4$ kΩ, $P = \dfrac{36}{4\cdot 4000} = 2\text{,}25$ mW
3. Tylko źródło napięciowe: $6\cdot\dfrac{1}{3} = 2$ V; tylko prądowe: $3\ \text{mA}\cdot(2\parallel 1)\ \text{k}\Omega = 2$ V; razem 4 V
4. Gwiazda: 3 × 10 Ω. Trójkąt: suma iloczynów 1100; $R_{ab} = 1100/30 \approx 36\text{,}7\ \Omega$, $R_{bc} = 1100/10 = 110\ \Omega$, $R_{ca} = 1100/20 = 55\ \Omega$ (przy $R_a = 10$, $R_b = 20$, $R_c = 30$)
5. 3 A z równoległym 4 Ω
6. $V = \dfrac{1 + 1 + 0}{0\text{,}1 + 0\text{,}05 + 0\text{,}05} = 10$ V
7. $R_{th} = 500\ \Omega$, $I_{zw} = 9/500 = 18$ mA
</details>

## Źródła

- [DC Electrical Circuit Analysis — J. M. Fiore](https://eng.libretexts.org/Bookshelves/Electrical_Engineering/Electronics/DC_Electrical_Circuit_Analysis_-_A_Practical_Approach_%28Fiore%29) — superpozycja, przekształcanie źródeł, Thévenin, Norton, maksymalna moc, gwiazda–trójkąt
- [Neso Academy — Network Theory](https://www.classcentral.com/classroom/youtube-network-theory-48208) — m.in. seria rozwiązanych zadań z twierdzenia o maksymalnej mocy
- [Analog Devices — Engineering University Program](https://wiki.analog.com/university) — ćwiczenie laboratoryjne z twierdzeń Thévenina i Nortona oraz dopasowania mocy
- [MIT 6.002 Circuits and Electronics](https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/)
