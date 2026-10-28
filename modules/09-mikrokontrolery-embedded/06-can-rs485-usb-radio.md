# 09.06 — CAN, RS-485, USB i łączność bezprzewodowa

## Po co to jest

Gdy urządzenia są oddalone o metry lub kilometry, pracują w zakłóconym środowisku albo muszą rozmawiać z komputerem czy chmurą, interfejsy z płytki (UART, SPI, I²C) przestają wystarczać. Interfejsy różnicowe (CAN, RS-485) dominują w motoryzacji i przemyśle, USB — w komunikacji z komputerem, a radio — w IoT.

## Teoria w pigułce

### Interfejsy przewodowe

| Interfejs | Warstwa fizyczna | Topologia | Szybkość / zasięg | Cechy |
|---|---|---|---|---|
| **RS-485** | Różnicowa para skręcona, 120 Ω | Magistrala, do 32 (lub więcej) urządzeń, półdupleks | do ok. 10 Mbit/s na krótkich odcinkach, ok. 100 kbit/s przy 1200 m | Protokół w warstwie wyższej (np. Modbus RTU); terminacja na obu końcach, polaryzacja linii |
| **CAN** | Różnicowa (CAN_H, CAN_L), 120 Ω na obu końcach | Magistrala multimaster | 1 Mbit/s do ok. 40 m, 125 kbit/s do ok. 500 m; CAN FD szybciej w fazie danych | Arbitraż bez kolizji, CRC, potwierdzenia, obsługa błędów sprzętowo |
| **USB** | Różnicowa D+/D−, 90 Ω | Gwiazda z koncentratorami, host steruje | 12 Mbit/s (FS), 480 Mbit/s (HS) | Klasy urządzeń (CDC — wirtualny port szeregowy, HID, MSC), zasilanie z magistrali |
| Ethernet | Transformatory, para różnicowa | Gwiazda (przełącznik) | 10/100/1000 Mbit/s | Stos TCP/IP (moduł [14](../14-sieci-telekomunikacyjne/)) |

**Dlaczego różnicowo:** zakłócenie indukowane w obu przewodach skrętki jest prawie takie samo (sygnał wspólny) i odbiornik różnicowy je odrzuca ([08.07](../08-miernictwo/07-zaklocenia-i-ekranowanie.md)).

**Arbitraż CAN:** stan dominujący (0) „wygrywa” z recesywnym (1). Nadajniki porównują wysłany i odczytany bit — kto wysłał 1, a widzi 0, przegrywa i milknie. Wiadomość o najmniejszym identyfikatorze ma najwyższy priorytet i nie traci czasu na kolizje.

### Łączność bezprzewodowa (IoT)

| Technologia | Pasmo | Zasięg | Przepustowość | Pobór mocy | Zastosowanie |
|---|---|---|---|---|---|
| **BLE** | 2,4 GHz | ~10–100 m | do 1–2 Mbit/s | Bardzo mały | Urządzenia osobiste, smartfony |
| **Wi-Fi** | 2,4 / 5 GHz | ~50 m | dziesiątki–setki Mbit/s | Duży | Bezpośrednio do sieci IP |
| Zigbee / Thread | 2,4 GHz | ~10–100 m (sieć kratowa) | 250 kbit/s | Mały | Automatyka domowa |
| **LoRa / LoRaWAN** | Sub-GHz (868 MHz w UE) | km | 0,3–50 kbit/s | Bardzo mały | Odczyty liczników, czujniki rozproszone |
| NB-IoT / LTE-M | Pasma komórkowe | Sieć operatora | kbit/s – Mbit/s | Mały | Urządzenia mobilne, liczniki |

Kompromis: **zasięg ↔ przepustowość ↔ energia**. Większy zasięg przy tej samej mocy uzyskuje się kosztem szybkości (więcej energii na bit). Ograniczenia regulacyjne pasm nielicencjonowanych: moc, cykl pracy (np. 1% czasu nadawania w części pasma 868 MHz). Szczegóły propagacji — moduł [11](../11-pole-em-linie-anteny/), modulacji — [13](../13-telekomunikacja/).

## Przykład rozwiązany

**Czas ramki CAN** 500 kbit/s, standardowy identyfikator, 8 bajtów danych: ok. 111 bitów bez bitów wypełniających (stuffing), do ok. 135 z nimi → **222–270 µs**. Magistrala z 10 węzłami wysyłającymi po 100 takich ramek na sekundę zajmuje ok. 22–27% pasma — z zapasem na wiadomości zdarzeniowe.

**Terminacja:** magistrala RS-485 lub CAN ma rezystory 120 Ω **tylko na dwóch końcach**. Zmierzona omomierzem rezystancja między liniami przy wyłączonym zasilaniu powinna wynosić ok. 60 Ω.

## Typowe pułapki

- **Terminacja w każdym węźle** albo brak terminacji — odbicia i błędy przy dłuższych przewodach.
- **Długie odgałęzienia (stub)** od magistrali do węzła.
- **RS-485 bez polaryzacji (fail-safe biasing)** — w stanie spoczynku linia „pływa” i odbiorniki widzą śmieci.
- **Brak wspólnej masy lub izolacji** przy dużych odległościach i różnicy potencjałów ziemi.
- **Sterowanie kierunkiem nadajnika RS-485 z opóźnieniem** — ucięty ostatni bajt.
- **Moduł radiowy z anteną schowaną za metalem lub baterią.**

## Ćwiczenie praktyczne

- [ ] Połącz dwa mikrokontrolery przez transceivery CAN (lub RS-485) na kilku metrach skrętki; zmierz przebiegi różnicowe oscyloskopem z terminacją i bez.
- [ ] Uruchom klasę USB CDC (wirtualny port szeregowy) i porównaj przepustowość z UART-em przez przejściówkę.
- [ ] Zmierz prąd modułu BLE lub LoRa w czasie nadawania i oszacuj energię na jedną wiadomość.

## Zadania

1. Oszacuj czas ramki CAN z 8 bajtami przy 500 kbit/s.
2. Jaka jest maksymalna liczba ramek 8-bajtowych na sekundę przy 500 kbit/s (bez wypełnień, 100% obciążenia)? Dlaczego projektuje się obciążenie poniżej ok. 50%?
3. Zmierzona rezystancja między CAN_H i CAN_L przy wyłączonych węzłach wynosi 120 Ω. Co jest nie tak?
4. Czujnik ma wysyłać 20 bajtów co 15 minut z odległości 3 km, na baterii przez 5 lat. Którą technologię wybierzesz i dlaczego?
5. Dlaczego CAN nie potrzebuje oddzielnego mechanizmu wykrywania kolizji jak dawny Ethernet?

<details>
<summary>Odpowiedzi</summary>

1. ok. 222–270 µs
2. ok. 4500 ramek/s; zapas na wypełnienia, retransmisje po błędach i opóźnienia wiadomości o niższym priorytecie
3. Brakuje jednego terminatora (powinno być 60 Ω — dwa 120 Ω równolegle)
4. LoRaWAN (lub NB-IoT, jeśli jest zasięg operatora) — duży zasięg i bardzo mały pobór energii przy małej ilości danych
5. Arbitraż bitowy jest bezstratny — w razie jednoczesnego nadawania wiadomość o wyższym priorytecie przechodzi bez zakłócenia, a pozostali nadawcy wycofują się i ponawiają później
</details>

## Źródła

- [Embedded Systems — Shape the World (J. Valvano)](https://users.ece.utexas.edu/~valvano/Volume1/E-Book/) — komunikacja szeregowa i sieci w systemach wbudowanych
- [Interrupt (blog Memfault)](https://interrupt.memfault.com/) — wpisy o BLE, sieciach i urządzeniach IoT
- Specyfikacje i noty aplikacyjne producentów transceiverów RS-485, CAN i modułów radiowych
