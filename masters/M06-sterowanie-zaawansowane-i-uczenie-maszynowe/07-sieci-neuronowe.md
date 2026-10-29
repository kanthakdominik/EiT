# M06.07 — Sieci neuronowe od zera: propagacja wsteczna i klasyfikacja sygnałów

## Po co to jest

Sieci neuronowe rozpoznają mowę, obrazy i sygnały radiowe, kompensują nieliniowości wzmacniaczy mocy, dekodują kanały, a coraz częściej działają bezpośrednio na mikrokontrolerach i w FPGA. Biblioteki (PyTorch, TensorFlow, JAX) ukrywają mechanikę — tymczasem kto choć raz zaimplementował propagację wsteczną i optymalizator, ten rozumie, dlaczego uczenie się rozbiega, co robi inicjalizacja, jak sprawdzić gradient i ile obliczeń kosztuje wnioskowanie na docelowym sprzęcie. Przykład: klasyfikacja modulacji — klasyczne zadanie radia kognitywnego i monitoringu widma.

## Teoria w pigułce

### Perceptron wielowarstwowy (MLP)

Warstwa: $a^{(l)} = \phi\left(a^{(l-1)}W^{(l)} + b^{(l)}\right)$, aktywacje: ReLU $\max(0, z)$ w warstwach ukrytych, softmax $p_k = e^{z_k}/\sum_j e^{z_j}$ na wyjściu klasyfikatora. Twierdzenie o uniwersalnej aproksymacji: jedna warstwa ukryta wystarczy do aproksymacji dowolnej funkcji ciągłej — ale głębsze sieci robią to oszczędniej.

### Propagacja wsteczna

Reguła łańcuchowa od straty do wag: dla softmaxu z entropią krzyżową $\partial\ell/\partial z = p - \mathbf 1_y$; dalej $\delta^{(l-1)} = \left(\delta^{(l)}W^{(l)T}\right)\odot\phi'(z^{(l-1)})$, gradienty $\partial\ell/\partial W^{(l)} = a^{(l-1)T}\delta^{(l)}$. Koszt — ok. 2 × koszt propagacji w przód. **Test gradientu** różnicami skończonymi wyłapuje niemal wszystkie błędy implementacji.

### Uczenie

- **SGD z mini-paczkami** (32–256 próbek), **Adam** (adaptacyjny krok z momentami pierwszego i drugiego rzędu, korekcja obciążenia) — domyślny wybór.
- **Inicjalizacja** He ($\sigma^2 = 2/n_{in}$ dla ReLU), Glorot dla tanh — utrzymuje wariancję sygnałów między warstwami.
- **Regularyzacja:** L2 (weight decay), dropout, wczesne zatrzymanie na zbiorze walidacyjnym, augmentacja danych (dla sygnałów: różne SNR, przesunięcia częstotliwości, fazy, opóźnienia).
- **Architektury dla sygnałów:** sieci splotowe 1D na próbkach I/Q (lokalne wzorce, niezmienniczość przesunięcia), rekurencyjne/LSTM i transformery dla zależności długoterminowych, autoenkodery do wykrywania anomalii i „uczenia łącza od końca do końca”.

### Klasyfikacja modulacji

Podejścia: cechy eksperckie (kumulanty wyższych rzędów, statystyki amplitudy i fazy) + prosty klasyfikator lub sieć ucząca się wprost z próbek I/Q. Trudność rośnie przy niskim SNR i dla modulacji o podobnych konstelacjach (QPSK/8PSK, 16/64-QAM); realistyczne dane wymagają też nieznanego CFO, fazy i szybkości symboli.

## Przykład rozwiązany

MLP 100–32–4 (3364 parametry) w numpy; wejście — histogram konstelacji 10 × 10 z ramki 256 symboli; klasy BPSK, QPSK, 8PSK, 16-QAM; uczenie na 8000 ramkach o SNR losowym 0–20 dB, Adam, 30 epok.

- Test gradientu: analitycznie $-1\text{,}881551\cdot 10^{-3}$, numerycznie $-1\text{,}881551\cdot 10^{-3}$.
- Strata uczenia po 30 epokach: 0,096.

| SNR | Dokładność | BPSK | QPSK | 8PSK | 16-QAM |
|---|---|---|---|---|---|
| 0 dB | 63,9% | 98% | 48% | 58% | 50% |
| 5 dB | 95,3% | 100% | 100% | 99% | 84% |
| 10 dB | 99,5% | 100% | 100% | 100% | 98% |
| 15–20 dB | 100% | 100% | 100% | 100% | 100% |

Przy 0 dB punkty konstelacji QPSK, 8PSK i 16-QAM zlewają się w jedną chmurę i różnią się głównie rozkładem amplitudy — sieć myli je zgodnie z intuicją. BPSK (punkty na osi rzeczywistej) jest rozpoznawany niemal zawsze.

## Typowe pułapki

- **Brak testu gradientu** — błąd w propagacji wstecznej „uczy” sieć, ale gorzej; trudny do znalezienia później.
- **Za duży krok uczenia** — strata rośnie lub oscyluje; za mały — utknięcie.
- **Dane uczące zbyt idealne** (znana faza, brak CFO) — świetny wynik w symulacji, porażka na prawdziwym sygnale.
- **Softmax liczony bez odjęcia maksimum** — przepełnienie `exp`.
- **Brak porównania z prostym klasyfikatorem** (np. kumulanty + regresja logistyczna, [06](06-uczenie-maszynowe-podstawy.md)) — nie wiadomo, czy sieć jest potrzebna.

## Ćwiczenie komputerowe

MLP z propagacją wsteczną, testem gradientu i optymalizatorem Adam — klasyfikacja modulacji:

```python
import numpy as np

rng = np.random.default_rng(7)
# Klasyfikacja modulacji siecią MLP napisaną w numpy (propagacja wsteczna od zera)
const = {
    "BPSK": np.array([1, -1], complex),
    "QPSK": np.exp(1j * np.pi / 4 * np.array([1, 3, 5, 7])),
    "8PSK": np.exp(1j * np.pi / 4 * np.arange(8)),
    "16QAM": np.array([a + 1j * b for a in (-3, -1, 1, 3) for b in (-3, -1, 1, 3)]) / np.sqrt(10),
}
klasy = list(const)

def ramka(c, snr_db, n=256):
    s = rng.choice(const[c], n)
    return s + np.sqrt(10**(-snr_db / 10) / 2) * (rng.standard_normal(n) + 1j * rng.standard_normal(n))

def cechy(x, nb=10):                       # histogram 2D konstelacji 10 x 10 -> 100 wejść
    H, *_ = np.histogram2d(x.real, x.imag, bins=nb, range=[[-1.6, 1.6], [-1.6, 1.6]])
    return H.ravel() / len(x) * 10

def zbior(n, snr_lo=0, snr_hi=20):
    X, Y = [], []
    for _ in range(n):
        k = rng.integers(4)
        X.append(cechy(ramka(klasy[k], rng.uniform(snr_lo, snr_hi)))); Y.append(k)
    return np.array(X), np.array(Y)

class MLP:
    def __init__(self, sizes):
        self.W = [rng.normal(0, np.sqrt(2 / a), (a, b)) for a, b in zip(sizes[:-1], sizes[1:])]  # inicjalizacja He
        self.b = [np.zeros(b) for b in sizes[1:]]
    def forward(self, X):
        self.a = [X]
        for i, (W, b) in enumerate(zip(self.W, self.b)):
            z = self.a[-1] @ W + b
            self.a.append(np.maximum(z, 0) if i < len(self.W) - 1 else z)   # ReLU w warstwach ukrytych
        z = self.a[-1] - self.a[-1].max(1, keepdims=True)
        self.p = np.exp(z) / np.exp(z).sum(1, keepdims=True)             # softmax
        return self.p
    def loss(self, X, Y):
        return -np.mean(np.log(self.forward(X)[np.arange(len(Y)), Y] + 1e-12))
    def backward(self, Y):
        d = self.p.copy(); d[np.arange(len(Y)), Y] -= 1; d /= len(Y)        # gradient entropii krzyżowej
        gW, gb = [], []
        for i in reversed(range(len(self.W))):
            gW.insert(0, self.a[i].T @ d); gb.insert(0, d.sum(0))
            if i > 0:
                d = (d @ self.W[i].T) * (self.a[i] > 0)
        return gW, gb

net = MLP([100, 32, 4])
# Sprawdzenie gradientu metodą różnic skończonych (zawsze przed uczeniem!)
Xg, Yg = zbior(20)
net.forward(Xg); gW, _ = net.backward(Yg)
i, j, eps = 33, 5, 1e-6                        # wejście 33: pole histogramu w pobliżu punktu konstelacji
net.W[0][i, j] += eps; Lp = net.loss(Xg, Yg); net.W[0][i, j] -= 2 * eps; Lm = net.loss(Xg, Yg); net.W[0][i, j] += eps
print(f"test gradientu: analityczny {gW[0][i, j]:.6e}, numeryczny {(Lp - Lm) / (2 * eps):.6e}")

# Uczenie: mini-paczki, optymalizator Adam
X, Y = zbior(8000)
m = [np.zeros_like(p) for p in net.W + net.b]; v = [np.zeros_like(p) for p in net.W + net.b]
lr, b1, b2, t = 2e-3, 0.9, 0.999, 0
for epoka in range(30):
    perm = rng.permutation(len(Y))
    for k in range(0, len(Y), 64):
        idx = perm[k:k + 64]
        net.forward(X[idx]); gW, gb = net.backward(Y[idx]); t += 1
        for n, (p, g) in enumerate(zip(net.W + net.b, gW + gb)):
            m[n] = b1 * m[n] + (1 - b1) * g; v[n] = b2 * v[n] + (1 - b2) * g**2
            p -= lr * (m[n] / (1 - b1**t)) / (np.sqrt(v[n] / (1 - b2**t)) + 1e-8)
print(f"strata na zbiorze uczącym po 30 epokach: {net.loss(X, Y):.3f}")
for snr in (0, 5, 10, 15, 20):
    Xt, Yt = zbior(2000, snr, snr)
    pred = net.forward(Xt).argmax(1)
    pom = [np.mean(pred[Yt == k] == k) for k in range(4)]
    print(f"SNR {snr:2d} dB: dokładność {100 * np.mean(pred == Yt):5.1f} % "
          f"({', '.join(f'{c} {100 * p:.0f}%' for c, p in zip(klasy, pom))})")
```

Rozszerzenia: dodaj losową fazę nośnej do danych — dokładność spadnie; przywróć ją cechami niezmienniczymi względem obrotu (histogram amplitudy i fazy po podniesieniu do 4. potęgi lub kumulanty $C_{40}$, $C_{42}$); zastąp histogram surowymi próbkami I/Q i siecią splotową 1D w PyTorch; porównaj z regresją logistyczną na kumulantach.

## Zadania

1. Ile mnożeń wymaga jedno wnioskowanie sieci 100–32–4? Ile pamięci zajmują wagi w float32?
2. Wyprowadź $\partial\ell/\partial z_k = p_k - \mathbf 1[k = y]$ dla softmaxu z entropią krzyżową.
3. Dlaczego inicjalizacja wszystkich wag zerami nie działa?
4. Po co korekcja obciążenia momentów w Adamie ($m/(1 - \beta_1^t)$)?
5. Dlaczego dokładność dla 16-QAM przy 5 dB jest wyraźnie niższa niż dla pozostałych modulacji?

<details>
<summary>Odpowiedzi</summary>

1. $100\cdot 32 + 32\cdot 4 = 3328$ mnożeń (plus dodawania i 36 biasów); $(3328 + 36)\cdot 4\ \text{B} \approx 13$ kB
2. $\ell = -\ln p_y = -z_y + \ln\sum_je^{z_j}$ → $\partial\ell/\partial z_k = -\mathbf 1[k = y] + e^{z_k}/\sum_je^{z_j} = p_k - \mathbf 1[k = y]$
3. Wszystkie neurony warstwy liczą to samo i dostają ten sam gradient — symetria nigdy nie zostaje złamana (a przy ReLU i zerowych wagach gradienty są zerowe)
4. Momenty startują od zera, więc w pierwszych krokach są zaniżone (średnia wykładnicza z niewielu wartości); korekcja usuwa to obciążenie i daje sensowny krok od początku
5. Najmniejsza odległość między punktami 16-QAM (przy tej samej mocy średniej) jest najmniejsza — przy 5 dB punkty wewnętrzne i zewnętrzne zlewają się, a histogram upodabnia się do chmury PSK
</details>

## Źródła

- [I. Goodfellow, Y. Bengio, A. Courville — Deep Learning (darmowa wersja online)](https://www.deeplearningbook.org) — propagacja wsteczna, optymalizacja, regularyzacja
- [Dive into Deep Learning](https://d2l.ai) — implementacje od zera i w bibliotekach
- [MIT 6.036 Introduction to Machine Learning (2020)](https://ocw.mit.edu/courses/6-036-introduction-to-machine-learning-fall-2020/) — sieci neuronowe, uczenie gradientowe
- [PySDR: A Guide to SDR and DSP using Python](https://pysdr.org) — sygnały I/Q i modulacje do generowania danych
