# 03.04 — Tranzystor bipolarny (BJT)

## Po co to jest

Tranzystor bipolarny jest wciąż podstawą wielu układów analogowych (wejścia wzmacniaczy operacyjnych, źródła odniesienia, lustra prądowe, stopnie mocy audio) i prostych kluczy. Jego wykładnicza charakterystyka daje dużą transkonduktancję przy małym prądzie.

## Teoria w pigułce

### Budowa i działanie (npn)

Dwa złącza: emiter–baza i baza–kolektor. Emiter jest silnie domieszkowany, baza bardzo cienka i słabo domieszkowana. Przy złączu BE spolaryzowanym w kierunku przewodzenia elektrony z emitera dyfundują do bazy; ponieważ baza jest cienka, prawie wszystkie docierają do złącza BC (spolaryzowanego zaporowo) i są „zbierane” przez kolektor.

$$I_C = I_Se^{U_{BE}/U_T}\left(1 + \frac{U_{CE}}{V_A}\right), \qquad I_C = \beta I_B, \qquad I_E = I_C + I_B, \qquad \alpha = \frac{\beta}{\beta + 1}$$

$\beta$ (= $h_{FE}$) typowo 50–500, **ma duży rozrzut i zależy od prądu i temperatury**. $V_A$ — napięcie Early'ego (efekt Early'ego: wzrost $U_{CE}$ zwęża efektywną bazę i zwiększa $I_C$).

### Stany pracy

| Stan | Złącze BE | Złącze BC | Właściwości |
|---|---|---|---|
| Odcięcie | zaporowo | zaporowo | $I_C \approx 0$ — klucz otwarty |
| Aktywny normalny | przewodzenie | zaporowo | $I_C = \beta I_B$ — wzmacnianie |
| Nasycenie | przewodzenie | przewodzenie | $U_{CE} \approx 0{,}1$–0,3 V, $I_C < \beta I_B$ — klucz zamknięty |
| Aktywny inwersyjny | zaporowo | przewodzenie | Rzadko używany |

**Procedura rozpoznania stanu:** załóż stan aktywny, policz $I_B$, $I_C$, $U_{CE}$. Jeśli wyszło $U_{CE} < 0{,}2$ V (albo ujemne) — tranzystor jest nasycony; policz ponownie z $U_{CE} = U_{CE,sat}$.

pnp działa tak samo z odwróconymi kierunkami prądów i napięć.

### Tranzystor jako klucz

Aby zapewnić nasycenie przy najgorszym $\beta$, prąd bazy dobiera się z zapasem (przesterowanie, typowo 2–5 razy):

$$I_B = k\cdot\frac{I_C}{\beta_{min}}$$

Głębokie nasycenie spowalnia wyłączanie (ładunek zgromadzony w bazie) — w szybkich kluczach stosuje się diodę Schottky'ego BC lub MOSFET.

### Ograniczenia

$U_{CEO}$ (maksymalne napięcie), $I_{C,max}$, $P_{tot}$, obszar bezpiecznej pracy SOA (w tym drugie przebicie), częstotliwość $f_T$.

## Przykład rozwiązany

**Klucz sterujący przekaźnikiem** z wyjścia mikrokontrolera 3,3 V. Cewka przekaźnika pobiera 100 mA, tranzystor ma $\beta_{min} = 50$.

1. Minimalny prąd bazy: $100/50 = 2$ mA; z zapasem 3×: $I_B = 6$ mA.
2. $R_B = \dfrac{3{,}3 - 0{,}8}{6\ \text{mA}} \approx 417\ \Omega$ → 390 Ω (wartość z szeregu, nieco większy prąd). Sprawdź, czy wyjście mikrokontrolera wytrzyma ok. 6,4 mA.
3. Równolegle do cewki — dioda gasząca (katodą do plusa zasilania)!
4. Straty w tranzystorze: $0{,}2\ \text{V}\cdot 0{,}1\ \text{A} = 20$ mW.

## Typowe pułapki

- **Założenie stanu aktywnego bez sprawdzenia** — klasyczny błąd z testu wejściowego (ujemne $U_{CE}$).
- **Projekt zależny od dokładnej wartości $\beta$.** Dobry układ działa poprawnie przy każdym $\beta$ z zakresu katalogowego.
- **Brak rezystora w bazie** — złącze BE to dioda, prąd ograniczony tylko wyjściem sterującym.
- **Pomylenie wyprowadzeń** — kolejność E-B-C zależy od obudowy i producenta.

## Symulacja

```spice
* 03.04 charakterystyki wyjsciowe 2N3904
VCE c 0 5
IB 0 b 10u
Q1 c b 0 2N3904
.model 2N3904 NPN(Is=6.734f Xti=3 Eg=1.11 Vaf=74.03 Bf=416.4 Ne=1.259 Ise=6.734f Ikf=66.78m Xtb=1.5 Br=.7371 Nc=2 Isc=0 Ikr=0 Rc=1 Cjc=3.638p Mjc=.3085 Vjc=.75 Fc=.5 Cje=4.493p Mje=.2593 Vje=.75 Tr=239.5n Tf=301.2p Itf=.4 Vtf=4 Xtf=2 Rb=10)
.dc VCE 0 10 0.05 IB 10u 50u 10u
.end
```

Wyświetl `Ic(Q1)`. Odczytaj $\beta$ dla kilku prądów bazy, przedłuż charakterystyki w lewo do przecięcia z osią $U_{CE}$ — punkt przecięcia to $-V_A$.

## Zadania

1. Tranzystor npn: $\beta = 100$, $R_B = 43$ kΩ z 5 V, $R_C = 1$ kΩ z 5 V. Wyznacz stan pracy i prąd kolektora.
2. Jak zmieni się odpowiedź na zadanie 1, jeśli $R_B = 470$ kΩ?
3. Dobierz $R_B$ klucza: obciążenie 100 mA, $\beta_{min} = 50$, sterowanie 3,3 V, przesterowanie 3×.
4. $I_E = 2$ mA, $\beta = 100$. Ile wynosi $I_C$, $I_B$ i $\alpha$?
5. Tranzystor ma $V_A = 100$ V. O ile procent wzrośnie $I_C$ przy zmianie $U_{CE}$ z 2 V na 12 V (przy stałym $U_{BE}$)?

<details>
<summary>Odpowiedzi</summary>

1. Nasycenie, $I_C \approx 4{,}8$ mA (stan aktywny dawałby $U_{CE} = -5$ V)
2. $I_B \approx 9{,}1\ \mu$A, $I_C \approx 0{,}91$ mA, $U_{CE} \approx 4{,}1$ V — stan aktywny
3. ≈ 417 Ω → 390 Ω
4. $I_B = 2/101 \approx 19{,}8\ \mu$A, $I_C \approx 1{,}98$ mA, $\alpha \approx 0{,}99$
5. $\dfrac{1 + 12/100}{1 + 2/100} \approx 1{,}098$ — o ok. 10%
</details>

## Źródła

- [Semiconductor Devices — J. M. Fiore, rozdziały o tranzystorze bipolarnym](http://www2.mvcc.edu/users/faculty/jfiore/freebooks.html)
- [MIT 6.012 Microelectronic Devices and Circuits](https://ocw.mit.edu/courses/6-012-microelectronic-devices-and-circuits-spring-2009/) — fizyka i modele BJT
- [All About Circuits — tom Semiconductors, rozdział *Bipolar Junction Transistors*](https://www.allaboutcircuits.com/textbook/)
- [Falstad — demonstracje tranzystorów bipolarnych](https://falstad.com/circuit/e-index.html)
