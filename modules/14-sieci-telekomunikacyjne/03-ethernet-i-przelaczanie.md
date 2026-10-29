# 14.03 — Ethernet, przełączanie i VLAN

## Po co to jest

Ethernet jest wszędzie: w domu, w biurze, w centrach danych, w samochodach i fabrykach, a nawet w łączach do stacji bazowych. Zrozumienie ramki, przełączania i sieci wirtualnych (VLAN) pozwala projektować sieci lokalne, diagnozować problemy (pętle, burze rozgłoszeniowe, zła konfiguracja portów) i rozumieć, co robi przełącznik w sprzęcie.

## Teoria w pigułce

### Ramka Ethernet II

| Pole | Długość | Opis |
|---|---|---|
| Preambuła + SFD | 8 B | Synchronizacja (warstwa fizyczna) |
| Adres docelowy MAC | 6 B | Unicast, multicast, broadcast (FF:FF:FF:FF:FF:FF) |
| Adres źródłowy MAC | 6 B | 3 B identyfikator producenta (OUI) + 3 B numer |
| (Znacznik 802.1Q) | (4 B) | VLAN ID (12 bitów) + priorytet (3 bity) |
| EtherType | 2 B | 0x0800 IPv4, 0x86DD IPv6, 0x0806 ARP |
| Dane | 46–1500 B | (do ok. 9000 B — ramki jumbo) |
| FCS | 4 B | CRC-32 ([13.06](../13-telekomunikacja/06-kodowanie-kanalowe.md)) |
| Przerwa międzyramkowa | 12 B | Odstęp na łączu |

Minimalna ramka 64 B (od adresu do FCS) — dawniej wymagana do wykrywania kolizji w CSMA/CD; dziś łącza są pełnodupleksowe przez przełączniki i kolizji nie ma.

Narzut: przy 1500 B danych na łączu zajęte jest $1500 + 38 = 1538$ B → sprawność 97,5%. Przy ramkach 64 B łącze 1 Gbit/s przenosi maksymalnie ok. 1,49 mln ramek/s.

### Warstwa fizyczna Ethernetu

| Standard | Medium | Kodowanie / modulacja |
|---|---|---|
| 100BASE-TX | 2 pary kat. 5 | 4B5B + MLT-3 |
| 1000BASE-T | 4 pary kat. 5e, pełny dupleks na każdej parze | PAM-5, kasowanie echa |
| 10GBASE-T | 4 pary kat. 6A | PAM-16 (DSQ128), LDPC |
| 10GBASE-SR/LR | Światłowód MMF / SMF | 64b/66b |
| 100G/400G | Światłowody, wiele torów | PAM-4, FEC |

Transformatory separujące na każdym porcie (izolacja galwaniczna), **PoE** — zasilanie przez skrętkę (do ok. 15–90 W według odmiany).

### Przełączanie

Przełącznik **uczy się** adresów MAC: zapisuje adres źródłowy każdej ramki z numerem portu (tablica MAC/CAM). Ramkę do znanego adresu wysyła tylko na właściwy port, do nieznanego lub rozgłoszeniowego — na wszystkie pozostałe (flooding). Przełączanie w sprzęcie (ASIC) z pełną szybkością łączy; tryby store-and-forward (sprawdza FCS) i cut-through (mniejsze opóźnienie).

**Pętle:** dwa połączenia między przełącznikami tworzą pętlę — ramki rozgłoszeniowe krążą bez końca (burza rozgłoszeniowa). **STP/RSTP** (Spanning Tree) wyłącza nadmiarowe łącza, zostawiając drzewo, i włącza je przy awarii. Agregacja łączy (LACP) łączy kilka portów w jeden logiczny.

### VLAN

Sieci wirtualne dzielą jeden fizyczny przełącznik na kilka niezależnych domen rozgłoszeniowych. Port **dostępowy** (access) należy do jednego VLAN-u, port **trunk** przenosi wiele VLAN-ów ze znacznikiem 802.1Q. Ruch między VLAN-ami wymaga routera (lub przełącznika warstwy 3). Zastosowania: separacja działów, telefonów IP, urządzeń IoT, sieci gości.

### Ethernet przemysłowy i motoryzacyjny

Ethernet czasu rzeczywistego (PROFINET, EtherCAT), TSN (Time-Sensitive Networking — gwarantowane opóźnienia), synchronizacja czasu PTP (IEEE 1588), Automotive Ethernet (100BASE-T1 — jedna para).

## Przykład rozwiązany

Sieć: przełącznik z 3 hostami A (port 1), B (port 2), C (port 3); tablica MAC pusta.

1. A wysyła do B: przełącznik zapisuje A → port 1; B nieznany → ramka idzie na porty 2 i 3.
2. B odpowiada A: zapis B → port 2; A znany → tylko port 1.
3. Kolejne ramki A ↔ B nie trafiają do C.
4. Przepływność przełącznika 24 × 1 Gbit/s pełny dupleks: 48 Gbit/s łącznie; przy ramkach 64 B ok. 35,7 mln ramek/s.

## Typowe pułapki

- **Niezgodność trybu dupleksu** (jedna strona pełny, druga pół) — straty i spowolnienie przy dużym ruchu.
- **Pętla bez STP** — sieć przestaje działać w kilka sekund.
- **Ramki z VLAN-em na porcie dostępowym** albo brak VLAN-u natywnego zgodnego po obu stronach trunka.
- **Kabel za długi lub złej kategorii** — działa przy 100 Mbit/s, nie działa przy 1 Gbit/s.
- **Ramki jumbo tylko w części ścieżki** — fragmentacja lub odrzucanie.

## Ćwiczenie komputerowe

Symulacja przełącznika uczącego się i sprawdzenie CRC-32 ramki:

```python
import zlib

class Switch:
    def __init__(self, nports): self.table, self.n = {}, nports
    def receive(self, port, src, dst):
        self.table[src] = port
        out = [self.table[dst]] if dst in self.table and dst != 'FF' else [p for p in range(1, self.n + 1) if p != port]
        return [p for p in out if p != port]

sw = Switch(4)
for port, src, dst in [(1, 'A', 'B'), (2, 'B', 'A'), (1, 'A', 'B'), (3, 'C', 'FF'), (4, 'D', 'C')]:
    print(f"{src}->{dst} z portu {port}: wysłano na porty {sw.receive(port, src, dst)}; tablica {sw.table}")

frame = bytes.fromhex('ffffffffffff' '001122334455' '0806') + bytes(46)
fcs = zlib.crc32(frame) & 0xFFFFFFFF
print(f"FCS (CRC-32) = 0x{fcs:08X}")
corrupted = bytearray(frame); corrupted[20] ^= 0x01
print("błąd jednego bitu wykryty:", zlib.crc32(bytes(corrupted)) & 0xFFFFFFFF != fcs)
for payload in [46, 512, 1500, 9000]:
    print(f"dane {payload:5d} B: sprawność {payload/(payload + 38)*100:5.1f}%, "
          f"ramek/s przy 1 Gbit/s = {1e9/((payload + 38)*8)/1e6:.3f} mln")
```

## Zadania

1. Policz maksymalną liczbę ramek 64 B na sekundę przy 10 Gbit/s.
2. Ile VLAN-ów można zdefiniować znacznikiem 802.1Q? Dlaczego nie wszystkie są używane?
3. Host w VLAN 10 wysyła ramkę rozgłoszeniową. Które porty przełącznika ją otrzymają?
4. Dwa przełączniki połączono dwoma kablami bez STP. Opisz, co się stanie po wysłaniu jednej ramki ARP.
5. Dlaczego 1000BASE-T potrzebuje kasowania echa?

<details>
<summary>Odpowiedzi</summary>

1. $10^{10}/(84\cdot 8) \approx 14\text{,}88$ mln ramek/s
2. $2^{12} = 4096$; wartości 0 i 4095 zarezerwowane — 4094 użytecznych (dla większej skali: Q-in-Q, VXLAN)
3. Wszystkie porty dostępowe VLAN 10 i porty trunk przenoszące VLAN 10 (poza portem źródłowym)
4. Ramka rozgłoszeniowa jest przekazywana w kółko w obu kierunkach i powielana — burza rozgłoszeniowa wysyca łącza i procesory, tablice MAC „skaczą” między portami
5. Każda para przenosi sygnał jednocześnie w obu kierunkach; odbiornik musi odjąć od sygnału na linii własny nadawany sygnał i jego odbicia (echo)
</details>

## Źródła

- [Computer Networks: A Systems Approach — Peterson, Davie](https://github.com/SystemsApproach/book) — rozdziały o łączach bezpośrednich i przełączaniu (Ethernet, mosty, STP, VLAN)
- [Kurose — wykłady wideo](https://www.youtube.com/results?search_query=Jim+Kurose+Computer+Networking+Top-Down+Approach) — warstwa łącza danych
- [Wireshark — dokumentacja](https://www.wireshark.org/docs/) — analiza ramek Ethernet i znaczników VLAN
