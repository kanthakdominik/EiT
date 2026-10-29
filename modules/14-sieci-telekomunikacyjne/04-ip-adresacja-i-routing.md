# 14.04 — IP: adresacja, podsieci i routing

## Po co to jest

Protokół IP łączy miliardy urządzeń w jedną sieć, mimo że korzystają z setek różnych technologii łącza. Adresacja i routing to rdzeń Internetu: każdy pakiet znajduje drogę dzięki tablicom routingu budowanym przez protokoły takie jak OSPF i BGP. Planowanie adresacji i diagnozowanie routingu to codzienna praca przy każdej sieci — także przy wdrażaniu urządzeń IoT.

## Teoria w pigułce

### IPv4

Adres 32-bitowy, zapis kropkowo-dziesiętny. **Prefiks (CIDR)** /n — pierwsze $n$ bitów to sieć, reszta — host. W podsieci /n: $2^{32-n}$ adresów, z czego $2^{32-n} - 2$ dla hostów (adres sieci i rozgłoszeniowy).

| Prefiks | Maska | Adresy | Hosty |
|---|---|---|---|
| /24 | 255.255.255.0 | 256 | 254 |
| /26 | 255.255.255.192 | 64 | 62 |
| /30 | 255.255.255.252 | 4 | 2 (łącza punkt–punkt) |

**Adresy prywatne** (RFC 1918): 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 — w Internecie niewidoczne, tłumaczone przez **NAT** (wiele adresów prywatnych za jednym publicznym, rozróżnianych portami). Specjalne: 127.0.0.0/8 (pętla zwrotna), 169.254.0.0/16 (adresy lokalne łącza).

**Nagłówek IPv4** (20 B bez opcji): wersja, długość, TTL (maleje o 1 na każdym routerze — chroni przed pętlami), protokół (6 TCP, 17 UDP, 1 ICMP), suma kontrolna nagłówka, adresy. **Fragmentacja** przy MTU mniejszym niż pakiet (w IPv6 tylko u nadawcy; stosuje się wykrywanie MTU ścieżki).

### IPv6

Adres 128-bitowy, zapis szesnastkowy z kompresją zer (np. 2001:db8::1). Typowo /64 na podsieć, autokonfiguracja adresów (SLAAC), brak NAT jako konieczności, uproszczony nagłówek (40 B), protokół NDP zamiast ARP. Ze względu na wyczerpanie adresów IPv4 obie wersje działają równolegle (dual-stack).

### Usługi pomocnicze

| Protokół | Rola |
|---|---|
| **ARP** | Adres IP → adres MAC w sieci lokalnej (zapytanie rozgłoszeniowe) |
| **DHCP** | Automatyczne przydzielanie adresu, maski, bramy, DNS |
| **DNS** | Nazwa → adres IP (hierarchiczny, rozproszony) |
| **ICMP** | Komunikaty o błędach i diagnostyka (ping, traceroute — wykorzystuje TTL) |

### Przekazywanie pakietów i routing

Host: jeśli adres docelowy jest w mojej podsieci → wysyłam bezpośrednio (ARP), inaczej → do **bramy domyślnej**. Router: **najdłuższe dopasowanie prefiksu** w tablicy routingu wybiera następny skok.

| Rodzaj routingu | Przykłady | Zasada |
|---|---|---|
| Statyczny | Trasy wpisane ręcznie | Proste sieci, trasy domyślne |
| Wektor odległości | RIP | Sąsiedzi wymieniają odległości (Bellman–Ford); wolna zbieżność |
| **Stan łącza** | **OSPF**, IS-IS | Każdy router zna topologię, liczy najkrótsze ścieżki (Dijkstra) — wewnątrz jednej organizacji |
| **Wektor ścieżki** | **BGP** | Między systemami autonomicznymi (operatorami) — polityka, nie tylko najkrótsza droga |

## Przykład rozwiązany

**Podział sieci 192.168.10.0/24** na podsieci dla trzech działów: 100, 50 i 20 hostów (VLSM, od największej):

| Dział | Potrzeba | Prefiks | Sieć | Zakres hostów | Rozgłoszeniowy |
|---|---|---|---|---|---|
| A | 100 | /25 (126) | 192.168.10.0 | .1–.126 | .127 |
| B | 50 | /26 (62) | 192.168.10.128 | .129–.190 | .191 |
| C | 20 | /27 (30) | 192.168.10.192 | .193–.222 | .223 |

Zostaje 192.168.10.224/27 na przyszłość (np. łącza /30 między routerami).

**Najdłuższe dopasowanie:** tablica zawiera 10.0.0.0/8 → R1, 10.1.0.0/16 → R2, 0.0.0.0/0 → R3. Pakiet do 10.1.2.3 → R2 (dopasowanie /16), do 10.5.0.1 → R1, do 8.8.8.8 → R3.

## Typowe pułapki

- **Zła maska na hoście** — host „myśli”, że odbiorca jest w lokalnej sieci, i wysyła ARP zamiast do bramy.
- **Nakładające się podsieci** w różnych miejscach sieci.
- **Brak trasy powrotnej** — ping „w jedną stronę” działa, odpowiedź nie wraca.
- **Problemy z MTU** (np. tunele, PPPoE) — małe pakiety przechodzą, duże giną, gdy ICMP jest blokowane.
- **NAT i połączenia przychodzące** — urządzenie IoT za NAT nie jest osiągalne z zewnątrz bez przekierowania portów lub połączenia inicjowanego od środka (np. MQTT do brokera).

## Ćwiczenie komputerowe

Planowanie podsieci i najdłuższe dopasowanie prefiksu z modułem `ipaddress` oraz Dijkstra dla małej sieci (jak w OSPF):

```python
import ipaddress, heapq

net = ipaddress.ip_network('192.168.10.0/24')
need = {'A': 100, 'B': 50, 'C': 20}
free, plan = [net], {}
for name, hosts in sorted(need.items(), key=lambda x: -x[1]):
    prefix = 32 - (hosts + 2 - 1).bit_length()
    blk = next(b for b in free if b.prefixlen <= prefix)
    free.remove(blk); subs = list(blk.subnets(new_prefix=prefix))
    plan[name] = subs[0]; free = sorted(free + subs[1:], key=lambda n: n.network_address)
for k, v in plan.items():
    print(f"{k}: {v}, maska {v.netmask}, hosty {list(v.hosts())[0]}–{list(v.hosts())[-1]}, broadcast {v.broadcast_address}")
print("wolne:", free)

table = [(ipaddress.ip_network('10.0.0.0/8'), 'R1'), (ipaddress.ip_network('10.1.0.0/16'), 'R2'),
         (ipaddress.ip_network('0.0.0.0/0'), 'R3')]
for dst in ['10.1.2.3', '10.5.0.1', '8.8.8.8']:
    a = ipaddress.ip_address(dst)
    print(dst, '->', max((n for n in table if a in n[0]), key=lambda n: n[0].prefixlen)[1])

graph = {'A': {'B': 1, 'C': 4}, 'B': {'A': 1, 'C': 2, 'D': 5}, 'C': {'A': 4, 'B': 2, 'D': 1}, 'D': {'B': 5, 'C': 1}}
dist, prev, pq = {'A': 0}, {}, [(0, 'A')]
while pq:
    d, u = heapq.heappop(pq)
    for v, w in graph[u].items():
        if d + w < dist.get(v, 1e9): dist[v], prev[v] = d + w, u; heapq.heappush(pq, (d + w, v))
path, v = ['D'], 'D'
while v != 'A': v = prev[v]; path.append(v)
print("koszty z A (Dijkstra):", dist, "| ścieżka do D:", ' -> '.join(path[::-1]), "| następny skok:", path[-2])
```

## Zadania

1. Ile hostów ma podsieć /28? Podaj maskę.
2. Czy adresy 192.168.1.130 i 192.168.1.200 z maską /25 są w tej samej podsieci?
3. Podziel 10.0.0.0/22 na podsieci /24. Wypisz je.
4. Router ma trasy 172.16.0.0/12 → A i 172.16.5.0/24 → B. Dokąd trafi pakiet do 172.16.5.77, a dokąd do 172.20.0.1?
5. Dlaczego traceroute pokazuje kolejne routery na ścieżce?

<details>
<summary>Odpowiedzi</summary>

1. 14 hostów; 255.255.255.240
2. Tak — obie w 192.168.1.128/25 (.129–.254)
3. 10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24
4. 172.16.5.77 → B (dłuższy prefiks); 172.20.0.1 → A
5. Wysyła pakiety z TTL = 1, 2, 3…; router, na którym TTL spada do zera, odsyła komunikat ICMP „time exceeded” ze swoim adresem
</details>

## Źródła

- [Computer Networks: A Systems Approach — Peterson, Davie](https://github.com/SystemsApproach/book) — internetworking, IP, routing (OSPF, BGP), IPv6
- [MIT 6.02 Digital Communication Systems](https://ocw.mit.edu/courses/6-02-introduction-to-eecs-ii-digital-communication-systems-fall-2012/) — routing, wektor odległości i stan łącza
- [Kurose — wykłady wideo](https://www.youtube.com/results?search_query=Jim+Kurose+Computer+Networking+Top-Down+Approach) — warstwa sieci
- [Python — moduł ipaddress](https://docs.python.org/3/library/ipaddress.html)
