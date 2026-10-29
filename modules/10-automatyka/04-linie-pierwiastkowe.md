# 10.04 — Linie pierwiastkowe

## Po co to jest

Linie pierwiastkowe (root locus) pokazują, jak bieguny układu zamkniętego przesuwają się przy zmianie wzmocnienia. To graficzne narzędzie łączy wymagania czasowe (obszar dozwolony z [10.02](02-odpowiedzi-czasowe-i-uchyb.md)) z doborem wzmocnienia i umieszczeniem zer i biegunów kompensatora.

## Teoria w pigułce

Równanie charakterystyczne $1 + K\,G(s) = 0$, $G(s) = \dfrac{N(s)}{D(s)}$, czyli $D(s) + K N(s) = 0$. Dla $K$ od 0 do ∞ pierwiastki zakreślają linie:

- **start** ($K = 0$) w biegunach $G$, **koniec** ($K \to \infty$) w zerach $G$ lub w nieskończoności;
- **na osi rzeczywistej:** w punktach, na prawo od których leży nieparzysta liczba biegunów i zer;
- **asymptoty:** $n - m$ gałęzi idzie do nieskończoności pod kątami $\dfrac{(2k+1)180°}{n - m}$, z punktu $\sigma_a = \dfrac{\sum p_i - \sum z_i}{n - m}$;
- **warunek kąta:** $\arg G(s) = 180°$ (punkt należy do linii), **warunek modułu:** $K = 1/|G(s)|$ (jakie wzmocnienie daje biegun w tym punkcie);
- przecięcie z osią urojoną — z kryterium Routha.

**Kompensatory:**
- **Wyprzedzający (lead)** $\dfrac{s + z}{s + p}$, $z < p$ — przesuwa linie w lewo, szybsza odpowiedź, większy zapas fazy (działanie podobne do PD).
- **Opóźniający (lag)** $\dfrac{s + z}{s + p}$, $z > p$, oba blisko zera — zwiększa wzmocnienie statyczne (mniejszy uchyb) prawie bez zmiany dynamiki (działanie podobne do PI).

## Przykład rozwiązany

$G(s) = \dfrac{1}{s(s + 2)}$, regulator P o wzmocnieniu $K$.

1. Bieguny w 0 i −2; odcinek osi rzeczywistej między nimi należy do linii.
2. Dwie asymptoty pod ±90° z punktu $\sigma_a = -1$.
3. Równanie charakterystyczne $s^2 + 2s + K = 0$: dla $K < 1$ dwa bieguny rzeczywiste, dla $K = 1$ podwójny w −1, dla $K > 1$ zespolone $-1 \pm j\sqrt{K - 1}$.
4. $\omega_n = \sqrt K$, $\zeta = 1/\sqrt K$. Dla $\zeta = 0\text{,}707$: **$K = 2$**, bieguny $-1 \pm j$.
5. Czas ustalania $4/1 = 4$ s niezależnie od $K$ — regulator P nie przyspieszy tego układu; potrzebny kompensator wyprzedzający (zero przesuwa linie w lewo).

## Typowe pułapki

- **Linie dla dodatniego sprzężenia** (lub ujemnego $K$) rysowane regułami dla ujemnego — inne odcinki osi i kąty.
- **Wzmocnienie przeniesione na złą stronę** — reguły dotyczą postaci $1 + KG(s)$ z $G$ w postaci z jednostkowymi współczynnikami przy najwyższych potęgach.
- **Zapomniane zera układu zamkniętego** — linie pokazują bieguny, a zera regulatora też wpływają na przeregulowanie.
- **Opóźnienie** — nieskończenie wiele biegunów; linie dla aproksymacji Padégo są tylko przybliżeniem.

## Ćwiczenie komputerowe

Linie pierwiastkowe liczone numerycznie (pierwiastki $D + KN$ dla siatki $K$):

```python
import numpy as np
import matplotlib.pyplot as plt

def rlocus(num, den, Ks):
    return np.array([np.roots(np.polyadd(den, K*np.asarray(num, float))) for K in Ks])

Ks = np.concatenate([np.linspace(0, 2, 400), np.logspace(np.log10(2), 3, 400)])
cases = {'1/(s(s+2))': ([1], [1, 2, 0]),
         '(s+3)/(s(s+2)(s+10)) – z kompensatorem lead': ([1, 3], np.poly([0, -2, -10])),
         '1/(s+1)^3': ([1], np.poly([-1, -1, -1]))}
for name, (n, d) in cases.items():
    r = rlocus(n, d, Ks)
    plt.figure(); plt.plot(r.real, r.imag, 'b.', ms=1)
    plt.plot(np.roots(d).real, np.roots(d).imag, 'kx', ms=10)
    if len(n) > 1: plt.plot(np.roots(n).real, np.roots(n).imag, 'ko', mfc='none', ms=10)
    plt.axvline(0, color='k', lw=0.5); plt.grid(); plt.title(name)
print('K=2 dla 1/(s(s+2)):', np.roots([1, 2, 2]))
plt.show()
```

## Zadania

1. Narysuj odręcznie linie dla $G = \dfrac{1}{s(s+2)}$ i wyznacz $K$ dla $\zeta = 0\text{,}5$.
2. Dla $G = \dfrac{1}{(s+1)^3}$ wyznacz asymptoty i punkt przecięcia z osią urojoną.
3. Gdzie zaczynają i kończą się linie dla $G = \dfrac{s + 3}{s(s+2)(s+10)}$? Ile gałęzi idzie do nieskończoności i pod jakimi kątami?
4. Dlaczego dodanie zera w $-3$ (kompensator) poprawia szybkość układu $\dfrac{1}{s(s+2)}$?
5. Do czego służy kompensator opóźniający, skoro „opóźnia”?

<details>
<summary>Odpowiedzi</summary>

1. $\zeta = 1/\sqrt K = 0\text{,}5$ → $K = 4$, bieguny $-1 \pm j1\text{,}73$
2. Trzy asymptoty pod 60°, 180°, 300° z $\sigma_a = -1$; przecięcie osi urojonej przy $K = 8$, $\omega = \sqrt 3$
3. Start w 0, −2, −10; jedna gałąź kończy w −3, dwie idą do nieskończoności pod ±90° z $\sigma_a = (0 - 2 - 10 + 3)/2 = -4\text{,}5$
4. Asymptoty przesuwają się z −1 do −4,5 (przy biegunie −10 kompensatora) — bieguny zespolone mogą mieć większą część rzeczywistą, czyli krótszy czas ustalania
5. Zwiększa wzmocnienie dla niskich częstotliwości (mniejszy uchyb ustalony), praktycznie nie zmieniając położenia biegunów dominujących; nazwa pochodzi od ujemnej fazy, którą wnosi w wąskim zakresie niskich częstotliwości
</details>

## Źródła

- [Feedback Systems — Åström, Murray](https://www.cds.caltech.edu/~murray/amwiki/Second_Edition.html) — linie pierwiastkowe (rozdział 12)
- [MIT RES.6-007 Signals and Systems](https://ocw.mit.edu/courses/res-6-007-signals-and-systems-spring-2011/) — wykład o linii pierwiastkowej
- [Brian Douglas — Control Systems Lectures](https://www.youtube.com/results?search_query=Brian+Douglas+Control+System+Lectures) — seria o root locus
