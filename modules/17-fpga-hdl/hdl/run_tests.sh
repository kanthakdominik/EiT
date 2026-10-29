#!/usr/bin/env bash
# Uruchamia wszystkie testbenche (tb_*.v) w Icarus Verilog.
# Użycie: ./run_tests.sh   (wymaga: iverilog, vvp)
set -u
cd "$(dirname "$0")"
sources=$(ls *.v | grep -v '^tb_')
fail=0
for tb in tb_*.v; do
    top="${tb%.v}"
    echo "=== ${top}"
    if ! iverilog -g2012 -Wall -s "$top" -o "${top}.vvp" "$tb" $sources; then
        echo "FAIL: błąd kompilacji ${tb}"; fail=1; continue
    fi
    out=$(vvp -n "${top}.vvp")
    echo "$out"
    echo "$out" | grep -q '^PASS' || fail=1
done
rm -f ./*.vvp
if [ $fail -eq 0 ]; then echo "Wszystkie testbenche: PASS"; else echo "Co najmniej jeden testbench: FAIL"; fi
exit $fail
