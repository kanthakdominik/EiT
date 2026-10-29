# 14.08 — Teoria ruchu i bezpieczeństwo transmisji

## Po co to jest

Ile łączy, kanałów radiowych czy pojemności serwera potrzeba, żeby użytkownicy rzadko trafiali na „zajęte”, a opóźnienia nie rosły w nieskończoność? Odpowiada na to teoria ruchu — od wzoru Erlanga sprzed stu lat po modele kolejek stosowane dziś do routerów i centrów danych. Drugą częścią tematu jest bezpieczeństwo: każdy system telekomunikacyjny musi chronić poufność, integralność i autentyczność przesyłanych danych.

## Teoria w pigułce

### Ruch telekomunikacyjny

**Natężenie ruchu** $A = \lambda\cdot h$ [Erl] — intensywność zgłoszeń × średni czas obsługi; 1 Erl = jeden kanał zajęty bez przerwy. Godzina największego ruchu (GNR) — podstawa wymiarowania.

**Erlang B** (system ze stratami — zgłoszenie bez wolnego kanału jest odrzucane, np. połączenia telefoniczne, kanały radiowe):

$$B(A, N) = \frac{A^N/N!}{\sum_{k=0}^{N}A^k/k!},\qquad B(A, 0) = 1,\quad B(A, N) = \frac{A\,B(A, N - 1)}{N + A\,B(A, N - 1)}$$

Postać rekurencyjna jest stabilna numerycznie. **Efekt skali:** większe wiązki kanałów są wykorzystywane wydajniej (10 Erl → 18 kanałów przy 1%, 20 Erl → 30 kanałów).

**Erlang C** (system z oczekiwaniem — call center): prawdopodobieństwo, że zgłoszenie musi czekać; wymaga $A < N$.

### Kolejki

Notacja Kendalla A/B/c: rozkład napływu / rozkład obsługi / liczba stanowisk. **M/M/1** (napływ Poissona λ, wykładniczy czas obsługi o intensywności μ, obciążenie $\rho = \lambda/\mu < 1$):

| Wielkość | Wzór |
|---|---|
| Średnia liczba w systemie | $\dfrac{\rho}{1 - \rho}$ |
| Średni czas w systemie | $\dfrac{1}{\mu - \lambda}$ |
| Prawo Little'a (dowolny system) | $N = \lambda T$ |

Kluczowa obserwacja: **opóźnienie rośnie bez ograniczeń, gdy obciążenie zbliża się do 100%** — przy ρ = 0,5 średni czas to 2/μ, przy 0,9 — 10/μ, przy 0,99 — 100/μ. Dlatego łącza projektuje się z zapasem, a ruch czasu rzeczywistego obsługuje priorytetowo ([14.05](05-transport-i-qos.md)). Rzeczywisty ruch internetowy jest „zrywowy” (samopodobny), co pogarsza wyniki względem modelu Poissona.

### Bezpieczeństwo: cele i narzędzia

| Cel | Narzędzie |
|---|---|
| Poufność | Szyfrowanie symetryczne (**AES**, ChaCha20) |
| Integralność | Funkcje skrótu (**SHA-256**, SHA-3), kody MAC (**HMAC**), szyfrowanie uwierzytelnione (**AES-GCM**) |
| Uwierzytelnienie | Podpisy cyfrowe (RSA, **ECDSA**, Ed25519), certyfikaty X.509 i PKI |
| Uzgodnienie klucza | **Diffie–Hellman** (ECDHE) — wspólny klucz przez publiczny kanał |
| Ochrona przed powtórzeniem | Liczniki, znaczniki czasu, jednorazowe wartości (nonce) |

**Szyfrowanie symetryczne** — szybkie, ale problem dystrybucji klucza; **asymetryczne** — wolne, rozwiązuje uzgodnienie klucza i podpisy. W praktyce **hybrydowo**: asymetrycznie uzgadnia się klucz sesji, symetrycznie szyfruje dane.

**Zasada Kerckhoffsa:** bezpieczeństwo ma zależeć tylko od tajności klucza, nie algorytmu. Bezpieczeństwo w bitach: AES-128 → $2^{128}$ prób; RSA-2048 ≈ 112 bitów; ECC 256 bitów ≈ 128 bitów. Komputery kwantowe zagrażają RSA i ECC (algorytm Shora) — standaryzowana jest kryptografia postkwantowa (np. ML-KEM, ML-DSA).

### Bezpieczeństwo w sieciach

- **TLS 1.3** (HTTPS, MQTT/TLS, QUIC): uzgodnienie ECDHE, uwierzytelnienie serwera certyfikatem, szyfrowanie AEAD; zapewnia **poufność przyszłą** (forward secrecy).
- **IPsec, WireGuard** — sieci VPN na poziomie IP.
- **Wi-Fi:** WPA2/WPA3 (AES-CCMP/GCMP, w WPA3 uzgodnienie SAE odporne na ataki słownikowe offline).
- **Sieci komórkowe:** klucz tajny w karcie SIM i u operatora, wzajemne uwierzytelnienie (AKA), szyfrowanie interfejsu radiowego; w 5G szyfrowany identyfikator abonenta (SUCI).
- **IoT:** unikalne klucze/certyfikaty na urządzenie, bezpieczny rozruch (secure boot), podpisane aktualizacje, sprzętowe przechowywanie kluczy (secure element).

## Przykład rozwiązany

**Wymiarowanie:** 200 abonentów, każdy 3 połączenia w GNR po 2 min średnio: $A = 200\cdot 3\cdot 2/60 = 20$ Erl. Dla blokady ≤ 1% potrzeba **30 kanałów** (Erlang B); dla 10 Erl — 18 kanałów, a przy 15 kanałach blokada wynosiłaby ok. 3,7%.

**Kolejka routera:** pakiety 800/s, obsługa 1000/s: ρ = 0,8, średnio 4 pakiety w systemie, średni czas $1/(1000 - 800) = 5$ ms. Wzrost ruchu o 12,5% (do 900/s) podwaja czas do 10 ms.

**Szyfrowanie:** klucz AES-128 przy $10^{12}$ prób/s: średnio $2^{127}/10^{12} \approx 1\text{,}7\cdot 10^{26}$ s — ok. $5\cdot 10^{18}$ lat; atakuje się więc implementacje, klucze i ludzi, nie algorytm.

## Typowe pułapki

- **Wymiarowanie na ruch średni dobowy** zamiast GNR.
- **Łącza planowane na 90–100% obciążenia** — opóźnienia i straty rosną gwałtownie.
- **Własna kryptografia** zamiast sprawdzonych bibliotek i protokołów.
- **Szyfrowanie bez uwierzytelnienia** (np. tryb CTR bez MAC) — możliwa modyfikacja danych.
- **Wspólny klucz wpisany w oprogramowanie wszystkich urządzeń** — wyciek z jednego urządzenia kompromituje całą flotę.
- **Brak weryfikacji certyfikatu** po stronie klienta (np. w urządzeniu IoT) — atak „man-in-the-middle”.

## Ćwiczenie komputerowe

Erlang B, symulacja kolejki M/M/1 i HMAC/szyfrowanie z biblioteki standardowej:

```python
import numpy as np, hmac, hashlib, secrets

def erlang_b(A, N):
    B = 1.0
    for k in range(1, N + 1): B = A*B/(k + A*B)
    return B
def channels(A, target=0.01):
    N = 1
    while erlang_b(A, N) > target: N += 1
    return N
for A in [2, 10, 20, 50, 100]:
    N = channels(A); print(f"A = {A:3d} Erl: {N:3d} kanałów dla 1% (wykorzystanie {A*(1 - erlang_b(A, N))/N*100:4.1f}%)")

rng = np.random.default_rng(0)
lam, mu, n = 800, 1000, 200_000
arr = np.cumsum(rng.exponential(1/lam, n)); svc = rng.exponential(1/mu, n)
dep = np.empty(n); t = 0.0
for i in range(n):
    t = max(t, arr[i]) + svc[i]; dep[i] = t
print(f"M/M/1 rho=0.8: średni czas sym. {np.mean(dep - arr)*1e3:.2f} ms, teoria {1/(mu - lam)*1e3:.2f} ms")

key = secrets.token_bytes(32)
msg = b"temp=23.5;id=42"
tag = hmac.new(key, msg, hashlib.sha256).hexdigest()
print("HMAC-SHA256:", tag[:32], "...")
print("weryfikacja zmienionej wiadomości:", hmac.compare_digest(tag, hmac.new(key, b"temp=99.9;id=42", hashlib.sha256).hexdigest()))
print("SHA-256('abc') =", hashlib.sha256(b"abc").hexdigest()[:16], "...")
```

## Zadania

1. 500 abonentów, 2 połączenia w GNR po 3 min. Jakie natężenie ruchu? Ile kanałów dla 2% blokady?
2. Ile wynosi blokada przy 10 Erl i 15 kanałach?
3. Kolejka M/M/1 ma μ = 10 000 pakietów/s. Przy jakim obciążeniu średni czas w systemie przekroczy 1 ms?
4. Dlaczego TLS używa zarówno kryptografii asymetrycznej, jak i symetrycznej?
5. Wymień trzy mechanizmy, które chronią flotę urządzeń IoT przed przejęciem przez złośliwą aktualizację.

<details>
<summary>Odpowiedzi</summary>

1. $500\cdot 2\cdot 3/60 = 50$ Erl; 61 kanałów (snippet: `channels(50, 0.02)`)
2. ≈ 3,65%
3. $1/(\mu - \lambda) > 10^{-3}$ → $\lambda > 9000$/s, czyli ρ > 0,9
4. Asymetryczna — do uzgodnienia klucza przez niezaufaną sieć i uwierzytelnienia serwera (podpis, certyfikat); symetryczna — do szybkiego szyfrowania i uwierzytelniania danych kluczem sesji
5. Podpis cyfrowy aktualizacji weryfikowany kluczem publicznym w urządzeniu; bezpieczny rozruch (łańcuch zaufania od ROM); ochrona przed cofaniem wersji (licznik wersji) i bezpieczne przechowywanie kluczy (secure element); transport przez TLS z weryfikacją certyfikatu
</details>

## Źródła

- [Teletraffic Engineering Handbook — V. B. Iversen](https://orbit.dtu.dk/en/publications/teletraffic-engineering-handbook/) — Erlang B, C, systemy kolejkowe
- [A Graduate Course in Applied Cryptography — D. Boneh, V. Shoup](https://crypto.stanford.edu/~dabo/cryptobook/) — szyfry, MAC, podpisy, uzgadnianie kluczy
- [Computer Networks: A Systems Approach — Peterson, Davie](https://github.com/SystemsApproach/book) — bezpieczeństwo sieci (TLS, IPsec)
- [Python — hashlib i hmac](https://docs.python.org/3/library/hmac.html)
