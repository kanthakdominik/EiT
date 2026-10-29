# 18.04 — Dokumentacja i prezentacja

## Po co to jest

Dokumentacja odpowiada na pytanie: czy ktoś inny — albo ty za rok — odtworzy, zrozumie i rozwinie urządzenie? W pracy inżynierskiej to także podstawa oceny. Dobra dokumentacja nie jest opisem „co zrobiłem po kolei”, tylko uporządkowanym dowodem: wymagania, decyzje z uzasadnieniem, realizacja, weryfikacja, wnioski.

## Teoria w pigułce

### Zestaw dokumentów

| Dokument | Zawartość |
|---|---|
| **Raport techniczny** | Struktura w [szablonie](szablony/raport-techniczny.md): wymagania, architektura, obliczenia, realizacja, weryfikacja, wnioski |
| Schemat (PDF) | Czytelny, z notatkami doboru, wersja i data |
| Płytka | Rysunek montażowy, stos warstw, pliki produkcyjne w repozytorium |
| BOM | Z numerami katalogowymi i zamiennikami |
| Oprogramowanie / HDL | Repozytorium z README (budowanie, programowanie), komentarze przy nieoczywistych miejscach, testy |
| Wyniki pomiarów | Surowe dane, skrypty, wykresy — powtarzalne |
| Instrukcja użytkownika | Uruchomienie, obsługa, ograniczenia, bezpieczeństwo |
| Dziennik uruchomienia i lista zmian | Problemy i poprawki — materiał do wersji 2 |

### Pisanie raportu — zasady

- **Od ogółu do szczegółu:** streszczenie (cel, wynik, najważniejsze liczby) na początku.
- **Każda decyzja z uzasadnieniem:** obliczenie, symulacja, odwołanie do noty, porównanie wariantów.
- **Liczby z jednostkami i niepewnościami;** wzory z oznaczeniami; rysunki z podpisami i osiami.
- **Wyniki zestawione z wymaganiami** (macierz zgodności) i z przewidywaniami (obliczenia, symulacje); różnice wyjaśnione.
- **Wnioski konkretne:** co działa, czego nie spełniono i dlaczego, co zmienić w wersji 2.
- Źródła: noty katalogowe, normy, podręczniki — z odnośnikami.

### Prezentacja i demonstracja

Ok. 15–20 minut: problem i wymagania (2 min), architektura i kluczowe decyzje (5 min), realizacja (3 min), weryfikacja — wykresy z wymaganiami (5 min), wnioski (2 min), **demonstracja na żywo** (z planem B — nagraniem). Jeden slajd = jedna myśl; wykresy zamiast tabel liczb; pokazuj problemy i jak je rozwiązano — to przekonuje bardziej niż „wszystko działało”.

## Przykład rozwiązany

**Fragment raportu — uzasadnienie doboru (wzorzec):**

> *Przetwornica obniżająca 12 → 3,3 V.* Zgodnie z bilansem mocy (tab. 3) maksymalny prąd szyny 3,3 V wynosi 175 mA, a średni 23 mA. Stabilizator LDO traciłby przy 12 V wejścia do $(12 - 3\text{,}3)\cdot 0\text{,}175 \approx 1\text{,}5$ W (temperatura złącza w obudowie SOT-223 ok. 140 °C przy 50 °C otoczenia — niedopuszczalne), dlatego wybrano przetwornicę synchroniczną z trybem oszczędnym (sprawność 88% przy 175 mA i 80% przy 20 mA według noty, sprawdzone pomiarem — rozdz. 7.2). Tor analogowy zasilany jest przez filtr LC i osobny LDO 3,0 V (PSRR 60 dB przy 1 kHz) dla ograniczenia tętnień przetwornicy w paśmie pomiaru.

Taki akapit odpowiada na pytania „dlaczego?”, „na jakiej podstawie?” i „czy sprawdzono?”.

## Typowe pułapki

- **Opis chronologiczny** („najpierw próbowałem…, potem…”) zamiast uporządkowanego.
- **Wyniki bez porównania z wymaganiami i obliczeniami.**
- **Zrzuty ekranu oscyloskopu bez opisu** skal, sond i warunków.
- **Brak instrukcji budowania oprogramowania** — po roku nikt nie skompiluje projektu.
- **Prezentacja bez demonstracji** albo demonstracja bez planu B.

## Ćwiczenie praktyczne

- [ ] Załóż repozytorium projektu ze strukturą: `docs/` (raport, wymagania, plan testów), `hardware/` (KiCad, pliki produkcyjne, BOM), `firmware/` lub `hdl/`, `measurements/` (dane, skrypty), `CHANGELOG.md`.
- [ ] Napisz streszczenie raportu (maks. 200 słów) jeszcze przed końcem projektu — pokaże, czego brakuje.
- [ ] Przygotuj 10-slajdową prezentację i nagraj 3-minutową demonstrację działania.

## Ćwiczenie komputerowe

Generowanie macierzy zgodności (Markdown) z wyników pomiarów — do wklejenia w raport:

```python
reqs = [  # ID, opis, granica, typ, wynik, niepewność rozszerzona, jednostka
    ('W1', 'Niepewność pomiaru temperatury', 0.5, '<=', 0.32, 0.05, '°C'),
    ('W3', 'Zasięg w terenie otwartym', 500, '>=', 1200, 100, 'm'),
    ('W4', 'Czas pracy na baterii', 1.0, '>=', 5.8, 0.4, 'lat'),
    ('W7', 'Tętnienia szyny 3,3 V', 20, '<=', 18, 3, 'mV p-p'),
]
def verdict(lim, typ, y, U):
    if typ == '<=': return 'spełnione' if y + U <= lim else ('niespełnione' if y - U > lim else 'niejednoznaczne')
    return 'spełnione' if y - U >= lim else ('niespełnione' if y + U < lim else 'niejednoznaczne')
print("| ID | Wymaganie | Granica | Wynik | Status |\n|---|---|---|---|---|")
for i, d, lim, typ, y, U, u in reqs:
    print(f"| {i} | {d} | {typ} {lim} {u} | {y} ± {U} {u} | {verdict(lim, typ, y, U)} |")
```

## Zadania

1. Przygotuj spis treści raportu dla swojego projektu według [szablonu](szablony/raport-techniczny.md).
2. Przepisz zdanie „Zastosowano kondensator 100 µF, bo tak było w nocie” w formie uzasadnienia inżynierskiego.
3. Jakie informacje musi zawierać podpis wykresu z oscyloskopu w raporcie?
4. Dlaczego niespełnione wymaganie powinno trafić do raportu z analizą przyczyn?
5. Zaplanuj demonstrację swojego urządzenia w 3 minutach, z planem B.

<details>
<summary>Odpowiedzi</summary>

1. —
2. Np. „Kondensator wyjściowy 100 µF (polimerowy, ESR 20 mΩ) dobrano na podstawie dopuszczalnego spadku napięcia 50 mV przy skoku obciążenia 1 A i paśmie pętli 20 kHz ($C \geq \Delta I/(2\pi f_c\Delta U) \approx 160$ µF — zastosowano 2 × 100 µF) oraz zakresu ESR zapewniającego stabilność według noty producenta; zmierzony spadek: 38 mV (rys. 12)”
3. Co mierzono (sygnał, punkt pomiaru), skale (V/dz, s/dz), sonda (tłumienie, sposób podłączenia masy), pasmo/filtr, warunki (obciążenie, napięcie zasilania), ewentualnie liczba uśrednień
4. Pokazuje rzetelność i zrozumienie, chroni przed powtórzeniem błędu, daje konkretne zadania na wersję 2; ukrycie niespełnienia podważa wiarygodność całej weryfikacji
5. Np. 30 s — cel i urządzenie; 90 s — działanie na żywo (pomiar, transmisja, wynik na ekranie); 60 s — kluczowy wykres z weryfikacji; plan B — nagranie wideo i zrzuty, zapasowy zasilacz i kabel
</details>

## Źródła

- [KiCad — dokumentacja](https://docs.kicad.org/) — eksport schematów, BOM i rysunków montażowych
- [Interrupt (blog Memfault)](https://interrupt.memfault.com/) — dokumentowanie i wersjonowanie projektów firmware
- [MIT 6.111 — projekty końcowe](https://ocw.mit.edu/courses/6-111-introductory-digital-systems-laboratory-spring-2006/) — przykłady raportów i prezentacji projektów
