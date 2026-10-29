# 03.03 — Diody specjalne

## Po co to jest

Zwykła dioda prostownicza to tylko jeden z wielu przyrządów opartych na złączu. Diody Zenera stabilizują napięcie, Schottky'ego zmniejszają straty w przetwornicach, LED-y świecą, fotodiody mierzą światło, warikapy przestrajają obwody rezonansowe, a diody TVS chronią przed przepięciami.

## Teoria w pigułce

| Dioda | Zasada | Kluczowe parametry | Zastosowanie |
|---|---|---|---|
| **Zenera** | Praca w zakresie przebicia | $U_Z$, $r_z$, $I_{Z,min}$, $P_{max}$, współczynnik temperaturowy | Proste źródła napięcia odniesienia, zabezpieczenia |
| **Schottky'ego** | Złącze metal–półprzewodnik, brak nośników mniejszościowych | Mały spadek (0,2–0,45 V), praktycznie brak $t_{rr}$, **duży prąd wsteczny** | Przetwornice, zabezpieczenia przed odwrotną polaryzacją |
| **LED** | Rekombinacja promienista w półprzewodniku z prostą przerwą | $U_F$ zależne od barwy, prąd znamionowy | Sygnalizacja, oświetlenie, transoptory |
| **Fotodioda** | Generacja par nośników przez światło | Czułość (A/W), pojemność, prąd ciemny | Pomiar światła, odbiorniki optyczne |
| **Warikap (waraktor)** | Pojemność złączowa zależna od napięcia | $C(U_R)$, zakres przestrajania, dobroć | Przestrajanie VCO i filtrów |
| **TVS** | Szybkie przebicie lawinowe o dużej mocy | Napięcie pracy, napięcie ograniczania, moc impulsowa | Ochrona przed ESD i przepięciami |

### Dioda Zenera — stabilizator parametryczny

Źródło $U_{we}$ → rezystor $R$ → dioda Zenera równolegle z obciążeniem. Rezystor musi zapewnić minimalny prąd Zenera przy najgorszych warunkach (najmniejsze $U_{we}$, największy prąd obciążenia):

$$R \leq \frac{U_{we,min} - U_Z}{I_{L,max} + I_{Z,min}}$$

Projekt w szczegółach — [04.01](../04-uklady-analogowe/01-uklady-z-diodami.md).

### LED

Napięcie przewodzenia rośnie z energią fotonu: czerwona ok. 1,8–2,1 V, zielona 2,0–3,2 V, niebieska i biała 2,8–3,4 V. LED zasila się **prądem**, a rezystor szeregowy $R = (U_{zas} - U_F)/I_F$.

### Fotodioda

Prąd fotoelektryczny $I_{ph} = \mathcal{R}\cdot P$ ($\mathcal{R}$ — czułość, dla krzemu typowo 0,4–0,6 A/W przy ok. 800–900 nm).

- **Tryb fotowoltaiczny** (bez polaryzacji) — mały prąd ciemny, dobry do precyzyjnych pomiarów.
- **Tryb fotoprzewodzący** (polaryzacja zaporowa) — mniejsza pojemność, większa szybkość.

Prąd fotodiody zamienia się na napięcie wzmacniaczem transimpedancyjnym (TIA), [04.07](../04-uklady-analogowe/07-wzmacniacz-operacyjny-idealny.md).

## Przykład rozwiązany

**Przestrajanie obwodu LC warikapem.** $L = 1\ \mu$H, pojemność warikapu zmienia się od 10 pF (przy 0 V) do 3,5 pF (przy 5 V).

$$f = \frac{1}{2\pi\sqrt{LC}}: \quad 10\ \text{pF} \rightarrow 50\text{,}3\ \text{MHz}, \quad 3\text{,}5\ \text{pF} \rightarrow 85\text{,}1\ \text{MHz}$$

Pojemność zmienia się 2,86 razy, a częstotliwość tylko $\sqrt{2\text{,}86} \approx 1\text{,}69$ razy. Pojemności pasożytnicze dodają się do warikapu i zawężają zakres.

## Typowe pułapki

- **LED bez rezystora** podłączony bezpośrednio do zasilania — prąd ograniczony tylko rezystancją wewnętrzną źródła.
- **Zener jako precyzyjne źródło odniesienia.** Ma duży rozrzut, dryft i rezystancję dynamiczną. Do precyzji stosuje się układowe źródła odniesienia (bandgap).
- **Schottky w układzie wysokiej temperatury lub precyzyjnym** — prąd wsteczny rzędu µA–mA rośnie wykładniczo z temperaturą.
- **Fotodioda podłączona do zwykłego rezystora obciążenia** o dużej wartości — pojemność złącza z tym rezystorem bardzo ogranicza pasmo.

## Symulacja

```spice
* 03.03 stabilizator z dioda Zenera - wplyw obciazenia
V1 in 0 12
R1 in out 270
D1 0 out DZ
RL out 0 {RL}
.model DZ D(Bv=5.1 Ibv=5m Rs=5)
.step param RL list 1k 500 255 200
.op
.end
```

Obserwuj napięcie wyjściowe i prąd diody dla kolejnych obciążeń. Przy którym obciążeniu stabilizacja przestaje działać?

## Zadania

1. Niebieska LED ($U_F = 3\text{,}0$ V przy 5 mA) ma świecić z zasilania 3,3 V. Dobierz rezystor. Co się stanie, gdy napięcie zasilania spadnie do 3,1 V?
2. Dioda Zenera 5,1 V przewodzi 20 mA. Jaka moc się w niej wydziela?
3. Warikap zmienia pojemność od 10 pF do 3,5 pF, $L = 1\ \mu$H. Wyznacz zakres przestrajania.
4. Fotodioda o czułości 0,5 A/W jest oświetlona mocą 1 µW. Jakie napięcie da wzmacniacz transimpedancyjny z rezystorem 1 MΩ?
5. Dlaczego w przetwornicy 5 V → 3,3 V zastosowanie diody Schottky'ego zamiast zwykłej poprawia sprawność? Oszacuj różnicę strat przy prądzie diody 1 A średnio.

<details>
<summary>Odpowiedzi</summary>

1. $R = 0\text{,}3\ \text{V}/5\ \text{mA} = 60\ \Omega$; przy 3,1 V prąd spadnie do ok. 1,7 mA — przy tak małym zapasie napięcia jasność bardzo zależy od zasilania (lepiej zasilać źródłem prądowym)
2. $P \approx 102$ mW
3. ≈ 50,3–85,1 MHz
4. $I = 0\text{,}5\ \mu$A, $U = 0\text{,}5$ V
5. Spadek ok. 0,35 V zamiast ok. 0,8 V przy tym prądzie oraz brak strat na ładunek $t_{rr}$; straty przewodzenia ok. 0,35 W zamiast 0,8 W
</details>

## Źródła

- [Semiconductor Devices — J. M. Fiore](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html) — diody Zenera, LED, diody specjalne
- [All About Circuits — tom Semiconductors, rozdział *Diodes and Rectifiers*](https://www.allaboutcircuits.com/textbook/) — diody Zenera, Schottky'ego, LED, warikapy
- [Analog Devices — Electronics I and II](https://wiki.analog.com/university/courses/electronics/text/electronics-toc)
