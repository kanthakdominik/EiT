# 14.07 — Sieci komórkowe i IoT

## Po co to jest

Sieci komórkowe łączą miliardy telefonów i coraz więcej urządzeń — od liczników po samochody. Ich architektura (sieć radiowa + sieć rdzeniowa) rozwiązuje problemy, których nie ma w sieci przewodowej: ruch użytkownika między komórkami, dzielenie widma, oszczędzanie baterii, uwierzytelnienie abonenta. Obok nich działają sieci IoT krótkiego i dalekiego zasięgu, z których wybór jest jedną z pierwszych decyzji przy projektowaniu urządzenia.

## Teoria w pigułce

### Koncepcja komórkowa

Obszar podzielony na komórki obsługiwane przez stacje bazowe; te same częstotliwości używane ponownie w odległych komórkach (w 4G/5G — zwykle we wszystkich, z koordynacją zakłóceń). Mniejsze komórki → większa pojemność na km². **Przełączanie (handover)** utrzymuje połączenie przy przejściu między komórkami; **lokalizacja i przywoływanie (paging)** pozwalają znaleźć uśpiony terminal.

### Generacje

| Generacja | Dostęp radiowy | Rdzeń | Charakter |
|---|---|---|---|
| 2G (GSM) | TDMA/FDMA, GMSK | Komutacja łączy (+ GPRS) | Głos, SMS |
| 3G (UMTS) | WCDMA | Łączy + pakietów | Dane mobilne |
| **4G (LTE)** | OFDMA w dół, SC-FDMA w górę, MIMO | **EPC** — tylko pakiety (głos jako VoLTE) | Szerokopasmowy Internet mobilny |
| **5G (NR)** | OFDMA, elastyczne odstępy podnośnych $15\cdot 2^\mu$ kHz, pasma < 6 GHz i fale milimetrowe, masywne MIMO i formowanie wiązki | **5GC** — architektura usługowa, chmurowa, przekroje sieci | eMBB (przepływność), URLLC (niskie opóźnienia), mMTC (masowe IoT) |

### Architektura LTE/5G

- **Sieć radiowa (RAN):** stacja bazowa (eNodeB w LTE, gNodeB w 5G) — harmonogramowanie zasobów (bloki podnośnych × czas co 1 ms lub krócej), adaptacja modulacji i kodowania, HARQ, MIMO. W 5G możliwy podział na jednostki CU/DU/RU, Open RAN.
- **Fronthaul/backhaul:** światłowód lub radiolinie do sieci rdzeniowej; synchronizacja czasu (PTP, GNSS) — kluczowa dla TDD.
- **Rdzeń (EPC / 5GC):** zarządzanie mobilnością i sesjami (MME / AMF, SMF), bramy do Internetu (S/P-GW / UPF), baza abonentów (HSS / UDM), uwierzytelnienie i szyfrowanie (karta SIM/eSIM z kluczem — [14.08](08-teoria-ruchu-i-bezpieczenstwo.md)).
- **Stos protokołów radiowych:** PHY → MAC (harmonogramowanie, HARQ) → RLC (segmentacja, ARQ) → PDCP (szyfrowanie, kompresja nagłówków) → RRC (sterowanie).

### Sieci IoT

| Technologia | Zasięg | Przepływność | Topologia | Energia | Uwagi |
|---|---|---|---|---|---|
| **BLE** | 10–100 m | do 2 Mbit/s | Gwiazda, mesh | Bardzo mała | Smartfon jako brama; profile GATT |
| **Zigbee / Thread** | 10–100 m na skok | 250 kbit/s | Mesh (IEEE 802.15.4) | Mała | Automatyka domowa; Thread oparty na IPv6, standard Matter |
| **Wi-Fi** (w tym HaLow 802.11ah) | 50 m (km dla HaLow) | Mbit/s | Gwiazda | Duża (HaLow — mniejsza) | Bezpośrednio IP |
| **LoRaWAN** | km | 0,3–50 kbit/s | Gwiazda gwiazd (bramy → serwer sieci) | Bardzo mała | Pasma nielicencjonowane, ograniczenie cyklu pracy, klasy A/B/C urządzeń |
| **NB-IoT / LTE-M** | Zasięg sieci komórkowej (+ ok. 20 dB lepszy zasięg z powtórzeniami) | kbit/s – ok. 1 Mbit/s | Komórkowa | Mała (tryby PSM, eDRX) | Pasma licencjonowane, zarządzanie SIM |

**Protokoły aplikacyjne IoT:** MQTT (publikacja–subskrypcja przez broker, nad TCP), CoAP (REST nad UDP), LwM2M (zarządzanie urządzeniami).

**Wybór technologii:** zasięg, ilość i częstotliwość danych, budżet energii (lata na baterii?), koszt abonamentu i infrastruktury, opóźnienia, mobilność, czy jest smartfon/brama w pobliżu.

## Przykład rozwiązany

**Liczniki wody w mieście:** 20 bajtów raz na godzinę, zasięg z piwnic, 10 lat na baterii.
- BLE/Zigbee — za mały zasięg bez gęstej sieci bram.
- Wi-Fi — za duży pobór, brak zasięgu w piwnicach.
- **LoRaWAN** (własna sieć bram) lub **NB-IoT** (sieć operatora, lepszy zasięg w budynkach dzięki powtórzeniom) — obie spełniają wymagania; wybór zależy od kosztów abonamentu vs infrastruktury.

**Czas nadawania LoRa:** ramka 20 B przy wolnym ustawieniu (SF12, 125 kHz) trwa ok. 1,32 s — przy limicie 1% cyklu pracy urządzenie może nadawać najwyżej ok. 27 razy na godzinę; przy SF7 — ok. 57 ms (ok. 600 ramek/h) (z budżetem zasięgu mniejszym o ok. 12–13 dB).

## Typowe pułapki

- **Wybór technologii po przepływności zamiast po energii i zasięgu.**
- **Ignorowanie limitów cyklu pracy** w pasmach nielicencjonowanych.
- **Zakładanie stałego połączenia** urządzenia NB-IoT/LTE-M — w trybie PSM jest nieosiągalne do czasu wybudzenia.
- **Brak obsługi zmiany adresu IP** (NAT operatora, CGNAT) — komunikację inicjuje urządzenie.
- **Mylenie zasięgu w terenie otwartym z zasięgiem w budynkach.**

## Ćwiczenie komputerowe

Czas nadawania ramki LoRa (wzór z dokumentacji producenta układów, tryb z nagłówkiem jawnym) i liczba dozwolonych transmisji przy cyklu pracy 1%:

```python
import math

def lora_airtime(payload, sf, bw=125e3, cr=1, preamble=8, crc=True, header=True):
    ldro = 1 if (sf >= 11 and bw == 125e3) else 0
    Ts = 2**sf/bw
    n = 8 + max(math.ceil((8*payload - 4*sf + 28 + 16*crc - 20*(not header))/(4*(sf - 2*ldro)))*(cr + 4), 0)
    return (preamble + 4.25)*Ts + n*Ts

for sf in [7, 9, 12]:
    t = lora_airtime(20, sf)
    print(f"SF{sf:2d}: czas ramki 20 B = {t*1e3:7.1f} ms, maks. {3600*0.01/t:6.1f} ramek/h przy 1% cyklu pracy")
for mu in range(4):
    print(f"5G numerologia mu={mu}: odstęp podnośnych {15*2**mu} kHz, szczelina {1/2**mu:.3f} ms")
```

## Zadania

1. Wymień trzy główne klasy usług 5G i przykład zastosowania każdej.
2. Odstęp podnośnych 5G dla numerologii μ = 3. Do jakich pasm się go stosuje i dlaczego?
3. Urządzenie ma wysyłać 1 kB co minutę z samochodu w ruchu. Którą technologię wybierzesz?
4. Dlaczego Thread (i Matter) opiera się na IPv6?
5. Policz czas nadawania ramki LoRa 50 B przy SF10 (snippet) i liczbę ramek na godzinę przy 1% cyklu pracy.

<details>
<summary>Odpowiedzi</summary>

1. eMBB — szybki Internet mobilny/wideo; URLLC — sterowanie przemysłowe, pojazdy; mMTC — masowe czujniki IoT
2. 120 kHz; fale milimetrowe — większe przesunięcia Dopplera i szum fazowy wymagają szerszych podnośnych, krótsze symbole dają mniejsze opóźnienia (a mniejsze rozmycie opóźnień w małych komórkach pozwala na krótki prefiks)
3. LTE-M (mobilność, przepływność, przełączanie między komórkami, możliwy głos) — NB-IoT gorzej obsługuje ruch i przełączanie
4. Każde urządzenie ma adres IP i może być adresowane end-to-end bez bram tłumaczących protokoły; standardowe narzędzia sieci IP; duża przestrzeń adresowa i autokonfiguracja
5. Ok. 0,62 s; ok. 58 ramek/h
</details>

## Źródła

- [Computer Networks: A Systems Approach — Peterson, Davie](https://github.com/SystemsApproach/book) — sieci bezprzewodowe i komórkowe
- [Kurose — wykłady wideo](https://www.youtube.com/results?search_query=Jim+Kurose+Computer+Networking+Top-Down+Approach) — sieci bezprzewodowe i mobilne (4G/5G)
- [PySDR](https://pysdr.org) — warstwa fizyczna systemów radiowych w praktyce
- Specyfikacje 3GPP (seria 36 — LTE, 38 — 5G NR), specyfikacja LoRaWAN (LoRa Alliance), noty producentów układów LoRa (wzór na czas nadawania)
