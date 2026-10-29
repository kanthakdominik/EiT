# 24.03 — Mikrofony

## Po co to jest

Mikrofon jest w telefonie (często kilka — do redukcji szumu i kształtowania wiązki), laptopie, głośniku inteligentnym, aparacie słuchowym, systemie nagłośnieniowym i mierniku hałasu. Wybór mikrofonu i zaprojektowanie przedwzmacniacza wymaga przeliczenia czułości na napięcie, porównania szumu własnego z szumem wzmacniacza oraz sprawdzenia, czy najgłośniejszy dźwięk nie przesteruje toru.

## Teoria w pigułce

### Rodzaje

| Typ | Zasada | Cechy | Zastosowanie |
|---|---|---|---|
| **Dynamiczny** | Cewka w polu magnesu (indukcja) | Wytrzymały, nie wymaga zasilania, mała czułość (1–3 mV/Pa), niska impedancja | Scena, wokal |
| **Pojemnościowy** | Zmiana pojemności membrany i elektrody pod napięciem polaryzacji (48 V phantom) | Duża czułość, szerokie pasmo, wymaga zasilania i przedwzmacniacza | Studio, pomiary |
| **Elektretowy** (ECM) | Pojemnościowy z trwale naładowaną warstwą, wbudowany JFET | Tani, mały, zasilanie przez rezystor 2,2 kΩ z 1,5–10 V | Urządzenia powszechne |
| **MEMS** | Krzemowa membrana pojemnościowa + ASIC; wyjście analogowe lub cyfrowe (PDM, I²S) | Mały, powtarzalny, odporny na lutowanie rozpływowe, dobre dopasowanie egzemplarzy | Telefony, szyki mikrofonowe |
| Piezoelektryczny | Efekt piezoelektryczny | Odporny, duża impedancja | Przetworniki kontaktowe |

### Parametry

- **Czułość** — napięcie wyjściowe przy 1 Pa (94 dB SPL), zwykle w dBV/Pa: $S_{dBV} = 20\log_{10}(S/1\ \text{V/Pa})$. Np. −38 dBV/Pa = 12,6 mV/Pa. Mikrofony cyfrowe: dBFS przy 94 dB SPL (np. −26 dBFS).
- **SNR** — stosunek sygnału 94 dB SPL do szumu własnego (zwykle ważony A, 20 Hz–20 kHz). **Szum własny** (EIN akustyczny) $= 94 - \mathrm{SNR}$ dB(A) SPL — najcichszy dźwięk, który mikrofon „słyszy” ponad własnym szumem.
- **AOP** (akustyczny punkt przesterowania) — poziom SPL, przy którym THD osiąga 10%; razem z szumem własnym wyznacza zakres dynamiki.
- **Charakterystyka kierunkowa:** dookólna (ciśnieniowa), ósemkowa (gradientowa), kardioidalna i pochodne; mikrofony kierunkowe mają **efekt zbliżeniowy** (wzrost basu blisko źródła).
- Pasmo i równomierność, czułość na wibracje, odporność na zasilanie (PSRR dla MEMS).

### Przedwzmacniacz

- Wzmocnienie dobiera się tak, by maksymalny oczekiwany poziom wykorzystał zakres ADC z zapasem (headroom).
- **Szum wejściowy przedwzmacniacza** powinien być mniejszy niż szum mikrofonu przeliczony na napięcie: szum własny 29 dB(A) przy czułości 12,6 mV/Pa to ok. $12\text{,}6\ \text{mV}\cdot 10^{-65/20} = 7\text{,}1$ µV RMS — przedwzmacniacz musi mieć znacznie mniej (≈ 2 µV, czyli ok. 14 nV/√Hz w 20 kHz).
- Mikrofon dynamiczny 2 mV/Pa daje tylko 2 mV przy 94 dB — stąd przedwzmacniacze o szumie ok. 1 nV/√Hz i wzmocnieniu do 60 dB.
- Wejścia symetryczne (XLR) z dużym CMRR — odporność na zakłócenia w długich kablach ([16.05](../16-pcb-emc-konstrukcja/05-masa-i-uklady-mieszane.md)).

## Przykład rozwiązany

**Mikrofon MEMS analogowy:** czułość −38 dBV/Pa, SNR 65 dB(A), AOP 120 dB SPL. Przetwornik A/C: pełna skala 1 V RMS (0 dBFS).

1. Czułość: 12,6 mV/Pa. Szum własny: $94 - 65 = 29$ dB(A) SPL → 7,1 µV RMS na wyjściu.
2. Przy AOP (120 dB SPL, o 26 dB więcej niż 94 dB): $12\text{,}6\ \text{mV}\cdot 10^{26/20} = 251$ mV RMS.
3. Wzmocnienie tak, by AOP dał −1 dBFS: $20\log_{10}(0\text{,}89/0\text{,}251) = 11$ dB (×3,5). Wtedy 94 dB SPL → $-27$ dBFS.
4. Zakres dynamiki mikrofonu: $120 - 29 = 91$ dB — przetwornik powinien mieć zakres dynamiki ≥ 100 dB, żeby nie dodawał szumu (np. sigma-delta 24-bitowy o DR 105 dB).

## Typowe pułapki

- **Mylenie dBV/Pa z dBV** i przeliczanie czułości bez odniesienia 94 dB SPL.
- **Porównanie SNR mikrofonów mierzonych w różnych pasmach lub bez ważenia.**
- **Zbyt duże wzmocnienie** — przesterowanie przy głośnych dźwiękach (krzyk, uderzenie) i obcięcie w ADC; zbyt małe — szum przetwornika.
- **Zasilanie mikrofonu MEMS z hałaśliwej szyny** cyfrowej — tętnienia słychać w sygnale; filtr RC lub LDO.
- **Otwór akustyczny w obudowie** — wąski kanał i komora przed mikrofonem tworzą rezonator Helmholtza (podbicie kilku kHz); uszczelka między płytką a obudową.
- **Mikrofon cyfrowy PDM z długimi przewodami** — integralność zegara (MHz) i zakłócenia.

## Ćwiczenie komputerowe

Budżet poziomów toru mikrofon → przedwzmacniacz → ADC:

```python
import numpy as np

def mic_chain(sens_dbv, snr_dba, aop_spl, adc_fs_vrms=1.0, adc_dr=105, headroom_db=1.0, preamp_noise_v=2e-6):
    s = 10**(sens_dbv/20)                                 # V/Pa
    noise_mic = s*10**(-snr_dba/20)                       # V RMS przy szumie własnym
    v_aop = s*10**((aop_spl - 94)/20)
    gain = adc_fs_vrms*10**(-headroom_db/20)/v_aop
    n_adc_in = adc_fs_vrms*10**(-adc_dr/20)/gain          # szum ADC przeliczony na wejście przedwzmacniacza
    total = np.sqrt(noise_mic**2 + preamp_noise_v**2 + n_adc_in**2)
    print(f"czułość {s*1e3:.2f} mV/Pa, szum mikrofonu {noise_mic*1e6:.2f} µV, przy AOP {v_aop*1e3:.0f} mV")
    print(f"wzmocnienie {20*np.log10(gain):.1f} dB; szum: mikrofon {noise_mic*1e6:.2f}, przedwzm. {preamp_noise_v*1e6:.2f}, "
          f"ADC (na wejściu) {n_adc_in*1e6:.2f} µV → razem {total*1e6:.2f} µV")
    print(f"pogorszenie SNR przez elektronikę: {20*np.log10(total/noise_mic):.2f} dB; "
          f"94 dB SPL → {20*np.log10(s*gain/adc_fs_vrms):.1f} dBFS\n")

mic_chain(-38, 65, 120)                                   # MEMS z przykładu
mic_chain(-54, 70, 130, preamp_noise_v=0.5e-6)            # mikrofon dynamiczny (2 mV/Pa), niskoszumny przedwzmacniacz
```

## Zadania

1. Przelicz czułość −44 dBV/Pa na mV/Pa. Jakie napięcie da ten mikrofon przy 110 dB SPL?
2. Mikrofon cyfrowy: czułość −26 dBFS przy 94 dB SPL. Przy jakim SPL osiągnie pełną skalę?
3. Szum własny mikrofonu 20 dB(A) SPL, czułość 20 mV/Pa. Ile wynosi napięcie szumu?
4. Dlaczego mikrofony w szyku do kształtowania wiązki (beamforming) powinny mieć dobrze dopasowaną czułość i fazę?
5. Mikrofon kardioidalny przy wokalu z odległości 2 cm brzmi „basowo”. Dlaczego?

<details>
<summary>Odpowiedzi</summary>

1. $10^{-44/20} = 6\text{,}3$ mV/Pa; 110 dB SPL to +16 dB względem 94 dB → $6\text{,}3\cdot 6\text{,}31 = 40$ mV
2. $94 + 26 = 120$ dB SPL
3. $20\ \text{mV}\cdot 10^{(20 - 94)/20} = 20\ \text{mV}\cdot 10^{-3\text{,}7} = 4$ µV
4. Kształtowanie wiązki opiera się na odejmowaniu/sumowaniu sygnałów z różnymi opóźnieniami; różnice czułości i fazy między mikrofonami psują wygaszanie kierunków niepożądanych (głębokość „zer” charakterystyki) — stąd popularność MEMS o rozrzucie ±1 dB
5. Efekt zbliżeniowy: mikrofon gradientowy reaguje na różnicę ciśnień; w polu bliskim (krzywizna frontu fali) składowa gradientu rośnie dla niskich częstotliwości — podbicie basu nawet o 10–15 dB
</details>

## Źródła

- [TDK InvenSense — AN-1112: Microphone Specifications Explained](https://invensense.tdk.com/?p=6991)
- [sengpielaudio — kalkulatory czułości i poziomów](https://sengpielaudio.com/Calculations03.htm)
- [Elliott Sound Products (spis artykułów)](https://sound-au.com/site-map.htm) — przedwzmacniacze mikrofonowe, zasilanie phantom
