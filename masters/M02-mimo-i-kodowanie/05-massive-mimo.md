# M02.05 — Massive MIMO i prekodowanie wielu użytkowników

## Po co to jest

Stacja bazowa 5G z 32–64 (w paśmie milimetrowym — setkami) anten obsługuje jednocześnie wielu użytkowników w tym samym paśmie, kierując do każdego osobną wiązkę. Gdy anten jest znacznie więcej niż użytkowników, dzieje się coś zaskakującego: kanały użytkowników stają się prawie ortogonalne, a zaniki „uśredniają się” (utwardzanie kanału) — proste prekodowanie liniowe zbliża się do optimum. To podstawa wzrostu efektywności widmowej sieci 5G.

## Teoria w pigułce

### MU-MIMO w dół (downlink)

$M$ anten stacji, $K$ jednoantenowych użytkowników, kanał $\mathbf H \in \mathbb C^{K\times M}$. Sygnał: $\mathbf x = \mathbf W\mathbf s$, użytkownik $k$ odbiera $y_k = \mathbf h_k^T\mathbf W\mathbf s + w_k$.

| Prekoder | $\mathbf W$ | Cechy |
|---|---|---|
| **MRT** (dopasowany) | $\mathbf H^H$ | Maksymalizuje sygnał użytkownika, ignoruje interferencję; najlepszy przy niskim SNR i $M \gg K$ |
| **ZF** | $\mathbf H^H(\mathbf H\mathbf H^H)^{-1}$ | Zeruje interferencję między użytkownikami; wzmacnia moc przy złym uwarunkowaniu |
| **RZF / MMSE** | $\mathbf H^H(\mathbf H\mathbf H^H + \alpha\mathbf I)^{-1}$ | Kompromis, $\alpha \approx K/\mathrm{SNR}$ |
| Nieliniowe (DPC, THP) | — | Optymalne, złożone, rzadkie w praktyce |

### Efekty dużej liczby anten

- **Przybliżona ortogonalność:** $\dfrac{1}{M}\mathbf h_i^H\mathbf h_j \to 0$ dla $i \ne j$ (niezależne kanały).
- **Utwardzanie kanału:** $\dfrac{1}{M}\lVert\mathbf h_k\rVert^2 \to 1$ — wzmocnienie po kształtowaniu wiązki jest prawie stałe; odchylenie standardowe maleje jak $1/\sqrt M$.
- Zysk szyku $\propto M$ → można zmniejszyć moc nadawania.

### Ograniczenia

- **Wiedza o kanale:** w TDD stacja estymuje kanał z pilotów od użytkowników (wzajemność kanału — wymaga kalibracji torów); w FDD potrzeba informacji zwrotnej, której koszt rośnie z $M$.
- **Zanieczyszczenie pilotów** — użytkownicy w sąsiednich komórkach z tymi samymi pilotami: estymata kanału zawiera kanał „obcego”, interferencja nie znika przy $M \to \infty$.
- **Kanały skorelowane** (mało rozproszeń, linia widzenia) — mniejsza ortogonalność; użytkownicy w podobnych kierunkach są trudni do rozdzielenia (dobór użytkowników do jednoczesnej obsługi).
- Koszt i pobór mocy wielu torów w.cz. — architektury hybrydowe (temat 04), przetworniki o małej rozdzielczości.

## Przykład rozwiązany

**8 użytkowników, SNR 0 dB na użytkownika** (symulacja, kanał i.i.d., idealna wiedza o kanale):

| Anteny $M$ | Suma przepływności MRT | ZF | std$(\lVert\mathbf h\rVert^2/M)$ |
|---|---|---|---|
| 8 | 8,2 | 5,3 b/s/Hz | 0,36 |
| 16 | 13,0 | 25,5 | 0,27 |
| 64 | 26,0 | 46,7 | 0,12 |
| 256 | 41,0 | 63,7 | 0,06 |

Przy $M = K = 8$ ZF jest gorszy od MRT — macierz $\mathbf H\mathbf H^H$ jest źle uwarunkowana i zerowanie interferencji kosztuje dużo mocy. Przy $M \geq 2K$ ZF wyraźnie wygrywa. Utwardzanie kanału widać w spadku rozrzutu jak $1/\sqrt M$ (0,36 → 0,06 przy 32-krotnym wzroście $M$, czyli ok. $1/\sqrt{32} \approx 0\text{,}18$ razy).

## Typowe pułapki

- **Wnioski z modelu i.i.d.** dla rzeczywistego kanału z linią widzenia — przeszacowanie zysków.
- **Pominięcie kosztu pilotów** — w kanale szybkozmiennym (duża prędkość) czas koherencji ogranicza liczbę użytkowników, dla których można zmierzyć kanał.
- **ZF przy $M \approx K$** — wzmocnienie mocy i utrata zysku.
- **Normalizacja mocy prekodera** różna w porównaniach (całkowita vs na antenę) — wyniki nieporównywalne.
- **Brak kalibracji wzajemności** w TDD — kanał „w górę” ≠ „w dół” przez różnice torów nadawczych i odbiorczych.

## Ćwiczenie komputerowe

Suma przepływności MRT i ZF w funkcji liczby anten oraz utwardzanie kanału:

```python
import numpy as np

rng = np.random.default_rng(4)
K, snr_db, trials = 8, 0, 300                            # 8 użytkowników jednoantenowych, SNR na użytkownika 0 dB
snr = 10**(snr_db/10)
for M in (8, 16, 64, 256):                                # liczba anten stacji bazowej
    rates = {"MRT": [], "ZF": []}
    hard = []
    for _ in range(trials):
        H = (rng.normal(size=(K, M)) + 1j*rng.normal(size=(K, M)))/np.sqrt(2)   # kanał w dół: K × M
        for name in rates:
            W = H.conj().T if name == "MRT" else H.conj().T @ np.linalg.inv(H @ H.conj().T)
            W = W/np.linalg.norm(W)*np.sqrt(K)                                 # moc całkowita K (1 na użytkownika)
            G = np.abs(H @ W)**2
            sig = np.diag(G); interf = G.sum(axis=1) - sig
            rates[name].append(np.sum(np.log2(1 + snr*sig/(snr*interf + 1))))
        hard.append(np.linalg.norm(H[0])**2/M)
    print(f"M = {M:3d}: suma przepływności MRT {np.mean(rates['MRT']):5.1f}, ZF {np.mean(rates['ZF']):5.1f} b/s/Hz; "
          f"utwardzanie kanału: std(‖h‖²/M) = {np.std(hard):.3f}")
```

Rozszerzenie: dodaj błąd estymacji kanału (kanał estymowany = prawdziwy + szum o wariancji 0,1) i zanieczyszczenie pilotów (do estymaty dodany kanał użytkownika z sąsiedniej komórki) — sprawdź, który efekt zostaje przy dużym $M$.

## Zadania

1. Ile wynosi zysk szyku dla $M = 64$ i jak można go wykorzystać?
2. Dlaczego TDD jest preferowany w Massive MIMO?
3. Wyjaśnij, dlaczego przy $M \to \infty$ interferencja z zanieczyszczenia pilotów nie znika.
4. Dlaczego ZF przy $M = K$ daje mniejszą przepływność niż MRT w przykładzie?
5. Jak zmienia się wariancja $\lVert\mathbf h\rVert^2/M$ dla kanału i.i.d. $\mathcal{CN}(0, 1)$?

<details>
<summary>Odpowiedzi</summary>

1. 18 dB — można zmniejszyć moc nadawania (efektywność energetyczna) albo obsłużyć dalszych/słabszych użytkowników, albo zwiększyć przepływność
2. Kanał w górę i w dół jest ten sam (wzajemność) — wystarczą piloty od $K$ użytkowników (narzut ∝ $K$), zamiast pilotów z $M$ anten i informacji zwrotnej o kanale (narzut ∝ $M$)
3. Estymata kanału użytkownika jest skorelowana z kanałem użytkownika z innej komórki (te same piloty) — wiązka skierowana na „swojego” jest częściowo skierowana na „obcego”, a ta składowa rośnie z $M$ tak samo jak sygnał użytkowany; stosunek sygnału do interferencji dąży do skończonej granicy
4. $\mathbf H\mathbf H^H$ dla macierzy kwadratowej losowej ma bardzo małe wartości własne; odwracanie wymaga ogromnej mocy na kierunkach słabych, a przy ograniczonej mocy całkowitej sygnał użyteczny jest mały
5. $\lVert\mathbf h\rVert^2$ ma rozkład gamma o średniej $M$ i wariancji $M$ → $\mathrm{var}(\lVert\mathbf h\rVert^2/M) = 1/M$, odchylenie $1/\sqrt M$
</details>

## Źródła

- [E. Björnson, J. Hoydis, L. Sanguinetti — Massive MIMO Networks](https://nowpublishers.com/article/Details/SIG-093)
- [D. Tse, P. Viswanath — Fundamentals of Wireless Communication](https://web.stanford.edu/~dntse/wireless_book.html) — rozdział 10 (MIMO wielu użytkowników)
- [NVIDIA Sionna (GitHub)](https://github.com/NVlabs/sionna) — symulacje MU-MIMO
