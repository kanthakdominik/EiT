# 14 — Sieci telekomunikacyjne

> **Status:** ✅ pełny

## Cel modułu

Rozumieć budowę i działanie sieci przenoszących dane i głos — od światłowodu i ramki Ethernet, przez adresację i routing IP, transport i jakość usług, po sieci dostępowe, komórkowe i IoT. Umieć policzyć opóźnienia, przepustowość, budżet łącza optycznego i liczbę kanałów dla zadanego ruchu, a także rozumieć podstawy zabezpieczania transmisji. Perspektywa inżyniera telekomunikacji: co dzieje się w sprzęcie i dlaczego protokoły wyglądają tak, a nie inaczej.

## Wymagania wstępne

- [13 Telekomunikacja](../13-telekomunikacja/) — modulacje, kodowanie, OFDM, kanał radiowy.
- [00.06 Prawdopodobieństwo i statystyka](../00-matematyka/06-prawdopodobienstwo-i-statystyka.md) — dla teorii ruchu.
- [05.01 Liczby i kody](../05-technika-cyfrowa/01-liczby-i-kody.md) — zapis binarny i szesnastkowy.

## Tematy

| # | Temat | Czas (od zera / odświeżenie) |
|---|---|---|
| 01 | [Architektura sieci, modele warstwowe, opóźnienia](01-architektura-i-modele.md) | 6 h / 2 h |
| 02 | [Warstwa fizyczna i telekomunikacja światłowodowa](02-warstwa-fizyczna-i-swiatlowody.md) | 8 h / 3 h |
| 03 | [Ethernet, przełączanie i VLAN](03-ethernet-i-przelaczanie.md) | 6 h / 2 h |
| 04 | [IP: adresacja, podsieci i routing](04-ip-adresacja-i-routing.md) | 10 h / 3 h |
| 05 | [Warstwa transportowa i jakość usług](05-transport-i-qos.md) | 8 h / 2 h |
| 06 | [Sieci dostępowe i szkieletowe](06-sieci-dostepowe-i-szkieletowe.md) | 6 h / 2 h |
| 07 | [Sieci komórkowe i IoT](07-sieci-komorkowe-i-iot.md) | 8 h / 3 h |
| 08 | [Teoria ruchu i bezpieczeństwo transmisji](08-teoria-ruchu-i-bezpieczenstwo.md) | 8 h / 3 h |

## Test wejściowy (diagnoza)

Około 60 minut, bez notatek.

1. Wymień warstwy modelu TCP/IP i podaj po jednym protokole dla każdej.
2. Ramka 1500 B na łączu 100 Mbit/s, odległość 1000 km światłowodem. Ile wynosi opóźnienie transmisji, a ile propagacji?
3. Ile adresów hostów ma podsieć 192.168.10.0/26? Jaka jest maska i adres rozgłoszeniowy?
4. Czym różni się przełącznik od routera?
5. Dlaczego TCP na łączu o RTT 50 ms z oknem 64 KB nie przekroczy ok. 10 Mbit/s, choć łącze ma 1 Gbit/s?
6. Łącze światłowodowe 40 km, 0,35 dB/km, 4 złącza po 0,5 dB, 10 spawów po 0,1 dB, margines 3 dB. Jaki budżet mocy jest potrzebny?
7. Ruch 10 Erl. Ile kanałów zapewni prawdopodobieństwo blokady poniżej 1%?
8. Czym różni się szyfrowanie symetryczne od asymetrycznego? Gdzie stosuje się każde z nich w TLS?

<details>
<summary>Odpowiedzi</summary>

1. Dostępu do sieci (Ethernet, Wi-Fi), internetowa (IP), transportowa (TCP, UDP), aplikacji (HTTP, DNS)
2. Transmisja: 120 µs; propagacja: 5 ms
3. 62 hosty; 255.255.255.192; 192.168.10.63
4. Przełącznik przekazuje ramki w obrębie jednej sieci warstwy 2 na podstawie adresów MAC; router łączy różne sieci IP i wybiera drogę na podstawie adresów IP (warstwa 3)
5. Przepływność ≤ okno/RTT = 65 535 · 8 / 0,05 ≈ 10,5 Mbit/s — nadawca czeka na potwierdzenia (rozwiązanie: skalowanie okna)
6. $14 + 2 + 1 + 3 = 20$ dB
7. 18 kanałów (Erlang B)
8. Symetryczne — jeden wspólny klucz, szybkie (szyfrowanie danych, np. AES); asymetryczne — para kluczy, wolne (uzgodnienie klucza i uwierzytelnienie — ECDHE, podpisy RSA/ECDSA w certyfikatach)

**Ocena:** 1–2 — temat 01; 3 — 04; 4 — 03–04; 5 — 05; 6 — 02; 7–8 — 08.
</details>

## Projekt modułowy: sieć od kabla do aplikacji

- [ ] **Topologia:** zbuduj w symulatorze sieci (np. GNS3, Mininet lub symulatorze producenta sprzętu) albo na kilku urządzeniach (router domowy, przełącznik zarządzalny, Raspberry Pi) sieć z dwiema podsieciami, VLAN-em i routingiem.
- [ ] **Adresacja:** zaplanuj podsieci (VLSM) dla trzech działów o różnej liczbie hostów; skonfiguruj DHCP i routing.
- [ ] **Analiza:** przechwyć ruch [Wiresharkiem](https://www.wireshark.org/docs/) — ARP, DHCP, DNS, nawiązanie połączenia TCP, zapytanie HTTP; opisz enkapsulację od warstwy aplikacji do ramki Ethernet (nagłówki, adresy, porty).
- [ ] **Pomiar:** zmierz RTT i przepustowość (np. iperf) dla TCP i UDP; porównaj z obliczeniami z okna i BDP.
- [ ] **Bezpieczeństwo:** obejrzyj nawiązanie sesji TLS (wymiana certyfikatów, uzgodnienie szyfrów) i wyjaśnij, co jest szyfrowane, a co widoczne.
- [ ] **Obliczenia:** budżet łącza światłowodowego dla wybranego połączenia oraz liczba kanałów/łączy dla zadanego ruchu (Erlang B).

## Sprawdzian końcowy modułu

- [ ] Opisuję drogę pakietu przez sieć (enkapsulacja, ARP, przełącznik, router, NAT).
- [ ] Liczę opóźnienia (transmisji, propagacji, kolejkowania) i iloczyn pasmo–opóźnienie.
- [ ] Liczę budżet mocy i ograniczenia dyspersyjne łącza światłowodowego.
- [ ] Planuję adresację IPv4 z podsieciami i rozumiem IPv6.
- [ ] Wyjaśniam działanie TCP (okno, sterowanie przeciążeniem) i mechanizmy QoS.
- [ ] Porównuję technologie dostępowe (DSL, kablowe, PON) i znam rolę sieci szkieletowej.
- [ ] Opisuję architekturę sieci 4G/5G i dobieram technologię IoT.
- [ ] Liczę ruch w erlangach, liczbę kanałów (Erlang B) i opóźnienia w kolejce M/M/1; znam podstawowe mechanizmy kryptograficzne.

## Główne źródła modułu

| Źródło | Najlepsze do |
|---|---|
| [Computer Networks: A Systems Approach — L. Peterson, B. Davie (wersja otwarta)](https://github.com/SystemsApproach/book) | Główny podręcznik: od łącza po aplikacje, z naciskiem na projektowanie systemów |
| [MIT 6.02 Digital Communication Systems](https://ocw.mit.edu/courses/6-02-introduction-to-eecs-ii-digital-communication-systems-fall-2012/) | Warstwa fizyczna, dostęp do medium, routing, niezawodny transport |
| [Kurose — Computer Networking: A Top-Down Approach (wykłady wideo)](https://www.youtube.com/results?search_query=Jim+Kurose+Computer+Networking+Top-Down+Approach) | Wykłady autora najpopularniejszego podręcznika (książka płatna) |
| [The Fiber Optic Association — Guide to Fiber Optics](https://www.thefoa.org/tech/ref/) | Światłowody w praktyce: tłumienie, złącza, spawanie, budżet łącza, PON |
| [Teletraffic Engineering Handbook — V. B. Iversen (ITU/DTU)](https://orbit.dtu.dk/en/publications/teletraffic-engineering-handbook/) | Teoria ruchu: Erlang B i C, systemy kolejkowe |
| [A Graduate Course in Applied Cryptography — D. Boneh, V. Shoup](https://crypto.stanford.edu/~dabo/cryptobook/) | Kryptografia (darmowa książka) |
| [Wireshark — dokumentacja](https://www.wireshark.org/docs/) | Analiza ruchu sieciowego |
