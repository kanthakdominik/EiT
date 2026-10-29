# M01.06 — Filtry adaptacyjne: LMS, NLMS, RLS

## Po co to jest

Gdy statystyki sygnałów są nieznane albo się zmieniają, filtr musi się ich uczyć na bieżąco. Filtry adaptacyjne usuwają echo w telefonii i wideokonferencjach, tłumią hałas w słuchawkach ANC, wyrównują kanał w modemach i łączach szeregowych (equalizery w SerDes), identyfikują systemy i usuwają zakłócenia 50 Hz z sygnałów biomedycznych. Dwa podstawowe algorytmy — LMS (prosty, tani) i RLS (szybki, droższy) — wyznaczają kompromis szybkość–koszt–stabilność obecny w każdym zastosowaniu.

## Teoria w pigułce

### LMS (Least Mean Squares)

Stochastyczny spadek gradientowy po powierzchni MSE z jedną próbką zamiast wartości oczekiwanej:

$$e[n] = d[n] - \mathbf w^T[n]\mathbf u[n], \qquad \mathbf w[n+1] = \mathbf w[n] + \mu\,e[n]\,\mathbf u[n]$$

- Koszt: $2L$ mnożeń na próbkę.
- **Stabilność (w średniej kwadratowej):** w przybliżeniu $0 < \mu < \dfrac{2}{L\,\sigma_u^2}$ (ślad macierzy autokorelacji); w praktyce $\mu$ wielokrotnie mniejsze.
- **Kompromis:** duże $\mu$ — szybka zbieżność, duży błąd nadmiarowy (szum współczynników, *misadjustment* $\approx \mu L\sigma_u^2/2$); małe $\mu$ — dokładniej, ale wolno.
- Szybkość zbieżności zależy od **rozrzutu wartości własnych** $\mathbf R_u$ — sygnał wejściowy silnie kolorowy (mowa) zbiega wolno w niektórych kierunkach.

### NLMS

Krok normowany mocą wejścia: $\mathbf w \mathrel{+}= \dfrac{\tilde\mu}{\delta + \mathbf u^T\mathbf u}e\,\mathbf u$, $0 < \tilde\mu < 2$ — niezależność od poziomu sygnału (mowa o zmiennej głośności), standard w kasowaniu echa.

### RLS (Recursive Least Squares)

Minimalizuje ważoną wykładniczo sumę kwadratów błędów $\sum_k\lambda^{n-k}e^2[k]$; rekurencyjna aktualizacja odwrotności macierzy autokorelacji $\mathbf P$:

$$\mathbf k = \frac{\mathbf P\mathbf u}{\lambda + \mathbf u^T\mathbf P\mathbf u}, \quad \mathbf w \mathrel{+}= \mathbf k\,e, \quad \mathbf P = \frac{\mathbf P - \mathbf k\mathbf u^T\mathbf P}{\lambda}$$

- Zbieżność w ok. $2L$ próbkach niezależnie od rozrzutu wartości własnych.
- Koszt $O(L^2)$ na próbkę; problemy numeryczne w arytmetyce o skończonej precyzji (utrata symetrii i dodatniej określoności $\mathbf P$) — wersje QR-RLS, lattice.
- **Współczynnik zapominania** $\lambda$: pamięć ok. $1/(1 - \lambda)$ próbek; mniejsze $\lambda$ — szybsze śledzenie zmian, większy szum.

### Struktury zastosowań

| Struktura | Wejście $\mathbf u$ | Sygnał pożądany $d$ | Wynik |
|---|---|---|---|
| **Identyfikacja** | Pobudzenie systemu | Wyjście systemu | $\mathbf w$ = model systemu |
| **Kasowanie echa** | Sygnał z głośnika (daleki rozmówca) | Sygnał mikrofonu | $e$ = mowa lokalna bez echa |
| **Usuwanie zakłóceń** (ANC) | Czujnik odniesienia zakłócenia | Sygnał z zakłóceniem | $e$ = sygnał oczyszczony |
| **Equalizer** | Wyjście kanału | Znane symbole (trening) lub decyzje | $\mathbf w$ ≈ odwrotność kanału |
| **Predykcja** | Przeszłe próbki | Bieżąca próbka | Współczynniki LPC, wybielanie |

## Przykład rozwiązany

**Identyfikacja 8-współczynnikowego systemu** z szumem pomiaru 0,01, wejście białe o wariancji 1:

| Algorytm | Próbki do błędu współczynników −20 dB | Błąd ustalony |
|---|---|---|
| LMS, $\mu = 0\text{,}01$ | ok. 290 | −55 dB |
| LMS, $\mu = 0\text{,}05$ | ok. 64 | −47 dB |
| NLMS, $\tilde\mu = 0\text{,}5$ | ok. 50 | −45 dB |
| RLS, $\lambda = 0\text{,}999$ | ok. 15 | −64 dB |

Granica stabilności LMS: $\mu < 2/(8\cdot 1) = 0\text{,}25$. Widać kompromis LMS: 5-krotnie większy krok — 5 razy szybciej, ale błąd ustalony 8 dB większy. RLS jest najlepszy w obu kryteriach, kosztem $O(L^2)$ operacji — dla echa z odpowiedzią 128 ms przy 16 kHz ($L = 2048$) to ok. 4 mln operacji na próbkę, dlatego tam stosuje się NLMS lub algorytmy w dziedzinie częstotliwości.

## Typowe pułapki

- **Krok LMS dobrany dla jednego poziomu sygnału** — przy głośniejszym sygnale filtr się rozbiega (użyj NLMS).
- **Adaptacja w czasie podwójnej rozmowy** (double talk) w kasowaniu echa — mowa lokalna działa jak silny szum i „psuje” współczynniki; potrzebny detektor podwójnej rozmowy.
- **Wejście nie pobudza wszystkich częstotliwości** (np. sinus) — współczynniki dryfują w kierunkach niepobudzonych; dodaj „przeciek” (leaky LMS).
- **RLS w arytmetyce stałoprzecinkowej** bez stabilizacji — rozbieżność po długim czasie.
- **Zbyt krótki filtr** względem odpowiedzi systemu — resztkowe echo, którego żaden krok nie usunie.

## Ćwiczenie komputerowe

Identyfikacja systemu: LMS, NLMS i RLS — szybkość zbieżności i błąd ustalony:

```python
import numpy as np

rng = np.random.default_rng(5)
L, N, noise = 8, 4000, 0.01
h_true = rng.normal(size=L)*np.exp(-0.4*np.arange(L))        # nieznany system (np. ścieżka echa)
x = rng.normal(size=N)
d = np.convolve(x, h_true)[:N] + rng.normal(0, noise, N)

def lms(mu, normalized=False):
    w = np.zeros(L); err = np.zeros(N)
    for n in range(L, N):
        u = x[n:n-L:-1]
        e = d[n] - w @ u
        step = mu/(1e-6 + u @ u) if normalized else mu
        w += step*e*u
        err[n] = np.sum((w - h_true)**2)
    return err

def rls(lam=0.999, delta=100.0):
    w = np.zeros(L); P = delta*np.eye(L); err = np.zeros(N)
    for n in range(L, N):
        u = x[n:n-L:-1]
        k = P @ u/(lam + u @ P @ u)
        e = d[n] - w @ u
        w += k*e
        P = (P - np.outer(k, u @ P))/lam
        err[n] = np.sum((w - h_true)**2)
    return err

for name, err in (("LMS μ = 0,01", lms(0.01)), ("LMS μ = 0,05", lms(0.05)),
                  ("NLMS μ̃ = 0,5", lms(0.5, True)), ("RLS λ = 0,999", rls())):
    n20 = np.argmax(err[L:] < 1e-2*np.sum(h_true**2)) + L     # błąd współczynników −20 dB
    print(f"{name:14s}: −20 dB po {n20:5d} próbkach, błąd końcowy {10*np.log10(err[-500:].mean()/np.sum(h_true**2)):6.1f} dB")
print(f"granica stabilności LMS (σx² = 1): μ < 2/(L·σx²) = {2/L:.2f}")
```

Rozszerzenie: zamień wejście na szum kolorowy (np. AR(1) z $a = 0\text{,}9$) i porównaj, jak bardzo zwalnia LMS, a jak mało zmienia się RLS.

## Zadania

1. Filtr LMS ma 64 współczynniki, moc wejścia 0,5. Jaka jest przybliżona górna granica $\mu$?
2. RLS z $\lambda = 0\text{,}99$. Ile próbek wynosi efektywna pamięć filtru?
3. Zaprojektuj układ usuwania zakłócenia 50 Hz z EKG filtrem adaptacyjnym z odniesieniem — co jest wejściem, a co sygnałem pożądanym? Ile współczynników wystarczy?
4. Dlaczego zbieżność LMS jest wolna dla sygnału mowy, a RLS — nie?
5. Kasowanie echa w pomieszczeniu: odpowiedź 250 ms, $f_s = 16$ kHz. Ile współczynników i ile mnożeń na sekundę wymaga NLMS?

<details>
<summary>Odpowiedzi</summary>

1. $\mu < 2/(64\cdot 0\text{,}5) = 0\text{,}0625$ (w praktyce ok. 10 razy mniej)
2. $1/(1 - 0\text{,}99) = 100$ próbek
3. Wejście $\mathbf u$: dwa sygnały odniesienia $\cos$ i $\sin$ 50 Hz (np. z sieci przez transformator lub generowane); $d$: EKG z zakłóceniem; wyjście: błąd $e$ = EKG bez 50 Hz. Wystarczą 2 współczynniki (amplituda i faza) — filtr działa jak adaptacyjny filtr wycinający śledzący zmiany amplitudy i fazy
4. Mowa ma silnie kolorowe widmo → duży rozrzut wartości własnych macierzy autokorelacji; LMS zbiega w każdym kierunku własnym z szybkością proporcjonalną do wartości własnej (słabe pasma — bardzo wolno). RLS „wybiela” wejście przez $\mathbf P \approx \mathbf R^{-1}$
5. $L = 0\text{,}25\cdot 16\,000 = 4000$; ok. $2L\cdot f_s = 128$ mln mnożeń/s (plus normowanie) — stąd implementacje blokowe w dziedzinie częstotliwości (FDAF)
</details>

## Źródła

- [MIT 2.160 Identification, Estimation, and Learning](https://ocw.mit.edu/courses/2-160-identification-estimation-and-learning-spring-2006/) — RLS, identyfikacja
- [MIT 6.011 Signals, Systems and Inference](https://ocw.mit.edu/courses/6-011-signals-systems-and-inference-spring-2018/)
- S. Haykin — *Adaptive Filter Theory* (płatna)
