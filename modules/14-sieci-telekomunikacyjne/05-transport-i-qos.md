# 14.05 — Warstwa transportowa i jakość usług

## Po co to jest

IP dostarcza pakiety „jak się uda” — mogą zginąć, przyjść w innej kolejności albo zostać powielone. Warstwa transportowa zapewnia aplikacjom niezawodny strumień (TCP) albo szybką, prostą usługę datagramową (UDP), a mechanizmy sterowania przeciążeniem chronią sieć przed zapaścią. Jakość usług (QoS) decyduje o tym, czy rozmowa głosowa nie rwie się, gdy ktoś w tej samej sieci pobiera duży plik.

## Teoria w pigułce

### UDP i TCP

| | UDP | TCP |
|---|---|---|
| Usługa | Datagramy, bez połączenia | Niezawodny, uporządkowany strumień bajtów |
| Nagłówek | 8 B | 20 B (+ opcje) |
| Niezawodność | Brak (aplikacja decyduje) | Numery sekwencyjne, potwierdzenia, retransmisje |
| Sterowanie przepływem i przeciążeniem | Brak | Okno odbiorcy, sterowanie przeciążeniem |
| Zastosowania | DNS, VoIP, wideo na żywo, gry, IoT (CoAP), QUIC | WWW, poczta, transfer plików, MQTT |

**Porty** (16 bitów) identyfikują aplikacje: 80/443 HTTP/HTTPS, 53 DNS, 22 SSH, 1883/8883 MQTT.

### Mechanizmy TCP

- **Nawiązanie połączenia:** trójetapowe (SYN, SYN-ACK, ACK); zamknięcie: FIN/ACK.
- **Okno przesuwne:** nadawca może mieć w drodze najwyżej tyle danych, ile wynosi okno — przepływność $\leq W/RTT$. Okno odbiorcy (sterowanie przepływem) ≤ 64 KB bez opcji skalowania okna.
- **Retransmisje:** po przekroczeniu czasu (RTO wyznaczane ze średniego RTT i jego zmienności) lub po trzech powtórzonych potwierdzeniach (szybka retransmisja).
- **Sterowanie przeciążeniem:** okno przeciążenia — wolny start (podwajanie co RTT), potem **AIMD** (+1 segment na RTT, połowa przy stracie); nowsze algorytmy: CUBIC (domyślny w Linuksie), BBR (modeluje pasmo i RTT). Przybliżenie przepływności przy stratach $p$ (wzór Mathisa):

$$R \approx \frac{1\text{,}22\cdot MSS}{RTT\sqrt p}$$

Wniosek: na łączach o dużym RTT nawet małe straty (np. radiowe) bardzo ograniczają przepływność TCP.

**QUIC** (podstawa HTTP/3) — transport nad UDP z wbudowanym szyfrowaniem TLS 1.3, szybszym nawiązaniem połączenia i wieloma niezależnymi strumieniami.

### Jakość usług (QoS)

| Parametr | Przykładowe wymagania (rozmowa głosowa) |
|---|---|
| Opóźnienie (w jedną stronę) | ≲ 150 ms |
| Zmienność opóźnienia (jitter) | ≲ 30 ms (kompensowane buforem odbiorczym) |
| Straty pakietów | ≲ 1% |

Mechanizmy: **klasyfikacja i znakowanie** (pole DSCP w nagłówku IP — DiffServ; priorytet 802.1p w ramce z VLAN-em), **kolejkowanie z priorytetami** i ważone (WFQ), **kształtowanie i ograniczanie ruchu** (wiaderko żetonowe, token bucket), aktywne zarządzanie kolejką (RED, CoDel — przeciw zbyt dużym buforom, „bufferbloat”). W sieciach operatorskich: MPLS-TE, rezerwacja zasobów; w 5G — przekroje sieci (network slicing) i klasy QoS.

**Głos przez IP (VoIP):** sygnalizacja SIP, media przez RTP/UDP, kodeki (G.711 64 kbit/s, Opus 6–510 kbit/s, AMR-WB); pakiet co 20 ms.

## Przykład rozwiązany

**Ograniczenie oknem:** okno 64 KB, RTT 50 ms → $65\,535\cdot 8/0\text{,}05 \approx 10\text{,}5$ Mbit/s — niezależnie od tego, że łącze ma 1 Gbit/s. Do pełnego wykorzystania potrzeba okna ≥ BDP = 6,25 MB (opcja skalowania okna).

**Straty:** MSS = 1460 B, RTT = 50 ms, $p = 10^{-4}$: $R \approx 1\text{,}22\cdot 1460\cdot 8/(0\text{,}05\cdot 0\text{,}01) \approx 28\text{,}5$ Mbit/s.

**Narzut VoIP:** kodek G.711, ramka 20 ms → 160 B danych + RTP 12 + UDP 8 + IPv4 20 = 200 B co 20 ms → 80 kbit/s na poziomie IP (z Ethernetem 38 B ok. 95 kbit/s) — 64 kbit/s „netto” to tylko 2/3 pasma.

## Typowe pułapki

- **Testowanie przepustowości jednym połączeniem TCP na łączu o dużym RTT** — wynik zaniżony przez okno.
- **UDP bez kontroli szybkości** — zalewa łącze i wypiera ruch TCP.
- **Za duże bufory w routerach** (bufferbloat) — opóźnienia setek ms przy obciążeniu.
- **Znakowanie DSCP bez konfiguracji kolejek** — znaczniki nic nie zmieniają; albo nieufne znakowanie przez hosty.
- **Mylenie przepływności łącza z przepływnością aplikacji** — nagłówki, potwierdzenia, retransmisje.

## Ćwiczenie komputerowe

Symulacja okna przeciążenia TCP (wolny start + AIMD z losowymi stratami) i porównanie ze wzorem Mathisa:

```python
import numpy as np
import matplotlib.pyplot as plt

rng = np.random.default_rng(0)
MSS, RTT, p = 1460, 0.05, 1e-4
cwnd, ssthresh, sent, hist = 1.0, 64.0, 0, []
for rtt_i in range(20000):
    segs = int(cwnd)
    lost = rng.random(segs) < p
    sent += segs - lost.sum()
    if lost.any(): ssthresh = max(cwnd/2, 2); cwnd = ssthresh          # szybkie odtworzenie (uproszczone)
    elif cwnd < ssthresh: cwnd *= 2                                    # wolny start
    else: cwnd += 1                                                    # unikanie przeciążenia
    hist.append(cwnd)
R_sim = sent*MSS*8/(20000*RTT)
R_math = 1.22*MSS*8/(RTT*np.sqrt(p))
print(f"symulacja: {R_sim/1e6:.1f} Mbit/s, wzór Mathisa: {R_math/1e6:.1f} Mbit/s")
print(f"ograniczenie oknem 64 KB: {65535*8/RTT/1e6:.1f} Mbit/s")
print(f"VoIP G.711/20 ms: IP {200*8/0.02/1e3:.0f} kbit/s, z Ethernetem {(200 + 38)*8/0.02/1e3:.1f} kbit/s")
plt.plot(hist[:2000]); plt.xlabel('RTT'); plt.ylabel('cwnd [segmenty]'); plt.grid(); plt.show()
```

## Zadania

1. Okno 256 KB, RTT 20 ms. Maksymalna przepływność TCP?
2. Jakie okno jest potrzebne, by wykorzystać łącze satelitarne 50 Mbit/s z RTT 600 ms?
3. Łącze radiowe ma straty 1%, RTT 100 ms, MSS 1400 B. Oszacuj przepływność TCP Reno.
4. Ile wynosi przepływność IP rozmowy w kodeku o 8 kbit/s z ramkami 20 ms (IPv4, UDP, RTP)? Jaki to procent narzutu?
5. Dlaczego DNS korzysta głównie z UDP, a przesyłanie plików z TCP?

<details>
<summary>Odpowiedzi</summary>

1. $262\,144\cdot 8/0\text{,}02 \approx 105$ Mbit/s
2. $50\cdot 10^6\cdot 0\text{,}6/8 = 3\text{,}75$ MB
3. $1\text{,}22\cdot 1400\cdot 8/(0\text{,}1\cdot 0\text{,}1) \approx 1\text{,}37$ Mbit/s
4. 20 B danych + 40 B nagłówków = 60 B co 20 ms → 24 kbit/s; narzut 2/3 (67%) — stąd kompresja nagłówków (ROHC) w sieciach komórkowych
5. Zapytanie DNS mieści się zwykle w jednym pakiecie, a odpowiedź jest szybka — zestawianie połączenia byłoby kosztowniejsze niż ewentualne ponowienie; plik wymaga niezawodnego, uporządkowanego przesłania wielu segmentów i sterowania przeciążeniem
</details>

## Źródła

- [Computer Networks: A Systems Approach — Peterson, Davie](https://github.com/SystemsApproach/book) — protokoły end-to-end, sterowanie przeciążeniem, QoS
- [MIT 6.02 Digital Communication Systems](https://ocw.mit.edu/courses/6-02-introduction-to-eecs-ii-digital-communication-systems-fall-2012/) — niezawodny transport, okno przesuwne
- [Kurose — wykłady wideo](https://www.youtube.com/results?search_query=Jim+Kurose+Computer+Networking+Top-Down+Approach) — warstwa transportowa, TCP
