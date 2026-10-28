# 01.11 — Obwody trójfazowe

## Po co to jest

W EiT obwody trójfazowe pojawiają się krócej niż w elektrotechnice, ale elektronik musi je znać: zasilanie urządzeń przemysłowych, prostowniki trójfazowe, falowniki i sterowanie silników, a przede wszystkim bezpieczeństwo pracy z siecią 230/400 V.

## Teoria w pigułce

Układ trójfazowy to trzy napięcia sinusoidalne o tej samej amplitudzie, przesunięte o 120°:

$$\underline{U}_{L1} = U_f\angle 0^\circ, \quad \underline{U}_{L2} = U_f\angle -120^\circ, \quad \underline{U}_{L3} = U_f\angle +120^\circ$$

Suma trzech symetrycznych napięć fazowych wynosi zero.

### Gwiazda (Y) i trójkąt (Δ)

| | Gwiazda | Trójkąt |
|---|---|---|
| Napięcie na odbiorniku fazowym | $U_f = U_p/\sqrt{3}$ | $U_p$ |
| Prąd przewodowy | $I_p = I_f$ | $I_p = \sqrt{3}I_f$ |

$U_p$ — napięcie przewodowe (między fazami), $U_f$ — fazowe. W sieci niskiego napięcia: $U_f = 230$ V, $U_p = 400$ V.

### Moc układu symetrycznego

$$P = \sqrt{3}\,U_pI_p\cos\varphi = 3U_fI_f\cos\varphi$$

### Przewód neutralny

Przy obciążeniu symetrycznym prąd w przewodzie neutralnym jest zerowy. Przy niesymetrycznym przewód N wyrównuje potencjał punktu gwiazdowego — jego przerwanie może spowodować groźne przepięcia na fazach mniej obciążonych.

**Bezpieczeństwo:** prace przy sieci wymagają uprawnień. Do eksperymentów elektronicznych używaj transformatorów separujących i napięć bezpiecznych.

## Przykład rozwiązany

Trzy jednakowe rezystory 23 Ω, sieć 230/400 V.

**Połączenie w gwiazdę:** $I_f = 230/23 = 10$ A, $P = 3\cdot 230\cdot 10 = 6{,}9$ kW.

**Połączenie w trójkąt:** $I_f = 400/23 \approx 17{,}4$ A, $I_p = \sqrt{3}\cdot 17{,}4 \approx 30{,}1$ A, $P = 3\cdot 400\cdot 17{,}4 \approx 20{,}9$ kW.

Te same rezystory w trójkącie pobierają **trzy razy większą** moc — na tym opiera się rozruch silników „gwiazda–trójkąt”.

## Typowe pułapki

- **Mylenie napięcia fazowego i przewodowego.**
- **$\sqrt{3}$ we wzorze na moc zastosowane do wielkości fazowych** (wtedy jest $3U_fI_f$).
- **Założenie, że prąd neutralny jest zawsze zerowy** — tylko przy obciążeniu symetrycznym.

## Symulacja

```spice
* 01.11 odbiornik symetryczny w gwiazde
V1 L1 0 SINE(0 325.27 50 0 0 0)
V2 L2 0 SINE(0 325.27 50 0 0 -120)
V3 L3 0 SINE(0 325.27 50 0 0 120)
R1 L1 N 23
R2 L2 N 23
R3 L3 N 23
RN N 0 1m
.tran 0 100m 60m
.end
```

Sprawdź prąd przez `RN` (przewód neutralny). Zmień jeden rezystor na 46 Ω i obserwuj, jak pojawia się prąd w przewodzie neutralnym.

## Zadania

1. Napięcie fazowe wynosi 230 V. Ile wynosi przewodowe?
2. Odbiornik rezystancyjny 23 Ω na fazę połączony w gwiazdę do sieci 230/400 V. Wyznacz prądy i moc.
3. Ten sam odbiornik połączony w trójkąt. Wyznacz prąd fazowy, przewodowy i moc. Ile razy wzrosła moc?
4. Silnik 400 V o mocy 5,5 kW i $\cos\varphi = 0{,}85$ (pomiń sprawność). Jaki pobiera prąd przewodowy?
5. Jaki prąd płynie w przewodzie neutralnym przy obciążeniu symetrycznym? Dlaczego?

<details>
<summary>Odpowiedzi</summary>

1. $230\sqrt{3} \approx 398$ V (w praktyce 400 V)
2. $I = 10$ A w każdej fazie, $P = 6{,}9$ kW
3. $I_f \approx 17{,}4$ A, $I_p \approx 30{,}1$ A, $P \approx 20{,}9$ kW — trzykrotnie więcej
4. $I = \dfrac{5500}{\sqrt{3}\cdot 400\cdot 0{,}85} \approx 9{,}34$ A
5. Zero — suma trzech prądów o równych amplitudach przesuniętych o 120° wynosi zero
</details>

## Źródła

- [All About Circuits — tom AC, rozdział o układach wielofazowych](https://www.allaboutcircuits.com/textbook/)
- [Lessons in Electric Circuits — wersja oryginalna](https://ibiblio.org/kuphaldt/electricCircuits/) — tom AC, układy wielofazowe i silniki
