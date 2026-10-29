# 13.06 — Kodowanie kanałowe

## Po co to jest

Kodowanie kanałowe dodaje do danych nadmiarowość, która pozwala wykryć i poprawić błędy. To ono zbliża współczesne systemy do granicy Shannona: kod o sprawności 1/2 potrafi dać kilka–kilkanaście dB zysku, czyli wielokrotnie większy zasięg przy tej samej mocy. Kody wykrywające (CRC) chronią każdą ramkę w sieciach, kody korekcyjne — każdą transmisję radiową, zapis na dysku i w pamięci.

## Teoria w pigułce

### Podstawowe pojęcia

- Kod blokowy $(n, k)$: $k$ bitów danych → $n$ bitów słowa kodowego; **sprawność** $r = k/n$.
- **Odległość Hamminga** między słowami: liczba różniących się pozycji. Minimalna odległość kodu $d_{min}$:
  wykrywa $d_{min} - 1$ błędów, **poprawia** $t = \lfloor(d_{min} - 1)/2\rfloor$ błędów.
- **Zysk kodowania:** o ile dB mniejsze $E_b/N_0$ wystarcza z kodem dla tego samego BER.
- Dekodowanie twarde (decyzje 0/1) vs **miękkie** (wykorzystuje wiarygodność, np. log-iloraz prawdopodobieństw LLR) — miękkie daje ok. 2 dB więcej.

### Kody blokowe liniowe

Kodowanie: $\mathbf c = \mathbf dG$ (macierz generująca), sprawdzanie: **syndrom** $\mathbf s = \mathbf rH^T$; $\mathbf s = 0$ — brak wykrytego błędu, inaczej syndrom wskazuje wzorzec błędu.

**Kod Hamminga (7,4):** $d_{min} = 3$, poprawia 1 błąd, $r = 4/7$. Bity parzystości na pozycjach 1, 2, 4; syndrom to numer pozycji błędnego bitu. Rozszerzony (8,4) — dodatkowo wykrywa 2 błędy (SECDED w pamięciach ECC).

Inne: BCH, **Reed–Solomon** (symbole wielobitowe — poprawia błędy seryjne: CD, DVB, kody QR, RAID 6).

### CRC — wykrywanie błędów

Reszta z dzielenia wielomianów nad GF(2): dane × $x^r$ mod wielomian generujący $g(x)$ stopnia $r$. Wykrywa wszystkie błędy pojedyncze, wszystkie serie krótsze niż $r + 1$ bitów i ogromną większość innych. Popularne: CRC-8, CRC-16-CCITT, CRC-32 (Ethernet, ZIP). Używane z retransmisją (ARQ, HARQ).

### Kody splotowe i Viterbi

Koder ze rejestrem przesuwnym długości $K$ (długość wymuszona), każdy bit wejściowy daje $n$ bitów wyjściowych jako sumy modulo 2 wybranych komórek. Klasyczny kod $r = 1/2$, $K = 7$ (wielomiany 171, 133 ósemkowo) — $d_{free} = 10$, zysk ok. 5 dB przy dekodowaniu miękkim. **Dekoder Viterbiego** znajduje najbardziej prawdopodobną ścieżkę w kracie (trellis) w czasie liniowym względem długości wiadomości (programowanie dynamiczne, $2^{K-1}$ stanów). **Nakłuwanie (puncturing)** daje sprawności 2/3, 3/4 z tego samego kodera.

### Przeplot

Kody korygują błędy rozproszone, a kanał z zanikami daje serie. **Przeplatacz** rozkłada sąsiednie bity kodowe w czasie (lub po podnośnych) — po rozplocie seria staje się rozproszonymi pojedynczymi błędami.

### Kody nowoczesne

| Kod | Idea | Zastosowania |
|---|---|---|
| **Turbo** | Dwa kody splotowe z przeplotem, dekodowanie iteracyjne z wymianą miękkiej informacji | 3G, 4G (dane), łącza kosmiczne |
| **LDPC** | Rzadka macierz sprawdzeń, dekodowanie iteracyjne (propagacja przekonań) | Wi-Fi, DVB-S2, 5G (dane), Ethernet 10G, dyski SSD |
| **Polarne** | Polaryzacja kanałów — część „idealnych”, część „bezużytecznych” | 5G (kanały sterujące) |

Pracują w odległości ułamka dB do ok. 1 dB od granicy Shannona przy długich blokach.

## Przykład rozwiązany

**Hamming (7,4)**, dane 1011. Pozycje: p1 p2 d1 p4 d2 d3 d4.

1. d1 = 1, d2 = 0, d3 = 1, d4 = 1.
2. p1 = d1 ⊕ d2 ⊕ d4 = 0; p2 = d1 ⊕ d3 ⊕ d4 = 1; p4 = d2 ⊕ d3 ⊕ d4 = 0.
3. Słowo: **0 1 1 0 0 1 1**.
4. Błąd na pozycji 5: odebrano 0110**1**11. Syndrom: s1 = pozycje 1, 3, 5, 7 → 0 ⊕ 1 ⊕ 1 ⊕ 1 = 1; s2 = 2, 3, 6, 7 → 1 ⊕ 1 ⊕ 1 ⊕ 1 = 0; s4 = 4, 5, 6, 7 → 0 ⊕ 1 ⊕ 1 ⊕ 1 = 1. Syndrom (s4 s2 s1) = 101 = **5** — pozycja błędu; poprawiamy.

## Typowe pułapki

- **Ocena zysku kodowania przy tym samym $E_s/N_0$** zamiast $E_b/N_0$ — kod obniża energię na bit kodowy.
- **CRC traktowany jako korekcja** — tylko wykrywa.
- **Kod korekcyjny bez przeplotu w kanale z zanikami** — serie błędów przekraczają zdolność korekcji.
- **Dekodowanie twarde tam, gdzie dostępne są wartości miękkie** — strata ok. 2 dB.
- **Różne konwencje CRC** (wartość początkowa, odwrócenie bitów, XOR na końcu) — „ten sam” CRC-16 daje różne wyniki w różnych bibliotekach.

## Ćwiczenie komputerowe

Hamming (7,4), CRC-8 i kod splotowy (7,5) z dekoderem Viterbiego — BER w kanale BPSK/AWGN:

```python
import numpy as np
from scipy.special import erfc

rng = np.random.default_rng(0)
# --- Hamming (7,4): pozycje p1 p2 d1 p4 d2 d3 d4
def ham_enc(d):
    d1, d2, d3, d4 = d
    return np.array([d1 ^ d2 ^ d4, d1 ^ d3 ^ d4, d1, d2 ^ d3 ^ d4, d2, d3, d4])
def ham_dec(r):
    r = r.copy()
    s = (r[0] ^ r[2] ^ r[4] ^ r[6]) | (r[1] ^ r[2] ^ r[5] ^ r[6]) << 1 | (r[3] ^ r[4] ^ r[5] ^ r[6]) << 2
    if s: r[s - 1] ^= 1
    return r[[2, 4, 5, 6]]
c = ham_enc([1, 0, 1, 1]); print("Hamming 1011 ->", c)
e = c.copy(); e[4] ^= 1; print("błąd na poz. 5, po dekodowaniu:", ham_dec(e))

# --- CRC-8 (wielomian x^8+x^2+x+1 = 0x07, bez odwracania)
def crc8(data, poly=0x07):
    crc = 0
    for byte in data:
        crc ^= byte
        for _ in range(8): crc = ((crc << 1) ^ poly) & 0xFF if crc & 0x80 else (crc << 1) & 0xFF
    return crc
print("CRC-8('123456789') = 0x%02X (wartość kontrolna 0xF4)" % crc8(b"123456789"))

# --- kod splotowy r=1/2, K=3, wielomiany (7,5) ósemkowo, Viterbi z decyzjami miękkimi
G = [0b111, 0b101]
def conv_enc(bits):
    s, out = 0, []
    for b in np.concatenate([bits, [0, 0]]):
        s = ((s << 1) | b) & 0b111
        out += [bin(s & g).count('1') & 1 for g in G]
    return np.array(out)
def viterbi(r):                                   # r: miękkie wartości (+1 ~ bit 0, -1 ~ bit 1)
    n = len(r)//2; INF = 1e18
    pm = np.array([0, INF, INF, INF]); prev = np.zeros((n, 4), int); inp = np.zeros((n, 4), int)
    for t in range(n):
        new = np.full(4, INF)
        for st in range(4):
            if pm[st] >= INF: continue
            for b in (0, 1):
                full = ((st << 1) | b) & 0b111
                o = [bin(full & g).count('1') & 1 for g in G]
                m = pm[st] - (r[2*t]*(1 - 2*o[0]) + r[2*t + 1]*(1 - 2*o[1]))
                ns = full & 0b11
                if m < new[ns]: new[ns], prev[t, ns], inp[t, ns] = m, st, b
        pm = new
    st, out = 0, []
    for t in range(n - 1, -1, -1): out.append(inp[t, st]); st = prev[t, st]
    return np.array(out[::-1])[:-2]

N = 20000
for ebn0 in [3, 5, 7]:
    g = 10**(ebn0/10)
    b = rng.integers(0, 2, N)
    unc = np.mean(((1 - 2*b) + rng.standard_normal(N)/np.sqrt(2*g) < 0) != b)
    cb = conv_enc(b); sig = (1 - 2*cb) + rng.standard_normal(cb.size)/np.sqrt(2*g*0.5)   # Ec = Eb/2
    dec = np.mean(viterbi(sig) != b)
    print(f"Eb/N0 = {ebn0} dB: bez kodu {unc:.2e} (teoria {0.5*erfc(np.sqrt(g)):.2e}), kod (7,5)+Viterbi {dec:.2e}")
```

## Zadania

1. Kod ma $d_{min} = 5$. Ile błędów wykrywa, ile poprawia?
2. Zakoduj dane 0110 kodem Hamminga (7,4) według schematu z przykładu.
3. Odebrano słowo 1110010 (Hamming (7,4)). Który bit jest błędny i jakie były dane?
4. Kod o sprawności 1/2 daje BER $10^{-5}$ przy $E_b/N_0 = 4{,}5$ dB. Jaki jest zysk kodowania względem BPSK bez kodu?
5. Dlaczego w łączu radiowym z zanikami po koderze splotowym stosuje się przeplatacz?

<details>
<summary>Odpowiedzi</summary>

1. Wykrywa 4, poprawia 2
2. d1 = 0, d2 = 1, d3 = 1, d4 = 0: p1 = 0⊕1⊕0 = 1, p2 = 0⊕1⊕0 = 1, p4 = 1⊕1⊕0 = 0 → **1100110**
3. s1 = r1⊕r3⊕r5⊕r7 = 1⊕1⊕0⊕0 = 0; s2 = r2⊕r3⊕r6⊕r7 = 1⊕1⊕1⊕0 = 1; s4 = r4⊕r5⊕r6⊕r7 = 0⊕0⊕1⊕0 = 1 → syndrom 110 = 6: błędny bit 6; poprawione słowo 1110000, dane d1 d2 d3 d4 = 1 0 0 0
4. $9{,}6 - 4{,}5 = 5{,}1$ dB
5. Zanik niszczy serię kolejnych bitów; kod splotowy (i Viterbi) radzi sobie z błędami rozproszonymi — przeplot rozkłada serię na pojedyncze błędy odległe od siebie
</details>

## Źródła

- [MIT 6.02 Digital Communication Systems](https://ocw.mit.edu/courses/6-02-introduction-to-eecs-ii-digital-communication-systems-fall-2012/) — kody liniowe, Hamming, kody splotowe, dekoder Viterbiego (notatki z przykładami)
- [MIT 6.450 Principles of Digital Communications I](https://ocw.mit.edu/courses/6-450-principles-of-digital-communications-i-fall-2006/)
- [Fundamentals of Electrical Engineering I — D. Johnson](https://open.umn.edu/opentextbooks/textbooks/fundamentals-of-electrical-engineering-1) — kody korekcyjne
