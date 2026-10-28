# 10.08 — Zastosowania w elektronice: zasilacze, PLL, silniki, temperatura

## Po co to jest

Automatyka w elektronice to nie osobna dziedzina — to codzienność. Każdy stabilizator, przetwornica, pętla PLL, sterownik silnika czy termostat jest układem regulacji. Ten temat pokazuje, jak narzędzia z modułu przekładają się na konkretne układy, i odsyła do modułów, w których są rozwinięte.

## Teoria w pigułce

### Wzmacniacz operacyjny i stabilizator

Wzmacniacz z ujemnym sprzężeniem zwrotnym: pętla $L = A(s)\beta$. Zapas fazy decyduje o przeregulowaniu odpowiedzi i stabilności przy obciążeniu pojemnościowym ([04.06](../04-uklady-analogowe/06-sprzezenie-zwrotne-i-stabilnosc.md), [04.08](../04-uklady-analogowe/08-wzmacniacz-operacyjny-rzeczywisty.md)). Stabilizator LDO — pętla z biegunem od kondensatora wyjściowego i jego ESR ([04.11](../04-uklady-analogowe/11-stabilizatory.md)).

### Przetwornica DC-DC

Przetwornica obniżająca (buck) w trybie napięciowym: obiekt = modulator PWM + filtr LC z biegunem podwójnym w $f_0 = \dfrac{1}{2\pi\sqrt{LC}}$ (faza spada o 180°) i zerem od ESR kondensatora. Regulator **typu III** (dwa zera, trzy bieguny, w tym całkowanie) kompensuje fazę wokół $f_0$. W trybie prądowym wewnętrzna pętla prądowa redukuje obiekt prawie do pierwszego rzędu — wystarcza regulator **typu II**. Pulsacja odcięcia zwykle do ok. 1/10–1/5 częstotliwości przełączania. Weryfikacja: pomiar pętli przez wstrzyknięcie sygnału na rezystorze w pętli sprzężenia ([08.04](../08-miernictwo/04-generatory-i-analizatory.md)). Szczegóły — moduł [15](../15-energoelektronika-zasilanie/).

### Pętla synchronizacji fazy (PLL)

Detektor fazy → filtr pętli → VCO → dzielnik $1/N$ → detektor. VCO całkuje: faza = całka częstotliwości, więc obiekt zawiera $K_{VCO}/s$. Z pompą ładunku i filtrem pasywnym (kondensator + rezystor) pętla ma drugi integrator i zero — pętla typu 2, zerowy uchyb fazy w stanie ustalonym. Dobór pasma pętli: kompromis między tłumieniem szumu fazowego referencji (wąskie pasmo) a tłumieniem szumu VCO i szybkością przestrajania (szerokie pasmo). Zapas fazy typowo 45–60°. Szczegóły — moduły [12](../12-technika-wcz-rf/) i [13](../13-telekomunikacja/).

### Napęd silnika

Struktura kaskadowa: wewnętrzna pętla prądu (moment) — najszybsza, pętla prędkości, zewnętrzna pętla położenia. Każda pętla kilka razy wolniejsza od wewnętrznej — wtedy wewnętrzną można traktować jak proste wzmocnienie. Prędkość od momentu: $\dfrac{1}{Js + b}$; położenie dodaje $1/s$.

### Regulacja temperatury

Obiekt wolny, z opóźnieniem transportowym, sterowanie jednostronne (grzanie bez chłodzenia) i nasycone. Proste rozwiązania: regulacja dwustanowa z histerezą (oscylacje wokół zadanej, amplituda zależna od opóźnienia i histerezy), PI z anti-windup (projekt modułowy). Przy opóźnieniu dominującym nad stałą czasową: predyktor Smitha lub wolniejszy regulator.

## Przykład rozwiązany

**Filtr LC przetwornicy buck:** $L = 10$ µH, $C = 100$ µF → $f_0 = \dfrac{1}{2\pi\sqrt{10^{-5}\cdot 10^{-4}}} \approx 5{,}03$ kHz. Przy częstotliwości przełączania 500 kHz pulsacja odcięcia pętli może sięgać ok. 50 kHz — dziesięć razy powyżej $f_0$, czyli w obszarze, gdzie filtr ma już fazę bliską −180° (przy pominięciu ESR). Regulator musi tam dostarczyć ok. +45…+60° fazy: dwa zera w okolicy $f_0$ (regulator typu III).

**Kaskada silnika:** pętla prądu z pasmem 1 kHz, pętla prędkości 100 Hz, pętla położenia 10 Hz — każda 10 razy wolniejsza.

## Typowe pułapki

- **Regulator przetwornicy dobrany bez uwzględnienia ESR kondensatora wyjściowego** — wymiana kondensatora na ceramiczny (mały ESR) zmienia fazę i może zdestabilizować pętlę.
- **Pasmo pętli zbliżone do częstotliwości przełączania** — próbkujący charakter modulatora PWM daje dodatkowe opóźnienie.
- **Pętle kaskadowe o zbliżonych pasmach** — oddziałują na siebie, trudno je nastroić.
- **Zmiana punktu pracy** (napięcie wejściowe, obciążenie, temperatura) zmieniająca wzmocnienie obiektu — sprawdzaj zapasy w najgorszym przypadku.
- **Regulator dwustanowy bez histerezy** — bardzo częste przełączanie (zużycie przekaźnika, zakłócenia).

## Ćwiczenie komputerowe

Charakterystyka filtra LC przetwornicy z ESR kondensatora i bez:

```python
import numpy as np
from scipy import signal
import matplotlib.pyplot as plt

L, C, Rload = 10e-6, 100e-6, 1.0
f = np.logspace(2, 6, 1000); w = 2*np.pi*f
print(f"f0 = {1/(2*np.pi*np.sqrt(L*C))/1e3:.2f} kHz")
for esr in [1e-3, 30e-3]:
    # Vout/Vin = (1 + s C esr) / (s^2 L C (1 + esr/R) + s (L/R + C esr) + 1)
    num = [C*esr, 1]
    den = [L*C*(1 + esr/Rload), L/Rload + C*esr, 1]
    _, H = signal.freqs(num, den, w)
    plt.subplot(2, 1, 1); plt.semilogx(f, 20*np.log10(abs(H)), label=f'ESR={esr*1e3:.0f} mΩ')
    plt.subplot(2, 1, 2); plt.semilogx(f, np.unwrap(np.angle(H))*180/np.pi)
    i = np.argmin(abs(f - 50e3))
    print(f"ESR={esr*1e3:.0f} mΩ: faza przy 50 kHz = {np.degrees(np.angle(H[i])):.1f} deg, "
          f"zero ESR przy {1/(2*np.pi*C*esr)/1e3:.1f} kHz")
plt.subplot(2, 1, 1); plt.ylabel('|H| [dB]'); plt.legend(); plt.grid(which='both')
plt.subplot(2, 1, 2); plt.ylabel('faza [°]'); plt.xlabel('f [Hz]'); plt.grid(which='both'); plt.show()
```

## Zadania

1. Częstotliwość rezonansowa filtra LC 10 µH / 100 µF.
2. Dlaczego VCO w pętli PLL jest członem całkującym (z punktu widzenia fazy)?
3. Pętla prędkości silnika ma pasmo 100 Hz. Jakie pasmo powinna mieć pętla prądu, a jakie pętla położenia?
4. Termostat dwustanowy z histerezą ±0,5 K steruje obiektem z opóźnieniem 10 s. Dlaczego amplituda wahań temperatury jest większa niż 1 K?
5. Kondensator wyjściowy elektrolityczny (ESR 30 mΩ) zastąpiono ceramicznym (ESR 1 mΩ). Jak zmienia się faza filtra przy 50 kHz i co to oznacza dla regulatora?

<details>
<summary>Odpowiedzi</summary>

1. ≈ 5,03 kHz
2. Faza jest całką pulsacji: $\varphi(t) = \int\omega(t)\,dt$, a VCO zamienia napięcie na pulsację — transmitancja od napięcia do fazy to $K_{VCO}/s$
3. Np. pętla prądu ≥ ok. 500 Hz–1 kHz, pętla położenia ≤ ok. 10–20 Hz (separacja ok. 5–10 razy)
4. Po przełączeniu grzałki temperatura jeszcze przez czas opóźnienia zmienia się w tę samą stronę — przekracza próg histerezy o $\approx$ (szybkość zmian) × (opóźnienie)
5. Zero od ESR przesuwa się z ok. 53 kHz do ok. 1,6 MHz — przy 50 kHz faza spada z ok. −134° (zero ESR dodaje fazę) do ok. −176° (wyniki symulacji powyżej). Regulator musi dostarczyć więcej fazy — typ III zamiast typu II
</details>

## Źródła

- [MIT 6.302 Feedback Systems](https://ocw.mit.edu/courses/6-302-feedback-systems-spring-2007/) — sprzężenie zwrotne w układach elektronicznych, kompensacja, oscylatory
- [Feedback Systems — Åström, Murray](https://www.cds.caltech.edu/~murray/amwiki/Second_Edition.html) — przykłady (m.in. wzmacniacze, silniki, sterowanie kaskadowe)
- [Analog Devices — Electronics I and II](https://wiki.analog.com/university/courses/electronics/text/electronics-toc) — stabilność wzmacniaczy, układy zasilania
- Noty aplikacyjne producentów sterowników przetwornic dotyczące kompensacji pętli (typ II/III) i pomiaru pętli
