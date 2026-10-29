# 16.08 — Produkcja, montaż i uruchamianie

## Po co to jest

Projekt staje się urządzeniem dopiero po wyprodukowaniu, zmontowaniu i uruchomieniu płytki. Kompletna i jednoznaczna dokumentacja produkcyjna, projektowanie pod montaż (DFM) i pod test (DFT) oraz metodyczne uruchamianie oszczędzają pieniądze, czas i nerwy — a pierwsze włączenie zasilania nie kończy się zapachem spalenizny.

## Teoria w pigułce

### Dokumentacja produkcyjna

| Dla kogo | Pliki |
|---|---|
| **Producent płytek** | Gerber (RS-274X) wszystkich warstw: miedź, maska, opis, pasta, obrys; plik wierceń (Excellon) z rozróżnieniem otworów metalizowanych i niemetalizowanych; opis stosu warstw, grubość, miedź, wykończenie (HASL, ENIG), kolor maski, wymagania impedancji; alternatywnie ODB++ lub IPC-2581 |
| **Montażownia** | **BOM** (oznaczenie, wartość, obudowa, producent i numer katalogowy, zamienniki, DNP); **plik pick-and-place** (współrzędne, obrót, strona); rysunek montażowy; szablon pasty (stencil) |
| **Ty za pół roku** | Schemat w PDF, wersja i data na płytce, dziennik zmian, kod źródłowy oprogramowania testowego |

### Projektowanie pod montaż (DFM)

- Footprinty zgodne z zaleceniami (wielkość padów, pasta na padach termicznych w polach, nie w całości).
- Odstępy między elementami dla automatu, lutowania i poprawek; elementy wysokie nie zasłaniają niskich przy lutowaniu na fali.
- **Termiczne odciążenie** (thermal relief) padów połączonych z dużymi polami miedzi — inaczej trudne do przylutowania.
- Znaczniki referencyjne (fiducials) dla automatu, panelizacja z krawędziami technologicznymi.
- Polaryzacja i pin 1 jednoznacznie oznaczone na opisie.
- Jedna strona montażu SMD, jeśli to możliwe (taniej).

### Projektowanie pod test (DFT)

Punkty testowe na zasilaniach, zegarach, resetach i magistralach (dostęp sondą lub igłami łoża testowego); złącze programowania/debugowania; diody sygnalizacyjne zasilań; rezystory 0 Ω lub zworki do pomiaru prądu poszczególnych bloków; oprogramowanie testowe (test produkcyjny: komunikacja, przetworniki, wejścia/wyjścia).

### Montaż ręczny prototypu

Pasta + szablon + stacja na gorące powietrze lub piec/płyta grzewcza dla SMD; lutownica z cienkim grotem i topnik dla poprawek; mikroskop/lupa do inspekcji (mostki, „nagrobki”, zimne luty). Kolejność: najmniejsze i najniższe elementy, potem wyższe; układy w obudowach QFN — kontrola zwarć pod spodem (pomiar rezystancji między szynami).

### Uruchamianie krok po kroku

1. **Kontrola wizualna** i pomiar rezystancji między szynami zasilania a masą (brak zwarć).
2. **Zasilanie z zasilacza z ograniczeniem prądu** (najpierw niski limit), obserwacja poboru.
3. Sprawdzenie każdej szyny zasilania (napięcie, tętnienia oscyloskopem z krótką masą — [08.03](../08-miernictwo/03-oscyloskop.md)); temperatura elementów (palec/termowizja).
4. Mikrokontroler: połączenie z debugerem, zegar (pin MCO), prosty program (miganie diodą).
5. Kolejne bloki pojedynczo z oprogramowaniem testowym: interfejsy, przetworniki, radio.
6. **Dziennik uruchomienia:** każdy problem, przyczyna, poprawka (do kolejnej wersji płytki).
7. Pomiary weryfikacyjne względem wymagań (moduł [18](../18-projekt-dyplomowy/)).

## Przykład rozwiązany

**Szacowanie kosztu prototypu i wpływu decyzji:**
- Płytka 4-warstwowa 50 × 50 mm, 5 sztuk — koszt zależy głównie od liczby warstw, rozmiaru, minimalnych ścieżek/otworów i czasu realizacji; 2 → 4 warstwy często podnosi koszt prototypu kilkukrotnie, ale rozwiązuje wiele problemów SI/EMC.
- Montaż SMD obustronny vs jednostronny — w montażowniach zwykle istotnie drożej (dwa przejścia przez proces).
- Przejście z obudów 0201 na 0402/0603 — prostsze montowanie ręczne i poprawki prototypu.

**Pierwsze włączenie:** limit prądu 100 mA przy oczekiwanym poborze 25 mA; zmierzone 100 mA i zasilacz w ograniczeniu → zwarcie lub odwrotnie wlutowany element → wyłączyć, szukać (termowizja przy niskim prądzie lub pomiar spadków napięć na ścieżkach).

## Typowe pułapki

- **Brak warstwy obrysu lub sprzeczne wymiary** w plikach dla producenta.
- **BOM bez numerów katalogowych** („kondensator 10 µF”) — montażownia dobierze cokolwiek (napięcie, dielektryk, obudowa).
- **Rotacje w pliku pick-and-place** niezgodne z konwencją montażowni — diody i układy obrócone.
- **Pierwsze włączenie bez ograniczenia prądu.**
- **Uruchamianie wszystkiego naraz** — gdy nie działa, nie wiadomo co.

## Ćwiczenie praktyczne

- [ ] Wygeneruj z KiCad komplet plików produkcyjnych (Gerber, wiercenia, BOM, pick-and-place) dla płytki z projektu modułowego; otwórz Gerbery w przeglądarce Gerberów i porównaj z projektem.
- [ ] Przygotuj BOM z numerami katalogowymi i zamiennikami; sprawdź dostępność.
- [ ] Napisz procedurę uruchomienia płytki (lista kroków, oczekiwane wartości, limity prądu) i dziennik uruchomienia.

## Ćwiczenie komputerowe

Prosta kontrola spójności BOM i pliku pick-and-place (każdy element z BOM ma położenie, brak duplikatów, elementy DNP pominięte):

```python
import csv, io

bom = io.StringIO("""Ref,Value,Footprint,MPN,DNP
C1,100nF,0402,GRM155R71C104KA88,
C2,10uF,0805,GRM21BR61E106KA73,
R1,10k,0402,RC0402FR-0710KL,
R2,0R,0402,,DNP
U1,STM32G0,LQFP-48,STM32G0B1CET6,
""")
pnp = io.StringIO("""Ref,PosX,PosY,Rot,Side
C1,10.2,5.1,90,top
C2,12.0,5.1,0,top
U1,20.0,20.0,0,top
R1,8.0,7.5,180,top
""")
B = {r['Ref']: r for r in csv.DictReader(bom)}
P = {r['Ref']: r for r in csv.DictReader(pnp)}
to_place = {k for k, v in B.items() if v['DNP'] != 'DNP'}
print("brak w pick-and-place:", sorted(to_place - P.keys()) or "—")
print("w pick-and-place, a nie w BOM:", sorted(P.keys() - B.keys()) or "—")
print("bez numeru katalogowego (MPN):", sorted(k for k in to_place if not B[k]['MPN']) or "—")
print("elementy DNP:", sorted(set(B) - to_place))
```

## Zadania

1. Wymień pliki, które wyślesz producentowi płytki 4-warstwowej z kontrolowaną impedancją.
2. Dlaczego pad połączony z polem miedzi wymaga odciążenia termicznego?
3. Zaprojektuj procedurę pierwszego włączenia płytki z przetwornicą 12 → 3,3 V, mikrokontrolerem i modułem radiowym.
4. Jakie elementy DFT dodasz do projektu rejestratora?
5. Płytka po włączeniu pobiera prąd ograniczenia zasilacza. Jak znajdziesz zwarcie bez uszkodzenia kolejnych elementów?

<details>
<summary>Odpowiedzi</summary>

1. Gerbery wszystkich warstw (miedź L1–L4, maska, opis, obrys, pasta jeśli szablon), wiercenia PTH/NPTH, opis stosu z wymaganą impedancją i ścieżkami testowymi (lub listą sieci z impedancją), grubość, miedź, wykończenie, kolor; ewentualnie rysunek wymiarowy
2. Pole miedzi odprowadza ciepło grota/pieca — lut nie osiąga temperatury (zimny lut, długie grzanie elementu); odciążenie (kilka wąskich mostków) ogranicza odpływ ciepła przy zachowaniu połączenia elektrycznego
3. Kontrola wizualna i rezystancji szyn; zasilacz z limitem ok. 50–100 mA; sprawdzenie 12 V i 3,3 V, tętnienia; temperatura; dopiero potem debuger i prosty program; radio na końcu (z anteną lub obciążeniem 50 Ω)
4. Punkty testowe 12 V, 3,3 V, masy, zegara, resetu, linii UART i I²C; złącze SWD; zworka/rezystor 0 Ω do pomiaru prądu radia i części analogowej; diody zasilania; firmware testowy
5. Zasilanie z małym limitem prądu (np. 0,5–1 A przy niskim napięciu, np. 1 V) i termowizja/dotyk w poszukiwaniu ciepłego miejsca; pomiar spadków napięcia na płaszczyznach miliwoltomierzem (prąd płynie w stronę zwarcia); odlutowanie podejrzanych elementów po kolei
</details>

## Źródła

- [KiCad — dokumentacja](https://docs.kicad.org/) — eksport plików produkcyjnych, BOM, pliki pozycji, przeglądarka Gerberów
- [Phil's Lab — projektowanie PCB w KiCad](https://www.youtube.com/results?search_query=Phil%27s+Lab+KiCad+PCB+design) — przygotowanie do produkcji i uruchamianie płytek
- H. Scott — *Designing Electronics That Work* (płatna) — produkcja, uruchamianie, testowanie
