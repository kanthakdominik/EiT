# 03.06 — Tranzystor MOSFET

## Po co to jest

MOSFET to najczęściej produkowany przyrząd w historii: z niego zbudowane są procesory, pamięci, przetworniki i niemal cała logika CMOS. Dyskretne MOSFET-y mocy dominują w przetwornicach, sterownikach silników i kluczach zasilania.

## Teoria w pigułce

### Budowa (nMOS, kanał wzbogacany)

Podłoże p, dwa obszary n⁺ (źródło S i dren D), nad obszarem między nimi cienki tlenek i bramka G. Dodatnie napięcie bramki odpycha dziury i przyciąga elektrony — przy $U_{GS} > V_t$ (napięcie progowe) tworzy się kanał typu n łączący źródło z drenem. **Bramka jest izolowana** — w stanie ustalonym prąd bramki jest zerowy.

### Zakresy pracy (model kwadratowy)

$k = \mu_nC_{ox}\dfrac{W}{L}$, napięcie przesterowania $U_{ov} = U_{GS} - V_t$.

| Zakres | Warunek | Prąd drenu |
|---|---|---|
| Odcięcie | $U_{GS} < V_t$ | $I_D \approx 0$ |
| Liniowy (triodowy) | $U_{GS} > V_t$, $U_{DS} < U_{ov}$ | $I_D = k\left[U_{ov}U_{DS} - \dfrac{U_{DS}^2}{2}\right]$ |
| Nasycenie (pentodowy) | $U_{GS} > V_t$, $U_{DS} \geq U_{ov}$ | $I_D = \dfrac{k}{2}U_{ov}^2(1 + \lambda U_{DS})$ |

**Uwaga na nazewnictwo:** „nasycenie” MOSFET-a to zakres, w którym pracuje on jako **wzmacniacz** (prąd prawie niezależny od $U_{DS}$). Odpowiada stanowi aktywnemu BJT, a nie nasyceniu BJT!

Przy bardzo małym $U_{DS}$ kanał zachowuje się jak rezystor sterowany napięciem: $R_{DS} \approx \dfrac{1}{kU_{ov}}$.

### Rodzaje

- **nMOS / pMOS** — pMOS działa z odwróconymi znakami napięć i prądów; para nMOS + pMOS tworzy inwerter CMOS.
- **Wzbogacany** (normalnie wyłączony, $V_t > 0$ dla nMOS) — typowy.
- **Zubożany** (normalnie włączony) — rzadszy.

### Efekty drugiego rzędu

Modulacja długości kanału ($\lambda$, analog efektu Early'ego), efekt podłoża (wzrost $V_t$ przy napięciu źródło–podłoże), praca podprogowa (wykładnicza zależność prądu — ważna w układach niskiej mocy), nasycenie prędkości w krótkich kanałach (prąd rośnie liniowo, a nie kwadratowo z $U_{ov}$).

W tranzystorach dyskretnych **dioda podłożowa** (body diode) łączy źródło z drenem — MOSFET mocy przewodzi w jednym kierunku nawet wyłączony.

## Przykład rozwiązany

nMOS: $k = 2$ mA/V², $V_t = 1$ V, $\lambda = 0$.

1. $U_{GS} = 2$ V, $U_{DS} = 5$ V: $U_{ov} = 1$ V, $U_{DS} > U_{ov}$ → nasycenie. $I_D = \tfrac{2}{2}\cdot 1^2 = 1$ mA.
2. $U_{GS} = 3$ V, $U_{DS} = 0\text{,}5$ V: $U_{ov} = 2$ V $> U_{DS}$ → zakres liniowy. $I_D = 2[2\cdot 0\text{,}5 - 0\text{,}125] = 1\text{,}75$ mA.
3. $U_{GS} = 5$ V, małe $U_{DS}$: $R_{DS} \approx \dfrac{1}{2\cdot 10^{-3}\cdot 4} = 125\ \Omega$.

## Typowe pułapki

- **„Nasycenie” MOSFET-a utożsamione z nasyceniem BJT.**
- **$V_t$ z dokumentacji jako napięcie pełnego włączenia.** Katalogowe $U_{GS(th)}$ mierzy się przy prądzie rzędu 250 µA. Do pełnego włączenia potrzeba napięcia, przy którym podano $R_{DS(on)}$ (np. 4,5 V lub 10 V).
- **Pływająca bramka.** Bez rezystora do źródła bramka ładuje się zakłóceniami i tranzystor może się włączyć częściowo i przegrzać.
- **Pominięcie diody podłożowej** w układach, gdzie napięcie na drenie może spaść poniżej źródła.

## Symulacja

```spice
* 03.06 charakterystyki nMOS (model poziomu 1)
VDS d 0 5
VGS g 0 2
M1 d g 0 0 NM
.model NM NMOS(Level=1 Vto=1 Kp=2m Lambda=0.02)
.dc VDS 0 5 0.01 VGS 1.5 3.5 0.5
.end
```

`Kp` w modelu poziomu 1 odpowiada $k$ przy $W = L$. Zaznacz na wykresie granicę $U_{DS} = U_{GS} - V_t$ między zakresem liniowym a nasyceniem.

## Zadania

1. nMOS: $k = 2$ mA/V², $V_t = 1$ V. Wyznacz zakres pracy i $I_D$ przy $U_{GS} = 2$ V, $U_{DS} = 5$ V.
2. Ten sam tranzystor: $U_{GS} = 3$ V, $U_{DS} = 0\text{,}5$ V. Zakres i prąd?
3. Jakie napięcie $U_{GS}$ jest potrzebne, aby w nasyceniu płynął prąd 4 mA?
4. Wyznacz rezystancję kanału przy $U_{GS} = 5$ V i małym $U_{DS}$.
5. Dlaczego w układach cyfrowych CMOS tranzystor pMOS jest szerszy niż nMOS?
6. MOSFET mocy ma $U_{GS(th)} = 2$–4 V i $R_{DS(on)}$ podane przy $U_{GS} = 10$ V. Czy nadaje się do bezpośredniego sterowania z mikrokontrolera 3,3 V?

<details>
<summary>Odpowiedzi</summary>

1. Nasycenie, 1 mA
2. Liniowy, 1,75 mA
3. $U_{ov} = \sqrt{2\cdot 4/2} = 2$ V → $U_{GS} = 3$ V
4. 125 Ω
5. Ruchliwość dziur jest ok. 2–3 razy mniejsza niż elektronów; szerszy kanał wyrównuje prądy i czasy przełączania obu stron
6. Nie — przy 3,3 V może się w ogóle nie włączyć albo włączyć się częściowo z dużą rezystancją. Potrzebny tranzystor typu „logic level” z $R_{DS(on)}$ podanym przy 2,5–3,3 V albo driver bramki
</details>

## Źródła

- [MIT 6.012 Microelectronic Devices and Circuits](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-spring-2009/) — struktura MOS i model tranzystora
- [MIT 6.002 Circuits and Electronics](https://ocw.mit.edu/courses/6-002-circuits-and-electronics-spring-2007/) — MOSFET jako klucz i jako źródło prądowe sterowane napięciem
- [Semiconductor Devices — J. M. Fiore, rozdziały o tranzystorach polowych](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html)
- [Falstad — demonstracje MOSFET](https://falstad.com/circuit/e-index.html)
