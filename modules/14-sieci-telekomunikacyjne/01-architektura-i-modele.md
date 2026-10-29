# 14.01 — Architektura sieci, modele warstwowe, opóźnienia

## Po co to jest

Sieć to zbyt złożony system, by projektować go w całości. Model warstwowy dzieli go na niezależne poziomy — od impulsów w kablu po aplikację — z jasnymi interfejsami. Dzięki temu Wi-Fi można wymienić na światłowód bez zmiany przeglądarki. Drugie podstawowe narzędzie to rachunek opóźnień: z czego składa się czas dotarcia pakietu i co ogranicza przepustowość.

## Teoria w pigułce

### Modele warstwowe

| OSI | TCP/IP | Jednostka danych | Przykłady | Urządzenie |
|---|---|---|---|---|
| 7 Aplikacji, 6 Prezentacji, 5 Sesji | **Aplikacji** | Wiadomość | HTTP, DNS, SMTP, MQTT, TLS | Serwer, host |
| 4 Transportowa | **Transportowa** | Segment / datagram | TCP, UDP, QUIC | Host |
| 3 Sieciowa | **Internetowa** | Pakiet | IP, ICMP | Router |
| 2 Łącza danych | **Dostępu do sieci** | Ramka | Ethernet, Wi-Fi (802.11), PPP | Przełącznik, punkt dostępowy |
| 1 Fizyczna | | Bit / symbol | Kodowanie, modulacja, światłowód, skrętka, radio | Wzmacniak, transceiver |

**Enkapsulacja:** każda warstwa dodaje swój nagłówek (i ewentualnie stopkę) do danych z warstwy wyższej. Ramka Ethernet = nagłówek Ethernet + [nagłówek IP + [nagłówek TCP + [dane aplikacji]]] + FCS.

**Zasada końców (end-to-end):** inteligencja (niezawodność, szyfrowanie) w hostach, sieć prosta i szybka — choć w praktyce sieci mają wiele „pośredników” (NAT, zapory, serwery pośredniczące).

### Komutacja łączy i pakietów

| | Komutacja łączy | Komutacja pakietów |
|---|---|---|
| Zasób | Rezerwowany na czas połączenia (kanał, szczelina czasowa) | Współdzielony, dane w pakietach |
| Opóźnienie | Stałe po zestawieniu | Zmienne (kolejki) |
| Wykorzystanie | Słabe przy ruchu „zrywowym” | Dobre (multipleksacja statystyczna) |
| Przykłady | Klasyczna telefonia (PSTN, ISDN), SDH | Internet, sieci komórkowe od 4G |

### Opóźnienia

$$d = d_{przetw} + d_{kolejk} + d_{trans} + d_{prop}$$

| Składnik | Wzór / wartość |
|---|---|
| Transmisji (serializacji) | $L/R$ — długość pakietu / szybkość łącza |
| Propagacji | $d/v$; w światłowodzie i miedzi $v \approx 2\cdot 10^8$ m/s (ok. 5 µs/km) |
| Kolejkowania | Zależy od obciążenia — rośnie gwałtownie, gdy obciążenie zbliża się do 100% ([14.08](08-teoria-ruchu-i-bezpieczenstwo.md)) |
| Przetwarzania | µs w sprzęcie, więcej w oprogramowaniu |

**Iloczyn pasmo–opóźnienie (BDP)** $= R\cdot RTT$ — ile danych „mieści się w rurze”; tyle musi wynosić okno nadawcy, żeby wykorzystać łącze ([14.05](05-transport-i-qos.md)).

**Przepustowość ścieżki** = przepustowość najwolniejszego łącza (wąskiego gardła).

### Standaryzacja

IETF (RFC — protokoły internetowe), IEEE 802 (Ethernet, Wi-Fi), 3GPP (sieci komórkowe), ITU-T (telekomunikacja, światłowody, kodeki), ETSI. Dokumenty RFC i wiele norm są dostępne bezpłatnie.

## Przykład rozwiązany

Pakiet 1500 B z Warszawy do serwera odległego o 1000 km (światłowód), łącze 100 Mbit/s, 5 routerów po drodze (każdy z buforowaniem typu „store-and-forward”).

1. Transmisja jednego pakietu: $1500\cdot 8/10^8 = 120$ µs; na 6 łączach (5 routerów): 720 µs.
2. Propagacja: $10^6/(2\cdot 10^8) = 5$ ms.
3. RTT ≈ 10 ms + transmisje + kolejki — dla małych pakietów dominuje propagacja.
4. BDP przy 1 Gbit/s i RTT 50 ms: $10^9\cdot 0\text{,}05/8 = 6\text{,}25$ MB — tyle danych musi być „w drodze”, by w pełni wykorzystać łącze.

## Typowe pułapki

- **Mylenie przepływności z opóźnieniem** — szybsze łącze nie skraca propagacji.
- **Bity i bajty** (Mbit/s vs MB/s) — czynnik 8.
- **Prędkość światła w próżni zamiast w medium** (ok. 2/3 c).
- **Przypisywanie protokołów do „złych” warstw** — np. TLS formalnie nad TCP, ARP między warstwami 2 i 3.
- **Ignorowanie narzutu nagłówków** przy małych pakietach (VoIP, IoT).

## Ćwiczenie komputerowe

Kalkulator opóźnień i BDP; symulacja czasu przesłania pliku przez kilka łączy „store-and-forward” z pakietyzacją:

```python
def delays(L_bytes, R_bps, dist_m, hops=1, v=2e8):
    t_tr = L_bytes*8/R_bps
    return t_tr, dist_m/v, hops*t_tr + dist_m/v

t_tr, t_pr, total = delays(1500, 100e6, 1e6, hops=6)
print(f"transmisja {t_tr*1e6:.0f} us, propagacja {t_pr*1e3:.1f} ms, łącznie {total*1e3:.2f} ms")
for R, rtt in [(10e6, 0.02), (1e9, 0.05), (10e9, 0.1)]:
    print(f"R = {R/1e6:6.0f} Mbit/s, RTT = {rtt*1e3:3.0f} ms: BDP = {R*rtt/8/1e6:7.3f} MB")

# plik 10 MB przez 3 łącza 100 Mbit/s: wpływ wielkości pakietu (nagłówek 40 B)
F, hops, R = 10e6, 3, 100e6
for P in [500, 1500, 9000, 10e6]:
    n = int(F//P) + (F % P > 0)
    t = (n + hops - 1)*(P + 40)*8/R        # potokowe przesyłanie przez kolejne łącza
    print(f"pakiet {P:>9.0f} B: {n:6d} pakietów, czas {t:.4f} s")
```

## Zadania

1. Ile trwa wysłanie ramki 64 B na łączu 1 Gbit/s? A 9000 B (jumbo)?
2. RTT między Europą a USA (6000 km światłowodem, droga okrężna ×1,5). Oszacuj minimalne RTT.
3. Plik 1 GB przesyłany łączem 100 Mbit/s z RTT 100 ms. Ile trwa transmisja przy idealnym wykorzystaniu łącza? Jakie okno TCP jest potrzebne?
4. Dlaczego przy przesyłaniu przez wiele łączy dzielenie danych na mniejsze pakiety skraca czas (do pewnej granicy)?
5. Przyporządkuj do warstw: MAC, numer portu, adres IP, kod Manchester, adres URL.

<details>
<summary>Odpowiedzi</summary>

1. 0,512 µs; 72 µs
2. Droga 9000 km → jednokierunkowo 45 ms, RTT ≈ 90 ms
3. $8\cdot 10^9/10^8 = 80$ s (+ narzut); okno ≥ BDP = $10^8\cdot 0\text{,}1/8 = 1\text{,}25$ MB
4. Potokowanie — kolejne łącza pracują równolegle nad różnymi pakietami; zbyt małe pakiety zwiększają narzut nagłówków i obciążenie przetwarzania
5. MAC — 2; port — 4; IP — 3; Manchester — 1; URL — 7 (aplikacji)
</details>

## Źródła

- [Computer Networks: A Systems Approach — Peterson, Davie](https://github.com/SystemsApproach/book) — rozdział 1 (architektura, wydajność, opóźnienia)
- [MIT 6.02 Digital Communication Systems](https://ocw.mit.edu/courses/6-02-introduction-to-eecs-ii-digital-communication-systems-fall-2012/) — komutacja pakietów, opóźnienia
- [Kurose — wykłady wideo](https://www.youtube.com/results?search_query=Jim+Kurose+Computer+Networking+Top-Down+Approach) — rozdział 1 (opóźnienia, warstwy)
