# 11.01 — Równania Maxwella

## Po co to jest

Cztery równania Maxwella opisują całą elektrotechnikę: od kondensatora i transformatora po antenę i światłowód. Teoria obwodów to ich przybliżenie dla układów małych w porównaniu z długością fali. Gdy to przybliżenie przestaje działać — na wysokich częstotliwościach, na długich ścieżkach, przy szybkich zboczach — trzeba wrócić do pól.

## Teoria w pigułce

### Równania

| Postać różniczkowa | Postać całkowa | Nazwa i sens |
|---|---|---|
| $\nabla\cdot\mathbf D = \rho$ | $\oint_S \mathbf D\cdot d\mathbf S = Q$ | Prawo Gaussa: ładunki są źródłami pola elektrycznego |
| $\nabla\cdot\mathbf B = 0$ | $\oint_S \mathbf B\cdot d\mathbf S = 0$ | Brak ładunków magnetycznych; linie B są zamknięte |
| $\nabla\times\mathbf E = -\dfrac{\partial\mathbf B}{\partial t}$ | $\oint_C \mathbf E\cdot d\mathbf l = -\dfrac{d\Phi}{dt}$ | Prawo Faradaya: zmienne pole magnetyczne wytwarza wirowe pole elektryczne |
| $\nabla\times\mathbf H = \mathbf J + \dfrac{\partial\mathbf D}{\partial t}$ | $\oint_C \mathbf H\cdot d\mathbf l = I + \dfrac{d\Psi_D}{dt}$ | Prawo Ampère'a–Maxwella: prąd i zmienne pole elektryczne wytwarzają pole magnetyczne |

Związki materiałowe (ośrodek liniowy, izotropowy): $\mathbf D = \varepsilon\mathbf E$, $\mathbf B = \mu\mathbf H$, $\mathbf J = \sigma\mathbf E$. Operatory dywergencji i rotacji — [00.08](../00-matematyka/08-rachunek-wektorowy.md).

### Prąd przesunięcia

Człon $\partial\mathbf D/\partial t$ dodany przez Maxwella. Bez niego prawo Ampère'a byłoby sprzeczne z zachowaniem ładunku: prąd płynie przez przewód do kondensatora, ale nie przez dielektryk między okładkami. Prąd przesunięcia „zamyka obwód” i — co ważniejsze — umożliwia istnienie fal: zmienne E tworzy B, zmienne B tworzy E, i tak dalej bez przewodów.

**Równanie ciągłości** (wynika z równań): $\nabla\cdot\mathbf J = -\partial\rho/\partial t$ — ładunek nie znika, tylko przepływa.

### Postać zespolona (dla przebiegów sinusoidalnych)

Z $\partial/\partial t \to j\omega$: $\nabla\times\mathbf E = -j\omega\mu\mathbf H$, $\nabla\times\mathbf H = (\sigma + j\omega\varepsilon)\mathbf E$. Stosunek $\sigma/(\omega\varepsilon)$ rozstrzyga, czy ośrodek zachowuje się jak przewodnik ($\gg 1$), czy dielektryk ($\ll 1$).

### Warunki brzegowe

Na granicy dwóch ośrodków:
- składowa styczna $\mathbf E$ ciągła: $E_{t1} = E_{t2}$;
- składowa normalna $\mathbf D$ skacze o gęstość powierzchniową ładunku: $D_{n1} - D_{n2} = \rho_s$;
- składowa normalna $\mathbf B$ ciągła;
- składowa styczna $\mathbf H$ skacze o gęstość powierzchniową prądu.

Na powierzchni idealnego przewodnika: $E_t = 0$ i $B_n = 0$. Dlatego pole E jest prostopadłe do powierzchni metalu, a fala odbija się od niego całkowicie.

### Energia i wektor Poyntinga

$$\mathbf S = \mathbf E\times\mathbf H\ \ [\text{W/m}^2]$$

Gęstość strumienia mocy. Energia w linii czy kablu płynie **w polu wokół przewodów**, a przewody ją prowadzą. Twierdzenie Poyntinga: moc wpływająca przez powierzchnię = przyrost energii pól + straty (ciepło Joule'a). Dla fazorów: średnia moc $\langle\mathbf S\rangle = \tfrac12\text{Re}(\mathbf E\times\mathbf H^*)$.

### Kiedy wystarczy teoria obwodów

Gdy wymiary układu $\ll \lambda$ (umownie poniżej ok. $\lambda/10$, a dla szybkich zboczy — gdy czas propagacji jest dużo krótszy od czasu narastania, [11.05](05-stany-nieustalone-na-liniach.md)). Przy 50 Hz $\lambda = 6000$ km, przy 1 GHz w laminacie FR-4 — ok. 16 cm.

## Przykład rozwiązany

**Kondensator płaski i prąd przesunięcia.** Okładki o polu $A = 1$ cm², odstęp 1 mm, próżnia, napięcie $u(t) = 10\sin(2\pi\cdot 1\ \text{MHz}\cdot t)$.

1. $C = \varepsilon_0A/d = 8\text{,}85\cdot 10^{-12}\cdot 10^{-4}/10^{-3} \approx 0\text{,}885$ pF.
2. Prąd w przewodach: amplituda $\omega CU = 2\pi\cdot 10^6\cdot 0\text{,}885\cdot 10^{-12}\cdot 10 \approx 55\text{,}6$ µA.
3. Między okładkami: $E = u/d$, $D = \varepsilon_0E$, gęstość prądu przesunięcia $\partial D/\partial t$, całkowity prąd przesunięcia $A\,\varepsilon_0\,\dot u/d = C\dot u$ — **ten sam co w przewodach**. Prawo Ampère'a–Maxwella działa dla dowolnej powierzchni rozpiętej na tym samym konturze.

## Typowe pułapki

- **Mylenie $\mathbf E$ z $\mathbf D$ i $\mathbf B$ z $\mathbf H$** — w próżni różnią się tylko stałą, w materiałach to inne wielkości.
- **„Prąd płynie w przewodzie, więc energia też”** — energia płynie w polu (wektor Poyntinga).
- **Stosowanie praw Kirchhoffa do układów porównywalnych z długością fali** — napięcie między punktami zależy wtedy od drogi całkowania.
- **Zapominanie o znaku minus w prawie Faradaya** (reguła Lenza).

## Ćwiczenie komputerowe

Sprawdź, czy pole $\mathbf E = \hat x E_0\cos(\omega t - kz)$, $\mathbf H = \hat y (E_0/\eta)\cos(\omega t - kz)$ spełnia równania Maxwella w próżni — numerycznie, metodą różnic skończonych:

```python
import numpy as np
mu0, eps0 = 4e-7*np.pi, 8.854e-12
c, eta = 1/np.sqrt(mu0*eps0), np.sqrt(mu0/eps0)
f = 100e6; w = 2*np.pi*f; k = w/c; E0 = 1.0
z, t, h = 0.37, 1.3e-9, 1e-6                 # punkt, chwila, krok różnicowy

Ex = lambda z, t: E0*np.cos(w*t - k*z)
Hy = lambda z, t: E0/eta*np.cos(w*t - k*z)

# rot E (składowa y) = dEx/dz ; prawo Faradaya: dEx/dz = -mu0 dHy/dt
lhs = (Ex(z + h, t) - Ex(z - h, t))/(2*h)
rhs = -mu0*(Hy(z, t + h/c) - Hy(z, t - h/c))/(2*h/c)
print(f"Faraday: {lhs:.6e} vs {rhs:.6e}")
# rot H (składowa x) = -dHy/dz ; Ampère-Maxwell: -dHy/dz = eps0 dEx/dt
lhs = -(Hy(z + h, t) - Hy(z - h, t))/(2*h)
rhs = eps0*(Ex(z, t + h/c) - Ex(z, t - h/c))/(2*h/c)
print(f"Ampère–Maxwell: {lhs:.6e} vs {rhs:.6e}")
print(f"c = {c:.4e} m/s, eta0 = {eta:.2f} Ohm, lambda = {c/f:.3f} m")
```

## Zadania

1. Zapisz równania Maxwella w postaci zespolonej dla ośrodka o przewodności $\sigma$.
2. Policz $\sigma/(\omega\varepsilon)$ dla wody morskiej ($\sigma = 4$ S/m, $\varepsilon_r = 81$) przy 1 kHz i 10 GHz. Jak się zachowuje?
3. Wyprowadź równanie ciągłości z prawa Ampère'a–Maxwella i prawa Gaussa.
4. Dla kondensatora z przykładu policz amplitudę gęstości prądu przesunięcia.
5. Do jakiej częstotliwości ścieżkę o długości 10 cm na FR-4 ($\varepsilon_{eff} \approx 3\text{,}3$) można traktować jako „krótką” według kryterium $\lambda/10$?

<details>
<summary>Odpowiedzi</summary>

1. $\nabla\cdot\varepsilon\mathbf E = \rho$, $\nabla\cdot\mu\mathbf H = 0$, $\nabla\times\mathbf E = -j\omega\mu\mathbf H$, $\nabla\times\mathbf H = (\sigma + j\omega\varepsilon)\mathbf E$
2. 1 kHz: $4/(2\pi\cdot 10^3\cdot 81\cdot 8\text{,}85\cdot 10^{-12}) \approx 8\text{,}9\cdot 10^5$ — przewodnik; 10 GHz: ≈ 0,089 — raczej stratny dielektryk. Dlatego z okrętami podwodnymi komunikuje się na bardzo niskich częstotliwościach
3. Dywergencja rotacji jest zerowa: $0 = \nabla\cdot\mathbf J + \partial(\nabla\cdot\mathbf D)/\partial t = \nabla\cdot\mathbf J + \partial\rho/\partial t$
4. $\varepsilon_0\omega U/d = 8\text{,}85\cdot 10^{-12}\cdot 2\pi\cdot 10^6\cdot 10^4 \approx 0\text{,}556$ A/m² (razy 1 cm² daje 55,6 µA)
5. $\lambda = c/(f\sqrt{3\text{,}3}) \geq 1$ m → $f \leq 3\cdot 10^8/(1\cdot 1\text{,}82) \approx 165$ MHz
</details>

## Źródła

- [Electromagnetics, Vol. 1 — Ellingson](https://doi.org/10.21061/electromagnetics-vol-1) — rozdziały o elektrostatyce, magnetostatyce i równaniach Maxwella
- [MIT 8.02 Physics II](https://ocw.mit.edu/courses/8-02-physics-ii-electricity-and-magnetism-spring-2007/) — prąd przesunięcia, wektor Poyntinga, wizualizacje
- [MIT 6.013 Electromagnetics and Applications](https://ocw.mit.edu/courses/6-013-electromagnetics-and-applications-fall-2005/) — postać inżynierska, warunki brzegowe
