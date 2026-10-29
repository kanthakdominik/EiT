# Lista kontrolna przeglądów

Odhaczaj w kopii dla każdego przeglądu; każdy punkt „nie” → zadanie z terminem.

## Przegląd schematu

- [ ] Każde wymaganie ma odzwierciedlenie w schemacie (macierz wymaganie → blok)
- [ ] Bilans mocy aktualny; zapasy prądowe stabilizatorów i przetwornic
- [ ] Zapasy napięciowe i mocowe elementów (derating), kondensatory ceramiczne z uwzględnieniem DC bias
- [ ] Każdy pin zasilania ma odsprzęganie; zasilanie analogowe filtrowane
- [ ] Piny nieużywane skonfigurowane / podłączone zgodnie z dokumentacją; brak pływających wejść
- [ ] Reset, zegar (kondensatory kwarcu policzone), złącze programowania, punkty testowe
- [ ] Poziomy logiczne zgodne między układami; rezystory podciągające I²C dobrane
- [ ] Ochrona złączy: ESD, odwrotna polaryzacja, przepięcia, bezpieczniki
- [ ] Notatki z obliczeniami przy elementach nieoczywistych; elementy DNP do strojenia
- [ ] ERC bez błędów (lub ze świadomie zaakceptowanymi ostrzeżeniami)
- [ ] Footprinty sprawdzone z kartami katalogowymi (numeracja pinów, wymiary, pad termiczny)

## Przegląd płytki

- [ ] Stos warstw uzgodniony z producentem; impedancje kontrolowane policzone
- [ ] Ciągła płaszczyzna masy pod sygnałami szybkimi; brak sygnałów nad podziałami
- [ ] Pętle prądu impulsowego przetwornic minimalne; węzły przełączające małe
- [ ] Kondensatory odsprzęgające przy pinach, przelotki przy padach
- [ ] Szerokości ścieżek zasilania policzone (prąd, spadek napięcia), liczba przelotek
- [ ] Strefy: zasilanie / cyfrowa / analogowa / w.cz.; antena ze strefą wolną od miedzi
- [ ] Elementy ochronne przy złączach z krótką drogą do masy/obudowy
- [ ] Termika: pola miedzi, przelotki termiczne, odległość elementów gorących od wrażliwych
- [ ] DRC bez błędów; odstępy izolacyjne dla wyższych napięć
- [ ] Opis: oznaczenia, polaryzacje, pin 1, wersja płytki, data, logo/nazwa
- [ ] Punkty testowe dostępne; otwory montażowe; kolizje z obudową (model 3D)
- [ ] Pliki produkcyjne wygenerowane i sprawdzone w przeglądarce Gerberów

## Przegląd oprogramowania / HDL

- [ ] Architektura udokumentowana (diagram stanów / zadań, przepływ danych)
- [ ] Obsługa błędów: czujnik nieobecny, utrata łączności, zasilanie niskie, watchdog
- [ ] Zmienne współdzielone z przerwaniami chronione; brak blokujących opóźnień w pętli głównej
- [ ] Testy jednostkowe logiki (na komputerze) / testbenche z PASS/FAIL (HDL)
- [ ] Ostrzeżenia kompilatora/syntezy przejrzane; brak niezamierzonych zatrzasków (HDL)
- [ ] Ograniczenia czasowe zdefiniowane, raport czasowy bez naruszeń (HDL)
- [ ] Sygnały asynchroniczne zsynchronizowane (HDL), reset zwalniany synchronicznie
- [ ] Wersja oprogramowania w pliku binarnym; instrukcja budowania w README
