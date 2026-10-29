# 14.06 — Sieci dostępowe i szkieletowe

## Po co to jest

Sieć operatora składa się z dwóch bardzo różnych części: sieci dostępowej („ostatnia mila” do domu lub firmy — tam jest najwięcej kosztów i ograniczeń fizycznych) oraz sieci szkieletowej (gruba rura między miastami i krajami). Znajomość technologii dostępowych pozwala ocenić, co realnie da się uzyskać na danym przyłączu, a sieci szkieletowej — jak operatorzy przenoszą terabity z niezawodnością „pięciu dziewiątek”.

## Teoria w pigułce

### Technologie dostępowe

| Technologia | Medium | Przepływność (rząd) | Zasada |
|---|---|---|---|
| **xDSL** (ADSL2+, VDSL2, G.fast) | Para miedziana | od kilku–kilkunastu Mbit/s (ADSL na kilku km) do 100+ Mbit/s (VDSL2 < 1 km) i ok. 1 Gbit/s (G.fast < 100–200 m) | OFDM (DMT) — tysiące podnośnych o modulacji dobieranej do SNR każdej; **wektoryzacja** kasuje przesłuchy między parami |
| **Sieci kablowe** (DOCSIS 3.0/3.1/4.0) | Sieć hybrydowa światłowód–koncentryk (HFC) | od setek Mbit/s do kilku–10 Gbit/s (współdzielone w segmencie) | Kanały QAM, w DOCSIS 3.1 OFDM do 4096-QAM |
| **FTTH — PON** (GPON, XGS-PON) | Światłowód jednomodowy z pasywnym rozgałęźnikiem | 2,5/1,25 Gbit/s (GPON), 10/10 Gbit/s (XGS-PON) — współdzielone | Jedno włókno od centrali (OLT) do 32–64 terminali (ONT); downstream rozgłoszeniowy (szyfrowany), upstream TDMA |
| FTTH punkt–punkt | Osobne włókno | 1–10 Gbit/s | Ethernet |
| Dostęp radiowy stacjonarny (FWA) | LTE/5G, radiolinie | dziesiątki–setki Mbit/s | Tam, gdzie kabel jest za drogi |
| Satelita (GEO, LEO) | Radio | dziesiątki–setki Mbit/s | GEO: RTT ok. 600 ms; LEO: RTT rzędu 30–50 ms |

**Ograniczenia DSL:** tłumienie pary rośnie z częstotliwością i długością, przesłuchy (NEXT/FEXT) z innych par w kablu — szybkość spada gwałtownie z odległością. Stąd architektury FTTC/FTTB (światłowód do szafki lub budynku + krótki odcinek miedzi).

**Budżet PON:** rozgałęźnik 1:N ma tłumienie co najmniej $10\log N$ (1:32 → 15 dB, w praktyce ok. 17 dB) + włókno i złącza; klasy optyczne (np. B+, C+) określają dopuszczalne tłumienie (ok. 28–32 dB) — stąd typowe zasięgi do 20 km. Długości fal: 1490 nm w dół, 1310 nm w górę (GPON), 1577/1270 nm (XGS-PON), 1550 nm — telewizja RF overlay.

### Sieć szkieletowa i metro

- **Transport optyczny:** DWDM ([14.02](02-warstwa-fizyczna-i-swiatlowody.md)), **OTN** (ITU-T G.709 — „kontenery” z FEC i nadzorem), ROADM — rekonfigurowalne multipleksery optyczne kierujące długości fali bez zamiany na sygnał elektryczny.
- **SDH/SONET** — dawny standard synchronicznej multipleksacji (STM-1 = 155,52 Mbit/s, STM-16 ≈ 2,5 Gbit/s, STM-64 ≈ 10 Gbit/s), wciąż w starszych sieciach; synchronizacja i ochrona w pierścieniach (przełączenie < 50 ms).
- **MPLS** — przełączanie etykiet w sieci IP: szybkie przekazywanie, inżynieria ruchu, VPN-y dla klientów (L2/L3), szybkie przełączanie awaryjne; nowsze: Segment Routing.
- **Punkty wymiany ruchu (IXP)** i połączenia między operatorami (BGP — [14.04](04-ip-adresacja-i-routing.md)).
- **Niezawodność:** dostępność $A = MTBF/(MTBF + MTTR)$; „pięć dziewiątek” (99,999%) to ok. 5 minut przestoju rocznie; uzyskuje się ją nadmiarowością (dwie niezależne trasy kabla, ochrona 1+1).

### Sieci definiowane programowo

**SDN** — oddzielenie płaszczyzny sterowania (logicznie scentralizowany kontroler) od płaszczyzny przekazywania; **NFV** — funkcje sieciowe (zapora, router, rdzeń sieci komórkowej) jako oprogramowanie na zwykłych serwerach. Podstawa nowoczesnych sieci operatorskich i 5G.

## Przykład rozwiązany

**Budżet GPON:** OLT +3 dBm (klasa B+), czułość ONT −27 dBm → dostępne 30 dB (zgodnie z klasą B+ 28 dB do zaplanowania + zapas). Rozgałęźnik 1:32 — 17 dB, 15 km włókna przy 1490 nm (0,3 dB/km) — 4,5 dB, 4 złącza po 0,5 dB — 2 dB, spawy 1 dB → 24,5 dB; margines 3 dB → 27,5 dB ≤ 28 dB — mieści się.

**Przepływność na abonenta:** XGS-PON 10 Gbit/s, 32 abonentów → gwarantowane minimum ok. 300 Mbit/s każdemu, ale dzięki multipleksacji statystycznej pojedynczy abonent zwykle dostaje dużo więcej.

**Dostępność:** łącze o MTBF = 4000 h i MTTR = 8 h: $A = 4000/4008 \approx 99\text{,}8\%$ — ok. 17,5 h przestoju rocznie. Dwa niezależne łącza równolegle: niedostępność $(0\text{,}002)^2 = 4\cdot 10^{-6}$ → 99,9996% (ok. 2 min rocznie).

## Typowe pułapki

- **Utożsamianie przepływności nominalnej z gwarantowaną** — w PON i DOCSIS medium jest współdzielone.
- **Szacowanie DSL bez długości i jakości pary** — dwukrotna różnica odległości to wielokrotna różnica szybkości.
- **Redundancja „na papierze”** — dwa włókna w tym samym kanale kablowym ulegną jednej koparce.
- **Brak planu długości fal i tłumików w PON** — przesterowanie bliskich ONT.

## Ćwiczenie komputerowe

Budżet PON dla różnych współczynników podziału i dostępność łączy nadmiarowych:

```python
import numpy as np

def pon_budget(split, L_km, alpha=0.3, n_conn=4, l_conn=0.5, splices=1.0, excess=2.0, margin=3.0):
    return 10*np.log10(split) + excess + L_km*alpha + n_conn*l_conn + splices + margin

for split in [16, 32, 64]:
    for L in [10, 20]:
        b = pon_budget(split, L)
        print(f"1:{split:<2}  {L:2d} km: {b:5.1f} dB  {'OK (B+ 28 dB)' if b <= 28 else ('OK (C+ 32 dB)' if b <= 32 else 'za dużo')}")

A1 = 4000/(4000 + 8)
for n in [1, 2, 3]:
    A = 1 - (1 - A1)**n
    print(f"{n} niezależne łącza: dostępność {A*100:.5f}%, przestój {(1 - A)*8760*60:.1f} min/rok")
```

## Zadania

1. Tłumienie rozgałęźnika idealnego 1:64? Jaki zostaje budżet na włókno przy klasie 28 dB, złączach 2 dB, spawach 1 dB, marginesie 3 dB i nadmiarze rozgałęźnika 2 dB? Jaki zasięg przy 0,35 dB/km?
2. Dlaczego VDSL2 osiąga dużo większe szybkości niż ADSL2+, ale tylko na krótkich pętlach?
3. Ile wynosi przepływność STM-4?
4. Wymagana dostępność 99,99%. Ile to minut przestoju rocznie?
5. Dlaczego w PON upstream wymaga TDMA, a downstream nie?

<details>
<summary>Odpowiedzi</summary>

1. ≈ 18,1 dB; pozostaje $28 - 18\text{,}1 - 2 - 2 - 1 - 3 \approx 1\text{,}9$ dB → ok. 5 km (dlatego 1:64 stosuje się na krótkich odcinkach lub z wyższą klasą optyki)
2. Wykorzystuje szersze pasmo (do 17–35 MHz zamiast 2,2 MHz); tłumienie pary przy wyższych częstotliwościach szybko rośnie z długością, więc wysokie podnośne są użyteczne tylko na krótkich pętlach
3. $4\cdot 155\text{,}52 = 622\text{,}08$ Mbit/s
4. ok. 52,6 min/rok
5. W dół OLT nadaje do wszystkich (rozgłoszenie, każdy ONT wybiera swoje dane); w górę sygnały wielu ONT łączą się w jednym włóknie — muszą nadawać w przydzielonych szczelinach czasowych, inaczej by się nakładały
</details>

## Źródła

- [The Fiber Optic Association — Guide to Fiber Optics](https://www.thefoa.org/tech/ref/) — FTTH i PON, budżety łączy
- [Computer Networks: A Systems Approach — Peterson, Davie](https://github.com/SystemsApproach/book) — sieci dostępowe, SDN
- [Kurose — wykłady wideo](https://www.youtube.com/results?search_query=Jim+Kurose+Computer+Networking+Top-Down+Approach) — sieci dostępowe, struktura Internetu
